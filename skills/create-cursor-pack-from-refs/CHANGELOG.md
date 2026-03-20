# Changelog

All notable changes to this skill are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html)
as recorded in `metadata.json` (or `assets/metadata.json` / registry) for this skill.

## [Unreleased]

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
