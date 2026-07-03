---
name: error-trace-rootcause
description: >-
  Root-cause a production error from Google Cloud Logging by correlating it into a
  single request's log trail and locating the offending code. Use when the user has
  an error and wants the bug behind it: pastes a Logs Explorer console URL or an
  Error Reporting group filter (errorGroups.id / error_groups.id), asks to "find the
  bug from this error", "root cause this", "what's causing this error group", "follow
  the trace", "build the log trail", or "trace='projects/…/traces/…'". The workflow
  picks a representative occurrence, pulls the full trace trail, reconstructs the causal
  chain, and maps the stack to source (local repo first, then a GitHub org you pass
  via gh); it produces a read-only root-cause report and does NOT write fixes. Do NOT
  use this skill to "write a Logs Explorer query" or "reduce log noise" (that is
  gcp-log-triage), or to "rank which error groups are worst / by blast radius" (that is
  error-reporting); this skill starts once a specific error is in hand. Also not for
  app-side logging/OpenTelemetry instrumentation, metrics/SLO/alerting, or non-GCP log
  systems (Datadog, ELK, CloudWatch).
---

# Root-cause a Cloud Logging error via its trace trail

A production error in Cloud Logging is the *symptom*. The bug is found by correlating
that error into the full trail of the one request that produced it, reading the causal
chain, and landing on the code. This skill does that end to end and stops at a **read-only
diagnosis** — it locates and explains the bug; it does not write the fix.

It is the debugging counterpart to `gcp-log-triage`: triage finds *which* error matters
and cuts noise; this skill takes one error and answers *why*.

## Use this skill when

- the user has an error (a console URL, an `errorGroups.id` filter, a raw query, a
  `trace=…`, or a pasted log) and wants the bug behind it / a root cause
- the request is "follow the trace", "build the log trail", "correlate these logs", or
  "what's actually causing this"
- an Error Reporting group needs to be turned into a concrete, code-level diagnosis

## Do not use this skill when

- the goal is to **reduce log noise / write queries** in general — that is `gcp-log-triage`
- the task is authoring **app-side logging/OTel instrumentation**
- the task is **metrics, SLOs, or alerting** config
- the logs are **not** Google Cloud Logging (Datadog, ELK, CloudWatch, raw files)
- the user wants the **fix written/applied** — diagnose and locate, then hand off

## Inputs and normalization

Any of these is a valid starting point; all reduce to one trace:

| Input | Normalize with |
|---|---|
| Logs Explorer **console URL** | `scripts/logs-url-to-filter.sh 'URL'` → filter + project + window |
| raw **UI query** string | `scripts/logs-url-to-filter.sh -` (decode + normalize `error_groups.id`) |
| **error group** id | use `errorGroups.id="…"` as the representative-search filter |
| an **Error Reporting** console URL | resolve the group id + blast radius with the `error-reporting` skill first, then use its `errorGroups.id="…"` here |
| a **trace** / pasted log | skip to the trail (read `.trace` from a pasted entry) |

Console URLs **double-encode** the filter (`/` → `%252F`, newlines → `%0A`); the parser
decodes them in one pass and normalizes the console alias `error_groups.id` to the
queryable `errorGroups.id`.

## Procedure

1. **Normalize the input** to a `gcloud` filter + project + time window
   (`logs-url-to-filter.sh`).
2. **Pick a representative occurrence.** An error group aggregates many occurrences;
   debug **one** — prefer the most recent occurrence that has a non-empty `trace` and a
   full `jsonPayload.data.error.stack`, on the revision being inspected. Read its `trace`.
3. **Pull the full trail.** Pivot on the **correlation key for the archetype**: the GCP
   `trace="projects/P/traces/HEX"` for Cloud Run / Firebase Functions, or
   `jsonPayload.traceId="UUID"` for **GKE** (`k8s_container` has no top-level trace — see
   `references/service-archetypes.md` in the `gcp-log-triage` skill). Pull it with **no
   severity floor and no stream filter**, ordered **ascending**. Steps 2–3 are automated by
   `scripts/trace-trail.sh`: `--filter` auto-detects the key from the representative (trace
   if present, else `jsonPayload.traceId`); `--trace`/`--app-id` pull directly (a UUID
   passed to `--trace` is auto-treated as a GKE app id); `--render` formats JSON you have.
