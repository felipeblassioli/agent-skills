#!/usr/bin/env bash
set -euo pipefail

RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

EXIT_USAGE=2
EXIT_SAFETY=3
EXIT_FS=4

FROM=""
TO=""
MODE="copy"
YES=false
BACKUP=false
OVERWRITE=false
VERBOSE=false
DRY_RUN=false
SKILLS=()

SOURCE_ROOT=""
DEST_ROOT=""
SOURCE_ROOT_ABS=""
DEST_ROOT_ABS=""
BACKUP_ROOT=""

die_usage() {
  printf '%b%s%b\n' "$RED" "$*" "$NC" >&2
  exit "$EXIT_USAGE"
}

die_safety() {
  printf '%b%s%b\n' "$YELLOW" "$*" "$NC" >&2
  exit "$EXIT_SAFETY"
}

die_fs() {
  printf '%b%s%b\n' "$RED" "$*" "$NC" >&2
  exit "$EXIT_FS"
}

usage() {
  cat <<'EOF'
Usage:
  scripts/skill-directory-sync.sh diff --from=TARGET_OR_PATH --to=TARGET_OR_PATH [--skill=NAME ...] [--verbose]
  scripts/skill-directory-sync.sh apply --from=TARGET_OR_PATH --to=TARGET_OR_PATH [--mode=copy|symlink] [--backup] [--overwrite] [--yes] [--dry-run] [--skill=NAME ...] [--verbose]
  scripts/skill-directory-sync.sh list-targets
  scripts/skill-directory-sync.sh help
EOF
}

