#!/usr/bin/env bash
# coverage-summary.sh — Read a coverage-summary.json and output compact metrics.
#
# Reads the Istanbul coverage-summary.json produced by Jest (per-tier or merged)
# and outputs a compact JSON with percentage values and threshold check.
#
# Usage:
#   coverage-summary.sh INPUT [--thresholds]
#
#   INPUT can be a file path or "-" for stdin.
#
# Examples:
#   # Read unit coverage
#   coverage-summary.sh functions/coverage/unit/coverage-summary.json
#
#   # Read merged coverage
#   coverage-summary.sh functions/coverage/merged/coverage-summary.json
#
#   # Check thresholds (unit tier thresholds: branches 20, functions 25, lines 30, statements 30)
#   coverage-summary.sh functions/coverage/unit/coverage-summary.json --thresholds
#
# Output (JSON to stdout):
#   {
#     "lines": 34.2,
#     "branches": 21.1,
#     "functions": 28.5,
#     "statements": 34.0,
#     "thresholds_pass": true,
#     "threshold_details": {
#       "branches": { "actual": 21.1, "required": 20, "pass": true },
#       "functions": { "actual": 28.5, "required": 25, "pass": true },
#       "lines": { "actual": 34.2, "required": 30, "pass": true },
#       "statements": { "actual": 34.0, "required": 30, "pass": true }
#     }
#   }

set -euo pipefail

# ── Unit tier thresholds (from jest.config.js) ───────────────────────────────
THRESH_BRANCHES=20
THRESH_FUNCTIONS=25
THRESH_LINES=30
THRESH_STATEMENTS=30

INPUT=""
CHECK_THRESHOLDS=false

usage() {
  cat <<'USAGE'
Usage: coverage-summary.sh INPUT [OPTIONS]

  INPUT              Path to coverage-summary.json, or "-" for stdin

Options:
  --thresholds       Include threshold check in output (unit tier thresholds:
                     branches 20%, functions 25%, lines 30%, statements 30%)
  -h, --help         Show this help message
USAGE
  exit 0
}

# ── Parse args ────────────────────────────────────────────────────────────────
if [[ $# -lt 1 ]]; then
  echo "Error: INPUT is required (file path or '-' for stdin)." >&2
  exit 1
fi

INPUT="$1"; shift

while [[ $# -gt 0 ]]; do
  case "$1" in
    --thresholds) CHECK_THRESHOLDS=true; shift ;;
    -h|--help)    usage ;;
    *)
      echo "Error: unknown argument '$1'" >&2
      exit 1
      ;;
  esac
done

# ── Validate ──────────────────────────────────────────────────────────────────
if ! command -v jq &>/dev/null; then
  echo "Error: jq is required. Install: https://stedolan.github.io/jq/download/" >&2
  exit 1
fi

if [[ "$INPUT" != "-" && ! -f "$INPUT" ]]; then
  echo "Error: file not found: $INPUT" >&2
  exit 1
fi

# ── Extract metrics ──────────────────────────────────────────────────────────
if [[ "$CHECK_THRESHOLDS" == "true" ]]; then
  JQ_EXPR="
    .total | {
      lines: .lines.pct,
      branches: .branches.pct,
      functions: .functions.pct,
      statements: .statements.pct,
      thresholds_pass: (
        .branches.pct >= $THRESH_BRANCHES and
        .functions.pct >= $THRESH_FUNCTIONS and
        .lines.pct >= $THRESH_LINES and
        .statements.pct >= $THRESH_STATEMENTS
      ),
      threshold_details: {
        branches:   { actual: .branches.pct,   required: $THRESH_BRANCHES,   pass: (.branches.pct   >= $THRESH_BRANCHES) },
        functions:  { actual: .functions.pct,  required: $THRESH_FUNCTIONS,  pass: (.functions.pct  >= $THRESH_FUNCTIONS) },
        lines:      { actual: .lines.pct,      required: $THRESH_LINES,      pass: (.lines.pct      >= $THRESH_LINES) },
        statements: { actual: .statements.pct, required: $THRESH_STATEMENTS, pass: (.statements.pct >= $THRESH_STATEMENTS) }
      }
    }
  "
else
  JQ_EXPR='
    .total | {
      lines: .lines.pct,
      branches: .branches.pct,
      functions: .functions.pct,
      statements: .statements.pct
    }
  '
fi

if [[ "$INPUT" == "-" ]]; then
  jq "$JQ_EXPR"
else
  jq "$JQ_EXPR" "$INPUT"
fi
