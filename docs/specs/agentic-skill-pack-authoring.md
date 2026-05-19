# Agentic Skill and Pack Authoring Specification

## Status

Draft

## Purpose

Define how this repository should author Cursor skills and Cursor packs so they
remain easy to discover, cheap to load, and reliable in agentic workflows.

This specification exists to make three things explicit:

- skills are routing and knowledge surfaces
- packs are installable runtime bundles
- context window quality is a first-class authoring constraint

## Background

This repository already separates:

- `skills/` for discoverable guidance and reusable task knowledge
- `packs/` for runtime assets such as subagents, hooks, rules, and MCP examples

Packs may also **ship bundled skills**: skill-shaped directories inside a pack that
the installer copies into Cursor skill discovery paths (for example
`.cursor/skills/<skillId>/` for project installs and `~/.cursor/skills/<skillId>/`
for user installs). That is a **delivery channel** only. A bundled skill keeps the
same semantics as any other skill (routing and knowledge, `SKILL.md` hot path) and
must not be folded into rules, hooks, or pack README prose.

What has been missing is a durable doctrine for deciding:

- when to create a skill versus a pack
- how to keep hot-path token usage low
- how to delegate work to cheaper agents first
- how to validate that new artifacts improve behavior rather than add noise

## Goals

- Keep skills and packs sharply separated by purpose.
- Optimize top-level authoring surfaces for discovery and routing.
- Preserve high-quality context windows for synthesis and judgment work.
- Make cheap-agent-first delegation the default authoring posture.
- Validate artifacts against realistic prompts or install flows.

## Non-goals

- Maximize documentation volume.
- Turn every adjacent concern into a new skill or pack.
- Duplicate the same policy across README files, `SKILL.md` files, rules, and scripts.
- Use expensive agents for basic retrieval or inventory work.

## Core Principles

### 1. Authoring is context architecture

A skill or pack is not just content. It is a context delivery system.

Quality is determined by whether the artifact:

- activates at the right time
- loads only what is needed
- preserves room for the real task
- changes agent behavior in the intended direction

### 2. Use one clear trigger surface

Each skill or pack should have one obvious reason to exist.

Good examples:

- one skill for one reusable decision or workflow
- one pack for one coherent runtime operating model

Bad examples:

- one skill mixing discovery, implementation, release, and review
- one pack bundling unrelated runtime concerns because they are all "agent stuff"

### 3. Cheap-agent-first delegation

Default to cheaper or faster agents for:

- repository exploration
- file discovery
- classification
- audits
- narrow comparison work

Reserve the primary or more capable agent for:

- synthesis
- doctrine writing
- architecture trade-offs
- final judgment

### 4. Progressive disclosure is required

The top-level document should answer:

- why the artifact exists
- when to use it
- what next file or runtime surface matters

Heavy detail belongs in one-hop supporting files or executable utilities.

### 5. Validate behavior, not prose alone

A polished artifact is not sufficient. A new skill or pack must prove that it:

- routes correctly
- activates appropriately
- improves behavior
- stays within acceptable context cost
- avoids runtime policy collisions

## Skill vs Pack Decision Framework

Create a **skill** when the main value is:

- reusable knowledge
- triggerable guidance
- a decision framework
- a task workflow
- supporting references or scripts that should load on demand

Create a **pack** when the main value is:

- reusable runtime configuration
- subagents
- hooks
- MCP examples
- rule bundles
- installable project or user operating modes

Create both only when:

- the pack provides runtime capability
- the skill teaches when and how to use that capability
- each artifact remains useful on its own without mirroring the other

### Pack-bundled skills

Use **`kind: "skill"`** artifacts in `pack.json` when the pack should install one or
more skills alongside runtime assets. Conventions in this repository:

- **`skillId`**: stable install folder name under the skills root. Prefer
  **pack-scoped** ids (for example `cursor-companion-pack-overview`) so installs
  from `scripts/cursor-pack-sync.sh` are less likely to collide with skills
  deployed by `scripts/skill-sync.sh` from `skill-registry.json` into the same
  `~/.cursor/skills/` namespace.
- **Authoring**: same requirements as repo-root skills (`SKILL.md`, `metadata.json`,
  progressive disclosure). Do not duplicate the skill body into `.cursor/rules` or
  the pack README.
- **Registry**: bundled skills are **not** automatically entries in
  `skill-registry.json`. Promoting a skill to the central registry is a separate,
  intentional step if you want it versioned and synced by `skill-sync.sh`.

