# MSW v2 patterns

Mock Service Worker v2 is the canonical way to fake **external HTTP** in unit, integration, and E2E suites. Internal HTTP (your own server) stays real in integration and E2E.

## Principles

| We **fake** | We keep **real** |
|---|---|
| Third-party HTTP APIs (PSP, SMTP, SaaS) | Our HTTP server, middleware, local DB/app wiring, event-bus |

1. **State-verification > behavior-verification.** Assert rows and events, not inner calls.
2. **Determinism**: every `it` and every test file get the same clean handler set.
3. **Pure handlers preferred.** Stateful fakes expose `reset()`.

## Folder layout

```
test/
└── __helpers__/
    ├── server.mock.ts            ← setupServer + canonicalHandlers
    ├── adyen-tokenise.stub.ts    ← v2 handler factories (http.* + HttpResponse.*)
    ├── email.stub.ts
    ├── payment.fake.ts           ← stateful fake with reset()
    └── ...
└── e2e/
    ├── setup-msw.ts              ← lifecycle hooks loaded by Vitest or Playwright helpers
    └── ... .spec.ts
```

## Handler conventions (v2 syntax)

### Stateless stub — pure factory

```ts
// adyen-tokenise.stub.ts
import { http, HttpResponse } from "msw";
import { faker } from "@faker-js/faker";

export const tokeniseOk = (extId = faker.string.uuid()) =>
  http.post("https://pal-live.adyen.com/tokenise", () =>
    HttpResponse.json({
      resultCode: "Success",
      external_unique_id: extId,
    }),
  );

export const tokeniseRefused = (reason = "Do not honour") =>
  http.post("https://pal-live.adyen.com/tokenise", () =>
    HttpResponse.json(
      { resultCode: "Refused", refusalReason: reason },
      { status: 402 },
    ),
  );

export const adyenHappyPath = [tokeniseOk()];
```

### v1 → v2 cheat sheet

| v1 (`rest`) | v2 (`http`) |
|---|---|
| `rest.post(url, (req, res, ctx) => res(ctx.json(...)))` | `http.post(url, () => HttpResponse.json(...))` |
| `ctx.status(400)` | `HttpResponse.json(body, { status: 400 })` |
| `ctx.delay(ms)` | `HttpResponse.delay(ms)` (used as `return HttpResponse.delay(ms)` inside handler) |

### Stateful fake with `reset()`

```ts
// payment.fake.ts
import { http, HttpResponse } from "msw";

export const paymentFake = (() => {
  let ledger: unknown[] = [];

  const handler = http.post("/charge", async ({ request }) => {
    ledger.push(await request.json());
    return HttpResponse.json({ ok: true });
  });

  return {
    handler,
    log: () => ledger.slice(),
    reset: () => { ledger = []; },
  };
})();
```

## Bootstrap and lifecycle

```ts
// server.mock.ts
import { setupServer } from "msw/node";
import { adyenHappyPath } from "./adyen-tokenise.stub";
import { emailHappyPath } from "./email.stub";

export const canonicalHandlers = [
  ...adyenHappyPath,
  ...emailHappyPath,
];

export const server = setupServer(...canonicalHandlers);
```

```ts
// setup-msw.ts
import { server, canonicalHandlers } from "@/test/__helpers__/server.mock";
import { paymentFake } from "@/test/__helpers__/payment.fake";

beforeAll(() => server.listen({ onUnhandledRequest: "error" }));

afterEach(() => {
  server.resetHandlers(...canonicalHandlers); // wipe overrides + restore baseline
  paymentFake.reset();                         // reset stateful fakes
});

afterAll(() => server.close());
```

### Why this lifecycle works

- `server.resetHandlers(...)` operates on the `server` instance inside the **current Node.js worker**.
  - Across workers: isolated Vitest fork workers or Playwright worker processes naturally isolate registries.
  - Across files in the same worker: the trailing `afterEach` of file A runs before file B reuses the shared setup, restoring the baseline.

## Per-test override

```ts
import { server } from "@/test/__helpers__/server.mock";
import { tokeniseRefused } from "@/test/__helpers__/adyen-tokenise.stub";

it("returns 422 when the PSP refuses tokenization", async () => {
  server.use(tokeniseRefused("Invalid PAN"));

  const res = await request(app)
    .post("/credit-card/encoded")
    .send(validEncryptedPayload)
    .expect(422);

  expect(res.body.code).toBe("GATEWAY_REFUSED");
});
```

`afterEach` flushes this override automatically.

## `onUnhandledRequest`

Keep `'error'` in CI. Any unexpected outbound HTTP **fails the test immediately**, preventing silent network leakage.

When porting flaky legacy tests you may temporarily start with `'warn'`, but switch back before merging.

## Isolation grid

| Target | Mechanism | Hook |
|---|---|---|
| MSW handler registry | `resetHandlers(...canonicalHandlers)` | global `afterEach` |
| Stateful fake in-memory state | `fake.reset()` | global or local `afterEach` |
| DB rows | TX rollback or `truncateAll()` | local hooks |
| Time | `vi.useRealTimers()` | local `afterEach` |

## Adding a new external dependency — recipe

1. Create `xyz.stub.ts` with `http.*` factories and a happy-path export.
2. Append the happy-path to `canonicalHandlers` in `server.mock.ts`.
3. If stateful, wrap with `reset()` and reset it in `afterEach`.

## Debugging v2

| Symptom | Check |
|---|---|
| `request not mocked for GET http://...` | URL mismatch (use absolute URLs); v2 does not normalize trailing slashes |
| Body matcher fails | `await request.json()` in handler — ensure caller sends JSON; check `Content-Type` |
| Need delay | `return HttpResponse.delay(ms)` inside handler |
| Default export interop | Use `{ default: handler }` shape if your module re-exports |

## Commit checklist

- [ ] Factories use `http.*` + `HttpResponse.*` (no `rest`).
- [ ] `canonicalHandlers` updated when adding a new external dep.
- [ ] `afterEach` restores baseline (`resetHandlers(...canonicalHandlers)`).
- [ ] Stateful fakes expose `reset()` and are reset.
- [ ] Suite passes in parallel **and** with `--runInBand`.
- [ ] No `onUnhandledRequest` warnings in CI.

## Anti-patterns

- Importing handlers from production code (`import handlers from "@/__helpers__/..."`). Helpers must live under `test/` only.
- Hard-coding URLs in two places. Define them once (a constants module) and reuse in both production gateway and stub.
- Per-test `setupServer` calls. Use the canonical server from `server.mock.ts`.
- Asserting inside the handler ("must be called once"). Push the assertion to the test body or capture calls in a closure (`spy` pattern).

## Vitest

If you're on Vitest, MSW v2 setup is almost identical; minor lifecycle differences are in [vitest-equivalents.md](vitest-equivalents.md).

## Further reading

- MSW v2 docs — API overview.
- Fowler, *Mocks Aren't Stubs*.
- [e2e-testing.md](e2e-testing.md) for parallel-data-isolation specifics.
