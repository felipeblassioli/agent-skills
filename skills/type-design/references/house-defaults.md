# House defaults (Turbi / `.specify`)

These are the type-*design*-relevant conventions from the team's TS rules. Treat
them as **defaults, not dogma**: apply them unless there's a reason not to, and
when you override one, state the reason in a line of prose or a comment. They are
distilled from `.specify/ts-core-v5.md` — that file is the source of truth for the
full ruleset (including lint/runtime rules this skill deliberately ignores). Only
the choices that shape *type design* are repeated here.

If you're using this skill outside Turbi, skip this file — the principles in
SKILL.md stand alone.

## Absence & nullish

- **One internal nullish: `undefined`.** Treat `null` as foreign. Normalize
  `null → undefined` at the boundary. *Why:* two representations of "missing"
  doubles the branching and invites `x == null` confusion. A DB or wire `null` is
  fine at the edge; it shouldn't survive inward.
- **Model absence explicitly** as `T | undefined` or a distinct union variant —
  never a magic sentinel (`-1`, `''`, `0`, `'none'`) that looks like real data.

## Unions over enums

- **No `enum` / `const enum`.** Use a literal union + `as const` map. *Why:*
  unions are structural, tree-shakeable, and don't create a runtime object with
  surprising reverse-mapping; the map gives you the same lookup with exhaustiveness.

```ts
type Status = 'novo' | 'em_analise' | 'concluido';
const LABEL = { novo: 'Novo', em_analise: 'Em análise', concluido: 'Concluído' } as const;
```

## `type` over `interface`

- Prefer `type`. Use `interface` only for declaration merging or `implements`.
  *Why:* `type` composes (unions, mapped, conditional) uniformly; mixing both
  styles for the same purpose is noise. No `I` prefix on names.

## `satisfies` over `as`

- Prefer `satisfies` for object conformance; **forbid double assertions**
  (`x as unknown as T`). *Why:* `satisfies` checks the value against the type
  while keeping the narrow inferred type; `as` silences the compiler and is where
  wrong assumptions hide. A lone `as` at an untyped-interop edge is OK **with a
  comment on why it's sound**.

## Readonly by default

- Default to `readonly` fields and `ReadonlyArray<T>` params; copy-on-write.
  *Why:* immutability at the type level prevents a whole class of
  spooky-action-at-a-distance bugs and documents that a function won't mutate its
  input. Don't mutate input params.

## Discriminated unions for state

- Model anything with distinct states as a discriminated union (see SKILL.md
  principle + worked example 2). This is the house's default for request/job/UI
  state.

## Brands for invariants

- Use a brand when a primitive carries an invariant or an identity that gets
  confused. Standard helper:

```ts
type Brand<T, B extends string> = T & { readonly __brand: B };
```

  Mint branded values only at the boundary that validates them. Don't brand
  primitives whose confusion isn't real (see worked example 4).

## Boundaries: parse, derive, don't hand-maintain

- **Validate all external input at the boundary** (HTTP, queues, files, env, DB
  reads) with a schema, and **derive the type via `z.infer`** rather than writing
  a parallel `type` by hand. *Why:* one source of truth; the validator and the
  type can't drift.
- Normalize `null → undefined` here too.

## Error model (type shape only)

- **Hybrid:** predictable/recoverable outcomes → a `Result<T, E>` union;
  programmer errors → throw and crash fast. The `Result` shape:

```ts
type Result<T, E extends string> =
  | { ok: true; value: T }
  | { ok: false; code: E; cause?: Error };
```

  *Why (design angle):* a `Result` makes the failure a value the caller must
  narrow — the type forces handling — whereas a throw is invisible in the
  signature. Reserve throws for "this should never happen" bugs. Domain errors
  carry a literal-union `code`, not a free-form string.

## `Promise<void>` on exported APIs

- Avoid `Promise<void>` on exported async APIs; use `Promise<undefined>` if a
  caller might accidentally `await` for a value. *Why:* `void` silently discards a
  returned promise/value at call sites; `undefined` keeps the intent explicit.

## Micro-shapes worth reusing

```ts
type NonEmptyArray<T> = readonly [T, ...T[]];              // "at least one" in the type
const isNonNullish = <T>(x: T): x is NonNullable<T> => x != null;
```

---

Remember the ordering: **principle > house default**. If applying a house rule
would produce a worse-designed or unreadable type (e.g., `no-any` forcing
unreadable generics), the principle in SKILL.md — correctness and clarity per unit
of complexity — wins, and you name the exception.
