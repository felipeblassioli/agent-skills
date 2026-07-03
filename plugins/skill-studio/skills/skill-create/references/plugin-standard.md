# Claude Skill & Plugin Standard

The authoring contract for Claude skills and the plugins that carry them. This
is the doctrine to normalize every new or imported skill toward.

## Skill package shape

A skill lives at `plugins/<plugin>/skills/<name>/` and keeps these files
consistent:

```text
skills/<name>/
├── SKILL.md          # Required — agent hot path
├── metadata.json     # Required — version/author/date/abstract/source_contracts
├── CHANGELOG.md      # Required — release history, matching-version entry
├── references/       # On-demand docs the agent reads when needed
├── assets/           # Static resources: templates, checklists, quick refs
└── scripts/          # Executable helpers, invoked via ${CLAUDE_SKILL_DIR}/...
```

Only create directories that will contain files.

## SKILL.md frontmatter — the Agent Skills contract

```yaml
---
name: my-skill          # lowercase, hyphens, max 64 chars, MUST match folder name
description: >-          # max 1024 chars, non-empty, third-person, WHAT + WHEN
  What the skill does. Use when <trigger 1>, <trigger 2>. Do not use when
  <anti-trigger> (route to <other-skill>).
---
```

- Frontmatter carries **`name` + `description` only** (plus optional
  `allowed-tools`). This is the only text Claude reads before deciding whether to
  load the body.
- **Do NOT** put `version`, `date`, `last_reviewed`, `source_contracts`, or
  `compatibility` in the frontmatter — they belong in `metadata.json`. Claude
  ignores extra keys, but the validator flags them.
- **Do NOT** use `disable-model-invocation` — it is not part of the Claude
  contract. Skills are invoked by description match or explicitly as
  `/<plugin>:<skill>`. Keep the description tight so routing stays accurate.

## Description rules

1. **Third person** — the description is injected into the system prompt.
   - Yes: "Deploys the application to staging environments."
   - No: "I can deploy ..." or "You can use this to deploy ..."
2. **WHAT + WHEN** — state capabilities AND trigger scenarios.
3. **Specific trigger terms** — include keywords the user would say.
4. **Anti-triggers** — when a sibling skill shares vocabulary, add
   "Do not use when ..." and route by name to keep the router on track.

Formula: `<verb-phrase of capabilities>. Use when <trigger 1>, <trigger 2>. Do not use when <anti-trigger> (route to <other-skill>).`

## metadata.json — governance and freshness

```json
{
  "version": "0.1.0",
  "author": "felipeblassioli@gmail.com",
  "date": "2026-07-02",
  "abstract": "Short summary of what the skill does and when to use it.",
  "source_contracts": [
    { "path": "https://github.com/org/repo/blob/main/docs/x.md", "reviewed_at": "2026-07-02" }
  ]
}
```

- Use semantic versioning; keep the version identical across `SKILL.md`'s
  package (via `metadata.json`), `metadata.json`, and the top `CHANGELOG.md` entry.
- Use ISO dates (`YYYY-MM-DD`).
- Record `source_contracts` only when the skill teaches an external tool,
  library, or runtime it does not own. Use canonical GitHub / docs URLs for
  external repos; repo-local paths for contracts in this repository. A missing
  local path is a validator warning, not a failure.

## Progressive disclosure

- `SKILL.md` is loaded when the skill is invoked. Keep it under **500 lines**;
  aim much smaller (under ~200) when it is a router for many references.
- Files in `references/` and `assets/` load on demand only when the agent
  follows a link from `SKILL.md`.
- **One-Hop Rule**: keep references one link deep from `SKILL.md`. The routing
  table should give a direct path to every reference. Deeply nested chains risk
  partial reads.

## Composing across skills and plugins

- Reference another skill **by name** — the model invokes it if installed, even
  across plugins. Do **not** use relative filesystem links across skills or
  plugins: installed plugins are copied to a cache, so cross-package paths break.
- Reference bundled files **inside the same skill** via `${CLAUDE_SKILL_DIR}`
  (or `${CLAUDE_PLUGIN_ROOT}` for plugin-level assets), e.g.
  `${CLAUDE_SKILL_DIR}/scripts/validate.sh`.

## Scripts

- Any language the runtime supports (bash, python, JS).
- Give each a usage comment block; handle errors (`set -euo pipefail`); prefer
  structured (JSON) output; mark executable.
- Make it explicit in `SKILL.md` whether to **execute** or only **read** a script.

## Plugin layout (when several surfaces ship together)

Reach for a plugin only when a skill must travel with sibling surfaces.

```text
plugins/<plugin>/
├── .claude-plugin/plugin.json    # Required — name, version, author
├── skills/<name>/                # One or more skills
├── agents/<name>.md              # Optional — subagents
├── commands/<name>.md            # Optional — slash commands
├── hooks/                        # Optional — hooks + hooks.json
└── README.md                     # Human docs
```

### plugin.json

```json
{
  "name": "my-plugin",
  "description": "...",
  "version": "0.1.0",
  "author": { "name": "Name", "email": "you@example.com" }
}
```

- `name` is the invocation namespace: skills become `/<plugin>:<skill>`.
- Set an explicit `version` and bump it per release — on a git-hosted
  marketplace, an omitted version makes every commit a new version.

### marketplace.json (repo root, `.claude-plugin/marketplace.json`)

The catalog. Required: `name` (the install suffix, `plugin@<name>`), `owner`
(name + email), and `plugins[]` — each entry needs `name` + `source` (e.g.
`./plugins/my-plugin`); `description` and `author` are recommended.

## Tiers

- **Sandbox plugin** (e.g. `blassioli`) — personal, experimental, "use at your
  own risk". New/unproven skills start here. Carries that note in the plugin
  description.
- **Official plugin** — reviewed, supported, defined audience. A sandbox skill
  is **promoted** here by the owner once it earns traction (that promotion is
  governance work — hand it to `repo-governance:skill-maintainer`).

## Validation

```bash
claude plugin validate ./plugins/<plugin> --strict
claude plugin validate . --strict            # marketplace
bash ${CLAUDE_SKILL_DIR}/scripts/validate-skill.sh <skill-dir>
```

## See Also

- `references/skill-archetypes.md` — pick the skill's shape.
- `references/skill-quality-checklist.md` — the final review gate.
