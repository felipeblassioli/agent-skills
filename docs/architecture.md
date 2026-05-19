# Architecture & Design Principles

This repository is a personal registry for versioned Agent Skills and installable
Cursor packs. It follows the same broad principles as larger agent marketplaces:
granularity, composability, progressive disclosure, and low context cost.

## Core Philosophy

### Single Responsibility

- Each root skill does one reusable guidance or routing job well.
- Each Cursor pack bundles one coherent runtime operating model.
- Skill descriptions optimize activation accuracy rather than summarizing every
  behavior.
- Supporting detail stays in `references/`, `assets/`, `scripts/`, or pack docs.

### Composability Over Bundling

- Root skills under `skills/<name>/` can be synced independently to target
  discovery paths.
- Cursor packs under `packs/<name>/` compose subagents, hooks, rules, MCP
  examples, docs, and optional pack-bundled skills.
- Pack-bundled skills are delivery companions for a pack, not automatic root
  registry entries.
- Broad operating models are split across skills, packs, rules, subagents, hooks,
  and MCP examples instead of folded into one large prompt.

### Context Efficiency

- Frequently loaded surfaces stay small and discriminative.
- `SKILL.md` frontmatter provides the first routing signal.
- Heavy examples and domain references are loaded only when the activated skill
  needs them.
- Deterministic scripts are preferred over long prose for repeated maintenance
  work.

### Maintainability

- `skill-registry.json` is the source of truth for root skill versions, targets,
  tags, and descriptions.
- `cursor-pack-registry.json` is the source of truth for registry-managed pack
  versions and install targets.
- Skill content, registry changes, pack changes, and build tooling changes should
  remain separated in reviewable commits.
- Release units are independent: one skill or one pack can be validated, tagged,
  and released without moving the whole repository.

## Repository Architecture

### Distribution

- **49 registry-managed root skills** in `skill-registry.json`.
- **6 registry-managed Cursor packs** in `cursor-pack-registry.json`.
- **13 pack-bundled skills** declared as `kind: "skill"` artifacts inside pack
  manifests.
- **4 sync targets** for root skills: Cursor, generic agents, Claude, and Gemini.
- **2 install targets** for Cursor packs: project Cursor config and user Cursor
  config.

### Root Skills

Root skills live under `skills/<name>/` and are deployed by
`scripts/skill-sync.sh`. Every registry-managed skill must have:

- `SKILL.md` for agent-facing activation and guidance.
- `metadata.json` for machine-readable version, author, date, and abstract.
- A matching entry in `skill-registry.json`.

Recommended supporting files include `CHANGELOG.md`, `README.md`,
`references/`, `assets/`, and `scripts/`.

### Cursor Packs

Cursor packs live under `packs/<name>/` and are installed by
`scripts/cursor-pack-sync.sh`. A pack can include:

- `.cursor/agents` subagents.
- `.cursor/rules` project rules.
- `.cursor/hooks` and hook configuration.
- `.cursor/mcp.example.json` template MCP configuration.
- `skills/<skillId>/` bundled skills declared with `kind: "skill"` in
  `pack.json`.
- Human-facing guides, release policy, verification evidence, and roadmap files.

Registry-managed packs keep release artifacts at the pack root:

- `README.md`
- `CHANGELOG.md`
- `VERIFICATION.md`
- `RELEASE-POLICY.md`
- `ROADMAP.md`

## Repository Structure

```text
agent-skills/
+-- skills/                         # Root skill sources
|   +-- <name>/
|   |   +-- SKILL.md                # Required agent-facing instructions
|   |   +-- metadata.json           # Required version and metadata authority
|   |   +-- CHANGELOG.md            # Recommended for maintained skills
|   |   +-- README.md               # Optional human-facing docs
|   |   +-- references/             # Optional one-hop supporting docs
|   |   +-- assets/                 # Optional templates and checklists
|   |   +-- scripts/                # Optional deterministic helpers
|   |   +-- rules/                  # Optional rules compiled into AGENTS.md
|   +-- claude.ai/                  # Claude.ai-only skill sources
+-- packs/
|   +-- <name>/
|       +-- pack.json               # Required pack manifest
|       +-- README.md               # Required for registry-managed packs
|       +-- CHANGELOG.md            # Release history
|       +-- VERIFICATION.md         # Release validation evidence
|       +-- RELEASE-POLICY.md       # Release rules
|       +-- ROADMAP.md              # Next work and known gaps
|       +-- .cursor/                # Runtime assets to install
|       +-- skills/                 # Optional pack-bundled skills
|       +-- guides/                 # Optional usage docs
|       +-- assets/                 # Optional examples and templates
+-- docs/
|   +-- ADR/                        # Architecture decision records
|   +-- guides/                     # Human-facing usage guides
|   +-- specs/                      # Maintained artifact contracts
|   +-- agent-skills.md             # Root skill catalog
|   +-- architecture.md             # This file
+-- packages/
|   +-- react-best-practices-build/ # Rules-based skill build tooling
+-- scripts/
|   +-- skill-sync.sh               # Deploy root skills to discovery paths
|   +-- skill-version.sh            # Bump skill versions
|   +-- skill-import.sh             # Import external skills
|   +-- cursor-pack-sync.sh         # Install Cursor packs
|   +-- cursor-pack-verify.sh       # Validate Cursor packs
|   +-- cursor-pack-version.sh      # Bump pack versions
+-- skill-registry.json             # Root skill registry
+-- cursor-pack-registry.json       # Cursor pack registry
```

