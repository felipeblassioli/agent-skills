# Security And Guard-Rails

This pack separates soft guidance from hard constraints.

## Soft guidance

Soft guidance should live in:

- skills
- rules
- subagent prompts

These layers teach the agent what to do, but they do not reliably enforce it.

## Hard constraints

Hard constraints should live in:

- hooks that block or audit runtime actions
- MCP approval policies
- secret handling conventions based on environment interpolation

## Pack policies

- `mcp.example.json` is a template, not live configuration
- sensitive file reads are blocked by hook
- obviously destructive shell commands are blocked by hook
- user installs do not pretend to install filesystem user rules that Cursor does not support

## Review checklist

Before enabling the strict profile:

1. Confirm the hook commands point to valid local scripts.
2. Confirm hook failures should be fail-open or fail-closed.
3. Confirm MCP servers are trusted and narrowly scoped.
4. Confirm secrets come from `${env:...}` placeholders.
5. Confirm denied actions show a useful user message.
