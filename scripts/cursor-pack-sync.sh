#!/usr/bin/env bash
# Usage: scripts/cursor-pack-sync.sh --pack=NAME --target=project|user [options]
# Stage and install a Cursor pack with conflict-aware backups and manifest updates.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=scripts/lib-cursor-pack.sh
source "$SCRIPT_DIR/lib-cursor-pack.sh"

PACK_NAME=""
RAW_TARGET=""
PROFILE=""
PROJECT_ROOT=""
STAGE_DIR=""
BACKUP_DIR=""
DRY_RUN=false
FORCE=false

for arg in "$@"; do
  case "$arg" in
    --pack=*) PACK_NAME="${arg#--pack=}" ;;
    --target=*) RAW_TARGET="${arg#--target=}" ;;
    --profile=*) PROFILE="${arg#--profile=}" ;;
    --project-root=*) PROJECT_ROOT="${arg#--project-root=}" ;;
    --stage-dir=*) STAGE_DIR="${arg#--stage-dir=}" ;;
    --backup-dir=*) BACKUP_DIR="${arg#--backup-dir=}" ;;
    --dry-run) DRY_RUN=true ;;
    --force) FORCE=true ;;
    --help)
      echo "Usage: $0 --pack=NAME --target=project|user [--profile=lite|strict] [--project-root=PATH] [--stage-dir=PATH] [--backup-dir=PATH] [--dry-run] [--force]"
      exit 0
      ;;
    *)
      cursor_pack_die "Unknown option: $arg"
      ;;
  esac
done

[[ -n "$PACK_NAME" ]] || cursor_pack_die "--pack is required"
[[ -n "$RAW_TARGET" ]] || cursor_pack_die "--target is required"

TARGET="$(cursor_pack_resolve_target_name "$RAW_TARGET")"

cursor_pack_registry_has_pack "$PACK_NAME" || cursor_pack_die "Pack '$PACK_NAME' not found in registry"

PACK_DIR="$(cursor_pack_path "$PACK_NAME")"
PACK_JSON="$(cursor_pack_json_path "$PACK_NAME")"
cursor_pack_require_dir "$PACK_DIR"
cursor_pack_require_file "$PACK_JSON"

if [[ -z "$PROFILE" ]]; then
  PROFILE="$(cursor_pack_default_profile "$PACK_JSON")"
fi
cursor_pack_has_profile "$PACK_JSON" "$PROFILE" || cursor_pack_die "Unknown profile '$PROFILE' for pack '$PACK_NAME'"

if [[ "$TARGET" == "project-cursor" ]]; then
  if [[ -z "$PROJECT_ROOT" ]]; then
    PROJECT_ROOT="$PWD"
  fi
  PROJECT_ROOT="${PROJECT_ROOT%/}"
  [[ -d "$PROJECT_ROOT" ]] || cursor_pack_die "Project root not found: $PROJECT_ROOT"
fi

TARGET_ROOT="$(cursor_pack_target_root "$TARGET" "$PROJECT_ROOT")"
MANIFEST_REL="$(cursor_pack_manifest_rel_path "$TARGET" "$PACK_JSON")"
MANIFEST_PATH="$TARGET_ROOT/$MANIFEST_REL"
PACK_VERSION="$(jq -r '.version' "$PACK_JSON")"

STAGE_ROOT_SETTING="$(jq -r '.install.stageRoot' "$PACK_JSON")"
BACKUP_ROOT_SETTING="$(jq -r '.install.backupRoot' "$PACK_JSON")"
TIMESTAMP="$(date +"%Y%m%d-%H%M%S")"

if [[ -z "$STAGE_DIR" ]]; then
  STAGE_DIR="$CURSOR_PACK_REPO_ROOT/$STAGE_ROOT_SETTING/$PACK_NAME/$TARGET/$TIMESTAMP"
fi

if [[ -z "$BACKUP_DIR" ]]; then
  BACKUP_DIR="$CURSOR_PACK_REPO_ROOT/$BACKUP_ROOT_SETTING/$PACK_NAME/$TARGET/$TIMESTAMP"
