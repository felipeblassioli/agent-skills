# Domain Policies (`*.policy.ts`)

A domain policy expresses a **stateless business rule** that doesn't naturally belong to a single entity, typically because it crosses multiple entities or value objects.

## Rules

| Rule | How to enforce in TypeScript |
|---|---|
| **Stateless** — no mutable instance fields | Prefer a pure function. If you need an interface, make the impl a class with `readonly` injected collaborators. |
| **Domain-only dependencies** | Accept and return entities, value objects, branded types, domain events. **Never** repositories, gateways, loggers, clocks. |
| **Deterministic, side-effect-free** | No logging, no random IDs, no `Date.now()` unless passed as an argument. |
| **Unit-testable in isolation** | No mocks needed; call the function directly with constructed entities. |

## Canonical example — pure function

```ts
// fraud-analysis.policy.ts
import { Customer } from "./customer.entity";
import { CreditCard } from "./credit-card.entity";
import { FraudScore } from "./fraud-score.vo";

export const assessFraudScore = (customer: Customer, newCard: CreditCard): FraudScore => {
  const reused = customer.cards.some(c => c.maskedBin === newCard.maskedBin);
  return reused ? FraudScore.low() : FraudScore.medium();
};
```

No `this`, no mutable fields, trivially thread-safe and testable.

## When you need an interface (rare)

If multiple implementations are required for testing or A/B switching:

```ts
export interface FraudAnalysisPolicy {
  assess(customer: Customer, newCard: CreditCard): FraudScore;
}

export const simpleFraudPolicy: FraudAnalysisPolicy = {
  assess: assessFraudScore,
};
```

The class form should hold only `readonly` collaborators (e.g. injected configuration values, not services).

## Where to put it

- **Domain layer**: `src/<context>/domain/<concept>.policy.ts`.
- It is **not** a use-case (no orchestration, no I/O, no transaction).
- It is **not** a repository or gateway.

## When to extract a policy vs put logic in the entity

| Logic location | When |
|---|---|
| Inside an entity method | The rule depends on the entity's invariants and operates on its own state |
| `*.policy.ts` | The rule crosses multiple entities, or depends on a configuration/strategy that should be swappable, or is otherwise awkward to attach to one entity |

If it's a function of a single entity's state and produces a new state, prefer an entity method.

## Anti-patterns

- **A "service" that fetches and decides**: that's a use-case, not a policy. Move I/O out.
- **A policy that takes a `repository` parameter**: extract the data fetch to the use-case; pass the resolved entities/VOs to the policy.
- **Hidden time/random**: every non-deterministic input must be a parameter (`now: Date`, `randomId: () => string`).
- **Logging from inside a policy**: forbidden. Pure → no observability calls. Logging belongs at the boundary (see [observability.md](observability.md)).

## Testing

Test policies as pure functions:

```ts
test("reused BIN scores low risk", () => {
  const customer = makeCustomerWith({ cards: [aCardWithBin("411111")] });
  const newCard = aCardWithBin("411111");

  const score = assessFraudScore(customer, newCard);

  expect(score).toEqual(FraudScore.low());
});
```

No doubles. Build inputs with VO/entity factories. Assert returned value.

See sibling skill **ts-hermetic-testing**, `references/unit-testing.md` for builders and AAA conventions.
