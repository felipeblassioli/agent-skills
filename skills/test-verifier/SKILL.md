---
name: test-verifier
description: >-
  Verify working-tree changes against turbi-guard's 8-tier test pyramid.
  Runs the right tests for changed files, collects coverage from instrumentable
  tiers, and returns a structured verification report. Use when the agent
  modifies production code, the user asks to run tests or check coverage, or
  the gh-pr-creator skill needs "Validação executada" data.
license: MIT
compatibility:
  - jq installed (used by helper scripts for JSON parsing)
  - Node.js and npm (functions/ project)
  - Docker (required only for integration tier — gracefully skipped if unavailable)
metadata:
  domain: testing
  framework: jest
  project: turbi-guard
---

# Test Verifier — Multi-Tier Test Runner

Reference: `docs/ADR/ADR-0002-multi-tier-testing-and-coverage-merging.md`

## When to use this skill

- After modifying production source files in `functions/`
- When the user asks to "run tests", "verify changes", "check coverage"
- When the `gh-pr-creator` skill needs "Validação executada" data
- Before creating a commit or PR, to confirm nothing is broken
- When explicitly invoked via `/test-verifier`

## Delegate to the `test-verifier` subagent when sensible

A companion subagent exists at `.cursor/agents/test-verifier.md`. It runs in an
isolated context and returns a structured verification report — keeping verbose
Jest output out of the main conversation.

**Delegate** (use the subagent) when:
- Running a full tier or multiple tiers (output exceeds ~50 lines)
- Running `coverage:all` (long-running: minutes, very verbose)
- The parent is mid-task and needs results without losing working context
- Running lint + typecheck + tests in parallel (launch multiple subagents)

**Use this skill directly** (no subagent) when:
- Running a single targeted test file (`jest -- rules.service.test`)
- Reading an existing `coverage-summary.json` (no test execution needed)
- The user explicitly asks to see raw output

### How to delegate

Pass the subagent enough context to work independently:

```
/test-verifier Verify changes to rules.service.js and alert.service.js.
Run unit and functional tiers with coverage on unit.
Working directory: functions/
```

The subagent will use the scripts from this skill and return a structured
verification report.

## Tier selection logic

Map changed file paths to the tiers that should run:

| Changed path pattern | Tiers to run |
|---|---|
| `domain/services/*.js` | unit |
| `domain/services/riskEngine/*.js` | unit + functional |
| `domain/repositories/*.js` | unit + integration (if Docker running) |
| `application/routes/*.js`, `application/config/*` | unit + functional-HTTP |
| `providers/*.js` | unit |
| `infra/*.js` | unit |
| `db/schema/*`, `db/seed/*` | integration (if Docker running) |
| Multiple layers touched | unit + functional (minimum); + integration if repos changed |

The `scripts/detect-tiers.sh` script automates this mapping. Run it with
changed file paths to get a JSON recommendation:

```bash
git diff --name-only HEAD | scripts/detect-tiers.sh
```

### The 8-tier pyramid

| Tier | Instrumentable | npm script | Prerequisites |
|------|:-:|---|---|
| Unit | Yes | `test:unit` | None |
| Structural | No | `test:structural` | None |
| Integration | Yes | `test:integration` | Docker (MySQL via Testcontainers) |
| Functional | Yes | `test:functional` | None |
| Functional-HTTP | Yes | `test:functional:http` | None |
| Emulator | No | `test:emulator` | Firebase emulator |
| System | No | `test:system` | Deployed GCP (turbi-dev) |
| Smoke | No | `smoke:test` | Live services |

Only 4 tiers produce coverage data: unit, integration, functional, functional-HTTP.
See [assets/tier-command-matrix.md](assets/tier-command-matrix.md) for the full reference.

## Coverage pipeline

Encoded from ADR-0002:

- Per-tier output: `functions/coverage/<tier>/` (unit, integration, functional, functional-http)
- Merged output: `functions/coverage/merged/`
- Merge uses Istanbul JSON (`coverage-final.json`) via `nyc report` — NOT LCOV
- Thresholds enforced only on unit tier: branches 20%, functions 25%, lines 30%, statements 30%
- Coverage commands use the `:cov` script variants (e.g. `test:unit:cov`, `test:integration:cov`)
- Full pipeline: `npm run coverage:all` (or `make coverage-all`) — sequential by design
- Merge only: `npm run coverage:merge` (or `make coverage-merge`)

### Reading coverage data

After a coverage run, read the compact summary:

```bash
scripts/coverage-summary.sh functions/coverage/unit/coverage-summary.json
```

For merged coverage across all instrumentable tiers:

```bash
scripts/coverage-summary.sh functions/coverage/merged/coverage-summary.json
```

## Output contract

When reporting verification results (whether inline or via the subagent),
use this structured format:

```markdown
## Verification Report

- **Changed files:** file1.js, file2.js
- **Tiers run:** unit, functional
- **Prerequisites:** Docker unavailable (integration skipped)

### Results
| Tier | Passed | Failed | Duration |
|------|--------|--------|----------|
| unit | 47 | 0 | 4.2s |
| functional | 12 | 1 | 8.1s |

### Failures (if any)
1. **functional** `analyser.service.functional.test.js`
   > "should alert when risk score exceeds threshold"
   > Expected: alertSent = true, Received: alertSent = false

### Coverage (if collected)
| Tier | Lines | Branches | Functions | Statements |
|------|-------|----------|-----------|------------|
| unit | 34.2% | 21.1% | 28.5% | 34.0% |

### Threshold check
- Unit: PASS (all above minimums: branches 20%, functions 25%, lines 30%, statements 30%)
```

## Composition with other skills

| Downstream skill | How to use together |
|---|---|
| `gh-pr-creator` | Paste the Results + Coverage tables into the "Validação executada" subsection of the "Como?" section |
| `commit-hygiene` | Use the verification report as a go/no-go signal before committing |
| `tdd-classicist` | Consult for tier placement decisions; this skill handles execution |

## Utility scripts

All scripts live in [scripts/](scripts/) and are self-contained (Bash + jq).

| Script | Purpose | Usage |
|--------|---------|-------|
| `detect-tiers.sh` | Map changed files to recommended tiers | `git diff --name-only HEAD \| scripts/detect-tiers.sh` |
| `run-tier.sh` | Run a single tier, emit Jest JSON to temp file | `scripts/run-tier.sh --tier unit --coverage --workdir functions` |
| `parse-jest-results.sh` | Extract pass/fail/failures from Jest JSON | `scripts/parse-jest-results.sh /tmp/jest-results.json` |
| `coverage-summary.sh` | Read coverage-summary.json, output compact metrics | `scripts/coverage-summary.sh functions/coverage/unit/coverage-summary.json` |

## Additional resources

- Tier command matrix: [assets/tier-command-matrix.md](assets/tier-command-matrix.md)
- Testing doctrine rule: `.cursor/rules/20-tests-doctrine.mdc`
- ADR-0002: `docs/ADR/ADR-0002-multi-tier-testing-and-coverage-merging.md`
