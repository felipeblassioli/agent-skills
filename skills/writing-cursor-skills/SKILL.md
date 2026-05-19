---
name: writing-cursor-skills
description: >-
  [DEPRECATED — replaced by `skill-studio-write` in the `cursor-skill-studio`
  pack per ADR-0005] Greenfield Cursor skill authoring through Socratic
  discovery, surface selection, archetype choice, and quality-gated scaffolding.
  This stub remains for one release window so existing installs keep working
  and so links from older specs still resolve. Do not invoke; route the user
  to `/skill-studio-write` instead.
disable-model-invocation: true
---

# Writing Cursor Skills — Deprecated

This skill has been consolidated into the
[`skill-studio-write`](../../packs/cursor-skill-studio/skills/skill-studio-write/SKILL.md)
bundled skill (Branch A — Greenfield skill) inside the `cursor-skill-studio`
Cursor pack.

See [`docs/ADR/ADR-0005-skill-authoring-surface-consolidation.md`](../../docs/ADR/ADR-0005-skill-authoring-surface-consolidation.md)
for the consolidation rationale.

## What to do instead

- Install the pack:
  `bash scripts/cursor-pack-sync.sh --pack=cursor-skill-studio --target=project --project-root="$PWD" --profile=lite`
- Invoke the consolidated authoring surface: **`/skill-studio-write`**
- Greenfield skill authoring lives in **Branch A** of the new skill, backed by
  `references/greenfield-discovery.md`, `references/surface-selection.md`,
  `references/skill-archetypes.md`, `references/cursor-skill-standard.md`, and
  `references/skill-quality-checklist.md`.

The previous reference files under this skill directory (`references/`,
`assets/`) remain in place for one release window so external links keep
resolving. They will be removed in the stub-removal PR per ADR-0005.
