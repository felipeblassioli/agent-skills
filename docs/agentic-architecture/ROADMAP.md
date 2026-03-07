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