## Delegation and Model-Tier Policy

### Default routing policy

1. Start with the smallest agent that can plausibly succeed.
2. Use subagents for bounded retrieval and analysis before synthesis.
3. Ask subagents for evidence and structured findings, not long narratives.
4. Do not let every agent read the same corpus.
5. Keep the primary agent context focused on decisions that need integration.

### Escalation rules

Escalate from a cheaper agent to the primary or more capable agent only when the
task requires:

- cross-cutting synthesis
- long-horizon reasoning
- subtle architecture trade-offs
- higher review quality than a fast pass can provide

## Context and Token Policy

### Hot-path policy

Frequently loaded surfaces must stay small and discriminative:

- skill descriptions should optimize for triggering accuracy
- top-level `SKILL.md` files should guide routing, not carry every detail
- pack README files should explain install shape and runtime intent, not duplicate assets

### Budget rules

1. Spend tokens on triggers before explanations.
2. Spend tokens on common and costly failures before edge-case essays.
3. Spend tokens once. Cross-reference instead of repeating.
4. Prefer deterministic scripts over verbose instructions when possible.
5. Keep references one hop away from the main document.

### Context hygiene rules

- Avoid force-loading large files when routing text is enough.
- Avoid nested reference chains.
- Use descriptive file names that make targeted reads obvious.
- Move domain-heavy detail into supporting references.
- Keep active checklists short enough to remain usable during execution.

## Authoring Workflow

### Phase 1: Observe failures

Collect real evidence before authoring:

- what the agent failed to find
- what it routed incorrectly
- what it over-read
- what it skipped
- what rules it rationalized away

### Phase 2: Choose the right surface

Ask in order:

1. Is the main problem discoverability or reasoning? Create or revise a skill.
2. Is the main problem runtime setup or enforcement? Create or revise a pack.
3. Is the problem both? Split capability and guidance only if both surfaces stay clean.

### Phase 3: Design the smallest useful artifact

For skills:

- define trigger vocabulary
- write the smallest viable `SKILL.md`
- push heavy detail into one-hop references
- provide scripts for deterministic repeated work

For packs:

- define targets and profiles
- separate artifacts by runtime responsibility
- declare bundled skills with `kind: "skill"` and explicit `skillId` values
- keep examples separate from live config
- document what must never be auto-promoted

### Phase 4: Validate realistic use

For skills, validate:

- realistic activation
- correct navigation to supporting files
- behavior under pressure when the skill enforces discipline
- acceptable context cost

For packs, validate:

- install shape by target and profile
- absence of conflicting runtime assets
- user versus project behavior
- safe defaults for hooks and MCP examples

### Phase 5: Refactor the hot path

Remove:

- repeated workflow text
- explanations of knowledge the agent already has
- duplicate examples
- large reference material from the main file

## Validation Gates

An authored skill or pack is ready only when the relevant gates pass.

### Discovery gate

- The artifact activates for the prompts it should match.
- It does not activate too broadly.
- Trigger vocabulary is explicit and realistic.

### Context gate

- The top-level surface is compact.
- Supporting material is one hop away.
- The artifact improves signal more than it consumes context.

### Behavior gate

- The artifact changes behavior in the intended direction.
- Delegation happens cheaply before synthesis.
- Pack runtime assets behave as documented.

### Safety gate

- Hooks are narrow and understandable.
- MCP examples remain examples.
- Project-only assets remain project-only.
- The artifact does not encourage hidden escalation or broad trust.

### Maintenance gate

- The artifact has a clear owner surface.
- Future edits have an obvious home.
- The top-level file can stay small as the artifact evolves.

## Repository Defaults

This repository should treat the following as default authoring policy:

1. Evaluation-first authoring.
2. Cheap-agent-first retrieval and classification.
3. Small hot-path surfaces.
4. One-hop progressive disclosure.
5. Skills versus packs stay separated **by purpose** (knowledge/routing vs
   installable runtime). Packs may still **deliver** bundled skills; those skills
   are not runtime substitutes for rules, hooks, or subagents.
6. Example config stays example config.
7. Deterministic utilities beat long prose for repeated operations.

## Related Documents

- `docs/specs/cursor-pack-specification.md`
- `docs/cursor-packs.md`
- `docs/specs/skill-authoring-checklist.md`
- `docs/specs/pack-authoring-checklist.md`
