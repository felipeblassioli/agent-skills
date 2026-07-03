# Kubernetes Runtime Review Reference

Use this reference for queue consumers, long-lived workers, APIs, or services running on Kubernetes, including GKE.

For `Job` and `CronJob` semantics such as overlap, resumability, checkpoints, and rerun safety, also read `references/scheduled-work-review.md`.

## Lifecycle and graceful shutdown

For workers and subscribers, shutdown behavior is correctness logic.

Review for:

- Signal handling for `SIGTERM`.
- Stop accepting new HTTP requests or stop pulling new messages on shutdown.
- Drain in-flight work before exit.
- Bound drain time below `terminationGracePeriodSeconds`.
- Avoid acking messages whose side effects did not complete durably.
- Emit shutdown logs and metrics.

Red flags:

- No signal handling in a long-running consumer.
- `process.exit()` in application paths.
- Kubernetes grace period shorter than maximum handler duration.
- PreStop hook that sleeps without application-level draining.
- PreStop hook that can hang or consume most of the grace period.

## Probes

Readiness is for traffic eligibility. Liveness is for stuck process recovery. Startup is for slow boot.

There is no separate Kubernetes `initProbe`. Initialization concerns belong in `startupProbe` or in init containers, depending on whether the work is application boot versus environment setup.

Review for:

- Readiness fails during shutdown before termination begins, when possible.
- Liveness does not kill a process simply because a dependency is temporarily slow.
- Startup probe exists when boot can exceed liveness thresholds.
- Probe timeouts and thresholds match actual runtime behavior.

Queue consumers need careful probe semantics. A worker can be alive but intentionally not ready to pull new work.

## Resources and concurrency

Review:

- CPU and memory requests exist.
- Limits are intentional, not copy-pasted.
- Subscriber concurrency is compatible with CPU, memory, DB pool, HTTP pool, and downstream quotas.
- Large messages or batches cannot exceed memory limit.
- HPA target signal matches bottleneck.

Red flags:

- High message concurrency with tiny CPU request.
- Memory limit lower than worst-case outstanding message bytes.
- DB pool size smaller than worker concurrency with no queueing discipline.
- HPA scales on CPU only while backlog age grows.

## Rollouts and disruption

Review:

- Rolling update parameters avoid too many concurrent consumers if side effects are expensive.
- PodDisruptionBudget exists for critical workers when appropriate.
- Deployment supports safe drain during node upgrades and rollouts.
- Duplicate consumer overlap is acceptable under idempotency guarantees.

## Security and service identity

Review:

- Workload identity / service account scope is least privilege.
- Secrets are not mounted unnecessarily.
- Network policy or egress controls exist where required.
- Containers avoid privileged mode and unnecessary capabilities.
- Images are pinned or versioned according to repository policy.

## Useful reviewer questions

- During deployment, can old and new versions process the same message safely?
- During node drain, what happens to in-flight messages?
- If the database is slow for 2 minutes, does the pod die, back off, or amplify retries?
- If Pub/Sub backlog spikes, what caps memory and downstream pressure?
- If liveness restarts the process mid-handler, is the side effect idempotent?
