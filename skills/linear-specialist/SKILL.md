---
name: linear-specialist
description: Use when the user wants to audit, tidy, or reality-check a Linear board using MCP-first evidence, especially for project hierarchy, labels, statuses, stale work, and whether Linear reflects the current state of work.
disable-model-invocation: true
---

# Linear Specialist

Use this skill when the real task is to inspect and tidy a Linear workspace or
project as an execution control plane, especially when the user asks in partial
or messy forms like "does this board make sense?", "what about the labels?", or
"does Linear reflect reality?".

## Applicability Gate

Use this skill when ANY of the following are true:

- the user wants to know whether a Linear board makes sense overall
- the user wants to audit project hierarchy, epics, stories, or issue placement
- the user wants to review labels, statuses, or workflow discipline
- the user wants to know whether the board is stale, drifted, or misleading
- the user wants to compare Linear state against current repo reality
- the user wants to identify cleanup actions for projects, issues, labels, or statuses
- the user wants to know whether issues are actually ready for agent execution
- the user asks a vague Linear question that is really about board hygiene or board-to-work alignment

Do NOT use this skill when:

- the task is building a Linear API client, integration, or automation
- the task is generic project management advice without inspecting Linear
- the task is mainly about GitHub issues, PRs, or commit workflows
- the task is implementing repo code without a real Linear audit question
- the task is a broad code review unrelated to whether Linear reflects progress

## Routing Table

| Question | Route to |
|---|---|
| "Does this board make sense?" | [references/audit-modes.md](references/audit-modes.md) |
| "Is the hierarchy right?" | [references/audit-modes.md](references/audit-modes.md) |
| "Are the labels or statuses working?" | [references/audit-modes.md](references/audit-modes.md) |
| "Is this board stale or drifted?" | [assets/quickref/drift-signals-checklist.md](assets/quickref/drift-signals-checklist.md) |
| "Does Linear reflect current work?" | [references/cache-and-evidence.md](references/cache-and-evidence.md) |
| "Should I trust the cache or refresh MCP?" | [references/cache-and-evidence.md](references/cache-and-evidence.md) |

## Procedure

1. Confirm the target scope:
   - workspace
   - team
   - project
   - issue set
   - single issue

2. Normalize the user's request into one primary audit mode:
   - board coherence
   - hierarchy audit
   - label taxonomy audit
   - status workflow audit
   - board-vs-work alignment
   - stale-work cleanup
   - agent-readiness audit

3. Use MCP first and gather only the minimum evidence needed:
   - team, project, issue, label, status, milestone, cycle, comment, or document scope
   - avoid broad workspace scans unless the user explicitly asks for them

4. If a relevant local cache exists, use it only as a speed layer:
   - treat it as non-canonical
   - check freshness before relying on it
   - refresh only the slice you need when stale or incomplete

5. When the question is about whether Linear reflects actual progress, do NOT do a broad direct code or git audit by default.
   Instead:
   - ask 1-3 targeted clarifying questions, or
   - launch focused readonly subagents to inspect current repo progress, implementation state, or missing work
   - ask those subagents narrow questions such as:
     - what appears implemented already?
     - what remains clearly unfinished?
     - does this issue description still match the current repo state?
     - are there signs the status should change?

6. Classify findings using explicit drift categories:
   - accurate
   - slightly stale
   - misleading
   - missing structure
   - needs triage
   - ready to tidy now

7. Produce a tidy-up report that separates:
   - live Linear evidence
   - cache evidence
   - repo/work-progress evidence
   - inference

8. Recommend the smallest useful cleanup actions first:
   - reparent or split issues
   - relabel or remove noisy labels
   - move status
   - mark blocked or decision-needed
   - update issue/project description
   - archive stale work
   - refresh cache

## Normalization Hints

Interpret partial prompts like this unless the user clarifies otherwise:

- "does this board make sense?" -> board coherence
- "the hierarchy?" -> hierarchy audit
- "the labels?" -> label taxonomy audit
- "the status?" -> status workflow audit
- "does it reflect our code?" -> board-vs-work alignment
- "what is stale here?" -> stale-work cleanup
- "is this ready?" -> agent-readiness audit

## Subagent Policy

Use subagents only when MCP evidence alone cannot answer whether Linear matches
real work.

Prefer:

- narrow readonly repo inspection
- one question per subagent when possible
- small evidence requests over broad codebase exploration

Good subagent questions:

- "Inspect the current repo state for this issue and tell me what seems done vs missing."
- "Check whether the linked docs and implementation still match this issue's described scope."
- "Summarize whether current code progress supports Todo, In Progress, In Review, or Done."

Do not delegate the entire board audit to a subagent.

## Report Contract

When performing an audit, produce:

- target scope
- audit mode
- evidence used
- findings ordered by importance
- drift classification
- recommended cleanup actions
- open questions
- confidence level

## Confirmation Policy

Do not make Linear changes without explicit user approval.

When evidence is incomplete, ask the smallest clarifying question needed or run
a focused readonly subagent before recommending a status or structure change.

## Related Skills

- `gh-issue-verifier` when the real task is GitHub issue implementation proof
- `gh-pr-creator` or `commit-hygiene` when the real task is PR or commit handling
- repository-specific implementation skills when the real task is coding, not board hygiene
