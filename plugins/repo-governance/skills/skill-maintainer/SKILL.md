---
name: skill-maintainer
description: >-
  Guides versioning, validating, releasing, and promoting plugins and skills
  under the agent-skills Claude-first marketplace model — plus marketplace.json /
  plugin.json manifest and registry alignment. Use when cutting a release, bumping
  a version, editing the .claude-plugin/marketplace.json catalog or a plugin.json
  manifest, aligning the registry, or updating the governance/validation/release
  tooling. For writing or scaffolding a skill use skill-studio:skill-create; for
  auditing skill quality use skill-studio:skill-audit.
---

# Skill & Plugin Maintainer

Meta-tooling for maintaining **the agent-skills marketplace itself** — the
Claude Code plugin marketplace. Use it when changing how the marketplace
packages, validates, versions, or promotes its own plugins and skills. For the
governance model it enforces, see `docs/marketplace-governance.md`.

## Apply When

- creating or changing a skill inside a plugin (`plugins/<plugin>/skills/<skill>/`)
- adding or promoting a plugin, or editing `.claude-plugin/marketplace.json`
- editing a `plugin.json` manifest (name, version, author, description)
- reconciling a skill package: `SKILL.md` frontmatter, `metadata.json`, `CHANGELOG.md`
- updating the governance docs, `scripts/validate-skill.sh`, or release tooling
- deciding whether an experimental skill is ready to graduate from a sandbox
  plugin to an official one

## Do Not Apply When

- the task is to USE an existing skill to solve an app or platform problem
  (use that skill directly)
- the work is authoring a plugin/skill outside the agent-skills repo
- the task is only committing already-complete changes
- the change edits source contracts without changing marketplace guidance

## Routing Table

| Need | Read |
|---|---|
| create / update / version / promote workflow | [references/workflow.md](references/workflow.md) |
| marketplace.json + plugin.json manifests, tiers, legacy registry | [references/marketplace-maintenance.md](references/marketplace-maintenance.md) |
| package-shape & source-contract governance requirements | [references/governance.md](references/governance.md) |
| final review and validation checklist | [references/quality-gate.md](references/quality-gate.md) |
| tiers, ownership, sandbox→promote model | `docs/marketplace-governance.md` |
| versioning & release procedure | `docs/versioning.md` and `docs/releasing.md` |
| human prompt and usage examples | [README.md](README.md) |

## Procedure

1. Classify the request: new skill, skill update, version-only, plugin/manifest,
   marketplace, governance-doc, or tooling work.
2. Decide the right tier and home: an **official plugin** (e.g. `repo-governance`)
   vs a personal **sandbox plugin** (e.g. `blassioli`). See
   [references/marketplace-maintenance.md](references/marketplace-maintenance.md).
3. Define the skill boundary in one sentence (triggers + anti-triggers).
4. Read the relevant source contracts before editing guidance.
5. Update the skill package together: `SKILL.md` (frontmatter = `name` +
   `description` only), `metadata.json` (version/date/source_contracts),
   `CHANGELOG.md`, optional `README.md`, references, assets.
6. Update `.claude-plugin/marketplace.json` and the `plugin.json` version for new
   plugins or releasable changes.
7. Keep cross-skill references **by name** (not relative filesystem links); keep
   bundled files inside the skill and reference them via `${CLAUDE_SKILL_DIR}` /
   `${CLAUDE_PLUGIN_ROOT}`.
8. Validate before sign-off (see below).

## Confirmation Policy

- Confirm before promoting a skill from a sandbox plugin to an official one.
- Confirm before changing the marketplace schema, a plugin name (= namespace), or
  install semantics.
- Confirm before splitting one requested skill into multiple siblings.
- Confirm before removing source contracts or narrowing activation triggers.
- Confirm before changing validator behavior or the release workflow.

## Validation

```bash
claude plugin validate ./plugins/<plugin> --strict
claude plugin validate . --strict            # marketplace
bash scripts/validate-skill.sh plugins/<plugin>/skills/<skill>
bash scripts/test-validate-skill.sh
```
