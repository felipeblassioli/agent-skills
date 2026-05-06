# Doubles taxonomy and `__helpers__/` suffixes

Fowler's *Mocks Aren't Stubs* taxonomy, applied with file-suffix discipline. The default mode is **state verification**: assert observable outcomes, not "method X was called".

## The taxonomy

| Double | Definition | Verification style | When to use |
|---|---|---|---|
| **Stub** | Stateless: returns canned answers, never asserts on calls | State | Happy path / specific error code where the test only cares about input → fixed output |
| **Fake** | Working in-memory implementation with minimal logic and state, exposes `reset()` | State (assert via outputs / DB / ledger) | Replace heavy collaborators (in-memory repository, ledger of charges, fake email sink) |
| **Spy** | Like a stub but records calls so you can assert later | Behavior, sparingly | Outbound boundary you must verify (e.g. `EventBus.publish` was called once with X) |
| **Mock** | Pre-programmed with **expectations**; assertion lives inside the double | Behavior | Last resort. Reserve for cross-cutting concerns (metrics, logging) where state verification is impractical |
| **Dummy** | Object passed but never used | n/a | Almost never; prefer builders |

> "Most MSW handlers you write to stand-in for a SaaS API are **stubs**." If the handler keeps in-memory state or has decision logic, it becomes a **fake**. If you also assert on what was sent, you've added a **spy** facet. If the assertion lives **inside** the handler ("must be called exactly once"), that part is a **mock**.

## File-suffix discipline (`test/__helpers__/`)

| Suffix | Role | Example |
|---|---|---|
| `*.stub.ts` | Stateless factory of canned responses (MSW handlers, DTO builders) | `adyen-tokenise.stub.ts` |
| `*.fake.ts` | Stateful in-memory replacement with `reset()` | `payment.fake.ts`, `credit-card.repository.fake.ts` |
| `*.spy.ts` | Light wrapper that records calls (when an inline spy function is not enough) | `event-bus.spy.ts` |
| `*.mock.ts` | Behavior-verification mock/spy wrapper with expectations | `logger.mock.ts` |
| `*.builder.ts` | Fluent DSL for variant test data | `user.builder.ts` |
| `*.fixture.ts` / `*.fixture.json` / `*.fixture.sql` | Frozen reference data | `user.fixture.json` |

Companion folders:
- `test/__helpers__/` — code-based doubles and builders.
- `test/__fixtures__/` — immutable data of any type. **Never mutated** during a test.

## Examples

### Stub (canned response)

```ts
// adyen-tokenise.stub.ts
import { http, HttpResponse } from "msw";
import { faker } from "@faker-js/faker";

export const tokeniseOk = (extId = faker.string.uuid()) =>
  http.post("https://pal-live.adyen.com/tokenise", () =>
    HttpResponse.json({ resultCode: "Success", external_unique_id: extId }),
  );

export const tokeniseRefused = (reason = "Do not honour") =>
  http.post("https://pal-live.adyen.com/tokenise", () =>
    HttpResponse.json({ resultCode: "Refused", refusalReason: reason }, { status: 402 }),
  );

export const adyenHappyPath = [tokeniseOk()];
```

### Fake (stateful, with `reset()`)

```ts
// payment.fake.ts
import { http, HttpResponse } from "msw";

export const paymentFake = (() => {
  let ledger: unknown[] = [];

  const handler = http.post("/charge", async ({ request }) => {
    const body = await request.json();
    ledger.push(body);
    const highValue = Number((body as { amount: string }).amount) > 100_000;
    return highValue
      ? HttpResponse.json({ resultCode: "Refused" }, { status: 402 })
      : HttpResponse.json({ resultCode: "Success" });
  });

  return {
    handler,
    log: () => ledger.slice(),
    reset: () => { ledger = []; },
  };
})();
```

Always reset stateful fakes in `afterEach`:

```ts
afterEach(() => paymentFake.reset());
```

### In-memory repository fake (no MSW)

```ts
// credit-card.repository.fake.ts
import type { CreditCardRepository } from "@/payments/domain/credit-card.repository";
import type { CreditCard } from "@/payments/domain/credit-card.entity";

export const createCreditCardRepoFake = (): CreditCardRepository & { _store: Map<string, CreditCard>; reset(): void } => {
  const _store = new Map<string, CreditCard>();
  return {
    _store,
    reset() { _store.clear(); },
    async findById(id) { return _store.get(id); },
    async findByCustomer(customerId) {
      return [..._store.values()].filter(c => c.customerId === customerId);
    },
    async save(card) { _store.set(card.id, card); },
  };
};
```

### Spy on a single boundary (E2E, EventBus)

```ts
// event-bus.spy.ts
import type { EventBus, DomainEvent } from "@/shared/event-bus";

export const eventBusSpy = (): EventBus & { calls: DomainEvent[]; reset(): void } => {
  const calls: DomainEvent[] = [];
  return {
    calls,
    reset() { calls.length = 0; },
    publish(event) { calls.push(event); return Promise.resolve(); },
  };
};
```

## State vs behavior verification — choosing

| You want to assert... | Use |
|---|---|
| The DB now contains a row matching X | State (Stub/Fake) |
| The HTTP response status and body are exactly Y | State (Stub/Fake) |
| The use-case published the right domain event | Spy (single integration spy at EventBus interface) |
| A logger emitted a metric with shape Z | Mock (rare; cross-cutting) |
| A specific outbound HTTP call was made with body W | Spy facet on the MSW handler (capture in a closure) |

**Rule of thumb**: if your test would pass with a different *implementation* (refactor) of the SUT, it's verifying behavior at the right level. If it breaks just because the SUT now calls `repo.findOne` instead of `repo.findById`, it's over-specified.

## Where to mock vs not

Allowed double | Inside the bounded context | At a port (repository, gateway) | At an external HTTP edge
---|---|---|---
Stub | ❌ | ✅ | ✅ (MSW)
Fake | ❌ | ✅ | ✅ (MSW with state)
Spy | ❌ (E2E EventBus is the exception) | ✅ if needed | ✅ (closure)
Mock | ❌ | ❌ rare | ❌

**Inside the bounded context, run the real code.** Doubles live at edges.

## Anti-patterns

- A `.mock.ts` inside an E2E suite. Treat it as a smell; use `.fake.ts` or `.stub.ts`.
- Asserting `expect(repo.save).toHaveBeenCalledWith(...)` instead of asserting the saved row exists.
- Stateful fakes without a `reset()`. Test order will eventually break.
- Mutating a fixture in-place. Fixtures are **immutable**; copy first if you need a variant.
- A `dummy` object that's actually used by the SUT. Promote to a stub or fake.
