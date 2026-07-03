---
name: error-reporting
description: >-
  Read Google Cloud Error Reporting from the CLI to triage and prioritize error
  groups by blast radius. Use when the user pastes a Cloud Error Reporting console
  URL (console.cloud.google.com/errors or /errors/detail/<groupId>), or asks "which
  errors are worst", "rank errors by occurrences/affected users", "what are the error
  groups for service X", "blast radius of this error", "is this error still
  happening / on which revision", "get the error group", or "show errors for
  orders-api". gcloud has no command for this, so the skill calls the Error
  Reporting REST API with a gcloud access token (handling a corporate CA if
  present): rank
  groups (groupStats.list), read a group's representative stack (detail), list recent
  occurrences (events.list), and parse /errors URLs to a group id. It is read-only
  (no resolution-status changes) and the entry point that hands a group id to
  error-trace-rootcause for the trace trail and code. Do NOT use to root-cause one
  error down to a trace/code (that is error-trace-rootcause), to reduce log noise or
  write log queries (that is gcp-log-triage), to author app-side instrumentation, or
  for non-GCP error trackers (Sentry, Rollbar, Bugsnag).
---

# Triage Google Cloud Error Reporting from the CLI

Error Reporting is the prioritization layer above logs: it groups identical errors and
counts them, answering **which** errors matter and **how badly** (blast radius), not *why*.
This skill reads it from the terminal — rank groups, inspect a group, list occurrences,
parse `/errors` URLs — then hands the group id down to the debugging skills.

It is the front door of the trio: **`error-reporting` (rank/triage) → `error-trace-rootcause`
(group→trace→trail→code) ⇄ `gcp-log-triage` (noise/queries)**.

## Use this skill when

- a Cloud Error Reporting console URL is pasted (`/errors` or `/errors/detail/<groupId>`)
- the ask is to rank/triage error groups, gauge blast radius, or check if/where an error
  is still firing
- a group's representative stack or recent occurrences are needed before debugging

## Do not use this skill when

- one specific error needs root-causing to a **trace and code** — that is
  `error-trace-rootcause` (hand it the group id)
- the goal is **log-noise reduction or query writing** — that is `gcp-log-triage`
- the task is **app-side instrumentation** (application logging setup) or metrics/SLO config
- the error tracker is **not** Google Cloud Error Reporting (Sentry, Rollbar, Bugsnag)

## Key facts (non-obvious)

- **gcloud cannot list error groups.** Its only Error Reporting surface is
  `gcloud beta error-reporting events` (report/delete). Group/stat/event **reads** go
  through the REST API `clouderrorreporting.googleapis.com` with a gcloud token.
- **No trace in Error Reporting.** `ErrorEvent`/`ErrorContext` carry the stack,
  `reportLocation`, and `httpRequest` — but **no Cloud Logging `trace`**. The join key to
  logs is the **group id**: Error Reporting `group.groupId` == the `errorGroups.id` log
  field. Pivot to logs to get a trace.
- **Custom CA (corporate proxy).** If you are behind a corporate proxy with a custom CA
  bundle, raw `curl` needs the gcloud-configured CA (`core/custom_ca_certs_file`); the
  bundled script passes it automatically when set.
- **`reportLocation`/`affectedUsersCount` are often null** for Node services using a
  structured JSON logger (e.g. pino / winston / bunyan) — the call site is in the stack
  `message`; rank by count/lifespan/services.
- **`MUTED` groups are excluded from rankings by default** — a quiet `list` may be hiding a
  muted known issue.

## Procedure

1. **Get to a project + filter.** From a console URL: `scripts/errors-url-to-query.sh 'URL'`
   (or `--cmd` to emit the matching `error-groups.sh` call). Otherwise take `--project` +
   `--service` (and `--version`) directly.
2. **Rank or inspect.**
   - `scripts/error-groups.sh list --project P --service SVC [--version V] [--resource-type
     cloud_function|cloud_run_revision|k8s_container] [--period 1d]` — groups ranked by blast
     radius. (Mind the archetype: `--project acme-services` for Functions/Cloud Run,
     `acme-prod` for GKE; for GKE `--service` is the reported otel service.)
   - `scripts/error-groups.sh detail GROUP_ID --project P [--period 1w]` — one group's
     stats + representative stack.
   - `scripts/error-groups.sh events GROUP_ID --project P` — recent occurrences + the
     **revision** they fire on.
3. **Prioritize by blast radius, not raw count** — weigh `count`, `affectedUsersCount`,
   `firstSeen`↔`lastSeen` (regression vs chronic; re-sort `--order LAST_SEEN_DESC`/
   `CREATED_DESC`), and `numAffectedServices`. Always state the `--period`; counts scale
   with it. Detail in `references/triage-workflow.md`.
4. **Hand off.** Pass the group id to `error-trace-rootcause` (it runs
   `errorGroups.id="GROUP_ID"` in Cloud Logging, picks a log occurrence that *does* carry a
   `trace`, pulls the trail, and maps to code). Use `gcp-log-triage` to de-noise/quantify
   around it.

## Available scripts

- `scripts/errors-url-to-query.sh` — parse a `/errors` or `/errors/detail/<id>` console URL
  into `PROJECT`/`GROUP_ID`/`SERVICE`/`VERSION`/`LOCATION`, or (`--cmd`) emit a runnable
  `error-groups.sh` command. No network.
- `scripts/error-groups.sh` — `list` / `detail` / `events` against the Error Reporting REST
  API using a gcloud token + the configured corporate CA. Projects only safe fields (never
  `httpRequest`/`remoteIp`/user). `--json` for machine output; `--dry-run` (and auto when
  gcloud/token is absent) prints the `curl` command. Requires `jq`; live calls need an
  authenticated `gcloud` with access to the project.

## Top traps

- gcloud has no `groups`/`groupStats` command — use the REST API (the script does).
- Error Reporting has **no trace** — pivot via `errorGroups.id` in logs for a trail.
- Counts scale with `--period`; a group is "173/day" *and* "1474/week" — state the window.
- `MUTED` groups vanish from `list`; check `groups.get` status if a known error is missing.
- `affectedUsersCount`/`reportLocation` often null here — do not treat null as zero impact.
- **Read-only:** never change resolution status or attach issues from this skill.

## Additional resources

- **`references/api-reference.md`** — the REST endpoints (`groupStats.list`, `events.list`,
  `groups.get`), params, response fields, auth + corporate CA, the no-trace/gcloud-limits
  facts, and raw `curl` recipes.
- **`references/triage-workflow.md`** — entry points, blast-radius prioritization, reading
  the representative, the hand-off pipeline, and the live worked example.
