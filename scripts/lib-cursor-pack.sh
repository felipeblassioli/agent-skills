#!/usr/bin/env bash
set -euo pipefail

CURSOR_PACK_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURSOR_PACK_REPO_ROOT="$(cd "$CURSOR_PACK_LIB_DIR/.." && pwd)"
CURSOR_PACK_REGISTRY="$CURSOR_PACK_REPO_ROOT/cursor-pack-registry.json"

CURSOR_PACK_RED='\033[0;31m'
CURSOR_PACK_GREEN='\033[0;32m'
CURSOR_PACK_YELLOW='\033[0;33m'
CURSOR_PACK_CYAN='\033[0;36m'
CURSOR_PACK_BOLD='\033[1m'
CURSOR_PACK_NC='\033[0m'

cursor_pack_die() {
  echo -e "${CURSOR_PACK_RED}$*${CURSOR_PACK_NC}" >&2
  exit 1
}

cursor_pack_require_file() {
  local path="$1"
  [[ -f "$path" ]] || cursor_pack_die "Required file not found: $path"
}

cursor_pack_require_dir() {
  local path="$1"
  [[ -d "$path" ]] || cursor_pack_die "Required directory not found: $path"
}

cursor_pack_registry_has_pack() {
  local pack_name="$1"
  jq -e --arg pack "$pack_name" '.packs[$pack] != null' "$CURSOR_PACK_REGISTRY" >/dev/null
}

cursor_pack_registry_entry() {
  local pack_name="$1"
  jq -c --arg pack "$pack_name" '.packs[$pack]' "$CURSOR_PACK_REGISTRY"
}

cursor_pack_path() {
  local pack_name="$1"
  jq -r --arg pack "$pack_name" '.packs[$pack].path' "$CURSOR_PACK_REGISTRY" \
    | sed "s#^#$CURSOR_PACK_REPO_ROOT/#"
}

cursor_pack_json_path() {
  local pack_name="$1"
  echo "$(cursor_pack_path "$pack_name")/pack.json"
}

cursor_pack_resolve_target_name() {
  local raw_target="$1"
  case "$raw_target" in
    project|project-cursor) echo "project-cursor" ;;
    user|user-cursor) echo "user-cursor" ;;
    *) cursor_pack_die "Unsupported target: $raw_target" ;;
  esac
}

cursor_pack_target_root() {
  local target="$1"
  local project_root="${2:-}"

  case "$target" in
    project-cursor)
      [[ -n "$project_root" ]] || cursor_pack_die "--project-root is required for project installs"
      echo "$project_root"
      ;;
    user-cursor)
      echo "$HOME/.cursor"
      ;;
    *)
      cursor_pack_die "Unknown target: $target"
      ;;
  esac
}

cursor_pack_manifest_rel_path() {
  local target="$1"
  local pack_json="$2"
  local manifest_file
  manifest_file=$(jq -r '.install.manifestFile' "$pack_json")

  case "$target" in
    project-cursor) echo ".cursor/$manifest_file" ;;
    user-cursor) echo "$manifest_file" ;;
    *) cursor_pack_die "Unknown target: $target" ;;
  esac
}

cursor_pack_list_profiles() {
  local pack_json="$1"
  jq -r '.profiles | keys[]' "$pack_json"
}

cursor_pack_has_profile() {
  local pack_json="$1"
  local profile="$2"
  jq -e --arg profile "$profile" '.profiles[$profile] != null' "$pack_json" >/dev/null
}

cursor_pack_default_profile() {
  local pack_json="$1"
  jq -r '.install.defaultProfile' "$pack_json"
}

cursor_pack_selected_artifacts() {
  local pack_json="$1"
  local target="$2"
  local profile="$3"

  jq -c --arg target "$target" --arg profile "$profile" '
    .artifacts[]
    | select((.targets | index($target)) != null)
    | select((.profiles | index($profile)) != null)
  ' "$pack_json"
}

cursor_pack_artifact_dest_rel() {
  local artifact_json="$1"
  local target="$2"

  case "$target" in
    project-cursor) jq -r '.projectPath // empty' <<<"$artifact_json" ;;
    user-cursor) jq -r '.userPath // empty' <<<"$artifact_json" ;;
    *) cursor_pack_die "Unknown target: $target" ;;
  esac
}

cursor_pack_bump_version() {
  local version="$1"
  local bump="$2"
  local major minor patch

  IFS='.' read -r major minor patch <<<"$version"
  major="${major:-0}"
  minor="${minor:-0}"
  patch="${patch:-0}"

  case "$bump" in
    major) major=$((major + 1)); minor=0; patch=0 ;;
    minor) minor=$((minor + 1)); patch=0 ;;
    patch) patch=$((patch + 1)) ;;
    *) cursor_pack_die "Unsupported bump type: $bump" ;;
  esac

  echo "$major.$minor.$patch"
}
