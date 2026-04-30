# Audit Modes

Use the smallest audit mode that fits the user's real question.

## 1. Board Coherence

Use when the user asks:

- "does this board make sense?"
- "is this organized well?"
- "what should I clean up first?"

Check:

- whether projects have a clear purpose
- whether issue placement feels coherent
- whether labels and statuses are carrying useful signal
- whether the board shape matches the current execution model

Minimum evidence:

- target team
- active projects
- active and recent issues
- status taxonomy
- label taxonomy

Good outcome:

- the board has a clear hierarchy
- status use is consistent
- labels are meaningful
- stale or redundant work is visible

Common drift:

- too many backlog items with no shaping
- project descriptions say one thing while issues imply another
- statuses are technically valid but semantically noisy
- labels overlap or do not influence action

## 2. Hierarchy Audit

Use when the user asks:

- "is the hierarchy right?"
- "should this be an epic or a story?"
- "are these parent-child links coherent?"

Check:

- epics vs stories vs standalone issues
- parent-child relationships
- whether project grouping matches the issue tree
- whether implementation slices are bounded

Minimum evidence:

- target project or issue tree
- parent-child relations
- nearby sibling issues
- project description

Good outcome:

- parent issues represent durable workstreams
- child issues are executable slices
- the tree helps execution rather than adding ceremony

Common drift:

- parents with no real decomposition role
- children that are too broad
- implementation work stored at epic level
- floating issues that obviously belong under a parent

## 3. Label Taxonomy Audit

Use when the user asks:

- "do these labels still make sense?"
- "are labels helping or just noisy?"

Check:

- whether labels encode action, type, or domain clearly
- whether labels are overlapping
- whether labels support actual decisions
- whether readiness labels are trustworthy

Minimum evidence:

- team label list
- sample issues using labels
- issue selection patterns

Good outcome:

- each common label has a clear job
- labels influence triage or execution
- low-value or duplicate labels are minimized

Common drift:

- labels that restate status
- labels with overlapping meanings
- labels applied inconsistently
- readiness labels on unready issues

## 4. Status Workflow Audit

Use when the user asks:

- "what about the statuses?"
- "are we using workflow correctly?"

Check:

- whether statuses match actual work stages
- whether issues are moving honestly
- whether backlog/todo/in-progress/review/done reflect real operational meaning

Minimum evidence:

- team statuses
- a sample of issues per status
- recent issue updates when needed

Good outcome:

- each status has a practical meaning
- issues in a status look similar in readiness/progress
- moving status changes what someone should do next

Common drift:

- Todo used as backlog
- In Progress used for parked work
- Done used while follow-up work is still central
- review states missing or bypassed

## 5. Board-Vs-Work Alignment

Use when the user asks:

- "does this reflect current code?"
- "is Linear aligned with reality?"
- "is this issue still accurate?"

Check:

- whether issue/project descriptions still match current work
- whether status matches apparent progress
- whether linked docs or implementation signals contradict Linear
- whether progress should be clarified, split, or retitled

Minimum evidence:

- targeted issue/project MCP read
- cache if fresh and relevant
- focused readonly subagent or targeted user questions about repo progress

Good outcome:

- Linear is a believable execution surface
- issue descriptions still match implementation reality
- status and structure are not misleading

Common drift:

- issue still says greenfield while repo already contains major work
- story marked ready but missing shaping details
- issue marked active without visible evidence of progress
- project says repo is canonical but issue text still carries stale design truth

## 6. Stale-Work Cleanup

Use when the user asks:

- "what is stale here?"
- "what should I archive or re-triage?"

Check:

- old untouched issues
- backlog clutter
- obsolete project framing
- superseded or misleading tasks

Minimum evidence:

- recent update ordering
- issue status
- selective deep reads only for suspicious items

Good outcome:

- stale issues are identified quickly
- cleanup actions are concrete
- the board gets simpler and more truthful

Common drift:

- old backlog with no next action
- placeholder epics with empty children
- resolved work still represented as active planning
- duplicate or superseded work not marked clearly

## 7. Agent-Readiness Audit

Use when the user asks:

- "is this ready for an agent?"
- "can I hand this to Cursor/Codex?"

Check:

- scope clarity
- acceptance criteria
- links to canonical docs
- blockers or unresolved decisions
- whether readiness labels are earned

Minimum evidence:

- issue details
- related labels
- parent/project context
- focused progress or repo check when necessary

Good outcome:

- issue can be executed without guessing
- blockers are explicit
- the right next step is obvious

Common drift:

- missing acceptance criteria
- vague titles
- repo docs implied but not linked
- "ready" labels used aspirationally
