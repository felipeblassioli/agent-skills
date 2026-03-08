#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=scripts/release-unit-lib.sh
source "$SCRIPT_DIR/release-unit-lib.sh"

TAG=""
KIND=""
NAME=""
VERSION=""
OUTPUT_DIR="$RELEASE_UNIT_OUTPUT_ROOT"

for arg in "$@"; do
  case "$arg" in
    --tag=*) TAG="${arg#--tag=}" ;;
    --kind=*) KIND="${arg#--kind=}" ;;
    --name=*) NAME="${arg#--name=}" ;;
    --version=*) VERSION="${arg#--version=}" ;;
    --output-dir=*) OUTPUT_DIR="${arg#--output-dir=}" ;;
    --help)
      echo "Usage: $0 --tag=skill-foo@1.2.3 [--output-dir=.work/release-assets]"
      exit 0
      ;;
    *)
      release_unit_die "Unknown option: $arg"
      ;;
  esac
done

if [[ -n "$TAG" ]]; then
  parsed="$(release_unit_parse_tag "$TAG")"
  KIND="$(jq -r '.kind' <<<"$parsed")"
  NAME="$(jq -r '.name' <<<"$parsed")"
  VERSION="$(jq -r '.version' <<<"$parsed")"
fi

metadata="$(release_unit_resolve "$KIND" "$NAME" "$VERSION")"
SOURCE_REL="$(jq -r '.sourceRel' <<<"$metadata")"
SOURCE_ABS="$RELEASE_UNIT_REPO_ROOT/$SOURCE_REL"
ARCHIVE_NAME="$(jq -r '.archiveName' <<<"$metadata")"
STAGE_NAME="$KIND-$NAME"

release_unit_require_dir "$SOURCE_ABS"
mkdir -p "$OUTPUT_DIR"

stage_dir="$(mktemp -d)"
trap 'rm -rf "$stage_dir"' EXIT

mkdir -p "$stage_dir/$STAGE_NAME"
rsync -a --exclude='.DS_Store' "$SOURCE_ABS/" "$stage_dir/$STAGE_NAME/"

archive_path="$OUTPUT_DIR/$ARCHIVE_NAME"
tar -czf "$archive_path" -C "$stage_dir" "$STAGE_NAME"

echo "$archive_path"
