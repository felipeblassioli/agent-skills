# Workflow

Use this workflow for plugin/skill changes in this marketplace.

## 1. Classify The Change

- Create: new skill in a plugin (`plugins/<plugin>/skills/<name>/`), or a new plugin.
- Update: existing skill behavior, references, examples, or source contracts.
- Version-only: metadata/changelog/plugin.json alignment without guidance changes.
- Marketplace: `marketplace.json` / `plugin.json` maintenance.
- Tooling: validator or release scripts.

## 2. Pick The Tier And Home

Decide official plugin vs sandbox plugin (see
[marketplace-maintenance.md](marketplace-maintenance.md) and
`docs/marketplace-governance.md`). New/experimental skills start in a sandbox
plugin and are promoted once they earn traction.

## 3. Define The Contract

Write a one-sentence boundary, realistic trigger phrases, anti-triggers and
by-name sibling handoffs, in/out-of-scope, and the source contracts to inspect.
Split the request if two distinct jobs appear.

## 4. Read Source Contracts

Read the files that define current behavior before editing guidance; check git
history when the source is a nested repo and current behavior matters. Record
reviewed sources in `metadata.json` `source_contracts` and the `CHANGELOG.md`
Source Contracts section.

## 5. Update The Package

Keep `SKILL.md` lean (frontmatter = `name` + `description`; applicability gate,
anti-triggers, routing table, short procedure, confirmation policy, validation).
Move detail to `references/`, human prompts to `README.md`. Keep bundled scripts
inside the skill and reference them via `${CLAUDE_SKILL_DIR}`.

## 6. Version

Bump `metadata.json` `version` (per `docs/versioning.md`) and add the matching
`CHANGELOG.md` entry. For releasable plugin changes, bump the `plugin.json`
`version` too.

## 7. Validate

```bash
claude plugin validate ./plugins/<plugin> --strict
claude plugin validate . --strict
bash scripts/validate-skill.sh plugins/<plugin>/skills/<name>
bash scripts/test-validate-skill.sh
```

## 8. Release

Plugin releases are advertised through `marketplace.json` + `plugin.json`
versions; users pick them up with `/plugin marketplace update`. (Per-skill
GitHub Release tags via `release-skill.yaml` remain for the skills still under
`skills/`; plugin-level release automation is a separate follow-up — see
`docs/releasing.md`.)
