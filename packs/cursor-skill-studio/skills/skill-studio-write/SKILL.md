---
name: skill-studio-write
description: >-
  Write, adapt, and validate Cursor skills and packs in
  felipeblassioli/agent-skills. Covers greenfield skill authoring through
  Socratic discovery, distilling reference material into a skill, scaffolding a
  pack under `packs/<name>/`, evaluating an external skill candidate before
  import, decomposing a Claude-style plugin into Cursor-native artifacts, and
  running the eval and comparison loop that proves an authoring change improved
  the artifact. Use when the user wants to create or refactor a skill or pack,
  needs help with `SKILL.md`, `metadata.json`, `pack.json`, or pack-bundled
  skills, or wants to decide whether content should live in a skill, pack,
  rule, hook, subagent, or docs. Invoke explicitly via `/skill-studio-write`.
  Do not use for portfolio overlap audits (use `skill-studio-audit`),
  governance or registry version bumps (use `skill-studio-maintain`), or skill
  install and sync (use the repo scripts directly).
disable-model-invocation: true
---

# Skill Studio — Write

Authoring surface for Cursor skills and packs in this repository. One skill,
six branches, shared principles and subagents. Pause for confirmation at each
phase and prefer the smallest correct shape.

## Applicability Gate

Apply this skill when ANY of the following are true:

- The user wants to create or refactor a Cursor skill.
- The user wants to create a Cursor pack under `packs/<name>/`.
- The user provides reference material (docs, code, URLs) to package as a
  skill or pack.
- The user wants a go/no-go review of an external skill candidate before
  importing it into `skills/`.
- The user wants to decompose a Claude-style plugin or mixed plugin folder
  into Cursor-native artifacts.
- The user wants evidence (an eval loop, blind comparison, or source audit)
  that an authoring change actually improved the artifact.

Do NOT apply when:

- The user wants a portfolio overlap or compliance audit across many skills
  → use `skill-studio-audit`.
- The user wants registry versioning, release artifacts, or governance work
  → use `skill-studio-maintain`.
- The user only wants to install, sync, list, or version existing skills
  → use the repo scripts (`scripts/skill-sync.sh`, `scripts/skill-version.sh`,
  `scripts/skill-import.sh`).
- The task is generic code implementation unrelated to skill or pack
  authoring.

## Intent Router

Pick exactly one branch. Each branch lists the primary references and supporting
templates/scripts to load on demand.

| Signal | Branch | Primary references | Supporting assets |
|---|---|---|---|
| New skill, no reference dump; user wants Socratic intake | **A. Greenfield skill** | `references/greenfield-discovery.md`, `references/surface-selection.md`, `references/skill-archetypes.md`, `references/cursor-skill-standard.md`, `references/skill-quality-checklist.md` | `assets/templates/skill-contract.md`, `assets/templates/skill-archetypes/*`, `scripts/validate-skill.sh` |
| User provides reference material (`@docs`, code, URLs) for a skill | **B. Skill from refs** | `references/material-intake.md`, `references/skill-archetypes.md`, `references/cursor-skill-standard.md`, `references/skill-quality-checklist.md` | `assets/templates/skill-archetypes/*`, `scripts/validate-skill.sh` |
| User wants an installable pack under `packs/<name>/` | **C. Pack from refs** | `references/material-intake.md`, `references/pack-standard.md`, `references/pack-archetypes.md`, `references/pack-quality-checklist.md` | `assets/templates/pack/*`, `assets/templates/bundled-skill-artifact.fragment.json`, `scripts/validate-pack.sh` |
| Candidate skill in another repo or arbitrary path | **D. External skill intake** | `references/candidate-review.md`, `references/import-paths.md` | `scripts/inspect-candidate-skill.sh`, `assets/templates/skill-intake-report.md` |
| `.claude-plugin`, `.mcp.json`, mixed plugin tree | **E. Claude-plugin adaptation** | `references/source-decomposition.md`, `references/pack-standard.md`, `references/cursor-skill-standard.md` | `assets/templates/adaptation-report.md`, `assets/templates/bundled-skill-artifact.fragment.json` |
| User wants proof an authoring change improved the artifact | **F. Eval / comparison loop** | `references/eval-loop.md` | `scripts/bootstrap_skill_comparison.py`, `scripts/aggregate_benchmark.py`, `eval-viewer/generate_review.py` |

