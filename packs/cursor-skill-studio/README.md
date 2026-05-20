---
name: cursor-skill-studio
version: "1.2.0"
description: Stable consolidated Cursor pack for the full skill lifecycle (write, audit, maintain). Ships skill-studio-write (greenfield, distillation, pack scaffolding, external intake, Claude-plugin adaptation, eval loop), skill-studio-audit (single-skill compliance audit, improvement recommendations, installed portfolio audit, deep repo-first-party overlap audit), and skill-studio-maintain (root-skill and pack releases, registry alignment, bundled-skill artifact edits, promotion/demotion, maturity classification, install verification).
---

# Cursor Skill Studio

> **1.1.0 — ADR-0005 cleanup complete.** PR 6 of
> [ADR-0005](../../docs/ADR/ADR-0005-skill-authoring-surface-consolidation.md)
> deletes the nine deprecated root-skill stub directories
> (`writing-cursor-skills`, `create-skill-from-refs`,
> `create-cursor-pack-from-refs`, `external-skill-intake`,
> `claude-plugin-to-cursor-pack`, `audit-skill-for-cursor`,
> `improving-agent-artifacts`, `personal-skill-maintainer`,
> `personal-pack-maintainer`) and their `skill-registry.json` entries,
> moves the deprecated `skill-consistency-auditor` pack to
> `packs/.archive/`, and drops the legacy
> `cursor-skill-creator-workflow` bundled skill from this pack. The
> three explicit-only studio bundled skills (`skill-studio-write`,
> `skill-studio-audit`, `skill-studio-maintain`) are now the only
> authoring / audit / maintain entry points in the repo.

`cursor-skill-studio` packages a reusable authoring workflow for turning
reference material, existing skills, and Claude-style plugin bundles into
installable Cursor-native artifacts, and (from the 0.3.0 line onward) extends
that into maintenance and audit workflows for skills and packs already in the
repository.

The pack combines three layers:

- a bundled installed skill for intake, decomposition, scaffolding, and review
- reusable helper subagents for grading, blind comparison, structural auditing,
  analysis, and bootstrap
- optional strict project rules that reinforce the intended authoring workflow

It is intentionally opinionated about adaptation strategy:

- treat skills as routing and knowledge surfaces
- treat packs as installable runtime bundles
- prefer bundled skills when guidance should ship with the pack
- keep Claude-only workflows out of the hot path unless explicitly adapted
- use deterministic scripts for evaluation and review when possible

## Profiles

- `lite`: installs the bundled workflow skill and helper subagents
- `strict`: installs the same runtime plus project-only guidance for intake,
  decomposition, and evaluation discipline

## Target support

- `project-cursor`: installs into a repository's `.cursor/` directory
- `user-cursor`: installs into `~/.cursor/`

Project installs can include `.cursor/rules/` for the `strict` profile.
User installs skip rules because Cursor user rules are managed in settings
rather than a `~/.cursor/rules/` directory.

## Included runtime assets

Authoring helpers (existing):

- `.cursor/agents/skill-creator-bootstrapper.md`
- `.cursor/agents/skill-creator-grader.md`
- `.cursor/agents/skill-creator-analyzer.md`
- `.cursor/agents/skill-creator-comparator.md`
- `.cursor/agents/skill-creator-structural-auditor.md`

Audit helpers (merged in 0.3.0 from the deprecated `skill-consistency-auditor` pack):

- `.cursor/agents/skill-overlap-clusterer.md`
- `.cursor/agents/skill-architecture-checker.md`
- `.cursor/agents/skill-consolidation-advisor.md`

Bundled installed skills:

- **`skill-studio-write`** — consolidated authoring surface for
  greenfield skills, distilling reference material, scaffolding packs,
  external skill intake, Claude-plugin adaptation, and the eval/comparison
  loop. Invoke explicitly via `/skill-studio-write`.
- **`skill-studio-audit`** — consolidated audit surface: single-skill
  compliance audit, improvement recommendations for an existing skill or
  pack, installed portfolio audit (three-subagent pipeline), and the deep
  repo-first-party overlap methodology. Invoke explicitly via
  `/skill-studio-audit`.
- **`skill-studio-maintain`** — consolidated maintain surface:
  root-skill release, pack release, bundled-skill artifact edits,
  promotion/demotion, maturity classification (ADR-0003), and install
  verification. Invoke explicitly via `/skill-studio-maintain`.

