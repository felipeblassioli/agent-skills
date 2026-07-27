#!/usr/bin/env bash
#
# worktree-nm-gc.sh — reclaim disk from git worktrees by deleting reproducible
# dependency trees (node_modules) from worktrees that show no sign of active work.
#
# Dry-run by default. Deletes only directories named exactly "node_modules"
# that sit next to a lockfile, inside a worktree that passed every safety gate.
#
# Bash 3.2 compatible (macOS system bash): no associative arrays, no mapfile.

set -euo pipefail

# ---------------------------------------------------------------------------
# defaults
# ---------------------------------------------------------------------------
repo_root=""
apply="false"
emit_json="false"
min_idle_days="1"
allow_untracked="false"
allow_unpushed="false"
allow_missing_lockfile="false"
inuse_check="true"
include_main="false"
target_worktrees=""   # newline-separated; empty = all

LOCKFILES="package-lock.json pnpm-lock.yaml yarn.lock npm-shrinkwrap.json bun.lockb"

usage() {
  cat <<'EOF'
Usage: worktree-nm-gc.sh [options]

Reclaim disk by deleting node_modules from git worktrees with no active work.
Dry-run unless --apply is passed.

Options:
  --repo-root PATH          Repo whose worktrees to scan (default: repo containing cwd).
  --worktree PATH           Limit to this worktree. Repeatable.
  --apply                   Actually delete. Without it, only report.
  --json                    Emit JSON instead of a table.
  --min-idle-days N         Skip worktrees with git activity newer than N days (default 1; 0 disables).
  --allow-untracked         Treat untracked-only worktrees as clean.
  --allow-unpushed          Do not require every commit to exist on a remote.
  --allow-missing-lockfile  Delete node_modules with no sibling lockfile (not reproducible).
  --no-inuse-check          Skip the open-file/cwd check (unsafe; use only if lsof is unavailable).
  --include-main            Also consider the primary checkout.
  -h, --help                This text.

Safety gates (a worktree is skipped if ANY fails):
  main            primary checkout                      (--include-main)
  cwd             your shell is inside it
  locked          `git worktree lock` was used
  prunable        worktree directory is missing
  dirty-tracked   uncommitted changes to tracked files
  dirty-untracked untracked files present               (--allow-untracked)
  unpushed        commits not reachable from any remote (--allow-unpushed)
  in-use          a process has it open or cwd'd into it (--no-inuse-check)
  recent          git activity within --min-idle-days
Per-node_modules gate:
  no-lockfile     no sibling lockfile => cannot reinstall faithfully (--allow-missing-lockfile)

Exit: 0 success, 1 usage/environment error.
EOF
}

die() { printf 'error: %s\n' "$*" >&2; exit 1; }

# ---------------------------------------------------------------------------
# args
# ---------------------------------------------------------------------------
while [ $# -gt 0 ]; do
  case "$1" in
    --repo-root)              repo_root="${2:-}"; shift 2 ;;
    --worktree)
      # git reports fully resolved paths (/private/tmp, not /tmp), so normalise
      # here or an argument through a symlinked parent silently matches nothing.
      _tw="${2:-}"
      _tw=$(cd "$_tw" 2>/dev/null && pwd -P) || _tw="${2:-}"
      target_worktrees="${target_worktrees}${_tw}
"; shift 2 ;;
    --apply)                  apply="true"; shift ;;
    --json)                   emit_json="true"; shift ;;
    --min-idle-days)          min_idle_days="${2:-}"; shift 2 ;;
    --allow-untracked)        allow_untracked="true"; shift ;;
    --allow-unpushed)         allow_unpushed="true"; shift ;;
    --allow-missing-lockfile) allow_missing_lockfile="true"; shift ;;
    --no-inuse-check)         inuse_check="false"; shift ;;
    --include-main)           include_main="true"; shift ;;
    -h|--help)                usage; exit 0 ;;
    *)                        usage >&2; die "unknown option: $1" ;;
  esac
done

case "$min_idle_days" in
  ''|*[!0-9]*) die "--min-idle-days must be a non-negative integer" ;;
