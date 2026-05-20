# Changelog

All notable changes to this skill will be documented in this file.

## [1.2.0] - 2026-05-20

### Deprecated
- Skill is deprecated and replaced by `skill-studio-maintain` (Branches A,
  C, D, E) inside the `cursor-skill-studio` Cursor pack per
  [ADR-0005](../../docs/ADR/ADR-0005-skill-authoring-surface-consolidation.md).

### Changed
- `SKILL.md` is now a thin redirect stub with
  `disable-model-invocation: true`. Reference files under `references/`
  remain in place for one release window so existing links keep resolving.
  Scheduled for full removal in the stub-removal PR per ADR-0005.
- `metadata.json` carries `deprecated: true` and a `replacedBy` pointer.

## [1.1.0] - 2026-05-19

### Added

- Added ADR-0003 artifact maturity routing for skills, scripts/tools, and Cursor packs.
- Added guidance to verify maintained scripts/tools against `SPEC.md`, tests, and linked backlog issues.

### Source Contracts

- `docs/ADR/ADR-0003-artifact-maturity-model.md` reviewed 2026-05-19
- `docs/specs/artifact-maintenance-workflow.md` reviewed 2026-05-19

## [1.0.0] - 2026-05-05

### Added

- Initial release of the `personal-skill-maintainer` skill.
- Added routing to package model, docs model, and versioning model references.

### Source Contracts

- `docs/ADR/ADR-0001-registry-driven-releases-for-skills-and-packs.md` reviewed 2026-05-05
- `docs/ADR/ADR-0002-governed-skill-maintenance-model.md` reviewed 2026-05-05
