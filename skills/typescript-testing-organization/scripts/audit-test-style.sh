#!/bin/bash
set -e

# audit-test-style.sh — Enforce tier-aligned TS test style rules.
# Outputs JSON to stdout, status messages to stderr.
#
# Enforced rules (non-classifying):
# - Unit + boundary integration tests MUST use `test()` (not `it()`)
# - Unit + boundary integration test titles MUST NOT start with "should"
#
# Usage: bash scripts/audit-test-style.sh [PROJECT_ROOT]

PROJECT_ROOT="${1:-.}"

echo "Auditing TS test style in: $PROJECT_ROOT" >&2

violations=""
violation_count=0
files_scanned=0

append_violation() {
  local entry="$1"
  if [ -z "$violations" ]; then
    violations="$entry"
  else
    violations="$violations,$entry"
  fi
}

# Collect unit tests (src/**/*.spec.ts?(x), excluding tiered suffixes)
unit_files=$(find "$PROJECT_ROOT/src" -type f \( -name "*.spec.ts" -o -name "*.spec.tsx" \) \
  ! -name "*.int.spec.ts" ! -name "*.int.spec.tsx" \
  ! -name "*.func.spec.ts" ! -name "*.func.spec.tsx" \
  ! -name "*.contract.spec.ts" ! -name "*.contract.spec.tsx" \
  ! -name "*.e2e.spec.ts" ! -name "*.e2e.spec.tsx" \
  ! -path "*/node_modules/*" 2>/dev/null || true)

# Collect boundary integration tests (test/integration/**/*.int.spec.ts?(x))
integration_files=$(find "$PROJECT_ROOT/test/integration" -type f \( -name "*.int.spec.ts" -o -name "*.int.spec.tsx" \) \
  ! -path "*/node_modules/*" 2>/dev/null || true)

all_files=$(printf "%s\n%s\n" "$unit_files" "$integration_files" | sed '/^$/d' | sort -u)

while IFS= read -r file; do
  [ -z "$file" ] && continue
  files_scanned=$((files_scanned + 1))
  rel_file="${file#"$PROJECT_ROOT"/}"

  # Rule: disallow it()
  # Match: it(, it.concurrent(, it.only(, it.skip(
  it_matches=$(grep -nE '(^|[^A-Za-z0-9_])it(\.concurrent|\.only|\.skip)?[[:space:]]*\(' "$file" 2>/dev/null || true)
  if [ -n "$it_matches" ]; then
    first_line=$(echo "$it_matches" | head -n 1 | cut -d: -f1)
    violation_count=$((violation_count + 1))
    append_violation "{\"rule\":\"unit-and-boundary-use-test\",\"file\":\"$rel_file\",\"line\":$first_line,\"message\":\"Uses it(); unit + boundary integration must use test()\"}"
  fi

  # Rule: disallow titles starting with "should" in test()
  should_matches=$(grep -nE "(^|[^A-Za-z0-9_])test[[:space:]]*\\([[:space:]]*([\"'\`])should([^A-Za-z0-9_]|$)" "$file" 2>/dev/null || true)
  if [ -n "$should_matches" ]; then
    first_line=$(echo "$should_matches" | head -n 1 | cut -d: -f1)
    violation_count=$((violation_count + 1))
    append_violation "{\"rule\":\"no-should-titles\",\"file\":\"$rel_file\",\"line\":$first_line,\"message\":\"Test title starts with should\"}"
  fi
done <<< "$all_files"

echo "Done. Scanned $files_scanned files, found $violation_count violations." >&2

cat <<EOF
{
  "project_root": "$PROJECT_ROOT",
  "files_scanned": $files_scanned,
  "violation_count": $violation_count,
  "violations": [$violations]
}
EOF

