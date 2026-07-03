# Pub/Sub Consumer Checklist

- [ ] Ack happens only after durable processing or durable handoff.
- [ ] Duplicate delivery is safe.
- [ ] Idempotency key is explicit and stable.
- [ ] Check-and-write idempotency is atomic.
- [ ] Retryable and permanent errors are separated.
- [ ] Poison messages cannot retry forever.
- [ ] Flow control caps outstanding messages.
- [ ] Flow control caps outstanding bytes.
- [ ] Application concurrency is bounded.
- [ ] Handler timeout is explicit.
- [ ] Shutdown stops new pulls and drains in-flight work.
- [ ] Ordering assumptions are explicit and enforced.
- [ ] Metrics include received, acked, nacked, failed, retried, DLQ, duration, and saturation.
- [ ] Logs include message id / event id / sanitized failure reason.
- [ ] Tests cover duplicate, retry, permanent failure, and shutdown behavior.
