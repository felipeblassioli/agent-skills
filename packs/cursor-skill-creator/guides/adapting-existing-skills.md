# Adapting Existing Skills

This pack is designed for sources that are not already Cursor-native.

## Common source types

- a Claude-style plugin or mixed plugin folder
- a plain skill directory with scripts and references
- design docs or hand-written guidance that should become an installed pack

## Adaptation defaults

- Prefer one pack-bundled workflow skill over a separate repo-root skill when the
  deliverable should install as one unit.
- Keep guidance inside bundled `skills/<folder>/` rather than copying it into
  `.cursor/rules` or README prose.
- Only create strict rules when they improve durable workflow behavior.
- Treat Claude-only automation as a redesign task, not a copy task.

## Good reasons to split artifacts

- reusable guidance that should install with the pack
- helper prompts that work better as subagents than as skill prose
- long-form docs or templates that would bloat the hot path

## Red flags

- direct references to repo-local top-level skills after installation
- Claude CLI assumptions such as `claude -p`
- machine-specific paths, usernames, or live credentials
