#!/usr/bin/env bash
# Post a PR review via gh api with a head-SHA drift guard.
#
# Usage:
#   post-review.sh \
#     --repo owner/name \
#     --pr 123 \
#     --payload .work/gh-review-owner-name-123-20260506T1755.json \
#     [--allow-sha-drift] \
#     [--draft]
#
# Behavior:
#   1. Reads "commit_id" from the payload (must be the SHA the comments anchor to).
#   2. Re-fetches the current PR head SHA.
#   3. Aborts (exit 2) if they differ, unless --allow-sha-drift is set.
#   4. If --draft, strips "event" from the payload before POST so GitHub
#      creates a PENDING review.
#   5. POSTs /repos/{owner}/{repo}/pulls/{pull_number}/reviews via gh api.
#   6. Prints STRICT JSON to stdout: {review_id, review_url, event, head_sha}.

set -euo pipefail

REPO=""
PR=""
PAYLOAD=""
ALLOW_DRIFT=0
DRAFT=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo) REPO="$2"; shift 2 ;;
    --pr) PR="$2"; shift 2 ;;
    --payload) PAYLOAD="$2"; shift 2 ;;
    --allow-sha-drift) ALLOW_DRIFT=1; shift ;;
    --draft) DRAFT=1; shift ;;
    -h|--help) sed -n '2,22p' "$0"; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 64 ;;
  esac
done

if [[ -z "$REPO" || -z "$PR" || -z "$PAYLOAD" ]]; then
  echo "missing required args; need --repo, --pr, --payload" >&2
  exit 64
fi
if [[ ! -r "$PAYLOAD" ]]; then
  echo "payload not readable: $PAYLOAD" >&2
  exit 66
fi
if ! command -v gh >/dev/null 2>&1; then
  echo "gh CLI not found on PATH" >&2
  exit 127
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "jq not found on PATH" >&2
  exit 127
fi

PAYLOAD_SHA="$(jq -r '.commit_id // empty' "$PAYLOAD")"
if [[ -z "$PAYLOAD_SHA" || "$PAYLOAD_SHA" == "REPLACE_WITH_HEAD_SHA" ]]; then
  echo "payload.commit_id is missing or unfilled" >&2
  exit 65
fi

CURRENT_SHA="$(gh api "/repos/${REPO}/pulls/${PR}" --jq '.head.sha')"
if [[ -z "$CURRENT_SHA" ]]; then
  echo "could not fetch head SHA for ${REPO}#${PR}" >&2
  exit 69
fi

if [[ "$PAYLOAD_SHA" != "$CURRENT_SHA" ]]; then
  if [[ "$ALLOW_DRIFT" -ne 1 ]]; then
    {
      echo "head SHA drift detected; aborting."
      echo "  payload.commit_id : ${PAYLOAD_SHA}"
      echo "  pull.head.sha     : ${CURRENT_SHA}"
      echo "Re-run parse + payload build against ${CURRENT_SHA}, or pass --allow-sha-drift."
    } >&2
    exit 2
  fi
fi

EFFECTIVE_PAYLOAD="$PAYLOAD"
TMP_PAYLOAD=""
cleanup() { [[ -n "$TMP_PAYLOAD" && -f "$TMP_PAYLOAD" ]] && rm -f "$TMP_PAYLOAD"; }
trap cleanup EXIT

if [[ "$DRAFT" -eq 1 ]]; then
  TMP_PAYLOAD="$(mktemp)"
  jq 'del(.event)' "$PAYLOAD" > "$TMP_PAYLOAD"
  EFFECTIVE_PAYLOAD="$TMP_PAYLOAD"
fi

RESP="$(gh api -X POST "/repos/${REPO}/pulls/${PR}/reviews" --input "$EFFECTIVE_PAYLOAD")"

REVIEW_ID="$(echo "$RESP" | jq -r '.id')"
REVIEW_STATE="$(echo "$RESP" | jq -r '.state')"
REVIEW_URL="$(echo "$RESP" | jq -r '.html_url')"
EVENT_OUT="$(jq -r '.event // "PENDING"' "$PAYLOAD")"

jq -n \
  --arg review_url "$REVIEW_URL" \
  --argjson review_id "$REVIEW_ID" \
  --arg event "$EVENT_OUT" \
  --arg state "$REVIEW_STATE" \
  --arg head_sha "$CURRENT_SHA" \
  '{review_url: $review_url, review_id: $review_id, event: $event, state: $state, head_sha: $head_sha}'
