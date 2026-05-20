# Blassioli Code Reviewer

Structured PR and diff review guidance for production-sensitive changes, with explicit review paths for HTTP services, scheduled work, queue consumers, and Kubernetes runtime behavior.

## When To Use

- "Use `blassioli-code-reviewer` to review this PR against `origin/main`."
- "Audit these Kubernetes and Cloud Run changes for shutdown, probes, and rollout safety."
- "Review this consumer code for idempotency, retries, backpressure, and observability."
- "Check whether this CronJob or backfill is safe under overlap, reruns, and partial failure."

## What This Skill Maintains

- `SKILL.md`: the hot-path review dispatcher and output contract.
- `references/`: one-hop deep dives for HTTP services, scheduled work, queue consumers, Kubernetes runtime, observability, and testing.
- `assets/`: reusable review templates and workload-specific checklists.
- `scripts/`: deterministic helpers for review-surface discovery and Kubernetes or consumer risk hints.
- `metadata.json`, `CHANGELOG.md`, and `skill-registry.json`: version and release authority for the registry skill.

## Release And Validation

```bash
bash scripts/skill-sync.sh --skill=blassioli-code-reviewer --dry-run
node --check skills/blassioli-code-reviewer/scripts/detect-k8s-runtime-risks.mjs
node --check skills/blassioli-code-reviewer/scripts/detect-queue-consumers.mjs
```

For release tags, ADR-0001 uses:

```text
skill-blassioli-code-reviewer@<version>
```

## Related Skills Or Packs

- `cursor-skill-studio` Cursor pack — `/skill-studio-audit` (compliance,
  overlap, improvement recommendations) and `/skill-studio-maintain`
  (releases, registry alignment, install verification). Replaces the
  former `audit-skill-for-cursor` and `personal-skill-maintainer` root
  skills per ADR-0005.
- `cloud-design-patterns`
