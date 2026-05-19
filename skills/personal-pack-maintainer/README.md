# personal-pack-maintainer

Audit and maintain Cursor packs in `felipeblassioli/agent-skills` as governed, versioned, installable runtime bundles.

## What this skill does

Keeps pack work self-contained and enforces a compact review checklist against:

- the pack directory contract,
- `pack.json` ↔ `cursor-pack-registry.json` version alignment,
- target/profile correctness for `project-cursor` and `user-cursor`,
- bundled-skill rules (`kind: "skill"` + pack-scoped `skillId`),
- MCP and hook safety policy,
- required release artifacts (`CHANGELOG.md`, `VERIFICATION.md`, `RELEASE-POLICY.md`, `ROADMAP.md`),
- the lifecycle scripts under `scripts/cursor-pack-*.sh`.

## What this skill does NOT do

- Maintain root skills under `skills/<name>/`.
- Depend on external documentation files to do its job. The required maintenance guidance lives under this skill's own `references/`.
- Operate as an installer. It does not run `cursor-pack-sync.sh` for you; it tells you when and how to run it.

## When the maintainer should invoke it

- Creating a new pack under `packs/`.
- Adding/changing artifacts in `pack.json`.
- Bumping a pack version or preparing a release tag (`pack-<name>@<version>`).
- Reviewing a PR that touches `packs/` or `cursor-pack-registry.json`.

## Maintenance

- Internal reference docs are listed in `metadata.json#references`.
- Bump version with `bash scripts/skill-version.sh personal-pack-maintainer patch|minor|major` and update `CHANGELOG.md` accordingly.
- Re-deploy with `bash scripts/skill-sync.sh --skill=personal-pack-maintainer` when needed.
