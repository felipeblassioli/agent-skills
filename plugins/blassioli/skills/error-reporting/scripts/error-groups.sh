#!/usr/bin/env bash
# error-groups.sh — read Cloud Error Reporting groups via the REST API (read-only).
#
# gcloud has no command to list error groups, so this calls the Error Reporting REST API
# (clouderrorreporting.googleapis.com) with a gcloud-minted access token. It respects the
# gcloud custom CA cert (corporate proxies) automatically. It projects only safe fields —
# never the full httpRequest, remoteIp, or user — so output is safe to paste.
#
# Modes:
#   list                 Rank a service's error groups by blast radius (groupStats.list).
#   detail GROUP_ID      One group's stats + representative stack/location.
#   events GROUP_ID      Recent occurrences of a group (events.list).
#
# Usage:
#   error-groups.sh list   --project P --service SVC [--version VER]
#   error-groups.sh detail GROUP_ID --project P
#   error-groups.sh events GROUP_ID --project P [--service SVC]
#
# Options:
#   --project P     GCP project (required).
#   --service SVC   serviceFilter.service (for GKE this is the reported serviceContext.service,
#                   e.g. the otel service name — not a resource label)
#   --version VER   serviceFilter.version
#   --resource-type T  serviceFilter.resourceType: cloud_function | cloud_run_revision | k8s_container
#   --period P      Window: 1h|6h|1d|1w|30d or a raw PERIOD_* value (default 1d).
#   --order O       list order: COUNT_DESC|LAST_SEEN_DESC|CREATED_DESC|AFFECTED_USERS_DESC (default COUNT_DESC).
#                   AFFECTED_USERS_DESC only ranks meaningfully when the service reports
#                   user context — it is often null for Node services, so the order can be moot.
#   --page-size N   Max groups/events (default 20). Ignored for `detail` (always 1).
#   --cacert FILE   CA bundle for curl (default: gcloud core/custom_ca_certs_file).
#   --json          Emit projected JSON instead of a table.
#   --dry-run       Print the curl command instead of calling.
#   -h, --help      Show this help and exit.
#
# Join to logs: the GROUP_ID equals the `errorGroups.id` log field. Error Reporting has
# NO trace id — to get a trace for a request trail, query errorGroups.id="GROUP_ID" in
# Cloud Logging and hand off to the error-trace-rootcause skill.
#
# Exit codes: 0 ok | 2 bad usage | 3 jq/processing error | 4 gcloud/token missing (dry-run printed) | 5 API error.
set -euo pipefail

MODE=""; GROUP_ID=""; PROJECT=""; SERVICE=""; VERSION=""; RESTYPE=""
PERIOD="1d"; ORDER="COUNT_DESC"; PAGE="20"; CACERT=""; OUTPUT="table"; DRYRUN="false"

die() { printf 'error-groups.sh: %s\n' "$1" >&2; exit "${2:-2}"; }
note() { printf 'error-groups.sh: %s\n' "$1" >&2; }
usage() { awk 'NR>1 && /^#/ {sub(/^# ?/,""); print; next} NR>1 {exit}' "$0"; exit 0; }

command -v jq >/dev/null 2>&1 || die "jq is required but not found on PATH" 3

[[ $# -gt 0 ]] || usage
case "$1" in list|detail|events) MODE="$1"; shift ;; -h|--help) usage ;; *) die "first arg must be: list | detail | events" ;; esac
if [[ "$MODE" == "detail" || "$MODE" == "events" ]]; then
  [[ $# -gt 0 && "${1:0:1}" != "-" ]] || die "$MODE needs a GROUP_ID"; GROUP_ID="$1"; shift
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project)   PROJECT="${2:?}"; shift ;;
    --service)   SERVICE="${2:?}"; shift ;;
    --version)   VERSION="${2:?}"; shift ;;
    --resource-type) RESTYPE="${2:?}"; shift ;;
    --period)    PERIOD="${2:?}"; shift ;;
    --order)     ORDER="${2:?}"; shift ;;
    --page-size) PAGE="${2:?}"; shift ;;
    --cacert)    CACERT="${2:?}"; shift ;;
    --json)      OUTPUT="json" ;;
    --dry-run)   DRYRUN="true" ;;
    -h|--help)   usage ;;
    *) die "unknown option: $1" ;;
  esac
  shift
done
[[ -n "$PROJECT" ]] || die "--project is required"

# Friendly period -> API enum.
case "$PERIOD" in
  1h)  PERIOD="PERIOD_1_HOUR" ;;  6h)  PERIOD="PERIOD_6_HOURS" ;;
  1d)  PERIOD="PERIOD_1_DAY" ;;   1w)  PERIOD="PERIOD_1_WEEK" ;;  30d) PERIOD="PERIOD_30_DAYS" ;;
  PERIOD_*) : ;;  *) die "bad --period: use 1h|6h|1d|1w|30d or a PERIOD_* value" ;;
esac

