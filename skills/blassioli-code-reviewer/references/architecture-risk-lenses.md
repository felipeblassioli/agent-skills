# Architecture Risk Lenses

Use this reference to sharpen reviews of production behavior. Do not turn the review into a pattern essay. Pick only the lenses that materially change the questions you ask.

## Request-driven services

### `Health Endpoint Monitoring`

Use when readiness, liveness, startup, or shutdown behavior affects traffic handling.

Ask:

- Does readiness reflect traffic eligibility?
- Can probe semantics cause restart storms or black-hole traffic?

### `Circuit Breaker`

Use when a dependency can fail repeatedly and burn resources.

Ask:

- Does the service fail fast when the dependency is unhealthy?
- Are state transitions and fallback behavior observable?

### `Bulkhead`

Use when one hot path or dependency can exhaust shared capacity.

Ask:

- Are pools, concurrency limits, or worker budgets isolated by criticality?
- Can one failing dependency starve unrelated traffic?

### `Retry`

Use when transient failures are expected.

Ask:

- Are retries bounded, backoff-based, and jittered?
- Is the protected operation idempotent?

### `Rate Limiting` / `Throttling`

Use when abuse, bursts, or quota protection matter.

Ask:

- Is overload rejected, queued, or degraded intentionally?
- Do callers get stable signals such as `429` or retry guidance?

### `Asynchronous Request-Reply`

Use when work is too slow or too fragile for a synchronous request.

Ask:

- Should the API accept work durably and return `202`?
- Is there a status or callback path to complete the workflow?

## Queue consumers and event-driven systems

### `Competing Consumers`

Use when multiple workers process the same stream or queue.

Ask:

- Are ordering assumptions compatible with horizontal scale?
- Is duplicate delivery safe?

### `Queue-Based Load Leveling`

Use when queues buffer producer bursts.

Ask:

- Does the queue actually protect the downstream dependency?
- Are backlog growth and saturation visible?

### `Sequential Convoy`

Use when related work must stay ordered but unrelated work can proceed in parallel.

Ask:

- What key defines ordered groups?
- Can this run safely with per-key serialization instead of global serialization?

### `Publisher-Subscriber` / `Choreography`

Use when events trigger downstream reactions across multiple services.

Ask:

- Is the consumer relying on accidental ordering?
- Are downstream contracts, replay behavior, and compensation clear?

## Scheduled work and distributed workflows

### `Leader Election`

Use when singleton work matters.

Ask:

- What enforces one active worker?
- What happens during failover or rollout overlap?

### `Scheduler Agent Supervisor`

Use when a scheduler dispatches work that must be tracked and recovered.

Ask:

- Is progress recorded durably?
- Can failed work be resumed or retried with clear ownership?

### `Compensating Transaction`

Use when multi-step work can partially succeed.

Ask:

- If step 3 fails after step 2 committed, what undoes or forward-fixes the state?
- Are compensation steps themselves idempotent?

### `Saga`

Use when a business workflow spans multiple systems.

Ask:

- Is the choreography or orchestration model explicit?
- Are rollback, retry, and observability paths clear?

## Selection shortcut

Use only the lenses that materially match the workload:

- HTTP service: `Health Endpoint Monitoring`, `Circuit Breaker`, `Bulkhead`, `Retry`, `Rate Limiting`, `Asynchronous Request-Reply`
- Queue consumer: `Competing Consumers`, `Queue-Based Load Leveling`, `Sequential Convoy`, `Retry`, `Compensating Transaction`
- CronJob / batch / reconciler: `Leader Election`, `Scheduler Agent Supervisor`, `Retry`, `Compensating Transaction`, `Bulkhead`

If a lens does not change the review question, do not mention it.
