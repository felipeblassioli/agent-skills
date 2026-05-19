---
name: personal-skill-maintainer
description: Use when creating, refactoring, versioning, promoting, or reviewing skills, scripts/tools, and Cursor packs in this repository.
---

# Personal Skill Maintainer

Maintain skills, scripts/tools, and packs as governed artifacts rather than loose
documentation. Ensure adherence to ADR-0001, ADR-0002, and ADR-0003.

## Applicability Gate

**Use when:**
- Creating, refactoring, versioning, or reviewing skills/packs in this repository.
- Changing maintained scripts/tools under `scripts/`.
- Checking if an existing artifact complies with ADR-0001, ADR-0002, or
  ADR-0003.

**Do NOT use when:**
- The user is asking about general programming practices.
- Working in a repository outside of `felipeblassioli/agent-skills`.

## Quick Start

When maintaining repository artifacts, always verify:

1. **Root Skills (`skills/<name>/`)** must have `SKILL.md` and `metadata.json`. It is highly recommended to have `CHANGELOG.md` and `README.md` if the skill is maintained or listed in `skill-registry.json`.
2. **Pack-Bundled Skills (`packs/<pack>/skills/<skillId>/`)** must have `SKILL.md` and `metadata.json` but they version with the pack and are NOT listed in `skill-registry.json` unless explicitly promoted.
3. **`SKILL.md` Frontmatter** stays light: `name` and `description` only. Avoid `version` and `last_reviewed` unless strictly required for provenance.
4. **Versions** follow SemVer based on agent-visible behavior. The version source of truth is `metadata.json` and registries (`skill-registry.json` or `cursor-pack-registry.json`).
5. **Maturity** determines documentation weight. Read ADR-0003 before deciding
   whether an artifact needs `SPEC.md`, README, changelog, tests, roadmap, or
   release evidence.
6. **Registry-managed Cursor packs** are L3 by default and keep README,
   CHANGELOG, VERIFICATION, RELEASE-POLICY, and ROADMAP aligned.

## Routing Table

| Topic | Reference |
|-------|-----------|
| Root vs Pack-Bundled Skill Package Model | `references/package-model.md` |
| Versioning, Releases, and Authority | `references/versioning-model.md` |
| Changelog and README requirements | `references/docs-model.md` |
| Artifact maturity and backlog workflow | `docs/ADR/ADR-0003-artifact-maturity-model.md` and `docs/specs/artifact-maintenance-workflow.md` |

## Review Checklist

Before finishing any skill authoring or maintenance task, verify:

- [ ] `SKILL.md` frontmatter has exact `name` (matching directory or `skillId`) and third-person `description`.
- [ ] No `version` or `last_reviewed` in `SKILL.md` frontmatter (unless already present and strictly necessary).
- [ ] `metadata.json` exists with `version`, `author`, `date`, `abstract`. (Prefer ISO dates for new skills).
- [ ] If bumping version, updated `skill-registry.json` or `cursor-pack-registry.json`.
- [ ] `CHANGELOG.md` updated using Keep a Changelog style (for maintained root skills).
- [ ] `README.md` exists and covers human usage/maintenance (for maintained root skills).
- [ ] Pack-bundled skills declare `kind: "skill"` in `pack.json` and use pack-scoped `skillId`s.
- [ ] Mature scripts/tools have a `SPEC.md`, tests or verification notes, and
      linked GitHub issues for concrete backlog slices.
- [ ] Repository-level governance changes update root `CHANGELOG.md`.

## Confirmation Policy

Do not apply registry, frontmatter, or versioning changes without explicit user confirmation. Present the proposed changes and wait for approval.
