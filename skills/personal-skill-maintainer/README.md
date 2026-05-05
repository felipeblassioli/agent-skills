# Personal Skill Maintainer

Audit and maintain Cursor skills and packs to ensure compliance with the repository's governed maintenance model and registry-driven releases.

## When To Use

- "Check if my new skill complies with ADR-0001 and ADR-0002."
- "Refactor this skill to follow the repo's governed package model."
- "Bump the version of this skill."
- "Create a new skill and ensure it has all required files and correct frontmatter."

## What This Skill Maintains

- Package file structure (`SKILL.md`, `metadata.json`, `CHANGELOG.md`, `README.md`).
- Strict frontmatter rules for `SKILL.md` (no `version` by default).
- Semantic versioning and version authority through `metadata.json` and `skill-registry.json` / `cursor-pack-registry.json`.

## Release And Validation

To validate the structure:
```bash
bash scripts/skill-sync.sh --skill=personal-skill-maintainer --dry-run
```

To execute a version bump and release:
```bash
bash scripts/skill-version.sh personal-skill-maintainer patch
git add skills/personal-skill-maintainer skill-registry.json
git commit -m "chore(personal-skill-maintainer): bump to <version>"
git tag skill-personal-skill-maintainer@<version>
```

## Related Skills Or Packs

- `cursor-skill-creator`: For Socratic discovery and initial scaffolding of a skill.
- `create-cursor-pack-from-refs`: For creating Cursor packs.
