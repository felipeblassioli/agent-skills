---
name: create-cursor-pack-from-refs
description: >-
  Create Cursor packs from user-provided reference material and repo context.
  Guides through intake, pack archetype selection, pack scaffolding under
  `packs/<name>/`, registry updates, and verification against this repository's
  pack conventions. Use when the user asks to create a Cursor pack, author
  `pack.json`, scaffold pack runtime assets, or package subagents, rules, hooks,
  MCP examples, guides, and optional pack-bundled skills (`kind: "skill"`) into
  an installable Cursor bundle.
disable-model-invocation: true
---

# Create Cursor Pack from References

Transform reference material into a repo-native Cursor pack for
`felipeblassioli/agent-skills`.

This skill is modeled on `create-skill-from-refs`, but targets the pack system:

- source trees live in `packs/<name>/`
- the catalog entry lives in `cursor-pack-registry.json`
- validation runs through `scripts/cursor-pack-verify.sh`
- install behavior is documented, but never executed automatically
- evolving packs should usually commit release artifacts such as `CHANGELOG.md`,
  `VERIFICATION.md`, `RELEASE-POLICY.md`, and `ROADMAP.md`

## Applicability Gate

Apply this skill when ANY of the following are true:

- the user wants a new installable Cursor pack under `packs/`
- the user provides reference docs, examples, or policies that should become a
  reusable bundle of subagents, rules, hooks, MCP examples, guides, and/or
  bundled skills shipped with the pack
- the task requires authoring `pack.json` and the matching registry entry
- the user wants a repo-aware pack scaffold rather than ad hoc `.cursor/` files

Do NOT apply when:

- the user wants to install, sync, restore, or verify an existing pack only
  - use the repo scripts directly: `scripts/cursor-pack-sync.sh`,
    `scripts/cursor-pack-restore.sh`, `scripts/cursor-pack-verify.sh`
- the user wants a reusable knowledge skill rather than a runtime bundle
  - use `create-skill-from-refs`
- the user wants to implement an MCP recommender or mutate live `mcp.json`
  - keep that work in `.work/` design notes until pack metadata matures

## Repo Awareness

Always preserve these repository constraints while authoring a pack:

- Packs are authored in `packs/<name>/`, never directly in `~/.cursor/`
- Create only the directories that will contain content
- The pack name must match the directory name and `pack.json.name`
- `cursor-pack-registry.json` must include the new pack entry
- Validation must go through `scripts/validate-pack.sh`, which wraps the
  canonical repo validator `scripts/cursor-pack-verify.sh`
- Pack authoring may create templates and examples, but must not install the
  pack or update PRs automatically
- MCP files must stay example-only unless the user explicitly asks for a
  different design and the repo standards support it

For the pack schema and current repo conventions:

- `references/pack-standard.md`
- `references/pack-archetypes.md`
- `references/recommendation-metadata.md`
- `references/quality-checklist.md`

## Phase 1 — Intake

Read and classify every reference the user provides.

### Material classification

| Material type | Classification | Destination |
|---|---|---|
| Architecture notes, operating model, product intent | Pack concept | `README.md`, guides, metadata choices |
| Existing `.cursor/` files, examples, snippets | Runtime artifact reference | matching `.cursor/...` path in pack |
| Guard-rails, policies, safety rules | Policy surface | `.cursor/rules/`, hooks, guides |
| Workflow descriptions for reviewers/helpers | Subagent concept | `.cursor/agents/*.md` |
| Reusable task guidance tied to the pack install | Bundled skill | `packs/<name>/skills/<folder>/` + `kind: "skill"` row in `pack.json` |
| Example MCP config, server docs | MCP example | `.cursor/mcp.example.json`, guides |
| Install or usage instructions | Operational guide | `guides/*.md` |
| Checklists or validation expectations | Quality gate | `references/quality-checklist.md` or `scripts/validate-pack.sh` |
| Release notes, test evidence, evolution plans | Release artifact | `CHANGELOG.md`, `VERIFICATION.md`, `RELEASE-POLICY.md`, `ROADMAP.md` |

### Intake actions

1. Read each source fully.
2. Classify it using the table above.
3. Distill high-signal content only.
4. Note which Cursor surfaces are implied: `skill`, `rule`, `subagent`, `hook`,
   `MCP`, or `pack`.
5. Identify what should remain documentation versus what should become a runtime
   artifact.

Present the result as:

```markdown
## Intake Summary

| # | Source | Classification | Suggested artifact | Notes |
|---|---|---|---|---|
| 1 | @notes/runtime-guardrails.md | Policy surface | `.cursor/rules/10-...mdc` | Persisted project guidance |
| 2 | @examples/reviewer.md | Subagent concept | `.cursor/agents/reviewer.md` | Read-only reviewer |
```

**PAUSE — Wait for approval before scaffolding anything.**

## Phase 2 — Pack Archetype Selection

Choose the smallest pack archetype that matches the material. Start from
`references/pack-archetypes.md`.