# Build the request path + query.
BASE="https://clouderrorreporting.googleapis.com/v1beta1/projects/${PROJECT}"
case "$MODE" in
  list)   URL="${BASE}/groupStats?timeRange.period=${PERIOD}&order=${ORDER}&pageSize=${PAGE}" ;;
  detail) URL="${BASE}/groupStats?timeRange.period=${PERIOD}&groupId=${GROUP_ID}&pageSize=1" ;;
  events) URL="${BASE}/events?timeRange.period=${PERIOD}&groupId=${GROUP_ID}&pageSize=${PAGE}" ;;
esac
[[ -n "$SERVICE" ]] && URL="${URL}&serviceFilter.service=${SERVICE}"
[[ -n "$VERSION" ]] && URL="${URL}&serviceFilter.version=${VERSION}"
[[ -n "$RESTYPE" ]] && URL="${URL}&serviceFilter.resourceType=${RESTYPE}"

# CA cert: explicit flag, else gcloud's configured custom CA (corporate proxy).
if [[ -z "$CACERT" ]] && command -v gcloud >/dev/null 2>&1; then
  CACERT="$(gcloud config get-value core/custom_ca_certs_file 2>/dev/null || true)"
  [[ "$CACERT" == "(unset)" ]] && CACERT=""
fi
CA_ARGS=(); [[ -n "$CACERT" && -r "$CACERT" ]] && CA_ARGS=(--cacert "$CACERT")

# Token (and dry-run fallback when gcloud/token is unavailable).
HAVE_GCLOUD="true"; command -v gcloud >/dev/null 2>&1 || HAVE_GCLOUD="false"
TOKEN=""
if [[ "$HAVE_GCLOUD" == "true" && "$DRYRUN" == "false" ]]; then
  TOKEN="$(gcloud auth print-access-token 2>/dev/null || true)"
  [[ -n "$TOKEN" ]] || { note "no access token (gcloud auth login?) — printing command instead"; DRYRUN="true"; }
elif [[ "$HAVE_GCLOUD" == "false" && "$DRYRUN" == "false" ]]; then
  note "gcloud not on PATH — printing command instead"; DRYRUN="true"
fi

if [[ "$DRYRUN" == "true" ]]; then
  printf 'curl -sS'; [[ ${#CA_ARGS[@]} -gt 0 ]] && printf ' --cacert %q' "$CACERT"
  printf ' -H %q %q\n' 'Authorization: Bearer $(gcloud auth print-access-token)' "$URL"
  exit "${4:-0}"
fi

BODY="$(mktemp)"; trap 'rm -f "$BODY"' EXIT
HTTP="$(curl -sS "${CA_ARGS[@]}" -m 30 -o "$BODY" -w '%{http_code}' \
  -H "Authorization: Bearer ${TOKEN}" "$URL" 2>/dev/null || echo 000)"
if [[ "$HTTP" != "200" ]]; then
  note "API returned HTTP ${HTTP}"; jq -r '.error.message // .' "$BODY" 2>/dev/null | head -5 >&2 || head -c 400 "$BODY" >&2
  exit 5
fi

# ---- safe-field projection (never httpRequest blob / remoteIp / user) ----------------
read -r -d '' PRELUDE <<'JQ' || true
def nz: if (. == null or . == "") then "-" else (.|tostring) end;
def line1: (. // "") | tostring | split("\n")[0] | gsub("\t"; " ");
def loc($r): if ($r == null) then "-" else "\($r.filePath // "?"):\($r.lineNumber // "?")" end;
def gstats: [ .errorGroupStats[]? | {
  groupId: .group.groupId, count: (.count // "0"), users: .affectedUsersCount,
  firstSeen: .firstSeenTime, lastSeen: .lastSeenTime, services: (.numAffectedServices // 1),
  error: (.representative.message | line1), where: loc(.representative.context.reportLocation) } ];
def events: [ .errorEvents[]? | {
  time: .eventTime, service: .serviceContext.service, version: .serviceContext.version,
  status: .context.httpRequest.responseStatusCode, method: .context.httpRequest.method,
  where: loc(.context.reportLocation), error: (.message | line1) } ];
JQ

if [[ "$MODE" == "events" ]]; then
  PROJ="events"; COLS='["TIME","SERVICE","VERSION","METHOD","STATUS","WHERE","ERROR"]'
  ROW='[(.time|nz),(.service|nz),(.version|nz),(.method|nz),(.status|nz),(.where|nz),(.error|nz)]'
else
  PROJ="gstats"; COLS='["GROUPID","COUNT","USERS","SERVICES","FIRSTSEEN","LASTSEEN","WHERE","ERROR"]'
  ROW='[(.groupId|nz),(.count|nz),(.users|nz),(.services|nz),(.firstSeen|nz),(.lastSeen|nz),(.where|nz),(.error|nz)]'
fi

if [[ "$OUTPUT" == "json" ]]; then
  jq "$PRELUDE ${PROJ}" "$BODY" || die "jq processing failed" 3
else
  jq -r "$PRELUDE (${COLS}), (${PROJ}[] | ${ROW}) | @tsv" "$BODY" \
    | column -t -s "$(printf '\t')" || die "jq processing failed" 3
fi
