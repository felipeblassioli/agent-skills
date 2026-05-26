# Verification

This file is the committed release companion to `CHANGELOG.md`.

## Release 0.1.0 - 2026-05-26

## Commands

```bash
bash scripts/cursor-pack-verify.sh --pack=shell-scripting
bash scripts/cursor-pack-sync.sh --pack=shell-scripting --target=codex-user --profile=lite --dry-run
bash scripts/cursor-pack-sync.sh --pack=shell-scripting --target=codex-project --project-root=.work/codex-pack-smoke --profile=lite --dry-run
bash scripts/cursor-pack-sync.sh --pack=shell-scripting --target=codex-project --project-root=.work/codex-pack-smoke-real --profile=lite
```

## Outcome

- `cursor-pack-verify.sh` passed with 1 pack checked, 0 errors, and 0 warnings.
- `codex-user` dry-run staged 8 files with 8 copied, 0 updated, 0 conflicts,
  and 0 unchanged.
- `codex-project` dry-run against `.work/codex-pack-smoke` staged 8 files with
  8 copied, 0 updated, 0 conflicts, and 0 unchanged.
- Scratch `codex-project` install wrote the expected `.codex/agents/`,
  `.codex/skills/`, and `.codex/.cursor-pack-manifest.json` files.

## Diagnosis

- The pack intentionally targets Codex paths only.
- No MCP, hook, or persistent rule surface is installed.

## Residual risks

- The upstream Claude plugin contains broader prose than this initial
  distillation. Future releases may add references if real use shows the hot
  paths are too compact.
