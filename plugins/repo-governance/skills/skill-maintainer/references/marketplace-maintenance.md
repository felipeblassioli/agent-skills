# Marketplace & Manifest Maintenance

agent-skills is a Claude Code plugin marketplace. Distribution is driven by two
manifests, not the legacy Cursor registry.

## `.claude-plugin/marketplace.json` (repo root)

The catalog. Required: `name` (the suffix users install with — `plugin@<name>`,
so this one's is `"agent-skills"`), `owner` (name + email), and `plugins[]`. Each
plugin entry needs `name` + `source` (e.g. `./plugins/repo-governance`);
`description` and `author` are recommended.

## `plugins/<plugin>/.claude-plugin/plugin.json`

The plugin manifest. `name` is the invocation namespace (skills become
`/<plugin>:<skill>`). Set an explicit `version` and bump it per release — if
omitted on a git-hosted marketplace, every commit counts as a new version.
Include `author` (name + email) for ownership.

## Tiers

- **Official plugin** (e.g. `repo-governance`) — reviewed, supported, defined
  audience.
- **Sandbox plugin** (e.g. `blassioli`) — personal, experimental, "use at your
  own risk". Carries that note in its `plugin.json` description.

See `docs/marketplace-governance.md` for the full tier and promotion model.

## Adding or promoting a plugin/skill

1. Place the skill at `plugins/<plugin>/skills/<skill>/`.
2. Ensure `plugin.json` exists and the plugin is listed in `marketplace.json`.
3. Validate: `claude plugin validate ./plugins/<plugin> --strict` and
   `claude plugin validate . --strict`.
4. Promotion (sandbox → official) is a deliberate move of the skill directory
   plus a `marketplace.json`/`plugin.json` update; the skill owner decides when
   traction is sufficient.

## Legacy: `skill-registry.json`

`skill-registry.json` is the Cursor-era own-skill registry (cursor/agents
targets). It is being retired as skills move into plugins; it now tracks only the
skills still living under `skills/`. Do not add new plugin skills to it — they
belong in `marketplace.json`. `validate-skill.sh` still checks version
consistency for any skill that remains listed there.

## Script Boundary

Add deterministic, repeated tooling only (version-sync checks, catalog
generation). Avoid scripting judgment-heavy work such as trigger design,
source-contract interpretation, or changelog wording.
