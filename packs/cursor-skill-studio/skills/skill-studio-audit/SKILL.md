---
name: skill-studio-audit
description: >-
  Audit and improve existing Cursor skills and packs, and review installed or
  repository-first-party skill portfolios for overlap, trigger collisions, and
  compliance with `docs/architecture.md`. Covers single-skill compliance
  review, diagnostic improvement recommendations for an existing skill or
  pack, lightweight portfolio audits of installed skill directories, and the
  deep repo-first-party overlap methodology. Invoke explicitly via
  `/skill-studio-audit`. Do not use for creating or scaffolding skills or
  packs (use `/skill-studio-write`), for registry/version/CHANGELOG governance
  (use `/skill-studio-maintain`), or for skill sync and install scripts (use
  the repo scripts directly).
disable-model-invocation: true
---

# Skill Studio — Audit

Audit and improvement surface for Cursor skills and packs in this repository.
Read-only by default; propose, don't apply. One skill, four branches, shared
subagent pool with `skill-studio-write`.

## Applicability Gate

Apply this skill when ANY of the following are true:

- The user wants to audit or review a specific skill for context efficiency,
  progressive disclosure, or compliance with `docs/architecture.md`.
- The user wants an improvement recommendation for an existing skill or pack
  before any rewrite.
- The user wants to audit an installed skill directory (`~/.cursor/skills`,
  `~/.agents/skills`, `~/.claude/skills`) for overlap, vague triggers, or
  duplicate names.
- The user wants a deep overlap audit of repo-first-party `skills/` to inform
  a consolidation ADR.

Do NOT apply when:

- The user wants to create or scaffold a new skill or pack
  → use `/skill-studio-write`.
- The user wants registry versioning, release artifacts, or governance work
  → use `/skill-studio-maintain`.
- The user wants to install, sync, list, or version existing skills
  → use the repo scripts (`scripts/skill-sync.sh`,
  `scripts/skill-version.sh`, `scripts/skill-import.sh`,
  `scripts/cursor-pack-sync.sh`).
- The user wants to compare two skill candidates with an eval/benchmark loop
  → use `/skill-studio-write` Branch F (eval loop owns A/B comparison;
  audit owns single-artifact review and portfolio overlap).

## Intent Router

Pick exactly one branch. Each branch lists the primary references and
subagents to load on demand.

| Signal | Branch | Primary references | Subagents / templates |
|---|---|---|---|
| Audit / review one skill (or a small set) for compliance, token economy, context efficiency, progressive disclosure | **A. Single-skill compliance audit** | `references/single-skill-audit.md`, `references/platform-audit-lenses.md` | Optional `skill-architecture-checker`, `scripts/skill_hot_path_audit.py` |
| Diagnose an existing skill or pack (including token-economy pressure) and recommend the highest-leverage change | **B. Improvement recommendation** | `references/skill-improvement.md` (skill), `references/pack-improvement.md` (pack) | `assets/templates/improvement-recommendation.md`, `scripts/skill_hot_path_audit.py` |
| Audit an installed skill directory for overlap, vague triggers, bad bundling | **C. Installed portfolio audit** | `references/portfolio-audit-workflow.md` | `skill-overlap-clusterer` → `skill-architecture-checker` → `skill-consolidation-advisor`; `assets/templates/portfolio-audit-report.md` |
| Deep repo-first-party overlap audit (consolidation ADR input) | **D. Repo-first-party overlap audit** | `references/repo-skills-overlap-audit.md`, [`docs/specs/skill-overlap-audit.md`](../../../../docs/specs/skill-overlap-audit.md) | Parallel cheap subagents per spec; `assets/templates/portfolio-audit-report.md` |

If the user only asks "does this skill match `docs/architecture.md`?", treat
it as a quick spot-check inside Branch A: dispatch `skill-architecture-checker`
on the target folder and stop.

## Shared Principles

These apply to every branch.

- **Read-only by default.** Audits inspect; they do not edit, rename, or move
  files. Propose, don't apply.
- **Confirmation gate.** Present the remediation plan or recommendation table
  and wait for explicit approval before any file operation.
- **Cheap-agent-first.** Delegate directory scans, clustering, and structural
  checks to the bundled subagents with `model: fast` / `readonly: true`.
  Never read 50+ `SKILL.md` files in the main thread.
- **Propose 1–3 recommendations, not a rewrite.** Recommend the highest-
  leverage change first, then follow-ups.
- **Expected outcomes are required.** Every recommendation must state what
  measurably improves (faster decisions, fewer reads, lower noise, better
  reuse, better activation, safer runtime behavior).
- **One-Hop Rule.** This `SKILL.md` is a router. Every reference and template
  is linked directly from here.

## Branch Procedures

Each branch is a thin handoff to its reference. Follow the numbered steps;
load reference files only when needed.

### A. Single-skill compliance audit
1. Resolve the target — a skill folder or a single `SKILL.md` file.
2. Run `python3 scripts/skill_hot_path_audit.py <target> --json` to
   generate hot-path evidence (v1 schema: `hot_path_metrics`,
   `duplication_buckets`, `findings`, `thresholds`).
3. Apply the cross-platform procedure in `references/single-skill-audit.md`
   (Context Litmus Test, trigger accuracy, progressive disclosure, strict
   outputs, cheap-agent delegation).
4. Apply the matching ecosystem lens in `references/platform-audit-lenses.md`
   (Cursor / Anthropic / Codex) only when the audited artifact targets that
   ecosystem.
5. Optionally dispatch `skill-architecture-checker` on the target folder for a
   compliance spot-check against `docs/architecture.md`.
