#!/usr/bin/env bash
#
# Self-contained behavioural tests for worktree-nm-gc.sh.
# Builds a throwaway repo + remote + worktrees under mktemp; touches nothing real.
#
#   bash skills/worktree-disk-gc/scripts/tests/test-worktree-nm-gc.sh

set -uo pipefail

here=$(cd "$(dirname "$0")" && pwd)
gc="$here/../worktree-nm-gc.sh"
[ -f "$gc" ] || { echo "cannot find worktree-nm-gc.sh next to tests/" >&2; exit 1; }

pass=0; fail=0
ok()   { printf '  ok   %s\n' "$1"; pass=$((pass+1)); }
bad()  { printf '  FAIL %s\n' "$1"; printf '       %s\n' "${2:-}"; fail=$((fail+1)); }
check(){ # name expected actual
  if [ "$2" = "$3" ]; then ok "$1"; else bad "$1" "expected [$2] got [$3]"; fi
}

# pwd -P: git reports resolved paths, and mktemp -d hands back /var/... on macOS
root=$(cd "$(mktemp -d)" && pwd -P)
trap 'chmod -R u+w "$root" 2>/dev/null; rm -rf "$root"' EXIT

export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null
export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@t GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@t
real_git=$(command -v git)

q() { "$@" >/dev/null 2>&1; }

# remote + primary clone
q git init --bare -b main "$root/remote.git"
q git clone "$root/remote.git" "$root/main"
main="$root/main"
# .worktrees/ must be ignored, else hosting a nested worktree makes the outer
# one dirty-untracked and the ownership case never gets exercised.
printf 'node_modules/\n.worktrees/\n' > "$main/.gitignore"
printf '{"name":"app"}\n' > "$main/package.json"
printf '{"lockfileVersion":3}\n' > "$main/package-lock.json"
q git -C "$main" add -A
q git -C "$main" commit -m init
q git -C "$main" push -u origin main

mk_nm() { mkdir -p "$1/node_modules/dep"; printf 'x\n' > "$1/node_modules/dep/index.js"; }

# --- fixtures -------------------------------------------------------------
# clean + pushed + lockfile
q git -C "$main" worktree add -b clean "$root/wt-clean" main
q git -C "$root/wt-clean" push -u origin clean
mk_nm "$root/wt-clean"

# unpushed commit
q git -C "$main" worktree add -b unpushed "$root/wt-unpushed" main
printf 'y\n' > "$root/wt-unpushed/new.txt"
q git -C "$root/wt-unpushed" add -A
q git -C "$root/wt-unpushed" commit -m local-only
mk_nm "$root/wt-unpushed"

# pushed, but node_modules has no sibling lockfile
q git -C "$main" worktree add -b nolock "$root/wt-nolock" main
q git -C "$root/wt-nolock" push -u origin nolock
mkdir -p "$root/wt-nolock/sub"
mk_nm "$root/wt-nolock/sub"

# dirty tracked file
q git -C "$main" worktree add -b dirty "$root/wt-dirty" main
q git -C "$root/wt-dirty" push -u origin dirty
printf 'changed\n' > "$root/wt-dirty/package.json"
mk_nm "$root/wt-dirty"

# untracked file only
q git -C "$main" worktree add -b untracked "$root/wt-untracked" main
q git -C "$root/wt-untracked" push -u origin untracked
printf 'scratch\n' > "$root/wt-untracked/scratch.md"
mk_nm "$root/wt-untracked"

# nested worktree living INSIDE another worktree
q git -C "$main" worktree add -b outer "$root/wt-outer" main
q git -C "$root/wt-outer" push -u origin outer
mk_nm "$root/wt-outer"
q git -C "$main" worktree add -b inner "$root/wt-outer/.worktrees/inner" main
printf 'z\n' > "$root/wt-outer/.worktrees/inner/local.txt"
q git -C "$root/wt-outer/.worktrees/inner" add -A
q git -C "$root/wt-outer/.worktrees/inner" commit -m inner-unpushed
mk_nm "$root/wt-outer/.worktrees/inner"

