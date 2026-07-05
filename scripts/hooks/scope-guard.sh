#!/usr/bin/env bash
# scope-guard.sh — scan a unified diff on stdin for content that must not enter
# this PUBLIC repository, and FAIL CLOSED (non-zero exit) when it finds any.
#
# Checks added ('+') lines only:
#   1. Generic secret/credential shapes (PEM private keys, cloud keys, provider
#      tokens, credentials embedded in URLs). These are generic patterns and are
#      safe to keep in a committed file — they match secret *values*, not names.
#   2. Email addresses whose domain is NOT on the permitted allowlist
#      (default: gmail.com + GitHub noreply). Catches a work/other identity.
#   3. Optional private denylist terms loaded from a file OUTSIDE the repo
#      (default: ~/.claude/scope-guard-denylist.txt). Absent => skipped. This is
#      where employer/private terms live, so they never enter this public repo.
#
# Interface: a unified diff on stdin, e.g. `git diff --cached | scope-guard.sh`.
# Harness-agnostic: usable from a Claude hook, a git pre-commit hook, or CI.
#
# Exit: 0 = clean; 1 = findings (reported on stderr). Override a verified false
# positive with SCOPE_GUARD_SKIP=1.
set -euo pipefail

[[ "${SCOPE_GUARD_SKIP:-}" == "1" ]] && exit 0

IFS=',' read -r -a ALLOWED_DOMAINS \
  <<< "${SCOPE_GUARD_ALLOWED_EMAIL_DOMAINS:-gmail.com,users.noreply.github.com,noreply.github.com}"
DENYLIST_FILE="${SCOPE_GUARD_DENYLIST:-$HOME/.claude/scope-guard-denylist.txt}"

# High-confidence, low-false-positive secret shapes. Parallel name/pattern arrays.
secret_names=(
  "PEM private key"
  "AWS access key id"
  "Google API key"
  "Slack token"
  "GitHub token"
  "JWT"
  "credentials in URL"
)
secret_patterns=(
  '-----BEGIN [A-Z ]*PRIVATE KEY-----'
  '(AKIA|ASIA)[0-9A-Z]{16}'
  'AIza[0-9A-Za-z_-]{35}'
  'xox[baprs]-[0-9A-Za-z]{10,}'
  'gh[pousr]_[0-9A-Za-z]{20,}'
  'eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}'
  '://[^/[:space:]:@]+:[^/[:space:]@]+@'
)

# Preload denylist terms (literal, case-insensitive) once.
deny_terms=()
if [[ -f "$DENYLIST_FILE" ]]; then
  while IFS= read -r term || [[ -n "$term" ]]; do
    term="${term#"${term%%[![:space:]]*}"}"   # ltrim
    [[ -z "$term" || "$term" == \#* ]] && continue
    deny_terms+=("$term")
  done < "$DENYLIST_FILE"
fi

trunc() { local s="$1"; (( ${#s} > 120 )) && printf '%s…' "${s:0:120}" || printf '%s' "$s"; }

current_file="(unknown)"
findings=()

while IFS= read -r raw || [[ -n "$raw" ]]; do
  case "$raw" in
    '+++ '*) current_file="${raw#+++ }"; current_file="${current_file#b/}"; continue ;;
    '--- '*) continue ;;
    '+'*)    line="${raw:1}" ;;
    *)       continue ;;
  esac

  # 1) secret/credential shapes
  for i in "${!secret_patterns[@]}"; do
    if [[ "$line" =~ ${secret_patterns[$i]} ]]; then
      findings+=("$current_file — ${secret_names[$i]}: $(trunc "$line")")
      break
    fi
  done

  # 2) emails outside the permitted allowlist
  while IFS= read -r email; do
    [[ -z "$email" ]] && continue
    dom="$(printf '%s' "${email##*@}" | tr '[:upper:]' '[:lower:]')"
    allowed=0
    for ad in "${ALLOWED_DOMAINS[@]}"; do [[ "$dom" == "$ad" ]] && { allowed=1; break; }; done
    (( allowed == 0 )) && findings+=("$current_file — non-permitted email domain '$dom': $email")
  done < <(printf '%s\n' "$line" | grep -oiE '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' || true)

  # 3) private denylist terms (loaded from OUTSIDE the repo)
  for term in "${deny_terms[@]}"; do
    if printf '%s' "$line" | grep -qiF -- "$term"; then
      findings+=("$current_file — denylisted term: $(trunc "$line")")
      break
    fi
  done
done

if (( ${#findings[@]} > 0 )); then
  {
    echo "scope-guard: refusing — staged/outgoing changes contain content that may not belong in this public repo:"
    printf '  - %s\n' "${findings[@]}"
    echo "If verified safe, re-run with SCOPE_GUARD_SKIP=1 to override."
  } >&2
  exit 1
fi
exit 0
