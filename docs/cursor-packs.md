# Cursor Pack Catalog

Browse the installable Cursor packs maintained in this repository. Packs are
private, repo-native bundles for Cursor runtime assets: agents, rules, hooks, MCP
examples, bundled skills, and supporting guides.

`cursor-pack-registry.json` remains the source of truth for pack versions,
targets, profiles, and descriptions. This document is the discovery catalog.

## Quick Start

### Essential Packs

**cursor-companion** - Cursor setup auditing and guardrails

```bash
bash scripts/cursor-pack-sync.sh --pack=cursor-companion --target=project --project-root="$PWD" --profile=lite --dry-run
```

Installs companion auditors, MCP examples, and an orientation skill. Use `strict`
when a project should also adopt hook and rule guardrails.

**cursor-skill-studio** - Skill and pack lifecycle workflow (write / audit / maintain)

```bash
bash scripts/cursor-pack-sync.sh --pack=cursor-skill-studio --target=project --project-root="$PWD" --profile=lite --dry-run
```

Installs helper and audit agents plus three explicit-only bundled skills:
`/skill-studio-write` (authoring), `/skill-studio-audit` (compliance and
overlap audits), and `/skill-studio-maintain` (releases, registry alignment,
install verification). Renamed from `cursor-skill-creator` in 0.3.0 and
consolidated under ADR-0005.

**node-test-verifier** - Low-noise Node/Jest verification

```bash
bash scripts/cursor-pack-sync.sh --pack=node-test-verifier --target=project --project-root="$PWD" --profile=lite --dry-run
```

Installs verifier agents for tier-aware test execution, prerequisite checks, and
compact pass/fail evidence.

### Operations Packs

**gcp-log-investigation** - Google Cloud log investigation

```bash
bash scripts/cursor-pack-sync.sh --pack=gcp-log-investigation --target=project --project-root="$PWD" --profile=lite --dry-run
```

Installs a production-safe log-reader agent for bounded Cloud Run, Cloud
Functions, and GKE log investigations.

**agentic-artifact-discovery** - Agentic system exploration

```bash
bash scripts/cursor-pack-sync.sh --pack=agentic-artifact-discovery --target=project --project-root="$PWD" --profile=lite --dry-run
```

Installs a lightweight exploration agent and workflow skill for understanding
skill systems, workflow frameworks, subagent bundles, and plugin-like artifacts.

## Complete Pack Catalog

### Authoring and Governance

| Pack | Version | Profiles | Includes | Description |
| --- | --- | --- | --- | --- |
| [`cursor-companion`](../packs/cursor-companion) | 0.1.3 | lite, strict | agents, rules, hooks, MCP example, bundled skill | Cursor runtime bundle with companion subagents, project rules, hook guardrails, MCP templates, operational guides, and an orientation skill. |
| [`cursor-skill-studio`](../packs/cursor-skill-studio) | 1.0.0 | lite, strict | agents, rules, three bundled skills | Consolidated skill-lifecycle pack covering authoring (`/skill-studio-write`), audit and improvement (`/skill-studio-audit`), and release/governance (`/skill-studio-maintain`). Renamed from `cursor-skill-creator` in 0.3.0 per ADR-0005. |
### Engineering Workflows

| Pack | Version | Profiles | Includes | Description |
| --- | --- | --- | --- | --- |
| [`engineering-workflows`](../packs/engineering-workflows) | 0.1.0 | lite, strict | MCP example, bundled skills | Bundled engineering workflow skills for code review, debugging, architecture, incident response, deploy readiness, documentation, standups, technical debt, and testing strategy. |
| [`node-test-verifier`](../packs/node-test-verifier) | 0.2.0 | lite, strict | agents, rules | Reusable Node and Jest verifier pack for low-noise, pass-fail-first verification with explicit evidence and optional coverage. |

### Operations and Discovery

| Pack | Version | Profiles | Includes | Description |
| --- | --- | --- | --- | --- |
| [`agentic-artifact-discovery`](../packs/agentic-artifact-discovery) | 0.1.0 | lite | agent, bundled skill | Discovery workflow and exploration agent for understanding skill systems, workflow frameworks, subagent bundles, and Claude-style plugins. |
| [`gcp-log-investigation`](../packs/gcp-log-investigation) | 0.1.0 | lite, strict | agent, rules | Portable GCP log-investigation pack with a reusable log-reader agent and production-safe guidance for Cloud Run, Cloud Functions, and GKE logs. |

