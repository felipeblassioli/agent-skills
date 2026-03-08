# Cursor Pack Archetypes

Use this reference to choose the smallest viable pack shape before scaffolding.

## 1. Runtime Companion

**Best fit:** a broad but coherent operational bundle that helps teams adopt a
safer or more consistent Cursor setup.

### Typical contents

- `.cursor/agents/`
- `.cursor/rules/`
- `.cursor/hooks*.json`
- `.cursor/hooks/`
- `.cursor/mcp.example.json`
- `guides/*.md`

### Signals

- the pack bundles multiple Cursor surfaces on purpose
- profiles matter because some teams want lighter installs
- there is a clear install story for `project-cursor`, `user-cursor`, or both

### Example use case

- "Ship a companion pack that adds review subagents, safe hooks, and an MCP
  example without installing live credentials."

## 2. Policy Pack

**Best fit:** persistent guidance and enforcement with little or no helper-agent
surface area.

### Typical contents

- `.cursor/rules/`
- `.cursor/hooks*.json`
- `.cursor/hooks/`
- `guides/*.md`

### Signals

- the main value is non-negotiable guard-rails
- the runtime behavior should be consistent across many conversations
- subagents are optional or absent

### Example use case

- "Package the project's shell safety, sensitive-read protections, and MCP
  hygiene defaults."

## 3. Review Toolkit

**Best fit:** focused helper agents plus guidance, with minimal enforcement.

### Typical contents

- `.cursor/agents/`
- `guides/*.md`
- optional `.cursor/mcp.example.json`

### Signals

- the core value is reusable helper agents for auditing, review, or analysis
- hooks would be too heavy-handed
- rules are optional and narrow

### Example use case

- "Bundle specialized project reviewers and the guide that explains when to use
  each reviewer."

## 4. Hybrid

**Best fit:** there is one dominant archetype, but a narrow secondary surface is
required for the pack to be usable.

### Signals

- one surface clearly carries the pack's value
- one or two extra surfaces support that value without redefining the pack
- omitting the secondary surface would make adoption meaningfully worse

### Guard-rail

Do not use "Hybrid" as an excuse to dump every possible Cursor surface into one
pack. If the pack has multiple unrelated goals, split it instead.

## Selection checklist

Choose the archetype that satisfies all of the following:

- the pack's why can be stated in one sentence
- the pack's profiles are easy to explain
- each included surface has a clear job
- at least one common surface is intentionally excluded

## Archetype-to-template mapping

| Need | Start with |
|---|---|
| Balanced runtime bundle | `assets/templates/pack.json.template.json` + all approved surface templates |
| Mostly rules/hooks | rules, hook configs, hook scripts, guide |
| Mostly helper agents | subagent, guide, optional MCP example |
| Mixed but coherent | dominant archetype plus only the extra approved templates |

## Surface exclusion heuristics

| Surface | Exclude when |
|---|---|
| Rules | guidance does not need to persist across conversations |
| Hooks | enforcement is not worth the operational cost |
| MCP example | the pack does not interact with external systems |
| Subagents | the pack's value is policy, not specialized helper flows |
| Guides | the runtime files are obvious and require no operational context |
