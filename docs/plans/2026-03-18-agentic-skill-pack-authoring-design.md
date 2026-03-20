# Agentic Skill and Pack Authoring Design

> Strategy document for authoring Cursor skills and Cursor packs with strict token discipline, high-signal context windows, and agentic delegation by default.

**Status:** Draft  
**Audience:** Agents authoring skills and packs on behalf of the repository owner  
**Primary goal:** Produce smaller, sharper, more testable skills and packs that are cheap to activate, easy to discover, and reliable under real agent workflows.

## Why This Exists

This repository already separates two different products:

- `skills/` store discoverable knowledge and task guidance.
- `packs/` store runtime assets such as subagents, hooks, rules, templates, and MCP examples.

What is missing is a single authoring doctrine that tells an agent:

- when to create a skill versus a pack
- how to keep the context footprint low
- how to route work to cheaper or faster agents first
- how to preserve high-quality context windows for the tasks that truly need them
- how to validate that a new skill or pack improves behavior instead of adding noise

The design goal is not "more documentation." The design goal is **better routing, better context architecture, and lower token waste**.

## Design Decisions

### 1. Treat authoring as context architecture

A skill or pack is not just content. It is a **context delivery system**. Its quality depends on:

- whether it activates at the right time
- whether it loads only what is needed
- whether it preserves room for the actual task
- whether it changes agent behavior in the intended direction

Every authoring decision should be evaluated against context cost.

### 2. Prefer one canonical trigger surface

Each skill or pack should have one obvious reason to exist.

Good:

- one skill for a single reusable decision pattern
- one pack for one coherent runtime bundle

Bad:

- one skill mixing discovery, implementation, release, and review
- one pack bundling unrelated rules, hooks, examples, and domain guidance only because they are all "agent stuff"

### 3. Default to cheaper and faster agents

Agentic workflows should assume:

- a cheaper or faster agent handles discovery, classification, audits, and narrow retrieval first
- the primary agent or a more capable agent is reserved for synthesis, architectural choices, and final writing only when needed

This preserves context window quality by preventing expensive agents from doing low-value scanning work.

### 4. Progressive disclosure is mandatory

The main file should answer:

- why this artifact exists
- when to use it
- what next file, script, or runtime asset to load

Heavy reference, long examples, large checklists, and reusable scripts should live outside the main file and be loaded on demand.

### 5. Validate behavior, not prose quality alone

A good-looking skill or pack is not enough. Authoring must verify:

- discovery works
- routing works
- instructions are followed under pressure
- token cost stays acceptable
- runtime assets do not create policy conflicts

## Operating Principles

### Principle 1: Discovery before detail

The highest leverage tokens are the tokens that control whether the right artifact is selected at all.

For skills this means:

- names should be searchable and action-oriented
- descriptions should contain trigger conditions and vocabulary the agent would actually match on
- descriptions should avoid summarizing the whole workflow when that summary would cause the body to be skipped

For packs this means:

- `pack.json` and top-level docs should make the install intent obvious
- profiles should map cleanly to operating modes, not marketing labels
- artifacts should be grouped by runtime responsibility

### Principle 2: Keep hot paths tiny

Frequently loaded surfaces must stay short:

- frontmatter and descriptions must be dense and discriminative
- top-level `SKILL.md` files should stay compact
- pack README files should explain shape, not duplicate every runtime asset

The more often a surface is read, the stricter its token budget should be.

### Principle 3: Separate routing knowledge from execution detail

The main doc should route. Supporting files should instruct. Scripts should execute. Runtime assets should enforce.

Do not duplicate the same rule in all four places unless the duplication is deliberate and justified.

### Principle 4: Author for retrieval, not narration

Agents need:

- explicit triggers
- crisp decisions
- stable file names
- one-hop references
- deterministic utilities when available

Agents do not need:

- memoirs about how the author discovered the pattern
- broad essays that mix use cases and implementation detail
- redundant examples teaching the same point repeatedly

### Principle 5: Context is a shared budget

