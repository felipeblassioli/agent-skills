# Value Objects (`*.vo.ts`)

A value object is an **immutable attribute object** with **no identity**, compared by value. The single source of truth for both compile-time type and runtime contract.

## Required ingredients

1. **Zod schema** (or equivalent codec) — runtime contract.
2. **Type alias** from `z.infer<>` — compile-time alias.
3. **Branded type** — prevents confusion with raw `string`/`number`/etc.
4. **Factory** (`parse`, `create`) — hides the constructor and enforces validation.
5. **Frozen / `readonly`** — true immutability for object-valued VOs.

## Canonical example

```ts
// card-token.vo.ts
import { z } from "zod";

const CardTokenSchema = z
  .string()
  .min(20)
  .max(40)
  .regex(/^[A-Za-z0-9_-]+$/, "invalid-token-format");

export type CardToken = z.infer<typeof CardTokenSchema> & { readonly __brand: "CardToken" };

export function parseCardToken(raw: unknown): CardToken {
  return CardTokenSchema.parse(raw) as CardToken;
}

export function isCardToken(x: unknown): x is CardToken {
  return CardTokenSchema.safeParse(x).success;
}
```

**Benefits**:

- **Compile-time**: a `CardToken` cannot be confused with any other `string`.
- **Runtime**: invalid strings are rejected at the boundary (controller, gateway, repo read).
- **Immutability**: primitives are immutable; for object-valued VOs, freeze.

## Object-valued VO

```ts
// money.vo.ts
import { z } from "zod";

const MoneySchema = z.object({
  amount: z.number().int().nonnegative(),
  currency: z.string().length(3).toUpperCase(),
}).readonly();

export type Money = Readonly<z.infer<typeof MoneySchema>> & { readonly __brand: "Money" };

export function parseMoney(raw: unknown): Money {
  const parsed = MoneySchema.parse(raw);
  return Object.freeze(parsed) as Money;
}

export const addMoney = (a: Money, b: Money): Money => {
  if (a.currency !== b.currency) throw new Error("currency_mismatch");
  return parseMoney({ amount: a.amount + b.amount, currency: a.currency });
};
```

## Mapping rows / payloads to VOs

Rows from the DB or payloads from an HTTP gateway are **plain primitives**. Convert immediately at the infra boundary:

```ts
// inside credit-card.repository.pg.ts
const row = await db.selectFrom("credit_cards").selectAll().where("id", "=", id).executeTakeFirst();
if (!row) return undefined;

const token = parseCardToken(row.card_token);
const masked = parseMaskedBin(row.masked_bin);

return CreditCard.rebuild({ token, masked, /* ... */ });
```

The entity factory **only ever sees value objects**, never raw row shapes.

## Rules

- A VO has **no identity** and **no `id` field**. If yours does, it's an entity.
- A VO has **no behavior beyond pure functions** of itself (e.g. `addMoney`, `formatCpf`). No I/O, no clock, no random.
- A VO is **frozen** or built from `Readonly<...>` for object shapes; primitives are inherently immutable.
- A VO's factory **throws** on invalid input (or returns `Result` if you prefer; pick one and stay consistent).
- VOs live in `src/<context>/domain/`.

## Anti-patterns

- **A "User VO" with an ID**. Wrong: that's an entity.
- **A `Money` with a setter**. Wrong: VO is immutable; provide pure functions returning new instances.
- **Raw primitive in a function signature for a known concept**: `function transfer(amountCents: number, currency: string)`. Replace with `function transfer(amount: Money)`.
- **Converting at every boundary**. Convert **once** at the edge; pass VOs through internal layers.

## Smells

- A VO that imports a logger, an HTTP client, or a date provider. Pure → no dependencies.
- A VO whose schema is duplicated in two places. There's exactly one schema; types derive from it.
- A "VO-like type" without a brand. Brand it; otherwise the type is structurally identical to `string` and the compiler offers no protection.
