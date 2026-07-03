#!/usr/bin/env bash
# logs-url-to-filter.sh — turn a Logs Explorer console URL (or a pasted UI query)
# into a clean `gcloud logging read` filter, project, and absolute time window.
#
# A Logs Explorer URL double-encodes the filter: `/` appears as `%252F`, newlines as
# `%0A`, quotes as `%22`. One URL-decode pass yields the canonical filter (logName keeps
# its `%2F`). This script does that decode, pulls the time window and project, normalizes
# the console-only `error_groups.id` to the queryable `errorGroups.id`, and prints either
# the parts or a ready-to-run command. It also drops console-only `-- comment` lines so
# AppHub workload queries (apphub.application.id / apphub.workload.id) run under gcloud.
#
# Usage:
#   logs-url-to-filter.sh 'CONSOLE_URL'
#   logs-url-to-filter.sh --gcloud 'CONSOLE_URL'      # print a runnable gcloud command
#   echo 'UI QUERY STRING' | logs-url-to-filter.sh -  # decode/normalize a pasted query
#
# Options:
#   --gcloud     Print a runnable `gcloud logging read` command (default: print parts).
#                NOTE: the emitted command is for the representative search
#                (--order=desc --limit=50), not the ordered full trail — pull the trail
#                with trace-trail.sh once you have a trace.
#   --no-time    Do not append timestamp>=/<= clauses from the URL window.
#   -h, --help   Show this help and exit.
#
# Output (default): shell-eval-able assignments FILTER, PROJECT, START, END.
# Exit codes: 0 ok | 2 bad usage.
set -euo pipefail

MODE="parts"; WANT_TIME="true"; INPUT=""

die() { printf 'logs-url-to-filter.sh: %s\n' "$1" >&2; exit "${2:-2}"; }
usage() { awk 'NR>1 && /^#/ {sub(/^# ?/,""); print; next} NR>1 {exit}' "$0"; exit 0; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --gcloud)  MODE="gcloud" ;;
    --no-time) WANT_TIME="false" ;;
    -h|--help) usage ;;
    -)         INPUT="$(cat)" ;;
    --)        shift; break ;;
    -*)        die "unknown option: $1" ;;
    *)         INPUT="$1" ;;
  esac
  shift
done
[[ -n "${INPUT:-}" ]] || { [[ $# -gt 0 ]] && INPUT="$1" || die "provide a console URL or pasted query (or '-' for stdin)"; }

# URL-decode: turn every %XX into \xXX and let printf %b interpret it. This collapses
# the double-encoded %252F -> %2F (correct for logName) and %0A -> newline in one pass.
urldecode() { local s="${1//+/ }"; printf '%b' "${s//%/\\x}"; }

# Field extraction is BSD/GNU-portable (no grep -P).
field() { printf '%s' "$INPUT" | sed -n "s/.*${1}=\\([^;?&]*\\).*/\\1/p" | head -1; }

if printf '%s' "$INPUT" | grep -q ';query='; then
  RAWQ="$(printf '%s' "$INPUT" | sed -n 's/.*;query=\([^;]*\).*/\1/p' | head -1)"
  FILTER="$(urldecode "$RAWQ")"
  # The console double-encodes grouping parens (%2528); after the single decode above they
  # remain %28/%29. Decode those (syntax, always safe) — but leave logName's %2F intact.
  FILTER="${FILTER//%28/(}"; FILTER="${FILTER//%29/)}"
else
  # Treat the whole input as an already-decoded UI query string.
  FILTER="$INPUT"
fi

PROJECT="$(field 'project' || true)"
START="$(field 'startTime' || true)"
END="$(field 'endTime' || true)"

# Normalize the console-only spelling to the queryable LogEntry field.
FILTER="${FILTER//error_groups.id/errorGroups.id}"

# Append the absolute window as filter clauses (gcloud --freshness only bounds "newer than").
if [[ "$WANT_TIME" == "true" ]]; then
  [[ -n "${START:-}" ]] && FILTER="${FILTER}"$'\n'"timestamp>=\"${START}\""
  [[ -n "${END:-}"   ]] && FILTER="${FILTER}"$'\n'"timestamp<=\"${END}\""
fi

# Drop console-only `-- comment` lines (gcloud filters have none) and blank lines.
FILTER="$(printf '%s' "$FILTER" | sed -e '/^[[:space:]]*--/d' -e '/^[[:space:]]*$/d')"

if [[ "$MODE" == "gcloud" ]]; then
  printf '# representative search (desc, limit 50) — pull the ordered trail with trace-trail.sh\n'
  printf 'gcloud logging read %q' "$FILTER"
  [[ -n "${PROJECT:-}" ]] && printf ' --project=%q' "$PROJECT"
  printf ' --order=desc --limit=50 --format=json\n'
else
  printf 'FILTER=%q\n'  "$FILTER"
  printf 'PROJECT=%q\n' "${PROJECT:-}"
  printf 'START=%q\n'   "${START:-}"
  printf 'END=%q\n'     "${END:-}"
fi
