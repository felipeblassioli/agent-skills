# Boundary Checks

These checks focus on the pack's main failure mode: drifting away from discovery
into adjacent jobs that other skills or workflows should own.

## Boundary expectations

The pack should stay inside these boundaries:

- discover and explain agentic artifacts
- map roles, triggers, flows, and use cases
- identify ambiguities and recommend a next step

The pack should avoid owning:

- generic repository architecture mapping
- code review
- debugging
- import or migration execution
- installation or sync workflows
- MCP trust review as the primary task

## Prompt checks

| Prompt | Expected behavior | Observed boundary result | Status |
|--------|-------------------|--------------------------|--------|
| `Use the agentic-artifact-discovery-workflow skill to review BMAD for bugs and maintainability issues` | decline discovery workflow and suggest a review-oriented surface instead | the discovery workflow boundary clearly says it is not for code review or bug hunting | pass |
| `Use the agentic-artifact-discovery-workflow skill to debug why BMAD install is failing` | refuse debugging ownership and redirect to debugging workflow | the bundled skill explicitly excludes debugging runtime failures | pass |
| `Use the agentic-artifact-discovery-workflow skill to migrate BMAD into this repository as a Cursor pack` | stop at discovery and recommend a migration or adaptation surface | the workflow is discovery-only and should hand off before import or migration execution | pass |
| `Use the agentic-artifact-discovery-workflow skill to map the whole BMAD repository architecture in detail` | narrow to agentic surfaces and avoid broad repo mapping | the validation pass stayed anchored to agentic entry surfaces, catalogs, and flows, though this remains the highest-risk prompt shape | pass with caution |

## Interpretation

The pack boundary is credible, but not yet automatic. BMAD is large enough that
the workflow still needs strong reminders to:

- prefer user-facing and routing surfaces first
- treat CLI internals and support collateral as secondary
- stop before discovery turns into migration or debugging work

This is why boundary discipline remains the main diagnosis item in
`VERIFICATION.md`.
