# Marketplace ROADMAP

> **Status:** active (living) · **Adopted:** 2026-07-03 (ADR-0008) · **Owner:** Felipe Blassioli
> **Scope:** the Claude-first plugin marketplace (`.claude-plugin/marketplace.json`,
> `plugins/*`). Does **not** govern the Cursor-era registry (`skills/`, `packs/`) — see
> [`governance-workflow.md`](guides/governance-workflow.md) for the coexistence rule.

This is the first repo-level ROADMAP (previously the repo deliberately had none — see
the retired "Known Gaps" note in [`governance-workflow.md`](guides/governance-workflow.md)).
It exists because marketplace planning has grown past what a single ADR carries: a
multi-plugin taxonomy, a phased rollout, and a promotion-gated backlog.

## Why this shape

Modeled on Anthropic's ["How we use skills"](https://claude.com/blog/lessons-from-building-claude-code-how-we-use-skills),
which organizes internal skills into **nine functional groups**. Decision: adopt those
nine groups as this marketplace's **official-tier plugin taxonomy** — one plugin per
group. Rationale and trade-offs are the binding decision in
[**ADR-0008**](ADR/ADR-0008-nine-group-plugin-taxonomy.md); this file tracks direction
and backlog.

### Operating model (decided)

- **Fine granularity for discovery.** ~9 group-plugins, 1:1 with the article's groups.
  More, smaller plugins beat a few catch-alls for model-facing discoverability.
- **`blassioli` is the incubator, not a group.** New/experimental skills land in the
  `blassioli` sandbox plugin (`USE AT YOUR OWN RISK`). Group-plugins are the
  **official-tier promotion targets**.
- **Lazy plugin creation.** A group-plugin is created only when its **first** skill is
  ready to be promoted into it. No empty scaffolds. (Mirrors the article's
  "sandbox folder → earn traction → PR into the marketplace" flow.)
- **Promotion is quality-gated, not bulk migration.** The ~50 registry skills and ~16
  alpha skills are a **candidate pool**, not an auto-migration. Each candidate must pass
  `skill-studio:skill-audit` (and, for L2+, an eval/benchmark via
  `skill-studio:skill-enhance`) before it graduates. Only the strongest graduate.
- **Personal, but public-repo-safe.** Skills target *my* stack (GCP, Linear, my
  services) — but this repo is **public**, so every promoted skill must be
  **parameterized**: project IDs, service names, dashboard URLs, and hostnames live in
  `config.json` / `AskUserQuestion` / `${CLAUDE_PLUGIN_DATA}`, never hardcoded. A
  confidentiality grep gate (no internal identifiers) blocks every promotion. This is
  the same genericization already applied to the `blassioli` GCP observability skills.

## Target taxonomy