Every loaded token competes with:

- system instructions
- repository rules
- conversation history
- open files
- code and docs relevant to the actual task

The correct default is to assume context is scarce even when the nominal window is large.

## Skill vs Pack Decision Framework

Create a **skill** when the primary value is:

- reusable knowledge
- routing and triggerable guidance
- a decision framework
- task-specific workflows
- references or scripts that should load on demand

Create a **pack** when the primary value is:

- reusable runtime configuration
- subagents
- hooks
- MCP examples
- rule bundles
- installable operating modes for projects or user environments

Create both only when:

- the pack provides runtime capabilities
- the skill teaches when and how to use those capabilities
- each artifact still has a clear standalone purpose

Do **not** create both when one artifact exists only to mirror the other.

## Delegation Strategy

### Default routing policy

Use a cheap or fast subagent first for:

- file discovery
- repo exploration
- candidate classification
- baseline audits
- pattern inventory
- narrow comparison work

Escalate to the primary agent only for:

- cross-cutting synthesis
- architecture or authoring decisions
- final doctrine writing
- trade-off resolution
- conflicting evidence

Escalate to a more capable agent only when the task has at least one of these properties:

- long-horizon reasoning
- many competing constraints
- subtle architecture trade-offs
- review quality matters more than speed

### Delegation rules

1. Start with the smallest agent that can plausibly succeed.
2. Give subagents bounded prompts with explicit return formats.
3. Ask subagents for evidence, not polished narratives.
4. Never let every agent read everything.
5. Preserve the primary agent context for synthesis and final judgment.

### Good delegation shape

- retrieval agent: find relevant files, names, and patterns
- audit agent: classify strengths, weaknesses, and collisions
- primary agent: distill principles and write the canonical document

### Bad delegation shape

- many agents all reading the same corpus
- expensive agent doing grep-equivalent work
- subagents returning large prose dumps instead of structured findings

## Token and Context Budget Policy

### Budgets by surface

These are repository policy targets, not hard parser limits:

| Surface | Target |
|---|---|
| Skill `description` | As short as possible while still being discriminative |
| Frequently used `SKILL.md` | Prefer under 200-300 words when feasible |
| Standard `SKILL.md` | Prefer under 500 lines and aggressively shorter when possible |
| Pack README | Explain install model and included capabilities; avoid runtime duplication |
| Supporting references | Split by domain; one hop from the main file |
| Reusable utilities | Prefer executable scripts over inline code when deterministic |

### Budget rules

1. Spend tokens on triggers before explanations.
2. Spend tokens on edge cases only if they are common or costly.
3. Spend tokens on examples only when the example teaches something the prose cannot.
4. Spend tokens once. Cross-reference instead of repeating.
5. If a script can do it reliably, prefer execution over verbose instructions.

### Context window hygiene

To keep the active context high quality:

- avoid force-loading large files when routing text would suffice
- avoid nested reference chains deeper than one hop from the main document
- keep filenames descriptive enough that agents can target the right file quickly
- place domain-heavy material in dedicated reference files instead of bloating the top-level file
- keep checklists short enough to track without drowning the active task

## Authoring Workflow

### Phase 1: Observe real failure modes

Before writing a skill or pack, collect evidence from real use:

- What does the agent fail to find?
- What does it route incorrectly?
- What does it over-read?
- What does it skip?
- What rules does it rationalize away?

Write only what fixes observed failure modes or closes obvious structural gaps.

### Phase 2: Choose the right surface

Ask in order:

1. Is the problem primarily discoverability or reasoning? Use a skill.
2. Is the problem primarily runtime behavior or reusable environment setup? Use a pack.
3. Is the problem both? Split into pack runtime plus skill guidance only if both surfaces remain clean and non-duplicative.

### Phase 3: Design the context architecture

For a skill:

- define the trigger vocabulary
- write the smallest viable `SKILL.md`
- place heavy detail in one-hop references
- prefer scripts for repeatable deterministic operations

For a pack:

