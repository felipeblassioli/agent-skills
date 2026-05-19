# Claude Plugin Export From Packs

## Status

Draft

## Purpose

Define how this repository should export registry-managed Cursor Packs into
Claude Code plugin and marketplace artifacts.

This specification implements the follow-up from
`docs/ADR/ADR-0004-cross-runtime-agent-packaging-model.md`: packs remain the
repository-native source of truth, while Claude Plugin files are generated or
staged platform outputs.

## Goals

- Generate self-contained Claude Plugin directories from `packs/<name>/`.
- Generate a Claude Plugin Marketplace catalog for exported packs.
- Preserve pack authority, versioning, and safety rules from `pack.json` and
  `cursor-pack-registry.json`.
- Keep MCP activation explicit and trust-reviewed.
- Avoid platform-specific metadata drift between Claude output and pack source.

## Non-goals

- Replace `scripts/cursor-pack-sync.sh`.
- Rename Cursor Packs or `cursor-pack-*` scripts.
- Change `pack.json`, `cursor-pack-registry.json`, or existing pack schemas.
- Publish to Anthropic's official or community marketplaces.
- Automatically install or enable live MCP servers.
- Export every pack artifact if there is no safe Claude equivalent.

## Source Of Truth

The exporter MUST treat these files as source authority:

- `packs/<name>/pack.json`
- `cursor-pack-registry.json`
- pack payload files under `packs/<name>/`
- pack release artifacts for human evidence

Generated Claude files MUST NOT become independent version or release authority.
If generated output conflicts with source pack metadata, the pack source wins.

## Output Layout

The exporter SHOULD stage generated artifacts under `.work/` by default so the
repository does not commit generated plugin trees accidentally.

Recommended staging layout:

```text
.work/claude-plugin-export/
├── .claude-plugin/
│   └── marketplace.json
└── plugins/
    └── <pack-name>/
        ├── .claude-plugin/
        │   └── plugin.json
        ├── skills/
        ├── agents/
        ├── hooks/
        ├── assets/
        └── README.md
```

Committed Claude marketplace artifacts may be considered later, but that is a
separate release decision. The first implementation should generate reviewable
staging output.

## Marketplace Catalog

The marketplace catalog MUST be written to:

```text
.work/claude-plugin-export/.claude-plugin/marketplace.json
```

The generated catalog MUST contain:

- `name`
- `owner`
- `plugins`

The marketplace name MUST NOT use Anthropic-reserved names such as
`claude-plugins-official`, `anthropic-plugins`, or `agent-skills`.

Recommended marketplace name:

```json
{
  "name": "felipeblassioli-agent-packs",
  "owner": {
    "name": "felipeblassioli"
  },
  "plugins": []
}
```

Each exported pack SHOULD become one plugin entry:

```json
{
  "name": "<pack-name>",
  "source": "./plugins/<pack-name>",
  "description": "<pack description>",
  "version": "<pack version>"
}
```

Relative plugin sources are valid only when the marketplace is added from a Git
source or local path. If the marketplace is distributed as a direct URL to
`marketplace.json`, plugin entries MUST use `github`, `url`, `git-subdir`, or
`npm` sources instead.

## Plugin Manifest

Each exported pack MUST generate:

```text
plugins/<pack-name>/.claude-plugin/plugin.json
```

The manifest MUST include:

- `name`
- `description`
- `version`

The manifest SHOULD include:

- `author`
- `skills` when exported bundled skills exist
- `agents` when exported agents exist
- `hooks` when exported hooks exist and pass safety review
- `mcpServers` only after explicit live MCP trust review

Example:

```json
{
  "name": "cursor-companion",
  "description": "Cursor companion runtime pack exported for Claude Code.",
  "version": "1.2.3",
  "author": {
    "name": "felipeblassioli"
  },
  "skills": "./skills",
  "agents": "./agents"
}
```

The exporter MUST NOT add `mcpServers` by translating
`.cursor/mcp.example.json` automatically.

## Artifact Mapping

### Bundled Skills

Pack-bundled skills declared with `kind: "skill"` SHOULD be copied to:

```text
plugins/<pack-name>/skills/<skillId>/
```

The exported skill directory MUST remain self-contained and include its
supporting files. `SKILL.md` and `metadata.json` remain required at source.

The pack remains the version authority. Do not add exported bundled skills to
`skill-registry.json`.

### Agents

Pack agent artifacts MAY be copied to:

```text
plugins/<pack-name>/agents/
```

Before export, the implementation MUST verify that agent frontmatter is
compatible with Claude Plugin agents. Claude Plugin agents support fields such as
`name`, `description`, `model`, `effort`, `maxTurns`, `tools`,
`disallowedTools`, `skills`, `memory`, `background`, and `isolation`.

The exporter MUST reject or omit plugin-shipped agents that require unsupported
Claude Plugin agent fields such as `hooks`, `mcpServers`, or `permissionMode`.

### Hooks

Hooks MAY be exported only after a platform-specific safety review.

Claude Plugin hooks are not the same as Cursor hooks. A future implementation
MUST map hook events deliberately and MUST NOT copy Cursor hook config as-is.

Exported hooks must:

