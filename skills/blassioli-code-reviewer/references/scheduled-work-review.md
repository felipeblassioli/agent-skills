# Scheduled Work Review Reference

Use this reference when reviewing Kubernetes `CronJob`s, scheduled backfills, reconcilers, recurring workers, maintenance jobs, or any batch process that may rerun after partial progress.

## Default posture

Treat scheduled work as re-entrant distributed work, not as a one-shot script.

Assume unless proven otherwise:

- Runs can overlap.
- Retries can happen after partial side effects.
- Operators can rerun the job manually.
- Old and new versions can overlap during rollout.
- Batch size can exceed timeout or quota budgets.

## Overlap and singleton semantics

Relevant design lenses:

- `Leader Election`
- `Scheduler Agent Supervisor`

Review:

- Is overlapping execution allowed, forbidden, or harmless?
- If singleton execution matters, what enforces it?
- For Kubernetes `CronJob`, is `concurrencyPolicy` intentional?
- Does rollout create multiple actors that can touch the same work concurrently?

Red flags:

- Singleton assumptions with no lock, lease, or platform enforcement.
- `CronJob` overlap that can double-charge, double-send, or double-write.
- Scheduler semantics delegated to "operators will not click twice."

## Idempotency, checkpoints, and reruns

Review:

- What is the idempotency boundary per item and per whole run?
- Is progress checkpointed so reruns can resume safely?
- Are side effects committed atomically with progress markers where possible?
- Does the job distinguish already-processed work from pending work?

Red flags:

- Restart-from-zero behavior after partial completion with irreversible side effects.
- Batch code that loads all candidates first and blindly applies side effects later.
- "Check then write" dedupe without an atomic boundary.

## Partial failure and compensation

Relevant design lenses:

- `Compensating Transaction`
- `Saga`

Review:

- What happens if the process fails mid-batch?
- Are partial side effects acceptable, compensated, or retried safely?
- Can the next run tell terminal failures from retryable ones?
- Is there an explicit forward-fix or compensation posture for multi-step work?

## Kubernetes CronJob specifics

Review:

- `concurrencyPolicy` is intentional.
- `startingDeadlineSeconds` matches lateness tolerance.
- `backoffLimit`, `activeDeadlineSeconds`, and history limits are intentional.
- Resource requests and limits fit worst-case batch size.
- Logs and metrics let operators distinguish skipped, overlapping, failed, and completed runs.

Red flags:

- Missing history limits on noisy jobs.
- Unlimited retries for permanently bad input.
- Active deadline shorter than normal batch duration.

## Dependency safety and load shape

Relevant design lenses:

- `Bulkhead`
- `Retry`
- `Rate Limiting`
- `Queue-Based Load Leveling`

Review:

- The job cannot exceed downstream quotas during large runs.
- Batch parallelism is bounded explicitly.
- Retries use backoff and jitter where appropriate.
- Work can be chunked or queued when the direct batch would overwhelm dependencies.

## Tests worth asking for

- Rerun after partial completion does not duplicate durable side effects.
- Overlapping runs are blocked or safe.
- Crash after item side effect but before checkpoint is safe.
- Permanent invalid item does not poison the whole recurring job forever.
- Batch concurrency and quota protection behave as intended.
