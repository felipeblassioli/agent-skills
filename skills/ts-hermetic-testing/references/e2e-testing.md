# E2E testing - browser journeys against the real stack

E2E suites exercise the whole user-visible slice from the browser: real UI, real API, real persistence, and only intentional external seams faked.

## Philosophy

1. **Test browser-visible behavior.** Use Playwright, not lower-level request helpers, when the goal is a user journey.
2. **Boot the real stack.** Start the app the way developers run it locally, with test-only hooks for seeding and reset if needed.
3. **Fake only intentional external systems.** Third-party APIs, email, or payment providers may be replaced; internal app wiring should stay real.
4. **Prefer state verification.** Assert rendered UI, navigation, network outcomes, and persisted state instead of internal call counts.

## Placement

| Location | Purpose |
|---|---|
| `playwright.config.ts` | Browser runner configuration and local `webServer` boot |
| `e2e/*.spec.ts` | Playwright scenarios |
| `e2e/global-setup.ts` | Optional API/server startup or suite seeding |
| test-only app routes/hooks | Deterministic seed/reset support when the product exposes them |

## Minimal example

```ts
import { expect, test } from "@playwright/test";

test("manager can generate a schedule", async ({ page, request }) => {
  await request.post("/api/test/reset");
  await request.post("/api/test/seed", {
    data: { scenario: "schedule-ready-team" }
  });

  await page.goto("/");
  await page.getByRole("link", { name: "Schedules" }).click();
  await page.getByRole("button", { name: "Generate schedule" }).click();

  await expect(page.getByText("Schedule generated")).toBeVisible();
  await expect(page.getByRole("table", { name: "Generated schedule" })).toBeVisible();
});
```

## Setup guidance

- Use `playwright.config.ts` to boot the frontend via `webServer`.
- Start the API or background services from `e2e/global-setup.ts` when they are not already covered by the frontend server startup.
- Use explicit test-only seed/reset endpoints or equivalent harnesses to make fixtures deterministic.
- If auth is expensive, prefer a test-only impersonation seam over replaying the full login stack in every spec.

## Isolation

1. Reset data at the start of each spec or scenario.
2. Avoid shared IDs; generate unique values per run.
3. Run serially when the app uses a shared file-backed DB or any other global state.
4. Keep browser assertions resilient: prefer roles, labels, and visible text over brittle selectors.

## When to add E2E

- Add or update E2E when a change affects a browser-visible flow.
- Keep E2E optional in fast local pre-PR loops unless the edited behavior is itself end-to-end.
- Expect CI or release verification to run the full browser suite.

## Anti-patterns

- Calling route handlers directly from an E2E file. That is integration, not E2E.
- Mocking your own API, database, or router in a browser flow.
- Depending on previous specs to create state.
- Using screenshot assertions for every change when text or role-based assertions would be clearer.

## Related

- Integration testing: [integration-testing.md](integration-testing.md)
- MSW guidance for external HTTP seams: [msw-v2.md](msw-v2.md)
- Contract/golden tests for deterministic pure pipelines: [contract-testing.md](contract-testing.md)
