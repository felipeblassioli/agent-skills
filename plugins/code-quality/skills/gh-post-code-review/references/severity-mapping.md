# Severity → GitHub review event mapping

GitHub PR reviews carry exactly one `event` per submission:
`APPROVE`, `REQUEST_CHANGES`, `COMMENT`, or `PENDING` (draft). This file
maps a structured review's verdict + severity buckets to the right event
and the right per-finding shape.

## Decision table

Evaluate top-down; the first matching row wins.

| Condition | `event` | Notes |
|---|---|---|
| Verdict explicitly says "NOT MERGE-READY", "BLOCKING", or contains any `BLOCKER` finding | `REQUEST_CHANGES` | Mandatory. Do not soften. |
| Any `HIGH` finding present, no `BLOCKER` | `REQUEST_CHANGES` | HIGH = production-impacting. |
| Only `MEDIUM` and/or `LOW` and/or `QUESTION` findings | `COMMENT` | Reviewer may still expect changes; use a clear ask line. |
| Verdict is "MERGE-READY" / "APPROVE" / "LGTM", no BLOCKER/HIGH | `APPROVE` | Allowed to include MEDIUM/LOW notes inline. |
| Verdict missing or ambiguous | `COMMENT` | Default-safe. Warn the user and surface this in the preview. |

## Per-finding rendering

| Severity | Inline anchor required? | Body prefix in inline comment | Body fold in summary |
|---|---|---|---|
| `BLOCKER` | yes if any code ref present; else summary-only | `**BLOCKER — <id> — <title>**` | not folded |
| `HIGH` | yes if any code ref present; else summary-only | `**HIGH — <id> — <title>**` | not folded |
| `MEDIUM` | preferred when code ref present | `**MEDIUM — <id> — <title>**` | not folded |
| `LOW` | optional | `**nit — <id> — <title>**` | folded under `<details><summary>nits</summary>` |
| `QUESTION` | yes if code ref present | `**Q — <id>** ` (phrase as a question) | not folded |

## Body composition (the top-level review body)

Order:

1. Addressing line: `Olá @${author}` / `Hi @${author}`.
2. Verdict line, verbatim from the input review.
3. Counts table: `| sev | count |` for each non-zero severity.
4. Findings without code refs grouped by severity (`HIGH` and above are
   never folded; `LOW` always folded).
5. Idempotency marker as the last line:
   `<!-- gh-post-code-review:sha=<head_sha>:hash=<bodyHash> -->`

`bodyHash` is a stable SHA-1 of the canonical findings JSON (sorted by id),
not of the markdown body. This lets the skill detect "same review re-posted
against the same commit" even if cosmetics differ.

## Edge cases

- **No findings at all.** Refuse to post; nothing to say. Return an error.
- **Only QUESTIONs.** Use `event: "COMMENT"`. Do not request changes for
  questions alone.
- **Verdict says APPROVE but findings include HIGH.** Treat as an authoring
  bug in the review; warn the user, default to `REQUEST_CHANGES`, and ask
  to confirm before posting.
