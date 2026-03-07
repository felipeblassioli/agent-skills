# Governance Layer: Risk Levels

This document defines a compact risk taxonomy for repository actions so tool
usage and approvals scale with impact.

## Risk taxonomy

### Low risk — read-only / non-mutating
Characteristics:
- no repository or external state changes,
- reversible by definition (no mutation),
- narrow information-gathering intent.

Repository examples:
- read files and docs,
- inspect directory structure,
- run read-only discovery commands.

Default handling:
- proceed directly,
- prefer narrow probes.

### Moderate risk — reversible write / bounded mutation
Characteristics:
- local mutation with clear rollback path,
- scope limited to requested files/surfaces,
- impact reviewable in small-to-medium diff.

Repository examples:
- targeted doc/code edits,
- small refactors with bounded file set,
- local generation/formatting with controlled output.

Default handling:
- proceed when scope is explicit,
- use focused validation,
- escalate if scope drifts or hidden side effects appear.

### High risk — broad or irreversible impact
Characteristics:
- broad blast radius or difficult rollback,
- external side effects or persistent remote impact,
- sensitive/security-critical surface.

Repository examples:
- sweeping repo-wide rewrites,
- destructive history/data operations,
- deploy/release/publish actions,
- security policy or permission model changes.

Default handling:
- require explicit approval before execution,
- present intended scope and impact first,
- prefer phased execution over one-shot broad operations.

## How risk level influences tool usage and approvals

- **Low risk**: read-first discovery and direct execution.
- **Moderate risk**: bounded writes with proactive checkpoint reporting.
- **High risk**: explicit approval gate and escalation discipline.

Risk should be reassessed as new information appears. If an operation moves to
higher risk than initially classified, pause and follow the approval/escalation
path in `approvals.md`.

## Layer boundary reminder

This taxonomy supports governance only:
- it does not define primary-agent identity or collaboration style,
- it does not define memory tiers/templates,
- it does not replace skill-level procedures.