expand_tilde() {
  local path="$1"
  case "$path" in
    ~) printf '%s\n' "$HOME" ;;
    ~/*) printf '%s/%s\n' "$HOME" "${path#~/}" ;;
    *) printf '%s\n' "$path" ;;
  esac
}

target_path() {
  local raw="$1"
  case "$raw" in
    cursor) printf '%s/.cursor/skills\n' "$HOME" ;;
    claude) printf '%s/.claude/skills\n' "$HOME" ;;
    agents) printf '%s/.agents/skills\n' "$HOME" ;;
    *) expand_tilde "$raw" ;;
  esac
}

list_targets() {
  printf '%-10s %s\n' "cursor" "$(target_path cursor)"
  printf '%-10s %s\n' "claude" "$(target_path claude)"
  printf '%-10s %s\n' "agents" "$(target_path agents)"
}

validate_skill_selector() {
  local name="$1"
  [[ -n "$name" ]] || die_usage "--skill must not be empty"
  [[ "$name" != *"/"* ]] || die_usage "--skill must be a skill name, not a path: $name"
  [[ "$name" != *"\\"* ]] || die_usage "--skill must be a skill name, not a path: $name"
}

contains_dot_components() {
  local raw="$1"
  [[ "$raw" == *"/../"* || "$raw" == *"/.." || "$raw" == "../"* || "$raw" == *"/./"* || "$raw" == *"/." ]]
}

abs_path_no_create() {
  local path="$1"
  if [[ -e "$path" ]]; then
    if [[ -d "$path" ]]; then
      (cd "$path" 2>/dev/null && pwd -P) || return 1
    else
      local parent base
      parent="$(dirname "$path")"
      base="$(basename "$path")"
      (cd "$parent" 2>/dev/null && printf '%s/%s\n' "$(pwd -P)" "$base") || return 1
    fi
  else
    local parent base existing_parent suffix
    parent="$(dirname "$path")"
    base="$(basename "$path")"
    existing_parent="$parent"
    suffix="$base"
    while [[ ! -e "$existing_parent" && "$existing_parent" != "/" ]]; do
      suffix="$(basename "$existing_parent")/$suffix"
      existing_parent="$(dirname "$existing_parent")"
    done
    (cd "$existing_parent" 2>/dev/null && printf '%s/%s\n' "$(pwd -P)" "$suffix") || return 1
  fi
}

path_contains() {
  local parent="$1"
  local child="$2"
  [[ "$child" == "$parent"/* ]]
}

parse_common_flags() {
  FROM=""
  TO=""
  MODE="copy"
  YES=false
  BACKUP=false
  OVERWRITE=false
  VERBOSE=false
  DRY_RUN=false
  SKILLS=()

  for arg in "$@"; do
    case "$arg" in
      --from=*) FROM="${arg#--from=}" ;;
      --to=*) TO="${arg#--to=}" ;;
      --mode=*) MODE="${arg#--mode=}" ;;
      --yes) YES=true ;;
      --backup) BACKUP=true ;;
      --overwrite) OVERWRITE=true ;;
      --verbose) VERBOSE=true ;;
      --dry-run) DRY_RUN=true ;;
      --skill=*)
        validate_skill_selector "${arg#--skill=}"
        SKILLS+=("${arg#--skill=}")
        ;;
      *) die_usage "Unknown option: $arg" ;;
    esac
  done

  [[ -n "$FROM" ]] || die_usage "--from is required"
  [[ -n "$TO" ]] || die_usage "--to is required"
  [[ "$MODE" == "copy" || "$MODE" == "symlink" ]] || die_usage "Unsupported mode: $MODE"
}

validate_roots() {
  SOURCE_ROOT="$(target_path "$FROM")"
  DEST_ROOT="$(target_path "$TO")"

  if [[ ! -e "$SOURCE_ROOT" && $(contains_dot_components "$SOURCE_ROOT"; echo $?) -eq 0 ]]; then
    die_safety "Refusing unresolved dot path components: $FROM"
  fi
  if [[ ! -e "$DEST_ROOT" && $(contains_dot_components "$DEST_ROOT"; echo $?) -eq 0 ]]; then
    die_safety "Refusing unresolved dot path components: $TO"
  fi

  [[ -d "$SOURCE_ROOT" ]] || die_fs "Source root not found: $SOURCE_ROOT"
  SOURCE_ROOT_ABS="$(abs_path_no_create "$SOURCE_ROOT")" || die_fs "Cannot resolve source root: $SOURCE_ROOT"
  DEST_ROOT_ABS="$(abs_path_no_create "$DEST_ROOT")" || die_fs "Cannot resolve destination path: $DEST_ROOT"

  if [[ "$SOURCE_ROOT_ABS" == "$DEST_ROOT_ABS" ]]; then
    die_safety "Source and destination resolve to the same directory"
  fi
  if path_contains "$SOURCE_ROOT_ABS" "$DEST_ROOT_ABS" || path_contains "$DEST_ROOT_ABS" "$SOURCE_ROOT_ABS"; then
    die_safety "Source and destination root contains the other"
  fi
}

is_selected_skill() {
  local name="$1"
  if [[ "${#SKILLS[@]}" -eq 0 ]]; then
    return 0
  fi
  local s
  for s in "${SKILLS[@]}"; do
    if [[ "$s" == "$name" ]]; then
      return 0
    fi
  done
  return 1
}

discover_entries() {
  local root="$1"
  local side="$2"
  local outfile="$3"
  : >"$outfile"

  if [[ ! -d "$root" ]]; then
    return 0
  fi

  while IFS= read -r entry; do
    local name type annotation
    name="$(basename "$entry")"
    if [[ -L "$entry" && ! -e "$entry" ]]; then
      if [[ "$side" == "source" ]]; then
        type="broken-source-symlink"
      else
        type="broken-destination-symlink"
      fi
      printf '%s\t%s\t%s\t%s\t%s\n' "$side" "$name" "$type" "" "$entry" >>"$outfile"
    elif [[ -d "$entry" && -f "$entry/SKILL.md" ]]; then
      if [[ -L "$entry" ]]; then
        annotation="${side}-symlink"
      else
        annotation=""
      fi
      printf '%s\t%s\t%s\t%s\t%s\n' "$side" "$name" "valid" "$annotation" "$entry" >>"$outfile"
    else
      if [[ "$side" == "source" ]]; then
        type="invalid-source-entry"
      else
        type="invalid-destination-entry"
      fi
      printf '%s\t%s\t%s\t%s\t%s\n' "$side" "$name" "$type" "" "$entry" >>"$outfile"
    fi
  done < <(find "$root" -mindepth 1 -maxdepth 1 -print | sort)
}

entry_line_by_name() {
  local file="$1"
  local name="$2"
  grep -F $'\t'"$name"$'\t' "$file" | head -n 1 || true
}

entry_type_by_name() {
  local file="$1"
  local name="$2"
  local line
  line="$(entry_line_by_name "$file" "$name")"
  if [[ -z "$line" ]]; then
    printf '\n'
  else
    printf '%s\n' "$line" | cut -f3
  fi
}

entry_annotation_by_name() {
  local file="$1"
  local name="$2"
  local line
  line="$(entry_line_by_name "$file" "$name")"
  if [[ -z "$line" ]]; then
    printf '\n'
  else
    printf '%s\n' "$line" | cut -f4
  fi
}

entry_path_by_name() {
  local file="$1"
  local name="$2"
  local line
  line="$(entry_line_by_name "$file" "$name")"
  if [[ -z "$line" ]]; then
    printf '\n'
  else
    printf '%s\n' "$line" | cut -f5
  fi
}

valid_names() {
  local file="$1"
  awk -F '\t' '$3=="valid" {print $2}' "$file" | sort -u
}

file_sha256() {
  local file="$1"
  local out
  out="$(shasum -a 256 "$file")"
  printf '%s\n' "${out%% *}"
}

skill_digest() {
  local entry="$1"
  local resolved
  resolved="$(cd "$entry" 2>/dev/null && pwd -P)" || return 1

  (
    cd "$resolved" || exit 1
    while IFS= read -r rel; do
      case "$rel" in
        ./.git|./.git/*|./.DS_Store|*/.DS_Store) continue ;;
      esac
      local clean
      clean="${rel#./}"
      if [[ -L "$rel" ]]; then
        printf 'L\t%s\t%s\n' "$clean" "$(readlink "$rel")"
      elif [[ -f "$rel" ]]; then
        printf 'F\t%s\t%s\n' "$clean" "$(file_sha256 "$rel")"
      fi
    done < <(find . -mindepth 1 \( -type f -o -type l \) -print | sort)
  ) | {
    local out
    out="$(shasum -a 256)"
    printf '%s\n' "${out%% *}"
  }
}

