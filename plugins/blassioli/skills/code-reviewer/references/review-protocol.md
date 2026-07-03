# Review Protocol

## First-principles checklist

Ask these questions in order:

1. What production behavior changed?
2. What contract changed?
3. What data can be lost, duplicated, corrupted, or made inconsistent?
4. What is the idempotency boundary for the logical operation?
5. What prevents two actors from doing the same work concurrently?
6. What happens under retry, timeout, cancellation, redeploy, crash, partial dependency failure, and high load?
7. If old and new versions overlap during rollout, is the work still safe?
8. What is the smallest test that should fail if this change is wrong?
9. What signal will tell operators this failed in production?
10. Is the change reversible?

## Review dimensions

### Correctness

- Domain invariants are explicit.
- Edge cases are handled intentionally.
- Time, randomness, and external dependencies are controlled where determinism matters.
- Error paths preserve state consistency.

### API and contract safety

- Request and response contracts are backward compatible unless a breaking change is explicit.
- Validation rejects invalid state before side effects.
- Error responses are stable enough for callers.
- Idempotency keys, natural keys, or uniqueness constraints exist where retries are expected.

### Concurrency and idempotency

- The review identifies the logical unit of work, not only the transport envelope.
- Duplicate work is safe because the operation is idempotent or guarded by an atomic boundary.
- "Check then write" patterns are treated as races unless the check and write are atomic.
- Cross-pod, cross-instance, and old-version/new-version overlap are considered.
- Singleton assumptions are enforced with a real mechanism when required.
- Batch and retry behavior cannot multiply irreversible side effects silently.
- Partial completion has compensation, checkpointing, or safe re-entry semantics.

Useful reviewer questions:

- What defines "same work" here?
- Can two requests, jobs, or consumers race on the same entity?
- If the process dies after the side effect but before commit/ack/response, what duplicates?
- If deployment creates overlap, can both versions safely process the same input?
- Is the guard local-memory only, or does it survive multi-instance concurrency?

### Persistence and migrations

- Migrations are backward compatible with the currently deployed application.
- Rollout order is safe.
- DDL locks, long-running migrations, and data backfills are considered.
- Constraints match application assumptions.
- Dual-write, backfill, and read-switch plans have verification gates when needed.

### Security

- No secrets in source, logs, metrics, traces, errors, tests, or fixtures.
- Authorization is checked server-side.
- Input is validated at trust boundaries.
- SSRF, path traversal, injection, and confused-deputy risks are considered.

### Observability

- Logs explain decisions without leaking sensitive data.
- Metrics capture counts, latency, failures, retries, drops, and saturation.
- Traces preserve causality across async boundaries where feasible.
- Alerts map to user impact or operator action.

### Testability

- Tests assert observable behavior, not implementation trivia.
- Regression tests exist for bug fixes.
- Integration tests cover database or external contract behavior where unit tests would lie.
- Tests cover duplicate delivery, retry, overlap, or rerun behavior when the workload is distributed or asynchronous.
- Queue consumers include duplicate, retry, poison message, and shutdown cases where feasible.

## Comment style

A good review comment has this shape:

```md
[SEVERITY] This can <specific failure> when <specific condition>.

The code currently <evidence>. If <runtime condition>, then <consequence>.

I would change this by <concrete fix>. At minimum, add a test for <specific case>.
```

Avoid:

- “Maybe consider...”
- “This feels wrong...”
- “Could be better...”
- “Nit:” for anything that can break production.

## Verdicts

Use `BLOCK` when one or more `BLOCKER` findings exist.
Use `CONDITIONAL` when merge is acceptable only after specific `HIGH` or `MEDIUM` fixes.
Use `APPROVE` only when remaining issues are non-blocking and explicitly documented.
