# Changelog

All notable changes to the `worktree-disk-gc` skill.

## 1.0.0 - 2026-07-26

### Added
- Initial skill: diagnose and reclaim disk in git worktree pools.
- `scripts/worktree-nm-gc.sh` — dry-run-by-default `node_modules` GC across
  every worktree of a repo, with per-worktree safety gates (`main`, `cwd`,
  `locked`, `prunable`, `dirty-tracked`, `dirty-untracked`, `unpushed`,
  `in-use`, `recent`) and a per-tree `no-lockfile` gate. Human table and
  `--json` output. Bash 3.2 compatible.
- `scripts/tests/test-worktree-nm-gc.sh` — 25 self-contained behavioural tests
  covering every gate, every opt-out flag, nested-worktree ownership,
  dry-run/apply separation, inspection failures, apply-time in-use refresh,
  and the symlink refusal.

### Notes
Two non-obvious behaviours are load-bearing and covered by tests:
- Activity mtimes are sampled **before** the dirty check, because `git status`
  rewrites the index and would otherwise make every worktree report as active.
- `--worktree` arguments and `--repo-root` are resolved with `pwd -P`, because
  `git worktree list` reports resolved paths (`/private/tmp`, not `/tmp`) and
  an unresolved argument silently matches nothing.
