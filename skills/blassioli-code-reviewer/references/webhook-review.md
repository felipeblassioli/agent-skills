# Webhook Review Reference

Use this reference when the change adds, modifies, or operates webhook endpoints — either receiving from a third party (Stripe, GitHub, Pub/Sub push, etc.) or emitting to customer / partner endpoints.

Webhooks are HTTP, but they have unique constraints. Reviewing them as plain HTTP misses the most common bugs.

## Default posture

Treat webhooks as adversarial, retrying, out-of-order, possibly-replayed traffic. Treat outgoing webhook endpoints as untrusted, slow, sometimes hostile.

## Incoming webhooks

### Authenticity

Ask:

- Is the request signature verified (HMAC, JWT, OIDC token, mTLS) before any business logic?
- Is the signing secret rotation path documented? Can the verifier accept multiple active keys during rotation?
- Is the request body verified against the signed body, not a re-serialized representation?
- Is the timestamp included in the signed payload, with a tolerance window to reject replay?
- Are production and test signing secrets isolated?

Red flags:

- Signature verification done after parsing, deserialization, or any side effect.
- Body re-encoded before HMAC computation.
- No replay window — old signed payloads accepted indefinitely.
- Signing secret in source code or shared across environments.

### Idempotency and replay

Most providers retry. Receivers must tolerate duplicate delivery.

Ask:

- Does the receiver dedupe by event id from the provider?
- Is the dedupe record committed in the same transaction as the side effect, or in a clearly atomic boundary?
- Are out-of-order events tolerated (e.g., `payment.updated` arriving before `payment.created`)?
- Does the handler use the provider's event id, or its own derived key?

Red flags:

- "Check then write" dedupe that races on duplicate concurrent retries.
- Reliance on receive time to order events.
- No record of processed event ids — duplicates apply twice.

### Sender timeout discipline

Ask:

- Does the handler respond inside the sender's timeout window (typically 5–30 seconds)?
- Is heavy work moved to a queue or background job, with the webhook responding `2xx` after the durable enqueue?
- Are retryable failures mapped to the right HTTP status (`5xx` triggers provider retry; `4xx` typically does not)?
- Is the durable handoff from the receiver to the worker idempotent, so the provider can retry the receiver safely?

Red flags:

- Synchronous heavy processing inside the webhook handler — provider retries pile up.
- Returning `200` before the durable record is committed.
- `4xx` returned for transient errors (provider will not retry).

### Tests worth asking for

- Replay of a previously-processed event produces no new side effect.
- Out-of-order delivery is rejected, buffered, or version-guarded.
- Invalid signature is rejected without side effects.
- Request that exceeds processing budget is enqueued and acked within the sender's timeout.

## Outgoing webhooks

Use when the system emits webhooks to customer / partner endpoints.

### Delivery semantics

Ask:

- Is delivery durable (queued behind a worker) or best-effort?
- Is there a documented retry policy (count, backoff, jitter, total deadline)?
- Are retryable vs terminal failures classified by HTTP status and by error class?
- Is there a dead-letter / retry-storage mechanism for events that exceed the retry budget?
- Is per-customer concurrency capped so one slow receiver does not exhaust shared workers?

Red flags:

- Outgoing webhook fired inline in a request handler.
- Retry loop with no max attempts or no backoff.
- One customer's slow endpoint blocks delivery to others.
- No replay tooling for ops to re-emit a missed event.

### Authentication and signing

Ask:

- Are outgoing requests signed (HMAC, mTLS, OIDC) so receivers can verify authenticity?
- Is the signing key rotated periodically? Is rotation transparent to receivers via key id headers?
- Is the customer's URL validated against an allowlist or server-side network policy to block SSRF and internal targets?
- Are user-controllable URL parts (host, scheme, port) sanitized before egress?

Red flags:

- Sending unsigned webhooks to customer endpoints.
- Customer-supplied URL fetched without SSRF protection.
- One static signing secret shared across all customers and all events.

### Observability

Ask:

- Per-customer metrics: success rate, retry rate, terminal-failure rate, delivery latency.
- Logs include event id, customer id, attempt number, terminal status, sanitized failure reason.
- Customer-facing surface (dashboard, log) where they can inspect their own delivery history.

### Tests worth asking for

- Customer endpoint returning `5xx` is retried with backoff and eventually dead-lettered.
- Customer endpoint returning `4xx` is not retried.
- Customer endpoint that times out does not block other customers.
- Outgoing URL pointing to an internal address is rejected.
- Replay tool emits the same payload with the same event id.