validate_source_skill_content() {
  local source_entry="$1"
  while IFS= read -r rel; do
    [[ -n "$rel" ]] || continue
    if [[ -L "$source_entry/$rel" && ! -e "$source_entry/$rel" ]]; then
      die_safety "Source skill contains broken nested symlink: $(basename "$source_entry")/$rel"
    fi
  done < <(cd "$source_entry" && find . -mindepth 1 -type l -print | sed 's#^./##' | sort)
}

print_diff_output() {
  local rows_file="$1"
  local counts_file="$2"
  printf 'Source: %s (%s)\n' "$FROM" "$SOURCE_ROOT"
  printf 'Destination: %s (%s)\n\n' "$TO" "$DEST_ROOT"
  printf '%-30s %s\n' "STATE" "SKILL"
  while IFS= read -r line; do
    [[ -n "$line" ]] || continue
    printf '%-30s %s\n' "$(printf '%s' "$line" | cut -f1)" "$(printf '%s' "$line" | cut -f2)"
  done <"$rows_file"
  printf '\n'
  while IFS= read -r c; do
    [[ -n "$c" ]] || continue
    printf '%s\n' "$c"
  done <"$counts_file"
}

run_diff() {
  parse_common_flags "$@"
  validate_roots

  local src_file dst_file rows_file counts_file
  src_file="$(mktemp)"
  dst_file="$(mktemp)"
  rows_file="$(mktemp)"
  counts_file="$(mktemp)"

  discover_entries "$SOURCE_ROOT" "source" "$src_file"
  discover_entries "$DEST_ROOT" "destination" "$dst_file"

  : >"$rows_file"
  : >"$counts_file"

  while IFS= read -r name; do
    [[ -n "$name" ]] || continue
    is_selected_skill "$name" || continue
    local dst_type dst_path src_path state
    dst_type="$(entry_type_by_name "$dst_file" "$name")"
    src_path="$(entry_path_by_name "$src_file" "$name")"
    dst_path="$(entry_path_by_name "$dst_file" "$name")"
    if [[ -z "$dst_type" ]]; then
      state="missing-in-destination"
    elif [[ "$dst_type" != "valid" ]]; then
      state="destination-conflict-for-source"
    else
      local src_digest dst_digest
      src_digest="$(skill_digest "$src_path")" || die_fs "Failed to hash source skill: $name"
      dst_digest="$(skill_digest "$dst_path")" || die_fs "Failed to hash destination skill: $name"
      if [[ "$src_digest" == "$dst_digest" ]]; then
        state="identical"
      else
        state="changed"
      fi
    fi
    printf '%s\t%s\n' "$state" "$name" >>"$rows_file"
  done < <(valid_names "$src_file")

  while IFS= read -r name; do
    [[ -n "$name" ]] || continue
    is_selected_skill "$name" || continue
    if [[ -z "$(entry_type_by_name "$src_file" "$name")" ]]; then
      printf '%s\t%s\n' "destination-only" "$name" >>"$rows_file"
    fi
  done < <(valid_names "$dst_file")

  while IFS= read -r line; do
    [[ -n "$line" ]] || continue
    local name st
    name="$(printf '%s' "$line" | cut -f2)"
    is_selected_skill "$name" || continue
    st="$(printf '%s' "$line" | cut -f3)"
    if [[ "$st" == "invalid-source-entry" || "$st" == "broken-source-symlink" ]]; then
      printf '%s\t%s\n' "$st" "$name" >>"$rows_file"
    fi
  done <"$src_file"

  while IFS= read -r line; do
    [[ -n "$line" ]] || continue
    local name st
    name="$(printf '%s' "$line" | cut -f2)"
    is_selected_skill "$name" || continue
    st="$(printf '%s' "$line" | cut -f3)"
    if [[ "$st" == "invalid-destination-entry" || "$st" == "broken-destination-symlink" ]]; then
      printf '%s\t%s\n' "$st" "$name" >>"$rows_file"
    fi
  done <"$dst_file"

  while IFS= read -r state; do
    [[ -n "$state" ]] || continue
    local count
    count="$(grep -c "^${state}" "$rows_file" || true)"
    printf '%s: %s\n' "$state" "$count" >>"$counts_file"
  done < <(cut -f1 "$rows_file" | sort | uniq)

  print_diff_output "$rows_file" "$counts_file"
  rm -f "$src_file" "$dst_file" "$rows_file" "$counts_file"
}

