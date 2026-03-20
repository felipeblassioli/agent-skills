# Installation

## Supported targets

- `project-cursor`
- `user-cursor`

## Recommended commands

Project install:

```bash
bash scripts/cursor-pack-sync.sh --pack=engineering-workflows --target=project --project-root="$PWD" --profile=lite
```

User install:

```bash
bash scripts/cursor-pack-sync.sh --pack=engineering-workflows --target=user --profile=lite
```

## What gets installed

- `engineering-*` bundled skills under `.cursor/skills/` or `~/.cursor/skills/`
- `.cursor/mcp.example.json` or `~/.cursor/mcp.example.json`

## First use

After installation, use any of the bundled workflow skills directly:

- `engineering-standup`
- `engineering-code-review`
- `engineering-debug`
- `engineering-architecture`
- `engineering-incident-response`
- `engineering-deploy-checklist`
