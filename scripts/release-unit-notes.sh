#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=scripts/release-unit-lib.sh
source "$SCRIPT_DIR/release-unit-lib.sh"

TAG=""
KIND=""
NAME=""
VERSION=""
OUTPUT=""

for arg in "$@"; do
  case "$arg" in
    --tag=*) TAG="${arg#--tag=}" ;;
    --kind=*) KIND="${arg#--kind=}" ;;
    --name=*) NAME="${arg#--name=}" ;;
    --version=*) VERSION="${arg#--version=}" ;;
    --output=*) OUTPUT="${arg#--output=}" ;;
    --help)
      echo "Usage: $0 --tag=skill-foo@1.2.3 [--output=.work/release-assets/release-notes.md]"
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
DESCRIPTION="$(jq -r '.description' <<<"$metadata")"
TARGETS="$(jq -r '.targets | join(", ")' <<<"$metadata")"
ARCHIVE_NAME="$(jq -r '.archiveName' <<<"$metadata")"

notes_path="$OUTPUT"
if [[ -z "$notes_path" ]]; then
  mkdir -p "$RELEASE_UNIT_OUTPUT_ROOT"
  notes_path="$RELEASE_UNIT_OUTPUT_ROOT/$KIND-$NAME-$VERSION-notes.md"
else
  mkdir -p "$(dirname "$notes_path")"
fi

case "$KIND" in
  skill)
    TAGS="$(jq -r '.tags | join(", ")' <<<"$metadata")"
    CHANGELOG_FILE="$RELEASE_UNIT_REPO_ROOT/$SOURCE_REL/CHANGELOG.md"
    CHANGELOG_SECTION=""
    if [[ -f "$CHANGELOG_FILE" ]]; then
      CHANGELOG_SECTION="$(release_unit_latest_changelog_section "$CHANGELOG_FILE" "$VERSION")"
    fi

    cat >"$notes_path" <<EOF
# $NAME v$VERSION

$DESCRIPTION

## Release Unit

- Type: skill
- Tag: \`skill-$NAME@$VERSION\`
- Source path: \`$SOURCE_REL\`
- Targets: $TARGETS
- Registry version: \`$VERSION\`

## Notes

This release publishes the current contents of \`$SOURCE_REL\` as an
independent skill release for the repository registry.

## Changes

EOF

    if [[ -n "$CHANGELOG_SECTION" ]]; then
      printf '%s\n' "$CHANGELOG_SECTION" >>"$notes_path"
    else
      cat >>"$notes_path" <<EOF
This skill currently uses the lightweight release-note path. If the skill later
adds a local \`CHANGELOG.md\`, matching version entries will automatically be
included in future GitHub Releases.
EOF
    fi

    cat >>"$notes_path" <<EOF

## Metadata

- Tags: ${TAGS:-none}
- Archive asset: \`$ARCHIVE_NAME\`

## Validation

- \`bash scripts/skill-sync.sh --skill=$NAME --dry-run\`
- confirm \`metadata.json\` and \`skill-registry.json\` versions match the tag
- if \`SKILL.md\` declares \`version:\`, confirm it matches the tag
EOF
    ;;
  pack)
    PROFILES="$(jq -r '.profiles | join(", ")' <<<"$metadata")"
    CHANGELOG_FILE="$RELEASE_UNIT_REPO_ROOT/$SOURCE_REL/CHANGELOG.md"
    CHANGELOG_SECTION=""
    if [[ -f "$CHANGELOG_FILE" ]]; then
      CHANGELOG_SECTION="$(release_unit_latest_changelog_section "$CHANGELOG_FILE" "$VERSION")"
    fi

    cat >"$notes_path" <<EOF
# $NAME v$VERSION

$DESCRIPTION

## Release Unit

- Type: Cursor pack
- Tag: \`pack-$NAME@$VERSION\`
- Source path: \`$SOURCE_REL\`
- Targets: $TARGETS
- Profiles: $PROFILES
- Archive asset: \`$ARCHIVE_NAME\`

## Changes

EOF

    if [[ -n "$CHANGELOG_SECTION" ]]; then
      printf '%s\n' "$CHANGELOG_SECTION" >>"$notes_path"
    else
      cat >>"$notes_path" <<EOF
This release packages the current contents of \`$SOURCE_REL\` as a
module-scoped GitHub Release. No matching changelog section for \`$VERSION\`
was found in \`CHANGELOG.md\`, so maintainers should update that file before
tagging future releases.
EOF
    fi

    cat >>"$notes_path" <<EOF

## Verification

- \`bash scripts/cursor-pack-verify.sh --pack=$NAME\`
- dry-run installs for the supported target/profile combinations in \`pack.json\`
- see \`$SOURCE_REL/VERIFICATION.md\` for committed verification evidence
EOF
    ;;
  *)
    release_unit_die "Unsupported release unit kind: $KIND"
    ;;
esac

echo "$notes_path"
