# gcp-log-triage

A skill for **using Google Cloud Logging effectively to handle noisy logs**. It helps
find the real error fast, write good Logs Explorer / `gcloud` queries, dedup the
multi-stream fan-out by trace, and — when noise recurs — reduce it at the source. The
technique is generic GCP; the field paths are an example structured-log shape (e.g. pino /
winston / bunyan) — adapt them to your own logger.

> ⚠️ Experimental / unproven. Use at your own risk.

## Why this skill exists

A single failed request to a Cloud Run / Gen 2 Functions service routinely produces
**multiple log entries**: one platform access log plus app logs on both stdout and
stderr, the same error often re-emitted at several layers, and each entry repeating the
**entire request header set** (including `authorization: Bearer …`) and empty device
objects. The actual diagnosis — what failed, where, why — is ~5 fields drowning in
hundreds of lines. This skill makes those 5 fields cheap to extract and shows how to stop
generating the noise.

## What it covers

| Area | Where |
|---|---|
| The noise model + field map (envelope, 3 streams, 2 trace ids, signal vs blob) | `references/log-anatomy.md` |
| Query operators + the triage funnel + paste-ready console & `gcloud` recipes | `references/query-cookbook.md` |
| Source-side reduction: emitter fixes, severity, exclusions, routing | `references/reduce-noise-at-source.md` |
| Offline/online dedup-by-trace extractor (never prints secrets) | `scripts/triage-logs.sh` |

## The bundled script

```bash
# A downloaded Logs Explorer export → one row per trace
scripts/triage-logs.sh downloaded-logs.json

# Pipe gcloud straight in (errors only)
gcloud logging read 'resource.type="cloud_run_revision" severity>="ERROR"' \
  --project=PROJECT --freshness=2h --limit=500 --format=json \
  | scripts/triage-logs.sh --errors

scripts/triage-logs.sh --help   # full interface
```

`triage-logs.sh` reads a JSON array (console "Download" or `gcloud … --format=json`) or
newline-delimited JSON, collapses entries by GCP `trace`, and prints
`TIME SEV N STREAMS STATUS ERROR SERVICE WHERE MESSAGE TRACE`. It **never** emits the
`headers`/`context` blobs, so it is safe on exports that contain bearer tokens. Requires
`jq`.

## Security note

Exports of these logs contain live credentials (the `authorization` Bearer JWT is logged
verbatim on every entry). Treat downloaded log files as sensitive, never paste header
blobs, and prefer `--format` field projection — unnamed fields never leave the API. If a
token is observed in logs, treat it as disclosed and rotate it.

## Scope

Use it for triaging and reducing noise in **Google Cloud Logging**. It is **not** for
authoring app-side logging/OpenTelemetry instrumentation, for metrics/SLO/alerting config,
or for non-GCP log systems (Datadog, ELK, CloudWatch).

See `CHANGELOG.md` for version history and `metadata.json` for source contracts.
