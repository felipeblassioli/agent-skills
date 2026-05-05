# Google Pub/Sub Consumer Review Reference

Use this reference when reviewing Pub/Sub subscribers, queue consumers, async workers, Cloud Run handlers receiving Pub/Sub push messages, or code using `@google-cloud/pubsub`, Google Cloud Pub/Sub clients, or equivalent libraries.

## Default delivery model

Unless the code and subscription configuration prove a stronger guarantee, assume at-least-once delivery and no ordering guarantee. A subscriber must tolerate duplicate messages. A message can be redelivered even after an ack request appears to succeed due to server-side or client-side issues.

Review implication: every side effect must be idempotent or guarded by an idempotency boundary.

## Ack and processing order

Required invariant:

```text
receive -> validate -> perform durable idempotent side effects -> commit processing result -> ack
```

Reject patterns:

```text
receive -> ack -> process
receive -> start async work -> ack before awaiting durable result
receive -> process external side effect -> crash before idempotency record
```

Acceptable alternatives:

- Ack after a durable outbox/inbox record is committed.
- Ack after storing a job for a separate durable processor, if that processor has its own idempotency and retry model.
- Nack or let ack deadline expire for transient failure, with bounded retry and poison-message handling.

## Idempotency review

Look for one of these boundaries:

- Unique constraint on message id, event id, business id, or idempotency key.
- Inbox table recording processed events with status and timestamps.
- Upsert / compare-and-set behavior that makes repeated application safe.
- External API idempotency key when calling third-party systems.
- Deterministic output key for object storage or BigQuery writes.

A function is not idempotent merely because it “checks first” unless the check and write are atomic.

Questions:

- What key defines “same work”?
- Is the key stable across publisher retries?
- Is the key business-level rather than transport-only when needed?
- Is the idempotency record written in the same transaction as the side effect when possible?
- What happens if the worker crashes after the side effect but before ack?

## Backpressure and flow control

Review subscriber configuration for:

- Maximum outstanding messages.
- Maximum outstanding bytes.
- Application-level concurrency limit.
- Per-message timeout / cancellation.
- Memory growth when large messages arrive.
- CPU saturation under batch processing.

Flow control is not optional decoration. Without it, a worker can pull more messages than it can safely process, causing deadline expirations, duplicate work, memory pressure, and retry storms.

Reject patterns:

- Unbounded `Promise.all(messages.map(...))`.
- Pull loop without outstanding message cap.
- Subscriber concurrency greater than database connection pool capacity.
- Large message handling without byte-based flow control.
- Autoscaling used as the only backpressure mechanism.

## Ack deadline and lease management

Review:

- Does processing normally finish within the ack deadline?
- Does the client library extend deadlines automatically?
- Is maximum processing time bounded below the maximum lease extension?
- Are long-running jobs split into smaller units or persisted before ack?
- Does the worker handle context cancellation and shutdown?

A long-running handler with no bounded lease model is a duplicate-work machine wearing a polite hat.

## Retry and poison messages

Review:

- Which errors are retryable vs permanent?
- Are validation errors acked, dropped to DLQ, or recorded as terminal failures?
- Is there a dead-letter topic or max delivery attempts where appropriate?
- Does retry include jitter/backoff where the client controls retry?
- Are poison messages observable by message id, event type, and failure reason?

Avoid infinite hot-loop retries for permanent invalid messages.

## Ordering

Pub/Sub does not provide ordering by default. Ordering requires explicit ordering keys and regional constraints. Review whether the code assumes ordered delivery accidentally.

Red flags:

- Updating aggregate state by applying deltas without version checks.
- Assuming “create” arrives before “update”.
- Using message publish time as business truth.
- No sequence number, version, or monotonic guard where order matters.

## Exactly-once delivery

Exactly-once delivery, when configured and supported by the client/library/runtime, narrows delivery behavior but does not remove the need to reason about idempotent side effects. External systems, databases, HTTP APIs, and storage writes still need their own idempotency contracts.

Review implication: do not let “exactly once” become a magic spell sprayed over non-transactional side effects.

## Observability for subscribers

Require useful signals:

- Messages received, acked, nacked, failed, dead-lettered.
- Processing latency by message type / handler.
- Retry count / delivery attempt if available.
- Oldest unacked message age or backlog age.
- Flow-control saturation.
- Handler timeout count.
- Shutdown drain success/failure.

Logs should include correlation identifiers, message id, event id, ordering key when present, delivery attempt when available, and sanitized failure reason.

## Tests worth asking for

- Duplicate delivery produces one durable side effect.
- Crash/retry window after side effect is safe.
- Permanent invalid message does not retry forever.
- Transient dependency failure retries without acking.
- Handler respects concurrency limit.
- Shutdown stops new pulls and drains in-flight messages.
- Out-of-order messages are rejected, buffered, or version-guarded when order matters.
