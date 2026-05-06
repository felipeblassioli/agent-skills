# Unit testing

Behavior-first, AAA-structured, deterministic, colocated with the SUT.

## Layout and naming

- The unit test sits **next to** the SUT:
  - `damage-prediction.service.ts`
  - `damage-prediction.service.test.ts`
- Prefer `*.test.ts[x]` for consistency. Use `*.spec.ts[x]` only if the team's BDD style demands it; choose one and stick with it inside a folder.

## AAA + behavior-first

```ts
test("only admins can change user roles", async () => {
  // Arrange
  const user = { id: "any-user-id", role: "admin" } as const; // only relevant fields
  const sut = makeService(/* deps */);

  // Act
  const ok = await sut.changeRole(user.id, "manager");

  // Assert
  expect(ok).toBe(true);
});
```

Rules:

- **One behavior per test.** If the title contains "and", split.
- **Failure messages must read like a sentence.** Descriptive names; full words.
- **Data relevance**: include only fields that matter to the case; default the rest via small builders.
- **Black-box**: assert observable results and published effects; do not assert internal call sequences.

## Builders for variant data

```ts
// test/__helpers__/user.builder.ts
import type { User, UserId } from "@/user/user.entity";

const defaults: Omit<User, "id"> = {
  name: "Test User",
  role: "member",
  createdAt: new Date("2024-01-01T00:00:00Z"),
};

export const aUser = (override: Partial<User> = {}): User => ({
  id: "u_test" as UserId,
  ...defaults,
  ...override,
});
```

Builders compose; fixtures are frozen (see [doubles-taxonomy.md](doubles-taxonomy.md)).

## Determinism

| Source of non-determinism | Fix |
|---|---|
| `Date.now()`, `new Date()` | `vi.useFakeTimers()` with an explicit clock and controlled advancement |
| `crypto.randomUUID()` | Inject the id generator as a dep, or seed it |
| `Math.random()` | Inject or stub at boundary |
| Timezone | All timestamps in UTC; convert at the edge |
| Filesystem ordering | Sort before asserting |
| Map/Set iteration order | Don't depend on order; sort or use `expect.arrayContaining` |
| Network | MSW v2 with `onUnhandledRequest: "error"` |

## What to assert

- **Behavior and types.** Use `expectTypeOf` (`vitest`/`expect-type`) or `tsd` for utility/public-type guarantees:

```ts
import { expectTypeOf } from "expect-type";

test("Result narrows correctly", () => {
  const r = parseEmail("a@b.c");
  if (r.ok) expectTypeOf(r.value).toEqualTypeOf<Email>();
  else expectTypeOf(r.code).toEqualTypeOf<"INVALID_EMAIL">();
});
```

- **DTO exactness** at boundaries (use `toEqual` over `toMatchObject` when you control the full shape).
- **Error codes** rather than error messages (codes are stable; messages drift).
- **Happy + degraded + error paths.** Don't ship a unit test that only covers the happy path.

## Property-based at boundaries

For parsers, normalizers, paginators, encoders/decoders — use `fast-check`:

```ts
import fc from "fast-check";

test("parseCardToken roundtrips with valid input", () => {
  fc.assert(
    fc.property(fc.stringMatching(/^[A-Za-z0-9_-]{20,40}$/), (s) => {
      const t = parseCardToken(s);
      expect(t).toBe(s);
    }),
  );
});

test("parseCardToken rejects invalid input", () => {
  fc.assert(
    fc.property(fc.string({ maxLength: 19 }), (s) => {
      expect(() => parseCardToken(s)).toThrow();
    }),
  );
});
```

## Doubles in unit tests

- **Stubs** for canned responses (gateway returns "REFUSED").
- **Fakes** for in-memory state (in-memory repository, ledger of charges).
- **Spies** only when you must verify an outbound call (rare in unit; usually a sign you should be at integration).
- **Mocks**: avoid. Use only for cross-cutting (logger, metrics) where state verification is impractical.

Build doubles **at edges** (port boundaries: repository, gateway, clock, UUID generator). Do not assert inside doubles.

See [doubles-taxonomy.md](doubles-taxonomy.md).

## No I/O, no globals, no open handles

- No live network. No real DB. No real filesystem beyond `__fixtures__/` reads.
- No `setInterval` left running. Clear timers in `afterEach`.
- No mutable module-scope state. Re-instantiate per test or reset.

Run with open-handle diagnostics locally; fix every cause.

## When a "unit" test grows mocks

If a unit test mocks more than two boundaries to make sense, you've drifted into another layer. Promote it: move repository or route checks to `packages/*/test/integration/` with a `.int.test.ts` suffix, or move deterministic pipeline coverage to `test/contract/` with a `.contract.test.ts` suffix.

## Anti-patterns

- Asserting `expect(repo.save).toHaveBeenCalled()`. Assert that the saved row exists in a fake or that the returned entity reflects the change.
- Snapshot tests for everything. Snapshots are good for stable transport contracts; bad for evolving internal shapes.
- "It works on my machine" timing tests. Use fake timers and advance explicitly.
- Shared `beforeAll` setup that mutates a module-scope variable read by multiple tests. Make it per-test or freeze it.
- Tests that import `prisma` / `axios` directly. Inject the dependency.
