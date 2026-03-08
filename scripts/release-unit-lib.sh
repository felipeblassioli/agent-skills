#!/usr/bin/env bash
set -euo pipefail

RELEASE_UNIT_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RELEASE_UNIT_REPO_ROOT="$(cd "$RELEASE_UNIT_LIB_DIR/.." && pwd)"
RELEASE_UNIT_SKILL_REGISTRY="$RELEASE_UNIT_REPO_ROOT/skill-registry.json"
RELEASE_UNIT_PACK_REGISTRY="$RELEASE_UNIT_REPO_ROOT/cursor-pack-registry.json"
RELEASE_UNIT_OUTPUT_ROOT="$RELEASE_UNIT_REPO_ROOT/.work/release-assets"

release_unit_die() {
  echo "$*" >&2
  exit 1
}

release_unit_require_file() {
  local path="$1"
  [[ -f "$path" ]] || release_unit_die "Required file not found: $path"
}

release_unit_require_dir() {
  local path="$1"
  [[ -d "$path" ]] || release_unit_die "Required directory not found: $path"
}

release_unit_assert_semver() {
  local version="$1"
  [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || release_unit_die "Invalid semver version: $version"
}

release_unit_parse_tag() {
  local tag="$1"
  local kind name version

  case "$tag" in
    skill-*@*)
      kind="skill"
      name="${tag#skill-}"
      name="${name%@*}"
      version="${tag##*@}"
      ;;
    pack-*@*)
      kind="pack"
      name="${tag#pack-}"
      name="${name%@*}"
      version="${tag##*@}"
      ;;
    *)
      release_unit_die "Unsupported release tag: $tag"
      ;;
  esac

  [[ -n "$name" ]] || release_unit_die "Release tag is missing a name: $tag"
  release_unit_assert_semver "$version"

  jq -n \
    --arg tag "$tag" \
    --arg kind "$kind" \
    --arg name "$name" \
    --arg version "$version" \
    '{tag: $tag, kind: $kind, name: $name, version: $version}'
}

release_unit_skill_source_rel() {
  local skill_name="$1"
  local custom_path
  custom_path=$(jq -r --arg skill "$skill_name" '.skills[$skill].path // empty' "$RELEASE_UNIT_SKILL_REGISTRY")
  if [[ -n "$custom_path" ]]; then
    echo "skills/$custom_path"
  else
    echo "skills/$skill_name"
  fi
}

release_unit_pack_source_rel() {
  local pack_name="$1"
  jq -r --arg pack "$pack_name" '.packs[$pack].path // empty' "$RELEASE_UNIT_PACK_REGISTRY"
}

release_unit_resolve() {
  local kind="$1"
  local name="$2"
  local version="$3"
  local source_rel description registry_version title archive_name

  release_unit_assert_semver "$version"
  release_unit_require_file "$RELEASE_UNIT_SKILL_REGISTRY"
  release_unit_require_file "$RELEASE_UNIT_PACK_REGISTRY"

  case "$kind" in
    skill)
      jq -e --arg skill "$name" '.skills[$skill] != null' "$RELEASE_UNIT_SKILL_REGISTRY" >/dev/null \
        || release_unit_die "Skill '$name' not found in skill-registry.json"
      source_rel="$(release_unit_skill_source_rel "$name")"
      description="$(jq -r --arg skill "$name" '.skills[$skill].description' "$RELEASE_UNIT_SKILL_REGISTRY")"
      registry_version="$(jq -r --arg skill "$name" '.skills[$skill].version' "$RELEASE_UNIT_SKILL_REGISTRY")"
      title="Skill $name v$version"
      archive_name="skill-$name-$version.tar.gz"
      jq -n \
        --arg kind "$kind" \
        --arg name "$name" \
        --arg version "$version" \
        --arg sourceRel "$source_rel" \
        --arg title "$title" \
        --arg archiveName "$archive_name" \
        --arg description "$description" \
        --arg registryVersion "$registry_version" \
        --argjson targets "$(jq --arg skill "$name" '.skills[$skill].targets' "$RELEASE_UNIT_SKILL_REGISTRY")" \
        --argjson tags "$(jq --arg skill "$name" '.skills[$skill].tags // []' "$RELEASE_UNIT_SKILL_REGISTRY")" \
        '{
          kind: $kind,
          name: $name,
          version: $version,
          sourceRel: $sourceRel,
          title: $title,
          archiveName: $archiveName,
          description: $description,
          registryVersion: $registryVersion,
          targets: $targets,
          tags: $tags
        }'
      ;;
    pack)
      jq -e --arg pack "$name" '.packs[$pack] != null' "$RELEASE_UNIT_PACK_REGISTRY" >/dev/null \
        || release_unit_die "Pack '$name' not found in cursor-pack-registry.json"
      source_rel="$(release_unit_pack_source_rel "$name")"
      release_unit_require_file "$RELEASE_UNIT_REPO_ROOT/$source_rel/pack.json"
      description="$(jq -r --arg pack "$name" '.packs[$pack].description' "$RELEASE_UNIT_PACK_REGISTRY")"
      registry_version="$(jq -r --arg pack "$name" '.packs[$pack].version' "$RELEASE_UNIT_PACK_REGISTRY")"
      title="Pack $name v$version"
      archive_name="pack-$name-$version.tar.gz"
      jq -n \
        --arg kind "$kind" \
        --arg name "$name" \
        --arg version "$version" \
        --arg sourceRel "$source_rel" \
        --arg title "$title" \
        --arg archiveName "$archive_name" \
        --arg description "$description" \
        --arg registryVersion "$registry_version" \
        --argjson targets "$(jq --arg pack "$name" '.packs[$pack].targets' "$RELEASE_UNIT_PACK_REGISTRY")" \
        --argjson profiles "$(jq -c '.profiles | keys' "$RELEASE_UNIT_REPO_ROOT/$source_rel/pack.json")" \
        '{
          kind: $kind,
          name: $name,
          version: $version,
          sourceRel: $sourceRel,
          title: $title,
          archiveName: $archiveName,
          description: $description,
          registryVersion: $registryVersion,
          targets: $targets,
          profiles: $profiles
        }'
      ;;
    *)
      release_unit_die "Unsupported release unit kind: $kind"
      ;;
  esac
}

release_unit_latest_changelog_section() {
  local changelog_file="$1"
  local version="$2"

  awk -v version="$version" '
    $0 ~ "^## " version "([[:space:]-]|$)" {
      in_section = 1
      print
      next
    }
    in_section && $0 ~ "^## " {
      exit
    }
    in_section {
      print
    }
  ' "$changelog_file"
}
