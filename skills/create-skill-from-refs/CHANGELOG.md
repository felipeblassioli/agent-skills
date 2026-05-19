# Changelog

All notable changes to this skill are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html)
as recorded in `metadata.json` (or `assets/metadata.json` / registry) for this skill.

## [Unreleased]

## [1.1.0] - 2026-05-19

### Deprecated

- Skill is deprecated and replaced by `skill-studio-write` (Branch B — Skill
  from reference material) inside the `cursor-skill-studio` Cursor pack per
  [ADR-0005](../../docs/ADR/ADR-0005-skill-authoring-surface-consolidation.md).

### Changed

- `SKILL.md` is now a thin redirect stub with
  `disable-model-invocation: true`. Reference files, archetype templates, and
  the validation script remain in place for one release window so existing
  links keep resolving. Scheduled for full removal in the stub-removal PR per
  ADR-0005.
- `metadata.json` carries `deprecated: true` and a `replacedBy` pointer.

## [1.0.0] - 2026-03-20

### Added

- Added `CHANGELOG.md`. Earlier releases are summarized from git history and `metadata.json` only.
