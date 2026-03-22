# Report Shape

Keep final reports stable so users can compare very different agentic systems
without relearning the format each time.

## Minimum sections

Every final report should include:

1. system shape
2. artifact inventory
3. actor and role map
4. trigger and invocation matrix
5. flow narrative
6. use cases
7. ambiguities or overloaded surfaces
8. recommended next step

## Section guidance

### System shape

State one of:

- `skill-system`
- `workflow-system`
- `plugin-bundle`
- `mixed-agentic-system`

Explain the primary reason for that classification in one or two sentences.

### Artifact inventory

List only the highest-signal paths and the role each path plays.

### Actor and role map

Name the main user-facing surfaces and helper surfaces. Show how responsibility
is split.

### Trigger and invocation matrix

Summarize how users or parent agents start the system and how the system invokes
supporting surfaces.

### Flow narrative

Describe the normal path through the system from entry point to helper surfaces
to outcome.

### Use cases

List the main tasks the system appears designed to support.

### Ambiguities or overloaded surfaces

Call out any confusing overlaps, mixed responsibilities, or misleading names.

### Recommended next step

Choose one:

- deeper discovery on a specific subpath
- migration analysis
- import readiness analysis
- review of a specific workflow or surface
- no follow-up needed for the current question
