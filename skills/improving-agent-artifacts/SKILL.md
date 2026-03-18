---
name: improving-agent-artifacts
description: >-
  Improve existing Cursor skills and Cursor packs by asking focused diagnostic
  questions, then recommending concrete changes with expected outcomes. Use
  when the user wants to refine an existing skill or pack, reduce noise or
  token cost, sharpen subagent delegation, or decide which improvement will
  have the highest leverage.
---

# Improving Agent Artifacts

Improve an existing skill or pack before rewriting it.

Optimize for:

- sharper scope boundaries
- cheaper routing and retrieval
- smaller hot-path context
- better subagent usage
- recommendations with explicit expected outcomes

## Applicability Gate

Apply this skill when ANY of the following are true:

- the user wants to improve an existing skill under `skills/`
- the user wants to improve an existing pack under `packs/`
- the user wants recommendations before implementing changes
- the user wants to reduce noise, token cost, or over-reading
- the user wants better subagent delegation or clearer boundaries

Do NOT apply when:

- the task is creating a net-new skill from scratch
- the task is creating a net-new pack from scratch
- the user only wants implementation without diagnosis
- the artifact should actually become a rule, hook, or subagent rather than a
  skill or pack improvement

## Inputs Required

Minimum input:

- target artifact path or name
- whether it is a skill or pack, if known
- observed problem or symptom
- desired improvement or expected outcome

Useful follow-up inputs:

- examples of noisy behavior or bad routing
- constraints on compatibility or install behavior
- whether the priority is speed, cost, reliability, or lower context use

## Routing Table

| Need | Route to |
|---|---|
| Diagnose an existing skill | [references/skill-improvement.md](references/skill-improvement.md) |
| Diagnose an existing pack | [references/pack-improvement.md](references/pack-improvement.md) |
| Present recommendations and expected outcomes | [assets/templates/improvement-recommendation.md](assets/templates/improvement-recommendation.md) |

## Question Flow

Ask only enough questions to identify the highest-leverage improvement.

Prefer one question at a time. Prefer multiple choice when practical.

Cover these in order:

1. What artifact is being improved?
2. What is the current job of the artifact in one sentence?
3. What is the main pain: wrong routing, too much noise, too much context,
   unclear boundaries, weak subagent design, or poor install/runtime shape?
4. What improvement matters most right now?
5. What outcome should improve measurably: faster decisions, fewer reads,
   lower noise, better reuse, better activation, or safer runtime behavior?

## Procedure

1. Restate the artifact's current job in one sentence.
2. Identify whether the primary problem is:
   - trigger/routing quality
   - hot-path token cost
   - reusable-versus-local boundary
   - subagent design
   - install/runtime behavior
3. Read only the matching reference:
   - `skill-improvement.md` for skills
   - `pack-improvement.md` for packs
4. Ask only the smallest set of follow-up questions needed to clarify the
   recommendation.
5. Recommend 1-3 changes first, not a rewrite by default.
6. For each recommendation, state:
   - the improvement
   - why it belongs there
   - the expected outcome
   - effort or risk level
7. Distinguish:
   - highest-leverage change now
   - follow-up improvements later

## Recommendation Policy

- Do not recommend both a skill and a pack unless both are clearly needed.
- Default to moving repo-specific noise out of reusable artifacts.
- Default to cheap-agent-first retrieval before synthesis.
- Prefer a bootstrap-once plus steady-state-fast pattern when the artifact is
  repeatedly invoked.
- Prefer thinner top-level docs and one-hop references over large dispatcher
  files.

## Output Contract

Use the structure in
[assets/templates/improvement-recommendation.md](assets/templates/improvement-recommendation.md).

The final answer should always make clear:

- what should change
- why it should change
- what outcome to expect if it changes