esac

command -v git >/dev/null 2>&1 || die "git not found"

if [ -z "$repo_root" ]; then
  repo_root=$(git rev-parse --show-toplevel 2>/dev/null) \
    || die "not inside a git repository; pass --repo-root"
fi
[ -d "$repo_root" ] || die "--repo-root is not a directory: $repo_root"
repo_root=$(cd "$repo_root" && pwd -P)

tmp=$(mktemp -d) || die "cannot create temp dir"
trap 'rm -rf "$tmp"' EXIT

now=$(date +%s)
idle_cutoff=$(( min_idle_days * 86400 ))

# ---------------------------------------------------------------------------
# scan-time lsof dump, prefix-matched per worktree (lsof +D is far slower)
# Apply mode refreshes this snapshot immediately before each deletion.
# ---------------------------------------------------------------------------
open_paths="$tmp/open-paths"
inuse_available="false"

refresh_open_paths() {
  # Write through a temporary file so a failed refresh never leaves a partial
  # snapshot that could be mistaken for a successful safety check.
  refreshed="$tmp/open-paths.new"
  : > "$refreshed"
  if command -v lsof >/dev/null 2>&1 \
    && lsof -w -F n 2>/dev/null | sed -n 's|^n\(/.*\)$|\1|p' | sort -u > "$refreshed" \
    && [ -s "$refreshed" ]; then
    mv "$refreshed" "$open_paths"
    inuse_available="true"
    return 0
  fi
  rm -f "$refreshed"
  inuse_available="false"
  return 1
}

: > "$open_paths"
if [ "$inuse_check" = "true" ]; then
  refresh_open_paths || true
fi

path_in_use() {
  # $1 = worktree path. True if any open file or process cwd lives at/under it.
  [ "$inuse_available" = "true" ] || return 1
  awk -v p="$1/" -v self="$1" '
    $0 == self { found = 1; exit }
    index($0, p) == 1 { found = 1; exit }
    END { exit !found }
  ' "$open_paths"
}

newest_mtime() {
  # echoes the newest mtime among existing paths, or 0
  newest=0
  for p in "$@"; do
    [ -e "$p" ] || continue
    m=$(stat -f %m "$p" 2>/dev/null || stat -c %Y "$p" 2>/dev/null || echo 0)
    [ "$m" -gt "$newest" ] 2>/dev/null && newest="$m"
  done
  printf '%s' "$newest"
}

human_kb() {
  awk -v k="$1" 'BEGIN{
    if (k >= 1048576) printf "%.1fG", k/1048576;
    else if (k >= 1024) printf "%.0fM", k/1024;
    else printf "%dK", k;
  }'
}

