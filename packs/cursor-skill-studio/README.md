---
name: cursor-skill-studio
version: "0.4.0"
description: Cursor pack covering the full skill lifecycle (write, maintain, audit). Ships skill-studio-write as the consolidated authoring surface (greenfield, distillation, pack scaffolding, external intake, Claude-plugin adaptation, eval loop); maintain/audit workflows land in subsequent PRs per ADR-0005.
---

# Cursor Skill Studio

> Renamed from `cursor-skill-creator` in 0.3.0. **0.4.0 lifts the five
> write-side root skills into one consolidated bundled skill,
> `skill-studio-write`**, and stubs the originals.  See
> [`docs/ADR/ADR-0005-skill-authoring-surface-consolidation.md`](../../docs/ADR/ADR-0005-skill-authoring-surface-consolidation.md)
> and the [CHANGELOG](CHANGELOG.md) for the full migration plan.

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

- **`skill-studio-write`** (0.4.0) — consolidated authoring surface for
  greenfield skills, distilling reference material, scaffolding packs,
  external skill intake, Claude-plugin adaptation, and the eval/comparison
  loop. Invoke explicitly via `/skill-studio-write`.
- `cursor-skill-creator-workflow` (deprecated in 0.4.0; superseded by
  `skill-studio-write`; removal target 0.5.0).
- `skill-studio-maintain` / `skill-studio-audit` (skeletons; lifted in PRs 3
  and 4).

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
