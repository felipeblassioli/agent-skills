---
title: Adopt a nine-group plugin taxonomy with an incubator-and-promotion model
status: accepted
date: 2026-07-03
owner: felipeblassioli
adr: 0008
---

# ADR-0008: Adopt a nine-group plugin taxonomy with an incubator-and-promotion model

## Context

ADR-0006 introduced the Claude-first plugin marketplace as an additive layer and
launched three plugins: `blassioli` (sandbox — GCP observability + a code reviewer),
`repo-governance` (release governance), and `skill-studio` (authoring craft, ADR-0007).
ADR-0006 explicitly **deferred** whether and how to migrate the ~50 Cursor-era registry
skills (`skills/`) and ~16 alpha skills (`skills-alpha/`) into the plugin model.

Two forces now make a structuring decision worthwhile:

- **The marketplace needs an organizing principle.** `blassioli` is doing double duty as
  both a personal sandbox and the home of already-mature skills (the GCP observability
  trio, an evaled `code-reviewer`). Without a taxonomy, new plugins accrete ad hoc and
  discovery degrades.
- **There is a proven taxonomy to borrow.** Anthropic's
  ["How we use skills"](https://claude.com/blog/lessons-from-building-claude-code-how-we-use-skills)
  organizes internal skills into **nine functional groups**: Library & API Reference,
  Product Verification, Data Fetching & Analysis, Business Process & Team Automation,
  Code Scaffolding & Templates, Code Quality & Review, CI/CD & Deployment, Runbooks, and
  Infrastructure Operations.

A triage of the existing inventory against those nine groups showed the coverage is
**already strong in ~6 of 9** (reference, verification, code-quality, cicd, runbooks,
and partially scaffolding/automation), spread across the registry, alpha, and the
`blassioli` plugin — with real gaps only in Data Analysis (metrics/BigQuery) and
Infrastructure Operations. So the work is largely **reorganizing and promoting existing
skills into coherent group-plugins plus filling two gaps**, not greenfield.

The tension ADR-0006 named still holds: a wholesale migration of the registry is large
and risky, and most alpha skills are L0-experimental (not promotion-ready). Bulk-moving
them would import unvetted quality into the official tier.

## Decision

Adopt the article's **nine functional groups as this marketplace's official-tier plugin
taxonomy** (one plugin per group), governed by an incubator-and-promotion model.

1. **Nine group-plugins, fine granularity.** Target plugins: `dev-reference`,
   `verification`, `data-analysis`, `team-automation`, `scaffolding`, `code-quality`,
   `cicd`, `runbooks`, `infra-ops`. Prefer more, smaller, single-purpose plugins over a
   few catch-alls — model-facing discoverability wins.
2. **`blassioli` is the incubator, not a group.** New/experimental skills land in the
   `blassioli` sandbox (`USE AT YOUR OWN RISK`). Group-plugins are the **official-tier
   promotion targets**. `blassioli`, `repo-governance`, and `skill-studio` sit **outside**
   the taxonomy (incubator + infrastructure).
3. **Lazy plugin creation.** A group-plugin is created only when its **first** skill is
   ready to promote into it. No empty scaffolds. (Mirrors the article's
   sandbox → traction → PR-into-marketplace flow.)
4. **Promotion is quality-gated, not bulk migration.** The registry and alpha skills are
   a **candidate pool**. Each candidate must pass `skill-studio:skill-audit` (and, for
   L2+, an eval/benchmark baseline via `skill-studio:skill-enhance`) before it graduates;
   `repo-governance:skill-maintainer` performs the promotion. Only the strongest
   graduate. This **resolves the migration question ADR-0006 deferred**: the answer is
   selective, gated promotion — never bulk.
5. **Personal, but public-repo-safe.** Skills target the owner's stack (GCP, Linear, the
   owner's services), but the repo is public: every promoted skill must be
   **parameterized** — project ids, service names, dashboard URLs, and hostnames live in
   `config.json` / `AskUserQuestion` / `${CLAUDE_PLUGIN_DATA}`, never hardcoded — and a
   confidentiality grep gate (zero internal identifiers) blocks each promotion. This
   extends ADR-0006's genericization posture to all future promotions.
6. **`infra-ops` is destructive by nature** and ships last, with read-only/dry-run
   defaults, explicit confirmation, and on-demand guardrail hooks (`/careful`, `/freeze`).

Direction, phasing, and the per-group candidate backlog live in the living
[`docs/ROADMAP.md`](../ROADMAP.md); this ADR records the binding decision.

### Relationship to prior ADRs

- **Resolves** the migration question **deferred by ADR-0006** (selective gated
  promotion, not bulk). ADR-0006's coexistence boundary is unchanged: the registry and
  Cursor packs keep their own tooling; nothing is auto-migrated.
- **Uses** `skill-studio` (ADR-0007) as the promotion gate and
  `repo-governance:skill-maintainer` (ADR-0006/0007) as the promotion mechanism.
- **Classifies** promotions on the ADR-0003 maturity ladder: sandbox = L0/L1, an
  official group-plugin skill is L2+ (needs a behavior contract + evals/verification).

## Consequences

### Positive
- A clear, discoverable structure for the marketplace; each plugin is single-purpose.
- The existing inventory becomes an actionable, prioritized backlog instead of sprawl.
- Quality can only rise: nothing reaches the official tier without an audit and (for
  L2+) evals; the public-safe gate is enforced on every promotion.
- Lazy creation avoids dead, empty plugins.

### Negative
- Nine potential plugins is more release/version surface than three. Mitigated by lazy
  creation (they appear only as they earn a skill) and shared `repo-governance` tooling.
- Some skills are genuinely cross-cutting (e.g. log data-fetch vs runbook; contract
  checks vs verification). Placement is resolved per-skill at audit time; the ROADMAP
  flags these as "route during audit."
- `blassioli` currently holds mature skills (`code-reviewer`, the GCP trio) that the
  taxonomy says belong in `code-quality` / `runbooks`. Graduating them is deliberate
  churn. Mitigated by treating those graduations as ordinary gated promotions (they are
  already evaled) rather than a rushed reshuffle, sequenced in ROADMAP Phase 1.

### Neutral
- The Cursor-era registry and packs are untouched; ADR-0001..0005 stay authoritative
  there. A registry skill only changes when it is *promoted* (copied + hardened into a
  plugin), and even then the registry entry's disposition is decided per-skill.
- The taxonomy is borrowed, not invented; if the owner's needs diverge from the article's
  nine groups, this ADR can be superseded rather than stretched.

## Alternatives considered

- **A — Coarser grouping (fewer, broader plugins).** e.g. one `gcp-sre` plugin folding
  runbooks + data + infra, one `dev` plugin folding reference + scaffolding. Rejected:
  the owner prioritized discovery; broad catch-alls dilute description-triggering and
  hide skills.
- **B — Bulk-migrate the registry/alpha into group-plugins now.** Rejected: imports
  unvetted (especially L0 alpha) quality into the official tier and repeats the
  cost/risk ADR-0006 already declined. Selective gated promotion is the chosen path.
- **C — Dissolve `blassioli`, no incubator.** Send every new skill straight into a
  group-plugin. Rejected: removes the low-friction sandbox where experiments live before
  they earn an audit; the incubator → promotion flow is the article's proven model.
- **D — No taxonomy; keep adding plugins ad hoc.** Rejected: the reason for this ADR —
  discovery and coherence degrade without an organizing principle.

## See also
- [`docs/ROADMAP.md`](../ROADMAP.md) — phasing + per-group candidate backlog
- `docs/ADR/ADR-0006-adopt-claude-first-plugin-marketplace.md` (migration question resolved here)
- `docs/ADR/ADR-0007-skill-studio-plugin-canonical.md` (the promotion gate)
- `docs/ADR/ADR-0003-artifact-maturity-model.md` (promotion = L1→L2+)
- `docs/marketplace-governance.md`
- `docs/guides/governance-workflow.md`