6. Produce an unapplied remediation plan with proposed diffs or file moves.
   **Pause for approval.**

### B. Improvement recommendation
1. Restate the artifact's current job in one sentence.
2. Run `python3 scripts/skill_hot_path_audit.py <target> --json` to
   identify prompt-visible surface problems. For packs, inspect
   `pack.cross_skill_duplication_buckets` for `multi_skill_shared_phrase`
   and `pack_readme_duplicates_intent_table` findings.
3. Identify the primary problem (trigger/routing quality, hot-path token
   cost, reusable-vs-local boundary, subagent design, install/runtime
   behavior).
4. Read only the matching reference:
   - `references/skill-improvement.md` for skills.
   - `references/pack-improvement.md` for packs.
5. Ask the smallest set of follow-up questions needed to clarify the
   recommendation (one at a time, multiple choice when practical).
6. Recommend 1–3 changes, not a rewrite by default. For each: improvement,
   why it belongs there, expected outcome, effort/risk level.
7. Present using `assets/templates/improvement-recommendation.md`.
   **Pause for approval.**

### C. Installed portfolio audit
1. Inventory the target directory (`~/.cursor/skills`, `~/.agents/skills`,
   `~/.claude/skills`) — state scope explicitly.
2. Dispatch `skill-overlap-clusterer` with the directory and an optional
   filter (e.g., "only skills starting with `gsd-`").
3. Dispatch `skill-architecture-checker` against the folders the clusterer
   flagged as suspicious — not the entire directory at once.
4. Dispatch `skill-consolidation-advisor` with the cluster + architecture
   outputs to produce a scored overlap report.
5. Present the report using `assets/templates/portfolio-audit-report.md`.
   **Pause for approval.**
6. Apply renames, anti-triggers, or archives only after explicit approval.

### D. Repo-first-party overlap audit (deep)
1. Confirm scope is `skills/` in this repo (and optionally
   `packs/*/skills/`).
2. Follow the methodology in
   [`docs/specs/skill-overlap-audit.md`](../../../../docs/specs/skill-overlap-audit.md):
   normalized inventory → cluster A (description) → cluster B (body) →
   cluster C (registry/tags) → arbiter pass.
3. Dispatch cheap read-only subagents in parallel for inventory and each
   cluster pass; reserve a single arbiter subagent to reconcile.
4. Present the report using `assets/templates/portfolio-audit-report.md`,
   augmented with the inventory JSON, the three cluster outputs, and the
   arbiter's final overlap groups.

## Subagent Delegation

Subagents bundled with this pack (`packs/cursor-skill-studio/.cursor/agents/`):

| Subagent | Use when |
|---|---|
| `skill-overlap-clusterer` | Branch C/D: heuristic clustering of a directory by description + body similarity. |
| `skill-architecture-checker` | Branch A spot-check; Branch C/D compliance pass against `docs/architecture.md`. |
| `skill-consolidation-advisor` | Branch C: synthesize cluster + architecture outputs into a scored consolidation report. |
| `skill-creator-bootstrapper` / `-structural-auditor` / `-grader` / `-comparator` / `-analyzer` | Owned by `skill-studio-write` (Branches B and F). Hand off if the user shifts from audit/improve to scaffolding or A/B eval. |

Prefer subagents over inline work whenever the task is bounded, read-heavy,
and would otherwise bloat the main context.

## Repo-Only Operations

These steps only work inside `felipeblassioli/agent-skills`:

- Reading `docs/architecture.md` directly (the
  `skill-architecture-checker` subagent assumes the path exists). Outside the
  repo, pass an architecture excerpt to the subagent instead.
- Running the deep repo-first-party audit (Branch D) against `skills/`.

Audit branches that target installed user directories (Branch C) work in any
workspace.

## Gotchas

- `skill-overlap-clusterer` becomes unactionable on >~50 skills. Scope
  it with a glob filter (for example `gsd-*` or `engineering-*`) before
  dispatching, or the output is noise.
- `skill-architecture-checker` reads `docs/architecture.md` directly.
  Outside `felipeblassioli/agent-skills`, pass an architecture excerpt
  to the subagent instead — do NOT assume the path exists.
- Every improvement recommendation MUST state an **expected outcome**
  AND an **effort/risk level**. Without both, the recommendation is
  unactionable and the user will re-ask the same question next session.
- Audits propose; they never apply. File operations only happen after
  explicit approval — even renames, even anti-trigger edits, even
  obvious deletions.
- Branch A vs Branch F boundary: a portfolio overlap audit does NOT
  run the eval/comparison loop. A/B comparison of two skill candidates
  is `/skill-studio-write` Branch F. Hand off cleanly.

## Output Contracts

| Branch | Final artifact to present |
|---|---|
| A | Unapplied remediation plan: findings table (severity, file, rule, evidence) + proposed diffs/file moves. |
| B | Filled `improvement-recommendation.md` with 1–3 ranked changes, expected outcomes, and effort/risk. |
| C, D | Filled `portfolio-audit-report.md` with executive summary, clusters, architecture violations, and proposed actions with confidence scores. |

## See Also

- `docs/ADR/ADR-0005-skill-authoring-surface-consolidation.md` — why this
  surface exists and how it relates to the deprecated source skills/pack.
- `docs/architecture.md` — repo-wide compliance authority.
- `docs/specs/skill-overlap-audit.md` — normative deep-audit methodology
  (Branch D).
- `../skill-studio-write/SKILL.md` — sibling authoring surface. Hand off
  there for scaffolding, eval/comparison, or external skill import.
