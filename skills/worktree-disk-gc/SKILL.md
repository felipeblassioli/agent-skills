---
name: worktree-disk-gc
description: Reclaim disk space from git worktree pools by deleting reproducible node_modules trees from worktrees that show no sign of active work, gated on clean tree, fully-pushed commits, no open files, idleness, and a sibling lockfile. Use when a worktree directory has grown to many GB, when asked why ~/worktrees is so large, to clean up node_modules across worktrees, to find abandoned or prunable worktrees, or to audit which worktrees still hold unpushed or uncommitted work. Not for deleting worktrees or branches, not for `git gc` / packfile repacking, and not for cleaning a single ordinary checkout.
---

# Worktree Disk GC

## Applicability Gate

Use this skill when disk pressure comes from **many git worktrees of the same repo**, each holding its own installed dependency tree.

Use it when the user asks to:
- explain why a worktree pool is tens of GB
- reclaim space from worktrees without losing work
- clean `node_modules` across worktrees
- list which worktrees are safe to touch, or which still hold unpushed work
- find prunable worktrees (registered but the directory is gone)

Do not use it to:
- remove worktrees or delete branches (`git worktree remove`, `git branch -d`)
- repack git objects (`git gc`, `git repack`) — worktrees **share** one object store, so that is not where the bytes are
- clean a single ordinary checkout (just delete `node_modules` directly)
- decide whether a branch's work is still wanted — that is a review question, not a disk question

## The Diagnosis First

Before proposing any deletion, establish where the bytes actually are. The
common answer in a worktree pool is *N* independent dependency installs, because
npm and yarn materialise a full tree per install with no content-addressed store
(pnpm is the exception). Confirm it:

```bash
du -sh <pool>/*  | sort -rh | head
du -sh <pool>/*/node_modules <pool>/*/*/node_modules 2>/dev/null | sort -rh | head
du -sh $(git rev-parse --git-common-dir)
```

If the shared git dir is small (tens of MB) and each worktree is ~1 GB, the
bytes are dependencies, not history. Say so — that reframes the problem from
"something is wrong" to "this is the expected cost of N installs".

## Running the Tool

`scripts/worktree-nm-gc.sh` enumerates every worktree of a repo — including
pools in unrelated parent directories, since `git worktree list` finds them all
— gates each one, and reports. **Dry-run by default.**

```bash
bash scripts/worktree-nm-gc.sh                       # report from inside the repo
bash scripts/worktree-nm-gc.sh --repo-root /path/to/repo
bash scripts/worktree-nm-gc.sh --json                # machine-readable
bash scripts/worktree-nm-gc.sh --apply               # delete what passed every gate
```

Always show the user the dry-run table and the reclaimable total before running
`--apply`. Deleting is reversible only in the sense that `npm ci` reinstalls —
which costs network time and, on private registries, a valid token.

### Safety gates

A worktree is skipped if **any** gate fails. Each has an opt-out flag, so
prefer explaining the gate over bypassing it.

| Gate | Meaning | Opt-out |
|---|---|---|
| `main` | primary checkout | `--include-main` |
| `cwd` | your shell is inside it | — |
| `locked` | `git worktree lock` was used | — |
| `prunable` | directory is missing | — |
| `dirty-tracked` | uncommitted changes to tracked files | — |
| `dirty-untracked` | untracked files present | `--allow-untracked` |
| `unpushed(N)` | N commits on no remote | `--allow-unpushed` |
| `in-use` | a process has it open or cwd'd there | `--no-inuse-check` |
| `recent(Nh)` | git activity inside `--min-idle-days` (default 1) | `--min-idle-days 0` |
| `no-lockfile` | no sibling lockfile, so `npm ci` cannot reproduce it | `--allow-missing-lockfile` |

`in-use` is the only gate whose failure means deleting would break something
running *right now*. The rest are proxies for "someone is still working here".

### Interpreting the report

- **`unpushed`** is the strongest "do not touch" signal, and it is also a
  finding in its own right: unpushed commits in an idle worktree are work at
  risk of being lost. Surface those separately from the disk question.
- **`no-lockfile`** commonly hits workspace sub-packages (`packages/*/node_modules`,
  `modules/*/node_modules`) whose lockfile lives at the workspace root. Those
  are reproducible by reinstalling at the root, so `--allow-missing-lockfile`
  is usually correct there — but confirm the root install actually recreates
  them before recommending it.
- **`prunable`** worktrees need `git worktree prune`, not deletion.

## Reporting Back

Give the user, in this order:
1. where the bytes are (diagnosis, not just a number)
2. reclaimable total and worktree count
3. the exact `--apply` command
4. the restore command (`npm ci`, run where the lockfile is)
5. anything the scan found that is *not* a disk issue — unpushed commits,
   prunable entries, worktrees whose branch already merged

## Notes

- The tool reads mtimes for the idle gate **before** running `git status`,
  because `git status` rewrites the index and would make every worktree look
  active. Preserve that ordering if editing the script.
- It never follows symlinks and refuses to delete any path whose basename is
  not exactly `node_modules`; it re-checks every invariant immediately before
  each `rm -rf`.
- A full run costs a `du` per candidate tree plus one `lsof` dump — tens of
  seconds on a large pool is normal.

Tests: `bash scripts/tests/test-worktree-nm-gc.sh` (self-contained; builds a
throwaway repo, touches nothing real).
