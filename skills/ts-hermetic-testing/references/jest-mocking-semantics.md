# Jest mocking semantics — CJS, ESM, and DI seams

Legacy reference only. The mocking principles still apply, but this file uses older Jest-specific APIs; prefer `vitest-equivalents.md` for the current canonical runner guidance.

Module mocking is the highest-bug-density area of test setup. Follow these rules deterministically.

## Core principles

1. **Mock before import.** Define module mocks **before** importing the module under test (MUT). Jest snapshots the module registry at import time.
2. **Prefer DI seams over constructor interception.** Expose a factory or constructor parameter so tests pass a fake (`makeService(fakeDeps)`). Intercepting `new` is a last resort.
3. **Path exactness.** The mock path must match the import path **exactly**. One import path → one mock. Alias drift (`@/foo` vs `../foo`) breaks mocks silently.
4. **Per-test isolation.** When import-time state matters, use `jest.resetModules()` (CJS) or `jest.isolateModulesAsync()` (ESM) and re-import inside the test.

## CommonJS pattern

```ts
// __tests__/service.cjs.test.ts
jest.mock("../slack", () => ({
  SlackProvider: jest.fn().mockImplementation(() => ({
    send: jest.fn().mockResolvedValue(true),
  })),
}));

const { SlackProvider } = require("../slack"); // mock in effect
const { service } = require("../service");      // import after the mock

// If you keep the real class, mock instance methods via prototype
jest.spyOn(SlackProvider.prototype, "send").mockResolvedValue(true);
```

## ESM pattern (NodeNext, `"type": "module"`)

```ts
// __tests__/service.esm.test.ts
await jest.unstable_mockModule("../slack.js", () => ({
  default: class SlackProvider {
    send = jest.fn().mockResolvedValue(true);
  },
  __esModule: true, // default/named interop
}));

const { default: SlackProvider } = await import("../slack.js");
const { service } = await import("../service.js");
```

For variant graphs per test:

```ts
await jest.isolateModulesAsync(async () => {
  await jest.unstable_mockModule("../slack.js", () => ({ /* variant */ }));
  const { service } = await import("../service.js");
  // ...assertions
});
```

## Constructor interception (only if necessary)

When you cannot pass a fake via DI:

- **Best**: introduce a DI seam.
- If you must intercept `new`:
  - Replace the exported class with a fake class returning `jest.fn()`s, **or**
  - Keep the real class and **spy on the prototype**: `jest.spyOn(SlackProvider.prototype, "send")`.
  - Avoid half-mocked classes that break `instanceof` or trigger side-effects.

## Interop and partial mocks

For ESM default exports, return `{ default: mock, __esModule: true }`.

For partial mocks, pull through the real module:

```ts
// CJS
const real = jest.requireActual("../slack");
jest.mock("../slack", () => ({ ...real, send: jest.fn() }));

// ESM
const real = await import("../slack.js");
await jest.unstable_mockModule("../slack.js", () => ({ ...real, send: jest.fn() }));
```

## TypeScript helpers

- `jest.mocked(thing, { shallow: true })` for typed mocks when only replacing functions.
- Keep `ts-jest` / `babel-jest` `moduleNameMapper` in sync with `tsconfig.paths` so the mock path matches the import path. **Alias drift is the #1 source of "mock not taking effect" bugs.**

## Setup files — what NOT to do

Do **not** place module mocks in `setupFilesAfterEnv`. By that point, app code may already be imported (transitively, via `jest-circus` or test framework probes). The mock will silently miss the SUT's import.

Keep `setupFilesAfterEnv` for **globals only**: matchers, fake timers, MSW server lifecycle.

## Modern fake timers

Use modern fake timers consistently for time-based code; advance them explicitly.

```ts
beforeEach(() => jest.useFakeTimers({ now: new Date("2024-01-01T00:00:00Z") }));
afterEach(() => jest.useRealTimers());

it("times out after 5 seconds", async () => {
  const promise = doThing();
  jest.advanceTimersByTime(5_000);
  await expect(promise).rejects.toThrow("timeout");
});
```

## After-each cleanup

```ts
afterEach(() => {
  jest.clearAllMocks();    // call counts, instances
  jest.restoreAllMocks();  // spies → real implementation
});
```

If you set fake timers globally, restore them too.

## No open handles

Run with `--detectOpenHandles` locally. Common causes:

- A logger transport (e.g. file stream) not closed.
- A DB pool not ended.
- A timer (`setInterval`) not cleared.
- An MSW server not closed in `afterAll`.

**Fix the cause; don't suppress.**

## External HTTP — MSW v2 only

No real network calls in any tier. See [msw-v2.md](msw-v2.md). Run with `onUnhandledRequest: "error"` so any leakage fails the test immediately.

## Vitest

If you're using Vitest instead of Jest, the principles are identical; the API differs. See [vitest-equivalents.md](vitest-equivalents.md).

## Checklist (paste into PR description for non-trivial test changes)

- [ ] Mocks defined **before** importing the SUT.
- [ ] ESM tests use `unstable_mockModule` + dynamic `import()`.
- [ ] No reassignment of ESM imports; paths are exact.
- [ ] Prefer DI seam over constructor interception; prototype spies when keeping the real class.
- [ ] `resetModules` / `isolateModulesAsync` applied when import-time state matters.
- [ ] `__esModule: true` set for default-export mocks.
- [ ] `restoreAllMocks` + `clearAllMocks` in `afterEach`.
- [ ] Modern fake timers used; **no open handles**.
- [ ] External HTTP via **MSW v2** only (no live network).

## Anti-patterns

- Reassigning ESM imports (`(slack as any).send = jest.fn()`). ESM imports are read-only bindings; will fail or silently no-op depending on bundler.
- Mocking with relative path that doesn't match the SUT's alias import. Use the same path the SUT uses.
- Half-mocking a class so `instanceof` checks break. Either fully mock, or use prototype spies.
- Module mocks defined inside `beforeEach`. Hoisting rules will surprise you. Define at top of file.
