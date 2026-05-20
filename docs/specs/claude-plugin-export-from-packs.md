# Claude Plugin Export From Packs

## Status

Draft (v0). Maturity: **L0 (experimental)** per ADR-0003. Promotion to L1
requires the verification workflow in this spec passing against at least one
real pack.

## Purpose

Define how this repository should export registry-managed Cursor Packs into
self-contained Claude Code plugin directories and a Claude Plugin Marketplace
catalog, for **local install** by the repository owner.

This specification implements the follow-up from
`docs/ADR/ADR-0004-cross-runtime-agent-packaging-model.md`: packs remain the
repository-native source of truth, while Claude Plugin files are generated or
staged platform outputs.

## Goals

- Generate self-contained Claude Plugin directories from `packs/<name>/`.
- Generate a Claude Plugin Marketplace catalog for exported packs that can be
  installed via `/plugin marketplace add <path>` from a local checkout.
- Preserve pack authority, versioning, and safety rules from `pack.json` and
  `cursor-pack-registry.json`.
- Keep MCP activation explicit and trust-reviewed.
- Avoid platform-specific metadata drift between Claude output and pack source.
- Default to safe (user-global) Claude installs; never silently ship
  project-only policy globally.

## Non-goals

- Replace `scripts/cursor-pack-sync.sh`.
- Rename Cursor Packs or `cursor-pack-*` scripts.
- Change `pack.json` or `cursor-pack-registry.json` schemas (this spec uses
  an optional discriminator only; see "Artifact Classification").
- Publish to Anthropic's official or community marketplaces.
- Provide a public Git-native distribution surface (committed exports, orphan
  branch, release archives, or separate repo). This is a separate follow-up
  spec.
- Automatically install or enable live MCP servers.
- Export Cursor hooks. Cursor hook events and Claude hook events differ
  enough that a deliberate mapping is out of scope for v0.
- Export Cursor rules into Claude user-global behavior.
- Export every pack artifact if there is no safe Claude equivalent.

## Source Of Truth

The exporter MUST treat these files as source authority:

- `packs/<name>/pack.json`
- `cursor-pack-registry.json`
- pack payload files under `packs/<name>/`
- pack release artifacts for human evidence

Generated Claude files MUST NOT become independent version or release
authority. If generated output conflicts with source pack metadata, the pack
source wins.

## Distribution Surface (v0)

The exporter stages generated artifacts under `.work/claude-plugin-export/`
only. `.work/` is gitignored.

- Local install: `/plugin marketplace add <abs-path-to-export-root>` from a
  checkout of this repository.
- Public distribution (committed exports, orphan branches, release archives,
  separate repos) is **out of scope** for v0 and tracked as follow-up work in
  ADR-0004. The exporter MUST NOT write outside `.work/` in v0.

## Plugin Granularity (v0)

One Claude plugin per pack. The exporter accepts `--profile=<profile>` to
select which Cursor Pack profile defines the export's artifact set. Default is
`install.defaultProfile` from `pack.json`.

Multiple-variant export (one Claude plugin per `(pack, profile)` pair) is
deferred. Operators who want both flavors today can run the exporter twice
into different `--output` directories.

## Output Layout

```text
.work/claude-plugin-export/
├── .claude-plugin/
│   └── marketplace.json
└── plugins/
    └── <pack-name>/
        ├── .claude-plugin/
        │   └── plugin.json
        ├── skills/
        │   └── <skillId>/
        ├── agents/
        │   └── <agent-name>.md
        ├── assets/
        └── README.md
```

`hooks/` is intentionally absent from v0 (see Non-goals).

## Marketplace Catalog

Written to:

```text
.work/claude-plugin-export/.claude-plugin/marketplace.json
```

MUST contain `name`, `owner`, `plugins`.

The marketplace `name` MUST NOT use Anthropic-reserved names such as
`claude-plugins-official`, `anthropic-plugins`. Recommended default for this
repository is `felipeblassioli-agent-packs`. **Forks MUST change this name**;
the exporter MUST accept `--marketplace-name=<name>` to override.

```json
{
  "name": "felipeblassioli-agent-packs",
  "owner": { "name": "felipeblassioli" },
  "plugins": []
}
```

Each exported pack becomes one entry:

```json
{
  "name": "<pack-name>",
  "source": "./plugins/<pack-name>",
  "description": "<pack description from pack.json>",
  "version": "<pack version from pack.json>"
}
```

Relative `./plugins/<pack-name>` sources are valid because v0 installs from a
local path. Git-native sources (`github`, `url`, `git-subdir`, `npm`) are
out of scope until the public distribution spec lands.

## Plugin Manifest

Each exported pack generates:

```text
plugins/<pack-name>/.claude-plugin/plugin.json
```

MUST include `name`, `description`, `version`.

