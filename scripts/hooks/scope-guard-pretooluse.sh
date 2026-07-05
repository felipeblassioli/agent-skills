#!/usr/bin/env bash
# PreToolUse hook adapter (Claude Code): when the model is about to run
# `git commit` or `git push`, scan the diff about to enter history / leave for
# the remote with scope-guard.sh and DENY the tool call (fail closed) if it
# finds leak-shaped content.
#
# This is a thin Claude-Code adapter around the harness-agnostic
# scripts/hooks/scope-guard.sh (which any runner / CI can call directly).
#
# Contract: reads the PreToolUse event JSON on stdin (.tool_input.command,
# .cwd). To block, prints a PreToolUse `permissionDecision: deny` payload and
# exits 0; otherwise exits 0 silently (defers to the normal flow).
set -euo pipefail

payload="$(cat)"
cmd="$(printf '%s' "$payload" | jq -r '.tool_input.command // empty' 2>/dev/null)" || cmd=""
[[ -n "$cmd" ]] || exit 0

# Only react to `git commit` / `git push`. Over-detection is harmless (a clean
# diff is allowed); we only ever block on an actual finding.
is_commit=0; is_push=0
if printf '%s' "$cmd" | grep -Eqw 'git'; then
  printf '%s' "$cmd" | grep -Eqw 'commit' && is_commit=1 || true
  printf '%s' "$cmd" | grep -Eqw 'push'   && is_push=1   || true
fi
(( is_commit || is_push )) || exit 0

cwd="$(printf '%s' "$payload" | jq -r '.cwd // empty' 2>/dev/null)" || cwd=""
[[ -n "$cwd" && -d "$cwd" ]] || cwd="${CLAUDE_PROJECT_DIR:-$PWD}"
cd "$cwd" 2>/dev/null || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

# Pick the diff to scan.
diff_out=""
if (( is_commit )); then
  diff_out="$(git diff --cached 2>/dev/null)" || diff_out=""
else
  # push: scan commits not yet on the upstream (best-effort). The commit-time
  # gate is the primary net; this is a backstop.
  if upstream="$(git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>/dev/null)"; then
    diff_out="$(git diff "${upstream}...HEAD" 2>/dev/null)" || diff_out=""
  else
    base="$(git rev-parse --verify --quiet origin/HEAD 2>/dev/null \
         || git rev-parse --verify --quiet origin/main 2>/dev/null || true)"
    [[ -n "$base" ]] && { diff_out="$(git diff "${base}...HEAD" 2>/dev/null)" || diff_out=""; }
  fi
fi
[[ -n "$diff_out" ]] || exit 0

guard_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
report="$(printf '%s\n' "$diff_out" | bash "$guard_dir/scope-guard.sh" 2>&1 1>/dev/null)" && rc=0 || rc=$?

if (( rc != 0 )); then
  op="$([[ $is_commit -eq 1 ]] && echo commit || echo push)"
  reason="$(printf 'scope-guard blocked this git %s — the diff contains content that may not belong in this public repo:\n\n%s' "$op" "$report")"
  jq -n --arg r "$reason" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $r
    }
  }'
fi
exit 0
