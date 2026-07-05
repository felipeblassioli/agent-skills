#!/usr/bin/env bash
# PostToolUse hook: validate a skill package right after its SKILL.md or
# metadata.json is edited, and surface findings back to the agent.
#
# FAIL-OPEN by design: this hook never blocks an edit. It always exits 0 and,
# when the validator reports errors or warnings, prints a PostToolUse
# `additionalContext` payload so the agent sees the findings inline. A clean
# skill (or a non-skill file) produces no output.
#
# Interface (harness-agnostic — the Claude Code trigger lives in
# .claude/settings.json, this script has no Claude-specific dependency):
#   - stdin: the hook event JSON; the edited path is read from
#     `.tool_input.file_path` (Edit/Write tools).
#   - OR argv: a file path as $1 (for direct testing and other runners).
#
# The real checks live in scripts/validate-skill.sh; this is only the wiring.
set -euo pipefail

# --- Resolve the edited file path (argv wins; otherwise stdin JSON) ----------
file_path=""
if [[ $# -ge 1 && -n "${1:-}" ]]; then
  file_path="$1"
else
  payload="$(cat)"
  file_path="$(printf '%s' "$payload" | jq -r '.tool_input.file_path // empty' 2>/dev/null)" || file_path=""
fi
[[ -n "$file_path" ]] || exit 0

# --- Only react to a skill's SKILL.md or metadata.json ------------------------
case "$(basename "$file_path")" in
  SKILL.md|metadata.json) ;;
  *) exit 0 ;;
esac

skill_dir="$(dirname "$file_path")"
# A metadata.json (or SKILL.md) only counts as a skill root when SKILL.md is there.
[[ -f "$skill_dir/SKILL.md" ]] || exit 0

# --- Locate the validator relative to this script (cwd-independent) -----------
validator="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/validate-skill.sh"
[[ -f "$validator" ]] || exit 0

# --- Run it (fail-open: swallow the validator's own non-zero exits) -----------
result="$(bash "$validator" "$skill_dir" 2>/dev/null)" || result=""
printf '%s' "$result" | jq empty >/dev/null 2>&1 || exit 0

# --- Emit additionalContext only when there is something to say ---------------
printf '%s' "$result" | jq \
  --arg dir "$skill_dir" '
  (.errors // []) as $e | (.warnings // []) as $w |
  if (($e | length) == 0) and (($w | length) == 0) then empty
  else
    { hookSpecificOutput: {
        hookEventName: "PostToolUse",
        additionalContext: (
          "Skill validation for \($dir) (scripts/validate-skill.sh). This hook is fail-open and did NOT block the edit; the release CI enforces the same checks, so fix these before release:\n"
          + (if ($e | length) > 0 then "ERRORS:\n" + ($e | map("  - " + .) | join("\n")) + "\n" else "" end)
          + (if ($w | length) > 0 then "WARNINGS:\n" + ($w | map("  - " + .) | join("\n")) else "" end)
        )
      } }
  end'
