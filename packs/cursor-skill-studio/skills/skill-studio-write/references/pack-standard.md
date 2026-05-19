# Cursor Pack Standard

Condensed repo reference for authoring installable Cursor packs in
`felipeblassioli/agent-skills`.

## Required locations

| Path | Purpose |
|---|---|
| `packs/<name>/pack.json` | Pack contract and install manifest |
| `packs/<name>/README.md` | Human-facing overview |
| `cursor-pack-registry.json` | Catalog entry for discovery and install tooling |
| `scripts/cursor-pack-verify.sh` | Canonical validator |
| `scripts/cursor-pack-sync.sh` | Installer for project/user targets |
| `scripts/cursor-pack-restore.sh` | Backup restore flow |

For evolving packs, also commit release artifacts at pack root:

| Path | Purpose |
|---|---|
| `packs/<name>/CHANGELOG.md` | Release-by-release change history |
| `packs/<name>/VERIFICATION.md` | Release companion with validation evidence and diagnosis |
| `packs/<name>/RELEASE-POLICY.md` | Rules for versioning, verification, and release expectations |
| `packs/<name>/ROADMAP.md` | Next improvements and known follow-up work |

Optional **bundled skills** (same semantics as `skills/<name>/`, different delivery
channel):

| Path | Purpose |
|---|---|
| `packs/<name>/skills/<folder>/SKILL.md` | Bundled skill hot path |
| `packs/<name>/skills/<folder>/metadata.json` | Bundled skill metadata |

Declare each bundled skill in `pack.json` with `"kind": "skill"`, a pack-scoped
`skillId`, and `source` pointing at that directory. See
`docs/specs/agentic-skill-pack-authoring.md` (pack-bundled skills).

## Pack naming rules

- lowercase letters, numbers, and hyphens only
- directory name must match `pack.json.name`
- keep names descriptive and surface-oriented
- prefer one pack per coherent operational outcome

## Required `pack.json` fields

```json
{
  "name": "pack-name",
  "version": "0.1.0",
  "description": "What the pack installs and why it exists.",
  "author": "felipeblassioli",
  "targets": ["project-cursor"],
  "profiles": {
    "lite": {
      "description": "Safe default profile."
    }
  },
  "artifacts": [
    {
      "id": "agents",
      "source": ".cursor/agents",
      "targets": ["project-cursor"],
      "profiles": ["lite"],
      "projectPath": ".cursor/agents"
    }
  ],
  "install": {
    "defaultProfile": "lite",
    "backupOnConflict": true,
    "stageRoot": ".work/cursor-pack-staging",
    "backupRoot": ".work/cursor-pack-backups",
    "manifestFile": ".cursor-pack-manifest.json",
    "conflictPolicy": "backup-and-overwrite",
    "mcpPolicy": "example-only"
  }
}
```

## Required registry fields

Each `cursor-pack-registry.json` entry must include:

```json
{
  "version": "0.1.0",
  "author": "felipeblassioli",
  "path": "packs/pack-name",
  "targets": ["project-cursor"],
  "profiles": ["lite"],
  "installPolicy": {
    "backupOnConflict": true,
    "defaultProfile": "lite",
    "projectRules": "project-only",
    "mcp": "example-only"
  },
  "tags": ["cursor", "subagents"],
  "description": "Short human-readable summary."
}
```

## Runtime surface rules

| Surface | Typical path | Guidance |
|---|---|---|
| Subagents | `.cursor/agents/*.md` | Use for noisy, parallel, or context-heavy helper work |
| Rules | `.cursor/rules/*.mdc` | Use for durable project guidance |
| Hook configs | `.cursor/hooks.project.json`, `.cursor/hooks.user.json` | Use for runtime enforcement wiring |
| Hook scripts | `.cursor/hooks/*` | Must be executable and pack-local |
| MCP examples | `.cursor/mcp.example.json` | Keep example-only by default |
| Guides | `guides/*.md` | Explain installation, usage, and safety trade-offs |
| Bundled skills | `skills/<folder>/` under pack root | `kind: "skill"` artifacts; install to `.cursor/skills/<skillId>/` or `~/.cursor/skills/<skillId>/` |

## Authoring constraints

- Create only files and directories that the approved artifact matrix needs.
- Keep pack examples portable: no personal usernames or machine-specific paths.
- Never commit real credentials.
- Prefer `${env:VAR}` interpolation in MCP examples.
- Do not make assumptions about user-level Cursor rule storage beyond current
  repo conventions.
- Do not auto-install the pack as part of authoring.
- If the pack will evolve across releases, keep release artifacts committed in
  the pack root instead of relying on transient chat history.
- Do not fold bundled skill bodies into `.cursor/rules` or the pack README;
  keep them skill-shaped and referenced only via `kind: "skill"` artifacts.
- Prefer **pack-scoped** `skillId` values (for example `my-pack-overview`) to
  avoid collisions with `skill-registry.json` skills synced to the same
  `~/.cursor/skills/` namespace.

## Validation expectations

The canonical validator checks:

- `pack.json` JSON validity and required top-level fields
- registry/version/path consistency
- committed release artifacts for evolving packs
- missing artifact sources
- profile/target consistency across artifacts
- subagent frontmatter
- rule frontmatter and size
- hook config JSON and local hook references
- MCP example JSON and secret detection
- machine-specific paths and suspicious credentials
- bundled skill artifacts (`kind: "skill"`): directory `source`, `SKILL.md` and
  `metadata.json`, `skillId` pattern, duplicate `skillId` within the pack,
  YAML frontmatter `name` matches `skillId`

Run via:

```bash
bash scripts/cursor-pack-verify.sh --pack=<name>
```

For evolving packs, verification should also be summarized in:

- `VERIFICATION.md`

and linked from:

- `CHANGELOG.md`

## Current schema gap

`cursor-pack.schema.json` supports **runtime** artifacts (optional
`"kind": "runtime"`) and **bundled skill** artifacts (`"kind": "skill"` +
`skillId`).
Schemas are still not optimized for reliable **recommendation** metadata. Before
building a recommender, capture richer machine-readable intent in:

- `references/recommendation-metadata.md`

That metadata should be designed first, then promoted into
`cursor-pack-registry.schema.json` or `cursor-pack.schema.json` in a separate
change when the repo is ready.
