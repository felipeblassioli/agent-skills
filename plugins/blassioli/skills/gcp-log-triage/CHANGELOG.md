# Changelog

## 0.3.0 - 2026-06-15

### Fixed

- Description now carves out the sibling skills by name in the frontmatter (the routing
  signal), not just the body: deep root-cause-to-code → `error-trace-rootcause`,
  error-group ranking/blast-radius → `error-reporting`. Closes the `skill-auditor`
  finding that the description over-claimed "find the real error / why is it erroring"
  with no reverse carve-out, creating a mis-trigger seam against the siblings.

### Added

- `evals/evals.json` — 8 edge cases (4 traps incl. secret-leak + exclusion-safety, 2
  cross-skill discrimination controls, 2 over-trigger controls).
- `evals/baselines/2026-06-15-iter1.{md,benchmark.json}` — committed baseline evidence.

### Evidence

- With-skill **92.9%** (26/28) vs baseline **57.1%** (16/28) = **+35.7 pts**;
  model claude-opus-4-8, 2026-06-15 (see the baseline snapshot). Two known with-skill
  flaws tracked for iteration 2 (GKE trace-note not volunteered on a plain query;
  ranking-deferral still sanity-checks raw logs) — neither a safety regression.

### Changed (cosmetic)

- `references/log-anatomy.md`: reworded two `triage-logs.sh` mentions as script names
  (prose), reserving the `${CLAUDE_SKILL_DIR}` form for runnable hot-path invocations.

## 0.2.0 - 2026-06-15

### Added

- `references/service-archetypes.md` — the shared targeting matrix for all three GCP
  observability skills, covering four common Cloud Logging shapes: Firebase Functions
  **Gen 1** (`cloud_function`), Functions **Gen 2** / Cloud Run (`cloud_run_revision`),
  **GKE** (`k8s_container`), and **AppHub** views (`apphub.*`). Documents per-archetype
  `resource.type`, identifying labels, `logName` (incl. plain GKE `…/logs/stderr` vs Cloud
  Run `%2Fstderr` vs Gen1 `%2Fcloud-functions`), stream count, trace correlation (GCP
  `trace` for #1/#2; `jsonPayload.traceId` for GKE — no top-level trace), `level` casing,
  per-archetype secrets (a custom API-key header on GKE alongside `authorization`), and the
  AppHub log-scope mechanics.

### Changed

- `SKILL.md` "Locate" step and `references/query-cookbook.md` now show per-archetype
  targeting (Gen1 / Cloud Run / GKE / AppHub) and route to `service-archetypes.md`.
- `scripts/triage-logs.sh`: the `service` column now falls back to
  `resource.labels.namespace_name` / `jsonPayload.application`, so GKE entries (which have
  no `service_name` label) render their app name.

## 0.1.0 - 2026-06-15

### Added

- Initial release. A triage-first skill for handling noisy Google Cloud Logging
  output, built around a Cloud Run export (using a structured JSON logger) in which one
  failed request produced four entries (duplicate stderr errors, an INFO middleware log,
  and the platform 504 access log), each repeating the full request header set.
- `SKILL.md`: the noise model (multi-stream fan-out, re-emitted errors, repeated
  blobs, GCP `trace` vs app `traceId`), a five-step triage funnel, a security
  guardrail against logging/echoing the Authorization Bearer token, and a secondary
  source-side reduction section.
- `references/log-anatomy.md`: the `LogEntry` envelope, the three Cloud Run streams,
  the two trace identifiers, an example structured-log `jsonPayload` field map (signal vs
  noise), and the worked example decoded.
- `references/query-cookbook.md`: operator quick reference, the triage funnel, and
  paste-ready Logs Explorer + `gcloud logging read` recipes.
- `references/reduce-noise-at-source.md`: emitter fixes, severity hygiene, exclusion
  filters on the `_Default` sink, and routing to dedicated buckets, with the
  non-retroactive / unrecoverable caveats called out.
- `scripts/triage-logs.sh`: a jq-backed extractor that accepts a JSON array
  (`gcloud logging read --format=json` or the console "Download") or JSONL, collapses
  it to one row per GCP `trace`, and prints only signal fields — never the
  header/context blobs — so it is safe to run on exports containing secrets. Supports
  `--by-trace` (default), `--flat`, `--errors`, `--json`, and `--help`.

### Notes

- The Cloud Logging query-language operators (`>=`, `:`, `=~`/`!~`, `AND/OR/NOT`, `-`
  negation, `SEARCH()`, `severity >= "ERROR"`, `logName` `%2F` encoding, bare-quoted
  global restriction) and the `gcloud logging read` / `gcloud logging sinks update`
  flags (`--limit`, `--order` default `desc`, `--freshness` default `1d`, `--format`,
  `--add-exclusion`/`--remove-exclusions`/`--clear-exclusions`) were verified against
  the official Google Cloud documentation on the `reviewed_at` date.
- Sandbox tier (blassioli plugin): experimental and unproven. Triggering accuracy of
  the `description` has not yet been measured with the description optimizer.

### Source Contracts

- `https://docs.cloud.google.com/logging/docs/view/logging-query-language`
- `https://docs.cloud.google.com/sdk/gcloud/reference/logging/read`
- `https://docs.cloud.google.com/sdk/gcloud/reference/logging/sinks/update`
- `https://docs.cloud.google.com/logging/docs/exclusions`
