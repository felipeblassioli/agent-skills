# Integration testing - repository and route slices with real wiring

Integration tests prove repository or HTTP-route behavior with real in-process wiring and a real ephemeral database. They sit between pure tests and browser-driven E2E.

## Scope

- Repository suites under `packages/*/test/integration/**/*.int.test.ts`.
- Route suites under `packages/*/test/integration/**/*.int.test.ts`.
- **Goal**: prove mappings, validation, auth, persistence, and transaction behavior with real app wiring.
- **Non-goal**: browser navigation and UI rendering. That belongs to E2E.

## Principles

1. **State verification.** Assert rows, returned domain objects, HTTP status codes, and response bodies - not query-builder internals.
2. **Real wiring, local process.** Use the same repositories, middleware, validation, and migrations as production where practical.
3. **Hermetic database.** Prefer a fresh in-memory SQLite database per file or per process.
4. **Fake only external systems.** If the slice crosses an outbound HTTP seam, use MSW.
5. **No shared state between files.** Process isolation beats clever cleanup.

## Suggested layout

```text
packages/db/
├── vitest.integration.config.ts
└── test/integration/
    └── roster-repository.int.test.ts

packages/api/
├── vitest.integration.config.ts
└── test/integration/
    └── schedules.routes.int.test.ts
```

## Harness shape

- Apply real migrations before the suite runs.
- Build the app in-process via a helper such as `createTestApp()` or `createTestDb()`.
- When route auth matters, inject the current user through a test-only seam rather than standing up the full auth system.
- Use Vitest process isolation (`pool: "forks"` or equivalent) when suites mutate globals or rely on a fresh DB per file.

## Repository example

```ts
import { beforeEach, describe, expect, it } from "vitest";

import { createTestDb } from "../test-support/create-test-db";
import { createRosterRepository } from "../../src/roster.repository";

describe("RosterRepository", () => {
  let db: Awaited<ReturnType<typeof createTestDb>>;

  beforeEach(async () => {
    db = await createTestDb();
  });

  it("persists and reloads a generated roster", async () => {
    const repo = createRosterRepository(db.client);
    const roster = { id: "roster-1", teamId: "team-1", week: "2026-W20" };

    await repo.save(roster);

    expect(await repo.findById("roster-1")).toEqual(roster);
  });
});
```

## Route example

```ts
import { describe, expect, it } from "vitest";

import { createTestApp } from "../test-support/create-test-app";

describe("POST /api/schedules", () => {
  it("creates a schedule for an authorized user", async () => {
    const app = await createTestApp({ currentUser: { id: "user-1", role: "manager" } });

    const response = await app.request("/api/schedules", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ week: "2026-W20" })
    });

    expect(response.status).toBe(201);
    expect(await response.json()).toMatchObject({ week: "2026-W20" });
  });
});
```

## Isolation checklist

- Fresh in-memory DB per file or per process.
- Real migrations applied before assertions.
- Unique IDs per test.
- MSW `onUnhandledRequest: "error"` if outbound HTTP is present.
- No suite-wide mutable fixtures shared across files.

## Anti-patterns

- Mocking the ORM or SQL client. That removes the main thing the layer is supposed to prove.
- Reusing one database across the whole suite without hard isolation boundaries.
- Calling live external APIs from integration tests.
- Asserting only that a repository or handler method was called.

## Related

- Contract/golden guidance: [contract-testing.md](contract-testing.md)
- E2E guidance: [e2e-testing.md](e2e-testing.md)
- MSW patterns for outbound HTTP seams: [msw-v2.md](msw-v2.md)
