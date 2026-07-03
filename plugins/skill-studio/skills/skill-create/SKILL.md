---
name: skill-create
description: >-
  Creates Claude skills and plugins. Covers greenfield authoring through Socratic
  discovery, distilling reference material (docs, a tool, an API) into a skill,
  scaffolding a Claude plugin (skills/agents/commands/hooks + plugin.json), and
  evaluating an external skill candidate before importing it. Use when the user
  wants to create, scaffold, or write a new skill or plugin, package reference
  material as a skill, or decide whether to import a skill found elsewhere. Do
  not use to audit or grade an existing skill (route to skill-audit), to improve
  a skill or run the eval/benchmark loop (route to skill-enhance), for versioning,
  releasing, or marketplace catalog work (route to repo-governance:skill-maintainer),
  or to author Cursor packs (use the frozen cursor-skill-studio pack).
---

# Skill Create

The "create" surface of the skill-authoring toolkit. One skill, four branches,
shared principles, two helper subagents. It teaches authoring **Claude skills
and plugins** — not Cursor packs. Pause for confirmation at each phase and
prefer the smallest correct shape.

## Applicability Gate

Apply this skill when ANY of the following are true:

- The user wants to create a new Claude skill from scratch.
- The user provides reference material (docs, code, URLs, a tool) to package as
  a skill.
- The user wants to scaffold a Claude plugin (one or more skills plus sibling
  `agents/`, `commands/`, or `hooks/`).
- The user wants a go/no-go review of an external skill candidate before
  importing it.

Do NOT apply when:

- The user wants to audit, grade, or lint an existing skill, or review a
  portfolio for overlap → route to **skill-audit**.
- The user wants to improve an existing skill or prove a change helped via the
  eval/benchmark loop → route to **skill-enhance**.
- The user wants versioning, release, promotion, or `marketplace.json` catalog
  work → route to **repo-governance:skill-maintainer**.
- The user wants to author a Cursor pack → use the frozen `cursor-skill-studio`
  pack.
- The task is generic code implementation unrelated to skill authoring.

## Intent Router

Pick exactly one branch. Load its references on demand.

| Signal | Branch | Primary references | Supporting assets |
|---|---|---|---|
| New skill, no reference dump; wants Socratic intake | **A. Greenfield** | [references/greenfield-discovery.md](references/greenfield-discovery.md), [references/surface-selection.md](references/surface-selection.md), [references/skill-archetypes.md](references/skill-archetypes.md), [references/plugin-standard.md](references/plugin-standard.md), [references/skill-quality-checklist.md](references/skill-quality-checklist.md) | [assets/templates/skill-contract.md](assets/templates/skill-contract.md), [assets/templates/skill-archetypes/](assets/templates/skill-archetypes/), scripts/validate-skill.sh |
| User provides material (docs, code, URLs, a tool) | **B. Distill material** | [references/material-intake.md](references/material-intake.md), [references/skill-archetypes.md](references/skill-archetypes.md), [references/plugin-standard.md](references/plugin-standard.md), [references/skill-quality-checklist.md](references/skill-quality-checklist.md) | [assets/templates/skill-archetypes/](assets/templates/skill-archetypes/), scripts/validate-skill.sh |
| User wants a plugin bundling several surfaces | **C. Scaffold plugin** | [references/surface-selection.md](references/surface-selection.md), [references/source-decomposition.md](references/source-decomposition.md), [references/plugin-standard.md](references/plugin-standard.md) | [assets/templates/adaptation-report.md](assets/templates/adaptation-report.md) |
| A skill candidate in another repo or path | **D. Evaluate external candidate** | [references/candidate-review.md](references/candidate-review.md), [references/import-paths.md](references/import-paths.md), [references/source-decomposition.md](references/source-decomposition.md) | scripts/inspect-candidate-skill.sh, [assets/templates/skill-intake-report.md](assets/templates/skill-intake-report.md) |

