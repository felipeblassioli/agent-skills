# Changelog

All notable changes to this skill are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html)
as recorded in `metadata.json` (or `assets/metadata.json` / registry) for this skill.

## [Unreleased]

## [1.1.0] - 2026-05-19

### Deprecated

- Skill is deprecated and replaced by `skill-studio-write` (Branch E —
  Claude-plugin adaptation) inside the `cursor-skill-studio` Cursor pack per
  [ADR-0005](../../docs/ADR/ADR-0005-skill-authoring-surface-consolidation.md).

### Changed

- `SKILL.md` is now a thin redirect stub with
  `disable-model-invocation: true` (previously omitted, which is what made
  this skill auto-invokable and collide with sibling intake/adapt skills).
  Decomposition guide and adaptation report template remain in place for one
  release window so existing links keep resolving. Scheduled for full removal
  in the stub-removal PR per ADR-0005.
- `metadata.json` carries `deprecated: true` and a `replacedBy` pointer.

## [1.0.1] - 2026-03-20

### Added

- Guidance for **pack-bundled skills** vs repo-root `skills/<name>/` in procedure, recommendation policy, and `skill-guidance` classification.
- `references/decomposition-guide.md`: when to use `packs/<pack>/skills/` + `kind: "skill"`.
- `assets/templates/adaptation-report.md`: recommended shapes and destination paths for bundled skills.

### Changed

- Frontmatter description; `metadata.json` to 1.0.1.

## [1.0.0] - 2026-03-08

### Added

- Initial skill: Claude plugin to Cursor pack migration recommendations.
