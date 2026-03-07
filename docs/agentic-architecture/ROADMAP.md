# Roadmap: Agent Collaboration Documentation System

## What this documentation system is for

Define a practical, repository-oriented operating model for agentic engineering
workspaces where agents can read code, edit files, run terminal commands, and
use browser tooling.

The goal is predictable collaboration with clear separation between:
- primary agent behavior,
- memory mechanics,
- governance constraints,
- modular skills,
- repository discoverability architecture.


## Third-party reader context

A new contributor should be able to read only this roadmap and understand:
- why these docs are being added in this repository,
- which layer owns each decision type,
- which existing sources are authoritative and should be reused.

## Document families

### Primary agent
- `primary-agent/profile.md`
- `primary-agent/operating-manual.md`
- `primary-agent/collaboration-contract.md`

### Memory
- `memory/bootstrap.md`
- `memory/memory-model.md`
- `memory/proactive-memory-practices.md`
- `memory/session-memory-template.md`
- `memory/repository-memory-template.md`

### Governance
- `governance/tool-constraints.md`
- `governance/approvals.md`
- `governance/risk-levels.md`

### Skills
- `skills/skills-catalog.md`
- `skills/specialized-workflows.md`
- `skills/delegation.md`

### Repository architecture
- `repository-architecture/ai-doc-index.md`
- `repository-architecture/navigation.md`
- `repository-architecture/architecture-maps.md`
- `repository-architecture/monorepo-discoverability.md`


## Document purpose matrix

| Layer | File | Purpose | Scope boundary | Must not redefine / absorb |
|---|---|---|---|---|
| Primary agent | `primary-agent/profile.md` | Define the long-lived coworker role and boundaries. | Identity/role contract for execution and collaboration posture. | Memory tiers, governance policy, skill procedures. |
| Primary agent | `primary-agent/operating-manual.md` | Define default reasoning and execution behavior. | Problem framing, exploration strategy, synthesis/delegation stance. | Tool-approval policy, skill-specific runbooks, memory schema. |
| Primary agent | `primary-agent/collaboration-contract.md` | Define human↔agent interaction norms. | Communication rigor, escalation behavior, reporting/handoffs. | Governance controls, persona theatrics, skill catalog content. |
| Memory | `memory/bootstrap.md` | Define cold-start context acquisition and first memory initialization. | Entry sequence, reading order, bootstrap deliverable and exit condition. | Governance policy authoring, primary-agent identity, full task execution plans. |
| Memory | `memory/memory-model.md` | Define memory tiers and promotion/pruning rules. | Ephemeral/session/repository/collaboration memory lifecycle. | Persona definition, approvals/risk controls, skill definitions. |
| Memory | `memory/proactive-memory-practices.md` | Define proactive memory update triggers and selection discipline. | Checkpoint-driven capture/pruning of decision-shaping operational learnings. | Primary-agent behavior policy, governance decisions, skill procedures. |
| Memory | `memory/session-memory-template.md` | Provide compact template for session working memory. | In-session facts, hypotheses, paths, commands, risks, checkpoints. | Durable repo canon, governance directives, identity contracts. |
| Memory | `memory/repository-memory-template.md` | Provide durable low-noise template for stable repo memory. | Long-lived repository facts, constraints, caveats, stable workflows. | Session scratchpad content, governance policy, skill workflow specs. |
| Governance | `governance/tool-constraints.md` | Define tool-level allowed/prohibited actions. | Execution constraint model for tools/environments. | Collaboration style, memory lifecycle, skill selection logic. |
| Governance | `governance/approvals.md` | Define approval and escalation requirements. | Decision points requiring human confirmation. | Agent identity, memory templates, repository navigation docs. |
| Governance | `governance/risk-levels.md` | Define risk taxonomy and operation classes. | Risk mapping for read/write/impactful actions. | Primary-agent behavior defaults, skill internals, memory promotion rules. |
| Skills | `skills/skills-catalog.md` | Enumerate available skills and intended fit. | Skill inventory, capability boundaries, applicability signals. | Primary-agent role, governance controls, memory ownership. |
| Skills | `skills/specialized-workflows.md` | Define reusable multi-step skill workflows. | Task-type playbooks built from existing skills. | Global execution policy, agent collaboration contract, memory model. |
| Skills | `skills/delegation.md` | Define when/how the primary agent delegates to skills. | Delegation triggers, handoff inputs/outputs, return-to-synthesis. | Primary-agent identity, approvals model, repository architecture canon. |
| Repository architecture | `repository-architecture/ai-doc-index.md` | Define AI-facing index of canonical docs/sources. | Source-of-truth map and retrieval starting points. | Governance policy, collaboration norms, memory tier rules. |
| Repository architecture | `repository-architecture/navigation.md` | Define practical navigation paths through repo artifacts. | Discovery heuristics for directories, docs, and scripts. | Execution constraints, agent role definition, delegation policy. |
| Repository architecture | `repository-architecture/architecture-maps.md` | Define structural maps of systems/packages/dependencies. | High-signal topology and boundaries for understanding impact. | Run-time governance decisions, identity/communication norms, memory templates. |
| Repository architecture | `repository-architecture/monorepo-discoverability.md` | Define conventions that keep large-repo discovery reliable. | Naming/indexing/linking rules for findability at scale. | Tool approval model, primary-agent behavior policy, skill workflow semantics. |

## Maturation phases (no timeline)

### Phase 1: architecture skeleton
- finalize layer boundaries and canonical docs tree,
- define naming conventions,
- keep files mostly as placeholders.

### Phase 2: primary agent definition
- define profile, behavior boundaries, and collaboration contract,
- clarify primary agent responsibilities vs delegated skills.

### Phase 3: bootstrap + memory system
- define first-load bootstrap sequence,
- define memory model and update rules,
- introduce session and repository memory templates.

### Phase 4: governance model
- define tool constraints,
- define approval/escalation decisions,
- define risk levels for operations.

### Phase 5: skills catalog integration
- map existing `skills/*` and `skill-registry.json` into a usable catalog,
- document skill selection and delegation criteria.

### Phase 6: repository architecture mapping
- add AI-readable index and navigation strategy,
- document architecture maps and monorepo discoverability rules.

## Dependencies between document families

- Primary agent docs depend on governance boundaries for executable behavior.
- Memory docs depend on primary agent operating model for write/read ownership.
- Governance docs are independent of specific skills and should remain stable.
- Skills docs depend on existing skill definitions and registry metadata.
- Repository architecture docs enable all other families by improving discovery.

## Reuse plan from current repository

Use current maintained sources instead of rewriting them:

- `AGENTS.md` + `.cursor/rules/` as governance/process references.
- `skills/*/SKILL.md` + `skill-registry.json` as skills sources.
- `README.md` + `scripts/skill-*.sh` as operational references.

## Open questions

1. Should governance have a single canonical source doc that references
   `AGENTS.md` and `.cursor/rules/`, or should both remain co-equal?
2. Should memory templates be prose-first, machine-readable-first, or hybrid?
3. Should skills catalog content be generated from `skill-registry.json`?
4. How should delegation rules vary across runtime environments with different
   permission models?
5. How should architecture maps relate to existing package-local documentation?