Surface-only question ("should this be a skill, rule, hook, subagent, or pack?")
→ load `references/surface-selection.md` first; route afterwards.

## Shared Principles

These apply to every branch.

- **Context architecture first.** Treat `SKILL.md` (or `pack.json`) as the hot
  path. Push detail into `references/`, `assets/`, and `scripts/`.
- **One-Hop Rule.** Every reference must be linked directly from `SKILL.md`.
  No multi-hop chains.
- **Smallest correct shape.** Prefer a single repo-root skill over a pack
  unless runtime assets are required. Prefer pack-bundled skills over copying
  guidance into rules.
- **Cheap-agent-first.** Delegate read-only exploration, classification, and
  blind grading to subagents with `model: fast` / `readonly: true`. Reserve
  the main thread for design decisions.
- **Strict output shapes.** Prefer JSON or constrained tables over chatty
  prose, especially for intake summaries and pack contracts.
- **The agent is already smart.** Skip generic explanations. Only include
  domain-specific knowledge the agent does not have.
- **Confirmation before files.** Do not write files until the current phase
  has been approved.

## Branch Procedures

Each branch is a thin handoff to its references. Follow the numbered steps;
load reference files only when needed.

### A. Greenfield skill
1. Confirm surface selection (`references/surface-selection.md`).
2. Run Socratic discovery (`references/greenfield-discovery.md`); fill
   `assets/templates/skill-contract.md`. **Pause for contract approval.**
3. Choose the archetype (`references/skill-archetypes.md`).
4. Scaffold only justified files; keep `SKILL.md` ≤ 500 lines.
5. Run `scripts/validate-skill.sh <skill-path>` and walk through
   `references/skill-quality-checklist.md`. **Pause for final sign-off.**

### B. Skill from reference material
1. Classify every source with `references/material-intake.md`. **Pause for
   classification approval.**
2. Choose archetype (`references/skill-archetypes.md`) and scaffold from
   `assets/templates/skill-archetypes/`.
3. Distill — high-signal content only; omit what the agent already knows.
4. Validate with `scripts/validate-skill.sh` and the quality checklist.

### C. Pack from reference material
1. Classify sources with `references/material-intake.md`. **Pause for
   classification approval.**
2. Pick a pack archetype (`references/pack-archetypes.md`). **Pause for scope
   approval.**
3. Define the pack contract (artifact matrix, targets, profiles, install
   policy). Use `references/pack-standard.md`. **Pause for scaffold approval.**
4. Scaffold from `assets/templates/pack/`. For bundled skills, use
   `assets/templates/bundled-skill-artifact.fragment.json` and a pack-scoped
   `skillId`.
5. Add the entry to `cursor-pack-registry.json` (repo-only operation).
6. Run `scripts/validate-pack.sh <pack-name>` (wraps
   `scripts/cursor-pack-verify.sh`). Walk through
   `references/pack-quality-checklist.md`. **Pause for final sign-off.**

### D. External skill intake
1. Run `scripts/inspect-candidate-skill.sh <candidate-path> [expected-name]`.
2. Read the JSON output. Classify `ready`, `adapt`, or `reject`.
3. Apply `references/candidate-review.md` to check repo fit.
4. Choose the import path from `references/import-paths.md`.
5. Present `assets/templates/skill-intake-report.md`. **Pause for approval.**
6. Only after approval, copy/normalize into `skills/<name>/`, add
   `metadata.json`, and register in `skill-registry.json`.