fi

artifact_lines_file="$(mktemp)"
installed_files_file="$(mktemp)"
backup_records_file="$(mktemp)"
trap 'rm -f "$artifact_lines_file" "$installed_files_file" "$backup_records_file"' EXIT

cursor_pack_selected_artifacts "$PACK_JSON" "$TARGET" "$PROFILE" >"$artifact_lines_file"
[[ -s "$artifact_lines_file" ]] || cursor_pack_die "No artifacts selected for pack '$PACK_NAME', target '$TARGET', profile '$PROFILE'"

mkdir -p "$STAGE_DIR"

while IFS= read -r artifact_json; do
  [[ -n "$artifact_json" ]] || continue
  source_rel="$(jq -r '.source' <<<"$artifact_json")"
  dest_rel="$(cursor_pack_artifact_dest_rel "$artifact_json" "$TARGET")"
  artifact_id="$(jq -r '.id' <<<"$artifact_json")"
  [[ -n "$dest_rel" ]] || cursor_pack_die "Artifact '$artifact_id' does not define a destination for target '$TARGET'"

  source_abs="$PACK_DIR/$source_rel"
  [[ -e "$source_abs" ]] || cursor_pack_die "Artifact source not found: $source_abs"

  if [[ -d "$source_abs" ]]; then
    mkdir -p "$STAGE_DIR/$dest_rel"
    rsync -a "$source_abs/" "$STAGE_DIR/$dest_rel/"
  else
    mkdir -p "$(dirname "$STAGE_DIR/$dest_rel")"
    cp -p "$source_abs" "$STAGE_DIR/$dest_rel"
  fi
done <"$artifact_lines_file"

is_up_to_date=false
if [[ "$FORCE" == false && -f "$MANIFEST_PATH" ]]; then
  if jq -e --arg pack "$PACK_NAME" --arg version "$PACK_VERSION" --arg profile "$PROFILE" '
    .packs[$pack] != null and
    .packs[$pack].version == $version and
    .packs[$pack].profile == $profile
  ' "$MANIFEST_PATH" >/dev/null 2>&1; then
    missing_files=false
    while IFS= read -r rel; do
      [[ -n "$rel" ]] || continue
      if [[ ! -e "$TARGET_ROOT/$rel" ]]; then
        missing_files=true
        break
      fi
    done < <(jq -r --arg pack "$PACK_NAME" '.packs[$pack].files[]?' "$MANIFEST_PATH")

    if [[ "$missing_files" == false ]]; then
      is_up_to_date=true
    fi
  fi
fi

if [[ "$is_up_to_date" == true ]]; then
  echo -e "${CURSOR_PACK_CYAN}UP-TO-DATE${CURSOR_PACK_NC} $PACK_NAME ($PACK_VERSION, profile=$PROFILE, target=$TARGET)"
  echo "Stage directory: $STAGE_DIR"
  exit 0
fi

mkdir -p "$TARGET_ROOT"

copied_count=0
updated_count=0
skipped_count=0
conflict_count=0

record_backup_entry() {
  local rel="$1"
  local existed_before="$2"
  printf '%s\t%s\n' "$rel" "$existed_before" >>"$backup_records_file"
}

backup_existing_file() {
  local rel="$1"
  local dest="$2"

  mkdir -p "$BACKUP_DIR/files/$(dirname "$rel")"
  cp -p "$dest" "$BACKUP_DIR/files/$rel"
}

while IFS= read -r staged_file; do
  rel="${staged_file#$STAGE_DIR/}"
  dest="$TARGET_ROOT/$rel"
  echo "$rel" >>"$installed_files_file"

  if [[ -f "$dest" ]]; then
    if cmp -s "$staged_file" "$dest"; then
      ((skipped_count+=1))
      continue
    fi

    ((conflict_count+=1))
    if [[ "$DRY_RUN" == false ]]; then
      backup_existing_file "$rel" "$dest"
      record_backup_entry "$rel" true
      cp -p "$staged_file" "$dest"
    fi
    ((updated_count+=1))
  else
    if [[ "$DRY_RUN" == false ]]; then
      mkdir -p "$(dirname "$dest")"
      record_backup_entry "$rel" false
      cp -p "$staged_file" "$dest"
    fi
    ((copied_count+=1))
  fi
