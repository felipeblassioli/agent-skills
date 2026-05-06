# ts-hermetic-testing

Hermetic TypeScript testing guidance for a four-layer strategy: colocated unit tests, contract/golden tests, in-process integration tests, and Playwright end-to-end flows.

## When To Use

Human prompt examples:

- "Should this behavior be a unit, contract, integration, or E2E test?"
- "Write a deterministic Vitest integration test for this route or repository."
- "Protect this scheduler output with a golden-file regression test."
- "Fix this flaky test suite that leaks state or hits the network."
- "Add a Playwright flow for this browser-visible user journey."

## What This Skill Maintains

- `SKILL.md` stays as the agent hot path: trigger surface, anti-triggers, tier-picking rules, and routing.
- `metadata.json` is the release authority for version, author, date, abstract, and reviewed source contracts.
- `references/` holds the detailed testing doctrine: layer placement, unit tests, contract/golden tests, integration harnesses, E2E flows, doubles taxonomy, MSW, and runner notes.
- `ts-prod-code` owns production design; this skill owns only the testing side of the boundary.

## Release And Validation

Review this skill against:

- `docs/ADR/ADR-0002-governed-skill-maintenance-model.md`
- `tmp/oncall-roster-ag/docs/adr/ADR-001-testing-strategy.md`

Useful checks:

- Confirm `SKILL.md` frontmatter stays limited to `name` and trigger-only `description`.
- Confirm the hot path and routing table reflect the accepted four-layer strategy: unit, contract, integration, E2E.
- Confirm integration guidance prefers real in-memory DB/app harnesses, not external services or containerized defaults.
- Confirm E2E guidance is browser-first (`Playwright`) and only fakes intentional external seams.
- Run `bash scripts/skill-sync.sh --skill=ts-hermetic-testing --dry-run` before release if packaging behavior changed.

## Source Contracts

Canonical review anchors for this refresh:

- `docs/ADR/ADR-0002-governed-skill-maintenance-model.md`
- `tmp/oncall-roster-ag/docs/adr/ADR-001-testing-strategy.md`

Background material retained as supporting input:

- `cursor/10_ts/rules/ts-test-v5.mdc`
- `cursor/10_ts/rules/ts-suffix-naming.mdc`
- `50_Work/Turbi/40_Guidelines/GUIDELINES - Testing with Jest unit integration e2e.md`
- `50_Work/Turbi/40_Guidelines/GUIDELINES - Mocks arent stubs.md`

## Related Skills Or Packs

- `ts-prod-code` for production-side architecture, domain modeling, and boundary ownership
- `tdd-classicist` for test-first methodology if the task is implementing behavior rather than just placing or refining tests
