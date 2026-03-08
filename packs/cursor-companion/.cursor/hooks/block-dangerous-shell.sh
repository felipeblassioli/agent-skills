#!/usr/bin/env bash
set -euo pipefail

payload="$(cat)"
command="$(printf '%s' "$payload" | jq -r '.command // ""')"

deny() {
  jq -n --arg user_message "$1" --arg agent_message "$2" '{
    permission: "deny",
    user_message: $user_message,
    agent_message: $agent_message
  }'
}

allow() {
  jq -n '{permission: "allow"}'
}

if [[ "$command" =~ (^|[[:space:]])rm[[:space:]]+-rf[[:space:]]+/($|[[:space:]]) ]]; then
  deny "Blocked destructive shell command: refusing rm -rf /" "The hook blocked a destructive shell command. Use a narrower, explicitly reviewed command instead."
  exit 0
fi

if [[ "$command" =~ git[[:space:]]+reset[[:space:]]+--hard ]] || [[ "$command" =~ git[[:space:]]+clean[[:space:]]+-x?fd ]]; then
  deny "Blocked destructive git cleanup command." "The hook blocked a destructive git command. Prefer reversible inspection or ask for explicit approval."
  exit 0
fi

allow
