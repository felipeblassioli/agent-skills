# Goal

Offer inspectable, experimental Claude routing and prompt-writing advice through
four skills sharing `~/.claude/model-profiles.md`.

## Invariants

- Placement and capability are independent. Handoffs preserve the selected tier;
  a fresh context does not imply escalation or guarantee independent judgment.
- Effective model selection may come from a matching agent definition or a
  supported call value. Configuration is not proof of execution.
- Repeated failures trigger reassessment of evidence, constraints, verification
  and tooling before capability changes. Reapply consequence floors on de-escalation.
- Extended profiles bind exact identity; legacy profiles require key/source
  verification before model-specific advice. Top-level policy paths match lookups.
  Unsupported effort or unverified posture must not become runtime instructions.
- Advice does not expand authorization. The hook warns about structural problems;
  prompt-audit severity does not create a runtime interception mechanism.
- Cost and quality claims require measured outcomes. Shared input data can reduce
  drift but cannot guarantee that separate model invocations agree.

## Verification state

Implemented: four skill procedures, shared profile example, SessionStart advisory
validator and synthetic regression suite. Behavioral evaluation cases cover
same-tier handoffs, effective selection, reassessment and consequence floors.

Not established by implementation: routing quality, lower all-agent cost,
subscription savings, better defect detection, or Codex compatibility. Historical
transcript counterfactuals are not end-to-end routing exercises.

See [evidence](evidence.md) for observed checks and
[the recommendation](portability.md) for a bounded evaluation before broader use.
