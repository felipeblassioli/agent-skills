# Observability Review Reference

Use this when reviewing logging, metrics, tracing, alerts, or async processing code.

## Minimum useful signals

For services:

- Request count by route, method, status class, and error class.
- Request latency histogram.
- Dependency latency and failure count.
- Saturation: queue depth, active workers, pool usage, rate limits, memory, CPU.

For queue consumers:

- Message receive count.
- Ack / nack / failure / DLQ count.
- Processing duration.
- Delivery attempt or retry count where available.
- Backlog age / oldest unacked age from platform metrics.
- Flow-control saturation.
- In-flight messages during shutdown.

## Logs

Good logs explain decisions and failures. Bad logs are either silent or theatrical.

Require:

- Stable event names.
- Correlation identifiers.
- Message id / event id for async work.
- Sanitized error details.
- Clear terminal vs retryable failure classification.

Reject:

- Secrets, tokens, CPF, credit card data, raw authorization headers, or large payload dumps.
- Logging and swallowing errors.
- Error logs without enough dimensions to aggregate.

## Traces

Review:

- Span boundaries follow meaningful units of work.
- Async boundaries preserve correlation where feasible.
- External dependency calls have spans or structured metrics.
- Span attributes avoid high-cardinality explosions and sensitive data.

## Alerts

Ask:

- Does this alert map to user impact or operator action?
- Is there a runbook or obvious next step?
- Does it avoid paging on single-message permanent failures unless volume matters?
