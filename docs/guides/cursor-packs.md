# Cursor Packs

Cursor Packs are installable bundles of Cursor runtime assets maintained in this
repository.

Use them when you want a repeatable way to install, restore, and upgrade a group
of Cursor customizations without publishing an official Cursor Plugin or paying
for a private Team Marketplace.

## What A Pack Can Contain

A pack can install any combination of:

- subagents
- project rules
- hooks
- MCP example configuration
- bundled skills
- helper guides or assets used by those runtime components

Packs live under `packs/<name>/` and declare their install contract in
`pack.json`. Installable packs must also be listed in the repository-level index,
`cursor-pack-registry.json`.

## Packs Versus Plugins

Cursor Plugins are the official Cursor distribution format. They use
`.cursor-plugin/plugin.json` and are intended for marketplace or team marketplace
installation.

Cursor Packs are repo-native bundles. They use `pack.json` and the scripts in
this repository. They are designed for private local use, project-local setup,
and personal user-level installation.

Use an official Cursor Plugin when you need marketplace distribution. Use a
Cursor Pack when you need a private installable bundle from this repository.

## Packs Versus Skills

Create or use a skill when the main value is guidance, routing, or a reusable
workflow.

Create or use a pack when the main value is runtime setup: subagents, rules,
hooks, MCP examples, or a coherent Cursor operating mode.

Some packs include bundled skills. Those skills explain how to use the pack, but
the pack remains the delivery mechanism.

## Targets

Packs support two install targets:

- `project`: installs into a project-local `.cursor/` tree
- `user`: installs into the user's `~/.cursor/` tree

In `pack.json` and `cursor-pack-registry.json`, the corresponding target names
are `project-cursor` and `user-cursor`.

Project installs are best for repository-specific rules and stricter policy.
User installs are best for reusable subagents and skills that should be
available across projects.

## Profiles

Most packs use these profiles:

- `lite`: minimal install with lower policy surface
- `strict`: fuller install, often including project-only rules or hooks

Use `lite` when trying a pack for the first time or installing at user level.
Use `strict` when the project should adopt the pack's full operating model.

## List Available Packs

Read `cursor-pack-registry.json` to see available packs, versions, targets, and
profiles.

Common packs in this repository include:

- `cursor-companion`
- `cursor-skill-creator`
- `engineering-workflows`
- `gcp-log-investigation`
- `node-test-verifier`
- `agentic-artifact-discovery`

## Verify A Pack

Before installing or releasing a pack, verify it:

```bash
bash scripts/cursor-pack-verify.sh --pack=cursor-companion
```

Verification checks the pack contract, registry alignment, release artifacts,
and safety-sensitive surfaces such as hooks, rules, MCP examples, and bundled
skills.

## Preview An Install

Always prefer a dry run before installing into a project:

```bash
bash scripts/cursor-pack-sync.sh \
  --pack=cursor-companion \
  --target=project \
  --project-root="$PWD" \
  --profile=strict \
  --dry-run
```

For a user-level preview:

```bash
bash scripts/cursor-pack-sync.sh \
  --pack=cursor-companion \
  --target=user \
  --profile=lite \
  --dry-run
```

## Install A Pack

Project install:

```bash
bash scripts/cursor-pack-sync.sh \
  --pack=cursor-companion \
  --target=project \
  --project-root="$PWD" \
  --profile=strict
```

User install:

```bash
bash scripts/cursor-pack-sync.sh \
  --pack=cursor-companion \
  --target=user \
  --profile=lite
```

The v0 installer stages files, backs up changed destination files, overwrites
them, copies selected artifacts, and writes an install manifest. The current
conflict behavior is fixed as backup-and-overwrite.

## Restore A Previous State

If an install overwrote files and created a backup, restore from that backup:

```bash
bash scripts/cursor-pack-restore.sh \
  --backup-dir .work/cursor-pack-backups/<pack>/<target>/<timestamp>
```

There is no uninstall command yet. If you need to remove a pack, inspect the
install manifest and remove files deliberately, or restore from a backup. A
future uninstall command should be manifest-aware and refuse to remove files
that changed after installation.

## Upgrade A Pack

For users, upgrading means installing a newer version over the current one after
reviewing the pack changelog and running a dry run.

For maintainers, bump the pack version with:

```bash
bash scripts/cursor-pack-version.sh cursor-companion patch
```

After bumping a maintained pack, update:

- `CHANGELOG.md`
- `VERIFICATION.md`
- `ROADMAP.md`

Then verify the pack and run dry-run installs for the relevant targets and
profiles.

## Current Limits

Cursor Packs v0 are registry-driven. Local pack directories that are not listed
in `cursor-pack-registry.json` are draft content, not installable packs.

Current limitations:

- uninstall is manual or backup-based
- conflict behavior is backup-and-overwrite only
- verification uses repository jq/bash checks rather than full JSON Schema
  validation
- live MCP configuration is not installed automatically

The planned uninstall design is documented in
`docs/specs/cursor-pack-uninstall-follow-up.md`.

## When To Use A Cursor Pack

Use a Cursor Pack when:

- a project needs repeatable Cursor setup
- multiple runtime assets should be installed together
- a workflow depends on subagents, hooks, rules, or MCP examples
- a bundled skill should travel with its supporting runtime assets
- you want local/private distribution without official marketplace publishing

## When Not To Use A Cursor Pack

Do not use a Cursor Pack when:

- a standalone skill is enough
- the content is mostly documentation
- the assets do not share a coherent purpose
- installation requires live secrets or credential decisions
- you need official marketplace or Team Marketplace distribution
- a one-off project edit would be clearer than a reusable bundle

## Safety Notes

Treat installed runtime assets as active configuration:

- read hooks before enabling strict profiles
- keep MCP examples as examples until reviewed
- avoid installing project-specific rules at user level
- prefer dry runs before project installs
- use backups and manifests when upgrading

## Specification

The formal pack contract is documented in
`docs/specs/cursor-pack-specification.md`.
