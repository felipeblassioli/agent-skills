#!/usr/bin/env bash
# Usage: scripts/release-skill.sh <skill-directory> [--dry-run]
#
# Creates a GitHub Release for a single skill. The release tag is
# "<skill-name>/v<version>" where:
#   - <skill-name> is "<plugin>-<skill>" for a plugin skill
#     (plugins/<plugin>/skills/<skill>), or the bare folder name for a legacy
#     top-level skill (skills/<skill>). Qualifying plugin skills keeps tags
#     collision-free across plugins.
#   - <version>    is metadata.json .version
#
# Steps:
#   1. Validate the skill package with scripts/validate-skill.sh.
#   2. Extract the matching CHANGELOG.md section.
#   3. Skip if the tag already exists on the remote (idempotent).
#   4. Create the GitHub Release pinned to the current HEAD commit.
#
# Requires: gh, jq. Must be authenticated with push permission on the
# felipeblassioli/agent-skills repository.

set -euo pipefail

SKILL_DIR="${1:?Usage: release-skill.sh <skill-directory> [--dry-run]}"
SKILL_DIR="${SKILL_DIR%/}"
DRY_RUN="${2:-}"

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Qualify a plugin skill as "<plugin>-<skill>" (collision-free across plugins);
# a legacy top-level skill keeps its basename.
case "$SKILL_DIR" in
  plugins/*/skills/*)
    SKILL_NAME="$(basename "$(dirname "$(dirname "$SKILL_DIR")")")-$(basename "$SKILL_DIR")"
    ;;
  *)
    SKILL_NAME="$(basename "$SKILL_DIR")"
    ;;
esac

METADATA_FILE="$REPO_ROOT/$SKILL_DIR/metadata.json"
CHANGELOG_FILE="$REPO_ROOT/$SKILL_DIR/CHANGELOG.md"

for cmd in gh jq; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "release-skill: required command not found: $cmd" >&2
    exit 1
  fi
done

if [[ ! -f "$METADATA_FILE" ]]; then
  echo "release-skill: metadata.json not found at $METADATA_FILE" >&2
  exit 1
fi

VERSION="$(jq -r '.version' "$METADATA_FILE")"
if [[ -z "$VERSION" || "$VERSION" == "null" ]]; then
  echo "release-skill: metadata.json is missing .version" >&2
  exit 1
fi

TAG="$SKILL_NAME/v$VERSION"
TITLE="$SKILL_NAME v$VERSION"

# Step 1: validate the package before tagging.
if ! bash "$REPO_ROOT/scripts/validate-skill.sh" "$SKILL_DIR" >/tmp/validate-skill.json; then
  cat /tmp/validate-skill.json >&2
  echo "release-skill: validation failed for $SKILL_DIR" >&2
  exit 1
fi
if [[ "$(jq -r '.pass' /tmp/validate-skill.json)" != "true" ]]; then
  cat /tmp/validate-skill.json >&2
  echo "release-skill: validation reported failure for $SKILL_DIR" >&2
  exit 1
fi

# Step 2: extract release notes for this version.
NOTES_FILE="$(mktemp)"
trap 'rm -f "$NOTES_FILE" /tmp/validate-skill.json' EXIT

if ! bash "$REPO_ROOT/scripts/extract-changelog.sh" "$CHANGELOG_FILE" "$VERSION" >"$NOTES_FILE"; then
  echo "release-skill: no CHANGELOG.md section found for version $VERSION in $CHANGELOG_FILE" >&2
  exit 1
fi
if [[ ! -s "$NOTES_FILE" ]]; then
  echo "release-skill: extracted release notes are empty for $TAG" >&2
  exit 1
fi

# Step 3: idempotency. If the tag already exists upstream, skip.
if gh release view "$TAG" >/dev/null 2>&1; then
  echo "release-skill: release already exists for $TAG, skipping"
  exit 0
fi

if [[ "$DRY_RUN" == "--dry-run" ]]; then
  echo "release-skill: dry run for $TAG"
  echo "---"
  cat "$NOTES_FILE"
  echo "---"
  exit 0
fi

# Step 4: create the release pinned to the current HEAD commit on main.
TARGET_SHA="$(git -C "$REPO_ROOT" rev-parse HEAD)"

gh release create "$TAG" \
  --title "$TITLE" \
  --notes-file "$NOTES_FILE" \
  --target "$TARGET_SHA"

echo "release-skill: published $TAG at $TARGET_SHA"
