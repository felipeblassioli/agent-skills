---
name: personal-skill-maintainer
description: >-
  [DEPRECATED — replaced by `skill-studio-maintain` in the
  `cursor-skill-studio` pack per ADR-0005] Maintain governed root skills,
  pack-bundled skills, and packs in this repository (SemVer bumps, registry
  alignment, CHANGELOG/README upkeep, ADR-0001/2/3 compliance). This stub
  remains for one release window so existing installs keep working and so
  links from older specs still resolve. Do not invoke; route the user to
  `/skill-studio-maintain` instead.
disable-model-invocation: true
---

# Personal Skill Maintainer — Deprecated

This skill has been replaced by the `skill-studio-maintain` bundled skill
inside the `cursor-skill-studio` Cursor pack per
[ADR-0005](../../docs/ADR/ADR-0005-skill-authoring-surface-consolidation.md).

## What to do instead

Route the user to `/skill-studio-maintain`. The relevant branches are:

- **Branch A — Root skill release** for SemVer bumps on `skills/<name>/`,
  `skill-registry.json` alignment, and `CHANGELOG.md` / `README.md`
  refreshes.
- **Branch C — Bundled-skill artifact** for `kind: "skill"` edits in
  `pack.json` (still relevant for scripts that maintain bundled skills as
  part of a pack release).
- **Branch D — Promotion / demotion** for moves between root and bundled.
- **Branch E — Maturity & backlog** for ADR-0003 classification decisions.

`packs/cursor-skill-studio/skills/skill-studio-maintain/SKILL.md` lists the
full router and orchestrates the same bump scripts
(`scripts/skill-version.sh`, `scripts/skill-sync.sh`).

## Removal plan

This directory is scheduled for full removal in the stub-removal PR per
ADR-0005. Reference files under `references/` remain in place during the
deprecation window so existing links keep resolving.
