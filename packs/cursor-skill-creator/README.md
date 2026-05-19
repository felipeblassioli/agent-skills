---
name: cursor-skill-creator
version: "0.2.0"
description: Portable authoring pack for creating, adapting, and comparing Cursor-native skills and packs with a bundled workflow skill, evaluation toolkit, and helper subagents.
---

# Cursor Skill Creator

`cursor-skill-creator` packages a reusable authoring workflow for turning
reference material, existing skills, and Claude-style plugin bundles into
installable Cursor-native artifacts.

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

- `.cursor/agents/skill-creator-bootstrapper.md`
- `.cursor/agents/skill-creator-grader.md`
- `.cursor/agents/skill-creator-analyzer.md`
- `.cursor/agents/skill-creator-comparator.md`
- `.cursor/agents/skill-creator-structural-auditor.md`
- bundled installed skill at `.cursor/skills/cursor-skill-creator-workflow/`
  or `~/.cursor/skills/cursor-skill-creator-workflow/`
- optional strict rules under `.cursor/rules/`

## What the bundled skill covers

The bundled workflow skill is the main entry point when the user wants to:

- create a new Cursor pack from reference material
- adapt a Claude-style skill or plugin-like folder into Cursor-native artifacts
- compare two skills using shared eval prompts plus a source-structure audit
- decide whether a source should become a pack, a bundled skill, docs, or a mix
- set up an eval workspace and use review or benchmark tooling for authoring

The installed skill stays compact and pushes detail into one-hop references,
templates, and scripts bundled alongside it.

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
