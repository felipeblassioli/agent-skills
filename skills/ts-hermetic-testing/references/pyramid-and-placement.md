# Pyramid and placement

Four test layers, each with its own placement rule, isolation model, and confidence target. **One file = one layer**.

## Layer matrix

| Layer | Suffix | Location | Isolation model | Typical use |
|---|---|---|---|---|
| Unit | `*.test.ts` / `*.test.tsx` | Colocated next to the source file | No DB, no HTTP, no filesystem beyond fixtures, frozen time/UUID when needed | Pure functions, value objects, domain policies, isolated helpers |
| Contract / golden | `*.contract.test.ts` | `test/contract/<area>/` | Pure pipeline, committed golden artifacts, deterministic reruns | Observable pipeline output such as CSVs, plans, normalized payloads |
| Integration | `*.int.test.ts` | `packages/*/test/integration/` | Real in-memory DB/app wiring, migrations applied, fake external HTTP only | Repository and route correctness in-process |
| E2E | `*.spec.ts` | `e2e/` | Real browser + real running stack, test-only seed/reset hooks, fake only intentional external seams | User journeys across UI + API + DB |

## Suggested layout

```text
project-root/
├── packages/
│   ├── core/
│   │   └── src/
│   │       ├── schedule-engine.ts
│   │       └── schedule-engine.test.ts
│   ├── db/
│   │   ├── vitest.integration.config.ts
│   │   └── test/integration/
│   │       └── roster-repository.int.test.ts
│   └── api/
│       ├── vitest.integration.config.ts
│       └── test/integration/
│           └── schedules.routes.int.test.ts
├── test/
│   ├── __helpers__/
│   ├── __fixtures__/
│   └── contract/
│       └── core-engine/
│           ├── success.contract.test.ts
│           ├── infeasible.contract.test.ts
│           ├── determinism.contract.test.ts
│           └── golden/
├── e2e/
│   └── generate-schedule.spec.ts
└── playwright.config.ts
```

## Picking the layer

1. **Is the behavior pure and local to one module?** Use a colocated unit test.
2. **Is the behavior pure but only meaningful across a realistic multi-step pipeline?** Use a contract/golden test.
3. **Are you proving repository or route behavior with real wiring but without a browser?** Use an integration test.
4. **Are you proving a browser-visible journey across the assembled stack?** Use an E2E test.

If a unit test needs too many mocks, promote it. If an integration test is only protecting final deterministic artifacts, demote it to a contract/golden test.

## Hermeticity by layer

### Unit

- Use fake timers when time matters (`vi.useFakeTimers()`).
- Use deterministic IDs or seeded builders.
- No live network or database.
- Doubles only at ports and only when the behavior needs them.

### Contract / golden

- Keep the whole pipeline pure.
- Commit expected output artifacts under `golden/`.
- Re-run the same input multiple times when determinism matters.
- Review golden diffs explicitly when behavior changes.

### Integration

- Create a fresh in-memory database per file or per process.
- Apply real migrations before the suite runs.
- Use MSW for outbound HTTP if the SUT crosses an external boundary.
- Avoid shared state between files; prefer process isolation for suites that mutate globals.

### E2E

- Drive the app through the browser with Playwright.
- Boot the real app stack; fake only intentional external systems.
- Seed and reset deterministic fixtures through explicit test-only hooks.
- Run serially when shared database state would otherwise create coupling.

## Suffix mapping reminder

| Production suffix | Default layer |
|---|---|
| `*.entity.ts`, `*.vo.ts`, `*.policy.ts` | Unit |
| deterministic pure pipeline entrypoints | Contract / golden |
| `*.repository.<tech>.ts` | Integration |
| `*.gateway.ts` | Integration with MSW |
| `*.controller.ts` | Integration, or E2E when part of a browser-visible slice |

For production-side suffix decisions, see sibling skill **ts-prod-code**, `references/suffix-naming-production.md`.

## File names - examples

```text
packages/core/src/schedule-engine.test.ts
packages/db/test/integration/roster-repository.int.test.ts
packages/api/test/integration/schedules.routes.int.test.ts
test/contract/core-engine/success.contract.test.ts
e2e/generate-schedule.spec.ts
test/__helpers__/roster.fake.ts
test/__fixtures__/schedule.csv
```

## Anti-patterns

- Unit tests under `test/unit/`. Wrong: colocate next to the source.
- Contract tests that read the clock or random source. Wrong: keep them pure.
- Integration tests that call live third-party APIs. Wrong: fake externals with MSW.
- E2E tests that bypass the browser and call handlers directly. Wrong: drive the real UI.
- Mixing layers in one file. Wrong: split the checks by their confidence target.
