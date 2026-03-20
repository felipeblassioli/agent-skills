# Installation

## Supported targets

- `project-cursor`
- `user-cursor`

## Recommended commands

Project install:

```bash
bash scripts/cursor-pack-sync.sh --pack=cursor-skill-creator --target=project --project-root="$PWD" --profile=lite
```

User install:

```bash
bash scripts/cursor-pack-sync.sh --pack=cursor-skill-creator --target=user --profile=lite
```

Strict project install:

```bash
bash scripts/cursor-pack-sync.sh --pack=cursor-skill-creator --target=project --project-root="$PWD" --profile=strict
```

## What gets installed

- `.cursor/agents/` or `~/.cursor/agents/`
- `.cursor/skills/cursor-skill-creator-workflow/` or
  `~/.cursor/skills/cursor-skill-creator-workflow/`
- `.cursor/rules/` only for strict project installs

## First use

After installation, use the bundled `cursor-skill-creator-workflow` skill when
you want to:

- create a new pack from reference material
- adapt a Claude-style source tree into Cursor-native artifacts
- structure an eval and review loop for authoring work
