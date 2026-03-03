# Tier Command Matrix

Quick reference for all 8 test tiers in turbi-guard. Derived from
`docs/ADR/ADR-0002-multi-tier-testing-and-coverage-merging.md` and
`functions/package.json`.

All npm scripts run from the `functions/` directory.

## Instrumentable tiers (produce coverage)

| Tier | npm script | npm script (coverage) | Jest config | Coverage dir | Prerequisites | Test pattern |
|------|-----------|----------------------|-------------|-------------|---------------|-------------|
| Unit | `test:unit` | `test:unit:cov` | `jest.config.js` | `coverage/unit/` | None | `*.test.js/ts`, `*.spec.js/ts` (colocated) |
| Integration | `test:integration` | `test:integration:cov` | `jest.integration.config.js` | `coverage/integration/` | Docker (MySQL via Testcontainers) | `test/integration/**/*.test.ts` |
| Functional | `test:functional` | `test:functional:cov` | `jest.functional.config.js` | `coverage/functional/` | None (in-process + MSW) | `test/functional/**/*.functional.test.ts/js` |
| Functional-HTTP | `test:functional:http` | `test:functional:http:cov` | `jest.functional-http.config.js` | `coverage/functional-http/` | None (supertest + MSW) | `test/functional-http/**/*.functional.test.ts/js` |

## Non-instrumentable tiers (no coverage)

| Tier | npm script | Jest config | Prerequisites | Test pattern |
|------|-----------|-------------|---------------|-------------|
| Structural | `test:structural` | `jest.structural.config.js` | None (reads source as text) | `test/structural/**/*.test.ts/js` |
| Emulator | `test:emulator` | `jest.emulator.config.js` | Firebase emulator running | `test/emulator/**/*.emulator.test.ts/js` |
| System | `test:system` | `jest.system.config.js` | Deployed GCP (turbi-dev) | `test/system/**/*.system.test.ts/js` |
| Smoke | `smoke:test` | `jest.smoke.config.js` | Live services | `**/*.smoke.test.js/ts` |

## Coverage pipeline commands

| Command | Scope | From |
|---------|-------|------|
| `npm run coverage:clean` | Remove `coverage/` directory | `functions/` |
| `npm run coverage:merge` | Merge per-tier Istanbul JSON → `coverage/merged/` | `functions/` |
| `npm run coverage:all` | Clean + run all 4 tiers with coverage + merge | `functions/` |
| `make coverage-all` | Same as `npm run coverage:all` | repo root |
| `make coverage-merge` | Same as `npm run coverage:merge` | repo root |

## Coverage thresholds

Thresholds are enforced **only on the unit tier** (in `jest.config.js`).
Integration, functional, and functional-HTTP configs set `coverageThreshold: {}`
(no thresholds) because each tier alone covers only a subset of production code.

| Metric | Minimum |
|--------|---------|
| Branches | 20% |
| Functions | 25% |
| Lines | 30% |
| Statements | 30% |

## Coverage output files

Each tier (when run with `:cov`) produces these files in `coverage/<tier>/`:

| File | Format | Purpose |
|------|--------|---------|
| `coverage-final.json` | Istanbul JSON | Lossless coverage data; used by merge |
| `coverage-summary.json` | JSON | Machine-readable totals (used by scripts) |
| `lcov.info` | LCOV | Per-tier CI upload / tooling |
| `lcov-report/index.html` | HTML | Per-tier browsable report |

Merged output lives in `coverage/merged/` with the same file set.