## Skill Architecture

### Progressive Disclosure

Skills use a three-tier architecture:

1. **Metadata**: frontmatter and registry description for activation.
2. **Instructions**: the compact `SKILL.md` hot path loaded when activated.
3. **Resources**: references, assets, or scripts loaded only when needed.

### Specification Compliance

Root skills follow the Agent Skills shape:

```yaml
---
name: skill-name
description: What the skill does. Use when the agent should activate it.
---
```

This repository adds a maintenance contract:

- `metadata.json` carries version and author metadata.
- `skill-registry.json` declares release targets and tags.
- Maintained skills should include release history in `CHANGELOG.md`.
- Human-facing or source-contract-heavy skills should include `README.md`.

### Skill Archetypes

**Standard skills** are edited directly through `SKILL.md` and optional support
files.

**Rules-based skills** include a `rules/` directory and compile those rules into
`AGENTS.md` through the build tooling in `packages/react-best-practices-build/`.

**Pack-bundled skills** live inside `packs/<pack>/skills/<skillId>/`. They follow
the same skill package expectations, but version and release with their containing
pack unless intentionally promoted to `skill-registry.json`.

## Pack Architecture

### Artifact Types

Packs are installable bundles for Cursor runtime surfaces:

- **Subagents** for context isolation and focused specialist work.
- **Rules** for persistent project guidance.
- **Hooks** for runtime enforcement and auditing.
- **MCP examples** for external capabilities without committing live secrets.
- **Bundled skills** for pack-scoped knowledge and workflow routing.

### Install Profiles

Packs commonly expose:

- `lite`: useful capability with minimal persistent policy.
- `strict`: fuller project guidance, hooks, or guardrails where appropriate.

The installer stages files, backs up conflicts, and records install manifests so
pack changes can be reviewed and restored.

## Design Patterns

### Pattern 1: Root Skill As Knowledge Surface

Use a root skill when the value is reusable task guidance:

```text
skills/tdd-classicist/
+-- SKILL.md
+-- metadata.json
+-- references/
```

The registry entry controls version, targets, tags, and discovery metadata.

### Pattern 2: Pack As Runtime Bundle

Use a pack when the value is runtime behavior:

```text
packs/node-test-verifier/
+-- pack.json
+-- .cursor/agents/
+-- .cursor/rules/
+-- guides/
```

The pack registry controls version, profiles, install targets, and install policy.

### Pattern 3: Pack With Bundled Skill

Use a bundled skill when a pack needs a discoverable workflow entrypoint:

```text
packs/cursor-skill-creator/
+-- pack.json
+-- .cursor/agents/
+-- .cursor/rules/
+-- skills/
    +-- cursor-skill-creator-workflow/
        +-- SKILL.md
        +-- metadata.json
```

The bundled skill teaches when and how to use the pack while the pack provides the
runtime assets.

### Pattern 4: Source Contract Plus Release Evidence

Maintained artifacts should point future editors to the durable source of truth:

- ADRs explain why the repository works this way.
- Specs define artifact contracts.
- README and guides explain usage.
- Changelogs and verification files preserve release history.

## Versioning & Updates

### Root Skill Updates

1. Change the skill content under `skills/<name>/`.
2. Update `metadata.json` if agent-visible behavior changes.
3. Update `skill-registry.json` to match the version and deployment metadata.
4. Update `CHANGELOG.md` for maintained skills.
5. Validate with the relevant sync or validation script.

### Pack Updates

1. Change pack assets under `packs/<name>/`.
2. Update `pack.json` if install behavior, artifacts, or version changes.
3. Update `cursor-pack-registry.json` for registry-managed packs.
4. Update release artifacts when versioning a pack.
5. Validate with `scripts/cursor-pack-verify.sh` and a dry-run install.

## See Also

- [Agent Skills](./agent-skills.md)
- [Cursor Packs Guide](./cursor-packs.md)
- [Agentic Skill and Pack Authoring Specification](./specs/agentic-skill-pack-authoring.md)
- [Skill Authoring Checklist](./specs/skill-authoring-checklist.md)
- [Pack Authoring Checklist](./specs/pack-authoring-checklist.md)
- [Governed Skill Maintenance Model](./ADR/ADR-0002-governed-skill-maintenance-model.md)
