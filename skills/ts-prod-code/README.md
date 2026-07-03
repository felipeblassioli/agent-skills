# ts-prod-code

Production TypeScript guidance for layered module boundaries, strict typing, domain modeling, boundary validation, error ownership, and observability.

## When To Use

Human prompt examples:

- "Model this entity/value object/use case in TypeScript."
- "Where should this file live, and what suffix should it use?"
- "Should this failure return a Result or throw?"
- "Add validation and structured logging at the HTTP or queue boundary."

## What This Skill Maintains

- `SKILL.md` stays as the agent hot path: trigger surface, anti-triggers, hard rules, and routing.
- `metadata.json` is the release authority for version, author, date, abstract, and reviewed source contracts.
- `references/` holds detailed guidance for layering, suffixes, domain modeling, repositories, error handling, and observability.
- `ts-hermetic-testing` owns test authoring; this skill only maintains production-side cross-references to test tiers.

## Release And Validation

Review this skill against:

- `docs/ADR/ADR-0002-governed-skill-maintenance-model.md`
- `tmp/oncall-roster-ag/docs/adr/ADR-001-testing-strategy.md` for layer-to-tier cross-references

Useful checks:

- Confirm `SKILL.md` frontmatter stays limited to `name` and trigger-only `description`.
- Confirm `metadata.json` keeps `version`, `author`, `date`, and `abstract` in sync with the current release.
- Re-read any changed reference file to make sure production-layer guidance still routes testing concerns to `ts-hermetic-testing`.
- Run `bash scripts/skill-sync.sh --skill=ts-prod-code --dry-run` before release if packaging behavior changed.

## Source Contracts

Primary review anchors for this refresh:

- `docs/ADR/ADR-0002-governed-skill-maintenance-model.md`
- `tmp/oncall-roster-ag/docs/adr/ADR-001-testing-strategy.md`

Foundational source material retained in the references:

- `cursor/10_ts/rules/ts-core-v5.mdc`
- `cursor/10_ts/rules/ts-suffix-naming.mdc`
- Private engineering guidelines — "TypeScript modules organization"
- Private engineering guidelines — "Error handling in TypeScript"
- Private engineering guidelines — "Structured logging"

## Related Skills Or Packs

- `ts-hermetic-testing` for unit, contract, integration, and E2E test authoring
- `typescript-quality` for adjacent TypeScript quality patterns outside this DDD-focused skill
