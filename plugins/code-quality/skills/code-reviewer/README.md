# code-reviewer

`code-quality:code-reviewer` — a strict, runtime-neutral code-review skill for
production-sensitive changes, with explicit review paths for HTTP services, HTTP API
contracts, scheduled work, queue consumers, Kubernetes runtime behavior, observability,
error-handling discipline, and distributed-systems safety.

## When to use

- "Review this PR / diff / branch against `origin/main`."
- "Audit these Kubernetes and Cloud Run changes for shutdown, probes, and rollout safety."
- "Review this consumer code for idempotency, retries, backpressure, and observability."
- "Check whether this CronJob or backfill is safe under overlap, reruns, and partial failure."
- "Evaluate this implementation plan for correctness and missing tasks."

## What's inside

- `SKILL.md` — the lean review dispatcher, severity model, and output contract.
- `references/` — one-hop deep dives (architecture lenses, HTTP services, API contracts,
  scheduled work, queue consumers, Kubernetes runtime, observability, data integrity,
  cross-cutting, error handling, webhooks, testing, review protocol).
- `assets/` — review templates and workload-specific checklists.
- `scripts/` — deterministic accelerators (`detect-api-contract-risks.mjs`,
  `detect-queue-consumers.mjs`, `detect-k8s-runtime-risks.mjs`, `list-review-surface.sh`),
  invoked via `${CLAUDE_SKILL_DIR}` so they resolve after the plugin is cache-installed.
- `evals/` — the evaluation suite and committed baseline snapshot.

## Install

```bash
/plugin marketplace add felipeblassioli/agent-skills
/plugin install code-quality@agent-skills
```

## Related

- `skill-studio:skill-create` / `skill-audit` / `skill-enhance` — author, audit, and
  improve skills (this skill was audited and hardened with them).
- `repo-governance:skill-maintainer` — versioning and release governance.
