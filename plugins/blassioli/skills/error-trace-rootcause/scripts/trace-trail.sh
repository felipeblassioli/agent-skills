#!/usr/bin/env bash
# trace-trail.sh — reconstruct the full, ordered log trail for one request.
#
# The "smart correlation" core: given an error filter (e.g. an Error Reporting group),
# pick a representative occurrence, read its correlation key, then pull EVERY entry that
# shares it — all severities, all streams — ordered oldest-first into a causal chain.
# The key is the GCP `trace` for Cloud Run / Firebase Functions, OR the app
# `jsonPayload.traceId` for GKE (k8s_container has no top-level trace). Auto-detected from
# the representative; override with --trace / --app-id. Given a key directly, it just pulls.
#
# It never prints the request `headers`/`track` blobs, so it is safe on data containing
# Authorization tokens.
#
# Usage:
#   trace-trail.sh --project P --trace TRACE            # TRACE = bare HEX, full path, or trace="..."
#   trace-trail.sh --project P --filter 'FILTER'        # pick a representative, then its trail
#   trace-trail.sh --render < trail.json                # just order+render a JSON array you already have
#   gcloud logging read 'trace="..."' --format=json | trace-trail.sh --render
#
# Options:
#   --project P     GCP project (required for live fetch; inferred from a full trace path).
#   --trace TRACE   Pull the trail for this GCP trace (Cloud Run / Functions).
#   --app-id ID     Pull the trail for this app trace id (jsonPayload.traceId) — GKE, which
#                   has no top-level GCP trace. Auto-detected when --trace is given a UUID.
#   --filter 'F'    Find a representative occurrence matching F, then pull its trail.
#   --window D      Freshness window for fetches (default 1d; e.g. 2h, 7d).
#   --limit N       Max entries to fetch (default 1000).
#   --render        Read a LogEntry JSON array from stdin and render it; no gcloud calls.
#   --json          Emit the ordered trail as JSON instead of a table.
#   --dry-run       Print the gcloud commands instead of running them.
#   -h, --help      Show this help and exit.
#
# Exit codes: 0 ok | 2 bad usage | 3 jq/processing error | 4 gcloud missing (commands printed).
set -euo pipefail

PROJECT=""; TRACE=""; APPID=""; FILTER=""; WINDOW="1d"; LIMIT="1000"
RENDER="false"; OUTPUT="table"; DRYRUN="false"

die() { printf 'trace-trail.sh: %s\n' "$1" >&2; exit "${2:-2}"; }
usage() { awk 'NR>1 && /^#/ {sub(/^# ?/,""); print; next} NR>1 {exit}' "$0"; exit 0; }
note() { printf 'trace-trail.sh: %s\n' "$1" >&2; }

command -v jq >/dev/null 2>&1 || die "jq is required but not found on PATH" 3

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) PROJECT="${2:?}"; shift ;;
    --trace)   TRACE="${2:?}"; shift ;;
    --app-id)  APPID="${2:?}"; shift ;;
    --filter)  FILTER="${2:?}"; shift ;;
    --window)  WINDOW="${2:?}"; shift ;;
    --limit)   LIMIT="${2:?}"; shift ;;
    --render)  RENDER="true" ;;
    --json)    OUTPUT="json" ;;
    --dry-run) DRYRUN="true" ;;
    -h|--help) usage ;;
    --) shift; break ;;
    -*) die "unknown option: $1" ;;
    *)  die "unexpected argument: $1" ;;
  esac
  shift
done