- define the install targets and profiles
- separate runtime artifacts by responsibility
- keep examples separate from live config
- document what the installer must never auto-promote

### Phase 4: Validate with realistic workflows

For skills, validate:

- activation on realistic prompts
- correct file navigation
- compliance under pressure for discipline-enforcing guidance
- acceptable token footprint

For packs, validate:

- install shape by target and profile
- absence of conflicting runtime assets
- clear user-versus-project behavior
- safe defaults for hooks and MCP examples

### Phase 5: Refactor for smaller hot paths

After the first draft, remove:

- workflow repetition already implied by structure
- explanatory text teaching what the agent already knows
- duplicated examples
- reference material that belongs in separate files

The default refactor question is: **what can move out of the hot path without harming discovery or correctness?**

## Validation and Release Gates

An authored skill or pack is ready only when all relevant gates pass.

### Discovery gate

- The artifact activates for the prompts it should match.
- It does not activate too broadly.
- Trigger vocabulary is explicit and realistic.

### Context gate

- The top-level surface is compact.
- Supporting material is one hop away.
- The artifact does not force unnecessary reads.
- The loaded context improves signal more than it consumes space.

### Behavior gate

- The skill changes agent behavior in the intended direction.
- The pack installs the intended runtime shape without surprising side effects.
- Delegation guidance produces bounded, cheap retrieval before synthesis.

### Safety gate

- Hooks are understandable and narrow.
- MCP examples remain examples, not accidental live config.
- Project-only assets stay project-only.
- The artifact does not encourage broad trust or hidden escalation.

### Maintenance gate

- The artifact has a single clear owner surface.
- File structure makes future edits obvious.
- The top-level doc still explains where to add future content without growing unbounded.

## Anti-Patterns

Avoid these during skill and pack creation:

- authoring from imagination instead of from observed failures
- stuffing one skill with multiple workflows because they are adjacent
- turning a pack into a document dump
- turning a skill into runtime policy when a pack should enforce it
- using expensive agents for retrieval work
- writing long descriptions that summarize the entire workflow
- repeating the same guidance in README, `SKILL.md`, references, and scripts
- deep reference chains that force exploratory reading
- large inline examples when a script or smaller pattern would do
- bundling example MCP config as if it were safe live config

## Recommended Repository Policy

This repository should adopt the following defaults for future authoring:

1. **Evaluation-first authoring:** New skills and packs should respond to observed failures, not generic aspirations.
2. **Cheap-agent-first retrieval:** Discovery, search, and classification should be delegated before synthesis.
3. **Small hot surfaces:** Keep descriptions and top-level docs aggressively small.
4. **One-hop disclosure:** Main documents may point to supporting files, but supporting files should not become their own navigation maze.
5. **Strict skill-pack separation:** Skills teach and route. Packs install and enforce.
6. **Examples are not live config:** Especially for MCP and hooks, examples stay examples.
7. **Prefer deterministic utilities:** If a repeatable script can replace a verbose process description, ship the script.

## Authoring Checklist

Use this checklist before adding or revising a skill or pack:

- [ ] I can state in one sentence why this should be a skill, a pack, or both.
- [ ] The top-level surface is optimized for discovery, not for completeness.
- [ ] I removed knowledge the agent almost certainly already has.
- [ ] Supporting detail sits behind one-hop references.
- [ ] I delegated retrieval and classification to cheaper agents where possible.
- [ ] I reserved richer context for synthesis and judgment.
- [ ] I validated the artifact against realistic prompts or install flows.
- [ ] I checked that token savings did not reduce behavioral reliability.
- [ ] I avoided duplicating runtime policy in narrative docs unless necessary.
- [ ] I left a future editor with an obvious place to extend the artifact safely.

## Suggested Next Documents

This strategy document should be followed by no more than two supporting artifacts if the repository needs them later:

- a reusable skill-authoring checklist tailored to this repo
- a pack-authoring checklist tailored to this repo

Do not create those by default. Only add them if repeated use shows the single strategy document is not sufficient.
