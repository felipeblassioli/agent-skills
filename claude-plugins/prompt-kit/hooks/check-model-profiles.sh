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
# Staleness belongs to staleness_rule, evaluated when a consumer is about to
# quote a nuance — the only moment it can change what happens.
#
# Silent and exit 0 when the file is present and consistent.
set -uo pipefail

# Optional path is for local validation/tests; SessionStart uses the installed file.
profile="${1:-${HOME}/.claude/model-profiles.md}"

if ! command -v python3 >/dev/null 2>&1; then
  echo 'prompt-kit: profile validation unavailable (python3 required).' >&2
  exit 0
fi

note() {  # emit a SessionStart additionalContext note and exit
  python3 -c 'import json,sys; print(json.dumps({"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":sys.stdin.read()}}))' <<< "$1"
  exit 0
}

if [ ! -f "$profile" ]; then
  note "prompt-kit is loaded but its shared routing source ~/.claude/model-profiles.md is MISSING. model-recommender, prompt-audit and tailor-to-fable read this file (tier_to_model, delegation_aliases, routing_rubric, execution_signals, per-model profiles) at runtime and cannot resolve a tier, an Agent-tool model alias, or a model string without it. If the user invokes any of them, tell them to install it first (see the prompt-kit README) — do not guess model strings from memory."
fi

if ! command -v yq >/dev/null 2>&1 || ! yq --version 2>/dev/null | grep -q 'mikefarah/yq.*version v4'; then
  note 'prompt-kit: profile validation unavailable. Install Mike Farah yq v4; routing data has not been checked.'
fi

tmp="$(mktemp -d)" || exit 0
trap 'rm -rf "$tmp"' EXIT
if ! awk -v d="$tmp" '/^```yaml$/{inb=1;n++;next} /^```$/{inb=0;next} inb{print >> (d "/b" n ".yaml")} END{if(inb) exit 1}' "$profile"; then
  note 'prompt-kit: model-profiles.md contains an unclosed yaml fence; routing data is unavailable.'
fi

problems=()
blocks=("$tmp"/b*.yaml)
if [ ! -e "${blocks[0]}" ]; then
  note 'prompt-kit: model-profiles.md contains no non-empty fenced yaml blocks; routing data is unavailable.'
fi

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
  for k in tier_to_model delegation_aliases routing_rubric execution_signals staleness_rule context_cost_rule \
    routing_rubric.where routing_rubric.consequence_override \
    execution_signals.escalate_when execution_signals.de_escalate_when \
    execution_signals.session_lifecycle; do
    yq -e ".$k" "$tmp/all.yaml" >/dev/null 2>&1 || problems+=("required block \`$k\` is missing")
  done
  # Both extensions are optional for legacy consumers; partial adoption is a defect.
  # See README Shared profiles and PR #136 review: never require an implicit migration.
  if yq -e '.execution_signals | (has("reassess_when") or has("reassess"))' "$tmp/all.yaml" >/dev/null 2>&1; then
    for k in reassess_when reassess; do
      yq -e ".execution_signals.$k" "$tmp/all.yaml" >/dev/null 2>&1 || problems+=("required block \`execution_signals.$k\` is missing from the reassessment extension")
    done
  fi
  identity_fields="$(yq '[.[] | select(tag=="!!map") | select(has("model_id") or has("delegation_alias"))] | length' "$tmp/all.yaml")"
  if [ "$identity_fields" != 0 ]; then
    incomplete="$(yq '[.[] | select(tag=="!!map") | select(has("tier") and has("api_verified")) | select(.model_id == null or .model_id == "" or .delegation_alias == null or .delegation_alias == "")] | length' "$tmp/all.yaml")"
    [ "$incomplete" = 0 ] || problems+=("profile identity extension is incomplete — every profile needs model_id and delegation_alias")
  fi
  tiers="$(yq -o=json -I=0 '.tier_to_model | keys | sort' "$tmp/all.yaml" 2>/dev/null)"
  for k in delegation_aliases routing_rubric.tier; do
    got="$(yq -o=json -I=0 ".$k | keys | sort" "$tmp/all.yaml" 2>/dev/null)"
    [ "$got" = "$tiers" ] || problems+=("\`$k\` covers $got but tier_to_model covers $tiers — a tier without an alias or a rubric entry cannot be routed")
  done
  # 3. every tier must have a profile block claiming it
  ptiers="$(yq -o=json -I=0 '[.. | select(tag=="!!map") | select(has("tier") and has("api_verified")) | .tier] | unique | sort' "$tmp/all.yaml" 2>/dev/null)"
  [ "$ptiers" = "$tiers" ] || problems+=("profile blocks claim tiers $ptiers but tier_to_model defines $tiers — a tier with no profile makes every recommendation for it a guess")

  # Profile identity is explicit: tier coverage alone accepts stale model mappings.
  # Compare aliases to the profile snapshot, not an evergreen built-in model enum.
  while IFS= read -r tier; do
    if [ "$identity_fields" = 0 ]; then
      count="$(TIER="$tier" yq '[.[] | select(tag=="!!map") | select(has("api_verified") and .tier == strenv(TIER))] | length' "$tmp/all.yaml")"
      [ "$count" = 1 ] || problems+=("legacy tier $tier must have exactly one candidate profile (found $count)")
      continue
    fi
    model="$(TIER="$tier" yq -r '.tier_to_model[strenv(TIER)]' "$tmp/all.yaml")"
    matches="$(MODEL="$model" yq -o=json -I=0 '[.[] | select(tag=="!!map") | select(.model_id == strenv(MODEL))]' "$tmp/all.yaml")"
    count="$(printf '%s' "$matches" | yq 'length')"
    if [ "$count" != 1 ]; then
      problems+=("tier $tier must resolve to exactly one profile by model_id (found $count)")
      continue
    fi
    claimed_tier="$(printf '%s' "$matches" | yq -r '.[0].tier')"
    [ "$claimed_tier" = "$tier" ] || problems+=("resolved profile has the wrong tier for $tier")
    alias="$(TIER="$tier" yq -r '.delegation_aliases[strenv(TIER)]' "$tmp/all.yaml")"
    profile_alias="$(printf '%s' "$matches" | yq -r '.[0].delegation_alias')"
    if [ "$alias" = null ] || [ -z "$alias" ] || [ "$alias" != "$profile_alias" ]; then
      problems+=("delegation alias for $tier does not match its resolved profile snapshot")
    fi
  done < <(yq -r '.tier_to_model | keys | .[]' "$tmp/all.yaml")

else
  problems+=("combined yaml is not a mapping that can be validated")
fi

[ ${#problems[@]} -eq 0 ] && exit 0

msg="prompt-kit's shared routing source ~/.claude/model-profiles.md has consistency problems found at session start:"
for p in "${problems[@]}"; do msg="$msg
  - $p"; done
msg="$msg
Before quoting anything from that file, tell the user what is broken. Parse failures mean the yaml is not the data any more — fix the file rather than reading the prose around it. Every problem above is a real defect in the file, not an aging date — fix it before relying on the routing data."
note "$msg"
