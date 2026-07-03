# Changelog

## 0.3.0 - 2026-06-15

### Fixed

- Description anti-trigger correctness: `"rank which errors matter"` no longer routes to
  `gcp-log-triage` (which does not rank) — it now routes "rank which error groups are
  worst / by blast radius" to **`error-reporting`**, the actual ranking skill. Closes the
  `skill-auditor` inter-skill routing inconsistency. Description also tightened
  (1203 → ~1115 chars) by compressing the mechanism clause.

### Added

- `evals/evals.json` — 8 edge cases (4 traps incl. GKE traceId pivot, first-failure, and
  read-only-no-fix; 2 discrimination controls; 2 over-trigger controls).
- `evals/baselines/2026-06-15-iter1.{md,benchmark.json}` — committed baseline evidence.

### Evidence

- With-skill **92.6%** (25/27) vs baseline **37.0%** (10/27) = **+55.6 pts**;
  model claude-opus-4-8, 2026-06-15 (see the baseline snapshot). The read-only "do not
  write the fix" scope held with-skill. Two known flaws tracked for iteration 2
  (service→repo source mapping not volunteered; a prompt without trail data
  limited the diagnosis assertion).

## 0.2.0 - 2026-06-15

### Changed

- `scripts/trace-trail.sh` is now **archetype-aware**. GKE (`k8s_container`) entries have no
  top-level GCP `trace`, so the trail pivots on `jsonPayload.traceId`/`contextId` instead.
  Added `--app-id ID`; `--filter` auto-detects the key from the representative (GCP trace if
  present, else app traceId); a UUID passed to `--trace` is auto-treated as a GKE app id;
  the `service` projection falls back to `namespace_name`/`jsonPayload.application`.
- `scripts/logs-url-to-filter.sh` now handles AppHub console URLs: it strips console-only
  `-- comment` lines and decodes the double-encoded grouping parens (`%2528` → `(`) while
  preserving logName's `%2F`. `apphub.application.id` / `apphub.workload.id` queries now
  pass straight to `gcloud logging read`.
- Docs: `correlation-playbook.md` gains a GKE "no top-level trace" fallback;
  `locate-code.md` maps GKE `namespace_name`/`application` to the service's own repo and
  pins the deployed commit via the `k8s-pod/otel/version` label; `SKILL.md` step 3 documents
  the per-archetype pivot. All route to `service-archetypes.md` (in `gcp-log-triage`).

## 0.1.0 - 2026-06-15

### Added

- Initial release. A read-only root-cause skill that pairs with `gcp-log-triage`:
  triage cuts noise and finds *which* error matters; this skill takes one error and
  answers *why*, down to the offending code. Built from a real Error Reporting group
  case (`errorGroups.id="CKfmhY3Kv8vOVQ"`, `orders-api`, project `acme-services`) and the
  trace-pivot pattern (`trace="projects/acme-services/traces/…"`).
- `SKILL.md`: inputs/normalization table, the six-step procedure (normalize → pick
  representative → pull trail → read causal chain → locate code local→gh → report),
  correlation fallbacks (async/cross-service/`gcloud` errorGroups.id), the root-cause
  report deliverable, scripts, and traps. Scope is locate-and-explain only — no fixes.
- `references/correlation-playbook.md`: entry points, representative selection criteria,
  pulling and reading the trail (first-failure rule, `+ms` gaps, `error.cause`,
  `Promise.all` fan-out, retry/timeout mismatch), the worked example read as a chain, and
  async/cross-service/thin-trail fallbacks.
- `references/locate-code.md`: stack-frame → repo-relative path, service→repo mapping
  (Cloud Run service repos vs Firebase Functions monorepos), local→`gh` resolution
  with no clone (org/owner supplied as a parameter), revision pinning, the `.js`-vs-`.ts`
  line-drift caveat, and the root-cause report template.
- `scripts/logs-url-to-filter.sh`: parses a Logs Explorer console URL (or a pasted UI
  query) into a `gcloud` filter + project + absolute time window. Decodes the double
  URL-encoding in one pass (`%252F` → `%2F`, `%0A` → newline), normalizes the console
  alias `error_groups.id` to the queryable `errorGroups.id`, and can emit a runnable
  `gcloud logging read` command. BSD/GNU-portable (no `grep -P`).
- `scripts/trace-trail.sh`: the correlation core. `--filter` selects a representative
  occurrence (most recent with a trace + richest error) and pivots to its trace;
  `--trace` pulls a trail directly; `--render` formats a JSON array from stdin. Orders
  ascending with `+ms` offsets, never prints the header/track blobs (safe on
  token-bearing data), auto-retries without the `errorGroups.id` clause on an empty live
  result, and falls back to `--dry-run` (prints the `gcloud` commands) when `gcloud` is
  absent.

### Notes

- The `errorGroups.id` filter field (canonical for querying Error Reporting groups; the
  console also shows the alias `error_groups.id`), the `trace=` filter, and the
  `gcloud logging read` flags were verified against the official Google Cloud
  documentation on the `reviewed_at` date. The docs confirm error-group filtering for
  the Logs Explorer UI but do not guarantee `gcloud` support — hence the automatic
  clause-drop fallback in `trace-trail.sh`.
- Both scripts pass `bash -n` and `shellcheck -S warning`, and were exercised against a
  real single-trace export (URL parsing, ordered trail rendering, dry-run command
  emission, secret-leak check).
- Sandbox tier (blassioli plugin): experimental and unproven. Triggering accuracy of the
  `description` and the disambiguation from `gcp-log-triage` have not yet been measured
  with the description optimizer.

### Source Contracts

- `https://docs.cloud.google.com/logging/docs/analyze/find-logs-error-groups`
- `https://docs.cloud.google.com/logging/docs/view/logging-query-language`
- `https://docs.cloud.google.com/sdk/gcloud/reference/logging/read`
