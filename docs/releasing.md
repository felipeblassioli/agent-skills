# Releasing

`agent-skills` has **two independent release units**, each with its own tag
namespace and CI workflow:

- **Skills** — the fine-grained unit. Tag `<skill-name>/v<version>`, sourced
  from `metadata.json`. See [Releasing skills](#releasing-skills).
- **Plugins** — the install unit a consumer actually adds. Tag
  `<name>--v<version>` (the `claude plugin tag` format), sourced from
  `plugin.json`, with a distributable `.zip` attached. See
  [Releasing plugins](#releasing-plugins).

The two never collide: skill tags use `/v`, plugin tags use `--v`.

> **Coexistence note.** These workflows release only `plugins/*` and the
> `.claude-plugin/marketplace.json` catalog. The pre-existing Cursor-era model
> (top-level `skills/` and `packs/`, governed by `skill-registry.json` and
> `cursor-pack-registry.json`) keeps its own tooling and is **not** released by
> these workflows. See
> [ADR-0006](ADR/ADR-0006-adopt-claude-first-plugin-marketplace.md).

# Releasing skills

Every skill version bump that lands on `main` is published as an independent
GitHub Release. Releases give humans a per-skill update feed and let
agents/tools resolve an immutable archive for a specific skill version.

## Release Identity

- **Tag**: `<skill-name>/v<version>` (e.g. `blassioli-gcp-log-triage/v1.2.0`).
  For a plugin skill `<skill-name>` is `<plugin>-<skill>` (collision-free across
  plugins).
- **Title**: `<skill-name> v<version>`.
- **Body**: the matching version section of the skill's `CHANGELOG.md`,
  extracted verbatim.
- **Target**: the `main` commit that merged the version bump.
- **Source of truth**: the skill's `metadata.json` `version` field
  (`plugins/<plugin>/skills/<skill>/`).

Tags are immutable. To correct a bad release, cut a new patch version.

## Automated Path (default)

`.github/workflows/release-skill.yaml` runs on every push to `main`.

For each skill whose `metadata.json` `version` changed in the merged commit,
the workflow:

1. Extracts the matching `CHANGELOG.md` section with
   `scripts/extract-changelog.sh`.
2. Verifies the version is consistent across `SKILL.md`, `metadata.json`, and
   the latest `CHANGELOG.md` entry by running `scripts/validate-skill.sh`.
3. Creates the tag `<skill-name>/v<version>` and the matching GitHub Release.

The workflow is idempotent: if the tag already exists it skips the skill.

## Manual Path (fallback)

Use the manual path when the automated workflow is paused, when reissuing a
release after fixing release-notes formatting, or when releasing from a
maintenance branch with explicit approval.

```bash
# from the repo root
bash scripts/release-skill.sh plugins/<plugin>/skills/<skill>
```

The script:

- reads the version from `metadata.json`
- runs the validator
- extracts the changelog section for that version
- creates the `<skill-name>/v<version>` tag and GitHub Release via `gh`

Requires `gh auth status` to succeed and push permission on
`github.com/felipeblassioli/agent-skills`.

## Authoring Notes For Release-Friendly Changelogs

The latest `CHANGELOG.md` entry is rendered as-is on GitHub Releases. Keep it
self-contained:

- Start at heading level `## <version> - <YYYY-MM-DD>`.
- Use Keep-a-Changelog sections (`### Added`, `### Changed`, `### Removed`,
  `### Fixed`, `### Source Contracts`).
- Avoid relative links that only resolve inside the repo unless they still
  make sense on the Releases page.
- Do not embed secrets, credentials, or private data.

## When Not To Cut A Release

- Pure source-contract `reviewed_at` refresh with no agent-visible change —
  bump `last_reviewed` only, no version bump, no release.
- Repository-level governance changes (this `docs/` folder, scripts, CI) that
  do not touch any skill's `metadata.json` version.
- Work-in-progress branches before merge to `main`.

# Releasing plugins

A plugin is the unit a consumer installs. A plugin release publishes a GitHub
Release with a **distributable `.zip`** attached, so the plugin can be loaded
without cloning the marketplace.

## Release Identity

- **Tag**: `<name>--v<version>` (e.g. `blassioli--v0.2.0`) — the format
  `claude plugin tag` produces.
- **Title**: `<name> v<version>`.
- **Body**: the matching section of `plugins/<name>/CHANGELOG.md` if present;
  otherwise a generated inventory of the bundled skills and their versions.
- **Asset**: `<name>.zip` — the plugin tree with the plugin root at the zip
  root (`.claude-plugin/plugin.json` at top level), **excluding** `evals/` and
  any `.work/`.
- **Target**: the `main` commit that merged the version bump.
- **Source of truth**: `plugins/<name>/.claude-plugin/plugin.json` `version`
  (decoupled from per-skill `metadata.json` versions).

## What the `.zip` is and is NOT for

Claude Code **cannot persistently install a plugin from a `.zip`**.
`claude plugin install` and `marketplace.json` `source` accept only git, a
local path, or a GitHub repo — there is no zip/archive source type. The `.zip`
is therefore a convenience artifact for:

- **ephemeral, session-scoped loads** — `claude --plugin-url <release-asset-url>.zip`
  or `claude --plugin-dir <file>.zip` (load for one session, e.g. to test a
  release candidate or in CI);
- **offline / air-gapped** hand-off.

The **persistent install channel stays the git marketplace**:

```
/plugin marketplace add felipeblassioli/agent-skills
/plugin install <name>@agent-skills
/plugin marketplace update
```

To make a persistent install resolve to a *specific* plugin version, pin the
`marketplace.json` entry to the plugin's release tag (a `ref`/`sha`); the bare
relative-path `source` always tracks `main`.

## Automated Path (default)

`.github/workflows/release-plugin.yaml` runs on every push to `main`. For each
plugin whose `plugin.json` `version` changed, it installs the Claude Code CLI,
then runs `scripts/release-plugin.sh`, which validates, builds the `.zip`, and
creates the release. Idempotent: an existing tag is skipped.

## Manual Path (fallback)

```bash
# from the repo root
bash scripts/release-plugin.sh plugins/<name>            # release
bash scripts/release-plugin.sh plugins/<name> --dry-run  # preview notes + zip
```

The script:

- reads `name`/`version` from `plugin.json`;
- runs `claude plugin validate --strict` (manifest gate) and
  `claude plugin tag --dry-run` (plugin.json ↔ marketplace.json agreement);
- extracts the changelog section (or generates the skill inventory);
- builds `<name>.zip`;
- refuses to publish from a dirty working tree;
- creates `<name>--v<version>` and the GitHub Release with the `.zip` via `gh`.

Requires `gh`, `jq`, `zip`, `git`, and `claude` on `PATH`, `gh auth status`
succeeding, and push permission on `github.com/felipeblassioli/agent-skills`.

## When Not To Cut A Plugin Release

- A `plugin.json` edit that does not change `version` (e.g. description fix).
- A skill-only change: release the skill instead; bump the plugin only when you
  want a new installable plugin version.
