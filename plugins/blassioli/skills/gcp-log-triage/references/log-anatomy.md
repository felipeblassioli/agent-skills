# Cloud Logging entry anatomy and the noise model

This reference dissects a noisy export so queries target the right fields. The
worked example is a Firebase Functions (Gen 2) service running on Cloud Run, logging
through a structured JSON logger (e.g. pino / winston / bunyan), but the envelope is
generic GCP and the technique transfers. The specific `jsonPayload.*` paths below are an
example convention — map them to whatever shape your own logger emits.

## The GCP `LogEntry` envelope (generic)

Every entry — whatever produced it — is a [`LogEntry`](https://docs.cloud.google.com/logging/docs/reference/v2/rest/v2/LogEntry).
The fields worth querying live at the top level:

| Field | Meaning | Query as |
|---|---|---|
| `severity` | `DEFAULT,DEBUG,INFO,NOTICE,WARNING,ERROR,CRITICAL,ALERT,EMERGENCY` (ordered enum) | `severity >= "ERROR"` |
| `timestamp` | when the event occurred | `timestamp >= "2026-06-15T21:00:00Z"` |
| `resource.type` | the monitored-resource kind | `resource.type = "cloud_run_revision"` |
| `resource.labels.*` | which instance of that resource | `resource.labels.service_name = "..."` |
| `logName` | the log stream; **`/` is percent-encoded `%2F`** | `logName = "projects/P/logs/run.googleapis.com%2Fstderr"` |
| `trace` | `projects/P/traces/HEX` — the cross-stream join key | `trace = "projects/P/traces/HEX"` |
| `spanId` | span within the trace | — |
| `labels.*` | platform/user labels | `labels."goog-drz-cloudfunctions-id" = "..."` |
| `httpRequest.*` | structured request record (access logs) | `httpRequest.status >= 500` |
| `jsonPayload.*` | the app's structured payload (if it logged JSON) | `jsonPayload.level = "error"` |
| `textPayload` | the app's payload (if it logged a plain string) | global restriction `"some text"` |
| `errorGroups[].id` | Error Reporting grouping key (when present) | pivot to Error Reporting |

Rule of thumb: **`resource.*` and `labels.*` describe _who emitted_ the entry;
`jsonPayload.*` / `httpRequest.*` describe _what happened_.** Filter location with the
former, filter content with the latter.

## The three Cloud Run log streams — the duplication source

A Cloud Run / Gen 2 Functions service writes to **three separate logs**, all under the
same `resource` and `trace`:

| `logName` ends in | Who writes it | Typical severity | Content |
|---|---|---|---|
| `run.googleapis.com%2Fstdout` | your app's stdout | INFO | request-start / middleware logs |
| `run.googleapis.com%2Fstderr` | your app's stderr | ERROR | caught errors, stack traces |
| `run.googleapis.com%2Frequests` | the platform | mirrors HTTP status | one access log per request (`httpRequest`) |

GKE/Kubernetes equivalents: `resource.type = "k8s_container"`, streams under
`stdout`/`stderr`, plus load-balancer request logs. The principle is identical: **a
single request fans out into one access log plus N app logs.** Cutting to one stream is
the first and biggest noise reduction.

## Two different "trace" identifiers — do not confuse them

- **GCP `trace`** (top-level): `projects/acme-services/traces/29f9796c02ab7c1f5b013e506fc66776`.
  Derived from the `x-cloud-trace-context` / `traceparent` header. **This is the
  cross-stream join key** — all four entries for one request share it. Group by this.
- **App `jsonPayload.traceId` / `jsonPayload.contextId`** (e.g. `9f257c75-6574-...`):
  the application's *own* correlation UUID, minted by the logger. Useful for grepping a
  single in-process flow, but it is **not** the GCP trace and will not match the
  `trace=` filter.

## An example structured-log `jsonPayload` shape

A structured JSON logger emits a fixed envelope. The exact paths depend on your logger —
the shape below is one common convention (`error` object plus a top-level `statusCode`);
adapt the field names to match yours. Fields that carry signal:

| Path | Meaning |
|---|---|
| `jsonPayload.severity` (or `jsonPayload.level`) | app severity — often mirrors the top-level `severity` |
| `jsonPayload.application` | logical app name, e.g. `"orders-api"` |
| `jsonPayload.message` | human string; for errors often `"Error: #service.method => \n  at ..."` |
| `jsonPayload.traceId` / `contextId` | app correlation UUID (see above) |
| `jsonPayload.error.name` | error class, e.g. `TimeoutError` |
| `jsonPayload.error.message` | error message (often contains the offending downstream URL) |
| `jsonPayload.statusCode` | mapped HTTP status, e.g. `504` |
| `jsonPayload.error.stack` | full stack; first application (non-dependency) frame = the call site |
| `jsonPayload.error.cause.stack` | underlying cause, e.g. `AbortError: This operation was aborted` |
| `jsonPayload.{method,url,body}` | request echo on info/request logs |

Fields that are almost always **noise** (and sometimes a security risk):

| Path | Why it is noise |
|---|---|
| `jsonPayload.keys.httpRequest.headers` (or wherever your logger stashes headers) | the **entire** request header set, repeated on every entry — including `authorization: Bearer <JWT>`, `cookie`, etc. This is both the bulk of the payload size and a credential leak. **Never project or paste it.** |
| `jsonPayload.keys.{query,params}` | denormalized echo of the request, duplicated across entries |
| `jsonPayload.track` and `jsonPayload.keys.track` | device/app/network/position; all-empty strings for non-mobile (web) callers |
| `jsonPayload.labels` | usually `{}` |

> Targeting `jsonPayload.error.*` and the platform `httpRequest.*` — and never
> `jsonPayload.keys.*` — is what separates signal from the blob. The bundled
> `triage-logs.sh` script encodes exactly this projection.

## The worked example, decoded

One failed request to `…/orders/triage/alerts`, GCP trace `29f9796c…`, produced **four**
entries within ~8 seconds:

1. **stderr / ERROR** — rich `jsonPayload.error` (`TimeoutError`, 504, stack →
   `orders.triage.service.js:102`, cause `AbortError`). Also carried the full header
   blob + empty `track`.
2. **stderr / ERROR** — a near-duplicate of #1 (same error, same trace), emitted from a
   second log site. Same blob again.
3. **stdout / INFO** — `LoggerMiddleware: GET …` request-start log. Pure lifecycle
   noise on a failing request; header blob again.
4. **requests / ERROR** — the platform access log: `httpRequest.status = 504`,
   `latency = 30.0s`.

Two signals worth noting from the decode:
- The app aborts the downstream at **8000 ms** (`timed out after 8000ms`) but the access
  log shows **30 s** latency — the handler retried / ran the downstream inside a
  `Promise.all` (`fetchBundle … index 1`), so the user-visible latency is a multiple of
  the per-call timeout.
- The root cause is downstream: `shop-web.example.com/booking` is slow, not the orders
  API itself.

That is the entire diagnosis — extractable from 4 fields — buried under ~300 lines of
repeated headers. The rest of this skill is about not reading those 300 lines.

## What the bundled script makes of it

Running `triage-logs.sh --flat` on the export shows the four-entry fan-out for the one
trace (`N=1` per row; note the two duplicate stderr ERRORs, the stdout INFO middleware
log, and the requests 504):

```
TIME                       SEV    N  STREAMS   STATUS  ERROR         SERVICE     WHERE                                  MESSAGE                                            TRACE
2026-06-15T21:09:42.5826…  ERROR  1  stderr    504     TimeoutError  orders-api  makeRequest (/app/providers/http.…     Request to https://…/booking timed out after …     29f9796c02ab7c1f5b013e506fc66776
2026-06-15T21:09:42.5734…  ERROR  1  stderr    504     TimeoutError  orders-api  makeRequest (/app/providers/http.…     Request to https://…/booking timed out after …     29f9796c02ab7c1f5b013e506fc66776
2026-06-15T21:09:34.4608…  INFO   1  stdout    -       -             orders-api  -                                      LoggerMiddleware: GET http://…/orders/triage/alerts… 29f9796c02ab7c1f5b013e506fc66776
2026-06-15T21:09:34.4535…  ERROR  1  requests  504     -             orders-api  -                                      https://…/orders-api/orders/triage/alerts…         29f9796c02ab7c1f5b013e506fc66776
```

The default (`--by-trace`) collapses all four into a single signal row — `N=4`,
`STREAMS=requests,stderr,stdout`, the call site preserved from the error stack — and
prints none of the header/track blobs:

```
TIME                       SEV    N  STREAMS                 STATUS  ERROR         SERVICE     WHERE                                    MESSAGE                                          TRACE
2026-06-15T21:09:42.5826…  ERROR  4  requests,stderr,stdout  504     TimeoutError  orders-api  makeRequest (/app/providers/http.client…  Request to https://…/booking timed out after …  29f9796c02ab7c1f5b013e506fc66776
```
