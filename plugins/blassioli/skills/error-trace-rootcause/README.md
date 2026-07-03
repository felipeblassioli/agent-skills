# error-trace-rootcause

Sandbox (blassioli) skill that turns a **Google Cloud Logging error into a
code-level root cause** by correlating it into one request's trace trail. Given an error
group, a Logs Explorer URL, a query, or a trace, it picks a representative occurrence,
pulls the full ordered trail for that trace, reads the causal chain, and locates the
offending code (local repo first, then a GitHub org you pass via `gh`).

It is the debugging counterpart to **`gcp-log-triage`**: triage cuts noise and finds
*which* error matters; this skill takes one error and answers *why*.

> ⚠️ Sandbox tier: experimental, unproven, not SRE-supported. Use at your own risk.
> **Read-only:** it locates and explains the bug — it does not write or apply fixes.

## Why this skill exists

An Error Reporting group is an aggregate; a bug lives in one concrete request. The leap
from "this error fired 200 times" to "here is the line and here is why" is the trace
pivot: take one occurrence, read its `trace`, and pull every entry that shares it —
across the stdout/stderr/requests streams and any trace-propagated downstream — into a
single ordered story. This skill encodes that pivot, the rules for reading the chain, and
the mapping from a `/workspace/...` stack frame back to source.

## What it covers

| Area | Where |
|---|---|
| Entry points, representative selection, reading the trail, async/cross-service fallbacks | `references/correlation-playbook.md` |
| Stack frame → repo (Cloud Run vs Firebase Functions), local→`gh` resolution, version pinning, `.js`/`.ts` drift, report template | `references/locate-code.md` |
| Console URL / pasted query → `gcloud` filter + project + window | `scripts/logs-url-to-filter.sh` |
| Representative selection + trace-trail assembly + ordered rendering | `scripts/trace-trail.sh` |

## The bundled scripts

```bash
# Console URL → ready-to-run gcloud command
scripts/logs-url-to-filter.sh --gcloud 'https://console.cloud.google.com/logs/query;query=…?project=acme-services'

# Error group → representative occurrence → full ordered trail
scripts/trace-trail.sh --project acme-services --filter 'errorGroups.id="CKfmhY3Kv8vOVQ"'

# A trace directly
scripts/trace-trail.sh --project acme-services --trace e3e9e9c5dbd83b4447dea411d467e52d

# Format a JSON array you already fetched (no gcloud)
gcloud logging read 'trace="projects/acme-services/traces/HEX"' --format=json | scripts/trace-trail.sh --render
```

`trace-trail.sh` orders the trail oldest-first with `+ms` offsets and **never prints the
request `headers`/`track` blobs**, so it is safe on data containing Authorization tokens.
When `gcloud` is unavailable it prints the exact commands to run instead. Both scripts
require `jq`; live fetches require an authenticated `gcloud` (and `gh` for remote source).

## Scope

Use it to root-cause **Google Cloud Logging** errors down to the code. It is **read-only**
(diagnose + locate, then hand off) and is **not** for: general log-noise reduction / query
writing (use `gcp-log-triage`), authoring app-side logging/OpenTelemetry instrumentation,
metrics/SLO/alerting config, or non-GCP log systems.

See `CHANGELOG.md` for version history and `metadata.json` for source contracts.
