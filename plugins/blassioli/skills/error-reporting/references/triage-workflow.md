# Error Reporting triage workflow

Error Reporting answers "**which** errors matter and **how badly**" — the prioritization
layer above logs. It does not answer "why" (no trace, no full request). Use it to pick the
target, then hand the group id down to `error-trace-rootcause` (trace → trail → code) and
`gcp-log-triage` (noise/queries).

```
Error Reporting ── rank groups by blast radius ──▶ pick a group id
        │                                                │
        │ (errorGroups.id = group.groupId)               ▼
        └──────────────────────────────▶ error-trace-rootcause ──▶ code/root cause
                                                         ▲
                                          gcp-log-triage ┘ (cut noise, quantify per-trace)
```

## Step 1 — get to a project + filter

| Input | Move |
|---|---|
| `/errors/detail/<id>;service=…;version=…?project=…` | `errors-url-to-query.sh 'URL'` → `GROUP_ID` + project/service/version → `error-groups.sh detail <id>` |
| `/errors;service=…;version=…?project=…` (list view) | `errors-url-to-query.sh 'URL'` → `error-groups.sh list --service …` |
| "worst errors for service X" | `error-groups.sh list --project P --service X` |
| a bare group id | `error-groups.sh detail <id> --project P` and `events <id>` |

`errors-url-to-query.sh --cmd 'URL'` prints the matching `error-groups.sh` invocation
directly.

**Archetype notes.** Pick the right `--project` (Functions/Cloud Run → `acme-services`, GKE →
`acme-prod`) and optionally narrow with `--resource-type cloud_function |
cloud_run_revision | k8s_container`. The `--service` value is the Error Reporting
`serviceContext.service`: a `service_name`/`function_name` for Functions/Cloud Run, but the
**reported app/otel service** for GKE (e.g. `orders-api-prod-web`), not the k8s namespace. See
`service-archetypes.md` (in `gcp-log-triage`) for the full matrix.

## Step 2 — rank by blast radius (not just count)

`list` defaults to `COUNT_DESC`. Count alone is misleading — weigh four signals together:

- **`count`** — raw volume in the window. High count can still be one noisy retry loop.
- **`affectedUsersCount`** — user-facing impact. A lower-count group hitting many distinct
  users usually outranks a high-count background-job error. (Null when the app does not
  report user context — common for Node services; fall back to the other signals.)
- **`firstSeenTime` vs `lastSeenTime`** — a recent `firstSeen` = a **regression** (likely a
  new deploy); an old `firstSeen` still firing = **chronic**. Re-sort with
  `--order LAST_SEEN_DESC` to surface what is active now, `CREATED_DESC` for new groups.
- **`numAffectedServices`** — a group seen across many services points at a shared library
  or a common downstream, not one service's bug.

Always pick a **window** (`--period`) and state it — counts scale with it (a group can be
173/day and 1474/week).

## Step 3 — read the representative, locate the version

`detail` returns the representative stack (`error` = first line) and, when populated,
`reportLocation`. For Node services using a structured JSON logger (e.g. pino / winston /
bunyan) the stack lives in the **message** and `reportLocation` is often null — read the
message's first non-`node_modules` `/workspace/` frame instead (the `error-trace-rootcause`
skill does this).

Run `events <id>` to confirm the group is **still firing** and on **which revision**
(`serviceContext.version`). Read code against that revision — not `main`.

## Step 4 — hand off

- **Root cause one occurrence:** pass the group id to `error-trace-rootcause`. It runs
  `errorGroups.id="GROUP_ID"` in Cloud Logging, picks a representative log entry (which —
  unlike Error Reporting — carries the `trace`), pulls the full request trail, and maps the
  stack to source.
- **Quantify / de-noise around it:** `gcp-log-triage` collapses the per-request log fan-out
  and counts traces, complementing Error Reporting's per-group counts.

## Worked example (`acme-services` data, 2026-06-15)

`error-groups.sh list --project acme-services --service orders-api --period 1d`:

| groupId | count | services | firstSeen | error |
|---|---|---|---|---|
| `Cy7f8e9d0c1b2a` | 261 | 2 | 2026-04-09 | `#orderLookupService.getOrderById` |
| `Cx1a2b3c4d5e6f` | 173 | 2 | 2026-04-09 | `#orderLookupService.getOrderById` |
| `Cz3d4c5b6a7089` | 28 | 2 | 2023-09-28 | `Error while fetching downstream product data` |

Reading: the two top groups are the **same symptom** (`getOrderById`) split across two
Error Reporting signatures — both chronic (firstSeen April, still firing). `events
Cx1a2b3c4d5e6f` shows current occurrences on revision `orders-api-00064-ceq`. Handing
`Cx1a2b3c4d5e6f` to `error-trace-rootcause` pivots to a trace and lands on the downstream
`/orders` timeout in `getOrderById` — the root cause, confirmed once, for a group
that Error Reporting shows is **1474 occurrences / 6 services over a week**. That blast-radius
number is the case for prioritizing the fix.

## Gotchas

- gcloud cannot list groups — the REST API does (see `references/api-reference.md`).
- No `trace` in Error Reporting — always pivot through logs by group id for the trail.
- `MUTED` groups are hidden from `list` by default — a clean ranking may be hiding a muted
  known issue.
- `affectedUsersCount`/`reportLocation` are frequently null for these services — lean on
  count, lifespan, services, and the message.
- This skill is **read-only**: it never changes resolution status or attaches issues.