The legacy `cursor-skill-creator-workflow` bundled skill (deprecated
in 0.4.0, superseded by `skill-studio-write`) was removed in 1.1.0.
Existing user installs should re-sync to drop the stale files.

Optional strict project rules under `.cursor/rules/`.

## What `skill-studio-write` covers

`skill-studio-write` is the consolidated authoring entry point. Invoke it with
`/skill-studio-write` to route into one of six branches:

| Branch | Use when |
|---|---|
| A — Greenfield skill | The user wants to create or refactor a Cursor skill through Socratic discovery (no reference dump). |
| B — Skill from reference material | The user provides docs, code, or URLs to package as a skill. |
| C — Pack from reference material | The user wants an installable pack under `packs/<name>/` (with optional bundled skills). |
| D — External skill intake | The user has a candidate skill folder elsewhere and wants a go/no-go review before importing. |
| E — Claude-plugin adaptation | The user has a `.claude-plugin/`, `.mcp.json`, or mixed plugin tree to decompose into Cursor-native artifacts. |
| F — Eval / comparison loop | The user wants evidence (blind A/B, structural audit, grading) that an authoring change improved the artifact. |

## What `skill-studio-audit` covers

`skill-studio-audit` is the consolidated audit and improvement entry point.
Invoke it with `/skill-studio-audit` to route into one of four branches:

| Branch | Use when |
|---|---|
| A — Single-skill compliance audit | The user wants to audit one skill (or a small set) for context efficiency, progressive disclosure, and compliance with `docs/architecture.md`. |
| B — Improvement recommendation | The user wants 1–3 highest-leverage recommendations for an existing skill or pack before any rewrite. |
| C — Installed portfolio audit | The user wants to audit `~/.cursor/skills`, `~/.agents/skills`, or `~/.claude/skills` for overlap, vague triggers, and bad bundling. Uses the three audit subagents in pipeline. |
| D — Repo-first-party overlap audit | The user wants the deep methodology in `docs/specs/skill-overlap-audit.md` applied to repo `skills/` (e.g., to inform a consolidation ADR). |

Audits are read-only and propose-don't-apply by default.

## What `skill-studio-maintain` covers

`skill-studio-maintain` is the consolidated governance and release entry
point. Invoke it with `/skill-studio-maintain` to route into one of six
branches:

| Branch | Use when |
|---|---|
| A — Root skill release | The user wants to bump a SemVer on `skills/<name>/`, refresh CHANGELOG/README, and sync `skill-registry.json`. |
| B — Pack release | The user wants to bump a pack, refresh CHANGELOG/VERIFICATION/ROADMAP, and sync `cursor-pack-registry.json`. |
| C — Bundled-skill artifact | The user wants to add, edit, or remove a `kind: "skill"` artifact in `pack.json`. |
| D — Promotion / demotion | The user wants to promote a pack-bundled skill into a root skill (or stop bundling one). |
| E — Maturity & backlog | The user wants to classify or reclassify an artifact under ADR-0003. |
| F — Install verification | The user wants to run `cursor-pack-verify.sh` plus per-profile `cursor-pack-sync.sh --dry-run` before merge. |

Maintain proposes changes first and applies them only after explicit
approval. Bump scripts (`scripts/skill-version.sh`,
`scripts/cursor-pack-version.sh`) and verify scripts live at the repo root;
the bundled skill orchestrates them.

The hot-path `SKILL.md` stays compact and routes to one-hop references,
templates, and bundled scripts (`validate-skill.sh`, `validate-pack.sh`,
`inspect-candidate-skill.sh`, `bootstrap_skill_comparison.py`,
`aggregate_benchmark.py`, and the eval review UI).

## What this pack expects from a project

This pack works best when the repository can supply:

- a target artifact shape: bundled skill, pack, or both
- clear source material such as a source tree, docs, or existing workflows
- a writable `.work/` area for review and benchmark outputs
- Python 3 for the bundled evaluation tooling

## Guides

- [guides/installation.md](guides/installation.md)
- [guides/evaluation-workflow.md](guides/evaluation-workflow.md)
- [guides/skill-comparison.md](guides/skill-comparison.md)
- [guides/adapting-existing-skills.md](guides/adapting-existing-skills.md)

## Release Artifacts

- [CHANGELOG.md](CHANGELOG.md)
- [VERIFICATION.md](VERIFICATION.md)
- [RELEASE-POLICY.md](RELEASE-POLICY.md)
- [ROADMAP.md](ROADMAP.md)
