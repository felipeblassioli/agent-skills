---
name: create-skill-from-refs
description: >-
  [DEPRECATED — replaced by `skill-studio-write` in the `cursor-skill-studio`
  pack per ADR-0005] Create Cursor Agent Skills from user-provided reference
  material (documents, code, examples, URLs). This stub remains for one release
  window so existing installs keep working and so links from older specs still
  resolve. Do not invoke; route the user to `/skill-studio-write` instead.
disable-model-invocation: true
---

# Create Skill From References — Deprecated

This skill has been consolidated into the
[`skill-studio-write`](../../packs/cursor-skill-studio/skills/skill-studio-write/SKILL.md)
bundled skill (Branch B — Skill from reference material) inside the
`cursor-skill-studio` Cursor pack.

See [`docs/ADR/ADR-0005-skill-authoring-surface-consolidation.md`](../../docs/ADR/ADR-0005-skill-authoring-surface-consolidation.md)
for the consolidation rationale.

## What to do instead

- Install the pack:
  `bash scripts/cursor-pack-sync.sh --pack=cursor-skill-studio --target=project --project-root="$PWD" --profile=lite`
- Invoke the consolidated authoring surface: **`/skill-studio-write`**
- The reference-distillation flow lives in **Branch B** of the new skill,
  backed by `references/material-intake.md`, `references/skill-archetypes.md`,
  `references/cursor-skill-standard.md`, and
  `references/skill-quality-checklist.md`. The archetype scaffolds are at
  `assets/templates/skill-archetypes/`.

The previous reference files, archetype templates, and validation script under
this directory remain in place for one release window so external links keep
resolving. They will be removed in the stub-removal PR per ADR-0005.
