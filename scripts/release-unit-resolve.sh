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
  KIND="$(jq -r '.kind' <<<"$(release_unit_parse_tag "$TAG")")"
  NAME="$(jq -r '.name' <<<"$(release_unit_parse_tag "$TAG")")"
  VERSION="$(jq -r '.version' <<<"$(release_unit_parse_tag "$TAG")")"
fi

[[ -n "$KIND" ]] || release_unit_die "Missing --tag or --kind"
[[ -n "$NAME" ]] || release_unit_die "Missing --name"
[[ -n "$VERSION" ]] || release_unit_die "Missing --version"

release_unit_resolve "$KIND" "$NAME" "$VERSION"
