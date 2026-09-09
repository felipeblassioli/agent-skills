# Portability and evaluation recommendation

Status: recommendation, not implemented Codex support. Reviewed 2026-09-09.

## Decision

Keep prompt-kit an experimental Claude plugin while retaining one shared decision
procedure: choose placement, capability and supported effort separately, account
for consequence and verifier coverage, and identify the effective execution target.
Use separate provider profiles and harness instructions when adding Codex support;
do not translate the Claude family ladder one-to-one into GPT models.

Select within the models available in the intended personal or work environment.
A request to use Claude at work is not an instruction to route that work to an
OpenAI account. Recommendation, configured target and observed execution are
separate states.

## What transfers, and what needs verification

| Surface | Assessment |
|---|---|
| Objectives, constraints, source-anchored evidence and acceptance criteria | Suitable shared procedure |
| Placement independent of tier and effort | Suitable shared procedure; economic benefit unproven |
| Self-contained handoffs and bounded delegation | Suitable intent; specify inherited history versus isolated context |
| Claude aliases, hook JSON, profile location and thinking/fallback parameters | Claude runtime instructions; not portable API contracts |
| Model-specific prompt posture and fixed effort defaults | Verify against the target provider and representative tasks |
| Savings or quality improvements | Unknown until compared against a baseline |

OpenAI documents Codex subagents, model and reasoning-effort configuration, and
custom-agent precedence. A model override is not always the final authority.
Context inheritance also depends on the spawning surface: the Codex app tool
inspected during this review exposed inherited-history and isolated-history
choices. Do not generalize that session's schema to every CLI/app version.

- [OpenAI subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents)
- [OpenAI skills](https://learn.chatgpt.com/docs/build-skills)
- [OpenAI reasoning prompting](https://developers.openai.com/api/docs/guides/reasoning-best-practices)
- [Claude subagent model resolution](https://code.claude.com/docs/en/sub-agents#choose-a-model)

OpenAI's clear-goal/constraint guidance supports the shared intent. Its advice to
start with direct prompts and try zero-shot before examples does not establish
universal rules about verbosity, negative instructions or prompt scaffolding.
Treat those prompt-audit heuristics as claims to calibrate for each provider.
A future Codex adapter must verify packaging/discovery, effective model/effort,
context inheritance, permissions and any advisory hook behavior on the actual
supported app/CLI version. No adapter or live compatibility result is claimed here.

## Smallest useful experiment

Use a fixed set of representative tasks: mechanical rename with a covering test,
source inventory with a known answer, diagnosis with competing hypotheses, review
of a known defect, a settled high-consequence change with inadequate tests, and a
repeated correction of an agent-invented boundary. Pin repository revision,
fixtures, allowed models, harness version, instructions and verification criteria.

1. Compare the normal workflow with prompt-kit on the same tasks. Repeat each
   condition at least three times, varying order; this is a pilot, not a statistical
   guarantee. Use the same model settings for the initial placement comparison.
2. For a stuck investigation, compare continued context with a fresh brief on the
   **same model**. Change model in a separate comparison to avoid attributing a
   context reset to greater capability.
3. For bounded delegation, compare direct execution and a worker, recording both
   parent and child usage. Check the effective worker model from execution metadata.
4. Establish a separate Codex baseline before running an adapted version. Do not
   carry Claude price ratios, effort rankings or prompt postures over as results.

Measure verified completion, missed defects, unsupported claims, human correction,
parent context, total input/output/cache usage across all agents, verification and
rework time, elapsed time, and actual model/effort. Price usage only under verified
applicable rates; distinguish list-price estimates from actual billing.

Retain a policy for a task class only when the pilot preserves required outcomes
and improves a chosen resource measure. Explicitly report neutral or worse total
cost even if parent context shrinks. Stop or revise on missed consequential defects,
wrong effective models, weakened authorization, invented constraints, repeated
parent rereads, or increased correction/rework. Keep inconclusive outcomes visible.

Do not make caches, general context admission, or checkpoint infrastructure a
prerequisite for this experiment. Those belong to the separate context project.
