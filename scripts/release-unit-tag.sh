#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=scripts/release-unit-lib.sh
source "$SCRIPT_DIR/release-unit-lib.sh"

KIND=""
NAME=""
VERSION=""
REMOTE="origin"
PUSH=false
ALLOW_DIRTY=false
DRY_RUN=false

for arg in "$@"; do
  case "$arg" in
    --skill=*)
      KIND="skill"
      NAME="${arg#--skill=}"
      ;;
    --pack=*)
      KIND="pack"
      NAME="${arg#--pack=}"
      ;;
    --version=*)
      VERSION="${arg#--version=}"
      ;;
    --remote=*)
      REMOTE="${arg#--remote=}"
      ;;
    --push)
      PUSH=true
      ;;
    --dry-run)
      DRY_RUN=true
      ;;
    --allow-dirty)
      ALLOW_DIRTY=true
      ;;
    --help)
      echo "Usage: $0 (--skill=NAME | --pack=NAME) [--version=X.Y.Z] [--push] [--remote=origin] [--dry-run] [--allow-dirty]"
      exit 0
      ;;
    *)
      release_unit_die "Unknown option: $arg"
      ;;
  esac
done

[[ -n "$KIND" ]] || release_unit_die "Pass exactly one of --skill or --pack"
[[ -n "$NAME" ]] || release_unit_die "Release unit name is required"

if [[ "$ALLOW_DIRTY" == false ]]; then
  status_output="$(git -C "$RELEASE_UNIT_REPO_ROOT" status --short)"
  if [[ -n "$status_output" ]]; then
    printf '%s\n' "$status_output" >&2
    release_unit_die "Working tree is not clean. Commit or stash changes before tagging, or pass --allow-dirty."
  fi
fi

if [[ -z "$VERSION" ]]; then
  case "$KIND" in
    skill)
      VERSION="$(jq -r --arg skill "$NAME" '.skills[$skill].version // empty' "$RELEASE_UNIT_SKILL_REGISTRY")"
      ;;
    pack)
      VERSION="$(jq -r --arg pack "$NAME" '.packs[$pack].version // empty' "$RELEASE_UNIT_PACK_REGISTRY")"
      ;;
  esac
fi

[[ -n "$VERSION" ]] || release_unit_die "Could not resolve version for $KIND '$NAME'"

metadata="$(release_unit_resolve "$KIND" "$NAME" "$VERSION")"
tag_prefix="$KIND"
tag_name="$tag_prefix-$NAME@$VERSION"

bash "$SCRIPT_DIR/release-unit-verify.sh" --kind="$KIND" --name="$NAME" --version="$VERSION" >/dev/null

if git -C "$RELEASE_UNIT_REPO_ROOT" rev-parse "$tag_name" >/dev/null 2>&1; then
  release_unit_die "Tag already exists locally: $tag_name"
fi

if [[ "$DRY_RUN" == true ]]; then
  printf 'Would create tag %s\n' "$tag_name"
  if [[ "$PUSH" == true ]]; then
    printf 'Would push tag %s to %s\n' "$tag_name" "$REMOTE"
  fi
  exit 0
fi

git -C "$RELEASE_UNIT_REPO_ROOT" tag -a "$tag_name" -m "Release $tag_name"
printf 'Created tag %s\n' "$tag_name"

if [[ "$PUSH" == true ]]; then
  git -C "$RELEASE_UNIT_REPO_ROOT" push "$REMOTE" "$tag_name"
  printf 'Pushed tag %s to %s\n' "$tag_name" "$REMOTE"
fi
