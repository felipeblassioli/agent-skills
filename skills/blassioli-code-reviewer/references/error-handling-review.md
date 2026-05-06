# Error Handling Review Reference

Use this reference when the change adds, modifies, or alters error paths — exception throws, error returns, retry logic, error logging, error responses, or process-exit calls.

This reference is framework- and language-neutral. It defines a taxonomy and a set of review questions, not a specific implementation.

## Default posture

Treat every catch block, every error return path, and every retry as a place where the wrong decision is the actual production bug.

The reviewer's job is to ensure each error is:

1. Correctly **classified** (failure vs defect vs fatal).
2. Correctly **handled** (recovered, propagated, or process-killed).
3. **Actionable** to the audience that will read it (caller, operator, on-call).

## The three-layer error model

Inspired by ZIO. Use these labels in review comments so the author and the reviewer share a vocabulary.

### `Failure` — expected, recoverable

The code knew this could go wrong. The error is part of the domain or boundary contract.

Examples:

- Validation rejected user input.
- A unique constraint was violated.
- A downstream HTTP API returned `429` or `503`.
- An optimistic-lock conflict.
- A business rule rejected the operation.

Posture:

- Should be **handled at the appropriate layer** — usually the layer that knows what to do.
- Must **not be retried blindly across all error classes** — only retry on transient subtypes.
- Must be **classified into stable buckets** at the boundary (validation / auth / conflict / dependency / rate-limit / not-found / etc.).
- Must **carry enough context** for the caller to act.

### `Defect` — unexpected, programmer error or invariant violation

The code did not expect this. It indicates a bug, a violated invariant, or a state the code believed unreachable.

Examples:

- An exhaustive `switch` hit the impossible default branch.
- A non-null field came back `null`.
- An array index was out of bounds where invariants should have prevented it.
- An assertion failed.
- A library threw a kind of exception that contradicts its contract.
- A migration left data in a state the application cannot represent.

Posture:

- Must **propagate up the stack** without being silently swallowed or downgraded to a generic failure.
- Must **not be retried** — retrying a defect is the bug.
- Must produce a **distinct error class / code** so it shows up separately in monitoring.
- May be converted to a failure **only at a layer that has explicit semantics for it** (for example, a request handler returning `500 Internal Server Error` with a stable error code while logging the full defect).
- Must be **paged on volume**, because volume of defects indicates a real bug, not noisy users.

### `Fatal` — catastrophic, the process must die

The process cannot reasonably continue. Continuing would corrupt data, mislead operators, or amplify damage.

Examples:

- Required configuration is missing or malformed at boot.
- Cryptographic primitive failed self-test.
- The data store is in a state the application cannot reconcile (schema drift, corrupted index).
- An OOM-style condition where partial recovery is unsafe.
- A panic from a critical subsystem that the application has no plan for.

Posture:

- Should **kill the process immediately** after the minimum amount of safe cleanup.
- Before exit: flush logs and metrics, stop accepting new work, **do not ack in-flight queue messages whose side effects did not complete**, release leases / locks if possible, write a stable shutdown reason.
- Use **non-zero exit codes** so the orchestrator (Kubernetes, Cloud Run, supervisord) restarts cleanly.
- Should **not be caught and logged-then-ignored** anywhere in the stack.
- Fatal at boot is normal and good. Fatal mid-flight is rare and must be deliberate.

## Actionability test

For every new or modified error path, ask: who reads this, and can they act on it?

The "5 W's" of an actionable error:

1. **What** failed (operation name, business action).
2. **Which** entity / subject (id, kind), with cardinality bounded for metric labels.
3. **Why** (error class + sanitized cause), retryable-or-terminal classification.
4. **What to do next** (caller-side: retry / fix input / contact support; operator-side: runbook link).
5. **How to correlate** (request id, trace id, message id, user id where appropriate and PII-safe).

Audience-specific rules:

- **Errors returned to API callers**: stable error codes, no internal details (stack traces, SQL, file paths), `Retry-After` for rate limits, idempotency-friendly semantics for retries.
- **Errors logged for operators**: full sanitized context (sanitize PII, secrets, tokens), correlation ids, error class as a stable label, terminal vs retryable explicit.
- **Errors surfaced in dashboards / alerts**: aggregate by error class, not by raw message; alert on rate / proportion, not single events (unless the error is by design rare).

## Retry classification

Retry is a per-error-class decision, not a per-call decision.

Ask:

