# Suite Health — Operational Constraints

A test suite is only valuable if it is trustworthy. Flaky, slow, or tangled
suites erode confidence and get ignored. This reference codifies the
non-negotiable operational properties of a healthy test suite.

---

## Non-Negotiable Properties (below E2E)

For any test tier below true E2E/system tests, ALL of the following MUST hold:

### 1. Hermetic

- Each test MUST be self-contained: it creates its own state, exercises the
  SUT, asserts, and cleans up.
- Tests MUST NOT depend on execution order.
- Tests MUST NOT share mutable state (global variables, shared database rows,
  shared files).
- If a test needs reference data, it MUST either create it or use an immutable
  shared seed.

### 2. Deterministic

- Tests MUST produce the same result on every run, on any machine.
- No live network calls (except to local/ephemeral containers).
- Time MUST be controlled via dependency injection (clock abstraction), not
  `Date.now()` or `time.Now()`.
- Randomness MUST be seeded or abstracted.
- Filesystem access MUST use temp directories or in-memory alternatives.

### 3. Parallel-by-default

- Tests MUST be safe to run in parallel unless explicitly marked otherwise.
- No shared mutable state (see Hermetic above).
- Database tests SHOULD use per-test isolation (ephemeral DB, transaction
  rollback, or schema-per-test).

---

## Fixture Strategy

### MUST prefer

- **Builders/factories** — small, composable, explicit about what they create.
- **Small composable seeds** — minimal data to satisfy the test scenario.

### MUST avoid

- **Giant golden fixtures** — large static snapshots of "the world" that every
  test depends on. They are fragile, hard to maintain, and obscure test intent.
- **Shared mutable fixtures** — if one test mutates the fixture, other tests
  break unpredictably.

### MAY use

- **Static fixtures** for genuinely static data (JSON files, CSV samples) that
  are read-only and small.
- **Fixture generation helpers** ("Object Mothers") for complex object graphs,
  but keep them focused and well-maintained.

---

## Controlling Nondeterminism

| Source | Solution |
|--------|----------|
| System time | Inject a clock abstraction; never call `Date.now()` / `time.Now()` directly in tested code |
| Random values | Inject a seeded RNG or abstract the randomness source |
| Network calls | Use local containers (Testcontainers pattern) or stub/fake the client |
| Filesystem | Use temp directories; clean up in teardown |
| Concurrency | Design for deterministic ordering in tests; use latches/barriers if needed |
| Third-party APIs | Stub/fake in PR runs; real calls only in scheduled contract tests |

---

## Test Output Hygiene

- Test runs SHOULD produce pristine output: no warnings, no deprecation
  notices, no unhandled promise rejections.
- Any noise in test output erodes trust and hides real failures.
- Logging in tests SHOULD be suppressed or captured, not dumped to stdout.

---

## Anti-Patterns

| Anti-pattern | Why harmful | Fix |
|-------------|-------------|-----|
| Tests depend on execution order | Passes locally, fails in CI shuffle | Make each test self-contained |
| Shared mutable global state | One test poisons another | Isolate per test; use DI |
| `sleep(N)` for timing | Flaky and slow | Use deterministic signals (events, polling with timeout) |
| Ignoring flaky tests | Erodes suite trust | Fix or quarantine immediately |
| Test-only methods on production classes | Pollutes the production API | Use dependency injection or test-specific subclasses |
| Giant shared fixtures | Fragile, obscure intent | Use builders; keep fixtures small |
| Uncontrolled time/randomness | Different results on different machines | Inject clock/RNG |

---

## Suite Organization (language-agnostic principles)

- Directory and suffix conventions MUST be standardized within a project so CI
  and tooling can target tiers predictably.
- The convention MUST be documented and enforced by automated checks (linters,
  audit scripts).
- For language-specific conventions, see the corresponding organization skill
  (e.g., `typescript-testing-organization`).

---

## See Also

- [taxonomy-test-tiers.md](taxonomy-test-tiers.md) — tier definitions and scope
- [assertions-and-contracts.md](assertions-and-contracts.md) — meaningful assertions
- [methodology-red-green-refactor.md](methodology-red-green-refactor.md) — the TDD cycle
