# Material Intake

How to classify user-provided reference material (docs, code, examples, URLs)
and where it should land in the resulting skill or pack.

Merged from the Phase 1 intake tables of `create-skill-from-refs` and
`create-cursor-pack-from-refs`.

## Procedure

1. Read each source fully.
2. Classify it using the table that matches the destination (skill or pack).
3. **Distill** — extract high-signal content. Strip boilerplate, redundancy,
   and anything the agent already knows.
4. Note cross-references between sources.
5. Present the intake summary in the table format below and **pause** until
   the user approves the classification.

## Classification for a new skill (`skills/<name>/` or bundled)

| Material type | Classification | Destination |
|---|---|---|
| Domain knowledge, specs, methodology | Core knowledge | `references/` |
| Lookup tables, matrices, glossaries | Quick reference | `assets/quickref/` |
| Decision procedures, flowcharts | Decision tree | `assets/decision-trees/` |
| Output format examples, templates | Templates | `assets/templates/` |
| Checklists, review guides | Checklists | `assets/checklists/` |
| Executable automation, validators | Scripts | `scripts/` |
| Code examples (illustration only) | Inline | Embed in the relevant `references/*.md` |

## Classification for a new pack (`packs/<name>/`)

| Material type | Classification | Destination |
|---|---|---|
| Architecture notes, operating model, product intent | Pack concept | `README.md`, guides, metadata choices |
| Existing `.cursor/` files, examples, snippets | Runtime artifact reference | Matching `.cursor/...` path in pack |
| Guard-rails, policies, safety rules | Policy surface | `.cursor/rules/`, hooks, guides |
| Workflow descriptions for reviewers/helpers | Subagent concept | `.cursor/agents/*.md` |
| Reusable task guidance tied to the pack install | Bundled skill | `packs/<name>/skills/<folder>/` + `kind: "skill"` row in `pack.json` |
| Example MCP config, server docs | MCP example | `.cursor/mcp.example.json`, guides |
| Install or usage instructions | Operational guide | `guides/*.md` |
| Checklists or validation expectations | Quality gate | `references/quality-checklist.md` or `scripts/validate-pack.sh` |
| Release notes, test evidence, evolution plans | Release artifact | `CHANGELOG.md`, `VERIFICATION.md`, `RELEASE-POLICY.md`, `ROADMAP.md` |

## Intake summary template

Present the result to the user in this shape and wait for confirmation before
scaffolding anything:

```markdown
## Intake Summary

| # | Source | Classification | Destination | Notes |
|---|--------|---------------|-------------|-------|
| 1 | @requirements.md | Core knowledge | references/auth-flow.md | Auth flow spec |
| 2 | @scripts/deploy.sh | Script | scripts/deploy.sh | Deploy pipeline |
```

## Skill vs pack destination

If the material spans both surfaces, decide using these signals:

- **Skill** when the value is reusable task guidance that other skills/agents
  can consume independently. Default to a root skill under `skills/<name>/`.
- **Pack** when the value is a runtime bundle (subagents, rules, hooks, MCP
  examples) that should install together. Pack-bundled skills live alongside
  these runtime assets and travel with the pack release.
- **Both** when the material splits cleanly: ship a pack for the runtime, and
  a separate root skill for the reusable guidance. Reference each other.

See `references/source-decomposition.md` for the full decomposition heuristic
when the source is a mixed plugin tree or external folder.