- be bounded
- be inspectable
- be explained in the generated plugin README or source pack README
- use paths relative to the Claude plugin root
- use `${CLAUDE_PLUGIN_ROOT}` when a command needs to reference bundled scripts

### MCP Examples

Cursor Pack MCP policy remains authoritative:

- `mcpPolicy: "none"` exports no MCP files.
- `mcpPolicy: "example-only"` MAY copy MCP examples into documentation or
  `assets/`, but MUST NOT generate live `.mcp.json` or `mcpServers`.

Live Claude Plugin MCP export is allowed only after a separate trust review that
approves:

- server command
- arguments
- environment variable handling
- credential access
- network access
- local file access

### Rules

Cursor rules have no automatic Claude Plugin equivalent in this spec.

Project-specific Cursor rules MUST NOT be exported into Claude user-global
behavior. If a rule contains reusable guidance, convert it into a skill or
documentation through a separate review rather than copying it directly.

### Guides And Assets

Pack `guides/` and `assets/` MAY be copied into the plugin output when they are
referenced by exported skills, agents, hooks, or README files.

The exporter MUST keep the Claude plugin tree self-contained. Exported files must
not rely on `../` paths outside `plugins/<pack-name>/`.

## Profile And Target Selection

The exporter MUST accept an explicit pack profile.

Default behavior SHOULD use `install.defaultProfile` from `pack.json`.

Artifacts are eligible for Claude export only when their `profiles` include the
selected profile.

Cursor targets do not map directly to Claude scopes. The first implementation
SHOULD treat `user-cursor` artifacts as the safest default export candidates and
SHOULD require an explicit flag to include `project-cursor`-only artifacts.

Project-only policy from the pack remains binding. Repository-specific rules or
hooks MUST NOT become globally installed Claude plugin behavior by default.

## Self-Contained Output Requirement

Claude Code copies installed plugins into `~/.claude/plugins/cache`. Exported
plugins therefore MUST be complete within the plugin directory.

Generated plugin files MUST NOT:

- reference `../` paths outside the plugin root
- depend on files under the source pack after installation
- rely on repository-relative paths
- assume the repository is present on the target machine

If multiple exported plugins need shared files, the first implementation SHOULD
duplicate those files into each plugin output. Shared-file deduplication can be
specified later.

## Command Shape

The first implementation SHOULD add a script with this shape:

```bash
bash scripts/claude-plugin-export.sh \
  --pack=<name> \
  --profile=<profile> \
  --output=.work/claude-plugin-export \
  --dry-run
```

Optional future flags:

```bash
--all
--include-project-only
--marketplace-name=<name>
--source=relative|github|git-subdir|url|npm
--repo=<owner/repo>
--ref=<git-ref>
--sha=<git-sha>
```

`--dry-run` MUST print planned generated paths, included artifacts, omitted
artifacts, and safety blockers without writing files.

## Validation Requirements

Before generating output, the exporter MUST validate:

- the pack exists in `cursor-pack-registry.json`
- `pack.json.version` equals the registry version
- selected profile exists
- exported artifact profiles reference the selected profile
- bundled skill source directories contain `SKILL.md` and `metadata.json`
- no exported file references `../` outside the plugin root
- no live MCP config is generated without explicit trust review
- project-only artifacts are omitted unless explicitly included

After generating output, the exporter SHOULD validate:

- `.claude-plugin/marketplace.json` parses as JSON
- each generated `.claude-plugin/plugin.json` parses as JSON
- every marketplace relative `source` points to an exported plugin directory
- every declared `skills`, `agents`, or `hooks` path exists
- generated plugin directories are self-contained

## Verification Workflow

A release-quality implementation should prove:

1. Exporting one pack with bundled skills only.
2. Exporting one pack with agents.
3. Omitting MCP examples from live config.
4. Rejecting or omitting unsupported Claude Plugin agent fields.
5. Generating a marketplace catalog with relative plugin sources.
6. Running `claude` plugin marketplace add/install manually from a scratch copy
   when Claude Code is available.

Manual Claude Code validation should use:

```text
/plugin marketplace add <path-to-export-root>
/plugin install <pack-name>@felipeblassioli-agent-packs
/reload-plugins
```

## Open Questions

- Should generated Claude plugin output ever be committed, or should releases
  publish it as archive artifacts only?
- Should each pack become one Claude plugin, or should some packs export multiple
  plugins?
- Should this repository add a `claude-plugin-registry.json`, or is the generated
  marketplace catalog enough?
- How should exported Claude plugin versions relate to `pack-<name>@<version>`
  GitHub release tags?
- Should live MCP review results be recorded in pack `VERIFICATION.md`, a
  separate trust file, or both?

## References

- ADR-0004:
  `docs/ADR/ADR-0004-cross-runtime-agent-packaging-model.md`
- Cursor Pack specification:
  `docs/specs/cursor-pack-specification.md`
- Agentic skill and pack authoring:
  `docs/specs/agentic-skill-pack-authoring.md`
- Personal pack maintainer:
  `.agents/skills/personal-pack-maintainer/SKILL.md`
- Claude Code plugin marketplaces:
  `https://code.claude.com/docs/en/plugin-marketplaces`
- Claude Code plugin reference:
  `https://code.claude.com/docs/en/plugins-reference`
