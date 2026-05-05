#!/usr/bin/env bash
set -euo pipefail

BASE_REF="${1:-origin/main}"

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "## Git status"
  git status --short
  echo

  if git rev-parse --verify "$BASE_REF" >/dev/null 2>&1; then
    echo "## Diff stat against $BASE_REF"
    git diff --stat "$BASE_REF"...HEAD || true
    echo
    echo "## Changed files"
    git diff --name-only "$BASE_REF"...HEAD || true
  else
    echo "## Diff stat against working tree"
    git diff --stat || true
    echo
    echo "## Changed files"
    git diff --name-only || true
  fi

  echo
  echo "## Risky terms in changed files"
  files=$(git diff --name-only "$BASE_REF"...HEAD 2>/dev/null || git diff --name-only || true)
  if [ -n "$files" ]; then
    rg -n -e 'pubsub|subscription|subscriber|ack\(|nack\(|dead.?letter|retry|idempot|SIGTERM|terminationGracePeriodSeconds|readinessProbe|livenessProbe|resources:|concurrency|Promise\.all|queue|worker|cronjob|concurrencyPolicy|startingDeadlineSeconds|leader|checkpoint|rate.?limit|circuit.?breaker' $files 2>/dev/null || true
  fi
else
  echo "Not inside a git repository. Run this script from the repository root."
fi
