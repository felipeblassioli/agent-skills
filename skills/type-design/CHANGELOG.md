# Changelog

All notable changes to this skill are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html)
as recorded in `metadata.json` and `skill-registry.json` for this skill.

## 0.1.0 - 2026-07-25

### Added

- Adopted into the registry. The skill already existed and was in use, but lived
  only as an unversioned directory in `~/.claude/skills/` — untracked, unbacked,
  and invisible to every clone. This entry records the adoption, not new
  authorship; `0.1.0` carries over the version its frontmatter already declared.
- `metadata.json` and a `skill-registry.json` entry, which the package lacked.

### Changed

- Removed the `metadata:` block (`author`, `version`) from `SKILL.md`
  frontmatter. Per the repo contract, frontmatter carries only `name` +
  `description`; version and author now have a single home in `metadata.json`
  instead of two that can drift.

### Notes

- `SKILL.md` body, `references/house-defaults.md`,
  `references/worked-examples.md`, and `evals/evals.json` are byte-identical to
  the copy found live. No guidance was reviewed or corrected as part of this
  adoption.
- `references/house-defaults.md` is team-specific and says so in its own opening
  lines; the principles in `SKILL.md` stand alone without it.
