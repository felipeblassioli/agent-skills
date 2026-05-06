# Type-safety checklist

Strict-typing rules applied without exception. Each rule has a one-line rationale and a code form.

## Banned

| Banned | Use instead |
|---|---|
| `any` | `unknown` + narrowing; if external surface, validate then narrow |
| `enum` / `const enum` | literal union + `as const` map |
| `as Foo` (assertion) | `satisfies Foo` for object conformance; `parse`/narrow for unknown input |
| double assertion `as unknown as Foo` | redesign; if truly needed, isolate behind a tiny adapter and document why |
| truthiness on numbers/strings/arrays | explicit: `value !== 0`, `value.length > 0`, `value !== ""` |
| `parseInt(x)` | `parseInt(x, 10)` and check `Number.isNaN` |
| ambient/global augmentation | reviewed `globals.d.ts` only |
| `throw "string"` | `throw new XxxError(message, { cause })` |
| `Promise<void>` on exported APIs | `Promise<undefined>` to prevent silent loss |
| mutating input params | copy-on-write |

## Required

### Single nullish

Internal absence is `undefined`. Treat `null` as foreign and normalize at every edge.

```ts
const normalize = <T>(x: T | null | undefined): T | undefined => x ?? undefined;
```

### Discriminated unions for state

```ts
type FetchState<T> =
  | { status: "idle" }
  | { status: "loading" }
  | { status: "success"; value: T }
  | { status: "error"; code: ErrorCode };
```

Force exhaustiveness with `never`:

```ts
const assertNever = (x: never): never => { throw new Error(`unhandled: ${JSON.stringify(x)}`); };
switch (state.status) {
  case "idle": /* ... */ break;
  case "loading": /* ... */ break;
  case "success": /* ... */ break;
  case "error": /* ... */ break;
  default: return assertNever(state);
}
```

### `readonly` by default

Params and collections accept `ReadonlyArray<T>` / `Readonly<T>`. Return new arrays only when allocating.

### Brands for invariants

```ts
type Brand<T, B extends string> = T & { readonly __brand: B };
type UserId = Brand<string, "UserId">;
```

Brands cannot be created from raw strings without going through a factory; this is the purpose. See [value-objects.md](value-objects.md).

### `as const` for literal configs

```ts
const HTTP_METHODS = ["GET", "POST", "PUT", "DELETE"] as const;
type HttpMethod = (typeof HTTP_METHODS)[number];
```

### `satisfies` over `as`

```ts
const config = {
  retries: 3,
  timeoutMs: 5_000,
} satisfies RetryConfig;
```

### Assertion helpers

```ts
export function invariant(c: unknown, m?: string): asserts c {
  if (!c) throw new Error(m ?? "invariant_failed");
}
export const isNonNullish = <T>(x: T): x is NonNullable<T> => x != null;
```

## Promise hygiene

- **No floating promises.** Every promise must be `await`ed, `return`ed, chained, or explicitly `void`-ed with an internal try/catch.
- **Cancellation**: IO APIs accept `AbortSignal`; document cancellation semantics.
- **Bounded concurrency**: utilities reporting which items failed by index/key.

```ts
void (async () => {
  try { await emitMetric(); } catch (e) { logger.warn({ event: "metric.emit.failed", err: e }); }
})();
```

## Numbers, time, IDs

- Big IDs → `bigint` or `string` (avoid IEEE-754 precision loss).
- Time in code is **UTC**; convert at the edge. Never mix zones silently.
- Always pass radix to `parseInt`; check `Number.isNaN` after numeric coercion.

## Exports

- Prefer named exports. Default exports only at framework boundaries that demand them.
- Barrels (`index.ts`) prefer **type-only re-exports** when possible: `export type { Foo } from "./foo";`.

## Files & identifiers

| Kind | Casing |
|---|---|
| Files | `kebab-case.ts` / `kebab-case.tsx` |
| Types, classes | `PascalCase` |
| Variables, params, functions, methods | `camelCase` |
| Top-level constants and enum-like members | `CONSTANT_CASE` |
| Interface names | **no `I` prefix** (`User`, not `IUser`) |
| Private members | `private` keyword; **no leading `_`** |

## Result for expected failures

```ts
export type Result<T, E extends string> =
  | { ok: true; value: T }
  | { ok: false; code: E; cause?: Error };
```

Use `Result` for predictable/recoverable failures; throw for programmer errors (crash fast). See [error-model.md](error-model.md).

## Common pitfalls

- Re-exporting infra-bound types from a domain barrel. Use type-only re-exports and check the import graph.
- Implicit `any` from third-party SDKs without `.d.ts`. Wrap in a typed adapter.
- Shared mutable state in module scope. Inject via constructor/factory.