SHOULD include:

- `author`
- `skills` when exported bundled skills exist
- `agents` when exported agents exist

MUST NOT include:

- `hooks` (out of scope for v0)
- `mcpServers` (live MCP requires separate trust review; see "MCP")
- `commands`, `lspServers` (out of scope; declare in follow-up if needed)

Example:

```json
{
  "name": "cursor-companion",
  "description": "Cursor companion runtime pack exported for Claude Code.",
  "version": "1.2.3",
  "author": { "name": "felipeblassioli" },
  "skills": "./skills",
  "agents": "./agents"
}
```

JSON output MUST be deterministic: stable key order, two-space indentation,
trailing newline. This keeps regeneration diffs reviewable.

## Artifact Classification

`cursor-pack.schema.json` knows only `kind: "runtime"` and `kind: "skill"`.
The exporter needs to distinguish subagents, hooks, rules, and MCP examples
within `runtime` artifacts.

v0 uses a **hybrid** strategy:

1. **Preferred**: an opt-in `runtimeKind` field on runtime artifacts in
   `pack.json`. Values: `"agent" | "hook" | "rule" | "mcp-example"`.
2. **Fallback**: source-path convention. Heuristics applied in order:

   | Source path pattern                | Inferred `runtimeKind` |
   |------------------------------------|------------------------|
   | `.cursor/agents/`                  | `agent`                |
   | `.cursor/hooks/`, `hooks.*.json`   | `hook`                 |
   | `.cursor/rules/`                   | `rule`                 |
   | `.cursor/mcp.example.json`         | `mcp-example`          |

3. **Failure mode**: if neither rule classifies a runtime artifact, the
   exporter MUST log a warning naming the artifact `id` and SHOULD skip it.
   It MUST NOT guess.

`runtimeKind` is **optional** in `pack.json` for v0. Existing packs do not
require migration. Packs that opt into Claude export SHOULD set
`runtimeKind` explicitly to avoid the heuristic fallback.

The schema change is additive: a new optional property on the runtime artifact
oneOf branch. `scripts/cursor-pack-verify.sh` MUST accept packs that omit it.
`scripts/cursor-pack-verify.sh` MUST reject `runtimeKind` values not in the
enum above. A separate spec MAY later make `runtimeKind` required for
export-eligible packs.

## Artifact Mapping

### Bundled skills (`kind: "skill"`)

Copied to `plugins/<pack-name>/skills/<skillId>/`. MUST remain self-contained.

`SKILL.md` and `metadata.json` are copied verbatim. `metadata.json` is not
read by Claude but ships for traceability back to the source pack.

The pack remains the version authority. Exported bundled skills MUST NOT be
added to `skill-registry.json`.

Collision policy: if two bundled skill artifacts in the same pack export to
the same `skillId` directory, the exporter MUST fail with a clear error
naming both artifact ids. Cross-pack collisions cannot happen because each
pack exports into its own `plugins/<pack-name>/skills/` tree.

### Agents (`runtimeKind: "agent"`)

Copied as Markdown files into `plugins/<pack-name>/agents/`. Naming uses the
frontmatter `name` field: `agents/<frontmatter-name>.md`. Collisions within a
pack MUST fail with a clear error.

Frontmatter mapping table (Cursor subagent → Claude Plugin agent):

| Cursor field           | Claude field          | v0 behavior                                                                 |
|------------------------|-----------------------|-----------------------------------------------------------------------------|
| `name`                 | `name`                | verbatim                                                                    |
| `description`          | `description`        | verbatim                                                                    |
| `model`                | `model`               | **dropped** with warning; Cursor model slugs (`fast`, `composer-2`) are not valid Claude slugs. Claude uses its default. |
| `readonly: true`       | (none)                | **dropped** with warning. v0 has no precise Claude analog. A future spec MAY translate to `disallowedTools`. |
| `readonly: false`      | (none)                | dropped (no-op)                                                             |
| `background: true|false` | `background`        | verbatim                                                                    |
| any other field        | (varies)              | rejected: exporter MUST fail naming the unknown field, unless the field is in the rejected set below in which case it MUST fail with the safety message |

The exporter MUST reject (fail, not skip) agents whose Cursor frontmatter
contains any of: `hooks`, `mcpServers`, `permissionMode`. These fields imply
behavior that does not transfer safely. Rejection error MUST name the agent
and the offending field.

Markdown body of the agent file is copied verbatim. The exporter MUST NOT
attempt to rewrite Cursor-specific tool references in prose; that is a
documentation concern outside v0.

### Hooks

Out of scope for v0. Declared in Non-goals.

If a `runtimeKind: "hook"` artifact (or source-path-inferred hook) is included
in the selected profile, the exporter MUST skip it with a warning. It MUST
NOT fail the whole export.

