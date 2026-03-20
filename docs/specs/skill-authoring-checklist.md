# Skill Authoring Checklist

Use this checklist when creating or revising anything under `skills/`.

## Fit

- [ ] I can explain in one sentence why this should be a skill and not a pack.
- [ ] The skill has one clear purpose, not several adjacent workflows bundled together.
- [ ] The value is primarily guidance, routing, reusable knowledge, or on-demand reference.

## Trigger Surface

- [ ] The skill name is searchable and specific.
- [ ] The description uses realistic trigger vocabulary.
- [ ] The description helps the skill activate correctly without becoming a workflow summary.
- [ ] The description is compact enough to stay cheap in the metadata hot path.

## Main File

- [ ] `SKILL.md` explains why the skill exists and when to use it.
- [ ] The top-level file routes to the next useful reference, script, or step.
- [ ] The main file is small enough to preserve context for the real task.
- [ ] I removed explanations the agent almost certainly already knows.

## Progressive Disclosure

- [ ] Heavy detail lives in supporting files, not the hot path.
- [ ] Supporting references are one hop away from `SKILL.md`.
- [ ] Filenames are descriptive enough to support targeted reads.
- [ ] Large examples appear only when they teach something the prose cannot.

## Scripts and Utilities

- [ ] I used a deterministic script when it can replace repeated prose instructions.
- [ ] It is clear whether a script should be executed or read as reference.
- [ ] Supporting utilities are narrow and obviously related to the skill purpose.

## Behavior and Evaluation

- [ ] The skill responds to an observed failure or repeated need, not an imagined one.
- [ ] I checked whether the skill activates on realistic prompts.
- [ ] I checked whether the agent follows the intended navigation path.
- [ ] If the skill enforces discipline, I tested it under pressure rather than only academically.

## Token and Context Discipline

- [ ] I spent tokens on triggers before explanations.
- [ ] I avoided repeating the same guidance across description, body, and references.
- [ ] I kept the hot path smaller than the full reference surface.
- [ ] The skill improves signal more than it consumes context.

## Final Readiness

- [ ] A future editor has an obvious place to add more detail without bloating `SKILL.md`.
- [ ] The skill still makes sense if supporting files grow later.
- [ ] The artifact is easy to discover, cheap to load, and precise in scope.
- [ ] For skills that evolve across releases, `CHANGELOG.md` at the skill root
  records notable changes (Keep a Changelog style) and aligns with
  `metadata.json` `version` when present.
