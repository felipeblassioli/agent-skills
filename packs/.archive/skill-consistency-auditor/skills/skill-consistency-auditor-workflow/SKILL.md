---
name: skill-consistency-auditor-workflow
description: >-
  [DEPRECATED — replaced by `skill-studio-audit` (Branch C — Installed
  portfolio audit) in the `cursor-skill-studio` pack per ADR-0005] Installed
  skill directory audit (overlap clustering, architecture compliance,
  consolidation advice). This stub remains for one release window so existing
  installs keep working; do not invoke, route the user to
  `/skill-studio-audit` instead.
disable-model-invocation: true
---

# Skill Consistency Auditor Workflow — Deprecated

This bundled skill has been replaced by the `skill-studio-audit` bundled skill
inside the `cursor-skill-studio` Cursor pack per
[ADR-0005](../../../../docs/ADR/ADR-0005-skill-authoring-surface-consolidation.md).

## What to do instead

Route the user to `/skill-studio-audit`, then follow **Branch C
(Installed portfolio audit)** in
`packs/cursor-skill-studio/skills/skill-studio-audit/SKILL.md`.

Branch C orchestrates the same three subagents (`skill-overlap-clusterer` →
`skill-architecture-checker` → `skill-consolidation-advisor`) that this
workflow used, and ships the `portfolio-audit-report.md` template directly
under `assets/templates/` so the report path resolves after install (this was
the broken-path issue called out in ADR-0005).

## Removal plan

This bundled skill and the `skill-consistency-auditor` pack are scheduled to
move to `packs/.archive/skill-consistency-auditor/` in the stub-removal PR per
ADR-0005. The three subagents are already duplicated in `cursor-skill-studio`
and remain available there.
