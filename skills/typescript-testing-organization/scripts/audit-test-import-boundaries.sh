#!/bin/bash
set -e

# audit-test-import-boundaries.sh — Check that src/ does not import from test/.
# Outputs JSON to stdout, status messages to stderr.
#
# Usage: bash scripts/audit-test-import-boundaries.sh [PROJECT_ROOT]

PROJECT_ROOT="${1:-.}"

echo "Auditing import boundaries in: $PROJECT_ROOT" >&2

violations=""
violation_count=0

# Rule 1: No imports from test/ inside src/
# Look for import/require statements that reference test/ or ../test/
if [ -d "$PROJECT_ROOT/src" ]; then
  while IFS= read -r file; do
    [ -z "$file" ] && continue

    # Search for import paths containing 'test/' or '../test/' or '../../test/'
    matches=$(grep -n "from ['\"].*test/" "$file" 2>/dev/null || true)
    req_matches=$(grep -n "require(['\"].*test/" "$file" 2>/dev/null || true)

    all_matches="$matches"$'\n'"$req_matches"
    all_matches=$(echo "$all_matches" | grep -v '^$' || true)

    if [ -n "$all_matches" ]; then
      rel_file="${file#"$PROJECT_ROOT"/}"
      while IFS= read -r match_line; do
        [ -z "$match_line" ] && continue
        line_num=$(echo "$match_line" | cut -d: -f1)
        violation_count=$((violation_count + 1))
        entry="{\"rule\":\"no-test-import-in-src\",\"file\":\"$rel_file\",\"line\":$line_num,\"message\":\"src/ file imports from test/\"}"
        if [ -z "$violations" ]; then
          violations="$entry"
        else
          violations="$violations,$entry"
        fi
      done <<< "$all_matches"
    fi
  done < <(find "$PROJECT_ROOT/src" -type f \( -name "*.ts" -o -name "*.tsx" \) \
    ! -name "*.spec.ts" ! -name "*.spec.tsx" \
    ! -name "*.test.ts" ! -name "*.test.tsx" \
    ! -path "*/node_modules/*" \
    2>/dev/null)
fi

# Rule 2: No infrastructure imports (testcontainers, etc.) in unit test files
# Unit tests = src/**/*.spec.ts (without tier prefix)
if [ -d "$PROJECT_ROOT/src" ]; then
  while IFS= read -r file; do
    [ -z "$file" ] && continue
    # Skip files with tier suffixes
    case "$file" in
      *.int.spec.ts|*.func.spec.ts|*.contract.spec.ts|*.e2e.spec.ts) continue ;;
      *.int.spec.tsx|*.func.spec.tsx|*.contract.spec.tsx|*.e2e.spec.tsx) continue ;;
    esac

    infra_matches=$(grep -n "from ['\"].*testcontainers\|from ['\"].*_support/harness" "$file" 2>/dev/null || true)
    if [ -n "$infra_matches" ]; then
      rel_file="${file#"$PROJECT_ROOT"/}"
      while IFS= read -r match_line; do
        [ -z "$match_line" ] && continue
        line_num=$(echo "$match_line" | cut -d: -f1)
        violation_count=$((violation_count + 1))
        entry="{\"rule\":\"no-infra-in-unit-tests\",\"file\":\"$rel_file\",\"line\":$line_num,\"message\":\"Unit test imports infrastructure (should be integration tier)\"}"
        if [ -z "$violations" ]; then
          violations="$entry"
        else
          violations="$violations,$entry"
        fi
      done <<< "$infra_matches"
    fi
  done < <(find "$PROJECT_ROOT/src" -type f \( -name "*.spec.ts" -o -name "*.spec.tsx" \) \
    ! -path "*/node_modules/*" \
    2>/dev/null)
fi

echo "Done. Found $violation_count violations." >&2

cat <<EOF
{
  "project_root": "$PROJECT_ROOT",
  "violation_count": $violation_count,
  "violations": [$violations]
}
EOF
