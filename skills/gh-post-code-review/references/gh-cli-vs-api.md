# `gh` CLI vs. GitHub REST API — decision matrix

`gh pr review` is the right tool for the simplest cases only. Anything that
needs **multiple inline comments**, **side-aware anchors** (`LEFT` vs.
`RIGHT`), **multi-line comments**, or **draft state** requires the REST API
via `gh api`.

## Decision matrix

| Need | Tool | Command |
|---|---|---|
| Approve with no inline comments | `gh pr review` | `gh pr review N --repo O/R --approve --body-file body.md` |
| Single body comment, no inline | `gh pr review` | `gh pr review N --repo O/R --comment --body-file body.md` |
| Request changes, no inline | `gh pr review` | `gh pr review N --repo O/R --request-changes --body-file body.md` |
| One or more inline comments | **`gh api`** | `gh api -X POST /repos/O/R/pulls/N/reviews --input payload.json` |
| Multi-line inline (`start_line`..`line`) | **`gh api`** | same as above; payload uses `start_line`+`line` |
| Comment on the **deleted** side of the diff | **`gh api`** | payload uses `side: "LEFT"` |
| Draft review (do not submit yet) | **`gh api`** | omit `event`; later `POST .../reviews/{id}/events` to submit |
| Submit an existing draft review | `gh api` | `gh api -X POST /repos/O/R/pulls/N/reviews/{id}/events -f event=...` |

## Why `gh pr review` cannot carry inline comments

The CLI command supports only `--body` / `--body-file` for a single body and
one `--approve|--comment|--request-changes` event. There is no flag to
attach an array of inline anchors. To anchor comments to specific
file/line ranges, you must POST to
`/repos/{owner}/{repo}/pulls/{pull_number}/reviews` with a `comments[]`
array. ([API docs — Create a review for a pull request][1])

[1]: https://docs.github.com/en/rest/pulls/reviews#create-a-review-for-a-pull-request

## Minimal `gh api` payload

```json
{
  "commit_id": "<head_sha>",
  "event": "REQUEST_CHANGES",
  "body": "Verdict line + summary + idempotency marker",
  "comments": [
    {
      "path": "functions/application/routes/v2/risk.v2.route.js",
      "start_line": 446,
      "line": 514,
      "start_side": "RIGHT",
      "side": "RIGHT",
      "body": "**B1 — Mechanism cannot solve the described failure mode.** ..."
    }
  ]
}
```

Notes:

- `commit_id` MUST be the PR head SHA at the moment of posting. Re-fetch it
  immediately before the POST and abort on drift.
- For single-line comments, omit `start_line` and `start_side`; keep `line`
  and `side`.
- `position` (the legacy diff-relative offset) is **not** used here — anchor
  by `line`/`side`. This is more robust to diff shifts within a single SHA.

## Submitting a draft later

```bash
gh api -X POST "/repos/O/R/pulls/N/reviews/${REVIEW_ID}/events" \
  -f event=REQUEST_CHANGES \
  -f body="..."
```

## When `gh pr view` and `gh api` disagree

Always trust `gh api /repos/O/R/pulls/N` as the source of truth for
`head.sha`, `state`, and `mergeable`. `gh pr view` is convenient but caches
some fields.
