# Cursor Agent Tools Reference

This document distinguishes two related but different things:

- the tools available to the agent in this workspace and chat session
- the broader Cursor surfaces you can use to shape agent behavior, integrations, and workflows

The first category is environment-specific. Another session, repository, or product surface may expose a different tool set.

For example, Cursor's public docs describe browser automation as an Agent capability, but this specific session should be documented by the tools actually exposed here rather than by every capability Cursor may support elsewhere.

## Tools Available To The Agent Here

### Search and reading

- `ReadFile`: read text files, PDFs, and supported images directly.
- `Glob`: find files by path pattern.
- `rg`: search file contents with ripgrep-style queries.
- `SemanticSearch`: find code by meaning instead of exact text.
- `ReadLints`: inspect current IDE diagnostics for changed files or paths.

Use these first when the task is exploratory or when I need evidence before editing.

### Editing and file changes

- `ApplyPatch`: make targeted edits to a single file.
- `Delete`: remove a file.
- `EditNotebook`: edit Jupyter notebook cells safely.

These are the main local write surfaces. In this workspace, narrow and reviewable edits are preferred over broad rewrites.

### Shell and command execution

- `Shell`: run terminal commands.
- `AwaitShell`: wait for or check background shell jobs.

These are useful for verification, git inspection, builds, tests, package-manager commands, and other command-line workflows. Shell usage is still constrained by repository rules and safety guidance.

### Planning and interaction

- `AskQuestion`: collect structured choices from the user.
- `TodoWrite`: track task progress.
- `SwitchMode`: move between plan and agent workflows when appropriate.
- `CreatePlan`: create a reviewable implementation plan before execution.

These tools shape how work is coordinated, clarified, and tracked rather than changing project files directly.

### Web and external research

- `WebSearch`: search the public web for current information.
- `WebFetch`: fetch and read a web page as markdown.
- `GenerateImage`: create an image when the user explicitly asks for one.

These are useful when the repository is not the source of truth, especially for current product documentation, API references, or external guidance.

### Delegation and parallel work

- `Subagent`: launch a specialized agent for exploration, shell work, review, verification, and other focused tasks.
- `multi_tool_use.parallel`: run multiple independent tool calls in parallel.

These help when work is noisy, parallelizable, or would otherwise consume too much context in the main conversation.

### MCP and external integrations

- `CallMcpTool`: call a tool exposed by a configured MCP server.
- `FetchMcpResource`: read a resource exposed by a configured MCP server.

In this workspace, MCP access is available but server availability is configuration-dependent. The current workspace configuration exposes at least the `user-sonarqube` server, so agent access to external systems is not just theoretical here.

## Cursor Surfaces And Where They Fit

The Cursor docs describe several persistent or configurable surfaces around Agent. These are not the same thing as the tool calls above, but they interact closely with them.

### Agent tools

Docs: [Agent tools overview](https://cursor.com/docs/agent/tools)

Cursor Agent uses tools to search code, read and edit files, run shell commands, search the web, use browser automation, generate images, and ask clarifying questions. This is the closest public-doc counterpart to the runtime tools listed earlier.

Use this layer when you want the agent to do work now in the current conversation.

### Rules

Docs: [Rules](https://www.cursor.com/docs/context/rules)

Rules are persistent instructions for the agent. Cursor supports:

- project rules in `.cursor/rules/`
- user rules
- team rules
- `AGENTS.md` as a simpler markdown instruction surface

Use rules when the guidance should keep applying across many conversations. Rules are the right surface for repository conventions, path-scoped standards, and long-lived operating constraints.

### Skills

Docs: [Agent Skills](https://cursor.com/docs/context/skills)

Skills are portable workflow packages built around `SKILL.md`, with optional `scripts/`, `references/`, and `assets/`. They are good for reusable task-specific procedures, domain knowledge, and on-demand guidance.

Use skills when the main value is teaching the agent how to perform a repeatable workflow, not enforcing a policy at runtime.

### Subagents

Docs: [Subagents](https://cursor.com/docs/agent/subagents)

Subagents are specialized assistants with their own context windows. Cursor uses them for noisy or context-heavy work and also supports custom subagents in `.cursor/agents/`.

Use subagents when you want:

- context isolation
- parallel workstreams
- specialist prompts
- independent review or verification

### Hooks

Docs: [Hooks](https://cursor.com/docs/agent/hooks)

Hooks are event-driven scripts or prompt checks that run before or after agent actions. They can observe, block, audit, or modify behavior around file reads, edits, shell commands, MCP calls, subagent lifecycle, and prompt submission.

Use hooks when the behavior must be enforced or audited at runtime. If something is truly non-negotiable, hooks are a stronger surface than a skill alone.

### MCP

Docs: [Model Context Protocol (MCP)](https://www.cursor.com/docs/context/mcp)

MCP connects Cursor to external tools and data sources. Cursor supports tools, prompts, resources, roots, elicitation, and MCP Apps, with local `stdio` and remote transports.

Use MCP when the agent needs structured access to systems outside the repo, such as issue trackers, observability platforms, design tools, or internal services.

### Plugins and packs

Related docs:

- [Cursor Marketplace](https://www.cursor.com/marketplace)
- [Cursor Packs guide](./cursor-packs.md)

Plugins and packs are delivery mechanisms, not just instruction surfaces.

- Cursor plugins are the official distribution surface for packaged Cursor functionality.
- Cursor packs in this repository are repo-native bundles for local or private installation.

Use these when you want to distribute a coherent runtime setup, not just write guidance.

## Quick Routing: Which Surface Should You Use?

- If you want the agent to search, read, edit, or run commands right now, use agent tools.
- If you want persistent guidance to apply across future work in a repo, use rules or `AGENTS.md`.
- If you want a reusable workflow or specialized domain guidance, use a skill.
- If you want isolated specialist work or parallel execution, use a subagent.
- If you want runtime enforcement, approvals, or auditing around actions, use hooks.
- If you want the agent to access external systems or structured remote data, use MCP.
- If you want to package and install a whole Cursor operating setup, use a plugin or a pack.

## Repository-Specific Follow-Ups

This repository maintains several Cursor-adjacent artifacts directly, so these documents are the best next references if you are working inside this repo:

- [Cursor Packs guide](./cursor-packs.md)
- [Cursor Pack specification](./specs/cursor-pack-specification.md)
- [Agentic skill and pack authoring](./specs/agentic-skill-pack-authoring.md)

The repository's local guidance also consistently frames the surface choice like this:

- skills for knowledge and routing
- rules and `AGENTS.md` for persistent guidance
- subagents for context isolation
- hooks for enforcement
- MCP for external capabilities

## Source Notes

The Cursor-platform sections above are based primarily on current public docs:

- [Agent tools overview](https://cursor.com/docs/agent/tools)
- [Rules](https://www.cursor.com/docs/context/rules)
- [Agent Skills](https://cursor.com/docs/context/skills)
- [Subagents](https://cursor.com/docs/agent/subagents)
- [Hooks](https://cursor.com/docs/agent/hooks)
- [Model Context Protocol (MCP)](https://www.cursor.com/docs/context/mcp)

Treat the runtime tool inventory in this document as a snapshot of this agent environment, not a universal Cursor contract.
