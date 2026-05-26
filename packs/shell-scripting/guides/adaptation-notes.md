# Adaptation Notes

This pack was adapted from the Claude plugin-shaped `shell-scripting` source in
the `claude-code-workflows` marketplace.

## What Changed

- Claude plugin metadata became pack metadata and release artifacts.
- Claude agents were renamed with a `shell-scripting-` prefix and adapted as
  Codex subagents under `.codex/agents/`.
- Claude skill folders became pack-bundled skills with pack-scoped `skillId`
  values.
- Long upstream reference prose was distilled into compact skill hot paths.

## What Did Not Carry Over

- Claude plugin cache metadata.
- Claude-only plugin manifest behavior.
- Hooks, MCP configuration, and slash-command UX, because the source plugin did
  not need them for this Codex install path.

## Attribution

The source plugin manifest credits Ryan Snodgrass and declares MIT licensing.
The marketplace repository license is MIT and is preserved in
`LICENSE.upstream.md`.
