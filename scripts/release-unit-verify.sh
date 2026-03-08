#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=scripts/release-unit-lib.sh
source "$SCRIPT_DIR/release-unit-lib.sh"

TAG=""
KIND=""
NAME=""
VERSION=""

for arg in "$@"; do
  case "$arg" in
    --tag=*) TAG="${arg#--tag=}" ;;
    --kind=*) KIND="${arg#--kind=}" ;;
    --name=*) NAME="${arg#--name=}" ;;
    --version=*) VERSION="${arg#--version=}" ;;
    --help)
      echo "Usage: $0 --tag=skill-foo@1.2.3 | --kind=skill|pack --name=foo --version=1.2.3"
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
REGISTRY_VERSION="$(jq -r '.registryVersion' <<<"$metadata")"

[[ "$REGISTRY_VERSION" == "$VERSION" ]] || release_unit_die "Registry version '$REGISTRY_VERSION' does not match tag version '$VERSION'"
release_unit_require_dir "$SOURCE_ABS"

case "$KIND" in
  skill)
    SKILL_MD="$SOURCE_ABS/SKILL.md"
    METADATA_FILE="$SOURCE_ABS/metadata.json"
    if [[ ! -f "$METADATA_FILE" ]]; then
      METADATA_FILE="$SOURCE_ABS/assets/metadata.json"
    fi

    release_unit_require_file "$SKILL_MD"
    release_unit_require_file "$METADATA_FILE"

    metadata_version="$(jq -r '.version' "$METADATA_FILE")"
    [[ "$metadata_version" == "$VERSION" ]] || release_unit_die "Skill metadata version '$metadata_version' does not match tag version '$VERSION'"

    skill_frontmatter="$(awk '/^---$/ { n++; next } n==1 { print }' "$SKILL_MD")"
    if printf '%s\n' "$skill_frontmatter" | rg -q '^version:'; then
      skill_md_version="$(printf '%s\n' "$skill_frontmatter" | awk -F': *' '/^version:/{gsub(/["'\'']/, "", $2); print $2; exit}')"
      [[ "$skill_md_version" == "$VERSION" ]] || release_unit_die "SKILL.md version '$skill_md_version' does not match tag version '$VERSION'"
    fi

    skill_sync_output="$(bash "$SCRIPT_DIR/skill-sync.sh" --skill="$NAME" --dry-run 2>&1 || true)"
    if rg -q 'SKIP|Unknown option|source not found|Errors:' <<<"$skill_sync_output"; then
      printf '%s\n' "$skill_sync_output" >&2
      release_unit_die "Skill dry-run sync failed for '$NAME'"
    fi
    ;;
  pack)
    PACK_JSON="$SOURCE_ABS/pack.json"
    release_unit_require_file "$PACK_JSON"

    pack_version="$(jq -r '.version' "$PACK_JSON")"
    [[ "$pack_version" == "$VERSION" ]] || release_unit_die "pack.json version '$pack_version' does not match tag version '$VERSION'"

    bash "$SCRIPT_DIR/cursor-pack-verify.sh" --pack="$NAME" >/dev/null

    while IFS= read -r target; do
      while IFS= read -r profile; do
        artifact_count="$(jq -r --arg target "$target" --arg profile "$profile" '
          [.artifacts[]
           | select((.targets | index($target)) != null)
           | select((.profiles | index($profile)) != null)] | length
        ' "$PACK_JSON")"

        if [[ "$artifact_count" == "0" ]]; then
          continue
        fi

        case "$target" in
          project-cursor)
            bash "$SCRIPT_DIR/cursor-pack-sync.sh" \
              --pack="$NAME" \
              --target=project \
              --project-root="$RELEASE_UNIT_REPO_ROOT" \
              --profile="$profile" \
              --dry-run >/dev/null
            ;;
          user-cursor)
            bash "$SCRIPT_DIR/cursor-pack-sync.sh" \
              --pack="$NAME" \
              --target=user \
              --profile="$profile" \
              --dry-run >/dev/null
            ;;
          *)
            release_unit_die "Unsupported pack target during verification: $target"
            ;;
        esac
      done < <(jq -r '.profiles | keys[]' "$PACK_JSON")
    done < <(jq -r '.targets[]' "$PACK_JSON")
    ;;
  *)
    release_unit_die "Unsupported release unit kind: $KIND"
    ;;
esac

echo "verified"
