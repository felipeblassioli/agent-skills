---
name: personal-pack-maintainer
description: Use when creating, refactoring, versioning, promoting, or reviewing Cursor packs in this repository.
---

# Personal Pack Maintainer

Maintain Cursor packs (`packs/<name>/`) as governed, versioned, installable runtime bundles, not loose collections of subagents, rules, hooks, or skills.

This skill is self-contained for pack mechanics, but pack maturity and backlog
policy are governed by ADR-0003.

## Applicability Gate

**Use when:**

- Creating, refactoring, versioning, or reviewing a pack under `packs/`.
- Adding or changing artifacts in `pack.json` (runtime artifacts or bundled skills).
- Updating `cursor-pack-registry.json` or release artifacts (`CHANGELOG.md`, `VERIFICATION.md`, `RELEASE-POLICY.md`, `ROADMAP.md`).
- Reviewing pack install/restore/upgrade safety before merge or release.

**Do NOT use when:**

- The work is a root skill under `skills/<name>/` rather than a pack under `packs/<name>/`.
- The artifact is an official Cursor Plugin destined for a marketplace.
- The user is only running `cursor-pack-sync.sh` to install an already-shipped pack (operational use, not maintenance).
- The work is general programming guidance with no pack lifecycle impact.

## Quick Start

When working on a pack, always verify:

1. **Pack identity matches everywhere.** `packs/<name>/pack.json` `name` and `version` MUST match the entry in `cursor-pack-registry.json`. Slugs match `^[a-z0-9-]+$`; versions match `^[0-9]+\.[0-9]+\.[0-9]+$`.
2. **Required release artifacts exist** for any registry-managed pack: `pack.json`, `README.md`, `CHANGELOG.md`, `VERIFICATION.md`, `RELEASE-POLICY.md`, `ROADMAP.md`.
3. **Targets and profiles are explicit.** Pack declares at least one profile; `install.defaultProfile` names a declared profile; runtime artifacts declare `projectPath` for `project-cursor` and `userPath` for `user-cursor`.
4. **Bundled skills use `kind: "skill"` with a pack-scoped `skillId`** (e.g. `cursor-companion-pack-overview`). Bundled skills are NOT added to `skill-registry.json` unless explicitly promoted.
5. **Safety boundaries hold.** `mcpPolicy` is `none` or `example-only`; project-only assets stay project-only; hooks are narrow and inspectable.
6. **Maturity is explicit.** Registry-managed packs are L3 by default under ADR-0003. Experimental packs must be clearly marked as local or exploratory.
7. **Backlog has two homes.** Durable pack direction lives in `ROADMAP.md`; concrete implementation slices live in GitHub issues and should be linked from the roadmap when they affect product direction.
8. **Verify before claiming done.** Run `bash scripts/cursor-pack-verify.sh --pack=<name>` and a `--dry-run` install for relevant target/profile combinations.

## Routing Table

| Topic | Reference |
|-------|-----------|
| Pack directory contract, draft vs registered | `references/pack-package-model.md` |
| `pack.json` fields, registry alignment, slugs and version regex | `references/manifest-and-registry.md` |
| Targets, profiles, runtime vs `kind: "skill"` artifacts | `references/targets-profiles-artifacts.md` |
| Bundled-skill rules and promotion boundary | `references/bundled-skills.md` |
| `cursor-pack-verify.sh`, `cursor-pack-sync.sh`, `cursor-pack-restore.sh`, `cursor-pack-version.sh` | `references/lifecycle-scripts.md` |
| MCP policy, hook narrowness, project-only invariants | `references/safety-and-mcp-policy.md` |
| `CHANGELOG.md`, `VERIFICATION.md`, `RELEASE-POLICY.md`, `ROADMAP.md`, release tag scheme | `references/release-artifacts.md` |
| Pack maturity and backlog workflow | `docs/ADR/ADR-0003-artifact-maturity-model.md` and `docs/specs/artifact-maintenance-workflow.md` |

## Review Checklist

Before finishing any pack authoring or maintenance task, verify:

- [ ] `pack.json` declares `name`, `version`, `description`, `author`, `targets`, `profiles`, `artifacts`, `install`.
- [ ] `pack.json.version` equals `cursor-pack-registry.json.packs.<name>.version`.
- [ ] `name`, artifact `id`s, and any `skillId`s match `^[a-z0-9-]+$`; version matches `^\d+\.\d+\.\d+$`.
- [ ] At least one profile declared; `install.defaultProfile` is one of them.
- [ ] Every artifact's `profiles` array references declared profile names only.
- [ ] Runtime artifacts: `projectPath` present iff `project-cursor` in `targets`; `userPath` present iff `user-cursor` in `targets`.
- [ ] Project-only policy (project rules, repo-scoped hooks) is NOT installed via `user-cursor` paths.
- [ ] Bundled skills declare `kind: "skill"` + pack-scoped `skillId`; `SKILL.md` `name` matches `skillId`; `metadata.json` present in source.
- [ ] Bundled skills are NOT added to `skill-registry.json` unless they are explicitly promoted into a root skill with independent version authority.
- [ ] `mcpPolicy` is `none` or `example-only`. No live `mcp.json` promotion in install path.
- [ ] Hooks are bounded, readable, and documented.
- [ ] Required release files exist: `README.md`, `CHANGELOG.md`, `VERIFICATION.md`, `RELEASE-POLICY.md`, `ROADMAP.md`.
- [ ] Registry-managed packs are treated as L3 artifacts under ADR-0003.
- [ ] Future pack work is tracked in `ROADMAP.md` and linked GitHub issues when it affects durable product direction.
- [ ] On version bump: used `bash scripts/cursor-pack-version.sh <pack> patch|minor|major`; updated `CHANGELOG.md`, `VERIFICATION.md`, `ROADMAP.md` accordingly.
- [ ] Ran `bash scripts/cursor-pack-verify.sh --pack=<name>`; ran a `--dry-run` install for each affected target/profile.
- [ ] Release tag (when releasing) follows `pack-<name>@<version>`.

## Confirmation Policy

Do not modify `pack.json`, `cursor-pack-registry.json`, release artifacts, or version files without explicit user confirmation. Present the proposed changes and wait for approval before applying them.
