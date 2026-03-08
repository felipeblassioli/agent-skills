# AGENTS.md

Guidance for AI coding agents (Cursor, Claude Code, Copilot, Codex) working in this repository.

## Repository Overview

Central registry for versioned Agent Skills and installable Cursor packs.
Skills are authored here and deployed to global (`~/.cursor/skills/`,
`~/.agents/skills/`) or project-local (`.cursor/skills/`) paths via
`scripts/skill-sync.sh`. Cursor runtime bundles such as subagents, hooks,
project rules, and MCP templates are authored under `packs/` and installed via
`scripts/cursor-pack-sync.sh`.

## Structure

```
agent-skills/
├── skills/                       # All skill sources
│   ├── <name>/
│   │   ├── SKILL.md              # Required — agent instructions
│   │   ├── metadata.json         # Required — version, author, date, abstract
│   │   ├── README.md             # Optional — human docs (excluded from deploy)
│   │   ├── AGENTS.md             # Optional — compiled rules output
│   │   ├── references/           # Optional — on-demand reference docs
│   │   ├── assets/               # Optional — templates, checklists, quickref
│   │   ├── scripts/              # Optional — executable automation
│   │   └── rules/                # Optional — rule files (compiled → AGENTS.md)
│   └── claude.ai/                # Skills targeting claude.ai only
│       └── vercel-deploy-claimable/
├── packs/
│   └── <name>/
│       ├── pack.json             # Required — pack metadata and install map
│       ├── README.md             # Recommended — human docs
│       ├── CHANGELOG.md          # Expected for evolving packs — release history
│       ├── VERIFICATION.md       # Expected for evolving packs — release evidence
│       ├── RELEASE-POLICY.md     # Expected for evolving packs — release rules
│       ├── ROADMAP.md            # Expected for evolving packs — next steps
│       ├── .cursor/              # Runtime assets to install
│       ├── guides/               # Optional — user-facing guidance
│       └── assets/               # Optional — templates and examples
├── skill-registry.json           # Central manifest (versions, targets, tags)
├── cursor-pack-registry.json     # Central manifest for installable Cursor packs
├── scripts/
│   ├── skill-sync.sh             # Deploy skills to target paths
│   ├── skill-version.sh          # Bump version (registry + metadata + SKILL.md)
│   └── skill-import.sh           # Import skill from external project
│   ├── cursor-pack-verify.sh     # Validate pack structure and safety checks
│   ├── cursor-pack-sync.sh       # Stage + install packs with backups
│   ├── cursor-pack-restore.sh    # Restore files from a pack backup
│   └── cursor-pack-version.sh    # Bump pack version (registry + pack.json)
├── packages/
│   └── react-best-practices-build/  # Build tooling for rules-based skills
├── .cursor/
│   ├── rules/                    # Cursor rules for this repo
│   └── skills/skill-registry/    # Meta-skill for registry management
└── README.md
```

## Skill Archetypes

### Rules-based skills
Skills with a `rules/` directory containing individual rule files that compile
into `AGENTS.md`. Used by: `react-best-practices`, `composition-patterns`,
`react-native-skills`, `go-package-documentation`.

Build with: `pnpm build` in `packages/react-best-practices-build/`.

### Standard skills
Direct `SKILL.md` + supporting `references/`, `assets/`, `scripts/`. Edited in
place. Used by all other skills.

## Registry Workflow

### Import a skill from another project
```bash
bash scripts/skill-import.sh <project-path> <skill-name> --tags=tag1,tag2
```

### Deploy skills to target paths
```bash
bash scripts/skill-sync.sh              # Deploy all
bash scripts/skill-sync.sh --dry-run    # Preview
bash scripts/skill-sync.sh --skill=NAME # Single skill
bash scripts/skill-sync.sh --list       # Show versions and drift
```

### Bump a skill version
```bash
bash scripts/skill-version.sh <skill-name> patch|minor|major
```

## Cursor Pack Workflow

### Verify a pack
```bash
bash scripts/cursor-pack-verify.sh --pack=cursor-companion
```

### Install a pack
```bash
bash scripts/cursor-pack-sync.sh --pack=cursor-companion --target=project --project-root="$PWD" --profile=strict
bash scripts/cursor-pack-sync.sh --pack=cursor-companion --target=user --profile=lite
```

### Restore from backup
```bash
bash scripts/cursor-pack-restore.sh --backup-dir .work/cursor-pack-backups/<pack>/<target>/<timestamp>
```

### Bump a pack version
```bash
bash scripts/cursor-pack-version.sh cursor-companion patch|minor|major
```

After a pack bump, also update the pack's release artifacts:

- `CHANGELOG.md`
- `VERIFICATION.md`
- `ROADMAP.md`

## Commit Conventions

Conventional Commits with skill name as scope:

```
feat(<skill-name>): <description>
fix(<skill-name>): <description>
docs(<skill-name>): <description>
chore(registry): <description>
```

Separate skill content, registry/scripts, and build changes into distinct commits.

## Pull Requests

All PR content in **English**. PRs target `felipeblassioli/agent-skills` (never upstream).

Use the template at `.github/pull_request_template.md`. Key expectations:

- **Focused scope** — separate skill content from registry/script from build changes.
- **Motivation section** — explain *why* before the reviewer reads the diff.
- **Quality checklist** — tick all items; run `validate-skill.sh` for skill PRs.
- **Validation section** — include actual commands and output.

Branch naming: `<type>/<skill-name>-<short-description>`
PR title: Conventional Commits format (`type(scope): description`)

See `.cursor/rules/30-pr-workflow.mdc` for the full workflow.

## Required Files per Skill

| File | Required | Notes |
|------|----------|-------|
| `SKILL.md` | Yes | Frontmatter: `name` (matches dir), `description` (WHAT + WHEN) |
| `metadata.json` | Yes | `version`, `author`, `date`, `abstract` |
| Entry in `skill-registry.json` | Yes | Version, scope, targets, tags |

## Installation

Skills are deployed via `skill-sync.sh` to these discovery paths:

| Target | Path | Scope |
|--------|------|-------|
| `cursor` | `~/.cursor/skills/<name>/` | Cursor IDE (global) |
| `agents` | `~/.agents/skills/<name>/` | Claude Code / generic agents |
| `claude` | `~/.claude/skills/<name>/` | Claude.ai projects |

Cursor packs install runtime assets differently by target:

| Target | Destination | Notes |
|--------|-------------|-------|
| `project-cursor` | `<project>/.cursor/` | Supports subagents, project rules, hooks, and MCP examples |
| `user-cursor` | `~/.cursor/` | Supports subagents, hooks, and MCP examples; project rules stay project-only |

## Pack Release Artifacts

Maintained packs should commit these root-level files:

- `CHANGELOG.md` — what changed per release
- `VERIFICATION.md` — how the release was tested and what it proved
- `RELEASE-POLICY.md` — release and verification expectations
- `ROADMAP.md` — next improvements and known follow-up work
