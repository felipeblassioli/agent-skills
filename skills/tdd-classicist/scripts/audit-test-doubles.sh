#!/bin/bash
set -e

# audit-test-doubles.sh — Scan test files for mock/spy usage and flag overuse.
# Outputs JSON to stdout, status messages to stderr.
#
# Usage: bash scripts/audit-test-doubles.sh [PROJECT_ROOT]

PROJECT_ROOT="${1:-.}"

echo "Scanning test files in: $PROJECT_ROOT" >&2

# Find all test files
test_files=$(find "$PROJECT_ROOT" \
  -type f \( -name "*.test.ts" -o -name "*.test.tsx" -o -name "*.spec.ts" -o -name "*.spec.tsx" \) \
  ! -path "*/node_modules/*" \
  ! -path "*/.cursor/*" \
  2>/dev/null | sort)

total_files=$(echo "$test_files" | grep -c '.' 2>/dev/null || echo "0")
files_with_mocks=0

# Build JSON array
json_entries=""

while IFS= read -r file; do
  [ -z "$file" ] && continue

  # Count patterns
  vi_fn=$(grep -c 'vi\.fn\b' "$file" 2>/dev/null || echo "0")
  vi_spyOn=$(grep -c 'vi\.spyOn\b' "$file" 2>/dev/null || echo "0")
  vi_mock=$(grep -c 'vi\.mock\b' "$file" 2>/dev/null || echo "0")
  jest_fn=$(grep -c 'jest\.fn\b' "$file" 2>/dev/null || echo "0")
  jest_spyOn=$(grep -c 'jest\.spyOn\b' "$file" 2>/dev/null || echo "0")
  jest_mock=$(grep -c 'jest\.mock\b' "$file" 2>/dev/null || echo "0")

  total_doubles=$((vi_fn + vi_spyOn + vi_mock + jest_fn + jest_spyOn + jest_mock))

  [ "$total_doubles" -eq 0 ] && continue

  files_with_mocks=$((files_with_mocks + 1))

  # Determine flag
  if [ "$total_doubles" -le 2 ]; then
    flag="ok"
  elif [ "$total_doubles" -le 5 ]; then
    flag="review"
  else
    flag="warning"
  fi

  # Strip project root prefix for cleaner paths
  rel_file="${file#"$PROJECT_ROOT"/}"

  entry=$(cat <<ENTRY
    {"file":"$rel_file","vi_fn":$vi_fn,"vi_spyOn":$vi_spyOn,"vi_mock":$vi_mock,"jest_fn":$jest_fn,"jest_spyOn":$jest_spyOn,"jest_mock":$jest_mock,"total_doubles":$total_doubles,"flag":"$flag"}
ENTRY
  )

  if [ -z "$json_entries" ]; then
    json_entries="$entry"
  else
    json_entries="$json_entries,$entry"
  fi
done <<< "$test_files"

echo "Done. Scanned $total_files files, $files_with_mocks contain test doubles." >&2

# Output JSON
cat <<EOF
{
  "total_files_scanned": $total_files,
  "files_with_mocks": $files_with_mocks,
  "summary": [$json_entries]
}
EOF
