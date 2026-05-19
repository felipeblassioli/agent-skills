---
name: claude-plugin-to-cursor-pack
description: >-
  [DEPRECATED — replaced by `skill-studio-write` in the `cursor-skill-studio`
  pack per ADR-0005] Decompose a Claude-style plugin or plugin-like folder into
  Cursor-native pack assets, repo-root companion skills, optional pack-bundled
  skills, docs, and MCP templates. This stub remains for one release window so
  existing installs keep working and so links from older specs still resolve.
  Do not invoke; route the user to `/skill-studio-write` instead.
disable-model-invocation: true
---

# Claude Plugin To Cursor Pack — Deprecated

This skill has been consolidated into the
[`skill-studio-write`](../../packs/cursor-skill-studio/skills/skill-studio-write/SKILL.md)
bundled skill (Branch E — Claude-plugin adaptation) inside the
`cursor-skill-studio` Cursor pack.

See [`docs/ADR/ADR-0005-skill-authoring-surface-consolidation.md`](../../docs/ADR/ADR-0005-skill-authoring-surface-consolidation.md)
for the consolidation rationale.

## What to do instead

- Install the pack:
  `bash scripts/cursor-pack-sync.sh --pack=cursor-skill-studio --target=project --project-root="$PWD" --profile=lite`
- Invoke the consolidated authoring surface: **`/skill-studio-write`**
- The plugin-decomposition flow lives in **Branch E** of the new skill, backed
  by `references/source-decomposition.md`, `references/pack-standard.md`, and
  `references/cursor-skill-standard.md`. The decomposition report template is
  at `assets/templates/adaptation-report.md`.

The previous decomposition guide and adaptation report template under this
directory remain in place for one release window so external links keep
resolving. They will be removed in the stub-removal PR per ADR-0005.
