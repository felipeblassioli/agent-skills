# RFC: Cursor Pack Specification

## Status

Draft

## Purpose

Define the repository-local Cursor Pack format: a versioned, installable,
restorable, and upgradeable bundle of Cursor runtime assets.

Cursor Packs exist because the official Cursor Plugin ecosystem is optimized
for public marketplace distribution and paid Team or Enterprise private
marketplaces. This repository also needs an unpaid, private, local distribution
scheme for personal and project-local Cursor configuration. Cursor Packs fill
that gap without pretending to be official Cursor Plugins.

## Terminology

**Cursor Plugin** means the official Cursor plugin format documented by Cursor.
Plugins use a `.cursor-plugin/plugin.json` manifest and may be distributed
through the Cursor Marketplace or a Team Marketplace.

**Cursor Pack** means this repository's installable bundle format under
`packs/<name>/`. A pack declares its install contract in `pack.json` and is
tracked by `cursor-pack-registry.json`.

**Runtime artifact** means a file or directory copied into a Cursor runtime
location, such as `.cursor/agents`, `.cursor/rules`, `.cursor/hooks`, or
`.cursor/mcp.example.json`.

**Bundled skill** means a skill-shaped directory shipped inside a pack and
installed into Cursor skill discovery paths. Bundled skills use artifact
`kind: "skill"` in `pack.json`.

## Goals

- Provide a private, local distribution scheme for Cursor runtime assets.
- Keep pack identity, version, targets, profiles, and artifacts explicit.
- Support project-level and user-level installs.
- Make install, restore, and upgrade operations predictable.
- Preserve a clean boundary between packs, skills, rules, hooks, MCP examples,
  and official Cursor Plugins.

## Non-goals

- Replace official Cursor Plugins.
- Publish packs to the Cursor Marketplace.
- Implement paid Team Marketplace behavior.
- Automatically install live MCP server configuration.
- Treat bundled skills as entries in `skill-registry.json` unless promoted
  separately.
- Make every skill or documentation set a pack.

## Relationship To Cursor Plugins

Cursor Packs and Cursor Plugins both bundle Cursor customization artifacts, but
they have different contracts.

Official Cursor Plugins:

- use `.cursor-plugin/plugin.json`
- can be reviewed and distributed through Cursor marketplace surfaces
- can participate in Team Marketplace distribution on paid plans
- are managed by Cursor's plugin installation model

Cursor Packs:

- use `pack.json`
- are managed by this repository's scripts
- are installed from local source into project or user Cursor paths
- are intended for private, personal, and repository-local use
- can be released as repository-scoped GitHub Release assets

Use a Cursor Plugin when marketplace distribution is the product requirement.
Use a Cursor Pack when the requirement is private, scriptable installation of a
known set of Cursor runtime assets.

## Pack Directory Contract

Every pack MUST live under:

```text
packs/<name>/
```

Every registry-managed pack MUST include:

- `pack.json`
- `README.md`

Every registry-managed pack MUST include release artifacts because
`scripts/cursor-pack-verify.sh` currently enforces them:

- `CHANGELOG.md`
- `VERIFICATION.md`
- `RELEASE-POLICY.md`
- `ROADMAP.md`

Draft pack directories that are not listed in `cursor-pack-registry.json` are
outside the v0 install contract. They may omit release artifacts while being
designed, but they cannot be installed by `scripts/cursor-pack-sync.sh` until
registered.

Packs MAY include:

- `.cursor/agents/`
- `.cursor/rules/`
- `.cursor/hooks/`
- `.cursor/hooks.project.json`
- `.cursor/hooks.user.json`
- `.cursor/mcp.example.json`
- `skills/<skill-folder>/`
- `guides/`
- `assets/`
- helper scripts or examples when they are part of the pack workflow

## Manifest Contract

The normative pack manifest is `packs/<name>/pack.json`, validated against
`cursor-pack.schema.json`.

A pack manifest MUST declare:

- `name`
- `version`
- `description`
- `author`
- `targets`
- `profiles`
- `artifacts`
- `install`

Pack names, artifact ids, and bundled skill ids MUST use lowercase slugs
matching `^[a-z0-9-]+$`.

Versions MUST use `MAJOR.MINOR.PATCH` SemVer-like strings matching
`^[0-9]+\\.[0-9]+\\.[0-9]+$`.

The pack version in `pack.json` MUST match the corresponding version in
`cursor-pack-registry.json`.

## Registry Contract