### Rules

Cursor rules have no automatic Claude Plugin equivalent. Default behavior:

- `runtimeKind: "rule"` (or path-inferred rules) under `project-cursor`
  targets: **skipped silently** (consistent with project-only safety).
- `runtimeKind: "rule"` under `user-cursor` targets: **skipped with a
  warning** naming the artifact. Reuse-as-skill is the recommended path.

The exporter MUST NOT copy rule files into the plugin tree in v0.

### MCP examples (`runtimeKind: "mcp-example"`)

Cursor Pack `mcpPolicy` remains authoritative:

- `mcpPolicy: "none"` exports no MCP files.
- `mcpPolicy: "example-only"` MAY copy MCP example files into
  `plugins/<pack-name>/assets/mcp-examples/` for documentation. The exporter
  MUST NOT generate a live `.mcp.json` and MUST NOT add `mcpServers` to
  `plugin.json`.

Live Claude Plugin MCP export is allowed only after a separate trust review
that approves server command, arguments, environment variable handling,
credential access, network access, and local file access. v0 does not provide
this path.

### Guides and assets

Pack `guides/` and `assets/` MAY be copied into the plugin output **only if
referenced by exported skills or agents**. The exporter MUST NOT blindly
mirror the pack tree.

Exported files MUST be self-contained: no `../` references outside
`plugins/<pack-name>/` (enforced; see "Validation").

### Pack release artifacts

`CHANGELOG.md`, `VERIFICATION.md`, `RELEASE-POLICY.md`, `ROADMAP.md`,
`LICENSE` from the pack root:

- `LICENSE` MUST be copied to `plugins/<pack-name>/LICENSE` if it exists.
- Other release artifacts MUST NOT be copied. They are repository-internal
  governance, not consumer documentation.

## README Generation

The exporter MUST generate `plugins/<pack-name>/README.md`. It MUST NOT copy
the pack's source `README.md` (which references repo-relative paths that
won't resolve inside `~/.claude/plugins/cache`).

The generated README MUST contain at minimum:

- pack `name`, `version`, `description` from `pack.json`
- a list of exported skills with their `skillId` and one-line description
- a list of exported agents with their `name` and one-line description
- a note that this plugin was generated from upstream pack source, with a
  link to the upstream repository and the pack path within it
- a clear statement that hooks and live MCP are not exported in this build

The generator SHOULD use a simple Markdown template; complex formatting is
out of scope.

## Profile And Target Selection

The exporter accepts `--profile=<profile>`. Default is
`install.defaultProfile` from `pack.json`.

Two filters apply in order:

1. **Profile filter**: an artifact is in-scope only if its `profiles` array
   includes the selected profile.
2. **Target-safety filter**: an artifact is in-scope only if its `targets`
   array includes `user-cursor`. Artifacts that are `project-cursor`-only
   are **excluded by default**.

`--include-project-only` flips the second filter. When set, the exporter MUST
emit a per-artifact warning naming the artifact id and explaining that
project-only policy is being installed as a Claude user-global plugin. The
exporter SHOULD also emit a summary line at the end listing all
project-only artifacts that were included.

Repository-specific rules and hooks MUST NOT become Claude user-global
behavior by default; the default filters enforce this.

## Self-Contained Output Requirement

Claude Code copies installed plugins into `~/.claude/plugins/cache`. Exported
plugins therefore MUST be complete within `plugins/<pack-name>/`.

Generated plugin files MUST NOT:

- reference `../` paths outside the plugin root in any path-typed field
- depend on files under the source pack after installation
- rely on repository-relative paths in `plugin.json` or skill/agent
  frontmatter
- assume the repository is present on the target machine
- contain symbolic links whose targets resolve outside the plugin root

Prose `../` references inside generated README files or skill bodies are not
inspected; the constraint applies to **path-typed fields** only (see
"Validation").

If multiple exported plugins need the same supporting file, the v0 exporter
**duplicates** it into each plugin output. Shared-file deduplication is
deferred.

## Idempotency

`--output` may point to an existing directory. Default behavior is
**clobber**: the exporter removes the existing
`<output>/.claude-plugin/` and `<output>/plugins/<pack-name>/` subtrees for
packs included in this run, then regenerates them. Subtrees for packs not
included in the run are left untouched.

`--dry-run` MUST NOT touch the filesystem.

## Command Shape

```bash
bash scripts/claude-plugin-export.sh \
  --pack=<name> \
  --profile=<profile> \
  --output=.work/claude-plugin-export \
  --dry-run
```

Required v0 flags:

- `--pack=<name>` (repeatable) or `--all`
- `--output=<path>` (default `.work/claude-plugin-export`; MUST be under
  `.work/` in v0)
- `--dry-run`

Optional v0 flags:

