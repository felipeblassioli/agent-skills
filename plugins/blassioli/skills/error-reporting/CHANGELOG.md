# Changelog

## 0.3.0 - 2026-06-15

### Added

- `evals/evals.json` — 8 edge cases (5 traps incl. gcloud-has-no-groups, no-trace-handoff,
  safe-fields-no-PII, and read-only-no-status-mutation; 1 discrimination control; 2
  over-trigger controls).
- `evals/baselines/2026-06-15-iter1.{md,benchmark.json}` — committed baseline evidence.

### Evidence

- With-skill **96.4%** (27/28) vs baseline **46.4%** (13/28) = **+50.0 pts**;
  model claude-opus-4-8, 2026-06-15 (see the baseline snapshot). Both safety assertions
  held with-skill: PII field-projection (3/3) and the read-only refusal of
  `resolutionStatus` mutation (3/3). One known grading-artifact flaw tracked for
  iteration 2 (when ranking live, briefly restate the REST/token access path).

### Note

- The `skill-auditor` mis-trigger seam on the shared "error group" vocabulary was
  addressed from the sibling side in `error-trace-rootcause` 0.3.0 (its anti-trigger now
  routes ranking here, not to `gcp-log-triage`). This skill's description was unchanged;
  optimizer-tuning against the new eval suite is the iteration-2 candidate.

## 0.2.0 - 2026-06-15

### Added

- `scripts/error-groups.sh --resource-type` (serviceFilter.resourceType:
  `cloud_function` | `cloud_run_revision` | `k8s_container`) to scope error groups to a
  service archetype.

### Changed

- `references/triage-workflow.md` documents per-archetype targeting: pick the right
  `--project` (Functions/Cloud Run → `acme-services`, GKE → `acme-prod`) and note that the
  Error Reporting `--service` (`serviceContext.service`) is the reported app/otel service for
  GKE (e.g. `orders-api-prod-web`), not the k8s namespace. Routes to `service-archetypes.md`
  (in `gcp-log-triage`) for the full matrix.

## 0.1.0 - 2026-06-15

### Added

- Initial release. A read-only skill to triage Google Cloud Error Reporting from the
  CLI — the prioritization front door of the GCP debugging trio (`error-reporting` →
  `error-trace-rootcause` ⇄ `gcp-log-triage`). Built from real `acme-services` /
  `orders-api` console URLs and verified against the live Error Reporting API.
- `SKILL.md`: when/when-not, the non-obvious facts (gcloud is events-only; no trace in
  Error Reporting; group id is the join key to logs; custom CA behind a corporate proxy; null
  reportLocation/affectedUsers; MUTED groups hidden by default), the four-step procedure
  (URL/inputs → rank/inspect → prioritize by blast radius → hand off the group id), the
  scripts, and traps. Read-only by design.
- `references/api-reference.md`: the REST endpoints (`groupStats.list`, `events.list`,
  `groups.get`), every query param, the response/`ErrorEvent`/`ErrorGroup` fields, auth +
  corporate-CA handling, the no-trace and gcloud-limits facts, the `resolutionStatus`
  enum (OPEN/ACKNOWLEDGED/RESOLVED/MUTED), and raw `curl` recipes.
- `references/triage-workflow.md`: entry points/URL parsing, blast-radius prioritization
  (count vs affected users vs lifespan vs services), reading the representative + the
  firing revision, the hand-off pipeline, and the live worked example.
- `scripts/errors-url-to-query.sh`: parses `/errors` and `/errors/detail/<groupId>`
  console URLs into `PROJECT`/`GROUP_ID`/`SERVICE`/`VERSION`/`LOCATION`, or emits a
  runnable `error-groups.sh` command (`--cmd`). BSD/GNU-portable; no network.
- `scripts/error-groups.sh`: `list` / `detail` / `events` against the Error Reporting
  REST API using a gcloud token and the configured custom CA (when behind a corporate
  proxy). Friendly `--period` (1h/6h/1d/1w/30d), `--order`, `--page-size`, `--json`, and a
  `--dry-run` that prints the `curl` command (auto when gcloud/token is absent). Projects
  only safe fields — never `httpRequest`/`remoteIp`/user.

### Notes

- **gcloud has no error-group commands.** Confirmed live against Google Cloud SDK
  548.0.0: `gcloud error-reporting` does not exist; `gcloud beta error-reporting` exposes
  only `events` (report/delete). Group/stat/event reads therefore use the REST API.
- The REST methods/params/fields, the no-trace finding, and the period-scaling behavior
  were verified against the official docs and a read-only call to an example project
  (`acme-services`, service `orders-api`) on 2026-06-15 (e.g. group `Cx1a2b3c4d5e6f`: 173
  occurrences / 2 services over a day, 1474 / 6 over a week, firing on revision
  `orders-api-00064-ceq`).
- Both scripts pass `bash -n` and `shellcheck -S warning`; leak check against live output
  found no tokens/PII.
- Experimental and unproven. Triggering accuracy and the boundary with
  `error-trace-rootcause` have not yet been measured with the description optimizer.

### Source Contracts

- `https://docs.cloud.google.com/error-reporting/reference/rest/v1beta1/projects.groupStats/list`
- `https://docs.cloud.google.com/error-reporting/reference/rest/v1beta1/projects.events/list`
- `https://docs.cloud.google.com/error-reporting/reference/rest/v1beta1/projects.groups`
- `https://docs.cloud.google.com/logging/docs/analyze/find-logs-error-groups`
