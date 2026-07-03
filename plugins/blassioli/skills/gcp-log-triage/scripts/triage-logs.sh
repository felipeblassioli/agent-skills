#!/usr/bin/env bash
# triage-logs.sh — collapse a noisy Google Cloud Logging export into signal.
#
# Reads Cloud Logging "LogEntry" data — a JSON array (the Logs Explorer "Download"
# button, or `gcloud logging read --format=json`) OR newline-delimited JSON objects
# — and prints one compact row per GCP trace (default). It never prints the
# repeated request `headers` / `track` blobs that dominate noisy app loggers, so it
# is safe to run on exports that contain Authorization headers or other secrets.
#
# Usage:
#   triage-logs.sh [options] [FILE]
#   gcloud logging read 'FILTER' --project=PROJECT --format=json | triage-logs.sh
#
# Options:
#   --by-trace   Collapse to one row per GCP `trace` (default). The main noise-cut:
#                one failed request emits 3-4 entries across the stdout, stderr and
#                requests streams that all share a single `trace`.
#   --flat       One row per log entry (signal fields only; never prints headers).
#   --errors     Keep only traces/entries that carry an error payload or status>=500.
#   --json       Emit JSON instead of an aligned table.
#   -h, --help   Show this help and exit.
#
# Field extraction is best-effort and tuned for a common structured-log jsonPayload
# shape (jsonPayload.error.{name,message,stack}, jsonPayload.statusCode,
# jsonPayload.message), with fallbacks for loggers that nest under `data`
# (jsonPayload.data.error.*) and for the platform httpRequest fields. It degrades
# gracefully on other shapes: unknown fields render as "-".
#
# Exit codes: 0 ok | 2 bad usage | 3 jq/processing error.
set -euo pipefail

MODE="by-trace"
ERRORS_ONLY="false"
OUTPUT="table"
FILE=""

die() { printf 'triage-logs.sh: %s\n' "$1" >&2; exit "${2:-2}"; }

usage() { awk 'NR>1 && /^#/ {sub(/^# ?/,""); print; next} NR>1 {exit}' "$0"; exit 0; }

command -v jq >/dev/null 2>&1 || die "jq is required but not found on PATH" 3

while [[ $# -gt 0 ]]; do
  case "$1" in
    --by-trace) MODE="by-trace" ;;
    --flat)     MODE="flat" ;;
    --errors)   ERRORS_ONLY="true" ;;
    --json)     OUTPUT="json" ;;
    -h|--help)  usage ;;
    --) shift; break ;;
    -*) die "unknown option: $1" ;;
    *)  [[ -z "$FILE" ]] || die "only one input FILE is supported"; FILE="$1" ;;
  esac
  shift
done
[[ $# -eq 0 ]] || { [[ -z "$FILE" ]] && FILE="$1" || die "only one input FILE is supported"; }

if [[ -n "$FILE" && ! -r "$FILE" ]]; then die "cannot read file: $FILE" 2; fi

# Normalize any accepted input into a single JSON array of LogEntry objects.
# `jq -s` slurps: a lone JSON array file -> [[...]] (unwrap); JSONL -> [obj,obj,...].
norm='if (length == 1 and (.[0]|type) == "array") then .[0] else . end'
if [[ -n "$FILE" ]]; then
  ENTRIES="$(jq -s "$norm" "$FILE" 2>/dev/null)" || die "input is not valid JSON" 3
else
  ENTRIES="$(jq -s "$norm" 2>/dev/null)" || die "stdin is not valid JSON" 3
fi

# Shared jq prelude: signal extraction + helpers. No headers/track ever leave here.
read -r -d '' PRELUDE <<'JQ' || true
def nz: if (. == null or . == "") then "-" else (.|tostring) end;
def clean: (. // "") | tostring | gsub("[\t\n\r]+"; " ");
def trunc($n): clean | if (length > $n) then (.[:$n] + "…") else . end;
def shorttrace: (. // "-") | tostring | sub(".*/traces/"; "");
def stream: (. // "") | tostring | ascii_downcase | sub(".*%2f"; "") | sub(".*/"; "");
def appframe($s):
  # First stack frame that looks like application code: an "at ..." line that is not
  # inside a dependency/build directory. Works across common runtimes/loggers.
  ($s // "") | tostring | [splits("\n")]
  | map(select(test("\\bat\\b") and (test("node_modules|/(dist|build|vendor)/|<anonymous>") | not)))
  | (.[0] // "") | gsub("^\\s*at\\s+"; "") | gsub("\\s+"; " ");
def sig:
  {
    time:     (.timestamp // .receiveTimestamp // ""),
    severity: ((.severity // .jsonPayload.severity // .jsonPayload.level // "") | ascii_upcase),
    stream:   (.logName | stream),
    service:  (.resource.labels.service_name // .resource.labels.function_name // .resource.labels.configuration_name // .resource.labels.namespace_name // .jsonPayload.application // ""),
    revision: (.resource.labels.revision_name // ""),
    trace:    (.trace | shorttrace),
    error:    (.jsonPayload.error.name // .jsonPayload.data.error.name // null),
    status:   (.jsonPayload.statusCode // .jsonPayload.error.statusCode // .jsonPayload.data.error.statusCode // .httpRequest.status // null),
    where:    appframe(.jsonPayload.error.stack // .jsonPayload.data.error.stack),
    message:  (.jsonPayload.error.message // .jsonPayload.data.error.message // .jsonPayload.message // .httpRequest.requestUrl // "")
  };
def worstsev($g): ($g | map(.severity // ""))
  | if any(.[]; . == "CRITICAL" or . == "ALERT" or . == "EMERGENCY") then "CRITICAL"
    elif any(.[]; . == "ERROR") then "ERROR"
    elif any(.[]; . == "WARNING") then "WARNING"
    elif any(.[]; . == "INFO") then "INFO"
    else (.[0] // "") end;
JQ

if [[ "$MODE" == "by-trace" ]]; then
  CORE='group_by(.trace // .insertId)
    | map(
        . as $g
        | ( ($g | map(select((.jsonPayload.error // .jsonPayload.data.error) != null)) | .[0])
            // ($g | map(select(.severity == "ERROR")) | .[0])
            // $g[0] ) as $rep
        | ($rep | sig) as $s
        | $s + {
            severity: worstsev($g),
            entries:  ($g | length),
            streams:  ($g | map(.logName | stream) | unique | join(","))
          }
      )'
else
  CORE='map(sig + { entries: 1, streams: (.logName | stream) })'
fi

if [[ "$ERRORS_ONLY" == "true" ]]; then
  CORE="$CORE"' | map(select((.error != null) or ((.status // 0) >= 500) or (.severity == "ERROR") or (.severity == "CRITICAL")))'
fi

if [[ "$OUTPUT" == "json" ]]; then
  printf '%s' "$ENTRIES" | jq "$PRELUDE $CORE" || die "jq processing failed" 3
else
  TABLE='( ["TIME","SEV","N","STREAMS","STATUS","ERROR","SERVICE","WHERE","MESSAGE","TRACE"] ),
    ( .[] | [ (.time|trunc(24)|nz), (.severity|nz), (.entries|tostring), (.streams|nz),
              (.status|nz), (.error|nz), (.service|nz), (.where|trunc(48)|nz),
              (.message|trunc(80)|nz), (.trace|nz) ] )
    | @tsv'
  printf '%s' "$ENTRIES" \
    | jq -r "$PRELUDE ($CORE) | $TABLE" \
    | column -t -s "$(printf '\t')" \
    || die "jq processing failed" 3
fi
