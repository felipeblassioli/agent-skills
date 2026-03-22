# Panel Mode

Use this guide when one explanation is not enough and the user wants the skill
to iterate with multiple BMAD role perspectives.

## Purpose

Run a small focused panel, not a broad brainstorming session.

The parent agent should:

1. inspect the installed BMAD setup first
2. choose only the roles needed
3. ask each role one narrow question
4. reconcile conflicts
5. write the final audit report

## Default Roles

### Analyst

Use for:

- identifying cross-cutting invariants
- deciding whether a rule is durable policy or temporary output
- spotting duplicated reasoning across roles

Prompt focus:

- Which rules should be explicit and durable?
- Which current customizations look duplicated or misplaced?
- Which output artifacts contain candidate rules that were never promoted?

### PM

Use for:

- deciding whether the behavior is process, scope, or one-off execution
- deciding if a recurring refinement practice deserves a workflow/checklist

Prompt focus:

- Which recurring behavior should become a named workflow or checklist?
- Which rules belong in role prompts versus shared team process?
- What traceability or approval gaps exist?

### Scrum Master

Use for:

- readiness gates
- checklist design
- refinement sequence
- operational handoff and queue discipline

Prompt focus:

- What is the actual readiness gate?
- What steps should be explicit in a refinement checklist?
- Where does the current process allow drift or fake readiness?

## Optional Roles

### Tech Writer

Use when:

- the output needs durable standards, report structure, or codified policy text

### Dev

Use when:

- the customization affects implementation handoff, context quality, or story
  execution

### UX

Use when:

- refinement depends on proof artifacts, journeys, screenshots, or demo evidence

## Briefing Material

Before launching a role-specific subagent, give it only the smallest set of
materials:

- the installed role file under `_bmad/.../agents/...`
- the matching `*.customize.yaml`, if present
- the one or two `_memory/` or `_bmad-output/` files relevant to the question

Do not dump the entire `_bmad/` tree into every subagent.

## Output Contract

Each role should return:

- what it believes is happening now
- what is good and should stay
- what is misplaced or duplicated
- what surface should own the behavior
- one recommended change with expected outcome

The parent agent remains responsible for the final reconciliation and report.
