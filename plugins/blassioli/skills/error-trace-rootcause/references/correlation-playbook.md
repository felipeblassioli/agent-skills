# Correlation playbook — from an error to one causal chain

The goal of correlation is to turn an aggregate error (an Error Reporting group, a noisy
filter) into a **single, ordered story of one request**: what happened, in what order,
where it first broke. Debugging an aggregate is guessing; debugging one trail is reading.

## Entry points (all roads lead to a trace)

| Input | First move |
|---|---|
| Logs Explorer **console URL** | `scripts/logs-url-to-filter.sh 'URL'` → filter + project + window |
| **Error group** (`errorGroups.id="…"`) | use it as the representative-search filter |
| Raw **UI query string** | `scripts/logs-url-to-filter.sh -` (decode/normalize) or use as-is |
| A **trace** (`projects/P/traces/HEX`) | skip straight to the trail |
| A **pasted log entry/export** | read its `.trace`; skip to the trail |

`errorGroups.id` is the canonical, queryable field (the console sometimes shows the alias
`error_groups.id`; the URL parser normalizes it). Filtering by error group is documented
for the Logs Explorer; `gcloud logging read` support is not guaranteed — if a live read
returns nothing, drop the `errorGroups.id` clause and rely on the surrounding constraints
(service + revision + stderr + `severity>="ERROR"` + the time window), then match the
error name/message. `trace-trail.sh` does this fallback automatically.

## Step 1 — pick a representative occurrence

An error group aggregates many occurrences; pick **one** to debug. Criteria, in order:
1. has a non-empty `trace` (no trace ⇒ no cross-stream trail),
2. carries the richest payload (`jsonPayload.data.error.stack` present),
3. most recent (matches the current deployed revision).

`scripts/trace-trail.sh --project P --filter 'FILTER'` applies exactly this and prints
the chosen trace. Prefer an occurrence on the **same `revision_name`** you intend to
inspect — line numbers and code only match the revision that produced them.

## Step 2 — pull the full trail

Pivot from the one occurrence to its whole request:
```
trace="projects/PROJECT/traces/HEX"
```
Pull it with **no severity floor and no stream filter**, ordered **ascending** — the
trail must include the INFO request-start, the stdout middleware logs, the stderr errors,
the platform `requests` access log, and any downstream service that shares the trace.
`scripts/trace-trail.sh` emits this as a sequence-numbered table with `+ms` offsets from
the first entry and never prints the header/track blobs.

## Step 3 — read the causal chain

Order is everything. With the trail oldest-first:

- **Find the _first_ failure, not the loudest or the last.** Loggers re-emit the same
  error at several layers; the top stderr line is usually the outermost catch, not the
  origin. Walk forward to the earliest entry whose severity or status degrades.
- **Locate the last good step before the gap.** A large `+ms` jump before the error
  (e.g. `+8120ms` in the worked example) is the operation that hung — read what started
  just before it.
- **Follow the cause chain.** `jsonPayload.data.error.cause.stack` often names the real
  origin (e.g. `AbortError: This operation was aborted` under a `TimeoutError`).
- **Recognize fan-out and retries.** `Promise.all (index N)` means N parallel downstreams
  — the failing index is the culprit; the others are noise. A repeated operation with
  rising `+ms` is a retry loop. An app-set timeout (`timed out after 8000ms`) far below
  the platform `latency` on the `requests` log means the handler retried or ran calls in
  parallel and the user-visible latency is a multiple of one timeout.
- **Cross the service boundary.** If the error message names a downstream URL, that
  downstream is the suspect — not the service that logged the error.

### Worked example, read as a chain

Trail for one `…/orders/triage/alerts` request (from `trace-trail.sh --render`):

```
#  +ms   SEV    STREAM    SERVICE     STATUS  ERROR         DETAIL
1  0     ERROR  requests  orders-api  504     -             GET …/orders/triage/alerts            (request received)
2  7     INFO   stdout    orders-api  -       -             LoggerMiddleware: GET …               (handler starts)
3  8120  ERROR  stderr    orders-api  504     TimeoutError  makeRequest (…/http.client.v2.js:174)
4  8129  ERROR  stderr    orders-api  504     TimeoutError  makeRequest (…/http.client.v2.js:174)
```

Reading: request starts → 8.1 s of nothing → a `TimeoutError` from `makeRequest` aborting
a downstream after 8000 ms (`error.cause` = `AbortError`), re-logged once. The message
names `inventory-api.acme-prod.example.app/products`. **Root cause: a slow downstream
(`/products`) with no resilience around the call** — not a defect in the orders API's own
logic. Next step is `references/locate-code.md` to pin the call site and confirm whether a
timeout/retry/circuit-breaker is missing.

## When the GCP trace does not span the flow

The top-level `trace` only correlates synchronous, trace-propagated calls. It breaks for:

- **GKE (`k8s_container`).** These entries have **no top-level `trace`** at all — even for
  ordinary synchronous requests. Pivot on `jsonPayload.traceId` / `contextId` (the app UUID)
  within the project; `trace-trail.sh --app-id UUID` (or `--filter`, which auto-detects)
  does this. The W3C `Traceparent` request header carries the cross-service trace if a
  downstream needs joining. See `service-archetypes.md` (in `gcp-log-triage`).
- **Async / jobs / Pub/Sub / workers.** Each hop may start a new trace. Correlate instead
  on the application ids: `jsonPayload.traceId` / `jsonPayload.contextId` (one process) and
  `event.id` / `correlation_id` (across hops).
- **Cross-service, same trace.** If a downstream is instrumented and `traceparent`
  propagated, the **same `trace`** appears in the callee's logs — query the callee
  service/project for that trace to read *its* error directly. If the call crossed
  projects (e.g. `acme-services` → `acme-prod`) or the header was not propagated,
  correlate by timestamp window + the downstream URL/identifiers in the message.
- **Thin trail (error only, no trace).** Broaden: drop the `errorGroups.id` clause, widen
  the window, and search by `jsonPayload.data.error.name` / message; then correlate the
  surviving entries by `contextId`.

## Anti-patterns

- Debugging the aggregate group instead of one concrete trail.
- Trusting the top stderr line as the origin (it is usually the outer catch).
- Blaming the service that logged the error when the message points at a downstream.
- Reading line numbers from a revision other than the one that produced the trace.