## Pack Contents

| Surface | Pack role | Catalog |
| --- | --- | --- |
| Agents | Bounded specialist workers installed into `.cursor/agents/` or `~/.cursor/agents/`. | [Agent Reference](./agents.md) |
| Bundled skills | Pack-scoped workflow or orientation skills installed alongside runtime assets. | [Agent Skills Catalog](./agent-skills.md) |
| Rules | Persistent project guidance, usually installed only through strict project profiles. | Pack README and `pack.json` |
| Hooks | Runtime enforcement or auditing, used only where a pack needs active guardrails. | Pack README and hook files |
| MCP examples | Template connector configuration that must not be promoted to live `mcp.json` automatically. | Pack README and `.cursor/mcp.example.json` |
| Guides and assets | Human-facing usage docs and support material for the pack. | Pack directory |

## Installation

### Preview First

Use dry runs before installing a pack:

```bash
bash scripts/cursor-pack-sync.sh \
  --pack=cursor-companion \
  --target=project \
  --project-root="$PWD" \
  --profile=strict \
  --dry-run
```

### Install To A Project

```bash
bash scripts/cursor-pack-sync.sh \
  --pack=cursor-companion \
  --target=project \
  --project-root="$PWD" \
  --profile=strict
```

Project installs write into the target repository's `.cursor/` tree.

### Install For The User

```bash
bash scripts/cursor-pack-sync.sh \
  --pack=cursor-companion \
  --target=user \
  --profile=lite
```

User installs write into `~/.cursor/`. Project-only rules are not installed at
user level.

## Profiles and Targets

| Concept | Values | Meaning |
| --- | --- | --- |
| CLI target | `project`, `user` | User-facing install target names for `cursor-pack-sync.sh`. |
| Manifest target | `project-cursor`, `user-cursor` | Pack and registry target names. |
| Profile | `lite` | Minimal install with lower policy surface. |
| Profile | `strict` | Fuller install, usually adding project-only rules, hooks, or stricter guidance. |

Use `lite` for first installs and user-level installs. Use `strict` when a
project should adopt the pack's full operating model.

## Pack Structure

```text
packs/<pack>/
+-- pack.json
+-- README.md
+-- CHANGELOG.md
+-- VERIFICATION.md
+-- RELEASE-POLICY.md
+-- ROADMAP.md
+-- .cursor/
|   +-- agents/
|   +-- rules/
|   +-- hooks/
|   +-- mcp.example.json
+-- skills/
+-- guides/
+-- assets/
```

Not every pack has every surface. The manifest controls what is installable for
each target and profile.

## Design Principles

### Focused Bundles

Each pack should provide one coherent operating model, not a mixed collection of
unrelated Cursor customizations.

### Install Only What You Need

Profiles keep the default install small. Project-only policy stays project-only;
user installs focus on reusable capabilities.

### Runtime Safety

Hooks should be narrow and inspectable. MCP files are examples unless a human
deliberately promotes them to live configuration.

### Progressive Disclosure

Packs may include bundled skills for workflow entrypoints, but detailed runtime
behavior stays in agents, rules, hooks, guides, and scripts.

## Maintenance

Before releasing pack changes:

```bash
bash scripts/cursor-pack-verify.sh --pack=cursor-companion
```

For versioned pack releases, update:

- `pack.json`
- `cursor-pack-registry.json`
- `CHANGELOG.md`
- `VERIFICATION.md`
- `ROADMAP.md`

Use `scripts/cursor-pack-version.sh` for version bumps, then verify and dry-run
the affected install targets and profiles.

## See Also

- [Agent Reference](./agents.md)
- [Agent Skills Catalog](./agent-skills.md)
- [Architecture](./architecture.md)
- [Cursor Pack Specification](./specs/cursor-pack-specification.md)
- [Pack Authoring Checklist](./specs/pack-authoring-checklist.md)
- [Archived Cursor Packs Guide](./archive/cursor-packs-guide.md)