- Which error classes are retryable (transient: timeout, connection reset, `5xx`, `429`, optimistic-lock conflict)?
- Which error classes are terminal (validation, auth, not-found, defect, business-rule rejection)?
- Is there a **retry budget** per logical operation — total attempts, total time, capped by jittered backoff — that prevents amplification?
- Are retries safe under **idempotency** (see `data-integrity-review.md` for outbox / inbox / dedupe)?
- Does the retry distinguish **client-controlled** retries (caller decides, server should be safe) from **server-controlled** retries (queue / worker / scheduler decides)?

Red flags:

- `for (let i = 0; i < N; i++) { try { ... } catch { ... } }` retrying every exception class.
- Retries on `4xx` other than `408` / `409` / `429`.
- Retrying defects (a `NullPointerException` is not a transient failure).
- No backoff / no jitter — retry storms on dependency recovery.
- Retry budget per call instead of per logical operation, so two layers stack their retries (3 × 3 = 9 total attempts).
- Infinite retry loops on permanently invalid input (poison messages, see `pubsub-consumer-review.md`).

## Boundary translation

Every layer that crosses a boundary should **translate** errors into vocabulary the next layer understands. Never bubble raw infrastructure errors past a layer that has language for them.

Boundaries:

- DB driver → repository / DAL: a `unique_violation` becomes a domain `Conflict` or returns a typed sentinel.
- Repository → application service: persistence-layer language is hidden; the service speaks domain.
- Application service → HTTP handler: domain failure becomes a stable HTTP status + error code envelope.
- Library exception → caller: never expose third-party exception types in public APIs.
- Foreign HTTP error → adapter: `503` becomes a typed `DependencyUnavailable` failure with retry hints.

Ask:

- Is each layer's error vocabulary explicit in its return type / thrown type / contract?
- Does the translation preserve enough information for the next layer (cause chain, error class, retryable flag)?
- Are defects still recognizable as defects after translation, or do they get downgraded to generic failures?

Red flags:

- HTTP `500` envelope containing the raw SQL error.
- Domain service throwing the database driver's exception type.
- Library exception caught and re-thrown as `Error("something went wrong")`.
- Retryable hint lost across the translation (transient `503` upstream becomes a generic terminal error downstream).

## Anti-patterns

The catch-block smells that turn defects into silent corruption:

- `catch (e) { log(e) }` with no rethrow, no recovery, and no decision recorded — silently swallowing.
- `catch (e) { return null }` or `return undefined` — null-poisoning the caller.
- `catch (e) { throw new Error(e.message) }` — losing the cause chain and the original class.
- Top-level `catch-all` that converts every exception into the same generic `500` envelope, including defects and fatals.
- `try { ... } catch (e) { /* TODO */ }` empty catch.
- Retry-on-everything wrapper functions.
- `process.exit(0)` on error — orchestrator sees success, no restart, work is lost.
- Throwing strings or plain objects instead of typed errors with a stable class.
- Error messages built by string concatenation with raw user input — high-cardinality metric labels and PII leaks.

## Process-exit discipline

`process.exit()` / `os.Exit()` / `panic()` are correctness primitives, not debugging tools.

Acceptable:

- At boot, when required config is missing or malformed (fatal at boot is the right behavior).
- When a fatal condition makes continuing unsafe.
- After a clean shutdown sequence completes (typically `exit(0)`).

Not acceptable:

- Inside a request handler to "give up" on a request.
- Inside a queue handler instead of returning / nacking the message.
- Inside a library function — only the application top level decides whether to die.
- With exit code `0` on error — the orchestrator must see failure to restart.

When the application must die mid-flight:

- Stop pulling new work first (readiness off, subscriber paused).
- Drain in-flight work where safe; abandon (do not ack) where not.
- Flush logs / metrics / traces.
- Release distributed locks / leases if possible.
- Exit with a non-zero code that operators recognize.

## Tests worth asking for

- A defect (impossible-state branch, invariant violation) produces a distinct error class and is **not** retried.
- A transient dependency failure is retried within budget and then becomes terminal.
- Validation errors are returned without retry and without internal detail leakage.
- A fatal at boot exits non-zero with a stable shutdown log line; no partial work was started.
- Catch-all top-level still logs defects as defects, not as generic failures.
- Boundary translation: a DB unique-violation surfaces as a domain `Conflict`, not as a 500.
- Retry budget: nested retries do not multiply across layers.

## Cross-references

- API envelope shape and stable error taxonomy: `cross-cutting-review.md` (`Error Model Design`).
- Retryable vs terminal in queue handlers: `pubsub-consumer-review.md`.
- Retryable vs terminal in webhooks: `webhook-review.md`.
- Logs and metrics for errors: `observability-review.md`.
- Idempotency posture under retry: `data-integrity-review.md`.
