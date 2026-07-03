#!/usr/bin/env bash
# Usage: scripts/release-plugin.sh <plugin-directory> [--dry-run]
#
# Creates a GitHub Release for a whole Bond plugin and attaches a distributable
# plugin .zip. The release tag is "<name>--v<version>" where:
#   - <name>    is plugin.json .name
#   - <version> is plugin.json .version
# This matches the tag format of `claude plugin tag` (the native CLI), and does
# NOT collide with the skill release scheme "<skill-name>/v<version>" (different
# separator: "--v" vs "/v").
#
# Steps:
#   1. Validate the plugin manifest with `claude plugin validate --strict`.
#   2. Validate that plugin.json agrees with its marketplace.json entry, via
#      `claude plugin tag --dry-run` (the native consistency check).
#   3. Extract release notes (plugin CHANGELOG.md section, or a generated
#      inventory of the bundled skills if the plugin has no CHANGELOG yet).
#   4. Skip if the release already exists on the remote (idempotent).
#   5. Build the plugin .zip (plugin root at the zip root; evals/ and .work/
#      excluded).
#   6. Create the GitHub Release pinned to the current HEAD commit, with the
#      .zip attached as an asset.
#
# IMPORTANT — what the .zip is for: Claude Code cannot *persistently* install a
# plugin from a .zip. `claude plugin install` and `marketplace.json` sources
# accept only git/path/GitHub. The .zip is a convenience artifact for ephemeral,
# session-scoped loads (`claude --plugin-url <release-asset>.zip` /
# `--plugin-dir <file>.zip`) and offline use. The persistent install channel
# remains the git marketplace. See docs/releasing.md.
#
# The release tag is created by `gh release create` (server-side, via the API
# token) rather than `claude plugin tag --push`, because CI checks out with
# `persist-credentials: false` and cannot `git push` a tag — `gh` can. The tag
# string is identical to what `claude plugin tag` would produce, and step 2
# runs the native agreement check.
#
# Requires: gh, jq, zip, git, claude. Must be authenticated with push
# permission on the felipeblassioli/agent-skills repository.

set -euo pipefail

PLUGIN_DIR="${1:?Usage: release-plugin.sh <plugin-directory> [--dry-run]}"
PLUGIN_DIR="${PLUGIN_DIR%/}"
DRY_RUN="${2:-}"

# Guard against `release-plugin.sh --dry-run` (plugin dir omitted): the flag
# would otherwise be taken as the plugin directory and fail confusingly later.
if [[ "$PLUGIN_DIR" == --* ]]; then
  echo "release-plugin: first argument must be a plugin directory, got '$PLUGIN_DIR'" >&2
  exit 1
fi

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MANIFEST_FILE="$REPO_ROOT/$PLUGIN_DIR/.claude-plugin/plugin.json"
CHANGELOG_FILE="$REPO_ROOT/$PLUGIN_DIR/CHANGELOG.md"

# Target every `gh` call at this repository explicitly, so the release lands on
# felipeblassioli/agent-skills regardless of the caller's working directory (gh otherwise
# infers the repo from cwd). Derived from origin; gh honors $GH_REPO.
ORIGIN_URL="$(git -C "$REPO_ROOT" config --get remote.origin.url || true)"
REPO_SLUG="$(printf '%s' "$ORIGIN_URL" | sed -E 's#^.*github\.com[:/]##; s#\.git$##')"
if [[ -n "$REPO_SLUG" ]]; then
  export GH_REPO="$REPO_SLUG"
fi

for cmd in gh jq zip git claude; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "release-plugin: required command not found: $cmd" >&2
    exit 1
  fi
done

if [[ ! -f "$MANIFEST_FILE" ]]; then
  echo "release-plugin: plugin.json not found at $MANIFEST_FILE" >&2
  exit 1
fi

NAME="$(jq -r '.name' "$MANIFEST_FILE")"
VERSION="$(jq -r '.version' "$MANIFEST_FILE")"
for field in NAME VERSION; do
  if [[ -z "${!field}" || "${!field}" == "null" ]]; then
    echo "release-plugin: plugin.json is missing .$(printf '%s' "$field" | tr '[:upper:]' '[:lower:]')" >&2
    exit 1
  fi
done

TAG="$NAME--v$VERSION"
TITLE="$NAME v$VERSION"

# Step 1: validate the plugin manifest (the package validator does not cover
# manifests — this is the only gate that does).
if ! claude plugin validate "$REPO_ROOT/$PLUGIN_DIR" --strict; then
  echo "release-plugin: 'claude plugin validate --strict' failed for $PLUGIN_DIR" >&2
  exit 1
