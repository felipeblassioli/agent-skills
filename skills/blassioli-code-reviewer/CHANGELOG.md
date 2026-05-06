# Changelog

All notable changes to this skill will be documented in this file.

## [1.2.0] - 2026-05-06

### Added

- Added `references/error-handling-review.md` introducing a framework-neutral, ZIO-inspired three-layer error taxonomy (`Failure` / `Defect` / `Fatal`), an actionability test (5 W's), retry classification by error class, boundary translation rules, anti-patterns for catch-block smells, and process-exit discipline.
- Added an "Error handling discipline" bullet to the cross-cutting review posture in `SKILL.md`.
- Added an `Error Handling Discipline` lens to the cross-cutting bucket of `references/architecture-risk-lenses.md`.
- Added a "Defects are not silently retried" item to `assets/senior-review-meta-checklist.md`.
- Added `error-handling` registry tag and expanded the auto-invocation `description` to surface error-handling concerns as triggers.

### Changed

- Reframed `references/cross-cutting-review.md` `Error Model Design` section as the **API envelope / external taxonomy** side of error handling, with a cross-reference to the new internal-discipline reference. The two are intentionally complementary.
- Reordered the operating procedure's cross-cutting routing step in `SKILL.md` to include error-handling-review.md.

### Validation

- `bash scripts/skill-sync.sh --skill=blassioli-code-reviewer --dry-run`
- `node --check skills/blassioli-code-reviewer/scripts/detect-k8s-runtime-risks.mjs`
- `node --check skills/blassioli-code-reviewer/scripts/detect-queue-consumers.mjs`

## [1.1.0] - 2026-05-06

### Added

- Added `references/data-integrity-review.md` covering dual-write / outbox / inbox, cache correctness, read-after-write / replication lag, money & unit precision, time & clocks, and additive schema/migration safety.
- Added `references/cross-cutting-review.md` covering multi-tenancy isolation, error model design, state machines, feature flags & kill switches, configuration safety, and cost & blast radius.
- Added `references/webhook-review.md` covering incoming webhook authenticity / replay / sender-timeout discipline and outgoing webhook delivery / signing / SSRF protection.
- Added `assets/senior-review-meta-checklist.md` for the steel-man, asymmetric-risk, scope, rollback, and 3-AM-signal pre-verdict pass.
- Added a "Cross-cutting review posture" section in `SKILL.md` with directional questions for the new lenses, plus an explicit cross-cutting bucket in `references/architecture-risk-lenses.md`.
- Added an explicit anti-triggers ("Do NOT use this skill when") block in `SKILL.md` to disambiguate from `code-review`, `commit-hygiene`, `gh-pr-creator`, `test-verifier`, and the skill-authoring skills.
- Added a cheap-agent delegation cue in `SKILL.md`: for PRs >300 LOC or >10 files, delegate the classification + reference-routing pass to a `subagent_type: explore`, `readonly: true` subagent.

### Changed

- Reordered the operating procedure to add a dedicated step for cross-cutting lenses (data integrity, cross-cutting, webhook) and a final step to apply the senior meta-checklist before the verdict.
- Expanded the auto-invocation `description` to surface webhooks, dual-writes, caches, multi-tenant data, money/units, time-sensitive logic, and feature flags as triggers.
- Added registry tags `data-integrity`, `multi-tenancy`, `webhooks`.

### Validation

- `bash scripts/skill-sync.sh --skill=blassioli-code-reviewer --dry-run`
- `node --check skills/blassioli-code-reviewer/scripts/detect-k8s-runtime-risks.mjs`
- `node --check skills/blassioli-code-reviewer/scripts/detect-queue-consumers.mjs`

## [1.0.0] - 2026-05-05

### Added

- Added the initial governed release for `blassioli-code-reviewer` as a root registry skill.
- Added workload-specific review paths for request-driven HTTP services, scheduled work, queue consumers, and Kubernetes runtime behavior.
- Added one-hop references for architecture risk lenses, HTTP service review, scheduled work review, observability, testing, and queue-consumer semantics.
- Added review checklists, comment/report templates, and helper scripts for review-surface discovery and Kubernetes runtime risk detection.

### Validation

- `bash scripts/skill-sync.sh --skill=blassioli-code-reviewer --dry-run`
- `node --check skills/blassioli-code-reviewer/scripts/detect-k8s-runtime-risks.mjs`
- `node --check skills/blassioli-code-reviewer/scripts/detect-queue-consumers.mjs`

### Source Contracts

- `docs/ADR/ADR-0001-registry-driven-releases-for-skills-and-packs.md` reviewed 2026-05-05
- `docs/ADR/ADR-0002-governed-skill-maintenance-model.md` reviewed 2026-05-05
- `skills/cloud-design-patterns/SKILL.md` reviewed 2026-05-05 for architecture-lens inspiration
