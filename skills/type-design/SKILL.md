---
name: type-design
description: >-
  Design and audit TypeScript types as a modeling discipline — making illegal
  states unrepresentable and encoding domain truth — NOT as a mechanical lint
  pass. Use whenever the user is modeling a new type, reviewing or refactoring
  existing types, or asking whether a type is well shaped: "how should I model
  X", "is this type right", "should this be an enum or a union", "this has too
  many optional/boolean fields", "refactor this stringly-typed code", "review
  the types in this PR/diff", or when a change introduces or reshapes a domain
  model, discriminated union, branded type, or validation boundary. Prefer this
  over ad-hoc type advice: it applies strict-but-not-mindless judgment
  (proportional rigor, no type gymnastics, keep wire/transport concerns out of
  domain types) and produces principle-grounded findings or a designed type
  with its rejected alternatives.
---

# Type Design — modeling, not linting

Types are the cheapest correctness tool you have: a good type deletes a class of
bugs at compile time and doubles as the most honest documentation of the domain.
This skill is about **designing types that make the illegal unrepresentable and
the domain obvious** — and about auditing types against that bar.

It is **not** a lint pass. `no-any`, `prefer-const`, and formatting are a
different job. The questions here are: *does this type let a wrong program
compile? does its shape match the domain's real states? can the next reader
learn the domain by reading it?* A type can be 100% "strictly typed" and still
be badly designed.

## The north star: strict, but not mindless

Two failure modes, equally bad:

- **Too loose** — `any`, `string` for everything, optional-soup, booleans where a
  union belongs. The compiler can't help; bugs ship.
- **Too clever** — conditional-type gymnastics, five-layer generics, brands on
  everything, `unknown`-and-cast theater to satisfy a rule. Nobody can read it;
  it fights the language and the libraries; maintenance stalls.

Good type design lives between these. The goal is **correctness and clarity per
unit of complexity spent**, sized to how much the type matters. Always ask
"what does this buy, and what does it cost the next reader?" — and be willing to
say "the simpler, slightly-looser type is the right call here."

## Two modes

### AUDIT — review an existing or proposed type

Use when handed a type, a diff, or a PR. Protocol:

1. **State the domain truth.** What are the real states/values this thing can
   take? Where does the data come from (wire? DB? internal)? What are the
   invariants (positivity, mutual exclusion, "at least one", ordering-irrelevance)?
2. **Find the gap between the type and the truth.** For each invariant: is it
   in the type, enforced only at runtime, or only in a comment? Can you write a
   well-typed value that is nonsense (`['none','none']`, both-fields-set, empty
   when empty is meaningless)?
3. **Name the smell and the principle it violates** (see catalog below). Not
   "this is bad" — "this leaks a wire concern into the persistence type, so the
   gateway has to reverse-engineer two facts out of one array."
4. **Give the concrete fix** as a type, not prose. Show the shape you'd move to.
5. **Check proportionality and scope.** Is the fix worth it here? Does it drag
   in a repo-wide refactor? If the ideal is out of scope, say so and recommend
   the smallest honest step (often: "make the trade-off explicit in a comment").

Output: findings ordered by leverage, each with *smell → why → fix → scope*.
Ratings (encapsulation, invariant expression, usefulness, enforcement) are
optional aids — use them to force a judgment, not to manufacture rigor. End with
a decisive recommendation, not both-sides hedging.

### DESIGN — model a new type from a requirement

Use when building something new. Protocol:

1. **Enumerate the states/values the domain actually has** — and which
   combinations are legal. This is the whole game.
2. **Pick the representation that makes illegal combos unrepresentable.**
   Discriminated union for "one of N states with different data"; record for
   "independent facts"; brand for "a primitive with an invariant"; literal union
   + map for a closed set.
3. **Site the parse boundary.** Untrusted input (HTTP/queue/env/DB read) gets
   validated once at the edge and narrowed to the clean internal type. Downstream
   code should never re-check what the boundary already guaranteed.
4. **Present the type + the why + the rejected alternatives.** The alternatives
   matter: they show you considered the design space and why the chosen shape wins.
5. **Cost check.** Re-read it as the next maintainer. Too clever? Dial back.

## Core principles (with the why)

- **Make illegal states unrepresentable.** If a value can't legally exist, the
  type shouldn't be able to hold it. This is stronger than validation: validation
  runs once and hopes; the type holds forever, for every caller. When you catch
  yourself writing a runtime guard that "should never happen," ask whether the
  type could have made it impossible.

- **Parse, don't validate.** At a boundary, transform untrusted input into a type
  that *carries the guarantee* (`z.infer` of a schema, a branded value), rather
  than checking-and-passing-through the raw shape. After the boundary, the type is
  proof; nobody downstream repeats the check. A `validate(x): boolean` that
  returns the same wide type it received has thrown away the evidence.

- **Keep boundary concerns out of domain and persistence types.** Wire encodings
  (a `'none'` string because query params can't carry `null`; snake_case DTO
  keys; stringified numbers) belong at the edge. The moment they survive into the
  internal model, every layer speaks the transport dialect and something has to
  translate back. Translate *at the edge*, once, into the domain's own vocabulary.

