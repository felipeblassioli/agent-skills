#!/usr/bin/env bash
# errors-url-to-query.sh — parse an Error Reporting console URL into its parts.
#
# Error Reporting console URLs use ;matrix=params and a /detail/<groupId> path segment:
#   list:   https://console.cloud.google.com/errors;service=SVC;version=VER?project=P
#   detail: https://console.cloud.google.com/errors/detail/GROUP_ID;service=SVC;version=VER;locations=global?project=P
# This extracts PROJECT, GROUP_ID (detail only), SERVICE, VERSION, LOCATION and prints
# eval-able assignments, or a ready `error-groups.sh` invocation with --cmd.
#
# Usage:
#   errors-url-to-query.sh 'CONSOLE_URL'
#   errors-url-to-query.sh --cmd 'CONSOLE_URL'     # print an error-groups.sh command
#   echo 'CONSOLE_URL' | errors-url-to-query.sh -
#
# Options:
#   --cmd        Print a runnable error-groups.sh command (detail if a group id is present,
#                else a list).
#   -h, --help   Show this help and exit.
#
# Exit codes: 0 ok | 2 bad usage.
set -euo pipefail

MODE="parts"; INPUT=""
die() { printf 'errors-url-to-query.sh: %s\n' "$1" >&2; exit "${2:-2}"; }
usage() { awk 'NR>1 && /^#/ {sub(/^# ?/,""); print; next} NR>1 {exit}' "$0"; exit 0; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --cmd)     MODE="cmd" ;;
    -h|--help) usage ;;
    -)         INPUT="$(cat)" ;;
    --)        shift; break ;;
    -*)        die "unknown option: $1" ;;
    *)         INPUT="$1" ;;
  esac
  shift
done
[[ -n "${INPUT:-}" ]] || { [[ $# -gt 0 ]] && INPUT="$1" || die "provide an Error Reporting console URL (or '-' for stdin)"; }

# matrix/query field extraction, BSD/GNU-portable (bounded by ; ? & or end).
field() { printf '%s' "$INPUT" | sed -n "s/.*[;?&]${1}=\\([^;?&]*\\).*/\\1/p" | head -1; }

# group id = the path segment after /errors/detail/ up to the first ; ? or /
GROUP_ID="$(printf '%s' "$INPUT" | sed -n 's#.*/errors/detail/\([^;?/]*\).*#\1#p' | head -1)"
SERVICE="$(field 'service' || true)"
VERSION="$(field 'version' || true)"
LOCATION="$(field 'locations' || true)"
PROJECT="$(field 'project' || true)"

if [[ "$MODE" == "cmd" ]]; then
  DIR='${CLAUDE_SKILL_DIR:-.}/scripts'
  if [[ -n "${GROUP_ID:-}" ]]; then
    printf '%s/error-groups.sh detail %q --project %q' "$DIR" "$GROUP_ID" "${PROJECT:-PROJECT}"
  else
    printf '%s/error-groups.sh list --project %q' "$DIR" "${PROJECT:-PROJECT}"
  fi
  [[ -n "${SERVICE:-}" ]] && printf ' --service %q' "$SERVICE"
  [[ -n "${VERSION:-}" ]] && printf ' --version %q' "$VERSION"
  printf '\n'
else
  printf 'PROJECT=%q\n'  "${PROJECT:-}"
  printf 'GROUP_ID=%q\n' "${GROUP_ID:-}"
  printf 'SERVICE=%q\n'  "${SERVICE:-}"
  printf 'VERSION=%q\n'  "${VERSION:-}"
  printf 'LOCATION=%q\n' "${LOCATION:-}"
fi
