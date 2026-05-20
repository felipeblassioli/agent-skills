---
name: personal-pack-maintainer
description: >-
  [DEPRECATED — replaced by `skill-studio-maintain` in the
  `cursor-skill-studio` pack per ADR-0005] Maintain governed Cursor packs
  (`packs/<name>/`) as installable runtime bundles: `pack.json` and
  `cursor-pack-registry.json` alignment, release artifacts (CHANGELOG,
  VERIFICATION, ROADMAP, RELEASE-POLICY), targets/profiles correctness,
  bundled-skill artifacts, MCP/hook safety, and install verification. This
  stub remains for one release window so existing installs keep working and
  so links from older specs still resolve. Do not invoke; route the user to
  `/skill-studio-maintain` instead.
disable-model-invocation: true
---

# Personal Pack Maintainer — Deprecated

This skill has been replaced by the `skill-studio-maintain` bundled skill
inside the `cursor-skill-studio` Cursor pack per
[ADR-0005](../../docs/ADR/ADR-0005-skill-authoring-surface-consolidation.md).

## What to do instead

Route the user to `/skill-studio-maintain`. The relevant branches are:

- **Branch B — Pack release** for SemVer bumps on `packs/<name>/`,
  `cursor-pack-registry.json` alignment, and the
  `CHANGELOG.md` / `VERIFICATION.md` / `ROADMAP.md` refresh cycle.
- **Branch C — Bundled-skill artifact** for `kind: "skill"` edits in
  `pack.json`.
- **Branch F — Install verification** for `cursor-pack-verify.sh` plus
  per-profile `cursor-pack-sync.sh --dry-run` rituals.
- **Branch E — Maturity & backlog** for ADR-0003 classification on
  registry-managed packs.

`packs/cursor-skill-studio/skills/skill-studio-maintain/SKILL.md` lists the
full router and orchestrates the same scripts
(`scripts/cursor-pack-version.sh`, `scripts/cursor-pack-verify.sh`,
`scripts/cursor-pack-sync.sh`, `scripts/cursor-pack-restore.sh`).

## Removal plan

This directory is scheduled for full removal in the stub-removal PR per
ADR-0005. Reference files under `references/` remain in place during the
deprecation window so existing links keep resolving.
