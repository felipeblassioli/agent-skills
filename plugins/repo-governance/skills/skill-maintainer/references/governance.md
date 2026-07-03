# Governance Requirements

Ported from the legacy `.cursor/rules/skill-governance.mdc`. The agent-skills
marketplace is the source of truth for these agent skills, distributed as Claude
Code plugins. Treat each skill as a versioned contract, not loose documentation.

## Plugin & Skill Package Shape

A skill lives at `plugins/<plugin>/skills/<skill>/` and keeps these files
consistent:

- `SKILL.md` — agent hot path. Frontmatter is **`name` + `description` only**
  (the Agent Skills standard Claude reads); `allowed-tools` is also permitted.
  No `version`/`last_reviewed`/`source_contracts` in the frontmatter.
- `metadata.json` — governance/freshness: `version`, `author`, `date`,
  `abstract`, and, when applicable, `source_contracts` (`path` + `reviewed_at`).
  This is where versioning and source-contract review live.
- `CHANGELOG.md` — current-version entry with reviewed source contracts; kept as
  history (not rewritten on rename).
- `references/` — longer guidance kept out of the hot path.
- `assets/` — copyable templates/examples only.
- `scripts/` — bundled executables, invoked via `${CLAUDE_SKILL_DIR}/...`.

The plugin root carries `.claude-plugin/plugin.json` (`name`, `version`,
`author`); the marketplace root carries `.claude-plugin/marketplace.json`.

## Source Contracts

If a skill teaches an external tool, library, CI/CD workflow, or runtime
behavior it does not own, record `source_contracts` in `metadata.json`. Use
canonical GitHub URLs (or documentation URLs) for external repos:

- `https://github.com/your-org/some-repo/blob/main/...`
- `https://github.com/your-org/some-repo/tree/main/docs/...`
- `https://github.com/your-org/some-repo/tree/<commit>/...`

Use repo-local paths (`docs/...`, `scripts/...`) for contracts that live in this
repository. A missing local path is a validator warning, not a failure
(provenance moves).

## Composing Skills Across Plugins

Reference other skills **by name** — the model invokes them if installed, even
across plugins (e.g. a `blassioli` sandbox skill handing off to a
`repo-governance` skill). Do not use relative filesystem links across skills or
plugins: installed plugins are copied to a cache, so cross-package paths break.

## Authoring Rules

- Keep `SKILL.md` concise and dispatcher-style; move detail to `references/`.
- Use ISO dates (`YYYY-MM-DD`) for metadata `date`, changelog entries, and
  `source_contracts[].reviewed_at`.
- Do not publish private or credentialed details in a public marketplace skill.

## Validation

```bash
claude plugin validate ./plugins/<plugin> --strict
bash scripts/validate-skill.sh plugins/<plugin>/skills/<skill>
```
