# Agent Collaboration Documentation Architecture

This directory defines a repository-oriented documentation system for agentic
engineering work where agents may have terminal, browser, and codebase access.

The architecture is intentionally separated into five layers. Do not mix layers
unless a document is explicitly about their relationship.

## Updated Documentation Tree (architecture skeleton)

```text
docs/agentic-architecture/
├── README.md
├── ROADMAP.md
├── primary-agent/
│   ├── profile.md
│   ├── operating-manual.md
│   └── collaboration-contract.md
├── memory/
│   ├── bootstrap.md
│   ├── memory-model.md
│   ├── proactive-memory-practices.md
│   ├── session-memory-template.md
│   └── repository-memory-template.md
├── governance/
│   ├── tool-constraints.md
│   ├── approvals.md
│   └── risk-levels.md
├── skills/
│   ├── skills-catalog.md
│   ├── specialized-workflows.md
│   └── delegation.md
└── repository-architecture/
    ├── ai-doc-index.md
    ├── navigation.md
    ├── architecture-maps.md
    └── monorepo-discoverability.md
```

> Current focus: architecture entrypoint and roadmap. Most files above remain
> planned placeholders until phased authoring begins.

## Layer Definitions

### 1) Primary agent layer
Defines the primary coworker identity and operating behavior:
- role and boundaries,
- operating manual,
- collaboration contract with humans and other agents.

### 2) Memory layer
Defines memory bootstrap and persistence mechanics:
- initial context loading,
- memory model (tiers and update rules),
- proactive memory update practices,
- session and repository memory templates.

### 3) Governance layer
Defines execution constraints and risk controls:
- allowed/prohibited tool usage,
- approval and escalation expectations,
- risk levels for read-only vs write operations.

### 4) Skills layer
Defines modular capabilities used by the primary agent:
- skill inventory and fit-for-purpose selection,
- specialized workflows built from skills,
- delegation rules.

Skills are complementary modules, not the full agent system.

### 5) Repository architecture layer
Defines how the repository is exposed for AI navigation:
- AI-readable index and navigation rules,
- architecture maps,
- monorepo discoverability conventions.

## Document Family Roles (north-star boundaries)

- **Primary agent**
  - Answers: "How should the long-lived coworker think, decide, and collaborate?"
  - Owns: role definition, execution behavior, collaboration contract.
  - Does not own: memory persistence rules, governance policy, skill internals.
- **Memory**
  - Answers: "What context persists, at which tier, and when is it updated?"
  - Owns: bootstrap flow, memory tiers, session/repository memory templates.
  - Does not own: agent identity, approval/risk policy, skill catalogs/workflows.
- **Governance**
  - Answers: "What is allowed, restricted, or escalated during execution?"
  - Owns: tool constraints, approvals, risk levels.
  - Does not own: collaboration style, memory schema, task-domain procedures.
- **Skills**
  - Answers: "Which specialized modules exist and when should they be delegated?"
  - Owns: skill catalog, specialized workflows, delegation patterns.
  - Does not own: primary-agent identity, global governance, memory architecture.
- **Repository architecture**
  - Answers: "How should agents discover repository structure and key entry points?"
  - Owns: AI doc index, navigation guidance, architecture maps, discoverability.
  - Does not own: execution policy, collaboration contract, memory lifecycle.

Boundary reminders:
- Primary agent identity is not memory.
- Memory is not governance.
- Skills are not the main agent.
- Repository architecture is not a substitute for execution policy.


## Scope and non-goals

- This documentation system defines how collaboration is organized, not how any
  specific coding task is implemented.
- Skills remain reusable modules; they do not replace primary agent identity,
  memory policy, or governance policy.
- Governance documents define constraints once and are referenced by other
  layers; they should not be redefined in skills or memory files.

## Runtime Flow

- **human ↔ primary agent**: collaboration loop for goals, clarifications,
  execution, and review.
- **primary agent → skills**: primary agent selects and invokes skills as needed.
- **primary agent ↔ memory**: primary agent reads/writes memory according to
  bootstrap and memory model rules.
- **skills constrained by governance**: all skill execution is bounded by tool,
  approval, and risk policies.
- **repository architecture enables discovery**: navigation/index/map docs make
  the codebase discoverable for both primary agent and delegated work.

## Reuse of Existing Repository Content

Reuse existing assets as source material instead of duplicating policy:

- `AGENTS.md` and `.cursor/rules/` for governance/process constraints.
- `skills/*/SKILL.md` and `skill-registry.json` for skills inventory and scope.
- `README.md` and `scripts/skill-*.sh` for repository operation flows.

## Authoring Guardrail

Each file should declare its layer at the top and stay in-layer. Cross-layer
linking is allowed, but cross-layer policy definition should remain explicit and
minimal.
