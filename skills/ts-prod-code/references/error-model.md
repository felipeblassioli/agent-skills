# Error model

Uniform, typed, layer-aware error handling that integrates with logging, tracing, and HTTP/gRPC mapping.

## The hybrid rule

| Failure kind | Mechanism |
|---|---|
| **Predictable / recoverable** (business rule violated, gateway refused, validation failed) | Return `Result<T, E>` from the function |
| **Programmer error / defect** (invariant broken, deserialization bug, unreachable branch) | **Throw** (crash fast; let the global boundary handle it) |

Mixing both in the same public contract is forbidden.

## Error categories by layer

| Category | Created in | Surfaced by | Typical HTTP | Log level | Alert |
|---|---|---|---|---|---|
| `DomainError` (business rule violated) | Domain (entity, policy) | Application service | 4xx (409, 422) | INFO/WARN | No |
| `ApplicationError` (orchestration/policy failure: saga timeout, outbox max retries) | Application service | API/adapter | 4xx or 5xx | WARN | SLO threshold |
| `RecoverableInfrastructureError` (transient I/O, rate-limit, timeout) | Infrastructure adapter | Application service | 503 / 504 | ERROR | SLO threshold |
| `FatalSystemError` (bug, data corruption, invariant broken) | Any layer | Global boundary | 500 | ERROR | **Always page** |

### Domain errors — never throw

```ts
// In the domain or application layer
return err(new CardUnavailableError({ cardId }));
```

Each subclass has a static `CODE`. They are **expected** failures (part of the ubiquitous language).

### Application errors

Created when higher-level coordination fails. Either propagate via `Result` or remap into a `DomainError` once the concept becomes part of the domain language.

### Recoverable infrastructure errors

Wrap raw SDK/DB/HTTP exceptions. Retries, exponential back-off, and circuit-breaking belong **inside** the gateway/repository. Alert when the **retry budget is exhausted**.

### Fatal system errors

Truly unexpected (assertion failure, deserialization bug). **Throw**, let the global boundary emit `500`, page on-call.

## `BaseError` template

```ts
// shared/base-error.ts
export abstract class BaseError extends Error {
  abstract readonly code: string;
  readonly context?: Record<string, unknown>;
  override readonly cause?: unknown;

  constructor(message: string, context?: Record<string, unknown>, cause?: unknown) {
    super(message, { cause });
    this.context = context;
    this.cause = cause;
  }

  rootCause(): unknown {
    let current: unknown = this;
    while (current instanceof Error && (current as { cause?: unknown }).cause) {
      current = (current as { cause?: unknown }).cause;
    }
    return current;
  }
}
```

Concrete errors extend `DomainError`, `ApplicationError`, etc., each with a **static `CODE`** constant:

```ts
export class CardUnavailableError extends DomainError {
  static readonly CODE = "CARD_UNAVAILABLE";
  readonly code = CardUnavailableError.CODE;

  constructor(context: { cardId: string }, cause?: unknown) {
    super("card is not available", context, cause);
  }
}
```

## Result type

```ts
// shared/result.ts
export type Result<T, E extends string> =
  | { ok: true; value: T }
  | { ok: false; code: E; cause?: Error };

export const ok = <T>(value: T): Result<T, never> => ({ ok: true, value });
export const err = <E extends string>(code: E, cause?: Error): Result<never, E> => ({ ok: false, code, cause });
```

Or use `neverthrown`'s `Result<T, E>` if you prefer its combinators (`.map`, `.andThen`, `.mapErr`).

## Cause chaining

Always preserve the original fault:

```ts
catch (sdkErr) {
  throw new GatewayTimeoutError({ vendor: "adyen", endpoint: "/tokenise" }, sdkErr);
}
```

The `cause` chain enables `rootCause()` to walk back to the original SDK error for dashboards that answer *"why did booking attempts fail?"*.

## Translation across layers

**One translation per boundary**. Don't rethrow within the same layer.

| Boundary | Translation |
|---|---|
| Infrastructure → Application | Wrap SDK error in `RecoverableInfrastructureError` (or domain `Result.err` if known business meaning) |
| Application → Domain | If a recoverable error becomes a known domain concept, map to `DomainError` |
| Application → Presentation (controller) | Map `Result.err` / domain error → HTTP status + body. **Do not rethrow** within the controller. |

## HTTP mapping (inbound REST/GraphQL)

| Error class | Default status | Response body |
|---|---|---|
| `DomainError` | 409 / 422 | `{ code, message, context }` |
| `ApplicationError` | 400 – 5xx | `{ code, message, context, retryable?: true }` |
| `RecoverableInfrastructureError` | 503 / 504 | `{ code, message }` |
| `FatalSystemError` | 500 | `{ code: "INTERNAL_ERROR", message: "Unexpected" }` |

**Never** include `stack`, `cause`, or internal hostnames in public responses. Internal callers (mTLS) may opt-in via header `X-Debug-Error: true`.

## One throw → one log

The boundary that surfaces the error to the user/client logs it **once**. Lower layers do not log; they wrap and propagate. See [observability.md](observability.md).

## Operational checklist

1. New aggregate rule? → Create a `DomainError` subclass with a static `CODE`.
2. Calling external I/O? → Wrap SDK error in `RecoverableInfrastructureError`; retry inside the gateway.
3. Escalating across layers? → Wrap prior error in `cause`; translate category if needed.
4. Boundary adapter (HTTP, gRPC, pub/sub)? → Map `Result` or `BaseError` to the proper status/body.
5. Logging serializer outputs `code`, `message`, `context`, `rootCode`, `rootMessage`, `traceId`, `spanId`.
6. Code review must flag any `throw new Error(...)` in domain or application layers.

## Anti-patterns

- **`throw "card not found"`** → throw an `Error` subclass with `code` and `cause`. Never strings.
- **Mixing `throw` and `Result` in the same public function**. Pick one.
- **Logging at every layer**. Each error gets exactly one log entry, at the surfacing boundary.
- **Discarding `cause`** when wrapping. Always pass the original error in.
- **Generic 500 for known business failures**. Map domain failures to 4xx.
- **Returning `Result<T, Error>`** with an unconstrained error type. Use a **literal-union code** (`Result<T, "REFUSED" | "TIMEOUT">`).

## Further reading

- TC39 — ECMAScript 2022 `Error.cause`.
- `neverthrown` — [https://github.com/supermacro/neverthrow](https://github.com/supermacro/neverthrow)
- Evans, *DDD*: Layered Architecture, Supple Design.
- Vernon, *Implementing DDD*: Notification & Exception Styles.
- Fowler, *POEAA*: Circuit Breaker, Retry.