`cursor-pack-registry.json` is the repository-level index of installable packs.
It is validated by `cursor-pack-registry.schema.json`.

Every installable pack MUST have exactly one registry entry with:

- version
- author
- path
- targets
- profiles
- install policy summary
- tags
- description

The registry is a discovery and version authority surface. It MUST NOT replace
the full artifact install graph in `pack.json`.

The v0 installer resolves packs from `cursor-pack-registry.json`. Unregistered
local pack directories are not installable through `scripts/cursor-pack-sync.sh`.

## Targets

The initial target set is:

- `project-cursor`: install into a project-local `.cursor/` tree
- `user-cursor`: install into the user's `~/.cursor/` tree

These are the manifest and registry target names. The CLI intentionally uses the
shorter flag values `--target=project` and `--target=user` for the same two
destinations.

Project installs are appropriate for repository-specific rules, hooks, and
subagents.

User installs are appropriate for reusable skills, subagents, hooks, and MCP
examples that should be available across projects.

Project-only artifacts MUST NOT be installed into user-level paths.

## Profiles

Profiles define install modes. A pack MUST declare at least one profile.

Repository convention:

- `lite`: minimal install with lower policy surface
- `strict`: fuller install that may include project rules or hooks

`install.defaultProfile` MUST name one of the declared profiles.

Every artifact's `profiles` array MUST reference declared profile names.

Profile names SHOULD describe real operating modes rather than vague maturity
levels.

## Artifact Types

### Runtime artifacts

Runtime artifacts copy a source path from the pack into target-specific
destinations.

A runtime artifact MUST declare:

- `id`
- `source`
- `targets`
- `profiles`

It MAY declare:

- `kind: "runtime"`
- `projectPath`
- `userPath`
- `notes`

For selected runtime artifacts, destination fields are conditionally required:

- `projectPath` is required when `targets` includes `project-cursor`
- `userPath` is required when `targets` includes `user-cursor`

Runtime artifacts SHOULD be grouped by responsibility. For example, subagents,
rules, hooks, and MCP examples should be separate artifacts rather than one
large mixed directory.

### Bundled skills

Bundled skill artifacts install a skill-shaped source directory into Cursor
skill discovery paths. Destinations are derived from `skillId`.

A bundled skill artifact MUST declare:

- `id`
- `source`
- `targets`
- `profiles`
- `kind: "skill"`
- `skillId`

Bundled skills MUST include `SKILL.md` and `metadata.json` in their source
directory.

Bundled skill ids SHOULD be pack-scoped to avoid collisions with skills managed
by `skill-registry.json`.

Bundled skills are delivery artifacts of the pack. They are NOT automatically
entries in `skill-registry.json`; promotion to the central skill registry is a
separate decision.

## Installation Semantics

Packs are installed by `scripts/cursor-pack-sync.sh`.

The installer currently:

1. Resolve the pack from `cursor-pack-registry.json`.
2. Load the pack's `pack.json`.
3. Select the requested target and profile, or use the default profile.
4. Stage selected artifacts before copying them into destination paths.
5. Apply the declared conflict policy.
6. Write an install manifest using `install.manifestFile`.

The v0 install policy is a fixed repository convention, not a general policy
engine:

- `conflictPolicy: "backup-and-overwrite"`
- `backupOnConflict: true`
- `stageRoot: ".work/cursor-pack-staging"`
- `backupRoot: ".work/cursor-pack-backups"`
- `manifestFile: ".cursor-pack-manifest.json"`

Future `conflictPolicy` values are reserved until the installer implements
their behavior.

Install commands SHOULD support dry runs before writing to target paths.

## Removal And Restore

Cursor Packs are designed to be restorable through backups created at install
time.

`scripts/cursor-pack-restore.sh` restores files from a backup directory created
by `scripts/cursor-pack-sync.sh`.

The repository does not currently define an uninstall command. v0 packs are
installable, restorable from install backups, and upgradeable by reinstalling a
newer version, but they are not fully uninstallable as a first-class lifecycle
operation.

Until a manifest-aware uninstall command exists, removal means one of:

- restore from the relevant backup
- manually remove installed files after inspecting the install manifest
- reinstall a previous pack version from a released archive or checked-out tag

## Upgrade Semantics

An upgrade is an install of a newer pack version over an existing installation.

Upgrade safety depends on:

- matching `pack.json` and registry versions
- backing up conflicts before overwrite
- preserving a manifest of installed files
- documenting release notes and verification evidence

