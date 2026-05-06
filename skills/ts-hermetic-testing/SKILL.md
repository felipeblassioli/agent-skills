---
name: ts-hermetic-testing
description: >-
  Use when writing or reviewing TypeScript tests, choosing between unit, contract,
  integration, and end-to-end layers, isolating database or HTTP seams, or fixing
  flaky, non-hermetic, or mis-layered test suites.
---

# TypeScript Hermetic Testing

Deterministic, hermetic test authoring across a four-layer strategy.

## Applicability gate

Apply this skill when ANY of the following is true:

- writing or reviewing a unit, contract/golden, integration, or E2E test in TypeScript
- deciding which test layer a behavior belongs to or where the file should live
- protecting deterministic pipeline output with golden files
- choosing a test double (stub, fake, spy, mock) or naming a `__helpers__/` file
- configuring MSW v2 (`onUnhandledRequest`, canonical handlers, per-test override, `reset()`)
- wiring or fixing a Vitest or Playwright test harness
- diagnosing flaky tests, open handles, shared state, or order-dependent failures

Do NOT apply this skill to:

| Situation | Route to |
|---|---|
| modeling entities, value objects, policies; designing the error model; structured logging | sibling skill `ts-prod-code` |
| visual-regression strategy or browser accessibility audits | out of scope |
| load / performance / chaos testing | out of scope |
| CI workflow YAML or pipeline orchestration | out of scope |
| frontend component testing (React Testing Library, RSC streaming tests) | not covered here |

## Routing table

| Need | Read |
|---|---|
| Where does this test go? Which suffix? Which tier? | [references/pyramid-and-placement.md](references/pyramid-and-placement.md) |
| Contract/golden tests for deterministic output | [references/contract-testing.md](references/contract-testing.md) |
| Stub vs fake vs spy vs mock; `__helpers__/` suffix discipline | [references/doubles-taxonomy.md](references/doubles-taxonomy.md) |
| Writing a unit test (AAA, builders, type-level, property-based) | [references/unit-testing.md](references/unit-testing.md) |
| Writing an integration test (real in-memory DB, in-process app wiring, route/repository coverage) | [references/integration-testing.md](references/integration-testing.md) |
| Writing an E2E (Playwright browser flow against the real stack) | [references/e2e-testing.md](references/e2e-testing.md) |
| MSW v2: `http.*` + `HttpResponse.*`, canonical handlers, override, stateful fakes | [references/msw-v2.md](references/msw-v2.md) |
| Vitest and Playwright runner notes | [references/vitest-equivalents.md](references/vitest-equivalents.md) |

## Hard rules (non-negotiable, applied without reading references)

1. **State-verification first.** Assert observable outcomes (rows, HTTP responses, published events) — not "method X was called".
2. **Hermetic.** No live network, no real cloud, no shared mutable global state. Frozen time and UUIDs in unit tests.
3. **No open handles.** Run with `--detectOpenHandles` locally; fix the cause (don't ignore the warning).
4. **Choose the smallest proving layer.** Pure logic stays unit; deterministic full-pipeline output uses contract/golden tests; repository/route behavior uses integration; browser journeys use E2E.
5. **Unit tests are colocated.** Keep pure, no DB/HTTP/I/O. If you need more infrastructure, promote the test.
6. **Contract tests protect observable artifacts.** Store committed golden files for deterministic pipelines and make intentional output changes explicit in diff review.
7. **Integration tests run in-process.** Use a real in-memory database with migrations or equivalent app harness; isolate per file; suffix them `*.int.test.ts`.
8. **E2E tests use Playwright against the real stack.** Fake only intentional external boundaries, and prefer serial execution when stateful fixtures would otherwise collide.
9. **Doubles at edges only.** Prefer DI, fakes, and stubs; mock before import only when module mocking is unavoidable.
10. **One responsibility per test.** AAA layout. Failure messages must read like a sentence.

## Procedure

When the user asks to write or fix a test:

1. **Identify the layer**: unit / contract / integration / E2E. Pick based on the smallest layer that can prove the behavior.
2. **Place the file**: unit colocated with the source, contract under `test/contract/`, integration under `packages/*/test/integration/`, E2E under `e2e/`.
3. **Pick the doubles**: prefer **fakes** for collaborators with logic, **stubs** for canned responses, **spies** only at real outbound boundaries, **mocks** rarely.
4. **Configure isolation**: deterministic time, unique IDs, MSW reset in `afterEach`, fresh in-memory DB/app wiring per file, explicit seed/reset for E2E fixtures.
5. **Arrange / Act / Assert** with the smallest data that proves the case. Use builders/fixtures from `test/__helpers__/` and `test/__fixtures__/`.
6. **Assert state, not interactions** — rows, responses, visible UI, emitted events, or byte-identical golden output.
7. **Verify hermeticity** before finishing: no live network, no open handles, stable results in focused and broader runs, and no reliance on cross-test order.

## Confirmation policy

- If the user asks to mock something **inside** the bounded context, push back: prefer a fake at the port boundary.
- If the user asks to skip a test, ask why; fix the underlying determinism problem.
- If a test relies on cross-test order, refuse: test order is not contractual.
- If the user asks to put unit tests under `test/unit/` (away from sources), enforce **colocation** instead.
- If the user wants a repository or route test to use a live external service, refuse and route the seam through MSW or a local test harness.

## Sibling skill

For production code (entities, value objects, error model, observability, suffixes for non-test files): **ts-prod-code**.
