# Material Intake

How to classify user-provided reference material (docs, code, examples, URLs, a
tool's `--help`) and where it should land in the resulting skill or plugin.

## Procedure

1. Read each source fully.
2. Classify it using the table that matches the destination (skill or plugin).
3. **Distill** — extract high-signal content. Strip boilerplate, redundancy,
   and anything the agent already knows.
4. Note cross-references between sources.
5. Present the intake summary in the table format below and **pause** until
   the user approves the classification.

## Classification for a new skill

| Material type | Classification | Destination |
|---|---|---|
| Domain knowledge, specs, methodology | Core knowledge | `references/` |
| Lookup tables, matrices, glossaries | Quick reference | `assets/` (quickref) |
| Decision procedures, flowcharts | Decision tree | `assets/` (decision tree) |
| Output format examples, templates | Templates | `assets/templates/` |
| Checklists, review guides | Checklists | `assets/` (checklist) |
| Executable automation, validators | Scripts | `scripts/` (invoked via `${CLAUDE_SKILL_DIR}/...`) |
| Code examples (illustration only) | Inline | Embed in the relevant `references/*.md` |
| Version/date/abstract/provenance | Governance | `metadata.json` (NOT `SKILL.md` frontmatter) |

## Classification for a new plugin (a bundle)

Reach for a plugin only when several surfaces must ship together. Then classify
each source by the surface it feeds:

| Material type | Classification | Destination |
|---|---|---|
| Reusable task guidance / knowledge | Skill | `plugins/<plugin>/skills/<skill>/` |
| A specialized read-only or execution role, longer investigation | Subagent | `plugins/<plugin>/agents/<name>.md` |
| A prompt macro or one-shot interaction with arguments | Command | `plugins/<plugin>/commands/<name>.md` |
| Observe / block / modify behavior at a tool lifecycle event | Hook | `plugins/<plugin>/hooks/` + `hooks/hooks.json` |
| Example MCP config, server docs | MCP example | example config with `${env:VAR}` placeholders — never a live server file |
| Plugin identity (name, version, author) | Manifest | `plugins/<plugin>/.claude-plugin/plugin.json` |
| Catalog entry for the plugin | Marketplace | `.claude-plugin/marketplace.json` (repo-only) |
| Human docs, usage examples | Human docs | `README.md` |
| Release history | Release artifact | `CHANGELOG.md` |

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

## Skill vs plugin destination

If the material spans both surfaces, decide using these signals:

- **Single skill** when the value is one reusable workflow or knowledge base
  that other skills/agents can consume independently. This is the default.
- **Plugin** when the value is several surfaces that should install and version
  as a unit — for example a skill plus a helper subagent plus a slash command.
- **Both** when the material splits cleanly: ship a standalone skill for the
  reusable guidance and reference any sibling surface **by name**.

See `references/source-decomposition.md` for the full decomposition heuristic
when the source is a mixed plugin tree or an external folder.
