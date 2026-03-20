---
name: cursor-companion-pack-overview
description: Summarizes the cursor-companion Cursor pack and how its runtime assets relate to repo-root skills. Use after installing cursor-companion or when deciding whether to use pack subagents, rules, hooks, or a separate skill from skill-registry.json.
---

# Cursor companion pack (overview)

This skill ships **with** the `cursor-companion` pack as a **bundled skill**. It is
installed into Cursor skill discovery paths by `scripts/cursor-pack-sync.sh`; it is
**not** automatically an entry in `skill-registry.json` unless someone promotes it.

## What the pack installs (runtime)

- Subagents under `.cursor/agents/` (project) or `~/.cursor/agents/` (user)
- Optional project rules, hooks, and MCP **examples** per pack profile

See the pack README and `packs/cursor-companion/guides/` for full detail.

## When to use this skill vs other skills

- Use this skill for **orientation**: what the companion pack is and where things
  landed after install.
- Use **repo-root skills** from `skills/` (via `skill-sync.sh` and
  `skill-registry.json`) for portable task workflows that are not tied to this
  pack's install layout.

## Related docs

- Pack human docs: `packs/cursor-companion/README.md` (in this repository)
- Repository spec: `docs/specs/agentic-skill-pack-authoring.md` (pack-bundled skills)
