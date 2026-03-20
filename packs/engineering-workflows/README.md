---
name: engineering-workflows
version: "0.1.0"
description: Portable engineering workflow pack with bundled skills for standups, code review, debugging, architecture, incident response, documentation, deploy readiness, technical debt, and testing strategy.
---

# Engineering Workflows

`engineering-workflows` adapts Anthropic's engineering plugin shape into a
Cursor-native pack with bundled workflow skills and example-only MCP
configuration.

The pack keeps the original intent while translating it into this repository's
preferred surfaces:

- workflow guidance becomes bundled installed skills
- connector setup becomes example-only MCP configuration
- install and connector notes become human-facing guides

## Profiles

- `lite`: installs the bundled engineering workflow skills plus example MCP
  configuration
- `strict`: currently installs the same assets and reserves room for future
  project-only guardrails

## Target support

- `project-cursor`: installs into a repository's `.cursor/` directory
- `user-cursor`: installs into `~/.cursor/`

## Included assets

- bundled skill: `engineering-architecture`
- bundled skill: `engineering-code-review`
- bundled skill: `engineering-debug`
- bundled skill: `engineering-deploy-checklist`
- bundled skill: `engineering-documentation`
- bundled skill: `engineering-incident-response`
- bundled skill: `engineering-standup`
- bundled skill: `engineering-system-design`
- bundled skill: `engineering-tech-debt`
- bundled skill: `engineering-testing-strategy`
- example connector config: `.cursor/mcp.example.json`

## Design choices

- Pack-bundled skills are used instead of repo-root skills so the engineering
  workflows install as one unit.
- MCP stays example-only and does not overwrite live `mcp.json`.
- Claude-only local settings and slash-command UX are adapted into normal skill
  routing rather than copied verbatim.

## Guides

- [guides/installation.md](guides/installation.md)
- [guides/connectors.md](guides/connectors.md)
- [guides/adaptation-notes.md](guides/adaptation-notes.md)

## Release Artifacts

- [CHANGELOG.md](CHANGELOG.md)
- [VERIFICATION.md](VERIFICATION.md)
- [RELEASE-POLICY.md](RELEASE-POLICY.md)
- [ROADMAP.md](ROADMAP.md)
