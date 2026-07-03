# code-quality

Official-tier **Code Quality & Review** plugin for the
[agent-skills](https://github.com/felipeblassioli/agent-skills) marketplace —
group 6 of the nine-group taxonomy
([ADR-0008](../../docs/ADR/ADR-0008-nine-group-plugin-taxonomy.md),
[ROADMAP](../../docs/ROADMAP.md) Phase 1).

## Skills

| Skill | What it does |
|---|---|
| `code-reviewer` | A strict, runtime-neutral distributed-systems code reviewer for PRs, diffs, branches, and implementation plans. Classifies the change, applies workload-archetype + cross-cutting review lenses (HTTP contracts, queue consumers, scheduled jobs, dual-write/outbox, money/units, Kubernetes runtime), and emits findings under a disciplined `BLOCKER/HIGH/MEDIUM/LOW/QUESTION` severity model. Ships an eval suite with committed baselines. |
| `typescript-quality` | TypeScript code-quality patterns: typed clients with timeouts, Zod boundary validation, structured domain errors, no-`any` on public surfaces, structured JSON logging (pino), OpenTelemetry tracing, and PII redaction. Routes a question to the right rule; details live one hop away. |

## Install

```
/plugin marketplace add felipeblassioli/agent-skills
/plugin install code-quality@agent-skills
```

## Provenance

`code-reviewer` was **graduated** from the `blassioli` sandbox into this
official-tier plugin after passing the `skill-studio:skill-audit` promotion gate
(see [#103](https://github.com/felipeblassioli/agent-skills/issues/103)). It
keeps its own version lineage (`metadata.json`); this plugin is versioned
independently.

## Roadmap

Further code-quality candidates (`gh-post-code-review`, `sql`/`postgresql` review,
`quality-playbook`) are audited and promoted incrementally under
[#103](https://github.com/felipeblassioli/agent-skills/issues/103) — one gated
promotion per follow-up PR. (`owasp-security` is externally sourced from a no-license
upstream and is held back from promotion until its license/attribution is resolved.)
Governance and release flow through the `repo-governance` plugin.
