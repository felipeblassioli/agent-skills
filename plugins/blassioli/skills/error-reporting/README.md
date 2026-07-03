# error-reporting

A skill for **triaging Google Cloud Error Reporting from the
CLI** — ranking error groups by blast radius and turning a console `/errors` URL into a
group you can act on. It is the prioritization front door of the GCP debugging trio:

```
error-reporting (rank/triage)  →  error-trace-rootcause (group→trace→trail→code)
                                ⇅
                          gcp-log-triage (noise / queries)
```

> ⚠️ Experimental. **Read-only** — it never changes resolution status or attaches issues.

## Why this skill exists

The Cloud console `/errors` page (Error Reporting) groups identical errors and counts
them — the fastest way to see *which* error matters and *how badly*. But **gcloud has no
command to read it**, and the API exposes **no Cloud Logging trace**, so it can't follow a
request on its own. This skill fills the gap: it reads Error Reporting over its REST API
with gcloud's own credentials (and a custom CA when behind a corporate proxy), ranks groups
by blast radius, and hands the group id to `error-trace-rootcause` — which pivots through
logs (`errorGroups.id`) to a trace, the full request trail, and the code.

## What it covers

| Area | Where |
|---|---|
| REST endpoints, params, response fields, auth + CA, no-trace/gcloud-limits, `curl` recipes | `references/api-reference.md` |
| Entry points, blast-radius prioritization, reading the representative, hand-off | `references/triage-workflow.md` |
| `/errors` URL → project/groupId/service/version (or a runnable command) | `scripts/errors-url-to-query.sh` |
| `list` / `detail` / `events` against the REST API (safe-field projection) | `scripts/error-groups.sh` |

## The bundled scripts

```bash
# Console URL → parts (or --cmd for a runnable error-groups.sh call)
scripts/errors-url-to-query.sh 'https://console.cloud.google.com/errors/detail/Cx1a2b3c4d5e6f;service=orders-api?project=acme-services'

# Rank a service's error groups by blast radius
scripts/error-groups.sh list --project acme-services --service orders-api --period 1d

# One group's stats + representative stack, and recent occurrences (+ revision)
scripts/error-groups.sh detail Cx1a2b3c4d5e6f --project acme-services --period 1w
scripts/error-groups.sh events Cx1a2b3c4d5e6f --project acme-services
```

`error-groups.sh` calls `clouderrorreporting.googleapis.com` with
`gcloud auth print-access-token` and the gcloud-configured CA (`core/custom_ca_certs_file`,
used when behind a corporate proxy with a custom CA bundle). It projects only safe fields —
never `httpRequest`, `remoteIp`, or user — and prints the `curl` command instead of calling
when `gcloud` is unavailable (`--dry-run`). Requires `jq`; live calls need an authenticated
`gcloud` with project access.

## Scope

Use it to **read and prioritize** Google Cloud Error Reporting. It is **not** for:
root-causing one error to a trace/code (use `error-trace-rootcause` with the group id),
log-noise reduction / query writing (`gcp-log-triage`), app-side instrumentation
(application logging setup), or non-GCP error trackers (Sentry, Rollbar, Bugsnag).

See `CHANGELOG.md` for version history and `metadata.json` for source contracts.