fi

# Step 2: confirm plugin.json agrees with its marketplace.json entry. The native
# tag command performs exactly this check. `--force` skips its own dirty-tree
# and tag-exists checks so this stays a *pure* agreement gate — the script owns
# dirty-tree refusal (below) and the tag-state check (idempotency).
if ! claude plugin tag "$REPO_ROOT/$PLUGIN_DIR" --dry-run --force >/dev/null 2>&1; then
  echo "release-plugin: plugin.json does not agree with its marketplace.json entry for $PLUGIN_DIR" >&2
  claude plugin tag "$REPO_ROOT/$PLUGIN_DIR" --dry-run --force >&2 || true
  exit 1
fi

# Step 3: release notes. Prefer a plugin-level CHANGELOG section; otherwise
# generate an inventory of the bundled skills so the release is never empty.
NOTES_FILE="$(mktemp)"
ZIP_DIR="$(mktemp -d)"
ZIP_FILE="$ZIP_DIR/$NAME.zip"
trap 'rm -rf "$NOTES_FILE" "$ZIP_DIR"' EXIT

if [[ -f "$CHANGELOG_FILE" ]] \
   && bash "$REPO_ROOT/scripts/extract-changelog.sh" "$CHANGELOG_FILE" "$VERSION" >"$NOTES_FILE" \
   && [[ -s "$NOTES_FILE" ]]; then
  : # used the plugin CHANGELOG section
else
  {
    echo "Release of the **$NAME** plugin, version $VERSION."
    echo
    if compgen -G "$REPO_ROOT/$PLUGIN_DIR/skills/*/metadata.json" >/dev/null; then
      echo "Bundled skills:"
      for meta in "$REPO_ROOT/$PLUGIN_DIR"/skills/*/metadata.json; do
        skill="$(basename "$(dirname "$meta")")"
        sver="$(jq -r '.version // "?"' "$meta")"
        echo "- \`$skill\` v$sver"
      done
      echo
    fi
    echo "Install via the git marketplace (\`/plugin marketplace update\`); the"
    echo "attached .zip is for ephemeral \`--plugin-url\` / \`--plugin-dir\` loads only."
  } >"$NOTES_FILE"
fi

# Step 4: idempotency. If the release already exists upstream, skip.
if gh release view "$TAG" >/dev/null 2>&1; then
  echo "release-plugin: release already exists for $TAG, skipping"
  exit 0
fi

# Step 5: build the plugin .zip — plugin root at the zip root, excluding the
# evals suite and any scratch .work/ at any depth (no value to consumers).
build_zip() {
  ( cd "$REPO_ROOT/$PLUGIN_DIR" \
      && zip -rq "$ZIP_FILE" . -x 'evals/*' '*/evals/*' '.work/*' '*/.work/*' )
}

if [[ "$DRY_RUN" == "--dry-run" ]]; then
  build_zip
  echo "release-plugin: dry run for $TAG"
  echo "  zip:  $ZIP_FILE ($(du -h "$ZIP_FILE" | cut -f1))"
  echo "  notes:"
  echo "---"
  cat "$NOTES_FILE"
  echo "---"
  exit 0
fi

# Refuse to publish from a dirty tree BEFORE building the artifact: the zip is
# built from the working tree, so uncommitted changes would ship in an artifact
# tagged at HEAD. (CI checks out clean; this guard protects manual runs.)
if [[ -n "$(git -C "$REPO_ROOT" status --porcelain)" ]]; then
  echo "release-plugin: working tree is not clean; commit or stash before releasing $TAG" >&2
  exit 1
fi

# A tag without a release means a previous run half-failed (or someone ran
# `claude plugin tag --push`). Refuse, rather than let `gh release create` reuse
# the stale tag and silently pin the release to its commit (gh ignores --target
# when the tag already exists).
if git -C "$REPO_ROOT" ls-remote --exit-code --tags origin "refs/tags/$TAG" >/dev/null 2>&1; then
  echo "release-plugin: tag $TAG exists on the remote but no release does — partial/inconsistent prior run; delete the tag or cut a new version before retrying" >&2
  exit 1
fi

# Step 6: create the release pinned to the current HEAD commit, with the .zip
# attached. gh creates and pushes the tag (server-side) at this SHA.
TARGET_SHA="$(git -C "$REPO_ROOT" rev-parse HEAD)"

build_zip

gh release create "$TAG" \
  --title "$TITLE" \
  --notes-file "$NOTES_FILE" \
  --target "$TARGET_SHA" \
  "$ZIP_FILE"

echo "release-plugin: published $TAG at $TARGET_SHA (asset: $NAME.zip)"