json_escape() { printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g'; }

is_targeted() {
  [ -z "$target_worktrees" ] && return 0
  printf '%s' "$target_worktrees" | grep -qxF "$1"
}

# ---------------------------------------------------------------------------
# enumerate worktrees
# ---------------------------------------------------------------------------
wt_list="$tmp/worktrees"
git -C "$repo_root" worktree list --porcelain > "$wt_list" 2>/dev/null \
  || die "cannot list worktrees in $repo_root"

# Worktrees can nest (a pool under .worktrees/ inside the primary checkout), so a
# find rooted at one worktree can reach another's node_modules. Longest-prefix
# ownership keeps each tree attributed to the worktree actually gating it.
wt_paths="$tmp/wt-paths"
sed -n 's/^worktree //p' "$wt_list" > "$wt_paths"

owning_worktree() {
  awk -v target="$1" '
    { if (index(target "/", $0 "/") == 1 && length($0) > length(best)) best = $0 }
    END { print best }
  ' "$wt_paths"
}

records="$tmp/records"          # decision \t kb \t path \t branch \t reasons
: > "$records"
targets="$tmp/targets"          # node_modules dirs cleared for deletion
: > "$targets"
notes="$tmp/notes"
: > "$notes"

wt_path=""; wt_branch=""; wt_head=""; wt_bare=""; wt_locked=""; wt_prunable=""
first="true"

flush_worktree() {
  [ -n "$wt_path" ] || return 0

  branch_label="$wt_branch"
  [ -n "$branch_label" ] || branch_label="(detached ${wt_head:0:8})"

  is_main="false"
  [ "$first_path" = "$wt_path" ] && is_main="true"

  if ! is_targeted "$wt_path"; then
    return 0
  fi

  reasons=""
  add_reason() { if [ -z "$reasons" ]; then reasons="$1"; else reasons="$reasons,$1"; fi; }

  [ -n "$wt_bare" ] && add_reason "bare"
  [ -n "$wt_locked" ] && add_reason "locked"
  [ -n "$wt_prunable" ] && add_reason "prunable"
  { [ "$is_main" = "true" ] && [ "$include_main" != "true" ]; } && add_reason "main"

  case "$PWD/" in
    "$wt_path"/*) add_reason "cwd" ;;
  esac

  if [ -d "$wt_path" ] && [ -z "$wt_bare" ]; then
    # Sample activity mtimes BEFORE any git command below: `git status` refreshes
    # the stat cache and rewrites the index, which would make every worktree look
    # active 0h ago and silently disable the recency gate.
    activity=0
    if [ "$idle_cutoff" -gt 0 ]; then
      idx=$(git -C "$wt_path" rev-parse --git-path index 2>/dev/null || echo "")
      rlog=$(git -C "$wt_path" rev-parse --git-path logs/HEAD 2>/dev/null || echo "")
      activity=$(newest_mtime "$idx" "$rlog")
    fi

    # dirty: tracked vs untracked are different signals
    tracked_status_ok="false"
    if tracked_status=$(git -C "$wt_path" status --porcelain --untracked-files=no 2>/dev/null); then
      tracked_status_ok="true"
      [ -n "$tracked_status" ] && add_reason "dirty-tracked"
    else
      add_reason "status-unknown"
    fi
    if [ "$allow_untracked" != "true" ] && [ "$tracked_status_ok" = "true" ]; then
      full_status_file="$tmp/full-status"
      if git -C "$wt_path" status --porcelain --untracked-files=normal > "$full_status_file" 2>/dev/null; then
        untracked=$(awk '
          /^\?\?/ {
            path = substr($0, 4)
            if (path !~ /(^|\/)node_modules(\/|$)/ && first == "") first = $0
          }
          END { if (first != "") print first }
        ' "$full_status_file")
        [ -n "$untracked" ] && add_reason "dirty-untracked"
      else
        add_reason "status-unknown"
      fi
      rm -f "$full_status_file"
    fi

    # pushed: every commit reachable from HEAD also lives on some remote ref
    if [ "$allow_unpushed" != "true" ]; then
      if ahead=$(git -C "$wt_path" rev-list --count HEAD --not --remotes 2>/dev/null); then
        [ "${ahead:-0}" -gt 0 ] 2>/dev/null && add_reason "unpushed($ahead)"
      else
        add_reason "reachability-unknown"
      fi
    fi

    # recency: index + per-worktree reflog cover every git operation done here.
    # Editor-only edits surface through the dirty gate instead.
    if [ "$idle_cutoff" -gt 0 ] && [ "$activity" -gt 0 ] 2>/dev/null; then
      if [ $(( now - activity )) -lt "$idle_cutoff" ]; then
        add_reason "recent($(( (now - activity) / 3600 ))h)"
      fi
    fi

    if [ "$inuse_check" = "true" ]; then
      if [ "$inuse_available" != "true" ]; then
        add_reason "inuse-unknown"
      elif path_in_use "$wt_path"; then
        add_reason "in-use"
      fi
    fi
  fi

  if [ -n "$reasons" ]; then
    printf 'SKIP\t0\t%s\t%s\t%s\n' "$wt_path" "$branch_label" "$reasons" >> "$records"
    return 0
  fi

  # gates passed — find candidate node_modules (top-level only per package dir,
  # never descending into one, never following symlinks)
  nm_list="$tmp/nm.$$"
  find "$wt_path" -name node_modules -type d -prune -print 2>/dev/null \
    | grep -v '/\.git/' > "$nm_list" || true

  total_kb=0
  kept=""
  while IFS= read -r nm; do
    [ -n "$nm" ] || continue
    # belongs to a nested worktree, which gets gated on its own turn
    [ "$(owning_worktree "$nm")" = "$wt_path" ] || continue
    parent=$(dirname "$nm")
    has_lock="false"
    for lf in $LOCKFILES; do
      [ -f "$parent/$lf" ] && { has_lock="true"; break; }
    done
    if [ "$has_lock" != "true" ] && [ "$allow_missing_lockfile" != "true" ]; then
      printf '%s\tno-lockfile\n' "$nm" >> "$notes"
      kept="yes"
      continue
    fi
    kb=$(du -sk "$nm" 2>/dev/null | awk '{print $1}')
    [ -n "$kb" ] || kb=0
    total_kb=$(( total_kb + kb ))
    printf '%s\n' "$nm" >> "$targets"
  done < "$nm_list"
  rm -f "$nm_list"

  if [ "$total_kb" -eq 0 ]; then
    if [ -n "$kept" ]; then
      printf 'SKIP\t0\t%s\t%s\tno-lockfile\n' "$wt_path" "$branch_label" >> "$records"
    else
      printf 'SKIP\t0\t%s\t%s\tnothing-to-reclaim\n' "$wt_path" "$branch_label" >> "$records"
    fi
    return 0
  fi

  printf 'RECLAIM\t%s\t%s\t%s\tclean,pushed,idle\n' "$total_kb" "$wt_path" "$branch_label" >> "$records"
}

first_path=""
while IFS= read -r line; do
  case "$line" in
    worktree\ *)
      flush_worktree
      wt_path="${line#worktree }"
      wt_branch=""; wt_head=""; wt_bare=""; wt_locked=""; wt_prunable=""
      [ "$first" = "true" ] && { first_path="$wt_path"; first="false"; }
      ;;
    HEAD\ *)     wt_head="${line#HEAD }" ;;
    branch\ *)   wt_branch="${line#branch refs/heads/}" ;;
    bare)        wt_bare="1" ;;
    locked*)     wt_locked="1" ;;
    prunable*)   wt_prunable="1" ;;
  esac
done < "$wt_list"
flush_worktree

# ---------------------------------------------------------------------------
# apply
# ---------------------------------------------------------------------------
deleted_kb=0
deleted_count=0
failed_count=0
if [ "$apply" = "true" ] && [ -s "$targets" ]; then
  while IFS= read -r nm; do
    [ -n "$nm" ] || continue
    # re-assert every invariant immediately before rm (TOCTOU + typo defense)
    [ "$(basename "$nm")" = "node_modules" ] || { printf 'refuse: not node_modules: %s\n' "$nm" >&2; failed_count=$((failed_count+1)); continue; }
    [ -d "$nm" ] || continue
    [ -L "$nm" ] && { printf 'refuse: symlink: %s\n' "$nm" >&2; failed_count=$((failed_count+1)); continue; }
    case "$nm" in
      /*/*) : ;;
      *) printf 'refuse: suspicious path: %s\n' "$nm" >&2; failed_count=$((failed_count+1)); continue ;;
    esac
    if [ "$inuse_check" = "true" ]; then
      if ! refresh_open_paths; then
        printf 'refuse: cannot refresh in-use check: %s\n' "$nm" >&2; failed_count=$((failed_count+1)); continue
      fi
      if path_in_use "$nm"; then
        printf 'refuse: became in-use: %s\n' "$nm" >&2; failed_count=$((failed_count+1)); continue
      fi
    fi
    kb=$(du -sk "$nm" 2>/dev/null | awk '{print $1}'); [ -n "$kb" ] || kb=0
    if rm -rf -- "$nm"; then
      deleted_kb=$(( deleted_kb + kb ))
      deleted_count=$(( deleted_count + 1 ))
    else
      failed_count=$(( failed_count + 1 ))
    fi
  done < "$targets"
