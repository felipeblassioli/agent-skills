# Changelog

All notable changes to this skill are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html)
as recorded in `metadata.json` (or `assets/metadata.json` / registry) for this skill.

## [Unreleased]

## [1.1.0] - 2026-05-19

### Deprecated

- Skill is deprecated and replaced by `skill-studio-write` (Branch D —
  External skill intake) inside the `cursor-skill-studio` Cursor pack per
  [ADR-0005](../../docs/ADR/ADR-0005-skill-authoring-surface-consolidation.md).

### Changed

- `SKILL.md` is now a thin redirect stub with
  `disable-model-invocation: true` (previously omitted, which is what made
  this skill auto-invokable and collide with sibling intake/adapt skills).
  Reference files, the inspection script, and the intake report template
  remain in place for one release window so existing links keep resolving.
  Scheduled for full removal in the stub-removal PR per ADR-0005.
- `metadata.json` carries `deprecated: true` and a `replacedBy` pointer.

## [1.0.0] - 2026-03-20

### Added

- Initial release of the `external-skill-intake` skill.
- Candidate classification workflow for deciding whether a skill source is
  ready, needs adaptation, or should be rejected before import.
- Supporting reference docs for repo-fit review and canonical versus
  normalization-first import paths.
- Structured intake-report template and inspection script for repeatable
  candidate evaluation.