- **Encode invariants in the type, not in comments.** A comment saying "deduped,
  positive ints, order irrelevant" is a promise the compiler can't keep. Prefer a
  shape where those facts are structural (`Set`-like, brand, boolean-instead-of-
  sentinel). When you truly can't (some invariants need runtime), enforce them
  *at the parse boundary* and give the type the narrowest shape you can.

- **Discriminated unions for states; kill boolean/flag soup.** Three booleans
  encode eight states when the domain has three. `{ status: 'loading' } | { status:
  'ok'; data: T } | { status: 'error'; error: E }` makes `data` reachable only when
  it exists. If several optional fields co-vary ("these three are all set or all
  absent"), that's a union wearing a trench coat.

- **Beat primitive obsession; brand what carries an invariant.** `userId: string`
  and `orderId: string` are swappable by accident. A brand (`UserId = string &
  {__brand}`) makes the mix-up a compile error — *when the confusion is real and
  costly*. Don't brand every string; brand the ones whose identity matters.

- **Model absence explicitly; one nullish.** Decide what "missing" means and use
  one representation for it internally (this codebase: `undefined`; normalize
  `null` at edges). `T | undefined` in the type beats a magic `-1` / `''` /
  `0` sentinel that looks like real data.

- **Single source of truth; derive, don't duplicate.** If two types must agree,
  derive one from the other (`Pick`, `Omit`, `z.infer`, `keyof`) so they can't
  drift. Hand-maintained parallel shapes rot.

- **Make the right thing easy and the wrong thing hard.** The best type is one a
  hurried caller can't misuse. Optional > required-with-a-default-of-undefined;
  a factory that can only produce valid values > a public constructor + a linter
  rule.

## The counterweight — when to stop

Reach for the simpler design when the "safer" one costs more than it saves:

- **Proportional rigor.** A core domain entity, a public API type, or a
  persistence contract earns real investment. A one-off script's local shape, a
  test fixture, or a throwaway does not. Match effort to blast radius × longevity.
- **`any`/escape hatches are sometimes right.** A narrow, commented `any` (or a
  single `as` with a note on why it's sound) can beat a six-line conditional type
  that nobody will maintain. Prefer `unknown`+narrowing; but don't let
  `no-any` push you into worse, unreadable code. The rule serves correctness, not
  the reverse.
- **Don't fight the language or the library.** If a generic helper needs the ORM's
  internal types to stay safe and the result is unreadable, a small amount of
  local looseness (or duplicating a two-line predicate at two call sites) can be
  cleaner than the "DRY, fully-generic" version. Weigh it.
- **Readability is a correctness feature.** A type the team can't read gets
  worked around, and the workarounds are where bugs live. If explaining the type
  takes longer than the code it guards, reconsider.
- **Name trade-offs instead of silently taking the worse path.** When scope,
  consistency-with-siblings, or deadline argues against the ideal shape, the
  senior move is an explicit one-line note ("keeping `Array<number|'none'>` for
  symmetry with `categoryId`; the cleaner shape is `{ids, includeUnassigned}` —
  deferred"), not quietly shipping the smell with no acknowledgment.

## Smell catalog (quick reference)

Each is a *default suspicion*, not a law — the last column is when it's fine.

| Smell | Reach for | Not a smell when |
|---|---|---|
| Wire sentinel (`'none'`, `-1`, `''`) in a domain/DB type | translate at the edge; internal boolean/`undefined`/variant | the type *is* the edge DTO |
| Boolean/flag soup; co-varying optionals | discriminated union | flags are genuinely independent |
| Stringly-typed; interchangeable ids | literal union / brand | truly free-form text |
| Optional-soup (`?` everywhere) | union of variants; required core | fields are independently optional |
| `as` / double assertion / cast theater | `satisfies`, or parse at boundary | interop with untyped lib, commented |
| Illegal states representable (dup, order-noise, both-set) | shape that can't hold them | the illegal value is harmless & rare |
| `enum` / `const enum` | literal union + `as const` map | — (prefer unions here) |
| Invariant only in comment/runtime | encode structurally; else enforce at parse | invariant is genuinely runtime-only |
| Parallel types that must agree | derive (`Pick`/`Omit`/`z.infer`) | intentionally decoupled |
| **Reverse smell:** conditional-type / generic gymnastics, brand-everything | the simplest shape that holds the invariant | the complexity buys a real guarantee |

## References

- `references/worked-examples.md` — before/after redesigns with the reasoning
  (wire-sentinel leak, boolean blindness, state machine, brand, parse-don't-
  validate, and an over-engineered-type walkback). Read for concrete patterns.
- `references/house-defaults.md` — the Turbi / `.specify` conventions this skill
  applies **by default but treats as adjustable** (single nullish, no enums,
  `type` over `interface`, `satisfies` over `as`, `readonly`, brands, `Result<T,E>`
  hybrid, boundary validation via zod). Override any of them *with a stated reason*;
  never cargo-cult them.

The principles are the spine; the house layer is preference. When they conflict,
the principle wins and you say why.