Maintainers SHOULD bump pack versions with:

```bash
bash scripts/cursor-pack-version.sh <pack-name> patch|minor|major
```

After a version bump, maintained packs SHOULD update:

- `CHANGELOG.md`
- `VERIFICATION.md`
- `ROADMAP.md`

## MCP Policy

Packs MUST treat MCP configuration conservatively.

`mcpPolicy: "none"` means the pack does not manage MCP configuration.

`mcpPolicy: "example-only"` means the pack may install example MCP
configuration, but MUST NOT promote it to live `mcp.json` automatically.

Live MCP setup requires separate user review because MCP servers can access
external systems, credentials, or sensitive data.

## Safety Requirements

Pack authors MUST keep safety-sensitive artifacts narrow and inspectable:

- hooks must be understandable and bounded
- project rules must remain project-only when they encode project policy
- MCP configuration must remain example-only unless explicitly reviewed outside
  the pack installer
- bundled skills must not duplicate their bodies into rules or README prose
- install paths must be explicit for runtime artifacts

## Validation Requirements

Before a pack change is considered ready, maintainers SHOULD run:

```bash
bash scripts/cursor-pack-verify.sh --pack=<pack-name>
```

For install-affecting changes, maintainers SHOULD also run dry-run installs for
the relevant target and profile combinations:

```bash
bash scripts/cursor-pack-sync.sh \
  --pack=<pack-name> \
  --target=project \
  --project-root="$PWD" \
  --profile=strict \
  --dry-run
```

Validation SHOULD prove:

- registry and manifest version alignment
- expected artifact selection by target and profile
- safe handling of hooks and MCP examples
- no accidental user-level install of project-only policy

`scripts/cursor-pack-verify.sh` currently performs bespoke jq/bash validation.
True JSON Schema validation against `cursor-pack.schema.json` and
`cursor-pack-registry.schema.json` is future verifier hardening, not a current
guarantee.

## Release Contract

Packs are independently versioned release units.

Pack releases use tags of the form:

```text
pack-<name>@<version>
```

GitHub Releases are the publication record. The registry and `pack.json` remain
the version source of truth.

Release assets SHOULD archive the pack under a stable top-level folder:

```text
pack-<name>/...
```

## When To Create A Pack

Create a Cursor Pack when the main value is an installable runtime operating
mode, such as:

- reusable subagents
- project rules
- hooks
- MCP examples
- bundled skills that explain or activate the runtime assets
- repeatable project or user Cursor setup

## When Not To Create A Pack

Do not create a Cursor Pack when:

- the work is only reusable knowledge or task guidance
- a single standard skill is enough
- the artifacts have no shared runtime purpose
- the intended distribution path is the official Cursor Marketplace
- the package would mainly be a documentation dump
- the assets require live credentials or external trust decisions at install
  time

## Known Gaps And Future Work

The v0 pack contract intentionally leaves these gaps explicit:

- **Manifest-aware uninstall**: add a dedicated uninstall command only after the
  install manifest records enough ownership data to avoid deleting user changes.
  See `docs/specs/cursor-pack-uninstall-follow-up.md`.
- **File hashes in manifests**: record installed file hashes so future uninstall
  can refuse to remove modified files unless explicitly forced.
- **True schema validation**: teach `scripts/cursor-pack-verify.sh` to validate
  against `cursor-pack.schema.json` and `cursor-pack-registry.schema.json`, or
  keep equivalent jq/bash checks in sync with those schemas.
- **Configurable conflict policies**: implement any future conflict policy before
  documenting it as supported.
- **Strict enums**: keep supported targets and install policy values closed for
  v0 unless the scripts implement new values.
- **Restore edge cases**: ensure restore works for first installs and new-file
  only backups.

## References

- `_references/cursor/Cursor Docs - Cursor Plugins.md`
- `cursor-pack.schema.json`
- `cursor-pack-registry.schema.json`
- `cursor-pack-registry.json`
- `scripts/cursor-pack-sync.sh`
- `scripts/cursor-pack-verify.sh`
- `scripts/cursor-pack-restore.sh`
- `scripts/cursor-pack-version.sh`
- `docs/specs/agentic-skill-pack-authoring.md`
- `docs/specs/pack-authoring-checklist.md`
- `docs/specs/release-workflow.md`
- `docs/specs/cursor-pack-uninstall-follow-up.md`
- `docs/ADR/ADR-0001-registry-driven-releases-for-skills-and-packs.md`
