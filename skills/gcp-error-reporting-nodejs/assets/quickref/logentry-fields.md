# Quick reference: Error Reporting log ingestion fields

When ingesting from **Cloud Logging**, Error Reporting looks for stack traces in:

- multi-line `textPayload`, or
- `jsonPayload` fields, especially:
  - `stack_trace`
  - `exception`
  - `message`

## Field evaluation order (jsonPayload)

If multiple fields are present, the evaluation order is:

1. `stack_trace`
2. `exception`
3. `message`

If `message` is evaluated and non-empty, a stack trace is captured only if `message` contains a
stack trace in a supported format.

## For text-only events (no stack trace)

If you only want to report a text message (no stack trace), shape the payload as a
`ReportedErrorEvent` by setting:

- `jsonPayload["@type"] =
  "type.googleapis.com/google.devtools.clouderrorreporting.v1beta1.ReportedErrorEvent"`
- `jsonPayload.message = "..."` (required)

If `@type` is not set, Cloud Logging may look for `serviceContext` to detect a ReportedErrorEvent
payload.

## Fields that drive the Error Reporting UI

Use these `jsonPayload` fields when you want both ingestion and richer HTTP context in Error
Reporting:

| Field | Purpose | Notes |
|---|---|---|
| `message` / `stack_trace` / `exception` | Error ingestion and grouping | Include a supported stack trace format when possible |
| `serviceContext.service` | Service grouping | Required for `ReportedErrorEvent` payloads |
| `serviceContext.version` | Version attribution | Optional but recommended for release tracking |
| `context.httpRequest.method` | HTTP request metadata | Only for real HTTP request flows |
| `context.httpRequest.url` | HTTP request metadata | Use the canonical request URL when available |
| `context.httpRequest.responseStatusCode` | Error Reporting response code | Use the actual HTTP status code, such as `404` or `500` |

## Do not confuse these fields

- `context.httpRequest.responseStatusCode` drives Error Reporting's HTTP response code display.
- Top-level `httpRequest.status` belongs to the Cloud Logging `LogEntry` envelope, not the
  `ReportedErrorEvent` payload.
- Business or provider error codes should live in separate fields such as `errorCode`.

## See also

- [LogEntry formatting rules](../../references/logentry-formatting.md)
