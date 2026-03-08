# Installation

Use the pack tooling from this repository so installs are staged, verified, and
backed up before conflicts are overwritten.

## 1. Verify before installing

```bash
bash scripts/cursor-pack-verify.sh --pack=cursor-companion
```

## 2. Install into a project

From the repository you want to equip with Cursor runtime assets:

```bash
bash /path/to/agent-skills/scripts/cursor-pack-sync.sh \
  --pack=cursor-companion \
  --target=project \
  --project-root "$PWD" \
  --profile=strict
```

Use `--dry-run` first if you want a staged preview without modifying the target.

## 3. Install into the user profile

```bash
bash scripts/cursor-pack-sync.sh \
  --pack=cursor-companion \
  --target=user \
  --profile=lite
```

This installs into `~/.cursor/`.

## 4. Restore from backup if needed

Every non-dry-run install creates a backup directory under `.work/`.

```bash
bash scripts/cursor-pack-restore.sh --backup-dir .work/cursor-pack-backups/<pack>/<target>/<timestamp>
```

## Recommended defaults

- use `project + strict` for team repos that want shared guard-rails
- use `user + lite` for personal reusable subagents and MCP templates
- promote `mcp.example.json` to a live `mcp.json` only after review
