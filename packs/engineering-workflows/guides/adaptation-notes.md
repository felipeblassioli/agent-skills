# Adaptation Notes

This pack was adapted from a Claude plugin-shaped source tree.

## What changed

- Slash-command framing such as `/standup` and `/debug` was rewritten into
  normal bundled skill routing.
- `.claude-plugin/plugin.json` became pack metadata and release artifacts.
- `.mcp.json` became example-only `.cursor/mcp.example.json`.
- Shared connector explanations became human-facing guides instead of relative
  links from each skill.

## What did not carry over directly

- Claude-local settings paths
- Claude-hosted MCP endpoints for Gmail and Google Calendar
- any assumption that the pack should overwrite a live `mcp.json`

## Follow-up work

- review attribution and redistribution expectations before publishing
- decide whether any bundled workflow should become a repo-root skill later
