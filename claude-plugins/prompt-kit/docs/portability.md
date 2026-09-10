# Portability recommendation

Status: experimental Claude plugin; Codex integration is not implemented.
Reviewed 2026-09-09. Revisit when adding a provider or changing harness versions.
Consumer: the prompt-kit maintainer deciding whether to build a Codex adapter.

Keep placement, capability, consequence and verifier coverage as a shared decision
procedure. Add separate provider profiles and harness instructions for Codex;
do not translate Claude model tiers, effort defaults or prompt-posture claims
one-to-one into GPT settings. Use the provider available in the intended work or
personal environment.

Objectives, constraints, evidence and self-contained handoffs are reasonable shared
practices. Claude aliases, hooks, thinking/fallback settings and effective model
selection need runtime-specific implementation. Even prompt-audit heuristics need
calibration: general prompting guidance does not validate every rule. Consult
[OpenAI reasoning guidance](https://developers.openai.com/api/docs/guides/reasoning-best-practices),
[Codex subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents) and
[Claude model resolution](https://code.claude.com/docs/en/sub-agents#choose-a-model).
A clean draft, configured model and observed execution are different evidence.

Before building the adapter, run a bounded pilot on representative inventory,
mechanical-edit, diagnosis and review tasks with known checks and a consequential
case whose verifier is incomplete. Pin revisions, instructions, models and runtime.
Compare the existing workflow with prompt-kit over repeated trials; compare
continued versus fresh context on the **same model**, and direct versus delegated
execution with both parent and worker usage included. Establish a separate Codex
baseline before evaluating an adapter.

Measure verified outcomes, missed defects, unsupported claims, human corrections,
all-agent token/cache usage, rework and elapsed time. List-price repricing is not
actual billing or quality equivalence. Retain a policy only when required outcomes
hold and a chosen resource measure improves; revise on missed consequential
failures, wrong effective models or increased rework. Report neutral, worse and
inconclusive results. The later context-admission/cache project is independent.
