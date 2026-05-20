# Changelog

All notable changes to this skill will be documented in this file.

## [1.2.0] - 2026-05-20

### Deprecated
- Skill is deprecated and replaced by `skill-studio-maintain` (Branches B,
  C, E, F) inside the `cursor-skill-studio` Cursor pack per
  [ADR-0005](../../docs/ADR/ADR-0005-skill-authoring-surface-consolidation.md).

### Changed
- `SKILL.md` is now a thin redirect stub with
  `disable-model-invocation: true`. Reference files under `references/`
  remain in place for one release window so existing links keep resolving.
  Scheduled for full removal in the stub-removal PR per ADR-0005.
- `metadata.json` carries `deprecated: true` and a `replacedBy` pointer.

## [1.1.0] - 2026-05-19

### Added

- Added ADR-0003 maturity routing for registry-managed packs as L3 artifacts.
- Added backlog guidance that keeps durable pack direction in `ROADMAP.md` and concrete implementation slices in linked GitHub issues.

### Source Contracts

- `docs/ADR/ADR-0003-artifact-maturity-model.md` reviewed 2026-05-19
- `docs/specs/artifact-maintenance-workflow.md` reviewed 2026-05-19

## [1.0.0] - 2026-05-06

### Added

- Initial release of the `personal-pack-maintainer` skill.
- Routing table covering pack package model, manifest/registry alignment, targets/profiles/artifacts, lifecycle scripts, MCP/hook safety, and release artifacts.
- Review checklist enforcing version alignment between `pack.json` and `cursor-pack-registry.json`, target/profile correctness, bundled-skill rules, and required release files.

### Changed

- Reworked the skill package to be self-contained instead of routing to external repository docs or other skill packages.
