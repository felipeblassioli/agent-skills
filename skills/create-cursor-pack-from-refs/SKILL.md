---
name: create-cursor-pack-from-refs
description: >-
  [DEPRECATED — replaced by `skill-studio-write` in the `cursor-skill-studio`
  pack per ADR-0005] Create Cursor packs from user-provided reference material
  and repo context. This stub remains for one release window so existing
  installs keep working and so links from older specs still resolve. Do not
  invoke; route the user to `/skill-studio-write` instead.
disable-model-invocation: true
---

# Create Cursor Pack From References — Deprecated

This skill has been consolidated into the
[`skill-studio-write`](../../packs/cursor-skill-studio/skills/skill-studio-write/SKILL.md)
bundled skill (Branch C — Pack from reference material) inside the
`cursor-skill-studio` Cursor pack.

See [`docs/ADR/ADR-0005-skill-authoring-surface-consolidation.md`](../../docs/ADR/ADR-0005-skill-authoring-surface-consolidation.md)
for the consolidation rationale.

## What to do instead

- Install the pack:
  `bash scripts/cursor-pack-sync.sh --pack=cursor-skill-studio --target=project --project-root="$PWD" --profile=lite`
- Invoke the consolidated authoring surface: **`/skill-studio-write`**
- The pack-scaffolding flow lives in **Branch C** of the new skill, backed by
  `references/material-intake.md`, `references/pack-standard.md`,
  `references/pack-archetypes.md`, and `references/pack-quality-checklist.md`.
  Pack templates are at `assets/templates/pack/`; the bundled-skill artifact
  fragment is at `assets/templates/bundled-skill-artifact.fragment.json`.
- The future advisory-MCP recommendation metadata growth spec now lives at
  `docs/specs/pack-recommendation-metadata.md`.

The previous reference files, pack templates, and validation wrapper script
under this directory remain in place for one release window so external links
keep resolving. They will be removed in the stub-removal PR per ADR-0005.
