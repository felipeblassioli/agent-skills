---
name: gcp-log-triage
description: >-
  Cut through noisy Google Cloud Logging output and find the real signal. Use
  when the user pastes or exports Cloud Logging entries (a downloaded-logs JSON,
  `jsonPayload`/`LogEntry`/`textPayload` shapes, Cloud Run / Cloud Functions /
  GKE logs) and asks to find the real error, explain why a service is erroring,
  dedup logs by trace, write a Logs Explorer or `gcloud logging read` query, or
  reduce log noise via exclusion filters or sinks — even when they only say
  "these logs are too noisy" or "what's actually failing here". Also fires when
  a service emits many entries per request (stdout/stderr/requests duplication)
  or repeats large header/context blobs. Do NOT use to root-cause one specific error
  down to a trace and the offending code (that is error-trace-rootcause) or to rank
  which error groups are worst by blast radius (that is error-reporting) — hand those
  off by name. Also not for authoring app-side OpenTelemetry instrumentation, for
  metrics/SLO/alerting config, or for non-GCP log systems (Datadog, ELK, CloudWatch).
---

# Triage and tame noisy Google Cloud logs

Google Cloud logs are noisy by construction: one request fans out into several
entries across multiple log streams, app loggers re-emit the same error, and each
entry can carry large repeated context blobs (full request headers, empty device
objects). The signal — what failed, where, and why — is a handful of fields buried
in that volume. This skill makes that signal cheap to extract, and shows how to
reduce the noise permanently when a class of it recurs.

The technique is generic GCP; the bundled example is a service on Cloud Run using a
structured JSON logger (e.g. pino / winston / bunyan), so field paths are concrete and
queries are paste-ready. The `jsonPayload.*` field paths below are an example
convention — adapt them to whatever shape your own logger emits.

## Use this skill when

- log output (pasted, exported, or fetched) is dominated by noise and the user wants
  the actual error / root cause
- the request is "write a query for Logs Explorer" or "`gcloud logging read` for …"
- a Cloud Run / Cloud Functions (Gen 2) / GKE service emits many entries per request
  or repeats header/context blobs
- the user wants to **dedup by trace**, drop lifecycle/middleware/request-log noise, or
  **reduce noise at the source** (exclusion filters, sinks, fixing the emitter)

## Do not use this skill when

- the task is authoring **application-side** logging/OTel instrumentation (how to emit
  logs) — that is a logging/instrumentation authoring task, not this skill
- the task is **metrics, SLOs, or alerting** config (e.g. the `charts` SLO templates)
- the goal is to **root-cause one specific error down to the code** — triage to the signal
  here, then hand off to the **`error-trace-rootcause`** skill, which correlates the full
  trace trail and locates the offending code
- the goal is to **rank/triage Error Reporting groups by blast radius** (the `/errors`
  console) — that is the **`error-reporting`** skill
- the logs are **not** Google Cloud Logging (Datadog, ELK/Kibana, CloudWatch, raw files)

## Mental model — why GCP logs are noisy

Internalize four facts (full detail in `references/log-anatomy.md`):

1. **Multiple streams per request.** Cloud Run writes `…%2Fstdout` (app INFO),
   `…%2Fstderr` (app errors), and `…%2Frequests` (one platform access log per request).
   One failed request ⇒ one access log **plus** N app logs. Picking a single stream is
   the biggest single noise cut.
2. **Re-emitted errors.** App loggers commonly log the same error at multiple layers
   (service catch + middleware) — near-duplicate stderr entries for one failure.
3. **Repeated blobs.** Each entry may echo the full request (`jsonPayload.keys.*`):
   headers (including `authorization: Bearer …`), query, empty `track`/`device`. This is
   most of the bytes and **none** of the signal — and a credential-leak risk.
4. **Two different trace ids.** The top-level **`trace`** (`projects/P/traces/HEX`, from
   `x-cloud-trace-context`) is the cross-stream join key — group on it. The app's
   `jsonPayload.traceId`/`contextId` (a UUID) is a separate in-process id and will **not**
   join across streams.

## Procedure — triage (the hot path)

Apply the funnel top-down; stop as soon as the view is quiet. Each step is one filter
line; recipes for both console and CLI are in `references/query-cookbook.md`.

1. **Locate** — bound volume by resource + time. The targeting depends on the **service
   archetype** — Gen1 `cloud_function`, Gen2/Cloud Run `cloud_run_revision`, GKE
   `k8s_container`, or AppHub (`apphub.*`). Each has different labels, `logName`, streams,
   and trace behavior; pick the right one from `references/service-archetypes.md`. Example
   (Cloud Run): `resource.type="cloud_run_revision"`, `resource.labels.service_name="…"`,
   `timestamp>=…`.
2. **Pick one stream** — `logName="projects/P/logs/run.googleapis.com%2Fstderr"` for Cloud
   Run app errors, or `…%2Frequests` for one row per request (`/` is encoded `%2F`). GKE
   uses plain `…/logs/stderr`; Gen1 has one merged `…%2Fcloud-functions` stream.
