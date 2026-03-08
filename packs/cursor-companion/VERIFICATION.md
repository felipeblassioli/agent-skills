# Verification

This file is the committed release companion to `CHANGELOG.md`.

## Release 0.1.0 - 2026-03-08

## Commands

```bash
bash scripts/cursor-pack-verify.sh --pack=cursor-companion
bash scripts/cursor-pack-sync.sh --pack=cursor-companion --target=project --project-root="$PWD" --profile=strict --dry-run
bash scripts/cursor-pack-sync.sh --pack=cursor-companion --target=user --profile=lite --dry-run
```

## Outcome

- structural verification passed
- dry-run installs validated the expected project and user targets
- the pack established the baseline runtime bundle for subagents, rules, hooks,
  and MCP examples in this repository

## Diagnosis

- the pack is a strong reference implementation for mixed-surface runtime bundles
- release history and verification evidence should remain committed as the pack evolves
- future changes should continue treating MCP as template-driven and keep guardrails explicit
