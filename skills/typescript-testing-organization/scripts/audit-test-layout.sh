#!/bin/bash
set -e

# audit-test-layout.sh — Check TS test suffix + path invariants.
# Outputs JSON to stdout, status messages to stderr.
#
# Usage: bash scripts/audit-test-layout.sh [PROJECT_ROOT]

PROJECT_ROOT="${1:-.}"

echo "Auditing test layout in: $PROJECT_ROOT" >&2

violations=""
violation_count=0

# Violation 1: Higher-tier test files under src/
for pattern in "*.int.spec.ts" "*.int.spec.tsx" \
               "*.func.spec.ts" "*.func.spec.tsx" \
               "*.contract.spec.ts" "*.contract.spec.tsx" \
               "*.e2e.spec.ts" "*.e2e.spec.tsx"; do
  while IFS= read -r file; do
    [ -z "$file" ] && continue
    rel_file="${file#"$PROJECT_ROOT"/}"
    violation_count=$((violation_count + 1))
    entry="{\"rule\":\"no-higher-tier-in-src\",\"file\":\"$rel_file\",\"message\":\"Higher-tier test file found under src/\"}"
    if [ -z "$violations" ]; then
      violations="$entry"
    else
      violations="$violations,$entry"
    fi
  done < <(find "$PROJECT_ROOT/src" -type f -name "$pattern" 2>/dev/null)
done

# Violation 2: .test.ts files (should be .spec.ts)
while IFS= read -r file; do
  [ -z "$file" ] && continue
  rel_file="${file#"$PROJECT_ROOT"/}"
  violation_count=$((violation_count + 1))
  entry="{\"rule\":\"use-spec-suffix\",\"file\":\"$rel_file\",\"message\":\"Uses .test suffix instead of .spec\"}"
  if [ -z "$violations" ]; then
    violations="$entry"
  else
    violations="$violations,$entry"
  fi
done < <(find "$PROJECT_ROOT" \
  -type f \( -name "*.test.ts" -o -name "*.test.tsx" \) \
  ! -path "*/node_modules/*" \
  ! -path "*/.cursor/*" \
  ! -path "*/dist/*" \
  2>/dev/null)

# Violation 3: Unit test files (*.spec.ts without tier prefix) outside src/
# that are not in test/_support/
while IFS= read -r file; do
  [ -z "$file" ] && continue
  # Skip files with tier suffixes (they belong in test/)
  case "$file" in
    *.int.spec.ts|*.func.spec.ts|*.contract.spec.ts|*.e2e.spec.ts) continue ;;
    *.int.spec.tsx|*.func.spec.tsx|*.contract.spec.tsx|*.e2e.spec.tsx) continue ;;
  esac
  # Skip _support files
  case "$file" in
    */_support/*) continue ;;
  esac
  rel_file="${file#"$PROJECT_ROOT"/}"
  violation_count=$((violation_count + 1))
  entry="{\"rule\":\"unit-tests-in-src\",\"file\":\"$rel_file\",\"message\":\"Plain .spec file outside src/ (unit tests should be colocated in src/)\"}"
  if [ -z "$violations" ]; then
    violations="$entry"
  else
    violations="$violations,$entry"
  fi
done < <(find "$PROJECT_ROOT/test" \
  -type f \( -name "*.spec.ts" -o -name "*.spec.tsx" \) \
  2>/dev/null)

echo "Done. Found $violation_count violations." >&2

cat <<EOF
{
  "project_root": "$PROJECT_ROOT",
  "violation_count": $violation_count,
  "violations": [$violations]
}
EOF