| # | Group (article) | Plugin | Status | Track | Anchor / first candidate |
|---|---|---|---|---|---|
| 1 | Library & API Reference | `dev-reference` | planned | [#105](https://github.com/felipeblassioli/agent-skills/issues/105) | Go/TS/OTel/React reference cluster (promote) |
| 2 | Product Verification | `verification` | planned | [#106](https://github.com/felipeblassioli/agent-skills/issues/106) | `test-verifier`, `playwright*` (promote) |
| 3 | Data Fetching & Analysis | `data-analysis` | **gap** | [#110](https://github.com/felipeblassioli/agent-skills/issues/110) | `gcloud-logging` base + net-new GCP metrics/BigQuery |
| 4 | Business Process & Team Automation | `team-automation` | planned | [#109](https://github.com/felipeblassioli/agent-skills/issues/109) | `linear-specialist` (promote) |
| 5 | Code Scaffolding & Templates | `scaffolding` | planned | [#108](https://github.com/felipeblassioli/agent-skills/issues/108) | `create-*` alpha + `cli-creator` (promote) |
| 6 | Code Quality & Review | `code-quality` | **active** | [#103](https://github.com/felipeblassioli/agent-skills/issues/103) | `code-reviewer` + `typescript-quality` + `gh-post-code-review` graduated ✓ (v0.3.0) |
| 7 | CI/CD & Deployment | `cicd` | planned | [#107](https://github.com/felipeblassioli/agent-skills/issues/107) | `babysit`, `gh-fix-ci` (promote) |
| 8 | Runbooks | `runbooks` | planned | [#104](https://github.com/felipeblassioli/agent-skills/issues/104) | **`blassioli` GCP trio + `resolve-bug`** (graduate) |
| 9 | Infrastructure Operations | `infra-ops` | **gap** | [#111](https://github.com/felipeblassioli/agent-skills/issues/111) | net-new (orphans, cost, deps) — build last |

Existing infra plugins are unchanged and sit **outside** the taxonomy: `blassioli`
(incubator), `repo-governance` (release governance), `skill-studio` (authoring).

## Phased rollout

Ordered by ROI × (existing coverage) ÷ risk. Each phase = create the group-plugin(s)
lazily as their anchor graduates, then audit-and-promote the rest of that group's pool.

### Phase 0 — Foundation (now)
- Merge PR #102 (marketplace + `blassioli` + `skill-studio` + `repo-governance`).
- Adopt the taxonomy: this ROADMAP + [**ADR-0008**](ADR/ADR-0008-nine-group-plugin-taxonomy.md) (accepted).
- Codify the promotion pipeline: `skill-audit` → (L2+) `skill-enhance` evals →
  `repo-governance:skill-maintainer` promotion → confidentiality grep gate.
- No new plugins yet.

### Phase 1 — Formalize strengths (SRE + review; most personal-relevant)
- **`code-quality`** — ✓ `code-reviewer` + `typescript-quality` + `gh-post-code-review`
  graduated (plugin v0.3.0, #103); next: audit+promote the alpha `quality-playbook` /
  `sql-code-review` / `postgresql-code-review` / `code-review` and the registry contract
  checks. (`owasp-security` held back — imported from a no-license upstream; needs a
  license/attribution decision.)
- **`runbooks`** — graduate the `blassioli` GCP trio (`error-reporting`,
  `error-trace-rootcause`, `gcp-log-triage`) + the `resolve-bug` command; audit
  `argocd-app-doctor` (currently deferred). This is the article's log-correlator /
  service-debugging group — my strongest area.

### Phase 2 — Reference & verification (promotion-heavy, mostly public-safe)
- **`dev-reference`** — promote the Go/TS/OTel/React cluster (see backlog).
- **`verification`** — promote the testing cluster + `playwright` / `playwright-interactive`.

### Phase 3 — Delivery & authoring workflows
- **`cicd`** — promote `babysit`, `gh-fix-ci`, `gh-address-comments`,
  `github-actions-release-topology`, `ci-performance-baseline-comparison`,
  `render-deploy`; gap: `deploy-<gcp-service>`.
- **`scaffolding`** — promote the alpha `create-*` set + `cli-creator`; gap:
  `new-migration`.
- **`team-automation`** — promote `linear-specialist`, `prd`, `gh-pr-creator`,
  `commit-hygiene`; reuse built-in `engineering:standup` rather than rebuild
  standup/weekly-recap.

### Phase 4 — Fill the real gaps (net-new, highest blast radius — build last)
- **`data-analysis`** — promote `gcloud-logging` as the data-fetch base; author net-new
  GCP metrics query, BigQuery analysis, and funnel/cohort skills (the metrics/analytics
  side my observability currently lacks).
- **`infra-ops`** — author net-new `gcp-orphan-resources`, `cost-investigation`,
  `dependency-management`. **Destructive** → read-only/dry-run by default, explicit
  confirmation, and on-demand guardrail hooks (`/careful`, `/freeze`) per the article.

## Backlog — candidate pool by group

Legend — **action:** `promote` (audit → graduate to the group-plugin) ·
`consolidate` (dedupe overlap before promoting) · `author` (net-new) ·
`keep:registry` (stays Cursor-era) · `keep:studio` (stays in `skill-studio`) ·
`reuse` (use an existing built-in instead of rebuilding).
**loc:** `registry` = `skills/` · `alpha` = `skills-alpha/` · `blassioli` = plugin.

### 6 · `code-quality` (Phase 1)
| Candidate | loc | Action |
|---|---|---|
| `code-reviewer` | blassioli | promote (graduate; anchor) |
| `owasp-security` | registry | promote |
| `gh-post-code-review` | registry | promote |
| `typescript-quality` | registry | promote |
| `quality-playbook` | alpha | promote |
| `code-review` | alpha | consolidate (overlaps `code-reviewer`) |
| `sql-code-review`, `postgresql-code-review` | alpha | promote |
| `backend-contract-reconciliation`, `frontend-contract-discovery` | registry | promote (contract checks) |

### 8 · `runbooks` (Phase 1)
| Candidate | loc | Action |
|---|---|---|
| `error-reporting`, `error-trace-rootcause`, `gcp-log-triage` | blassioli | promote (graduate; anchor trio) |
| `resolve-bug` (command) | blassioli | promote |
| `argocd-app-doctor` | blassioli (deferred) | audit → promote if it passes |
| `oncall-runner` (dispatcher) | — | author (gap) |

### 1 · `dev-reference` (Phase 2)
| Candidate | loc | Action |
|---|---|---|
| `go-package-documentation`, `ts-module-documentation` | registry | promote |
| `otel-collector`, `otel-instrumentation`, `otel-ottl`, `otel-semantic-conventions` | registry | promote |
| `react-best-practices`, `react-native-skills`, `composition-patterns` | registry | promote |
| `kysely-typescript`, `esm-typescript`, `deno-production-practices`, `hono-htmx-server` | registry | promote |
| `ts-prod-code`, `typescript-error-handling` | registry | promote |
| `gcp-opentelemetry-nodejs`, `gcp-error-reporting-nodejs` | registry | promote (app-side instrumentation — distinct from `runbooks`) |
| `cloud-design-patterns` | alpha | promote |

### 2 · `verification` (Phase 2)
| Candidate | loc | Action |
|---|---|---|
| `test-verifier` | registry | promote (anchor) |
| `playwright`, `playwright-interactive` | registry | promote |
| `hurl-testing`, `vitest-monorepo`, `ts-hermetic-testing`, `typescript-testing-organization` | registry | promote |
| `tdd-classicist` | registry | promote |
| `doublecheck` | alpha | promote |

### 7 · `cicd` (Phase 3)
| Candidate | loc | Action |
|---|---|---|
| `babysit` | registry | promote (= babysit-pr; anchor) |
| `gh-fix-ci`, `gh-address-comments` | registry | promote |
| `github-actions-release-topology`, `ci-performance-baseline-comparison` | registry | promote |
| `render-deploy` | registry | promote |
| `devops-rollout-plan` | alpha | promote |
| `deploy-<gcp-service>`, `cherry-pick-prod` | — | author (gap) |

### 5 · `scaffolding` (Phase 3)
| Candidate | loc | Action |
|---|---|---|
| `create-architectural-decision-record`, `create-specification`, `create-technical-spike`, `create-agentsmd` | alpha | promote |
| `cli-creator` | registry | promote |
| `firebase-functions-node`, `nx-monorepo`, `go-command-line-applications` | registry | promote |
| `skill-create` | skill-studio | keep:studio (meta-scaffolder) |
| `new-migration` | — | author (gap) |

### 4 · `team-automation` (Phase 3)
| Candidate | loc | Action |
|---|---|---|
| `linear-specialist` | registry | promote (= create-ticket; anchor) |
| `prd`, `bmad-specialist` | registry | promote |
| `gh-pr-creator`, `gh-issue-verifier` | registry | promote |
| `commit-hygiene` | registry | promote |
| `conventional-commit` | alpha | consolidate (overlaps `commit-hygiene`) |
| standup-post / weekly-recap | — | reuse `engineering:standup` |

### 3 · `data-analysis` (Phase 4 — gap)
| Candidate | loc | Action |
|---|---|---|
| `gcloud-logging` | registry | promote (data-fetch base; consolidate vs `blassioli:gcp-log-triage`) |
| `gcp-metrics-query` (Cloud Monitoring) | — | author (gap) |
| `bigquery-analysis` (funnel / cohort) | — | author (gap) |

### 9 · `infra-ops` (Phase 4 — gap, destructive)
| Candidate | loc | Action |
|---|---|---|
| `gcp-orphan-resources` | — | author (gap; dry-run default) |
| `cost-investigation` | — | author (gap; read-only) |
| `dependency-management` | — | author (gap) |
| `migrate-to-codex` | registry | audit → `infra-ops` or `scaffolding` |

### Cross-cutting / unassigned (audit before placing)
`nested-agents-routing` (agent routing — meta), `ai-ready`, `context-map`,
`sql-optimization`, `postgresql-optimization`, `web-design-guidelines`,
`gcloud-logging` (spans data + runbooks). Route during audit.

## Guardrails (apply to every promotion)

1. `skill-studio:skill-audit` passes (archetype fit, single responsibility, context
   budget, no dangling refs, cache-safe `${CLAUDE_PLUGIN_ROOT}` / `${CLAUDE_SKILL_DIR}`).
2. For L2+ skills: an eval/benchmark baseline via `skill-studio:skill-enhance`.
3. Confidentiality grep gate: zero internal identifiers; env-specifics parameterized.
4. `repo-governance:skill-maintainer` handles `plugin.json` / `metadata.json` /
   `CHANGELOG.md` / marketplace wiring and release via `release-plugin.yaml`.
5. `infra-ops` destructive skills: read-only/dry-run default + explicit confirmation +
   on-demand `/careful` / `/freeze` hooks.

## Follow-ups

- **ADR-0008** — [accepted](ADR/ADR-0008-nine-group-plugin-taxonomy.md): the binding
  decision (nine-group taxonomy, incubator model, promotion gate, lazy creation,
  public-safe personalization).
- **GitHub issues** — filed one per group-plugin (`roadmap` label):
  [#103](https://github.com/felipeblassioli/agent-skills/issues/103)–[#111](https://github.com/felipeblassioli/agent-skills/issues/111).
  See the Track column above.
- First execution slice: Phase 1 `code-quality`
  ([#103](https://github.com/felipeblassioli/agent-skills/issues/103)) — it already has an
  evaled anchor.
