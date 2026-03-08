#!/usr/bin/env bash
set -euo pipefail

payload="$(cat)"
file_path="$(printf '%s' "$payload" | jq -r '.file_path // ""')"

deny() {
  jq -n --arg message "$1" '{
    permission: "deny",
    user_message: $message
  }'
}

allow() {
  jq -n '{permission: "allow"}'
}

if [[ "$file_path" =~ (^|/)\.env($|[.]) ]] || [[ "$file_path" =~ \.(pem|p12|key)$ ]] || [[ "$file_path" =~ (credentials|secret|token)\.json$ ]]; then
  deny "Blocked read of a sensitive file. Move the needed value into a safe example or provide the minimum non-secret snippet manually."
  exit 0
fi

allow
