#!/usr/bin/env bash
# parse-jest-results.sh — Extract a compact summary from Jest --json output.
#
# Reads a Jest JSON results file and outputs a compact JSON summary with
# pass/fail counts and failure details.
#
# Usage:
#   parse-jest-results.sh INPUT
#
#   INPUT can be a file path or "-" for stdin.
#
# Examples:
#   # Parse a Jest JSON file
#   parse-jest-results.sh /tmp/jest-unit-abc123.json
#
#   # Pipe from run-tier.sh
#   run-tier.sh --tier unit --workdir functions | xargs parse-jest-results.sh
#
# Output (JSON to stdout):
#   {
#     "success": true,
#     "passed": 47,
#     "failed": 0,
#     "total": 47,
#     "suites_passed": 12,
#     "suites_failed": 0,
#     "duration_ms": 4200,
#     "failures": []
#   }

set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: parse-jest-results.sh INPUT

  INPUT    Path to Jest JSON output file, or "-" for stdin.

  Outputs a compact JSON summary of test results.

Options:
  -h, --help    Show this help message
USAGE
  exit 0
}

# ── Parse args ────────────────────────────────────────────────────────────────
INPUT=""

if [[ $# -lt 1 ]]; then
  echo "Error: INPUT is required (file path or '-' for stdin)." >&2
  exit 1
fi

case "$1" in
  -h|--help) usage ;;
  *) INPUT="$1" ;;
esac

# ── Validate ──────────────────────────────────────────────────────────────────
if ! command -v jq &>/dev/null; then
  echo "Error: jq is required. Install: https://stedolan.github.io/jq/download/" >&2
  exit 1
fi

if [[ "$INPUT" != "-" && ! -f "$INPUT" ]]; then
  echo "Error: file not found: $INPUT" >&2
  exit 1
fi

# ── Extract summary ──────────────────────────────────────────────────────────
JQ_EXPR='
{
  success: .success,
  passed: .numPassedTests,
  failed: .numFailedTests,
  total: (.numPassedTests + .numFailedTests + .numPendingTests),
  suites_passed: .numPassedTestSuites,
  suites_failed: .numFailedTestSuites,
  duration_ms: (
    if .testResults then
      ([.testResults[].endTime] | max) - .startTime
    else
      0
    end
  ),
  failures: [
    .testResults[]
    | select(.numFailingTests > 0)
    | .testFilePath as $file
    | .testResults[]
    | select(.status == "failed")
    | {
        file: ($file | split("/") | last),
        test: .ancestorTitles[-1:][0] + " > " + .title,
        message: (
          .failureMessages[0]
          | if . then
              split("\n")
              | map(select(. != ""))
              | .[0:3]
              | join(" | ")
            else
              "No failure message"
            end
        )
      }
  ]
}
'

if [[ "$INPUT" == "-" ]]; then
  jq "$JQ_EXPR"
else
  jq "$JQ_EXPR" "$INPUT"
fi
