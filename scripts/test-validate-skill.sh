#!/usr/bin/env bash
# Regression tests for scripts/validate-skill.sh (Claude-first contract).
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VALIDATOR="$REPO_ROOT/scripts/validate-skill.sh"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

failures=0

# Writes a Claude-contract skill package: frontmatter is name + description
# only; version/source_contracts live in metadata.json; CHANGELOG carries the
# changelog version (which may differ from metadata to exercise the check).
write_skill() {
  local dir="$1"
  local name="$2"
  local metadata_version="$3"
  local changelog_version="$4"

  mkdir -p "$dir"
  cat >"$dir/SKILL.md" <<EOF
---
name: $name
description: Use when testing the Bond validator.
---

# $name

See [Reference](reference.md).
EOF

  cat >"$dir/reference.md" <<EOF
# Reference
EOF

  cat >"$dir/metadata.json" <<EOF
{
  "version": "$metadata_version",
  "author": "test-author",
  "date": "2026-04-30",
  "abstract": "Synthetic validator fixture.",
  "source_contracts": [
    {
      "path": "README.md",
      "reviewed_at": "2026-04-30"
    }
  ]
}
EOF

  cat >"$dir/CHANGELOG.md" <<EOF
# Changelog

## $changelog_version - 2026-04-30

### Added

- Synthetic validator fixture.

### Source Contracts

- README.md
EOF
}

run_case() {
  local name="$1"
  local expected_pass="$2"
  local expected_text="$3"
  local skill_dir="$4"

  local output
  output="$("$VALIDATOR" "$skill_dir" 2>&1 || true)"

  local actual_pass
  actual_pass="$(jq -r '.pass' <<<"$output")"

  if [[ "$actual_pass" != "$expected_pass" ]]; then
    echo "FAIL $name: expected pass=$expected_pass, got pass=$actual_pass"
    echo "$output"
    failures=$((failures + 1))
    return
  fi

  if [[ -n "$expected_text" ]] && ! grep -Fq "$expected_text" <<<"$output"; then
    echo "FAIL $name: expected output to contain: $expected_text"
    echo "$output"
    failures=$((failures + 1))
    return
  fi

  echo "PASS $name"
}

# A clean Claude-contract package passes.
valid_skill="$tmp_dir/valid-skill"
write_skill "$valid_skill" "valid-skill" "1.2.3" "1.2.3"
run_case "valid governed skill passes" "true" "" "$valid_skill"

# Missing name in frontmatter fails.
missing_name_skill="$tmp_dir/missing-name-skill"
write_skill "$missing_name_skill" "missing-name-skill" "1.2.3" "1.2.3"
# Drop the name line from the frontmatter.
grep -v '^name:' "$missing_name_skill/SKILL.md" >"$missing_name_skill/SKILL.tmp"
mv "$missing_name_skill/SKILL.tmp" "$missing_name_skill/SKILL.md"
run_case "missing name fails" "false" "Missing required field: name" "$missing_name_skill"

# CHANGELOG must carry an entry for the metadata.json version.
mismatch_skill="$tmp_dir/mismatch-skill"
write_skill "$mismatch_skill" "mismatch-skill" "1.2.3" "1.2.2"
run_case "changelog missing metadata version fails" "false" "CHANGELOG.md missing entry for version 1.2.3" "$mismatch_skill"

# Missing CHANGELOG fails.
missing_changelog_skill="$tmp_dir/missing-changelog-skill"
write_skill "$missing_changelog_skill" "missing-changelog-skill" "1.2.3" "1.2.3"
rm "$missing_changelog_skill/CHANGELOG.md"
run_case "missing changelog fails" "false" "CHANGELOG.md not found at skill root" "$missing_changelog_skill"

# A structurally-broken source_contract (no reviewed_at) fails.
bad_source_contract_skill="$tmp_dir/bad-source-contract-skill"
write_skill "$bad_source_contract_skill" "bad-source-contract-skill" "1.2.3" "1.2.3"
jq '.source_contracts[0].reviewed_at = ""' "$bad_source_contract_skill/metadata.json" >"$bad_source_contract_skill/metadata.tmp"
mv "$bad_source_contract_skill/metadata.tmp" "$bad_source_contract_skill/metadata.json"
run_case "source_contract missing reviewed_at fails" "false" "source_contracts entries require path and reviewed_at" "$bad_source_contract_skill"

# A missing local source_contract path is a warning, not a failure.
missing_path_skill="$tmp_dir/missing-path-skill"
write_skill "$missing_path_skill" "missing-path-skill" "1.2.3" "1.2.3"
jq '.source_contracts[0].path = "missing/source-contract.md"' "$missing_path_skill/metadata.json" >"$missing_path_skill/metadata.tmp"
mv "$missing_path_skill/metadata.tmp" "$missing_path_skill/metadata.json"
run_case "missing source_contract path warns but passes" "true" "source_contracts path not found locally: missing/source-contract.md" "$missing_path_skill"

# Legacy frontmatter fields warn but do not fail.
legacy_frontmatter_skill="$tmp_dir/legacy-frontmatter-skill"
write_skill "$legacy_frontmatter_skill" "legacy-frontmatter-skill" "1.2.3" "1.2.3"
cat >"$legacy_frontmatter_skill/SKILL.md" <<'EOF'
---
name: legacy-frontmatter-skill
version: "1.2.3"
last_reviewed: "2026-04-30"
description: Use when testing the Bond validator.
---

# legacy-frontmatter-skill

See [Reference](reference.md).
EOF
run_case "legacy frontmatter field warns but passes" "true" "move it to metadata.json" "$legacy_frontmatter_skill"

if [[ "$failures" -gt 0 ]]; then
  echo "$failures validator regression test(s) failed"
  exit 1
fi

echo "All validator regression tests passed"