# ---- jq prelude: signal extraction + ordered-trail renderer (no headers/track) -------
read -r -d '' PRELUDE <<'JQ' || true
def nz: if (. == null or . == "") then "-" else (.|tostring) end;
def clean: (. // "") | tostring | gsub("[\t\n\r]+"; " ");
def trunc($n): clean | if (length > $n) then (.[:$n] + "…") else . end;
def stream: (.logName // "") | tostring | ascii_downcase | sub(".*%2f"; "") | sub(".*/"; "");
def appframe($s): ($s // "") | tostring | [splits("\n")]
  | map(select(test("/workspace/") and (test("node_modules") | not)))
  | (.[0] // "") | gsub("^\\s*at\\s+"; "") | gsub("\\s+"; " ");
# seconds-of-day from an RFC3339 timestamp (trails are short; date rollover ignored)
def secs: (. // "") | tostring
  | (capture("T(?<h>[0-9]{2}):(?<m>[0-9]{2}):(?<s>[0-9]{2})(?<f>\\.[0-9]+)?") // null)
  | if . == null then 0 else ((.h|tonumber)*3600 + (.m|tonumber)*60 + (.s|tonumber) + ((.f // "0")|tonumber)) end;
def trail:
  sort_by(.timestamp)
  | (.[0].timestamp | secs) as $t0
  | to_entries | map(
      .key as $i | .value as $e |
      {
        seq:     ($i + 1),
        dms:     ((($e.timestamp|secs) - $t0) * 1000 | round),
        time:    ($e.timestamp // ""),
        severity:((($e.severity // $e.jsonPayload.level) // "") | ascii_upcase),
        stream:  ($e | stream),
        service: ($e.resource.labels.service_name // $e.resource.labels.function_name // $e.resource.labels.configuration_name // $e.resource.labels.namespace_name // $e.jsonPayload.application // ""),
        status:  ($e.jsonPayload.data.error.statusCode // $e.httpRequest.status // null),
        error:   ($e.jsonPayload.data.error.name // $e.jsonPayload.error.name // null),
        detail:  ( appframe($e.jsonPayload.data.error.stack // $e.jsonPayload.error.stack) as $w
                   | if ($w != "" and $w != null) then $w
                     else ($e.jsonPayload.message // $e.httpRequest.requestUrl // $e.textPayload // "") end )
      })
;
def to_table:
  ( ["#","+ms","SEV","STREAM","SERVICE","STATUS","ERROR","DETAIL"] ),
  ( .[] | [ (.seq|tostring), (.dms|tostring), (.severity|nz), (.stream|nz),
            (.service|nz), (.status|nz), (.error|nz), (.detail|trunc(90)) ] )
  | @tsv
;
JQ

render() {  # stdin: JSON array -> table or json
  if [[ "$OUTPUT" == "json" ]]; then
    jq "$PRELUDE trail" || die "jq processing failed" 3
  else
    jq -r "$PRELUDE (trail | to_table)" | column -t -s "$(printf '\t')" || die "jq processing failed" 3
  fi
}

if [[ "$RENDER" == "true" ]]; then
  render; exit 0
fi

# ---- live fetch paths ----------------------------------------------------------------
HAVE_GCLOUD="true"; command -v gcloud >/dev/null 2>&1 || HAVE_GCLOUD="false"
if [[ "$HAVE_GCLOUD" == "false" && "$DRYRUN" == "false" ]]; then
  note "gcloud not on PATH — printing commands instead of executing (use --render to format their JSON output)."
  DRYRUN="true"
fi

run_read() {  # $1 = filter, $2 = order ; echoes JSON (or the command in dry-run)
  local filter="$1" order="$2"
  if [[ "$DRYRUN" == "true" ]]; then
    printf 'gcloud logging read %q --project=%q --freshness=%q --limit=%q --order=%q --format=json\n' \
      "$filter" "$PROJECT" "$WINDOW" "$LIMIT" "$order" >&2
    printf '[]'
  else
    gcloud logging read "$filter" --project="$PROJECT" --freshness="$WINDOW" \
      --limit="$LIMIT" --order="$order" --format=json
  fi
}

# A GCP trace is 32 hex chars; an app trace id (GKE) is a dashed UUID.
is_uuid() { [[ "$1" =~ ^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$ ]]; }

# From a filter, pick a representative occurrence and read its correlation key. Prefer the
# GCP trace (Cloud Run / Functions); fall back to jsonPayload.traceId (GKE has no trace).
if [[ -z "$TRACE" && -z "$APPID" && -n "$FILTER" ]]; then
  [[ -n "$PROJECT" ]] || die "--filter needs --project"
  note "selecting a representative occurrence (most recent with a trace/traceId + richest error)…"
  REP="$(run_read "$FILTER" desc)"
  # Auto-retry: drop a console-only error-group clause if it returned nothing live.
  if [[ "$DRYRUN" == "false" ]] && [[ "$(printf '%s' "$REP" | jq 'length')" == "0" ]] \
     && printf '%s' "$FILTER" | grep -qiE 'error_?[gG]roups\.id'; then
    note "no matches; retrying without the errorGroups.id clause (gcloud may not support it)…"
    FILTER="$(printf '%s' "$FILTER" | sed -E '/error_?[gG]roups\.id/d')"
    REP="$(run_read "$FILTER" desc)"
  fi
  read -r CH_TRACE CH_APPID < <(printf '%s' "$REP" | jq -r '
    (map(select(((.trace // "") != "") or ((.jsonPayload.traceId // "") != "")))) as $c
    | (($c | map(select(.jsonPayload.data.error.stack != null)))[0] // $c[0] // null)
    | if . == null then "- -" else "\(.trace // "-") \(.jsonPayload.traceId // .jsonPayload.contextId // "-")" end')
  if [[ "$DRYRUN" == "true" ]]; then
    note "(dry-run) then pick a .trace (Cloud Run/Functions) or .jsonPayload.traceId (GKE) and re-run with --trace/--app-id"; exit 0
  fi
  if [[ -n "${CH_TRACE:-}" && "$CH_TRACE" != "-" ]]; then TRACE="$CH_TRACE"; note "representative GCP trace: $CH_TRACE"
  elif [[ -n "${CH_APPID:-}" && "$CH_APPID" != "-" ]]; then APPID="$CH_APPID"; note "representative app traceId (GKE): $CH_APPID"
  else die "no occurrence with a trace or jsonPayload.traceId found in the window" 3; fi
fi

# A UUID handed to --trace is really an app trace id (GKE).
if [[ -n "$TRACE" ]]; then
  _T="${TRACE#trace=}"; _T="${_T//\"/}"
  is_uuid "$_T" && { APPID="$_T"; TRACE=""; }
fi

# Build the trail filter for whichever correlation key we have.
if [[ -n "$TRACE" ]]; then
  T="${TRACE#trace=}"; T="${T//\"/}"
  if [[ "$T" == projects/*/traces/* ]]; then
    [[ -n "$PROJECT" ]] || PROJECT="$(printf '%s' "$T" | sed -n 's#projects/\([^/]*\)/traces/.*#\1#p')"
    TRACE_PATH="$T"
  else
    [[ -n "$PROJECT" ]] || die "a bare trace needs --project"
    TRACE_PATH="projects/${PROJECT}/traces/${T}"
  fi
  TRAIL_FILTER="trace=\"${TRACE_PATH}\""; LABEL="$TRACE_PATH"
elif [[ -n "$APPID" ]]; then
  [[ -n "$PROJECT" ]] || die "an app trace id (GKE) needs --project"
  A="${APPID//\"/}"
  TRAIL_FILTER="jsonPayload.traceId=\"${A}\" OR jsonPayload.contextId=\"${A}\""
  LABEL="jsonPayload.traceId=${A} (project ${PROJECT})"
else
  die "provide --trace, --app-id, --filter, or --render"
fi

note "pulling full trail for ${LABEL}"
TRAIL="$(run_read "$TRAIL_FILTER" asc)"
if [[ "$DRYRUN" == "true" ]]; then exit 0; fi
printf '%s' "$TRAIL" | render