done < <(find "$STAGE_DIR" -type f | sort)

manifest_tmp="$(mktemp)"
installed_files_json="$(jq -R . <"$installed_files_file" | jq -s .)"
pack_entry_json="$(jq -n \
  --arg version "$PACK_VERSION" \
  --arg profile "$PROFILE" \
  --arg target "$TARGET" \
  --arg installedAt "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
  --arg sourceRepo "$CURSOR_PACK_REPO_ROOT" \
  --argjson files "$installed_files_json" \
  '{
    version: $version,
    profile: $profile,
    target: $target,
    installedAt: $installedAt,
    sourceRepo: $sourceRepo,
    files: $files
  }')"

if [[ -f "$MANIFEST_PATH" ]] && jq empty "$MANIFEST_PATH" >/dev/null 2>&1; then
  jq --arg pack "$PACK_NAME" --argjson entry "$pack_entry_json" '
    .packs = (.packs // {}) |
    .packs[$pack] = $entry
  ' "$MANIFEST_PATH" >"$manifest_tmp"
else
  jq -n --arg pack "$PACK_NAME" --argjson entry "$pack_entry_json" '{packs: {($pack): $entry}}' >"$manifest_tmp"
fi

if [[ "$DRY_RUN" == false ]]; then
  mkdir -p "$BACKUP_DIR/files"
  if [[ -f "$MANIFEST_PATH" ]]; then
    backup_existing_file "$MANIFEST_REL" "$MANIFEST_PATH"
    record_backup_entry "$MANIFEST_REL" true
  else
    record_backup_entry "$MANIFEST_REL" false
  fi
  mkdir -p "$(dirname "$MANIFEST_PATH")"
  mv "$manifest_tmp" "$MANIFEST_PATH"

  backup_records_json="$(jq -R 'split("\t") | {relativePath: .[0], existedBefore: (.[1] == "true")}' <"$backup_records_file" | jq -s .)"
  jq -n \
    --arg pack "$PACK_NAME" \
    --arg version "$PACK_VERSION" \
    --arg target "$TARGET" \
    --arg profile "$PROFILE" \
    --arg targetRoot "$TARGET_ROOT" \
    --arg manifestRel "$MANIFEST_REL" \
    --arg createdAt "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
    --argjson files "$backup_records_json" \
    '{
      pack: $pack,
      version: $version,
      target: $target,
      profile: $profile,
      targetRoot: $targetRoot,
      manifestRelativePath: $manifestRel,
      createdAt: $createdAt,
      files: $files
    }' >"$BACKUP_DIR/backup-metadata.json"
else
  rm -f "$manifest_tmp"
fi

echo -e "${CURSOR_PACK_BOLD}$PACK_NAME${CURSOR_PACK_NC} (${PACK_VERSION})"
echo "Target: $TARGET"
if [[ "$TARGET" == "project-cursor" ]]; then
  echo "Project root: $PROJECT_ROOT"
fi
echo "Profile: $PROFILE"
echo "Stage directory: $STAGE_DIR"
if [[ "$DRY_RUN" == false ]]; then
  echo "Backup directory: $BACKUP_DIR"
fi
echo "Copied: $copied_count"
echo "Updated: $updated_count"
echo "Conflicts: $conflict_count"
echo "Unchanged: $skipped_count"
if [[ "$DRY_RUN" == true ]]; then
  echo -e "${CURSOR_PACK_YELLOW}Dry run complete.${CURSOR_PACK_NC} No destination files were changed."
else
  echo -e "${CURSOR_PACK_GREEN}Install complete.${CURSOR_PACK_NC}"
fi
