# Changelog and README Requirements

## Changelog Model
Root skill changelogs should be concise and behavior-focused using Keep a Changelog style.

```markdown
# Changelog

All notable changes to this skill will be documented in this file.

## [1.1.0] - 2026-04-30

### Added
- Added ...

### Changed
- Changed ...

### Validation
- `bash scripts/skill-sync.sh --skill=<name> --dry-run`

### Source Contracts
- `path/to/source.md` reviewed 2026-04-30
```
*Note*: `Validation` is recommended for meaningful behavior changes. `Source Contracts` is recommended when behavior is derived from external docs/APIs.

## README Model
Root skill `README.md` files are human-facing and should NOT duplicate the `SKILL.md` body.

```markdown
# <Skill Name>

Short purpose.

## When To Use
Human prompt examples.

## What This Skill Maintains
Package files, source contracts, references, scripts, and registry expectations.

## Release And Validation
Commands and expected evidence.

## Related Skills Or Packs
Routing notes and links.
```
