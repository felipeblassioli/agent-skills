# HTTP Service Checklist

- [ ] Timeout and cancellation behavior are explicit for downstream calls.
- [ ] Mutating endpoints are safe under client or gateway retries.
- [ ] Idempotency boundary is explicit for irreversible side effects.
- [ ] Health endpoints distinguish readiness, liveness, and startup semantics.
- [ ] Startup behavior uses `startupProbe` or init containers intentionally when initialization is slow.
- [ ] `livenessProbe` is not tied to transient downstream dependency health.
- [ ] `readinessProbe` reflects traffic eligibility and fails during drain when appropriate.
- [ ] Probe handlers are cheap, deterministic, and side-effect free.
- [ ] Shutdown/drain behavior avoids accepting work the instance cannot finish.
- [ ] Dependency failures cannot exhaust the whole service.
- [ ] Rate limiting or throttling is intentional where abuse or bursts matter.
- [ ] Long-running work uses an async `202` pattern when appropriate.
- [ ] Rollout overlap does not break contracts or duplicate critical work.
- [ ] Metrics and logs capture request volume, latency, failures, and saturation.
