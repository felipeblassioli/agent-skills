#!/usr/bin/env bash
set -euo pipefail

payload="$(cat)"
log_root="${CURSOR_PROJECT_DIR:-$HOME/.cursor}"
audit_dir="$log_root/.work/cursor-hook-audit"
mkdir -p "$audit_dir"

jq -c '{
  hook_event_name,
  subagent_type,
  status,
  task,
  summary,
  duration_ms,
  timestamp: now
}' <<<"$payload" >>"$audit_dir/subagents.ndjson" 2>/dev/null || true

if jq -e '.hook_event_name == "subagentStart"' <<<"$payload" >/dev/null 2>&1; then
  jq -n '{permission: "allow"}'
fi
