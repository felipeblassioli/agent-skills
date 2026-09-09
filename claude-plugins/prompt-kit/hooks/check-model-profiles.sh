#!/usr/bin/env bash
# prompt-kit SessionStart guard for the shared routing source.
#
# model-recommender, prompt-audit and tailor-to-fable parse
# ~/.claude/model-profiles.md at runtime. Two failure modes are invisible to
# them and were both live in the wild:
#   1. a ```yaml block that does not parse — the consumer silently falls back to
#      reading the prose, so routing data becomes a guess;
#   2. a tier with no profile block, or a tier missing from delegation_aliases —
#      the consumer then has nothing to resolve and guesses.
# Check both at the session boundary so they fail loudly here, not mid-task.
#
# Deliberately NOT checked here: profile staleness. Dates age every day and some
# gaps (no published prompting page for a model) cannot be closed, so a boot-time
# staleness warning fires forever and trains the reader to ignore the hook.
# Staleness belongs to meta.staleness_rule, evaluated when a consumer is about to
# quote a nuance — the only moment it can change what happens.
#
# Silent and exit 0 when the file is present and consistent.
set -uo pipefail

profile="${HOME}/.claude/model-profiles.md"

note() {  # emit a SessionStart additionalContext note and exit
  python3 -c 'import json,sys; print(json.dumps({"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":sys.stdin.read()}}))' <<< "$1"
  exit 0
}

if [ ! -f "$profile" ]; then
  note "prompt-kit is loaded but its shared routing source ~/.claude/model-profiles.md is MISSING. model-recommender, prompt-audit and tailor-to-fable read this file (tier_to_model, delegation_aliases, routing_rubric, execution_signals, per-model profiles) at runtime and cannot resolve a tier, an Agent-tool model alias, or a model string without it. If the user invokes any of them, tell them to install it first (see the prompt-kit README) — do not guess model strings from memory."
fi

command -v yq >/dev/null 2>&1 || exit 0   # structural checks need yq; absence is not an error
command -v python3 >/dev/null 2>&1 || exit 0

tmp="$(mktemp -d)" || exit 0
trap 'rm -rf "$tmp"' EXIT
awk -v d="$tmp" '/^```yaml$/{inb=1;n++;next} /^```$/{inb=0;next} inb{print >> (d "/b" n ".yaml")}' "$profile"

problems=()

# 1. every yaml block must parse, and no list item may silently become a map
for b in "$tmp"/b*.yaml; do
  [ -e "$b" ] || break
  if ! yq -e 'keys' "$b" >/dev/null 2>&1; then
    problems+=("a \`\`\`yaml block does not parse ($(yq 'keys' "$b" 2>&1 | head -1)) — consumers cannot read the routing data from it")
  fi
done
cat "$tmp"/b*.yaml > "$tmp/all.yaml" 2>/dev/null
if yq -e 'keys' "$tmp/all.yaml" >/dev/null 2>&1; then
  bad_items="$(yq -o=json -I=0 '[.. | select(tag=="!!seq") | .[] | select(tag=="!!map")] | length' "$tmp/all.yaml" 2>/dev/null)"
  [ "${bad_items:-0}" != "0" ] && problems+=("$bad_items list item(s) parse as a map instead of a string — a note containing \": \" needs quoting or rewording")

  # 2. the contract the skills depend on
  for k in tier_to_model delegation_aliases routing_rubric execution_signals; do
    yq -e ".$k" "$tmp/all.yaml" >/dev/null 2>&1 || problems+=("required block \`$k\` is missing")
  done
  tiers="$(yq -o=json -I=0 '.tier_to_model | keys | sort' "$tmp/all.yaml" 2>/dev/null)"
  for k in delegation_aliases routing_rubric.tier; do
    got="$(yq -o=json -I=0 ".$k | keys | sort" "$tmp/all.yaml" 2>/dev/null)"
    [ "$got" = "$tiers" ] || problems+=("\`$k\` covers $got but tier_to_model covers $tiers — a tier without an alias or a rubric entry cannot be routed")
  done
  # 3. every tier must have a profile block claiming it
  ptiers="$(yq -o=json -I=0 '[.. | select(tag=="!!map") | select(has("tier") and has("api_verified")) | .tier] | unique | sort' "$tmp/all.yaml" 2>/dev/null)"
  [ "$ptiers" = "$tiers" ] || problems+=("profile blocks claim tiers $ptiers but tier_to_model defines $tiers — a tier with no profile makes every recommendation for it a guess")

fi

[ ${#problems[@]} -eq 0 ] && exit 0

msg="prompt-kit's shared routing source ~/.claude/model-profiles.md has consistency problems found at session start:"
for p in "${problems[@]}"; do msg="$msg
  - $p"; done
msg="$msg
Before quoting anything from that file, tell the user what is broken. Parse failures mean the yaml is not the data any more — fix the file rather than reading the prose around it. Every problem above is a real defect in the file, not an aging date — fix it before relying on the routing data."
note "$msg"
