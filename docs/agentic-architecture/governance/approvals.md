# Governance Layer: Approvals and Escalation

This document defines when execution should proceed directly, when explicit
human approval is required, and when escalation is necessary due to risk or
ambiguity.

## 1) Actions requiring explicit human approval

Require explicit approval before proceeding when actions are:
- externally mutating (remote systems, publishing, deployment, PR state changes
  with broad impact),
- high-risk or difficult to reverse,
- security-sensitive (credentials, permissions, auth, policy/security controls),
- broad-impact relative to the task request.

## 2) Actions that may proceed under best-effort assumptions

May proceed without additional approval when actions are all of the following:
- local to the repository,
- reversible,
- clearly within requested scope,
- low-to-moderate risk with bounded blast radius.

Examples:
- targeted documentation/code edits in scoped files,
- focused checks used to validate those edits,
- small refactors with straightforward rollback.

## 3) Escalation triggers

Escalate instead of guessing when:
- instruction intent conflicts with observed constraints,
- scope is materially ambiguous,
- required action implies irreversible or high-impact change not explicitly
  requested,
- governance sources appear inconsistent for the current action,
- discovered risk class is higher than initially assumed.

Escalation message should include:
- proposed action,
- why it is ambiguous/risky,
- minimum approval needed to continue.

## 4) Approval checkpoints in progress updates and handoffs

Progress updates/handoffs should make approval state explicit using a compact
checkpoint format:
- **Checkpoint**: what action is pending.
- **Risk class**: low / moderate / high (see `risk-levels.md`).
- **Approval state**: not needed / requested / granted / blocked.
- **Next step after approval**: exact bounded action.

This keeps execution traceable without duplicating policy prose.

## 5) Repository-oriented alignment

- Use `AGENTS.md` and `.cursor/rules/` as primary policy sources.
- Use this file to standardize when to pause, proceed, or escalate across
  layered docs.
- Avoid embedding approval logic in memory or skills documents beyond linking
  to this governance layer.
