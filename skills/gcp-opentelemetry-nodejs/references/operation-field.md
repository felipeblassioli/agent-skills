# LogEntry.operation: when and how to use it

`operation` is a **Cloud Logging** `LogEntry` field, not an OpenTelemetry concept. Use it when you need to group multiple log entries that belong to one potentially long-running business operation. Do not use it for request/span correlation; use `trace`, `spanId`, and `traceSampled` for that.

## When to use `operation`

Use `operation` when all of the following are true:

- Multiple log entries belong to the same business workflow or long-running task.
- You want Logs Explorer to group those entries (e.g. batch job, saga, reconciliation).
- The grouping is broader than a single request span.

Typical examples: nightly reconciliation, payout run, report generation, import pipeline, saga execution, replay or reprocessing job.

Set:

- `operation.id` — stable identifier for the workflow instance (e.g. `reconciliation-2026-03-10-ledger-a`).
- `operation.producer` — globally unique producer (e.g. `github.com/org/service`, `payments.reconciliation`).
- `operation.first` — `true` on the first boundary log.
- `operation.last` — `true` on the final boundary log.

## When not to use `operation`

Do **not** use `operation` as the primary correlation mechanism for:

- Normal HTTP request logs.
- Per-request application milestone logs.
- Ordinary function-level debug logging.

For those, use the standard trace fields: `trace`, `spanId`, `traceSampled`. Those are what Google Cloud uses to link logs with traces.

## Transport rule

How you populate the field depends on how logs are written:

- **Cloud Logging API or client library:** set top-level `operation` on the `LogEntry` when calling `log.entry()` / `entries.write`.
- **Structured JSON to stdout/stderr:** set the special JSON key `logging.googleapis.com/operation` so the agent extracts it into `LogEntry.operation`. Value must be an object `{ id, producer?, first?, last? }`.

## Recommended two-lane model (Cloud Run / Firebase Functions gen2)

- **Request and app logs:** structured JSON to stdout/stderr with `severity`, `message`, `httpRequest` when applicable, and `trace` / `spanId` / `traceSampled`. No `operation`.
- **Workflow boundary logs:** use the Cloud Logging client (or structured JSON with `logging.googleapis.com/operation` and `logging.googleapis.com/insertId`) for start/mid/end of long-running operations so they appear as grouped operations in Logs Explorer.

Keep request correlation in trace fields; use `operation` only for workflow-level grouping.

## References

- [LogEntry.operation (LogEntryOperation)](https://docs.cloud.google.com/logging/docs/reference/v2/rest/v2/LogEntry#LogEntryOperation)
- [Structured logging: special fields](https://docs.cloud.google.com/logging/docs/structured-logging) (`logging.googleapis.com/operation`)
- [Trace–log integration](https://docs.cloud.google.com/trace/docs/trace-log-integration)