sanitize_label() {
  printf '%s' "$1" | tr '/ :' '---' | tr -cd 'A-Za-z0-9._-'
}

validate_backup_root() {
  if path_contains "$SOURCE_ROOT_ABS" "$BACKUP_ROOT" || path_contains "$DEST_ROOT_ABS" "$BACKUP_ROOT"; then
    die_safety "Backup root must be outside source and destination roots"
  fi
}

create_backup_root() {
  local label timestamp base candidate n
  label="$(sanitize_label "$TO")"
  timestamp="$(date +"%Y%m%d-%H%M%S")"
  base="$PWD/.work/skill-directory-sync-backups/$timestamp/$label"
  candidate="$base"
  n=0
  while [[ -e "$candidate" ]]; do
    n=$((n + 1))
    candidate="$base-$n"
  done
  BACKUP_ROOT="$(abs_path_no_create "$candidate")" || die_fs "Cannot resolve backup root candidate: $candidate"
  validate_backup_root
  mkdir -p "$BACKUP_ROOT" || die_fs "Failed to create backup root: $BACKUP_ROOT"
}

write_backup_metadata() {
  local records_file="$1"
  local metadata_path="$BACKUP_ROOT/backup-metadata.json"
  local skills_json
  if [[ -s "$records_file" ]]; then
    skills_json="$(jq -R 'split("\t") | {name: .[0], destinationPath: .[1], backupPath: .[2], existedBefore: (.[3] == "true"), wasSymlink: (.[4] == "true")}' <"$records_file" | jq -s .)"
  else
    skills_json='[]'
  fi
  jq -n \
    --arg createdAt "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
    --arg source "$SOURCE_ROOT_ABS" \
    --arg destination "$DEST_ROOT_ABS" \
    --arg mode "$MODE" \
    --arg operation "overwrite" \
    --arg backupRoot "$BACKUP_ROOT" \
    --argjson skills "$skills_json" \
    '{createdAt: $createdAt, source: $source, destination: $destination, mode: $mode, operation: $operation, backupRoot: $backupRoot, skills: $skills}' >"$metadata_path"
}