# common flags: deterministic, no lsof dependency, no idle window
FLAGS="--repo-root $main --no-inuse-check --min-idle-days 0 --json"

decision_for() { # path
  /bin/bash "$gc" $FLAGS 2>/dev/null | jq -r --arg p "$1" '.worktrees[] | select(.path==$p) | .decision'
}
reasons_for() {
  /bin/bash "$gc" $FLAGS 2>/dev/null | jq -r --arg p "$1" '.worktrees[] | select(.path==$p) | .reasons'
}

echo "gates:"
check "clean+pushed+lockfile => RECLAIM"   "RECLAIM" "$(decision_for "$root/wt-clean")"
check "unpushed => SKIP"                   "SKIP"    "$(decision_for "$root/wt-unpushed")"
check "unpushed reason"                    "unpushed(1)" "$(reasons_for "$root/wt-unpushed")"
check "no sibling lockfile => SKIP"        "SKIP"    "$(decision_for "$root/wt-nolock")"
check "no-lockfile reason"                 "no-lockfile" "$(reasons_for "$root/wt-nolock")"
check "dirty tracked => SKIP"              "SKIP"    "$(decision_for "$root/wt-dirty")"
check "untracked-only => SKIP by default"  "SKIP"    "$(decision_for "$root/wt-untracked")"
check "primary checkout excluded"          "SKIP"    "$(decision_for "$main")"
check "primary checkout reason"            "main"    "$(reasons_for "$main")"

echo "escape hatches:"
u_dec=$(/bin/bash "$gc" $FLAGS --allow-untracked 2>/dev/null \
  | jq -r --arg p "$root/wt-untracked" '.worktrees[]|select(.path==$p)|.decision')
check "--allow-untracked flips untracked-only" "RECLAIM" "$u_dec"
p_dec=$(/bin/bash "$gc" $FLAGS --allow-unpushed 2>/dev/null \
  | jq -r --arg p "$root/wt-unpushed" '.worktrees[]|select(.path==$p)|.decision')
check "--allow-unpushed flips unpushed" "RECLAIM" "$p_dec"
l_dec=$(/bin/bash "$gc" $FLAGS --allow-missing-lockfile 2>/dev/null \
  | jq -r --arg p "$root/wt-nolock" '.worktrees[]|select(.path==$p)|.decision')
check "--allow-missing-lockfile flips no-lockfile" "RECLAIM" "$l_dec"

echo "inspection failures:"
mkdir -p "$root/shims"
cat > "$root/shims/git" <<EOF
#!/bin/sh
case "\$*" in
  *"-C \$GC_FAIL_STATUS_PATH status "*) exit 70 ;;
  *"-C \$GC_FAIL_REACHABILITY_PATH rev-list "*) exit 71 ;;
esac
exec "$real_git" "\$@"
EOF
chmod +x "$root/shims/git"

status_json=$(GC_FAIL_STATUS_PATH="$root/wt-untracked" GC_FAIL_REACHABILITY_PATH=/dev/null \
  PATH="$root/shims:$PATH" /bin/bash "$gc" $FLAGS --allow-untracked 2>/dev/null)
status_dec=$(printf '%s' "$status_json" | jq -r --arg p "$root/wt-untracked" '.worktrees[]|select(.path==$p)|.decision')
status_reason=$(printf '%s' "$status_json" | jq -r --arg p "$root/wt-untracked" '.worktrees[]|select(.path==$p)|.reasons')
check "failed tracked status => SKIP with --allow-untracked" "SKIP" "$status_dec"
check "failed tracked status reason" "status-unknown" "$status_reason"

reach_json=$(GC_FAIL_STATUS_PATH=/dev/null GC_FAIL_REACHABILITY_PATH="$root/wt-clean" \
  PATH="$root/shims:$PATH" /bin/bash "$gc" $FLAGS 2>/dev/null)
