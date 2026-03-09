# Configuration Guide

`node-test-verifier` stays reusable by consuming a project-local verification
contract instead of hardcoding one repository's commands.

## How to create the project-local contract

The preferred path is:

1. install the pack
2. run the `test-verifier-bootstrapper` agent
3. let it draft or update repo-local overlay files
4. refine unresolved items manually when the repository's scripts are ambiguous

That overlay is the source of truth for the repository. The pack remains generic.

## Required project inputs

Document these inputs somewhere the parent agent can read before delegating:

- test working directory
- package manager and preferred quiet invocation style
- changed-file to tier mapping rules
- per-tier commands
- per-tier coverage commands for instrumentable tiers
- per-tier prerequisite commands or checks
- coverage summary file locations
- optional merged coverage command and merged summary location
- threshold rules, if any

## Recommended tier matrix

A simple matrix works well:

| Tier | Command | Coverage command | Coverage summary | Prerequisites | Structured output |
|------|---------|------------------|------------------|---------------|-------------------|
| `unit` | `npm --silent run test:unit` | `npm --silent run test:unit:cov` | `coverage/unit/coverage-summary.json` | none | yes |
| `integration` | `npm --silent run test:integration` | `npm --silent run test:integration:cov` | `coverage/integration/coverage-summary.json` | `npm run build:modules`, Docker | yes |
| `functional` | `npm --silent run test:functional` | `npm --silent run test:functional:cov` | `coverage/functional/coverage-summary.json` | `npm run build:modules` if needed | yes |
| `functional-http` | `npm --silent run test:functional:http` | `npm --silent run test:functional:http:cov` | `coverage/functional-http/coverage-summary.json` | `npm run build:modules` if needed | yes |
| `emulator` | `npm --silent run test:emulator` | none | none | emulator availability, env vars | maybe |

If a tier command cannot accept appended Jest flags, document that clearly so the
verifier falls back to compact log summarization instead of expecting JSON.

## Changed-file routing

A useful routing map usually answers:

- which paths are pure unit territory
- which paths require integration because they touch SQL, repositories, or real I/O
- which paths require functional or functional-http because they touch orchestration or routes
- which changes trigger emulator, system, or smoke checks

Keep this map in project-local docs, rules, or `AGENTS.md`, not in the pack.

A bootstrapper-generated overlay is a good place to store this map when the repo
does not already have a strong testing section.

## Example based on a multi-config Jest package

For a repository with scripts like:

- `test:unit`
- `test:unit:cov`
- `test:integration`
- `test:integration:cov`
- `test:functional`
- `test:functional:cov`
- `test:functional:http`
- `test:functional:http:cov`
- `test:emulator`
- `coverage:all`
- `coverage:merge`
- `build:modules`

the project contract can describe:

| Tier | Command | Coverage | Notes |
|------|---------|----------|-------|
| `unit` | `npm --silent run test:unit` | `npm --silent run test:unit:cov` | baseline tier |
| `integration` | `npm --silent run test:integration` | `npm --silent run test:integration:cov` | requires `npm run build:modules` and Docker |
| `functional` | `npm --silent run test:functional` | `npm --silent run test:functional:cov` | in-process orchestration |
| `functional-http` | `npm --silent run test:functional:http` | `npm --silent run test:functional:http:cov` | Express or HTTP pipeline |
| `structural` | `npm --silent run test:structural` | none | no coverage |
| `emulator` | `npm --silent run test:emulator` | none | often cannot emit structured JSON cleanly |
| `system` | `npm --silent run test:system` | none | deployed environment |
| `smoke` | `npm --silent run smoke:test` | none | live sanity check |

## Prerequisite handling

Make prerequisites explicit per tier.

Good examples:

- `npm run build:modules`
- `docker info >/dev/null 2>&1`
- `test -n \"$FIREBASE_AUTH_PROJECT_ID\"`
- `test -f .runtimeconfig.dev.json`

The verifier should run those checks before the tier and report skips cleanly.

## Coverage strategy

Document which tiers are instrumentable. A common setup is:

- `unit`
- `integration`
- `functional`
- `functional-http`

Also document:

- per-tier coverage summary paths
- whether thresholds apply only to one tier or multiple tiers
- whether merged coverage exists and which command produces it

## Suggested parent prompt

Use a prompt shaped like this when delegating:

```text
Verify changes to the following files: src/routes/risk.ts, src/usecases/enqueue.ts
Working directory: functions
Package manager: npm
Prefer quiet execution: npm --silent run
Detect tiers using the repository's documented routing rules.
Tier matrix:
- unit: command `npm --silent run test:unit`, coverage `npm --silent run test:unit:cov`, summary `coverage/unit/coverage-summary.json`
- integration: command `npm --silent run test:integration`, coverage `npm --silent run test:integration:cov`, summary `coverage/integration/coverage-summary.json`, prerequisites `npm run build:modules`, `docker info >/dev/null 2>&1`
- functional-http: command `npm --silent run test:functional:http`, coverage `npm --silent run test:functional:http:cov`, summary `coverage/functional-http/coverage-summary.json`
Collect coverage for instrumentable tiers you run.
Return a compact verification report.
```

## Suggested bootstrap output

For many repos, the best long-lived result is a small combination of:

- `.cursor/rules/test-verifier-project.mdc` for persistent verification policy
- a short `AGENTS.md` note pointing to the repo-local verifier contract
- an optional `.cursor/test-verifier-config.md` when the tier matrix is too large
  for a short rule
