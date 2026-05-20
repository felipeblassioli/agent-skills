# Installation

## Supported targets

- `project-cursor`
- `user-cursor`

## Recommended commands

Project install:

```bash
bash scripts/cursor-pack-sync.sh --pack=cursor-skill-studio --target=project --project-root="$PWD" --profile=lite
```

User install:

```bash
bash scripts/cursor-pack-sync.sh --pack=cursor-skill-studio --target=user --profile=lite
```

Strict project install:

```bash
bash scripts/cursor-pack-sync.sh --pack=cursor-skill-studio --target=project --project-root="$PWD" --profile=strict
```

## What gets installed

- `.cursor/agents/` or `~/.cursor/agents/`
- `.cursor/skills/skill-studio-write/`,
  `.cursor/skills/skill-studio-audit/`, and
  `.cursor/skills/skill-studio-maintain/`
  (or the `~/.cursor/skills/...` equivalents on a user install)
- `.cursor/rules/` only for strict project installs

## First use

After installation, invoke the bundled skills explicitly:

- `/skill-studio-write` — author a new skill, distill from reference
  material, scaffold a pack, intake an external skill, adapt a
  Claude-style source tree, or run the eval/comparison loop.
- `/skill-studio-audit` — audit a single skill for compliance, request
  improvement recommendations, run an installed-portfolio audit, or
  perform a deep repo-first-party overlap audit.
- `/skill-studio-maintain` — release a root skill or pack, align
  registries, edit bundled-skill artifacts, promote / demote a skill,
  classify maturity, or verify an install.

## Migrating from `cursor-skill-creator`

The pack was renamed from `cursor-skill-creator` to `cursor-skill-studio`
in 0.3.0 and the legacy `cursor-skill-creator-workflow` bundled skill
was removed in 1.1.0 per
[ADR-0005](../../../docs/ADR/ADR-0005-skill-authoring-surface-consolidation.md).
Re-sync the pack with the new name and remove any stale files under
`~/.cursor/skills/cursor-skill-creator-workflow/` or
`<project>/.cursor/skills/cursor-skill-creator-workflow/`.
