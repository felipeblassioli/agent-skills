# Agent Skills

Personal registry of versioned Agent Skills and Cursor packs used across Cursor,
generic agents, and Claude environments.

This repository is the source of truth for skill content, pack content,
metadata, and deployment targets.

## Repository Purpose

- Maintain skills under `skills/<name>/`
- Maintain installable Cursor packs under `packs/<name>/`
- Track versions and targets in `skill-registry.json`
- Track pack versions and install targets in `cursor-pack-registry.json`
- Import skills from local repositories/projects
- Sync skills to discovery paths (for example `~/.cursor/skills/`)
- Verify, stage, install, and restore Cursor runtime bundles such as subagents, rules, hooks, and MCP templates

## Current Workflow

### 1) Import a skill

```bash
bash scripts/skill-import.sh <project-path> <skill-name> --tags=tag1,tag2
```

### 2) Validate registry and deploy plan

```bash
bash scripts/skill-sync.sh --list
bash scripts/skill-sync.sh --dry-run
```

### 3) Validate a skill package (recommended for PRs)

```bash
bash skills/create-skill-from-refs/scripts/validate-skill.sh skills/<skill-name>
```

### 4) Sync skills to targets

```bash
bash scripts/skill-sync.sh
```

## Cursor Pack Workflow

### 1) Verify a pack

```bash
bash scripts/cursor-pack-verify.sh --pack=cursor-companion
```

### 2) Dry-run a project install

```bash
bash scripts/cursor-pack-sync.sh \
  --pack=cursor-companion \
  --target=project \
  --project-root="$PWD" \
  --profile=strict \
  --dry-run
```

### 3) Install a pack

```bash
bash scripts/cursor-pack-sync.sh \
  --pack=cursor-companion \
  --target=project \
  --project-root="$PWD" \
  --profile=strict
```

For a user-level install:

```bash
bash scripts/cursor-pack-sync.sh \
  --pack=cursor-companion \
  --target=user \
  --profile=lite
```

### 4) Restore from backup if needed

```bash
bash scripts/cursor-pack-restore.sh --backup-dir .work/cursor-pack-backups/<pack>/<target>/<timestamp>
```

### 5) Bump a pack version

```bash
bash scripts/cursor-pack-version.sh cursor-companion patch
```

After a pack bump, update the committed release artifacts in the pack root:

- `CHANGELOG.md`
- `VERIFICATION.md`
- `ROADMAP.md`

## Release Workflow

This repository uses independent, registry-driven releases for skills and
Cursor packs.

### Release units

- Skills release from `skills/<name>`
- Packs release from `packs/<name>`
- Versions remain authoritative in `skill-registry.json` and
  `cursor-pack-registry.json`

### Git tags and GitHub Releases

Create one tag and one GitHub Release per released unit:

- Skills: `skill-<name>@<version>`
- Packs: `pack-<name>@<version>`

Pushed tags matching those patterns trigger `.github/workflows/release-units.yml`,
which:

1. resolves the tagged release unit from the registry
2. validates the unit and its version metadata
3. builds a module-scoped archive asset
4. generates release notes
5. publishes a GitHub Release for the tag

### Maintainer release flow

1. prepare a focused release PR with only the version bumps and release-doc
   updates needed for the units you want to ship
2. validate the released units locally
3. merge the release PR
4. create and push the matching `skill-...` or `pack-...` tag

Use the helper script to create tags from the current registry version:

```bash
bash scripts/release-unit-tag.sh --skill=tdd-classicist --dry-run
bash scripts/release-unit-tag.sh --pack=cursor-companion --push
```

Example skill release validation:

```bash
bash scripts/skill-sync.sh --skill=tdd-classicist --dry-run
```

Optional richer skill release notes:

- if a skill includes `skills/<name>/CHANGELOG.md`, the matching version section
  is included automatically in generated GitHub Release notes
- if no skill changelog exists, the workflow keeps the lightweight note format

Example pack release validation:

```bash
bash scripts/cursor-pack-verify.sh --pack=cursor-companion
bash scripts/cursor-pack-sync.sh --pack=cursor-companion --target=project --project-root="$PWD" --profile=strict --dry-run
```

### Release documentation

See:

- `docs/specs/release-workflow.md`
- `docs/ADR/ADR-0001-registry-driven-releases-for-skills-and-packs.md`

## PR Quality Standard

Use focused PRs and keep content in English:

- Follow `.github/pull_request_template.md`
- Keep commit/PR titles in Conventional Commits format
- Include explicit validation commands and outcomes
- Separate unrelated concerns (skill content vs registry/scripts vs build)

## Privacy and Naming Policy

When describing imported skills in commits/PRs/docs:

- Use generic wording such as `local repository` or `local project`
- Do not reference private repository names

## Skill Layout

Each skill directory should include:

- `SKILL.md` (required)
- `metadata.json` (required)
- Optional: `references/`, `assets/`, `scripts/`

## Cursor Pack Layout

Each pack directory should include:

- `pack.json` (required)
- `README.md` (recommended)
- runtime assets under `.cursor/`
- optional `guides/` and `assets/`

Maintained packs should also commit:

- `CHANGELOG.md`
- `VERIFICATION.md`
- `RELEASE-POLICY.md`
- `ROADMAP.md`

Current reference pack:

- `cursor-companion`
- `gcp-log-investigation`

## Selected Skills

This repository currently contains skills including:

- `commit-hygiene`
- `create-skill-from-refs`
- `firebase-functions-node`
- `gcloud-logging`
- `gh-pr-creator`
- `go-package-documentation`
- `nx-monorepo`
- `tdd-classicist`
- `test-verifier`
- `typescript-quality`
- `typescript-testing-organization`
- `vitest-monorepo`
- `react-best-practices`
- `react-native-skills`
- `web-design-guidelines`

## Best-Practice Model

Use the right Cursor surface for the job:

- `skills` teach and route
- `rules` persist project guidance
- `subagents` isolate noisy or parallel work
- `hooks` enforce or audit runtime behavior
- `MCP` connects external systems and should stay template-driven and secret-safe

## License

MIT
