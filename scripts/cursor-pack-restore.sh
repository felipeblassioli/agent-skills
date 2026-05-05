#!/usr/bin/env bash
# Usage: scripts/cursor-pack-restore.sh --backup-dir=PATH
# Restore files from a previous cursor-pack-sync backup.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=scripts/lib-cursor-pack.sh
source "$SCRIPT_DIR/lib-cursor-pack.sh"

BACKUP_DIR=""

for arg in "$@"; do
  case "$arg" in
    --backup-dir=*) BACKUP_DIR="${arg#--backup-dir=}" ;;
    --help)
      echo "Usage: $0 --backup-dir=PATH"
      exit 0
      ;;
    *)
      cursor_pack_die "Unknown option: $arg"
      ;;
  esac
done

[[ -n "$BACKUP_DIR" ]] || cursor_pack_die "--backup-dir is required"

METADATA="$BACKUP_DIR/backup-metadata.json"
cursor_pack_require_file "$METADATA"

jq empty "$METADATA" >/dev/null 2>&1 || cursor_pack_die "Backup metadata is not valid JSON: $METADATA"

TARGET_ROOT="$(jq -r '.targetRoot' "$METADATA")"
PACK_NAME="$(jq -r '.pack' "$METADATA")"

[[ -d "$TARGET_ROOT" ]] || cursor_pack_die "Target root does not exist anymore: $TARGET_ROOT"

restored_count=0
removed_count=0

while IFS= read -r record; do
  rel="$(jq -r '.relativePath' <<<"$record")"
  existed_before="$(jq -r '.existedBefore' <<<"$record")"
  dest="$TARGET_ROOT/$rel"
  backup_file="$BACKUP_DIR/files/$rel"

  if [[ "$existed_before" == "true" ]]; then
    cursor_pack_require_dir "$BACKUP_DIR/files"
    [[ -f "$backup_file" ]] || cursor_pack_die "Missing backup file for restoration: $backup_file"
    mkdir -p "$(dirname "$dest")"
    cp -p "$backup_file" "$dest"
    ((restored_count+=1))
  else
    rm -f "$dest"
    ((removed_count+=1))
  fi
done < <(jq -c '.files[]' "$METADATA")

echo -e "${CURSOR_PACK_GREEN}Restore complete.${CURSOR_PACK_NC}"
echo "Pack: $PACK_NAME"
echo "Backup directory: $BACKUP_DIR"
echo "Target root: $TARGET_ROOT"
echo "Files restored: $restored_count"
echo "Files removed: $removed_count"
