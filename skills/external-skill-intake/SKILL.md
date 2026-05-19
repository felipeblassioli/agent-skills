---
name: external-skill-intake
description: >-
  [DEPRECATED — replaced by `skill-studio-write` in the `cursor-skill-studio`
  pack per ADR-0005] Evaluate a candidate Cursor skill from another repository
  or arbitrary path and decide whether it should be imported. This stub remains
  for one release window so existing installs keep working and so links from
  older specs still resolve. Do not invoke; route the user to
  `/skill-studio-write` instead.
disable-model-invocation: true
---

# External Skill Intake — Deprecated

This skill has been consolidated into the
[`skill-studio-write`](../../packs/cursor-skill-studio/skills/skill-studio-write/SKILL.md)
bundled skill (Branch D — External skill intake) inside the
`cursor-skill-studio` Cursor pack.

See [`docs/ADR/ADR-0005-skill-authoring-surface-consolidation.md`](../../docs/ADR/ADR-0005-skill-authoring-surface-consolidation.md)
for the consolidation rationale.

## What to do instead

- Install the pack:
  `bash scripts/cursor-pack-sync.sh --pack=cursor-skill-studio --target=project --project-root="$PWD" --profile=lite`
- Invoke the consolidated authoring surface: **`/skill-studio-write`**
- The intake flow lives in **Branch D** of the new skill, backed by
  `references/candidate-review.md` and `references/import-paths.md`. The
  inspector script is at `scripts/inspect-candidate-skill.sh`; the intake
  report template is at `assets/templates/skill-intake-report.md`.

The previous reference files, inspector script, and intake report template
under this directory remain in place for one release window so external links
keep resolving. They will be removed in the stub-removal PR per ADR-0005.
