# Vitest and Playwright runner notes

This skill treats **Vitest** as canonical for unit, contract, and integration layers, and **Playwright** as canonical for E2E.

## Vitest basics

| Need | Vitest API |
|---|---|
| Test structure | `describe`, `it`, `test`, `expect` |
| Function doubles | `vi.fn()` |
| Spies | `vi.spyOn()` |
| Module mocks | `vi.mock()` |
| Fake timers | `vi.useFakeTimers()` / `vi.setSystemTime()` |
| Type assertions | `expectTypeOf()` |

## ESM mocking

Keep module mocks before importing the module under test. When the module reads values at import time, use `vi.hoisted()` and dynamic `import()`.

```ts
import { vi } from "vitest";

const { fixedNow } = vi.hoisted(() => ({
  fixedNow: new Date("2026-05-01T00:00:00Z")
}));

vi.mock("../clock", () => ({
  now: () => fixedNow
}));

const { buildWindow } = await import("../build-window");
```

## Typical Vitest configs

### Unit and contract

```ts
import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    environment: "node",
    include: ["src/**/*.test.ts", "test/contract/**/*.contract.test.ts"]
  }
});
```

### Integration

```ts
import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    environment: "node",
    pool: "forks",
    singleFork: false,
    setupFiles: ["./test/integration/setup.ts"],
    include: ["./test/integration/**/*.int.test.ts"]
  }
});
```

Use `pool: "forks"` when a fresh process per file makes DB or global-state isolation easier.

## Playwright basics

- Put browser flows under `e2e/*.spec.ts`.
- Use `playwright.config.ts` to boot the local app with `webServer`.
- Use `e2e/global-setup.ts` when the API or supporting services need explicit startup.
- Prefer role- and text-based selectors to brittle CSS selectors.

## Mapping from older Jest conventions

| Older convention | Current equivalent |
|---|---|
| `jest.useFakeTimers()` | `vi.useFakeTimers()` |
| `setupFilesAfterEnv` | `setupFiles` |
| `*.integration.test.ts` | `*.int.test.ts` |
| request-level E2E helpers | Playwright browser flows in `e2e/*.spec.ts` |
| ad hoc snapshot coverage | explicit contract/golden suites |

## Watch mode

- Vitest: `vitest`
- Focused file: `vitest path/to/file.test.ts`
- Playwright: `playwright test`

## Anti-patterns

- Keeping runner setup files while changing the tier model underneath them.
- Reusing browser E2E conventions for in-process integration tests.
- Treating contract/golden tests as "just snapshots" instead of observable contracts.
