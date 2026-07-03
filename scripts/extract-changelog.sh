#!/usr/bin/env bash
# Usage: scripts/extract-changelog.sh <changelog-file> <version>
#
# Prints the body of the changelog section for <version> to stdout. The body
# spans from the line *after* the matching "## <version> - <date>" heading up
# to (but not including) the next "## " heading or end of file.
#
# Exits non-zero if the section is not found.

set -euo pipefail

CHANGELOG_FILE="${1:?Usage: extract-changelog.sh <changelog-file> <version>}"
VERSION="${2:?Usage: extract-changelog.sh <changelog-file> <version>}"

if [[ ! -f "$CHANGELOG_FILE" ]]; then
  echo "extract-changelog: file not found: $CHANGELOG_FILE" >&2
  exit 1
fi

awk -v target="$VERSION" '
  BEGIN { in_section = 0; found = 0 }
  /^##[[:space:]]/ {
    if (in_section) { exit }
    # Match "## <version>" optionally followed by " - <date>" or whitespace.
    header = $0
    sub(/^##[[:space:]]+/, "", header)
    split(header, parts, /[[:space:]]+-[[:space:]]+/)
    if (parts[1] == target) {
      in_section = 1
      found = 1
      next
    }
  }
  in_section { print }
  END { if (!found) { exit 2 } }
' "$CHANGELOG_FILE" | awk '
  # Trim leading and trailing blank lines without buffering the whole file
  # twice for nothing.
  /^$/ { if (!seen) next; blanks = blanks $0 "\n"; next }
  { if (blanks) { printf "%s", blanks; blanks = "" } seen = 1; print }
'