reach_dec=$(printf '%s' "$reach_json" | jq -r --arg p "$root/wt-clean" '.worktrees[]|select(.path==$p)|.decision')
reach_reason=$(printf '%s' "$reach_json" | jq -r --arg p "$root/wt-clean" '.worktrees[]|select(.path==$p)|.reasons')
check "failed reachability check => SKIP" "SKIP" "$reach_dec"
check "failed reachability reason" "reachability-unknown" "$reach_reason"

echo "nesting:"
# wt-outer is clean+pushed; the nested inner worktree is unpushed. The outer
# worktree must NOT claim (and later delete) the inner one's node_modules.
outer_targets=$(/bin/bash "$gc" $FLAGS --worktree "$root/wt-outer" 2>/dev/null | jq -r '.node_modules_targets')
check "outer claims only its own node_modules" "1" "$outer_targets"
check "nested unpushed worktree skipped" "SKIP" "$(decision_for "$root/wt-outer/.worktrees/inner")"

echo "dry-run vs apply:"
q /bin/bash "$gc" $FLAGS
[ -d "$root/wt-clean/node_modules" ] && ok "dry-run left node_modules intact" \
  || bad "dry-run left node_modules intact" "it was deleted"

q /bin/bash "$gc" --repo-root "$main" --no-inuse-check --min-idle-days 0 --worktree "$root/wt-clean" --apply
[ -d "$root/wt-clean/node_modules" ] && bad "--apply removed node_modules" "still present" \
  || ok "--apply removed node_modules"
[ -f "$root/wt-clean/package.json" ] && ok "--apply left source files alone" \
  || bad "--apply left source files alone" "package.json gone"
[ -d "$root/wt-unpushed/node_modules" ] && ok "--apply spared the skipped worktree" \
  || bad "--apply spared the skipped worktree" "it was deleted"

echo "refusals:"
# a symlink named node_modules must never be followed or removed
q git -C "$main" worktree add -b linky "$root/wt-linky" main
q git -C "$root/wt-linky" push -u origin linky
mkdir -p "$root/precious/dep"
ln -s "$root/precious" "$root/wt-linky/node_modules"
q /bin/bash "$gc" --repo-root "$main" --no-inuse-check --min-idle-days 0 --worktree "$root/wt-linky" --apply
[ -d "$root/precious/dep" ] && ok "symlinked node_modules target untouched" \
  || bad "symlinked node_modules target untouched" "precious/ was deleted"

# The apply-time check must obtain a new lsof snapshot rather than reusing the
# scan-time result. Simulate a process opening the candidate between the calls.
q git -C "$main" worktree add -b became-active "$root/wt-became-active" main
q git -C "$root/wt-became-active" push -u origin became-active
mk_nm "$root/wt-became-active"
cat > "$root/shims/lsof" <<'EOF'
#!/bin/sh
count_file=${GC_LSOF_COUNT_FILE:?}
count=0
[ ! -f "$count_file" ] || count=$(cat "$count_file")
count=$((count + 1))
printf '%s\n' "$count" > "$count_file"
if [ "$count" -eq 1 ]; then
  printf 'n/some/unrelated/open/file\n'
else
  printf 'n%s/node_modules/dep/index.js\n' "$GC_LSOF_ACTIVE_PATH"
fi
EOF
chmod +x "$root/shims/lsof"
: > "$root/lsof-count"
GC_FAIL_STATUS_PATH=/dev/null GC_FAIL_REACHABILITY_PATH=/dev/null \
  GC_LSOF_COUNT_FILE="$root/lsof-count" GC_LSOF_ACTIVE_PATH="$root/wt-became-active" \
  PATH="$root/shims:$PATH" q /bin/bash "$gc" --repo-root "$main" --min-idle-days 0 \
    --worktree "$root/wt-became-active" --apply
[ -d "$root/wt-became-active/node_modules" ] && ok "apply refresh spared newly in-use node_modules" \
  || bad "apply refresh spared newly in-use node_modules" "it was deleted from the stale snapshot"
check "lsof was refreshed before deletion" "2" "$(cat "$root/lsof-count")"

printf '\n%s passed, %s failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ] || exit 1
