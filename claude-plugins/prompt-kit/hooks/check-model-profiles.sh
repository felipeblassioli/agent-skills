#!/usr/bin/env bash
# prompt-kit SessionStart guard.
#
# model-recommender and prompt-audit read ~/.claude/model-profiles.md
# (tier_to_model + routing_rubric + per-model profiles) at runtime; without it
# they cannot resolve a tier or a model string. Surface that at the session
# boundary so a fresh install fails loudly here, not mid-task.
#
# No-op and silent when the file is present (exit 0, no output).
set -euo pipefail

profile="${HOME}/.claude/model-profiles.md"
[ -f "$profile" ] && exit 0

# Missing: inject a session note so Claude warns the user instead of guessing.
cat << 'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "prompt-kit is loaded but its shared routing source ~/.claude/model-profiles.md is MISSING. The model-recommender and prompt-audit skills read this file (tier_to_model + routing_rubric + per-model profiles) at runtime and cannot resolve a tier or a model string without it. If the user invokes either skill, tell them to install ~/.claude/model-profiles.md first (see the prompt-kit README) — do not guess model strings from memory."
  }
}
EOF
exit 0
