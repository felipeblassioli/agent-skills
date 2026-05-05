# Changelog

All notable changes to this skill will be documented in this file.

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