fi

# ---------------------------------------------------------------------------
# report
# ---------------------------------------------------------------------------
candidate_kb=$(awk -F'\t' '$1=="RECLAIM"{s+=$2} END{print s+0}' "$records")
candidate_wt=$(awk -F'\t' '$1=="RECLAIM"' "$records" | wc -l | tr -d ' ')
skipped_wt=$(awk -F'\t' '$1=="SKIP"' "$records" | wc -l | tr -d ' ')
target_count=$(wc -l < "$targets" | tr -d ' ')

if [ "$emit_json" = "true" ]; then
  printf '{\n'
  printf '  "repo_root": "%s",\n' "$(json_escape "$repo_root")"
  printf '  "mode": "%s",\n' "$([ "$apply" = "true" ] && echo apply || echo dry-run)"
  printf '  "reclaimable_kb": %s,\n' "${candidate_kb:-0}"
  printf '  "reclaimable_worktrees": %s,\n' "${candidate_wt:-0}"
  printf '  "skipped_worktrees": %s,\n' "${skipped_wt:-0}"
  printf '  "node_modules_targets": %s,\n' "${target_count:-0}"
  printf '  "deleted_kb": %s,\n' "$deleted_kb"
  printf '  "deleted_count": %s,\n' "$deleted_count"
  printf '  "failed_count": %s,\n' "$failed_count"
  printf '  "inuse_check": "%s",\n' "$([ "$inuse_check" != "true" ] && echo disabled || ([ "$inuse_available" = "true" ] && echo ok || echo unavailable))"
  printf '  "worktrees": [\n'
  awk -F'\t' '
    { gsub(/\\/, "\\\\"); gsub(/"/, "\\\"") }
    { printf "%s    {\"decision\": \"%s\", \"kb\": %s, \"path\": \"%s\", \"branch\": \"%s\", \"reasons\": \"%s\"}", (NR>1 ? ",\n" : ""), $1, $2, $3, $4, $5 }
    END { if (NR) printf "\n" }
  ' "$records"
  printf '  ]\n}\n'
  exit 0
