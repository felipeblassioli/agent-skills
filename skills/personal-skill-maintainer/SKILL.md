---
name: personal-skill-maintainer
description: Audit and maintain Cursor skills and packs to ensure compliance with the repository's governed maintenance model (ADR-0002) and registry-driven releases (ADR-0001). Use when creating, refactoring, versioning, or reviewing skills to enforce required files, correct frontmatter, changelog updates, and version authority.
---

# Personal Skill Maintainer

Maintain skills and packs as governed, versioned contracts rather than loose documentation. Ensure adherence to ADR-0001 and ADR-0002.

## Applicability Gate

**Use when:**
- Creating, refactoring, versioning, or reviewing skills/packs in this repository.
- Checking if an existing skill complies with ADR-0001 and ADR-0002.

**Do NOT use when:**
- The user is asking about general programming practices.
- Working in a repository outside of `felipeblassioli/agent-skills`.

## Quick Start

When working with skills in this repository, always verify:

1. **Root Skills (`skills/<name>/`)** must have `SKILL.md` and `metadata.json`. It is highly recommended to have `CHANGELOG.md` and `README.md` if the skill is maintained or listed in `skill-registry.json`.
2. **Pack-Bundled Skills (`packs/<pack>/skills/<skillId>/`)** must have `SKILL.md` and `metadata.json` but they version with the pack and are NOT listed in `skill-registry.json` unless explicitly promoted.
3. **`SKILL.md` Frontmatter** stays light: `name` and `description` only. Avoid `version` and `last_reviewed` unless strictly required for provenance.
4. **Versions** follow SemVer based on agent-visible behavior. The version source of truth is `metadata.json` and registries (`skill-registry.json` or `cursor-pack-registry.json`).

## Routing Table

| Topic | Reference |
|-------|-----------|
| Root vs Pack-Bundled Skill Package Model | `references/package-model.md` |
| Versioning, Releases, and Authority | `references/versioning-model.md` |
| Changelog and README requirements | `references/docs-model.md` |

## Review Checklist

Before finishing any skill authoring or maintenance task, verify:

- [ ] `SKILL.md` frontmatter has exact `name` (matching directory or `skillId`) and third-person `description`.
- [ ] No `version` or `last_reviewed` in `SKILL.md` frontmatter (unless already present and strictly necessary).
- [ ] `metadata.json` exists with `version`, `author`, `date`, `abstract`. (Prefer ISO dates for new skills).
- [ ] If bumping version, updated `skill-registry.json` or `cursor-pack-registry.json`.
- [ ] `CHANGELOG.md` updated using Keep a Changelog style (for maintained root skills).
- [ ] `README.md` exists and covers human usage/maintenance (for maintained root skills).
- [ ] Pack-bundled skills declare `kind: "skill"` in `pack.json` and use pack-scoped `skillId`s.

## Confirmation Policy

Do not apply registry, frontmatter, or versioning changes without explicit user confirmation. Present the proposed changes and wait for approval.