backup_entry() {
  local name="$1"
  local dest_entry="$2"
  local records_file="$3"
  local backup_entry_path
  backup_entry_path="$BACKUP_ROOT/$name"

  mkdir -p "$(dirname "$backup_entry_path")"
  if [[ -L "$dest_entry" ]]; then
    cp -P "$dest_entry" "$backup_entry_path" || die_fs "Failed to back up symlink: $dest_entry"
    printf '%s\t%s\t%s\t%s\t%s\n' "$name" "$dest_entry" "$backup_entry_path" "true" "true" >>"$records_file"
  elif [[ -d "$dest_entry" ]]; then
    cp -a "$dest_entry" "$backup_entry_path" || die_fs "Failed to back up directory: $dest_entry"
    printf '%s\t%s\t%s\t%s\t%s\n' "$name" "$dest_entry" "$backup_entry_path" "true" "false" >>"$records_file"
  elif [[ -e "$dest_entry" ]]; then
    cp -p "$dest_entry" "$backup_entry_path" || die_fs "Failed to back up file: $dest_entry"
    printf '%s\t%s\t%s\t%s\t%s\n' "$name" "$dest_entry" "$backup_entry_path" "true" "false" >>"$records_file"
  else
    die_fs "Destination entry not found for backup: $dest_entry"
  fi
  write_backup_metadata "$records_file"
}

remove_destination_entry_after_backup() {
  local dest_entry="$1"
  local dest_parent dest_name
  dest_parent="$(cd "$(dirname "$dest_entry")" && pwd -P)" || die_fs "Cannot resolve destination parent"
  dest_name="$(basename "$dest_entry")"
  [[ "$dest_parent" == "$DEST_ROOT_ABS" ]] || die_safety "Refusing to remove non-child destination entry: $dest_entry"
  [[ -n "$dest_name" && "$dest_name" != "." && "$dest_name" != ".." ]] || die_safety "Refusing unsafe destination name: $dest_entry"

  if [[ -L "$dest_entry" ]]; then
    rm "$dest_entry" || die_fs "Failed to remove destination symlink: $dest_entry"
  elif [[ -d "$dest_entry" ]]; then
    rm -rf "$dest_entry" || die_fs "Failed to remove destination directory: $dest_entry"
  elif [[ -e "$dest_entry" ]]; then
    rm "$dest_entry" || die_fs "Failed to remove destination file: $dest_entry"
  fi
}

copy_skill_to_destination() {
  local source_entry="$1"
  local dest_entry="$2"
  mkdir -p "$dest_entry"
  rsync -a --exclude='.git' --exclude='.DS_Store' "$source_entry/" "$dest_entry/" || die_fs "Failed to copy skill: $source_entry"
}

real_skill_path() {
  local entry="$1"
  (cd "$entry" 2>/dev/null && pwd -P)
}

symlink_skill_to_destination() {
  local source_entry="$1"
  local dest_entry="$2"
  local real_source
  real_source="$(real_skill_path "$source_entry")" || die_fs "Cannot resolve source skill: $source_entry"
  ln -s "$real_source" "$dest_entry" || die_fs "Failed to symlink skill: $dest_entry"
}