fi

printf '%-8s %-8s %-58s %-42s %s\n' DECISION SIZE WORKTREE BRANCH REASONS
sort -t"$(printf '\t')" -k1,1r -k2,2nr "$records" | while IFS="$(printf '\t')" read -r d kb p b r; do
  size="-"
  [ "$kb" != "0" ] && size=$(human_kb "$kb")
  printf '%-8s %-8s %-58s %-42s %s\n' "$d" "$size" "${p/#$HOME/~}" "$b" "$r"
done

echo
if [ -s "$notes" ]; then
  echo "Skipped node_modules with no sibling lockfile (reinstall would not be reproducible):"
  awk -F'\t' -v h="$HOME" '{ p=$1; sub("^"h, "~", p); printf "  %s\n", p }' "$notes"
  echo
fi

if [ "$apply" = "true" ]; then
  printf 'Deleted %s node_modules tree(s), reclaimed %s. %s failure(s).\n' \
    "$deleted_count" "$(human_kb "$deleted_kb")" "$failed_count"
  echo 'Restore in any worktree with: npm ci   (run in the directory holding the lockfile)'
else
  printf 'Reclaimable: %s across %s worktree(s) / %s node_modules tree(s). %s worktree(s) skipped.\n' \
    "$(human_kb "${candidate_kb:-0}")" "${candidate_wt:-0}" "${target_count:-0}" "${skipped_wt:-0}"
  echo 'Dry run — nothing deleted. Re-run with --apply to delete.'
fi

if [ "$inuse_check" = "true" ] && [ "$inuse_available" != "true" ]; then
  echo
  echo 'WARNING: lsof produced no usable output, so "in use" could not be verified.' >&2
  echo 'All worktrees were skipped with reason inuse-unknown. Pass --no-inuse-check to override.' >&2
fi

prunable_n=$(grep -c '^prunable' "$wt_list" 2>/dev/null || true)
if [ "${prunable_n:-0}" -gt 0 ] 2>/dev/null; then
  echo
  printf 'Note: %s worktree(s) are prunable (directory gone). Run: git -C %s worktree prune\n' \
    "$prunable_n" "${repo_root/#$HOME/~}"
fi