Surface-only question ("should this be a skill, subagent, command, hook, or
plugin?") → load [references/surface-selection.md](references/surface-selection.md)
first, then route.

## Shared Principles

These apply to every branch.

- **Context architecture first.** Treat `SKILL.md` as the hot path. Push detail
  into `references/`, `assets/`, and `scripts/`.
- **One-Hop Rule.** Every reference must be linked directly from `SKILL.md`. No
  multi-hop chains.
- **Smallest correct shape.** Prefer a single standalone skill over a
  multi-surface plugin unless the surfaces must install and version together.
- **Confirm before creating files.** Do not write files until the current phase
  is approved.
- **Defer detail to references.** Keep the hot path a router; the depth lives in
  the reference docs.
- **The agent is already smart.** Skip generic explanations. Include only
  domain-specific knowledge the agent lacks.
- **Cheap-agent-first.** Delegate read-only exploration, classification, and
  shape audits to the subagents below. Reserve the main thread for design.
- **Compose by name.** Reference other skills by name and bundled files via
  `${CLAUDE_SKILL_DIR}` / `${CLAUDE_PLUGIN_ROOT}` — never cross-package relative
  links (installed plugins are copied to a cache).

## Branch Procedures

Each branch is a thin handoff to its references. Follow the numbered steps.

### A. Greenfield skill

1. Confirm surface selection (`references/surface-selection.md`).
2. Run Socratic discovery (`references/greenfield-discovery.md`); fill
   `assets/templates/skill-contract.md`. **Pause for contract approval.**
3. Choose the archetype (`references/skill-archetypes.md`); scaffold from
   `assets/templates/skill-archetypes/`.
4. Scaffold only justified files; keep `SKILL.md` ≤ 500 lines, frontmatter =
   `name` + `description` only; add `metadata.json` + `CHANGELOG.md`.
5. Run `${CLAUDE_SKILL_DIR}/scripts/validate-skill.sh <skill-path>` and walk
   `references/skill-quality-checklist.md`. **Pause for final sign-off.**

### B. Distill from reference material

1. Classify every source with `references/material-intake.md`. **Pause for
   classification approval.**
2. Choose the archetype (`references/skill-archetypes.md`) and scaffold from
   `assets/templates/skill-archetypes/`.
3. Distill — high-signal content only; omit what the agent already knows.
4. Record any external contract the skill teaches in `metadata.json`
   `source_contracts` (`references/plugin-standard.md`).
5. Validate with `scripts/validate-skill.sh` and the quality checklist.

### C. Scaffold plugin

1. Confirm several surfaces are truly needed (`references/surface-selection.md`);
   otherwise fall back to a standalone skill (Branch A/B).
2. Decompose sources into surfaces with `references/source-decomposition.md`;
   present `assets/templates/adaptation-report.md`. **Pause for approval.**
3. Lay out the plugin per `references/plugin-standard.md`:
   `.claude-plugin/plugin.json` (name/version/author), `skills/`, and any
   `agents/`, `commands/`, `hooks/`.
4. Author each skill via Branch A/B rules; reference sibling surfaces by name.
5. Add the plugin to `.claude-plugin/marketplace.json` (repo-only) and
   validate. **Hand versioning/release to `repo-governance:skill-maintainer`.**

### D. Evaluate external candidate

1. Run `${CLAUDE_SKILL_DIR}/scripts/inspect-candidate-skill.sh <candidate-path> [expected-name]`.
2. Read the JSON; classify `ready`, `adapt`, or `reject` with
   `references/candidate-review.md`.
3. If the source is a mixed tree, decompose with
   `references/source-decomposition.md`.
4. Choose the import path from `references/import-paths.md`.
5. Present `assets/templates/skill-intake-report.md`. **Pause for approval.**
6. Only after approval, copy/normalize into `plugins/<plugin>/skills/<name>/`,
   add `metadata.json` + `CHANGELOG.md`, and list the plugin in
   `marketplace.json` if new.

## Subagent Delegation

Helper subagents ship in this plugin's `agents/` — reference them by name:

| Subagent | Use when |
|---|---|
| `skill-creator-bootstrapper` | Branch C/D: classify a mixed source tree and propose an artifact matrix before scaffolding or import. |
| `skill-creator-structural-auditor` | Branch D: shape audit of an external candidate (package shape, trigger quality, hot-path size, repo fit) before import. |

Prefer subagents over inline work whenever the task is bounded, read-heavy, and
would otherwise bloat the main context. Hand the eval/comparison loop OFF to the
sibling **skill-enhance** skill — do not run it here.

## Gotchas

- `SKILL.md` frontmatter is **`name` + `description` only** (plus optional
  `allowed-tools`). Governance/freshness (`version`, `date`, `abstract`,
  `source_contracts`) lives in `metadata.json`. The validator warns on legacy
  frontmatter fields.
- `metadata.json` and `CHANGELOG.md` MUST exist alongside `SKILL.md`, and the
  `CHANGELOG.md` must carry an entry for the `metadata.json` version — the
  repo-root `scripts/validate-skill.sh` treats these as hard failures.
- Claude skills have no explicit-only frontmatter flag; every skill is
  model-invocable. Keep the description tight so the router loads it correctly.
- Reference other skills **by name**; reference bundled files via
  `${CLAUDE_SKILL_DIR}` / `${CLAUDE_PLUGIN_ROOT}`. Cross-package relative links
  break at install time (plugins are copied to a cache).
- Default to a standalone skill. Only build a multi-surface plugin when the
  surfaces must install and version as a unit.
- Never copy a live `mcp.json`. Ship example-only config with `${env:VAR}`
  placeholders and call out trust/portability concerns.
- New/unproven skills belong in a **sandbox** plugin (e.g. `blassioli`).
  Promotion to an official plugin is governance work — hand it to
  `repo-governance:skill-maintainer`.

## Output Contracts

| Branch | Final artifact to present |
|---|---|
| A, B | Filled `skill-contract.md`, file tree, validator JSON, checklist results. |
| C | Filled `adaptation-report.md`, plugin file tree, `marketplace.json` diff, validation output. |
| D | Filled `skill-intake-report.md` with classification, blocking issues, suggested destination. |