print_action_plan() {
  local actions_file="$1"
  local blocked_file="$2"

  if [[ -s "$actions_file" ]]; then
    printf '\nPlanned actions:\n'
    printf '%-8s %-24s FROM -> TO\n' "ACTION" "SKILL"
    while IFS= read -r plan_line; do
      [[ -n "$plan_line" ]] || continue
      local plan_action plan_name plan_src plan_dst
      plan_action="$(printf '%s' "$plan_line" | cut -f1)"
      plan_name="$(printf '%s' "$plan_line" | cut -f2)"
      plan_src="$(printf '%s' "$plan_line" | cut -f3)"
      plan_dst="$(printf '%s' "$plan_line" | cut -f4)"
      printf '%-8s %-24s %s -> %s\n' "$plan_action" "$plan_name" "$plan_src" "$plan_dst"
    done <"$actions_file"
  else
    printf '\nPlanned actions: (none)\n'
  fi

  if [[ -s "$blocked_file" ]]; then
    printf '\nConflicts:\n'
    while IFS= read -r blocked_line; do
      [[ -n "$blocked_line" ]] || continue
      local blocked_name blocked_src blocked_dst blocked_reason
      blocked_name="$(printf '%s' "$blocked_line" | cut -f1)"
      blocked_src="$(printf '%s' "$blocked_line" | cut -f2)"
      blocked_dst="$(printf '%s' "$blocked_line" | cut -f3)"
      blocked_reason="$(printf '%s' "$blocked_line" | cut -f4)"
      printf '%-24s %s\n' "$blocked_name" "$blocked_reason" 
      printf '  from: %s\n' "$blocked_src"
      printf '  to:   %s\n' "$blocked_dst"
    done <"$blocked_file"
  fi
}