- `--profile=<profile>` (default = pack's `install.defaultProfile`)
- `--marketplace-name=<name>` (default `felipeblassioli-agent-packs`)
- `--include-project-only` (off by default; emits warnings)

Reserved-but-unimplemented in v0 (out of scope, documented for forward
compatibility):

- `--source=relative|github|git-subdir|url|npm`
- `--repo=<owner/repo>`
- `--ref=<git-ref>`
- `--sha=<git-sha>`

`--dry-run` MUST print planned output paths, included artifacts, omitted
artifacts (with reason: profile, target-safety, unknown classification,
hook-skipped, rule-skipped, etc.), and any safety blockers, without writing
files.

## Validation

### Pre-generation checks (MUST)

- pack exists in `cursor-pack-registry.json`
- `pack.json.version` equals the registry version
- selected profile exists in `pack.json.profiles`
- every included artifact's `profiles` array references the selected profile
- bundled skill source directories contain `SKILL.md` and `metadata.json`
- agent frontmatter contains none of the rejected fields (`hooks`,
  `mcpServers`, `permissionMode`)
- agent frontmatter contains no fields outside the mapping table
- no live MCP config is generated
- `--output` is under `.work/`
- `runtimeKind` values, if present, are in the documented enum

### Post-generation checks (MUST)

- `.claude-plugin/marketplace.json` parses as JSON
- each generated `.claude-plugin/plugin.json` parses as JSON
- every marketplace `source` resolves to an exported plugin directory
- every declared `skills` and `agents` path in `plugin.json` exists
- `../`-scan **on path-typed fields only**: `.claude-plugin/marketplace.json`
  `source` values; `.claude-plugin/plugin.json` `skills`, `agents`, and any
  future path-typed fields; skill and agent frontmatter `path`-typed fields.
  Prose is NOT scanned.
- no symlinks in `plugins/<pack-name>/` whose target resolves outside that
  directory
- generated JSON files are byte-stable across two consecutive runs with
  identical inputs (determinism check)

## Verification Workflow

A release-quality v0 implementation MUST prove all of:

1. Exporting `cursor-companion` (multi-artifact pack) at `defaultProfile`
   produces a valid plugin tree with skills and agents and a marketplace
   catalog.
2. Exporting a pack with bundled skills only produces a skills-only plugin
   with no `agents` field in `plugin.json`.
3. Project-only artifacts are excluded by default and included with warnings
   under `--include-project-only`.
4. Cursor agents with rejected fields (`hooks`, `mcpServers`,
   `permissionMode`) cause the exporter to fail with a clear error naming
   the agent and field.
5. `mcpPolicy: "example-only"` packs produce no `mcpServers` field and place
   MCP example files under `assets/mcp-examples/` only.
6. A second invocation with identical inputs produces byte-identical output
   (determinism).
7. Manual Claude Code install from the staging path succeeds when Claude
   Code is available:

```text
/plugin marketplace add <abs-path-to>/.work/claude-plugin-export
/plugin install <pack-name>@felipeblassioli-agent-packs
/reload-plugins
```

Evidence of items 1–6 MUST be recorded in the pack's `VERIFICATION.md` (or a
dedicated `docs/specs/claude-plugin-export-verification.md` if cross-pack).
Item 7 evidence MAY be a screenshot or terminal log.

Promotion from L0 to L1 requires all seven items demonstrated for at least
one real pack.

## Open Questions (deferred to follow-up specs, not blockers)

- **Public distribution surface**: commit, orphan branch, release archive,
  or separate repo. Tracked under ADR-0004 follow-up work. v0 ships local-only.
- **Multiple-variant export** (one Claude plugin per `(pack, profile)`).
- **Claude release tagging** relative to `pack-<name>@<version>` tags.
- **Live MCP trust review** recorded in `VERIFICATION.md`, a separate trust
  file, or both.
- **Cursor `readonly: true` → Claude `disallowedTools`** translation table.
- **Cursor model slug → Claude model slug** mapping if/when Cursor model
  semantics align meaningfully with Claude's.

## References

- ADR-0004:
  `docs/ADR/ADR-0004-cross-runtime-agent-packaging-model.md`
- Cursor Pack specification:
  `docs/specs/cursor-pack-specification.md`
- Cursor Pack schema:
  `cursor-pack.schema.json`
- Agentic skill and pack authoring:
  `docs/specs/agentic-skill-pack-authoring.md`
- Personal pack maintainer:
  `packs/cursor-skill-studio/skills/skill-studio-maintain/SKILL.md`
  (consolidates the former `personal-pack-maintainer` root skill per ADR-0005)
- Claude Code plugin marketplaces:
  `https://code.claude.com/docs/en/plugin-marketplaces`
- Claude Code plugin reference:
  `https://code.claude.com/docs/en/plugins-reference`
