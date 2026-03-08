#!/usr/bin/env bash
# Usage: scripts/cursor-pack-version.sh <pack-name> [patch|minor|major]
# Bump the version of a Cursor pack in the pack registry and pack.json.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=scripts/lib-cursor-pack.sh
source "$SCRIPT_DIR/lib-cursor-pack.sh"

if [[ "${1:-}" == "--help" ]]; then
  echo "Usage: $0 <pack-name> [patch|minor|major]"
  exit 0
fi

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <pack-name> [patch|minor|major]" >&2
  exit 1
fi

PACK_NAME="$1"
BUMP_TYPE="${2:-patch}"

[[ "$BUMP_TYPE" =~ ^(patch|minor|major)$ ]] || cursor_pack_die "Invalid bump type: $BUMP_TYPE"
cursor_pack_registry_has_pack "$PACK_NAME" || cursor_pack_die "Pack '$PACK_NAME' not found in registry"

PACK_JSON="$(cursor_pack_json_path "$PACK_NAME")"
cursor_pack_require_file "$PACK_JSON"

CURRENT_VERSION="$(jq -r --arg pack "$PACK_NAME" '.packs[$pack].version' "$CURSOR_PACK_REGISTRY")"
NEW_VERSION="$(cursor_pack_bump_version "$CURRENT_VERSION" "$BUMP_TYPE")"

echo -e "${CURSOR_PACK_BOLD}$PACK_NAME${CURSOR_PACK_NC}: $CURRENT_VERSION -> ${CURSOR_PACK_GREEN}$NEW_VERSION${CURSOR_PACK_NC} ($BUMP_TYPE)"

jq --arg pack "$PACK_NAME" --arg version "$NEW_VERSION" '.packs[$pack].version = $version' \
  "$CURSOR_PACK_REGISTRY" >"$CURSOR_PACK_REGISTRY.tmp" && mv "$CURSOR_PACK_REGISTRY.tmp" "$CURSOR_PACK_REGISTRY"
echo -e "  ${CURSOR_PACK_GREEN}updated${CURSOR_PACK_NC} cursor-pack-registry.json"

jq --arg version "$NEW_VERSION" '.version = $version' "$PACK_JSON" >"$PACK_JSON.tmp" && mv "$PACK_JSON.tmp" "$PACK_JSON"
echo -e "  ${CURSOR_PACK_GREEN}updated${CURSOR_PACK_NC} $(realpath --relative-to="$CURSOR_PACK_REPO_ROOT" "$PACK_JSON" 2>/dev/null || printf '%s' "${PACK_JSON#$CURSOR_PACK_REPO_ROOT/}")"

PACK_README="$(dirname "$PACK_JSON")/README.md"
if [[ -f "$PACK_README" ]] && grep -q '^version:' "$PACK_README"; then
  sed -i '' -E "s/(version:[[:space:]]*)['\"]?[0-9]+\.[0-9]+\.[0-9]+['\"]?/\1\"$NEW_VERSION\"/" "$PACK_README"
  echo -e "  ${CURSOR_PACK_GREEN}updated${CURSOR_PACK_NC} $(realpath --relative-to="$CURSOR_PACK_REPO_ROOT" "$PACK_README" 2>/dev/null || printf '%s' "${PACK_README#$CURSOR_PACK_REPO_ROOT/}")"
else
  echo -e "  ${CURSOR_PACK_YELLOW}skipped${CURSOR_PACK_NC} README.md (no version field in frontmatter)"
fi

echo -e "\n${CURSOR_PACK_GREEN}Done.${CURSOR_PACK_NC} Run ${CURSOR_PACK_BOLD}cursor-pack-verify.sh${CURSOR_PACK_NC} before installing."