run_apply() {
  parse_common_flags "$@"
  validate_roots

  if ! "$DRY_RUN"; then
    "$YES" || die_safety "--yes is required for apply"
  fi

  local src_file dst_file selected_file actions_file blocked_file backup_records
  src_file="$(mktemp)"
  dst_file="$(mktemp)"
  discover_entries "$SOURCE_ROOT" "source" "$src_file"
  discover_entries "$DEST_ROOT" "destination" "$dst_file"

  selected_file="$(mktemp)"
  actions_file="$(mktemp)"
  blocked_file="$(mktemp)"
  backup_records="$(mktemp)"
  : >"$selected_file"
  : >"$actions_file"
  : >"$blocked_file"
  : >"$backup_records"

  if [[ "${#SKILLS[@]}" -eq 0 ]]; then
    valid_names "$src_file" >"$selected_file"
  else
    local req
    for req in "${SKILLS[@]}"; do
      if [[ "$(entry_type_by_name "$src_file" "$req")" == "valid" ]]; then
        printf '%s\n' "$req" >>"$selected_file"
      else
        die_safety "Selected skill is not a valid source skill: $req"
      fi
    done
  fi

  local copied_count=0
  local updated_count=0
  local unchanged_count=0
  local blocked_count=0
  local first_blocked=""
  local requires_backup=false

  while IFS= read -r name; do
    [[ -n "$name" ]] || continue
    local src_path dst_type dst_path src_digest dst_digest detail
    src_path="$(entry_path_by_name "$src_file" "$name")"
    validate_source_skill_content "$src_path"

    dst_type="$(entry_type_by_name "$dst_file" "$name")"
    dst_path="$DEST_ROOT/$name"

    if [[ -z "$dst_type" ]]; then
      printf 'copy\t%s\t%s\t%s\n' "$name" "$src_path" "$dst_path" >>"$actions_file"
      copied_count=$((copied_count + 1))
      continue
    fi

    if [[ "$dst_type" != "valid" ]]; then
      if "$OVERWRITE" && "$BACKUP"; then
        printf 'update\t%s\t%s\t%s\n' "$name" "$src_path" "$dst_path" >>"$actions_file"
        updated_count=$((updated_count + 1))
        requires_backup=true
      else
        detail="destination has invalid structure (${dst_type}); use --overwrite --backup"
        printf '%s\t%s\t%s\t%s\n' "$name" "$src_path" "$dst_path" "$detail" >>"$blocked_file"
        blocked_count=$((blocked_count + 1))
        [[ -n "$first_blocked" ]] || first_blocked="destination-conflict-for-source: $name"
      fi
      continue
    fi

    local src_digest dst_digest
    src_digest="$(skill_digest "$src_path")" || die_fs "Failed to hash source skill: $name"
    dst_digest="$(skill_digest "$DEST_ROOT/$name")" || die_fs "Failed to hash destination skill: $name"
    if [[ "$src_digest" == "$dst_digest" ]]; then
      unchanged_count=$((unchanged_count + 1))
      continue
    fi

    if "$OVERWRITE" && "$BACKUP"; then
      printf 'update\t%s\t%s\t%s\n' "$name" "$src_path" "$dst_path" >>"$actions_file"
      updated_count=$((updated_count + 1))
      requires_backup=true
    elif "$OVERWRITE" && ! "$BACKUP"; then
      detail="destination changed; --backup is required with --overwrite"
      printf '%s\t%s\t%s\t%s\n' "$name" "$src_path" "$dst_path" "$detail" >>"$blocked_file"
      blocked_count=$((blocked_count + 1))
      [[ -n "$first_blocked" ]] || first_blocked="--backup is required with --overwrite"
    else
      detail="destination changed; add --overwrite --backup"
      printf '%s\t%s\t%s\t%s\n' "$name" "$src_path" "$dst_path" "$detail" >>"$blocked_file"
      blocked_count=$((blocked_count + 1))
      [[ -n "$first_blocked" ]] || first_blocked="--overwrite is required for changed destination skills"
    fi
  done <"$selected_file"

  if [[ "$blocked_count" -gt 0 && "$DRY_RUN" == false ]]; then
    die_safety "$first_blocked"
  fi

  if [[ "$DRY_RUN" == false && ! -d "$DEST_ROOT" && ( "$copied_count" -gt 0 || "$updated_count" -gt 0 ) ]]; then
    mkdir -p "$DEST_ROOT" || die_fs "Failed to create destination root: $DEST_ROOT"
    DEST_ROOT_ABS="$(abs_path_no_create "$DEST_ROOT")" || die_fs "Cannot resolve destination root: $DEST_ROOT"
  fi

  if [[ "$DRY_RUN" == false ]] && "$requires_backup"; then
    create_backup_root
  fi

  if [[ "$DRY_RUN" == false ]]; then
    while IFS= read -r action_line; do
      [[ -n "$action_line" ]] || continue
      local action_type name src_path dest_path
      action_type="$(printf '%s' "$action_line" | cut -f1)"
      name="$(printf '%s' "$action_line" | cut -f2)"
      src_path="$(printf '%s' "$action_line" | cut -f3)"
      dest_path="$(printf '%s' "$action_line" | cut -f4)"

      if [[ "$action_type" == "update" ]]; then
        backup_entry "$name" "$dest_path" "$backup_records"
        remove_destination_entry_after_backup "$dest_path"
      fi

      if [[ "$MODE" == "copy" ]]; then
        copy_skill_to_destination "$src_path" "$dest_path"
      else
        symlink_skill_to_destination "$src_path" "$dest_path"
      fi
    done <"$actions_file"
  fi

  printf 'Source: %s (%s)\n' "$FROM" "$SOURCE_ROOT"
  printf 'Destination: %s (%s)\n' "$TO" "$DEST_ROOT"
  printf 'Mode: %s\n' "$MODE"
  print_action_plan "$actions_file" "$blocked_file"
  if "$requires_backup" && [[ "$DRY_RUN" == false ]]; then
    printf 'Backup directory: %s\n' "$BACKUP_ROOT"
  fi
  printf 'Copied: %s\n' "$copied_count"
  printf 'Updated: %s\n' "$updated_count"
  printf 'Conflicts: %s\n' "$blocked_count"
  printf 'Unchanged: %s\n' "$unchanged_count"
  if [[ "$DRY_RUN" == true ]]; then
    printf 'Dry run complete. No destination files were changed.\n'
  fi

  rm -f "$src_file" "$dst_file" "$selected_file" "$actions_file" "$blocked_file" "$backup_records"
}

main() {
  local cmd="${1:-help}"
  if [[ $# -gt 0 ]]; then
    shift
  fi

  case "$cmd" in
    help|--help|-h)
      usage
      ;;
    list-targets)
      list_targets
      ;;
    diff)
      run_diff "$@"
      ;;
    apply)
      run_apply "$@"
      ;;
    *)
      die_usage "Unknown command: $cmd"
      ;;
  esac
}

main "$@"
