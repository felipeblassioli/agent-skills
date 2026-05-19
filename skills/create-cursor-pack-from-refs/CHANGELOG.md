# Changelog

All notable changes to this skill are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html)
as recorded in `metadata.json` (or `assets/metadata.json` / registry) for this skill.

## [Unreleased]

## [1.1.0] - 2026-05-19

### Deprecated

- Skill is deprecated and replaced by `skill-studio-write` (Branch C — Pack
  from reference material) inside the `cursor-skill-studio` Cursor pack per
  [ADR-0005](../../docs/ADR/ADR-0005-skill-authoring-surface-consolidation.md).

### Changed

- `SKILL.md` is now a thin redirect stub with
  `disable-model-invocation: true`. References, pack templates, and the
  validation wrapper script remain in place for one release window so existing
  links keep resolving. Scheduled for full removal in the stub-removal PR per
  ADR-0005.
- `references/recommendation-metadata.md` has been promoted to
  `docs/specs/pack-recommendation-metadata.md`.
- `metadata.json` carries `deprecated: true` and a `replacedBy` pointer.

## [1.0.1] - 2026-03-20

### Added

- Documentation and templates for **pack-bundled skills** (`kind: "skill"` in `pack.json`): `references/pack-standard.md`, `references/quality-checklist.md`, `assets/templates/bundled-skill-artifact.fragment.json`.
- Intake table row, pack contract example, scaffolding rule, and template list updates in `SKILL.md`.

### Changed

- `references/pack-standard.md`: runtime surface table, validation list, schema note for bundled skills; authoring constraints for `skillId` collisions with `skill-registry.json`.
- `metadata.json` version bump to 1.0.1.

## [1.0.0] - 2026-03-08

### Added

- Initial skill: create Cursor packs from references with repo conventions and verification.
