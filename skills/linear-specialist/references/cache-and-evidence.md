# Cache And Evidence

This skill is MCP-first. Cache exists only to reduce repeated reads and preserve
high-signal context between sessions.

## Evidence Order

Prefer evidence in this order:

1. live MCP data
2. fresh local cache
3. focused readonly subagent evidence about current work progress
4. user clarification
5. inference

Do not treat cache as source of truth.

## Minimum-Scope Rule

Always gather the smallest slice that can answer the question.

Prefer:

- one team
- one project
- one issue set
- one issue

Avoid broad workspace scans unless explicitly requested.

## Local Cache Purpose

Use cache to store:

- workspace/team identity already confirmed
- project summaries
- status taxonomy
- label taxonomy
- recent issue snapshots for a specific project
- issue-level deep snapshots only after an explicit audit

Recommended path:

- `.work/linear-specialist/`

Recommended files:

- `workspace-summary.json`
- `team-<key>-workflow.json`
- `project-<slug>-snapshot.json`
- `issue-<id>-snapshot.json`

These are suggestions, not canonical requirements.

## Freshness Policy

Treat cache as:

- fresh for quick orientation
- suspect for status decisions
- stale whenever the user is asking about current progress and recent implementation
- refreshable in slices, not all at once

Good default behavior:

- reuse cache for structure and taxonomy
- refresh live issue/project state before recommending changes
- refresh only the target scope

## Board-Vs-Work Alignment Policy

When the user asks whether Linear reflects actual work:

- do not run a broad direct code or git audit by default
- do not assume absence of evidence means no progress
- prefer either:
  - targeted user questions, or
  - focused readonly subagents that inspect the relevant repo surface

Ask or delegate narrow questions such as:

- what appears implemented already?
- what still looks missing?
- is the issue still scoped correctly?
- does the current progress support the current status?

## Drift Categories

Use these categories consistently:

- `accurate`
- `slightly stale`
- `misleading`
- `missing structure`
- `needs triage`
- `ready to tidy now`

## Evidence Separation

In the final audit report, separate:

- live Linear evidence
- cache evidence
- repo/work-progress evidence
- inference

Never blur them together.

## Safety Notes

- Cache is an optimization layer, not a durable doc surface.
- Cache should be disposable and easy to refresh.
- Do not quietly trust stale snapshots for write decisions.
- When in doubt, prefer a narrow live MCP refresh.
