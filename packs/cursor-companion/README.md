---
name: cursor-companion
version: "0.1.2"
description: Cursor runtime bundle with companion subagents, project rules, hook guard-rails, MCP templates, and operational guides.
---

# Cursor Companion

`cursor-companion` is a first-class Cursor pack for projects and personal environments.

It packages the runtime pieces that do not belong inside `skills/`:

- focused subagents in `.cursor/agents/`
- project rules in `.cursor/rules/`
- hook guard-rails in `.cursor/hooks*.json` and `.cursor/hooks/`
- MCP configuration examples in `.cursor/mcp.example.json`
- usage guides and authoring templates for teams adopting the pack

It does not treat repo-specific nested `AGENTS.md` files as pack-managed runtime
assets. Instead, the pack teaches that pattern through guides and templates while
leaving the actual repository-local `AGENTS.md` files to the project.

## Profiles

- `lite`: install reusable subagents and MCP examples without active hooks
- `strict`: install the full bundle, including hooks and project rules where Cursor supports them

## Target support

- `project-cursor`: installs into a repository's `.cursor/` directory
- `user-cursor`: installs into `~/.cursor/`

Project installs include `.cursor/rules/`.
User installs skip rules because Cursor user rules are managed in settings rather than a `~/.cursor/rules/` directory.

## Included subagents

- `cursor-pack-auditor`
- `hook-policy-reviewer`
- `mcp-config-reviewer`

## Guides

- [guides/installation.md](guides/installation.md)
- [guides/verify-and-use.md](guides/verify-and-use.md)
- [guides/usage-patterns.md](guides/usage-patterns.md)
- [guides/nested-agents-strategy.md](guides/nested-agents-strategy.md)
- [guides/security-and-guardrails.md](guides/security-and-guardrails.md)
- [guides/authoring-companion-subagents.md](guides/authoring-companion-subagents.md)

## Release Artifacts

- [CHANGELOG.md](CHANGELOG.md)
- [VERIFICATION.md](VERIFICATION.md)
- [RELEASE-POLICY.md](RELEASE-POLICY.md)
- [ROADMAP.md](ROADMAP.md)
