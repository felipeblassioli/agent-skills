# Test Tiers — Quick Reference

Extracted from [ADR-0002](../../../../docs/ADR/ADR-0002-multi-tier-testing-and-coverage-merging.md).

## 8-Tier Pyramid

```
                    ┌──────────────┐
                    │   System     │  real GCP deployment (turbi-dev)
                    │  (turbi-dev) │  Proves: Cloud Tasks e2e, real Pub/Sub, cold start
                    ├──────────────┤
                    │  Emulator    │  Firebase emulator
                    │  (local)     │  Proves: onRequest lifecycle, Auth, Pub/Sub triggers
                 ┌──┴──────────────┴──┐
                 │   Functional-HTTP   │  supertest + MSW
                 │                     │  Proves: pipeline over HTTP, upstream failures
                 ├─────────────────────┤
                 │    Functional       │  in-process + MSW
                 │                     │  Proves: plate → score → alert orchestration
                 ├─────────────────────┤
                 │   Integration       │  Testcontainers MySQL + supertest
                 │                     │  Proves: SQL correctness, repository contracts
                 ├─────────────────────┤
                 │   Structural        │  AST/source guardrails (read-only)
                 │                     │  Proves: safety patterns not reverted
              ┌──┴─────────────────────┴──┐
              │          Unit              │  Jest mocks
              │                           │  Proves: domain logic, rules, scoring
              └───────────────────────────┘
```

## Tier Reference Table

| Tier | Jest Config | npm Script | Real Boundaries | Coverage? |
|------|-------------|------------|-----------------|-----------|
| Unit | `jest.config.js` | `test:unit` | None | Yes |
| Structural | `jest.structural.config.js` | `test:structural` | Source files (read-only) | No |
| Integration | `jest.integration.config.js` | `test:integration` | MySQL (Testcontainers) | Yes |
| Functional | `jest.functional.config.js` | `test:functional` | None (in-process) | Yes |
| Functional-HTTP | `jest.functional-http.config.js` | `test:functional:http` | Express (supertest) | Yes |
| Emulator | `jest.emulator.config.js` | `test:emulator` | Firebase runtime | No |
| System | `jest.system.config.js` | `test:system` | All (deployed GCP) | No |
| Smoke | `jest.smoke.config.js` | `smoke:test` | Live services | No |

## Key Design Principles

1. **Each tier owns exactly the boundaries it tests.** Lower tiers mock
   boundaries above; higher tiers exercise real boundaries but do not
   re-verify claims proven below.
2. **No claim duplication.** Emulator tests don't re-test Express routing
   (proven by supertest). System tests don't re-test error shapes (proven
   by emulator).
3. **Tier independence.** Every tier can be run in isolation. The base
   `jest.config.js` actively excludes all higher-tier test directories.

## Coverage Commands

| Command | Scope |
|---------|-------|
| `npm run test:unit:cov` | Unit → `coverage/unit/` |
| `npm run test:integration:cov` | Integration → `coverage/integration/` |
| `npm run test:functional:cov` | Functional → `coverage/functional/` |
| `npm run test:functional:http:cov` | Functional-HTTP → `coverage/functional-http/` |
| `npm run coverage:merge` | Merge all per-tier Istanbul JSON → `coverage/merged/` |
| `npm run coverage:all` | Clean → run all 4 instrumentable tiers → merge |

## Mapping Firebase Function Tests to Tiers

| What you're testing | Recommended tier |
|---------------------|-----------------|
| Domain logic, rules, scoring (no I/O) | **Unit** |
| Repository SQL queries | **Integration** |
| Service orchestration (plate → score → alert) | **Functional** |
| Express route handling, middleware, HTTP pipeline | **Functional-HTTP** |
| Firebase `onRequest` / `onMessagePublished` lifecycle | **Emulator** |
| Full deployment behavior (cold start, Cloud Tasks) | **System** |

## See Also

- [references/unit-testing.md](../references/unit-testing.md) — `firebase-functions-test` SDK patterns
- [references/local-development.md](../references/local-development.md) — Emulator and shell testing
- Canonical source: `docs/ADR/ADR-0002-multi-tier-testing-and-coverage-merging.md`
