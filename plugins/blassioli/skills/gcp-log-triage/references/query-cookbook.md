# Query cookbook — Logs Explorer and `gcloud logging read`

The **same filter language** drives both the Logs Explorer console and
`gcloud logging read`. Author once; use in either. Operators below are confirmed
against the official
[Logging query language](https://docs.cloud.google.com/logging/docs/view/logging-query-language)
and the
[`gcloud logging read`](https://docs.cloud.google.com/sdk/gcloud/reference/logging/read)
reference.

## Operator quick reference

| Operator | Meaning | Example |
|---|---|---|
| `=` `!=` | equality / inequality | `severity != "INFO"` |
| `>` `>=` `<` `<=` | ordered comparison (numbers, timestamps, **severity enum**) | `severity >= "ERROR"`, `httpRequest.status >= 500` |
| `:` | has / substring (strings & structs) | `jsonPayload.message:"timed out"` |
| `=~` `!~` | regular-expression match / non-match | `jsonPayload.message =~ "timed out after \d+ms"` |
| `AND` `OR` `NOT` | boolean; `NOT` binds tightest | `severity>="ERROR" AND resource.type="cloud_run_revision"` |
| `-field` | negation shorthand for `NOT` | `-logName=~"requests"` |
| `"bare string"` | global restriction — searches all indexed fields | `"TimeoutError"` |
| `SEARCH(field, "q")` | tokenized search of a field or whole entry | `SEARCH("booking timed out")` |

Notes:
- Severity is a **case-insensitive ordered enum**, so `severity >= "ERROR"` matches
  `ERROR`, `CRITICAL`, `ALERT`, `EMERGENCY`. Quoting (`"ERROR"`) is the documented form.
- In `logName`, the `/` characters are **percent-encoded as `%2F`**.
- Missing-field test: `NOT jsonPayload.error:*` (entries without an error object).

## The triage funnel (apply top-down, stop when it's quiet)

1. **Locate** — pin the resource and window so volume is bounded. Use the targeting for the
   service's **archetype** (full matrix in `service-archetypes.md`):
   ```
   # Gen2 / Cloud Run (acme-services)
   resource.type="cloud_run_revision" resource.labels.service_name="orders-api"
   # Gen1 Firebase Function (acme-services)
   resource.type="cloud_function" resource.labels.function_name="orders" resource.labels.region="us-central1"
   # GKE container (acme-prod)
   resource.type="k8s_container" resource.labels.namespace_name="inventory-api"
   # AppHub workload view (host project; works directly under gcloud)
   apphub.application.id="inventory-api" apphub.workload.id="inventory-api-prod-web"
   ```
   Always add `timestamp>=…` and the right `--project` (Functions/Cloud Run → `acme-services`,
   GKE/AppHub → `acme-prod`).
2. **Pick one stream** — kill cross-stream duplication. For Cloud Run app errors:
   ```
   logName="projects/acme-services/logs/run.googleapis.com%2Fstderr"
   ```
   For one row per request instead, use `…%2Frequests` (the access log).
3. **Floor the severity** — drop INFO lifecycle/middleware logs:
   ```
   severity>="ERROR"
   ```
4. **Narrow to the symptom** — by error class, status, or downstream:
   ```
   jsonPayload.error.name="TimeoutError"
   jsonPayload.error.message:"booking"
   ```
5. **Project, don't read** — in the console, pin summary fields
   (`jsonPayload.error.name`, `…message`, `resource.labels.revision_name`); on the
   CLI use `--format` (below) so the header blob is never fetched.

## Console (Logs Explorer) — paste-ready

Find the real error for one service, last hour, no lifecycle noise:
```
resource.type="cloud_run_revision"
resource.labels.service_name="orders-api"
severity>="ERROR"
-logName=~"requests"
```
(The `-logName=~"requests"` drops the platform access log so each request shows its
app-side error once. Drop that line instead and keep `logName=~"requests"` to see HTTP
status + latency per request.)

Isolate a single failing request once you have its trace:
```
trace="projects/acme-services/traces/29f9796c02ab7c1f5b013e506fc66776"
```

All 5xx access logs (latency outliers, timeouts), one row per request:
```
resource.type="cloud_run_revision"
logName=~"run.googleapis.com%2Frequests"
httpRequest.status>=500
```

Find a downstream-dependency failure across services:
```
severity>="ERROR"
(jsonPayload.message:"timed out" OR jsonPayload.error.name="TimeoutError")
```

## `gcloud logging read` — scriptable

Defaults that matter: `--order=desc`, `--freshness=1d`, `--limit` unbounded (always set
it). One scope flag only (`--project` / `--folder` / `--organization` / `--billing-account`).

Compact table, no payload blob ever leaves the API:
```bash
gcloud logging read \
  'resource.type="cloud_run_revision"
   resource.labels.service_name="orders-api"
   severity>="ERROR" -logName=~"requests"' \
  --project=acme-services --freshness=1h --limit=50 \
  --format='table(
    timestamp,
    resource.labels.revision_name,
    jsonPayload.error.name,
    jsonPayload.statusCode,
    jsonPayload.error.message)'
```

Extract just the call sites for a given error (one value per line):
```bash
gcloud logging read \
  'jsonPayload.error.name="TimeoutError"' \
  --project=acme-services --freshness=6h --limit=200 \
  --format='value(jsonPayload.error.stack)' \
  | grep -vE 'node_modules|/(dist|vendor)/' | grep -E '\bat\b' | sort | uniq -c | sort -rn
```

Pull JSON and hand it to the bundled triage helper (dedup by trace, never prints headers):
```bash
gcloud logging read \
  'resource.type="cloud_run_revision" resource.labels.service_name="orders-api" severity>="ERROR"' \
  --project=acme-services --freshness=2h --limit=500 --format=json \
  | "${CLAUDE_SKILL_DIR:-.}/scripts/triage-logs.sh" --errors
```

Count errors by class to see what actually dominates (cheap triage of "what's noisy"):
```bash
gcloud logging read 'severity>="ERROR"' \
  --project=acme-services --freshness=24h --limit=1000 \
  --format='value(jsonPayload.error.name)' \
  | sort | uniq -c | sort -rn
```

## Cross-stream caveats and gotchas

- **`--format=value(...)` / `table(...)` projection is the cheapest redaction**: fields
  you don't name are never returned, so the header blob and the Bearer token never reach
  your terminal, history, or clipboard.
- **`:` vs `=`**: `jsonPayload.message:"timeout"` is substring; `="timeout"` is exact.
  For the long `message` strings here, almost always use `:` or `=~`.
- **Indexed vs not**: global restrictions (`"text"`) and `=~` scan; on big windows,
  always also constrain `resource.*` + `timestamp` so the scan is bounded.
- **The app `traceId` won't join across streams** — group on the top-level `trace`.
- **Gen 2 Functions** appear as `resource.type="cloud_run_revision"` *and* carry
  `labels."goog-drz-cloudfunctions-id"`; either targets them, but the request access log
  only exists under the `run.googleapis.com%2Frequests` stream.
- To **save** a good query, use a saved query / Log Analytics view in the console rather
  than re-deriving the funnel each incident.

For turning a recurring noisy class into a *permanent* reduction (exclusion filters,
sinks, logger fixes), see `references/reduce-noise-at-source.md`.
