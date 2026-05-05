# Prompt Matrix

This matrix records the prompts used to pressure-test the discovery workflow
against `tmp/BMAD-METHOD`.

| Prompt | Intended behavior | Expected route | Actual route | Outcome | Notes |
|--------|-------------------|----------------|--------------|---------|-------|
| `Use the agentic-artifact-discovery-workflow skill to explain the flows and use cases in tmp/BMAD-METHOD` | Produce a broad but still structured discovery report | classify target -> explore key surfaces -> synthesize report | classified as `mixed-agentic-system`, prioritized README, package, catalogs, help, persona skill, workflow | pass | Produced a useful top-level system narrative without collapsing into generic repo summary |
| `Use the agentic-artifact-discovery-workflow skill to show how BMAD routes a user from planning entry to PRD creation` | Explain one concrete cross-file flow | classify -> read PM persona, help/catalog, PRD workflow | traced PM persona -> `bmad-init` -> capability code `CP` -> PRD workflow step-file architecture | pass | Good example of the pack supporting flow-focused questions, not only inventories |
| `Use the agentic-artifact-discovery-workflow skill to identify the main user-facing surfaces versus helper/runtime surfaces in tmp/BMAD-METHOD` | Separate entry surfaces from support machinery | classify -> inventory -> role split | identified install CLI, help skill, persona skills, task skills, catalog and installer helpers | pass | Confirms the pack can organize the system by user value rather than by directory only |
| `Use the agentic-artifact-discovery-workflow skill to tell me whether BMAD is a skill system, workflow system, plugin bundle, or something mixed` | Test classification quality directly | classify first, justify choice with evidence | returned `mixed-agentic-system` with evidence from CLI, skills, catalogs, and workflow files | pass | This is the most important classification result from the BMAD scenario |
| `Use the agentic-artifact-discovery-workflow skill to summarize every part of the BMAD repository` | Detect and resist generic full-repo mapping drift | should narrow scope to agentic surfaces only | kept focus on high-signal agentic files and noted noisy support collateral as secondary | pass with caution | Broad prompt still tempts over-reading; boundary reminders remain necessary |
