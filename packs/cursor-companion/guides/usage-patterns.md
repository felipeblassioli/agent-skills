# Usage Patterns

This pack is opinionated about where different kinds of guidance should live.

## Decision model

- use a `skill` when the agent needs reusable knowledge or routing logic
- use a `rule` when guidance should persist across many conversations in one project
- use a `subagent` when the work is noisy, parallel, or context-heavy
- use a `hook` when behavior must be enforced or audited at runtime
- use `MCP` when the agent must access external systems or structured data

## Good fits for the pack

- add guard-rails for dangerous shell commands
- protect sensitive files from being read into model context
- audit whether a project's Cursor setup is coherent
- review MCP configs before enabling live external tooling

## Poor fits for the pack

- encoding general coding style that already belongs in a linter
- creating a large catalog of vague subagents
- using hooks to enforce broad writing preferences
- auto-writing secrets into MCP config

## Recommended workflow

1. Verify the pack.
2. Install `lite` or `strict` based on the target.
3. Review generated or copied runtime files.
4. Customize rules, hooks, or subagent descriptions for the project.
5. Re-run verification after edits.