### E. Claude-plugin adaptation
1. Inspect the candidate root cheaply before reading many files.
2. Classify each file with `references/source-decomposition.md`
   (`pack-runtime`, `skill-guidance`, `docs-reference`, `claude-only`,
   `ignore`).
3. Recommend the smallest correct destination shape (pack only, repo-root
   skill only, pack with bundled skills, or pack/skill plus docs).
4. Call out MCP trust/portability concerns explicitly; default to example
   config with `${env:VAR}` placeholders, never live `mcp.json`.
5. Present `assets/templates/adaptation-report.md`. **Pause for approval.**
6. If the user proceeds with import, route to Branch C or D as appropriate.

### F. Eval / comparison loop
1. Bootstrap a workspace with `scripts/bootstrap_skill_comparison.py` (see
   `references/eval-loop.md` for the layout and JSON schemas).
2. Run candidate + baseline against shared `evals.json` prompts.
3. Grade with `skill-creator-grader`; compare blindly with
   `skill-creator-comparator`; audit structure with
   `skill-creator-structural-auditor`.
4. Aggregate with `scripts/aggregate_benchmark.py`; render the review UI
   with `eval-viewer/generate_review.py`.
5. Produce the recommendation with `skill-creator-analyzer`.

## Subagent Delegation

Subagents shipped with this pack (`packs/cursor-skill-studio/.cursor/agents/`):

| Subagent | Use when |
|---|---|
| `skill-creator-bootstrapper` | Branch C/E: mixed source tree needs an artifact matrix before scaffolding. |
| `skill-creator-structural-auditor` | Branch F: source-level comparison of two skills; pre-import shape audit (Branch D). |
| `skill-creator-grader` | Branch F: grade eval outputs against expectations. |
| `skill-creator-comparator` | Branch F: blind A/B comparison of outputs. |
| `skill-creator-analyzer` | Branch F: synthesize grades + comparisons + structural findings into the recommendation. |
| `skill-overlap-clusterer` / `skill-architecture-checker` / `skill-consolidation-advisor` | Owned by `skill-studio-audit`. Hand off if the user shifts from authoring to portfolio review. |

Prefer subagents over inline work whenever the task is bounded, read-heavy,
and would otherwise bloat the main context.

## Repo-Only Operations

These steps only work inside `felipeblassioli/agent-skills`:

- Registering a new skill in `skill-registry.json`.
- Registering a new pack in `cursor-pack-registry.json`.
- Importing an external skill via `scripts/skill-import.sh`.
- Verifying a pack via `scripts/cursor-pack-verify.sh`.

If the user is in another workspace, stop and report the missing dependency
rather than improvising.

## Output Contracts

| Branch | Final artifact to present |
|---|---|
| A, B | Filled `skill-contract.md`, file tree, validator JSON, checklist results. |
| C | Pack contract table, file tree, `cursor-pack-registry.json` diff, `cursor-pack-verify.sh` output. |
| D | `skill-intake-report.md` filled with classification, blocking issues, suggested destination. |
| E | `adaptation-report.md` with destination matrix, MCP classification, blocking concerns, smallest viable migration plan. |
| F | Analyzer JSON (`analysis.json`) with recommendation, evidence, residual risks. |

## Confirmation Policy

Do not write files until the current phase is approved. Pause after:

1. Surface decision (when applicable).
2. Skill contract or intake summary.
3. Archetype / pack contract.
4. Draft `SKILL.md` / `pack.json` and supporting files.
5. Validation results.

## See Also

- `docs/ADR/ADR-0005-skill-authoring-surface-consolidation.md` — why this
  surface exists and how it relates to the deprecated source skills.
- `docs/specs/skill-authoring-checklist.md` — compact authoring checklist.
- `docs/specs/agentic-skill-pack-authoring.md` — skill-vs-pack doctrine.
- `docs/specs/pack-recommendation-metadata.md` — future advisory-MCP schema
  (formerly bundled inside `create-cursor-pack-from-refs`).
