# Worked examples — redesigns with the reasoning

Each example shows a real shape, the design gap, the redesign, and — crucially —
*why*, plus a note on when the "smell" is actually fine. Read the reasoning, not
just the after-shape; the judgment transfers, the specific type doesn't.

- [1. Wire sentinel leaking into a persistence type](#1-wire-sentinel-leaking-into-a-persistence-type)
- [2. Boolean / flag soup → discriminated union](#2-boolean--flag-soup--discriminated-union)
- [3. Optional-soup request state → parse-don't-validate + union](#3-optional-soup-request-state--parse-dont-validate--union)
- [4. Primitive obsession → brand (when it earns its keep)](#4-primitive-obsession--brand-when-it-earns-its-keep)
- [5. The reverse smell — walking back an over-engineered type](#5-the-reverse-smell--walking-back-an-over-engineered-type)

---

## 1. Wire sentinel leaking into a persistence type

**Context.** A triage endpoint filters alerts by work group. The DB column is
`workGroupId INT NULL`. An HTTP query param can't carry `null` distinctly from
"absent", so the API uses `?workGroupId=none` to mean "match rows where
`workGroupId IS NULL`" (the unassigned bucket), and lets it mix with ids
(`none,3`).

**Before** — the wire sentinel is carried all the way into the internal filter:

```ts
// repository.ts — the persistence-layer filter type
type ListFilters = {
  workGroupIds?: Array<number | 'none'>;   // 'none' is an HTTP encoding
  // ...
};

// gateway — has to reverse-engineer two facts back out of the array
function applyWorkGroupFilter(query, value: Array<number | 'none'> | undefined) {
  if (!value?.length) return query;
  const includeNull = value.includes('none');
  const ids = value.filter((e): e is number => e !== 'none');
  if (!ids.length)      return query.where(col, 'is', null);
  if (!includeNull)     return query.where(col, 'in', ids);
  return query.where(sql`(${ref} in (${sql.join(ids)}) or ${ref} is null)`);
}
```

**The gap.** `'none'` is a *transport* concern (it exists only because query
params can't express `null`). The DB has no `'none'` — the column is `int | null`.
Carrying the string past the HTTP boundary means the persistence type speaks the
transport dialect, and the gateway has to *undo* the encoding (`includes('none')`
+ `filter`) to recover the two orthogonal facts it actually needs: **a set of ids**
and **a boolean "include the unassigned bucket."** Worse, the shape makes illegal
states representable: `['none','none']`, `[3,3]`, and `['none',3]` vs `[3,'none']`
(order is meaningless) are all well-typed; only a `Set` in the schema saves them —
and tests construct the filter directly, bypassing that.

Diagnostic tell: the *gateway* unit tests have to build `['none', 3]` — a wire
concept — to exercise SQL generation. When a layer's tests can't be written
without importing a higher layer's vocabulary, the boundary is in the wrong place.

**After** — translate at the edge; internal type carries the two real facts:

```ts
// internal type — two independent facts, no transport sentinel
type ListFilters = {
  workGroupIds?: { ids: number[]; includeUnassigned: boolean };
  // ...
};

// at the HTTP boundary (zod transform) — 'none' dies here, once:
//   'none'  -> includeUnassigned = true
//   digits  -> ids
// gateway now just reads two fields — no sentinel hunting:
function applyWorkGroupFilter(query, f: ListFilters['workGroupIds']) {
  if (!f || (!f.ids.length && !f.includeUnassigned)) return query;
  if (!f.includeUnassigned) return query.where(col, 'in', f.ids);
  if (!f.ids.length)        return query.where(col, 'is', null);
  return query.where((eb) => eb.or([eb(col, 'in', f.ids), eb(col, 'is', null)]));
}
```

**Why it's better.** The `IS NULL` concern is now *structurally* separate from the
id set — exactly the two facts the SQL needs. `includeUnassigned` is a boolean, so
`['none','none']` is unrepresentable. The edge does the translation once. And the
mixed branch can use the ORM's expression builder (`eb.or([...])`), which is fully
parameterized — so the raw `sql`/`sql.ref` escape hatch and its injection-guard
machinery disappear. Gateway tests now read `{ ids: [3], includeUnassigned: true }`
— the persistence vocabulary.

**When the before is acceptable.** If `ListFilters` *is* the edge DTO (no separate
internal model) and the endpoint is tiny, the sentinel array is a defensible
shortcut — name it. Also weigh consistency: if sibling scalar filters
(`categoryId?: number | 'none'`) already use the sentinel, changing only this one
field is right, but refactoring all of them is a separate, bigger change — don't
smuggle it in.

---

## 2. Boolean / flag soup → discriminated union

**Before** — four booleans encode 16 combinations for a domain with 3 states:

```ts
type Upload = {
  isPending: boolean;
  isComplete: boolean;
  isFailed: boolean;
  url?: string;      // present iff isComplete
  error?: string;    // present iff isFailed
};
```

**The gap.** `{ isComplete: true, isFailed: true }` is legal. `url` and `error`
float free of the flag that justifies them, so every reader guesses which
combinations are real, and `upload.url!` (the bang) spreads like mold.

**After:**

```ts
type Upload =
  | { status: 'pending' }
  | { status: 'complete'; url: string }
  | { status: 'failed'; error: string };
```

**Why.** `url` is reachable only after narrowing `status === 'complete'`; the
compiler enforces the co-variance the comments used to beg for. Three states,
three variants, zero impossible combinations. A `switch (u.status)` can be made
exhaustive.

**When flags are fine.** If the booleans are genuinely independent —
`{ isPinned; isArchived; isMuted }` on a conversation, where any subset is legal —
they are *not* soup; a union would be wrong (it'd force a false one-of-N).

---

## 3. Optional-soup request state → parse-don't-validate + union

**Before** — a validator that checks and hands back the same wide type:

```ts
type RawQuery = { plates?: string; recentMinutes?: string };

function isValid(q: RawQuery): boolean {          // returns a boolean, discards proof
  return (!!q.plates) !== (!!q.recentMinutes);    // exactly one required
}
// callers still hold RawQuery and must re-check / re-parse everywhere
```

**The gap.** `isValid` proves something then throws the proof away — downstream
still sees `plates?: string` and re-parses. The "exactly one of" invariant lives
in a comment.

**After** — parse into a type that carries the guarantee:

```ts
const QuerySchema = z.union([
  z.object({ mode: z.literal('plates'), plates: z.array(Plate).min(1) }),
  z.object({ mode: z.literal('recent'), recentMinutes: z.number().int().positive() }),
]);
type Query = z.infer<typeof QuerySchema>;   // one-of-N, guaranteed
```

**Why.** After `QuerySchema.parse(input)` at the edge, the internal `Query` type
*is* the proof: exactly one mode, its field present and well-formed. No downstream
re-checking, no optional-soup, no comment-only invariant. The boundary is the only
place that touches raw input.

---

## 4. Primitive obsession → brand (when it earns its keep)

**Before:**

```ts
function transfer(from: string, to: string, amount: number): void
transfer(orderId, userId, cents);   // args silently swapped — compiles fine
```

**After** — brand the identities whose confusion is real and costly:

```ts
type UserId  = string & { readonly __brand: 'UserId' };
type OrderId = string & { readonly __brand: 'OrderId' };
// minted only at the boundary that knows the value is valid:
const asUserId = (s: string): UserId => s as UserId;

function transfer(from: OrderId, to: UserId, amount: Cents): void
// transfer(orderId, userId, ...) now type-errors on a swap
```

**Why.** The brand turns an easy, expensive runtime bug (paying the wrong account)
into a compile error, at near-zero cost. It also documents intent: a function
taking `UserId` announces what it needs.

**When NOT to brand.** Don't brand every string. Brand identities that get mixed
up, or primitives with a validated invariant (`Email`, `NonEmptyString`, `Cents`).
A one-caller local string doesn't need ceremony — that's brand-everything noise,
the reverse smell.

---

## 5. The reverse smell — walking back an over-engineered type

Type design also means knowing when you've gone too far. The instinct to eliminate
every `any` and encode every invariant can produce types that cost more than the
bug they prevent.

**Over-engineered:**

```ts
// "type-safe" event map with recursive conditional payload inference
type EventName = `${Domain}.${Action}.${Version}`;
type PayloadFor<E extends EventName> =
  E extends `${infer D}.${infer A}.${infer V}`
    ? D extends keyof Registry
      ? A extends keyof Registry[D]
        ? Registry[D][A] extends { v: V } ? Registry[D][A]['payload'] : never
        : never
      : never
    : never;
```

**The problem.** Three levels of `infer`, a `never` maze, and a compile error
message no one can decode. It technically prevents mistyped payloads — but the
team now fears touching events, and the error messages send people to Stack
Overflow. The complexity outran the value.

**Walked back:**

```ts
type AppEvent =
  | { name: 'user.created';  userId: UserId }
  | { name: 'order.shipped'; orderId: OrderId; at: string };

function emit(e: AppEvent): void   // exhaustive, readable, still fully safe
```

**Why the simpler one wins.** A plain discriminated union gives the same
guarantee (payload matches name), narrows cleanly, produces legible errors, and
anyone can add a variant. It sacrifices the auto-derived template-literal names —
a feature nobody needed enough to pay that readability tax for.

**The lesson.** Before shipping a clever type, re-read it as the next maintainer
and ask: *what real bug does the extra complexity prevent, and is that bug
likely/costly enough to justify the reading cost?* If the answer is thin, the
simpler shape is the better-designed one. Strict is not the same as clever.