4. **Read the causal chain.** Order oldest-first; find the **first** failure (not the
   loudest/last), the last good step before a large `+ms` gap, the `error.cause` chain,
   and `Promise.all (index N)` fan-out / retry / timeout-mismatch signals. If the message
   names a downstream URL, that downstream is the suspect. Full method in
   `references/correlation-playbook.md`.
5. **Locate the code (read-only, local → gh).** Strip `/workspace/` from the first
   non-`node_modules` stack frame to get the repo-relative path; keep the function name.
   Grep the local workspace first (the service's repo/dir or the path/symbol); if absent,
   resolve the repo in a GitHub org you pass and read it via `gh` — no clone. Pin the
   deployed revision and beware `.js`-vs-`.ts` line drift (match by symbol, not line).
   Details in `references/locate-code.md`.
6. **Deliver a root-cause report** (below) and hand off. Do not write the fix.

## Correlation fallbacks (when the trace doesn't span the flow)

- **Async / jobs / Pub/Sub:** the GCP `trace` fragments per hop — correlate on
  `jsonPayload.traceId`/`contextId` (in-process) and `event.id`/`correlation_id` (across
  hops).
- **Cross-service:** if `traceparent` propagated, the **same trace** appears in the
  callee's logs — query that service for it. Across projects (e.g. `acme-services` →
  `acme-prod`) it usually does not propagate; correlate by timestamp + downstream
  identifiers.
- **`gcloud` rejects `errorGroups.id`:** drop the clause and rely on
  service + revision + stderr + `severity>="ERROR"` + window, matching by error name.
  `trace-trail.sh` retries this automatically.

## The root-cause report (deliverable)

Produce: (1) **error identity** (group id, name, message, `statusCode`, frequency if
known); (2) **the ordered trail** (trace, revision); (3) **root cause** in 1–2 sentences
(the first failure and why); (4) **location** — `file:line` or a GitHub permalink at the
pinned ref + the snippet, noting any line-number approximation; (5) **hypothesis &
direction** (the kind of fix indicated) **without** the patch; (6) **handoff** — to a
human or a fixing skill/agent. Quantify blast radius with the `error-reporting` skill
(group occurrence counts, affected users, services) and de-noise with `gcp-log-triage`
before prioritizing.

## Available scripts

- `scripts/logs-url-to-filter.sh` — Logs Explorer console URL (or pasted query) →
  `gcloud` filter + project + absolute time window; normalizes `error_groups.id`. `--gcloud`
  prints a runnable command; `--help` for the interface.
- `scripts/trace-trail.sh` — the correlation core: `--filter 'F'` picks a representative
  and pivots to its trace; `--trace HEX` pulls a trail directly; `--render` formats a JSON
  array on stdin. Orders ascending with `+ms` offsets and **never prints header/track
  blobs** (safe on token-bearing data). Falls back to `--dry-run` (prints the `gcloud`
  commands) when `gcloud` is absent.

## Top traps

- Debug **one trail**, not the aggregate error group.
- The top stderr line is usually the **outer catch**, not the origin — walk to the first
  failure.
- Blame the **downstream named in the message**, not the service that logged the error.
- `errorGroups.id` is the queryable field (console alias `error_groups.id`); gcloud support
  is not guaranteed.
- Read line numbers only from the **revision that produced the trace**, and match by
  **symbol** because the stack's `.js` line may not map to the `.ts` source.
- **Scope:** locate and explain; never write or apply the fix here.

## Additional resources

- **`references/correlation-playbook.md`** — entry points, representative selection,
  pulling/reading the trail, the worked example as a chain, async/cross-service fallbacks.
- **`references/locate-code.md`** — stack frame → repo-relative path, service→repo mapping,
  local→`gh` resolution, version pinning, the `.js`/`.ts` caveat, and the report template.
