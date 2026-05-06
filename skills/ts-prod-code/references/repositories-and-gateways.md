# Repositories and Gateways

The two **outbound ports** of a slice. Both are infrastructure adapters; both expose **interfaces in the domain** and **implementations in infra**.

## Repository — collection-like access to an aggregate

A repository encapsulates I/O for one aggregate root. It is **I/O-only**: SQL/NoSQL, identity map, transactions, cache, mapping. It contains **no business rules**.

### Interface in domain

```ts
// src/payments/domain/credit-card.repository.ts
import { CreditCard } from "./credit-card.entity";

export interface CreditCardRepository {
  findById(id: string): Promise<CreditCard | undefined>;
  findByCustomer(customerId: string): Promise<ReadonlyArray<CreditCard>>;
  save(card: CreditCard): Promise<void>;
}
```

### Implementation in infra

```ts
// src/payments/infra/credit-card.repository.pg.ts
import { Kysely } from "kysely";
import { CreditCard } from "../domain/credit-card.entity";
import { CreditCardRepository } from "../domain/credit-card.repository";
import { parseCardToken } from "../domain/card-token.vo";

export class CreditCardRepositoryPg implements CreditCardRepository {
  constructor(private readonly db: Kysely<DB>) {}

  async findById(id: string): Promise<CreditCard | undefined> {
    const row = await this.db
      .selectFrom("credit_cards")
      .selectAll()
      .where("id", "=", id)
      .executeTakeFirst();

    if (!row) return undefined;

    return CreditCard.rebuild({
      id: row.id,
      token: parseCardToken(row.card_token),
      isDefault: row.is_default,
    });
  }

  async save(card: CreditCard): Promise<void> {
    await this.db
      .insertInto("credit_cards")
      .values({
        id: card.id,
        card_token: card.token,
        is_default: card.isDefault,
      })
      .onConflict(oc => oc.column("id").doUpdateSet({ is_default: card.isDefault }))
      .execute();
  }
}
```

### Allowed inside a repository impl

| Allowed | Forbidden |
|---|---|
| SQL / Kysely / ORM calls | Pricing rules, fraud rules, validation invariants |
| Mapping rows ↔ entities | Mutating aggregate state (except reconstruction) |
| Identity map / cache | Calling a payment or email gateway |
| Opening / committing transactions | Deciding business outcomes (e.g. "is this card default?") |

### File names

| File | Location |
|---|---|
| `*.repository.ts` (interface) | `src/<context>/domain/` |
| `*.repository.<tech>.ts` (impl) | `src/<context>/infra/` |
| `*.mapper.ts` (optional row ⇄ entity helper) | `src/<context>/infra/`, sibling to the impl |

## Gateway — anti-corruption adapter to an external system

A gateway wraps an external API/SDK (Adyen, Stripe, Twilio, internal microservice, queue) and **translates** its DTOs to/from domain types.

### Interface in domain

```ts
// src/payments/domain/payment-tokenizer.gateway.ts
import { CardToken } from "./card-token.vo";
import { Result } from "../../shared/result";

export interface PaymentTokenizerGateway {
  tokenize(input: { pan: string }): Promise<Result<CardToken, "REFUSED" | "TIMEOUT">>;
}
```

### Implementation in infra

```ts
// src/payments/infra/adyen.gateway.ts
import { PaymentTokenizerGateway } from "../domain/payment-tokenizer.gateway";
import { parseCardToken } from "../domain/card-token.vo";
import { ok, err } from "../../shared/result";

export class AdyenGateway implements PaymentTokenizerGateway {
  constructor(private readonly http: AdyenHttpClient) {}

  async tokenize(input: { pan: string }) {
    const res = await this.http.post("/tokenise", { pan: input.pan });
    if (res.resultCode === "Refused") return err("REFUSED");
    return ok(parseCardToken(res.external_unique_id));
  }
}
```

### Rules

- The gateway **maps DTOs to value objects** before returning. Never let raw external JSON leak past infra.
- Translate transport errors into a closed-set domain error code (`"REFUSED" | "TIMEOUT"`); the use-case decides what to do.
- Apply retries, exponential back-off, circuit-breaking **inside** the gateway. The use-case sees the final outcome.
- Mark non-recoverable transport failures as `RecoverableInfrastructureError` (see [error-model.md](error-model.md)).

### Why interfaces in the domain?

So the use-case (application layer) depends only on **what** it needs (the abstraction), never on **how** (the SDK). This is the dependency rule (see [module-layering.md](module-layering.md)) and is what enables:

- swapping vendors (Adyen → Stripe) without touching domain or use-cases;
- in-memory **fakes** for tests (see ts-hermetic-testing);
- consumer-driven contract tests at the gateway boundary.

## Anti-patterns

- A "repository" that performs business validation. Wrong: move it to a `*.policy.ts` or entity method.
- A gateway that returns raw vendor JSON to the use-case. Wrong: map to a VO/result first.
- A repository that talks to two aggregates. Split: one repository per aggregate root.
- A use-case that imports a repository **impl** directly (`import { CreditCardRepositoryPg }`). Wrong: depend on the interface; wire the impl at the composition root.
- A gateway that logs and rethrows. Log **once** at the boundary that surfaces the error to the user; the gateway should translate (see [error-model.md](error-model.md), [observability.md](observability.md)).

## Testing

| Layer | Tier | Doubles |
|---|---|---|
| Repository impl | Integration (real in-memory DB with migrations or equivalent app test harness) | None inside the bounded context |
| Gateway impl | Integration (MSW v2 fakes external HTTP) | MSW handlers as stubs/fakes |
| Use-case using a repository | Unit | In-memory fake repository (`__helpers__/credit-card.repository.fake.ts`) |
| Use-case using a gateway | Unit | In-memory fake gateway with `reset()` |

See sibling skill **ts-hermetic-testing**.
