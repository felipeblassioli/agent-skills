# Format Cloud Logging entries for Error Reporting ingestion

Error Reporting can ingest error events from Cloud Logging when your log entry contains:

- a stack trace (as text), or
- a `ReportedErrorEvent` payload encoded into `jsonPayload`.

## Accepted payload shapes

### Option A — `textPayload` (multi-line stack trace)

Send a multi-line `textPayload` that includes a stack trace in a supported language format.

This is useful when you’re writing logs through Cloud Logging APIs/agents or CLIs and want Error
Reporting grouping “for free”.

### Option B — `jsonPayload` with recognized fields

If using `jsonPayload`, include one or more of these fields:

- `stack_trace`
- `exception`
- `message`

If more than one is present, Error Reporting evaluates in this order:

1. `stack_trace`
2. `exception`
3. `message`

If `message` is evaluated and is non-empty, a stack trace is only captured if `message` contains a
stack trace in a supported format.

### Option C — `jsonPayload` that represents a `ReportedErrorEvent`

If your error event is already shaped like a `ReportedErrorEvent`, copy its fields into
`jsonPayload`. If you are logging just a **text message** (no stack trace), set `@type` so Error
Reporting treats it as a `ReportedErrorEvent`:

```json
"jsonPayload": {
  "@type": "type.googleapis.com/google.devtools.clouderrorreporting.v1beta1.ReportedErrorEvent",
  "message": "A simple text message"
}
```

If you omit `@type` (or set it to a different value), Cloud Logging searches for a field labeled
`serviceContext` to determine whether the payload is a `ReportedErrorEvent`.

## Populate the Error Reporting response code for HTTP handlers

When the error happened while serving an HTTP request, add HTTP context under the
`ReportedErrorEvent` shape:

```json
"jsonPayload": {
  "serviceContext": {
    "service": "payments-api",
    "version": "2026-03-09"
  },
  "message": "Error: request failed\n    at ...",
  "context": {
    "httpRequest": {
      "method": "POST",
      "url": "https://api.example.com/payments",
      "responseStatusCode": 500,
      "userAgent": "curl/8.7.1"
    }
  },
  "errorCode": "PAYMENT_PROVIDER_TIMEOUT"
}
```

Use `context.httpRequest.responseStatusCode` to populate the Error Reporting UI's response-code
column. This value should be the actual HTTP response status you returned, such as `400`, `404`,
`409`, or `500`.

Keep these boundaries clear:

- `context.httpRequest.responseStatusCode` is for Error Reporting's HTTP context.
- Top-level `httpRequest.status` is for Cloud Logging request-summary logs and log queries.
- Application-specific or provider-specific error identifiers belong in separate payload fields such
  as `errorCode`, not in `responseStatusCode`.

If the error is not associated with an HTTP response, leave `context.httpRequest` unset instead of
inventing a response code.

## Monitored resource type

Set `resource.type` to a monitored resource type supported by Error Reporting (for example,
`cloud_run_revision`, `cloud_function`, `k8s_container`, `gce_instance`, etc.). Some types don’t
support `textPayload` (for example `global`).

## Common pitfalls

- **Single-line messages** without a stack trace are usually not enough to group an error unless
  you set `@type` (or provide a `serviceContext`-shaped payload).
- If your stack trace is in an **unsupported format**, Error Reporting may not capture it even if
  it looks “stack-ish”.

## See also

- [Quick reference: which fields are evaluated](../assets/quickref/logentry-fields.md)
- [Overview: ingestion paths](overview-and-ingestion-paths.md)
