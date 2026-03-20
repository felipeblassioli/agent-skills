---
name: engineering-architecture
description: Use when creating or evaluating an architecture decision record, choosing between technologies with trade-offs, or documenting a design decision for a new component or service.
---

# Engineering Architecture

Create an Architecture Decision Record or evaluate a design proposal with clear
trade-offs, consequences, and next steps.

## Good Fits

- choosing between technologies such as queues, databases, or cloud services
- reviewing a proposed architecture before implementation
- documenting a decision in ADR format

For broader greenfield system design, prefer `engineering-system-design`.

## Useful Inputs

- the decision to make or the proposal to review
- constraints such as scale, compliance, team familiarity, or deadline
- the alternatives already on the table
- any existing ADRs, architecture docs, or related tickets

## Output Shape

```markdown
# ADR-[number]: [Title]

**Status:** Proposed | Accepted | Deprecated | Superseded
**Date:** [Date]
**Deciders:** [Who needs to sign off]

## Context
## Decision
## Options Considered
## Trade-off Analysis
## Consequences
## Action Items
```

## Connected Tools

If connector categories are available:

- knowledge base: search for prior ADRs and runbooks
- project tracker: link the decision to epics or follow-up tasks

## Common Mistakes

- skipping alternatives and treating one option as the default
- hiding the biggest trade-off in the recommendation section
- writing an ADR that describes implementation details but not the decision

## Tips

1. State constraints early: timeline, scale, cost, compliance, or team skill.
2. Name at least two serious alternatives.
3. Make the trade-offs explicit instead of implying one option is obviously best.