3. **Floor severity** — `severity>="ERROR"` drops INFO lifecycle/middleware logs.
   (Severity is an ordered enum; the quoted form is canonical.)
4. **Narrow to the symptom** — by class/status/downstream:
   `jsonPayload.error.name="TimeoutError"`, `httpRequest.status>=500`,
   `jsonPayload.message:"timed out"`.
5. **Project, never read the blob** — name only the signal fields so the header blob is
   never fetched. CLI: `--format='table(timestamp, resource.labels.revision_name,
   jsonPayload.error.name, jsonPayload.statusCode, jsonPayload.error.message)'`.
   Console: pin those as summary fields.

The fields that constitute "the answer": `…error.name`, `…error.message` (often holds the
offending downstream URL), `…statusCode`, the first application (non-dependency) stack
frame (the call site), `resource.labels.revision_name`, and the GCP `trace`.

**Security guardrail:** never paste, echo, project, or commit the request-headers blob
or any `authorization`/`cookie` value. Field projection (step 5) is the cheapest redaction —
unnamed fields never leave the API. If a token is observed in logs, flag it as disclosed.

## Available script

`scripts/triage-logs.sh` collapses a noisy export into signal and **never prints the
header/track blobs**, so it is safe to run on exports that contain secrets. It accepts a
JSON array (Logs Explorer "Download", or `gcloud logging read --format=json`) or
newline-delimited JSON, from a file or stdin.

```bash
# Offline: a downloaded export → one row per trace (the main noise-cut)
"${CLAUDE_SKILL_DIR}/scripts/triage-logs.sh" downloaded-logs.json

# Live: pipe gcloud straight in, errors only
gcloud logging read 'resource.type="cloud_run_revision" severity>="ERROR"' \
  --project=PROJECT --freshness=2h --limit=500 --format=json \
  | "${CLAUDE_SKILL_DIR}/scripts/triage-logs.sh" --errors

# --flat = one row per entry (exposes the duplication); --json = machine output
"${CLAUDE_SKILL_DIR}/scripts/triage-logs.sh" --flat downloaded-logs.json
```

It groups by GCP `trace`, picks the richest error entry per trace, and prints
`TIME SEV N STREAMS STATUS ERROR SERVICE WHERE MESSAGE TRACE` (`N` = entries collapsed).
Run `--help` for the full interface. Extraction is tuned for a common structured-log
shape (`jsonPayload.message`, `jsonPayload.error.*`) with fallbacks to `httpRequest.*`,
and degrades to `-` on unknown shapes.

## Reduce noise at the source (secondary)

When a class of noise recurs, fix it once. Full guide and confirmed CLI in
`references/reduce-noise-at-source.md`. Order, cheapest/most-important first:

- **Fix the emitter (do first):** stop logging full headers + the Bearer token; log a
  header *allowlist*; omit empty `track`/`params`; collapse duplicate error emits.
- **Severity hygiene:** make `severity` accurate so `>=ERROR` is a clean filter.
- **Exclusion filters:** drop true noise before storage via the `_Default` sink
  (`gcloud logging sinks update _Default --add-exclusion=name=…,filter=…`). Exclusions are
  **not retroactive** and excluded entries are **unrecoverable** — exclude only zero-value
  logs, or keep a fraction with `sample(insertId, 0.95)`.
- **Routing:** send `severity>="ERROR"` to a dedicated bucket/view with longer retention
  instead of excluding logs that still have value.

Decide based on data: run the "count by error class" and "count by severity/stream"
queries (`references/query-cookbook.md`) before excluding anything.

## Top traps

- `logName` percent-encodes `/` as **`%2F`** — `…run.googleapis.com%2Fstderr`.
- The GCP **`trace`** joins streams; the app **`traceId`/`contextId`** does not.
- Cloud Run / Gen 2 Functions = **three streams**; forgetting to pick one keeps the
  duplication.
- **Exclusions and sinks are not retroactive** and exclusions are unrecoverable — never
  the first move, and never on `severity>="ERROR"`.
- `--format` projection (or pinned summary fields) is the cheapest redaction; default
  output drips the header blob and the token into your terminal and history.
- `:` is substring, `=` is exact — use `:`/`=~` for the long `message`/`stack` strings.

## Additional resources

- **`references/service-archetypes.md`** — how to target each platform (Gen1 `cloud_function`,
  Gen2/Cloud Run `cloud_run_revision`, GKE `k8s_container`, AppHub `apphub.*`): resource type,
  labels, `logName`, streams, trace correlation, `level` casing, and per-archetype secrets.
  Shared across all three GCP observability skills.
- **`references/log-anatomy.md`** — `LogEntry` envelope, the three streams, the two trace
  ids, an example structured-log `jsonPayload` field map, and the worked example decoded.
- **`references/query-cookbook.md`** — operator reference, the triage funnel, and
  paste-ready console + `gcloud logging read` recipes.
- **`references/reduce-noise-at-source.md`** — emitter fixes, severity hygiene, exclusion
  filters, and routing, with confirmed `gcloud` syntax.
- **`scripts/triage-logs.sh`** — dedup-by-trace signal extractor that never prints secrets.
