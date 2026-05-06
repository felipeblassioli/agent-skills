# Jest config and lifecycle

Legacy reference only. This file documents older Jest-specific patterns; the canonical guidance for this skill now lives in `vitest-equivalents.md` and `tmp/oncall-roster-ag/docs/adr/ADR-001-testing-strategy.md`.

A single root preset, suite-specific overrides, and **semantically named helper files** so every engineer immediately knows what each setup script does and **when** it runs.

## Helper-file naming (semantic, not generic)

| File | Jest hook | Purpose |
|---|---|---|
| `jest.config.ts` | n/a | Root preset shared by all suites |
| `jest.env.setup.ts` | `setupFiles` | Set `process.env` and polyfills **before** the test framework loads |
| `jest.msw.setup.ts` | `setupFilesAfterEnv` | Install MSW, custom matchers, fake timers |
| `jest.<db>.setup.ts` | `globalSetup` | Spin up DB Testcontainer, run migrations |
| `jest.<db>.teardown.ts` | `globalTeardown` | Stop container, clean temp dirs |

> Mnemonic: **env** → variables, **msw** → mocks, **mysql/postgres** → heavy DB.

If you need additional heavy resources (Redis, MinIO, LocalStack), follow the same pattern: `jest.redis.setup.ts`, `jest.redis.teardown.ts`, etc.

**Do not** name files `setup.ts` or `globals.ts`. Generic names hide intent.

## Root preset

```ts
// jest.config.ts — single source of truth
import { createDefaultPreset } from "ts-jest";
import { pathsToModuleNameMapper } from "ts-jest";
import baseTs from "./tsconfig.base.json";
import type { JestConfigWithTsJest } from "ts-jest";

const preset = createDefaultPreset({ tsconfig: "tsconfig.base.json" });

const base: JestConfigWithTsJest = {
  ...preset,
  testEnvironment: "node",
  silent: true,
  clearMocks: true,
  moduleFileExtensions: ["ts", "js", "json", "node"],
  moduleDirectories: ["node_modules"],
  moduleNameMapper: pathsToModuleNameMapper(baseTs.compilerOptions.paths ?? {}, {
    prefix: "<rootDir>/",
  }),
  // Each suite supplies its own testMatch and coverageDirectory.
};

export default base;
```

## Integration suite override

```ts
// test/integration/jest.config.ts
import base from "../../jest.config";
import path from "node:path";
import type { JestConfigWithTsJest } from "ts-jest";

export default <JestConfigWithTsJest>{
  ...base,
  rootDir: path.resolve(__dirname, "../.."),
  testMatch: ["<rootDir>/test/integration/**/*.integration.test.ts"],
  globalSetup: "<rootDir>/test/integration/jest.mysql.setup.ts",
  globalTeardown: "<rootDir>/test/integration/jest.mysql.teardown.ts",
  setupFiles: ["<rootDir>/test/integration/jest.env.setup.ts"],
  setupFilesAfterEnv: ["<rootDir>/test/integration/jest.msw.setup.ts"],
  coverageDirectory: "<rootDir>/coverage/int",
  maxWorkers: "50%",
};
```

## E2E suite override

```ts
// test/e2e/jest.config.ts
import base from "../../jest.config";
import path from "node:path";
import type { JestConfigWithTsJest } from "ts-jest";

export default <JestConfigWithTsJest>{
  ...base,
  rootDir: path.resolve(__dirname, "../.."),
  testMatch: ["<rootDir>/test/e2e/**/*.e2e.test.ts"],
  globalSetup: "<rootDir>/test/e2e/jest.mysql.setup.ts",
  globalTeardown: "<rootDir>/test/e2e/jest.mysql.teardown.ts",
  setupFiles: ["<rootDir>/test/e2e/jest.env.setup.ts"],
  setupFilesAfterEnv: ["<rootDir>/test/e2e/jest.msw.setup.ts"],
  coverageDirectory: "<rootDir>/coverage/e2e",
  bail: 1,
  testTimeout: 10_000,
};
```

## Lifecycle (in order)

| Phase | Hook | Where it runs | Typical purpose |
|---|---|---|---|
| 0 | `globalSetup` | Once outside workers | Spin Testcontainer, create per-worker schema, seed reference data |
| 1 | `setupFiles` | Per worker, **before** test framework | Set `process.env`, polyfills, globals the framework relies on |
| 2 | `ts-jest` transpile | Per test file | n/a |
| 3 | `setupFilesAfterEnv` | Per worker, **after** framework ready | Start MSW, install custom matchers, fake timers |
| 4 | Test files | Parallel across workers | `*.test.ts`, `*.integration.test.ts`, `*.e2e.test.ts` |
| 5 | `globalTeardown` | Once after all workers | Stop containers, drop schemas |

> Hooks share in-memory state **within** a worker process; they do **not** share across workers (each worker is its own Node process).

## What goes where (don't mix)

| Need | Put it in |
|---|---|
| Spin MySQL + run migrations once | `jest.mysql.setup.ts` (`globalSetup`) |
| Tear down container | `jest.mysql.teardown.ts` (`globalTeardown`) |
| Set `LOCAL_FIRESTORE_RUNTIME` env | `jest.env.setup.ts` (`setupFiles`) |
| Install MSW server, custom matchers, fake timers | `jest.msw.setup.ts` (`setupFilesAfterEnv`) |

**Never** put module mocks in `setupFilesAfterEnv` — by then the SUT may already be imported. See [jest-mocking-semantics.md](jest-mocking-semantics.md).

## CI commands

```json
{
  "scripts": {
    "test:unit": "jest --config jest.unit.config.ts",
    "test:int": "jest --config test/integration/jest.config.ts",
    "test:e2e": "jest --config test/e2e/jest.config.ts",
    "test:ci": "npm run test:unit && npm run test:int && npm run test:e2e"
  }
}
```

Coverage thresholds and reporters live in the root preset.

## Quality gates

- Unit suite < 2 s per file; integration suite < 30 s; E2E < 2 min locally.
- Per-test timeout (E2E): 10 s.
- Fail on unhandled promise rejections: `node --unhandled-rejections=strict`.
- `--detectOpenHandles` locally; fix every cause.

## Anti-patterns

- Generic `setup.ts` names. Use semantic names.
- Module mocks in `setupFilesAfterEnv`. Mock right before the import in the test file (or use `jest.unstable_mockModule` in ESM).
- Async work in `setupFiles` that delays the framework. Move to `globalSetup`.
- One mega `jest.config.ts` with conditional logic per tier. Split into root preset + suite overrides.
- Sharing a single config across tiers without per-suite `coverageDirectory`. Coverage data will collide.