| Archetype | Signal | Typical contents |
|---|---|---|
| Runtime Companion | Mixed runtime bundle for teams or projects | subagents, rules, hooks, MCP example, guides |
| Policy Pack | Mostly durable guidance and enforcement | rules, hooks, guide |
| Review Toolkit | Mostly focused helper agents and checklists | subagents, guides, optional MCP example |
| Hybrid | Multiple surfaces with one dominant intent | combine one primary archetype with narrowly scoped extras |

After choosing the archetype:

1. State why the pack should exist.
2. State who installs it (`project-cursor`, `user-cursor`, or both).
3. State which profiles are needed and why.
4. Identify which surfaces are intentionally excluded.

**PAUSE — Present the archetype recommendation and wait for approval.**

## Phase 3 — Define The Pack Contract

Before writing files, specify the machine-readable contract:

1. **Pack identity**
   - pack name
   - short human description
   - supported targets
   - profiles and default profile
2. **Artifact matrix**
   - one row per artifact with `id`, `source`, targets, profiles, and
     destination paths
3. **Install policy**
   - backup behavior
   - manifest path
   - MCP policy
4. **Recommendation metadata**
   - capture the structured fields from `references/recommendation-metadata.md`
   - if the repo is not ready to store them yet, record them in a draft block or
     `.work/` note for later promotion

Present the contract as:

```markdown
## Pack Contract

- Name: `my-pack`
- Targets: `project-cursor`
- Profiles: `lite`, `strict`

| Artifact ID | Surface | Source | Targets | Profiles | Destination |
|---|---|---|---|---|---|
| `agents` | subagent | `.cursor/agents` | project,user | lite,strict | `.cursor/agents` |
| `pack-overview` | bundled skill | `skills/my-pack-overview` | project,user | lite | `.cursor/skills/my-pack-overview` (derived) |
```

For bundled skills, destination paths are **derived** by the installer from
`skillId` (see `references/pack-standard.md`). Use
`assets/templates/bundled-skill-artifact.fragment.json` as a copy-paste pattern
for the `artifacts[]` entry.

**PAUSE — Wait for approval before creating files.**

## Phase 4 — Scaffold Only The Needed Files

Create `packs/<name>/` and only the subdirectories that will contain content.

Load the minimal template set from `assets/templates/`:

- `pack.json.template.json`
- `bundled-skill-artifact.fragment.json` (when adding `kind: "skill"` entries)
- `README.template.md`
- `guide.template.md`
- `CHANGELOG.template.md`
- `VERIFICATION.template.md`
- `RELEASE-POLICY.template.md`
- `ROADMAP.template.md`
- `subagent.template.md`
- `rule.template.mdc`
- `hook-script.template.sh`
- `hook-config.project.template.json`
- `hook-config.user.template.json`
- `mcp.example.template.json`

Scaffolding rules:

1. Only create files justified by the approved artifact matrix.
2. Keep `.cursor/` runtime assets installable as-is.
3. Put human-facing operational guidance in `guides/`.
4. Keep secrets out of examples; prefer `${env:VAR}` interpolation.
5. If a surface is not needed, do not create an empty directory for it.
5b. For bundled skills, create `packs/<name>/skills/<folder>/` with `SKILL.md` and
   `metadata.json`, declare `"kind": "skill"` and a pack-scoped `skillId` in
   `pack.json`, and do **not** list the skill in `skill-registry.json` unless the
   user explicitly wants a repo-global synced skill.
6. Mirror the repo's current pack style unless the user explicitly wants a new
   convention.
7. If the pack is expected to evolve across releases, scaffold committed release
   artifacts rather than leaving validation and roadmap notes only in chat or
   `.work/`.

## Phase 5 — Update The Registry

Add the matching entry to `cursor-pack-registry.json`.

Minimum required fields:

- `version`
- `author`
- `path`
- `targets`
- `profiles`
- `installPolicy`
- `tags`
- `description`

If structured recommendation metadata is available, prepare it for later schema
adoption, but do not invent live schema changes unless the user asks for them.

## Phase 6 — Verify

Run the pack quality gate:

```bash
bash "skills/create-cursor-pack-from-refs/scripts/validate-pack.sh" "<pack-name>"
```

This wrapper delegates to:

```bash
bash "scripts/cursor-pack-verify.sh" --pack="<pack-name>"
```

Then review the checklist in `references/quality-checklist.md`.

**PAUSE — Present validation output and any warnings before further changes.**

## Phase 7 — Final Review Output

Present the final result with:

1. created file tree
2. pack archetype and rationale
3. pack contract summary
4. registry entry summary
5. validation results
6. deferred metadata or MCP-catalog follow-ups recorded in `.work/`

## Confirmation Points

| Phase | Present to user | Wait for |
|---|---|---|
| After intake | Intake summary table | Classification approval |
| After archetype | Archetype + rationale | Scope approval |
| After contract | Pack contract + artifact matrix | Scaffold approval |
| After validation | Validation results + checklist | Final sign-off |

Do NOT create runtime installs, mutate live `~/.cursor/`, or implement a live
MCP recommender unless the user explicitly asks for that work.
