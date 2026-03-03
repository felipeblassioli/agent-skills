# Test Support Code — Naming and Placement

This reference defines conventions for test helpers, builders, fixtures, and
doubles that live alongside tests. The goal: avoid "fixtures sprawl" and keep
data setup composable.

---

## Placement

All support code lives under `test/_support/` (never under `src/` unless it
is production code).

```
test/
  _support/
    builders/              # Data construction helpers
    seeds/                 # DB seed files (deterministic, minimal)
    fixtures/              # Static files only (JSON, CSV, etc.)
    fakes/                 # Stateful but deterministic implementations
    stubs/                 # Fixed-response behavioral replacements
    spies/                 # Recording wrappers
    msw/                   # MSW HTTP handlers (explicitly stubs/fakes)
    harness/               # Infrastructure helpers (containers, servers)
```

The `_support/` prefix (with underscore) sorts it first in directory listings
and signals "not a test tier."

---

## Naming Conventions

| Category | Suffix | Example | Purpose |
|----------|--------|---------|---------|
| Builder | `*.builder.ts` | `order.builder.ts` | Construct domain objects with sensible defaults and composable overrides |
| Seed | `*.seed.ts` | `products.seed.ts` | Deterministic, minimal DB seed data |
| Fixture (static) | `*.json`, `*.csv`, etc. | `webhook-payload.json` | Static files for test input |
| Fake | `*.fake.ts` | `email-service.fake.ts` | Stateful but deterministic test implementation |
| Stub | `*.stub.ts` | `payment-gateway.stub.ts` | Fixed-response behavioral replacement |
| Spy | `*.spy.ts` | `audit-logger.spy.ts` | Records interactions for assertion |
| MSW handler | `*.msw.ts` | `stripe-api.msw.ts` | HTTP interceptor handlers (stubs/fakes, not mocks) |

---

## Rules

### Builders (preferred for domain objects)

- MUST provide sensible defaults for all required fields.
- MUST support composable overrides (e.g., `buildOrder({ status: 'shipped' })`).
- SHOULD be the default way to create test data for domain objects.
- MUST NOT call external services or infrastructure.

### Seeds (for DB state)

- MUST be deterministic and minimal.
- SHOULD be composable (small seeds that can be combined).
- MUST NOT depend on execution order.

### Fixtures (static files only)

- MUST be read-only.
- SHOULD be small and focused.
- MUST NOT be used as a substitute for builders when constructing domain objects.
- Use `test/_support/fixtures/` for JSON, CSV, and other static test data.

### Fakes

- MUST implement the same interface as the production dependency.
- MUST be deterministic (no randomness, no live network).
- MAY maintain internal state (e.g., in-memory repository with a Map).
- SHOULD be shared across tests that need the same fake.

### MSW handlers

- Are stubs/fakes (see `tdd-classicist/references/taxonomy-test-doubles.md`).
- MUST NOT be treated as expectation-driven mocks unless the call sequence is
  explicitly part of the contract.
- Place under `test/_support/msw/`.

### Harness helpers (infrastructure)

- Helpers that start containers, servers, or other infrastructure MUST live
  under `test/_support/harness/`.
- MUST only be imported by integration and E2E tests (not unit tests).

---

## Anti-Patterns

| Anti-pattern | Why harmful | Fix |
|-------------|-------------|-----|
| Giant golden fixtures | Fragile, hard to maintain, obscure intent | Use builders + small fixtures |
| Fixtures under `src/` | Mixes test support with production code | Move to `test/_support/fixtures/` |
| Shared mutable test state | One test poisons another | Use builders; isolate per test |
| Infrastructure helpers in unit test imports | Unit tests become slow and coupled | Keep harness under `test/_support/harness/`; import only in integration/E2E |
| Unnamed/generic helpers | Hard to find, hard to maintain | Follow naming conventions above |

---

## See Also

- [suffixes-and-layout.md](suffixes-and-layout.md) — where test files go
- [spec-vs-test.md](spec-vs-test.md) — suffix semantics
