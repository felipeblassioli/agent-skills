# Verification

This file is the committed release companion to `CHANGELOG.md`.

## Release 0.1.3 - 2026-03-19

## Commands

```bash
bash scripts/cursor-pack-verify.sh --pack=cursor-companion
bash scripts/cursor-pack-sync.sh --pack=cursor-companion --target=project --project-root="$PWD" --profile=lite --dry-run
bash scripts/cursor-pack-sync.sh --pack=cursor-companion --target=project --project-root="$PWD" --profile=strict --dry-run
bash scripts/cursor-pack-sync.sh --pack=cursor-companion --target=user --profile=lite --dry-run
bash scripts/cursor-pack-sync.sh --pack=cursor-companion --target=user --profile=strict --dry-run
```

## Outcome

- structural verification passed, including bundled skill checks (`SKILL.md`, `metadata.json`, `skillId` / frontmatter `name` alignment)
- dry-run installs covered both targets and both profiles; bundled skill stages to `.cursor/skills/cursor-companion-pack-overview/` (project) and `skills/cursor-companion-pack-overview/` under `~/.cursor` (user)

## Diagnosis

- establishes `kind: "skill"` pack artifacts as a supported install path aligned with repository doctrine
- residual risk: same `skillId` under `~/.cursor/skills/` can still collide with `skill-sync.sh`; pack-scoped naming mitigates

## Release 0.1.1 - 2026-03-09

## Commands

```bash
bash scripts/cursor-pack-verify.sh --pack=cursor-companion
bash scripts/cursor-pack-sync.sh --pack=cursor-companion --target=project --project-root="$PWD" --profile=lite --dry-run
bash scripts/cursor-pack-sync.sh --pack=cursor-companion --target=project --project-root="$PWD" --profile=strict --dry-run
bash scripts/cursor-pack-sync.sh --pack=cursor-companion --target=user --profile=lite --dry-run
bash scripts/cursor-pack-sync.sh --pack=cursor-companion --target=user --profile=strict --dry-run
```

## Outcome

- structural verification passed for the updated `0.1.1` pack contents
- dry-run installs covered both supported targets and both supported profiles
- the release adds explicit guidance and templates for nested `AGENTS.md`
  authoring while keeping repo-specific instruction files outside the pack's
  runtime ownership model

## Diagnosis

- `cursor-companion` now explains the split between repo `AGENTS.md`,
  `.cursor/rules`, reusable skills, and pack-owned runtime assets more clearly
- the release strengthens the pack as a reference implementation for
  Cursor-first routing and authoring guidance
- future releases should validate the templates against real project adoption
  examples as they accumulate

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
