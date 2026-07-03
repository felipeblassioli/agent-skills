# Error Reporting REST API reference (read paths)

Verified against the official docs and a live read-only call to `acme-services` on 2026-06-15.

## Why the REST API (not gcloud)

`gcloud` has **no** command to list or inspect error groups. The only native surface is
`gcloud beta error-reporting events` (`report`, `delete`) — useful for sending or wiping
events, useless for triage. So group/stat/event reads go through the REST API
`clouderrorreporting.googleapis.com`, authenticated with a gcloud-minted token:

```bash
curl -sS -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  [--cacert "$(gcloud config get-value core/custom_ca_certs_file)"] \
  "https://clouderrorreporting.googleapis.com/v1beta1/projects/PROJECT/groupStats?..."
```

**Custom CA (corporate proxy):** if you are behind a corporate proxy with a custom CA
bundle, raw `curl` needs the CA bundle that gcloud is configured with
(`core/custom_ca_certs_file`, e.g. `~/certs/custom-ca-bundle.pem`). gcloud injects it
automatically; `curl` does not. `scripts/error-groups.sh` reads it from gcloud config and
passes `--cacert` for you when it is set.

**The integration fact:** Error Reporting exposes the representative stack, `reportLocation`
(file/line/function), and `httpRequest` — but **no Cloud Logging `trace` id**, anywhere in
`ErrorEvent`/`ErrorContext`. The join key between Error Reporting and Cloud Logging is the
**group id**: the Error Reporting `group.groupId` is identical to the `errorGroups.id` field
on log entries. To get a trace, pivot to logs (`errorGroups.id="GROUP_ID"`) — that is the
`error-trace-rootcause` skill's job.

## `projects.groupStats.list` — rank/triage groups

```
GET .../v1beta1/projects/{PROJECT}/groupStats
```
Query params:

| Param | Notes |
|---|---|
| `groupId` (repeatable) | restrict to specific group ids (used by `detail`) |
| `serviceFilter.service` | service name, e.g. `orders-api` |
| `serviceFilter.version` | version/revision, e.g. `orders-api-00045-xid` |
| `serviceFilter.resourceType` | e.g. `cloud_run_revision` |
| `timeRange.period` | `PERIOD_1_HOUR`, `PERIOD_6_HOURS`, `PERIOD_1_DAY`, `PERIOD_1_WEEK`, `PERIOD_30_DAYS` |
| `order` | `COUNT_DESC` (default), `LAST_SEEN_DESC`, `CREATED_DESC`, `AFFECTED_USERS_DESC` — the last only ranks meaningfully when user context is reported (often null for Node services) |
| `timedCountDuration`, `alignment`, `alignmentTime` | shape the `timedCounts` sparkline buckets |
| `pageSize` (default 20), `pageToken` | pagination |

`ErrorGroupStats` response (`errorGroupStats[]`), signal fields:

| Field | Meaning |
|---|---|
| `group.groupId` | the join key (== `errorGroups.id` in logs) |
| `count` | occurrences in the window (string int) |
| `affectedUsersCount` | distinct users, when user context is reported (often null) |
| `firstSeenTime` / `lastSeenTime` | lifespan — `firstSeen` long ago + active `lastSeen` = chronic |
| `numAffectedServices` / `affectedServices[]` | how many services emit this group |
| `timedCounts[]` | the time-bucketed counts (the console sparkline) |
| `representative` | an `ErrorEvent` — canonical stack + context for the group |

> Period scales the counts: live, group `Cx1a2b3c4d5e6f` showed **173 / 2 services** over
> `PERIOD_1_DAY` and **1474 / 6 services** over `PERIOD_1_WEEK`. Always state the window.

## `projects.events.list` — recent occurrences

```
GET .../v1beta1/projects/{PROJECT}/events
```
`groupId` is **required**; also accepts `serviceFilter.*`, `timeRange.period`, `pageSize`,
`pageToken`. Returns `errorEvents[]` of `ErrorEvent`:

| Field | Meaning |
|---|---|
| `eventTime` | when this occurrence happened |
| `serviceContext.{service,version,resourceType}` | which deploy emitted it (e.g. the revision) |
| `message` | the stack trace string (for Node, the call site lives here, not in reportLocation) |
| `context.reportLocation.{filePath,lineNumber,functionName}` | call site when populated (often null for Node) |
| `context.httpRequest.{method,url,responseStatusCode,userAgent,remoteIp,referrer}` | request context — `remoteIp`/`userAgent` are PII; do **not** echo them |
| `context.user`, `context.sourceReferences[]` | user id (if reported); source repo refs |

Use `events.list` to confirm a group is still firing and on which **revision** (the
`serviceContext.version` is the deployed revision to read code against).

## `projects.groups.get` — group metadata (read)

```
GET .../v1beta1/projects/{PROJECT}/groups/{GROUP_ID}
```
`ErrorGroup`: `name`, `groupId`, `trackingIssues[]` (links to external issue trackers),
`resolutionStatus` ∈ `OPEN` (default) | `ACKNOWLEDGED` | `RESOLVED` | `MUTED`.

> **`MUTED` groups are excluded from `groupStats.list` by default** — a quiet `list` does
> not mean "no errors", it may mean "muted". Check group status when a known error is
> missing from the ranking. (Changing status is `groups.update`/PUT — out of scope for this
> read-only skill.)

## Quick raw recipes

```bash
P=acme-services; CA="$(gcloud config get-value core/custom_ca_certs_file)"
H=(-H "Authorization: Bearer $(gcloud auth print-access-token)" --cacert "$CA")
B="https://clouderrorreporting.googleapis.com/v1beta1/projects/$P"

# rank a service's groups by occurrences (last day)
curl -sS "${H[@]}" "$B/groupStats?serviceFilter.service=orders-api&timeRange.period=PERIOD_1_DAY&order=COUNT_DESC&pageSize=10" \
  | jq '.errorGroupStats[] | {id:.group.groupId, count, firstSeen:.firstSeenTime, lastSeen:.lastSeenTime, err:(.representative.message|split("\n")[0])}'

# one group's lifespan/blast radius over a week
curl -sS "${H[@]}" "$B/groupStats?groupId=Cx1a2b3c4d5e6f&timeRange.period=PERIOD_1_WEEK" | jq '.errorGroupStats[0] | {count, numAffectedServices, firstSeenTime, lastSeenTime}'

# group resolution status
curl -sS "${H[@]}" "$B/groups/Cx1a2b3c4d5e6f" | jq '{resolutionStatus, trackingIssues}'
```
