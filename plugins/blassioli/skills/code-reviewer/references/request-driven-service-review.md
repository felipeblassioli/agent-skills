# Request-Driven Service Review Reference

Use this reference when reviewing HTTP APIs, internal services, Cloud Run request handlers, webhook receivers, or request/response application boundaries.

## Default posture

Treat a request-driven service as a distributed boundary, not just as routing code.

Review for:

- Timeout budgets across client, gateway, service, and downstream calls.
- Retry amplification from clients, load balancers, SDKs, or background retries.
- Idempotency for mutating endpoints that callers may retry.
- Backpressure, rate limiting, or bulkheads protecting critical dependencies.
- Health endpoint semantics that reflect readiness without causing restart storms.
- Long-running work that should use an async `202 Accepted` plus status pattern instead of holding the request open.

## Idempotency and retries

Review:

- Which operations can be retried by clients or intermediaries?
- Is there an idempotency key, natural key, or uniqueness constraint for mutating endpoints?
- Are downstream side effects also protected against duplicates?
- Does the code assume a single request attempt when the platform may retry?

Red flags:

- `POST` or webhook handlers with irreversible side effects and no idempotency boundary.
- Local in-memory dedupe in a horizontally scaled service.
- Retry around non-idempotent dependency calls without protection.
- Returning success before durable state is committed.

## Timeouts, bulkheads, and dependency safety

Relevant design lenses:

- `Circuit Breaker`
- `Bulkhead`
- `Retry`
- `Rate Limiting`
- `Throttling`

Review:

- Every dependency call has an explicit timeout or cancellation path.
- Slow dependencies do not exhaust worker pools, DB pools, or request concurrency.
- Retries distinguish transient from permanent failures.
- Backoff and jitter exist where the client controls retries.
- Resource isolation prevents one dependency failure from saturating the whole service.

Questions:

- If the database or an external API is slow for 2 minutes, what gets exhausted first?
- Does retry make user impact smaller, or does it multiply load on a failing dependency?
- Are there per-route or per-tenant rate limits where abuse or bursts matter?

## Health endpoints and probes

Relevant design lens: `Health Endpoint Monitoring`

Review:

- Readiness indicates traffic eligibility, not "every dependency is perfect."
- Liveness only detects stuck or unrecoverable processes.
- Startup behavior is handled explicitly when boot, cache warm-up, migrations, or dependency priming can exceed normal liveness thresholds.
- Shutdown causes readiness to fail before the process is terminated, when possible.
- Health endpoints do not expose sensitive internal details.

Best-practice posture for HTTP services on Kubernetes:

- `readinessProbe` answers "should this instance receive traffic now?"
- `livenessProbe` answers "is this process wedged badly enough to restart?"
- `startupProbe` is the right mechanism when initialization is slow. There is no separate Kubernetes `initProbe`; initialization logic belongs in a startup probe or an init container, depending on the need.
- Readiness should usually fail during drain or startup until the service can safely serve requests.
- Liveness should not depend on transient downstream health such as a briefly slow database or third-party API.
- Probe handlers should be cheap, deterministic, and free of side effects.
- If probes hit application routes, they should bypass expensive middleware and not require user auth.
- Thresholds should reflect real warm-up and recovery behavior instead of copy-pasted defaults.

Red flags:

- Liveness probes tied to transient dependency health.
- Readiness staying green while the service is intentionally draining.
- No startup probe when boot or warm-up can be slow.
- Probe endpoints that perform expensive dependency fan-out on every check.
- Probe behavior that can trigger restart loops during cold start or dependency recovery.
- Readiness depending on optional dependencies that should degrade gracefully.

## Asynchronous request-reply

Relevant design lens: `Asynchronous Request-Reply`

Ask whether long-running or quota-sensitive work should be split into:

- `202 Accepted`
- status endpoint or callback/webhook
- durable job state
- correlation id

Red flags:

- Request handlers waiting on long-running batch work.
- HTTP timeouts hiding work that continues after the client gave up.
- No way for callers to learn terminal status after accepted async work.

## Rollouts and overlap

Review:

- Old and new versions can coexist safely during rollout.
- Schema or contract changes are compatible during overlap.
- Duplicate submissions from retries or double-clicks remain safe.
- Webhook consumers tolerate replay and redelivery.

## Tests worth asking for

- Mutating endpoint retry produces one durable side effect.
- Dependency timeout or transient failure returns the intended error behavior.
- Rate limit or backpressure behavior is observable and stable.
- Shutdown or rollout overlap does not lose or duplicate critical work.
- Async `202` flow persists job state durably and reports status correctly.
