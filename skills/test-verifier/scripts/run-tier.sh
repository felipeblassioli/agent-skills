#!/usr/bin/env bash
# run-tier.sh — Run a single test tier and write Jest JSON output to a file.
#
# Wraps the npm test:<tier> scripts with --json for machine-readable output.
# When --coverage is specified, uses the :cov variant of the script.
#
# Usage:
#   run-tier.sh --tier unit [--filter PATTERN] [--coverage] [--workdir DIR] [--output FILE]
#
# Examples:
#   # Run unit tests, JSON output to temp file
#   run-tier.sh --tier unit --workdir functions
#
#   # Run unit tests with coverage, filtered to specific files
#   run-tier.sh --tier unit --coverage --filter "rules.service|alert.service" --workdir functions
#
#   # Run functional tests, explicit output path
#   run-tier.sh --tier functional --output /tmp/functional-results.json --workdir functions

set -euo pipefail

# ── Tier-to-script mapping ───────────────────────────────────────────────────
declare -A TIER_SCRIPT
TIER_SCRIPT[unit]="test:unit"
TIER_SCRIPT[integration]="test:integration"
TIER_SCRIPT[functional]="test:functional"
TIER_SCRIPT[functional-http]="test:functional:http"
TIER_SCRIPT[structural]="test:structural"
TIER_SCRIPT[emulator]="test:emulator"
TIER_SCRIPT[system]="test:system"
TIER_SCRIPT[smoke]="smoke:test"

declare -A TIER_COV_SCRIPT
TIER_COV_SCRIPT[unit]="test:unit:cov"
TIER_COV_SCRIPT[integration]="test:integration:cov"
TIER_COV_SCRIPT[functional]="test:functional:cov"
TIER_COV_SCRIPT[functional-http]="test:functional:http:cov"

# ── Defaults ──────────────────────────────────────────────────────────────────
TIER=""
FILTER=""
COVERAGE=false
WORKDIR=""
OUTPUT=""

usage() {
  cat <<'USAGE'
Usage: run-tier.sh [OPTIONS]

Required:
  --tier TIER          Test tier to run (unit, integration, functional,
                       functional-http, structural, emulator, system, smoke)

Optional:
  --filter PATTERN     Jest test name or file pattern (passed after --)
  --coverage           Use the :cov variant of the npm script
  --workdir DIR        Working directory (default: current directory)
  --output FILE        Write Jest JSON output to FILE (default: auto-generated temp file)

Output:
  Jest JSON is written to the output file. The file path is printed to stderr.
  Exit code matches Jest's exit code (0 = all pass, 1 = failures).
USAGE
  exit 0
}

# ── Parse args ────────────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --tier)     TIER="$2";    shift 2 ;;
    --filter)   FILTER="$2";  shift 2 ;;
    --coverage) COVERAGE=true; shift ;;
    --workdir)  WORKDIR="$2"; shift 2 ;;
    --output)   OUTPUT="$2";  shift 2 ;;
    -h|--help)  usage ;;
    *)
      echo "Error: unknown argument '$1'" >&2
      usage
      ;;
  esac
done

# ── Validate ──────────────────────────────────────────────────────────────────
if [[ -z "$TIER" ]]; then
  echo "Error: --tier is required." >&2
  exit 1
fi

if [[ -z "${TIER_SCRIPT[$TIER]:-}" ]]; then
  echo "Error: unknown tier '$TIER'. Valid tiers: ${!TIER_SCRIPT[*]}" >&2
  exit 1
fi

if [[ "$COVERAGE" == "true" && -z "${TIER_COV_SCRIPT[$TIER]:-}" ]]; then
  echo "Warning: tier '$TIER' does not support coverage. Running without --coverage." >&2
  COVERAGE=false
fi

if [[ -n "$WORKDIR" ]]; then
  cd "$WORKDIR"
fi

if [[ ! -f "package.json" ]]; then
  echo "Error: package.json not found in $(pwd). Use --workdir to specify the functions/ directory." >&2
  exit 1
fi

# ── Determine npm script ─────────────────────────────────────────────────────
if [[ "$COVERAGE" == "true" ]]; then
  NPM_SCRIPT="${TIER_COV_SCRIPT[$TIER]}"
else
  NPM_SCRIPT="${TIER_SCRIPT[$TIER]}"
fi

# ── Prepare output file ──────────────────────────────────────────────────────
if [[ -z "$OUTPUT" ]]; then
  OUTPUT=$(mktemp "/tmp/jest-${TIER}-XXXXXX.json")
fi

# ── Build command ─────────────────────────────────────────────────────────────
CMD=(npm run "$NPM_SCRIPT" --)
CMD+=(--json --outputFile="$OUTPUT")

if [[ -n "$FILTER" ]]; then
  CMD+=("$FILTER")
fi

# ── Execute ───────────────────────────────────────────────────────────────────
echo "# Tier: $TIER" >&2
echo "# Script: npm run $NPM_SCRIPT" >&2
echo "# Coverage: $COVERAGE" >&2
echo "# Filter: ${FILTER:-<none>}" >&2
echo "# Output: $OUTPUT" >&2

EXIT_CODE=0
"${CMD[@]}" 2>&1 | tail -5 >&2 || EXIT_CODE=$?

if [[ -f "$OUTPUT" ]]; then
  echo "# Results written to: $OUTPUT" >&2
  echo "$OUTPUT"
else
  echo "# Warning: output file not created. Jest may have crashed." >&2
  echo "$OUTPUT"
fi

exit "$EXIT_CODE"
