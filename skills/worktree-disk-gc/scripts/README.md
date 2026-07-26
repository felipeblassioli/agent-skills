# scripts

## `worktree-nm-gc.sh`

Reclaims disk by deleting `node_modules` from git worktrees that show no sign of
active work. **Dry-run unless `--apply`.** See `SKILL.md` for the gate table.

```bash
bash worktree-nm-gc.sh --help
bash worktree-nm-gc.sh                     # report (repo containing cwd)
bash worktree-nm-gc.sh --json
bash worktree-nm-gc.sh --apply
```

Requires `git`, `du`, `awk`, `sed`, `find`, and `lsof` (for the in-use gate;
without it every worktree is skipped as `inuse-unknown` unless
`--no-inuse-check` is passed). No `jq` dependency — JSON is emitted directly.

Bash 3.2 compatible so it runs on macOS system bash.

### Invariants to preserve when editing

1. Activity mtimes are sampled **before** any `git status` call. `git status`
   refreshes the stat cache and rewrites the index, which resets the signal the
   idle gate depends on.
2. `--repo-root` and `--worktree` are normalised with `pwd -P`, because
   `git worktree list` reports resolved paths.
3. `node_modules` ownership uses longest-prefix matching against the full
   worktree list, so a worktree nested inside another (a pool under
   `.worktrees/`) is gated on its own turn rather than by its host.
4. Every deletion re-asserts basename, directory-ness, non-symlink, and
   not-in-use immediately before `rm -rf`.

## `tests/test-worktree-nm-gc.sh`

Self-contained: builds a bare remote, a clone, and seven worktrees under
`mktemp -d`. Touches nothing outside its temp dir.

```bash
bash tests/test-worktree-nm-gc.sh
```
