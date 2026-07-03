# Service archetypes — targeting the right logs per platform

A typical GCP estate runs four Cloud Logging shapes. The resource type, log streams,
trace correlation, and even the `jsonPayload` casing differ — using the wrong target
returns nothing or the wrong rows. This is the shared targeting reference for all three
GCP observability skills (`gcp-log-triage`, `error-trace-rootcause`, `error-reporting`).
The project ids and service names below (`acme-services`, `acme-prod`, `orders-api`,
`inventory-api`) are placeholders — substitute your own.

## Quick matrix

| # | Archetype | `resource.type` | Identifying labels | `logName` (ends in) | Streams | Top-level `trace`? | Correlate via | `jsonPayload.level` | Project (example) |
|---|---|---|---|---|---|---|---|---|---|
| 1 | Firebase Functions **Gen 1** | `cloud_function` | `function_name`, `region` | `cloudfunctions.googleapis.com%2Fcloud-functions` | 1 (merged) | **yes** | GCP `trace` | lower (`info`) | `acme-services` |
| 2 | Firebase Functions **Gen 2** / Cloud Run | `cloud_run_revision` | `service_name`, `revision_name`, `configuration_name`, `location` | `run.googleapis.com%2F{stdout,stderr,requests}` | 3 | **yes** | GCP `trace` | lower (`error`) | `acme-services` |
| 3 | **GKE** container | `k8s_container` | `container_name`, `pod_name`, `namespace_name`, `cluster_name`, `location` | `stdout` / `stderr` (plain) | 2 | **no** | `jsonPayload.traceId`/`contextId` + `Traceparent` | **UPPER** (`INFO`) | `acme-prod` |
| 4 | **AppHub** view (over #3 etc.) | adds `apphub.*` fields | `apphub.application.id`, `apphub.workload.id` | (underlying) | (underlying) | (underlying) | (underlying) | host/mgmt project |

If your services share a common structured-log shape, all four archetypes will carry the
same `jsonPayload` family (e.g. `application`, `message`, `traceId`, `contextId`,
`keys.httpRequest`, and an `error.{name,message,stack}` object plus `statusCode` on
errors) — but mind the casing and trace differences below.

## 1 — Firebase Functions Gen 1 (`cloud_function`)

```
resource.type="cloud_function"
resource.labels.function_name="orders"
resource.labels.region="us-central1"
severity>="DEFAULT"
```
- **One merged stream** (`…%2Fcloud-functions`) — no stdout/stderr/requests split; filter by
  `severity` to separate info from errors.
- Top-level `trace` **is** set → trace pivot works (`trace="projects/PROJECT/traces/HEX"`).
- `jsonPayload.level` is lowercase (`info`/`error`); `keys` includes `httpRequest, params,
  query, track, sender`.
- Example: `logName=projects/acme-services/logs/cloudfunctions.googleapis.com%2Fcloud-functions`,
  `trace=projects/acme-services/traces/8388d01c439b88d5444fb5019cec56fa`.

## 2 — Firebase Functions Gen 2 / Cloud Run (`cloud_run_revision`)

```
resource.type="cloud_run_revision"
resource.labels.service_name="orders-api"
resource.labels.revision_name="orders-api-00064-ceq"
resource.labels.configuration_name="orders-api"
resource.labels.location="us-central1"
```
- **Three streams**: `…%2Fstdout` (app INFO), `…%2Fstderr` (app errors), `…%2Frequests`
  (platform access log). Pick one to kill cross-stream duplication (see `log-anatomy.md`).
- Gen 2 *functions* also carry `labels."goog-drz-cloudfunctions-id"` and
  `goog-managed-by=cloudfunctions`; plain Cloud Run services do not.
- Top-level `trace` set; `level` lowercase. This is the archetype `log-anatomy.md` dissects.

## 3 — GKE container (`k8s_container`)

```
resource.type="k8s_container"
resource.labels.namespace_name="inventory-api"
resource.labels.container_name="web"
resource.labels.cluster_name="gke-prod-usc1-01"
resource.labels.location="us-central1"
```
- `logName` is **plain** `projects/PROJECT/logs/stderr` (or `stdout`) — **no**
  `run.googleapis.com%2F` prefix. Match with `logName=~"/logs/stderr$"`, not `%2Fstderr`.
- **No top-level `trace`.** This is the critical difference: a `trace="…"` pivot returns
  nothing. **Correlate on `jsonPayload.traceId` / `jsonPayload.contextId`** (the app UUID,
  e.g. `34b09e4e-08bd-4154-ac99-28d85c473303`) within the project, or extract the W3C trace
  from the `Traceparent` request header. `trace-trail.sh` (in the `error-trace-rootcause`
  skill) auto-detects this and pivots on `jsonPayload.traceId` when `.trace` is absent.
- `jsonPayload.level` is **UPPERCASE** (`INFO`/`ERROR`); the entry also has `jsonPayload.ts`
  (the app's own timestamp) and an `apphub` block. `resource.labels` has **no**
  `service_name` — the app name is `jsonPayload.application` (`inventory-api`) and
  `labels."k8s-pod/otel/service"` (`inventory-api-prod-web`).
- **Secrets/PII to never print:** `keys.httpRequest.headers` here can carry a custom API-key
  header (e.g. `X-Api-Key`), `X-Real-Ip` / `X-Forwarded-For` / `Cf-Connecting-Ip` (client IPs);
  `data.body` can carry domain PII. Treat any API-key header like an Authorization token —
  redact and rotate if seen.
- GKE services usually **map to local repos**: `namespace_name`/`application` (e.g.
  `inventory-api`) is a directory in your services monorepo — grep there directly (see
  `error-trace-rootcause`'s `locate-code.md`). This can differ from Firebase functions,
  which may live elsewhere.

## 4 — AppHub query view (`apphub.*`)

[App Hub](https://docs.cloud.google.com/logging/docs/log-scope/create-and-manage) groups
fleet resources into applications/workloads and stamps logs with `apphub.*`:
```
apphub.application.location="us-central1"
apphub.application.id="inventory-api"
apphub.workload.id="inventory-api-prod-web"
```
- These fields **query directly in `gcloud logging read`** in the App Hub host/management
  project, with **no log scope required**. They resolve to the same underlying
  `k8s_container` entries (archetype #3).
- The console wraps clauses in `(...)`, prefixes `-- comment` lines, and sets
  `storageScope=logScope,projects/PROJECT/locations/global/logScopes/_Default`. For gcloud:
  **strip the `-- comment` lines** (gcloud filters have no `--` comments); the `(...)` and
  the `apphub.*` clauses pass through unchanged. `logs-url-to-filter.sh` (in the
  `error-trace-rootcause` skill) strips comments automatically.
- Log scopes are managed with `gcloud logging scopes list` / `describe LOG_SCOPE_ID
  --project=PROJECT`. Within the host project the `apphub.*` filter alone is enough; cross-
  scope reads may need the scope's log views (`--bucket/--location/--view`).
- Use AppHub when triaging by **application/workload** across the fleet rather than by a raw
  k8s namespace — the resulting entries are still archetype #3 and follow its trace rules.

## Cross-cutting checklist

- **Pick the right `--project`.** In this example, Functions/Cloud Run live in
  `acme-services`; GKE/AppHub in `acme-prod`. A filter is silently empty against the wrong
  project.
- **`logName` encoding differs:** `%2F` for Cloud Run/Functions, plain `/logs/stderr` for GKE.
- **Trace pivot differs:** GCP `trace` for #1/#2; `jsonPayload.traceId` for #3/#4.
- **`level` casing differs:** prefer `severity` (always uppercase, comparable) over
  `jsonPayload.level` for floors.
- **Service identity differs:** `service_name`/`function_name` for #1/#2; `namespace_name` +
  `jsonPayload.application` for #3/#4 (and Error Reporting groups key on
  `serviceContext.service`).
- **Secrets differ:** `authorization: Bearer …` on Functions/Cloud Run; a custom API-key
  header (e.g. `X-Api-Key`) plus client IPs and the request body on GKE. Project safe fields
  only; never print header/body blobs.
