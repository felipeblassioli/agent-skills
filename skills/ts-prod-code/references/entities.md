# Entities (`*.entity.ts`)

An entity has **identity** and **invariants** that survive across state changes. Pick **one style per entity** and stay consistent. Both styles are valid; the choice is local.

## Rule 0 — One style per entity

Choose **either** the Encapsulated-Class style **or** the Immutable-Record + Pure-Functions style. **Never mix** both inside the same entity. Child entities of the same aggregate may differ from the root if it makes sense, but the root sets the tone.

## Rule 1 — Persistence-ignorance

Entities do not know about SQL columns, ORM types, table names, JSON serialization shapes, or DB transactions. Mapping rows ⇄ entity is the **repository's** job (see [repositories-and-gateways.md](repositories-and-gateways.md)).

## Style A — Encapsulated class

| Section | Mandatory content | Constraint |
|---|---|---|
| Private fields | All state in `private` fields (`_id`, `_status`, ...) | No public mutable properties |
| Constructor | `private`, accepts only validated VOs and primitives | Prevents uncontrolled instantiation |
| Static factories | At least `createNew(...)` (use-case driven) and `rebuild(...)` (repo-driven) | Factories enforce invariants and emit `"created"` events when appropriate |
| Domain methods | Imperative verbs (`disable()`, `makeDefault()`) that mutate internal state | Always enforce invariants; emit domain events into a private buffer |
| Event buffer | Private `events: DomainEvent[] = []` + `pullEvents(): DomainEvent[]` | Pull-based: repository drains and the bus publishes after commit |
| Getters | `get id()`, `get status()` | Never expose mutable state |
| External immutability | Callers can't bypass methods | Treat the entity as a transactional unit |

```ts
// credit-card.entity.ts
import { CardToken } from "./card-token.vo";
import { CreditCardAddedEvent } from "./credit-card-added.event";
import { DomainEvent } from "../shared/domain-event";

export class CreditCard {
  private events: DomainEvent[] = [];

  private constructor(
    private readonly _id: string,
    private readonly _token: CardToken,
    private _isDefault: boolean,
  ) {}

  static createNew(args: { id: string; token: CardToken }): CreditCard {
    const card = new CreditCard(args.id, args.token, /* isDefault */ false);
    card.events.push(new CreditCardAddedEvent({ cardId: args.id }));
    return card;
  }

  static rebuild(args: { id: string; token: CardToken; isDefault: boolean }): CreditCard {
    return new CreditCard(args.id, args.token, args.isDefault);
  }

  makeDefault(): void {
    if (this._isDefault) return;
    this._isDefault = true;
  }

  pullEvents(): DomainEvent[] {
    const out = this.events;
    this.events = [];
    return out;
  }

  get id(): string { return this._id; }
  get token(): CardToken { return this._token; }
  get isDefault(): boolean { return this._isDefault; }
}
```

## Style B — Immutable record + pure functions

| Section | Mandatory content | Constraint |
|---|---|---|
| Type alias | Branded `Readonly<{ ... }>` | Prevents structural confusion across contexts |
| Factory | `createCreditCard(input): [CreditCard, DomainEvent[]]` | Validates invariants; returns frozen state and events |
| Behavior functions | Pure: `disableCard(card, reason): [CreditCard, DomainEvent[]]` | Never mutate inputs |
| Event emission | Each function returns a tuple `[nextState, events[]]` | Explicit, testable |
| Persistence mapping | Repository handles fromPersistence/toPersistence | Helpers stay in repository |
| No classes, no `this` | Data + functions | Highly portable, JSON-friendly |

```ts
// credit-card.entity.ts
import { CardToken } from "./card-token.vo";
import { DomainEvent } from "../shared/domain-event";

export type CreditCard = Readonly<{
  id: string;
  token: CardToken;
  isDefault: boolean;
}> & { readonly __brand: "CreditCard" };

export function createCreditCard(args: { id: string; token: CardToken }): [CreditCard, DomainEvent[]] {
  const card = Object.freeze({
    id: args.id,
    token: args.token,
    isDefault: false,
  }) as CreditCard;
  return [card, [{ name: "credit-card.added", cardId: args.id }]];
}

export function makeDefault(card: CreditCard): [CreditCard, DomainEvent[]] {
  if (card.isDefault) return [card, []];
  const next = Object.freeze({ ...card, isDefault: true }) as CreditCard;
  return [next, [{ name: "credit-card.default-changed", cardId: card.id }]];
}
```

## Shared rules (both styles)

| Concern | Rule |
|---|---|
| Validation at creation | Always validate in the factory/constructor; never allow partially built entities |
| No I/O, no randomness, no clock | Entities cannot fetch, log, generate UUIDs, or read `Date.now()`. Pass these from the use-case. |
| Domain events | Class style: private buffer + `pullEvents()`. Record style: tuple return. |
| Custom errors | Throw **domain-specific** errors (or return `Result`); never throw plain `Error` or strings |
| Isolation | `*.entity.ts` may **only** import VOs, domain events, and domain errors. **No** repositories, gateways, controllers, infra, ORMs. |
| Unit testing | Test without mocks: construct directly via factory; assert state and pulled events |

## Mapping at the repository

The repository (in `infra/`) is responsible for:

1. Reading raw rows.
2. Converting columns into VOs (`parseCardToken(row.card_token)`).
3. Calling `CreditCard.rebuild(...)` (Style A) or `Object.freeze(...)` + brand (Style B) with VOs.
4. Persisting back: extract the entity's accessors / record fields, write columns.

**Never** give factories raw row shapes (`row.card_token` strings, ORM model instances). Always domain-friendly inputs.

```ts
// infra: credit-card.repository.pg.ts (Style A)
const row = await db.selectFrom("credit_cards").selectAll().where("id", "=", id).executeTakeFirst();
if (!row) return undefined;
return CreditCard.rebuild({
  id: row.id,
  token: parseCardToken(row.card_token),
  isDefault: row.is_default,
});
```

## Quick decision

| If you... | Then... |
|---|---|
| Prefer object-oriented style, stateful aggregates, rich methods | Style A (Class) |
| Prefer immutable data, functional purity, easy serialization, event-sourcing-friendly | Style B (Record) |
| Have an aggregate that needs invariant enforcement spanning many fields | Either; Style A is slightly easier to enforce |
| Need a JSON-portable representation | Style B is simpler |

## Smells

- An entity that imports `axios` or `prisma` → broken dependency rule.
- An entity that calls `crypto.randomUUID()` → push the side effect to the use-case; pass the id in.
- An entity with public mutable fields → use private + getters (Style A) or tuple-returning functions (Style B).
- An entity exposing `toRow()` / `toDb()` → mapping belongs in the repository.
