---
name: gh-post-code-review
description: Post a structured code review to a GitHub PR via `gh` CLI (REST API fallback for multi-comment / inline-anchored reviews). Maps BLOCKER/HIGH/MEDIUM/LOW/QUESTION sections to the right review event and inline anchors, parses ` ```start:end:path ` code refs, and adapts tone to the PR author. Use when you have a written code review and want it posted to a specific PR URL or number. Do NOT use to author the review itself, triage existing comments, or open/merge PRs.
---

# Post Code Review to GitHub PR

Turn a structured review (markdown) into a properly-anchored GitHub PR review.
Default to `gh pr review`. Fall back to `gh api POST /reviews` when the review
has multiple inline comments, side-aware anchors, or needs a draft state.

## Prerequisites

- `gh` CLI installed and authenticated (`gh auth status`).
- `jq` and `python3` available on PATH.
- Write access to the target repository (token scope `repo` / `pull_request:write`).

## Applicability Gate

Use when ALL of the following are true:

- The user provides (or has staged) a code review in markdown.
- The user provides a PR URL or `owner/repo#N` reference.
- The intent is to **post** the review on GitHub.

Do NOT use when:

- The review does not yet exist — that is `code-quality:code-reviewer`.
- The user wants to triage / reply to existing comments — see `babysit`,
  `get-pr-comments`.
- The user wants to open the PR or push a branch — see `gh-pr-creator`,
  `new-branch-and-pr`.
- The user wants to merge, rebase, or resolve threads.

## Inputs Contract

1. **Review markdown.** Expected (but not strictly required) sections:
   `Verdict`, `Findings`, severity buckets (`BLOCKER`, `HIGH`, `MEDIUM`,
   `LOW`, `QUESTION`). Findings may embed code refs as fenced blocks of the
   form ` ```START:END:PATH ` (Cursor `CODE REFERENCES` format). See
   [references/code-ref-parsing.md](references/code-ref-parsing.md).
2. **PR target.** A URL like `https://github.com/<owner>/<repo>/pull/<N>` or
   shorthand `<owner>/<repo>#<N>`.

## Output Contract

After posting, return STRICT JSON (no prose around it):

```json
{
  "review_url": "https://github.com/owner/repo/pull/N#pullrequestreview-XXXX",
  "review_id": 123456789,
  "event": "REQUEST_CHANGES",
  "head_sha": "abcdef0",
  "counts": { "blocker": 2, "high": 4, "medium": 6, "low": 3, "question": 3, "posted_inline": 12, "skipped": 3 },
  "posted_comments": [{ "finding_id": "B1", "comment_id": 123, "path": "...", "line": 514 }],
  "skipped_findings": [{ "finding_id": "M3", "reason": "no code ref; folded into summary body" }]
}
```

If staged-only (dry run), return the same shape with `review_url: null`,
`review_id: null`, and a `payload_path` field pointing to the staged JSON.

## Procedure

### 1. Resolve PR context

Parse the URL/shorthand into `OWNER`, `REPO`, `NUMBER`. Then:

```bash
gh pr view "$NUMBER" --repo "$OWNER/$REPO" \
  --json number,state,isDraft,author,headRefOid,baseRefName,headRefName,title,url
```

Refuse to proceed if:

- `state != "OPEN"`.
- The repo in the URL does not match `gh repo view --json nameWithOwner`
  unless `--repo` was explicitly passed (do not silently retarget).

Capture `headRefOid` as `HEAD_SHA`. All inline anchors are validated against
this SHA at post time (see step 8).

### 2. Parse the review

Pipe the review markdown through the bundled parser:

```bash
python3 "${CLAUDE_SKILL_DIR}/scripts/parse-refs.py" < review.md > .work/findings-<pr>-<ts>.json
```

The parser emits one entry per finding with: `id` (e.g. `B1`, `H2`), `severity`,
`title`, `body` (markdown without the fenced code-ref block), and zero or more
anchors `{path, start_line, line, side}` where `line == end` and `side` defaults
to `RIGHT`. Findings with no anchor are flagged `inline: false` and folded into
the summary body in step 4.

### 3. Decide the review event

Map the verdict + severities to a single GitHub review event. Full table in
[references/severity-mapping.md](references/severity-mapping.md). TL;DR:

| Condition | `event` |
|---|---|
| Any `BLOCKER` or verdict says NOT MERGE-READY / blocking | `REQUEST_CHANGES` |
| Any `HIGH`, no BLOCKER | `REQUEST_CHANGES` |
| Only `MEDIUM` / `LOW` / `QUESTION` | `COMMENT` |
| Verdict is "MERGE-READY" or "APPROVE", no BLOCKER/HIGH | `APPROVE` |
| Ambiguous / missing verdict | `COMMENT` (safe default; warn the user) |

### 4. Build the payload

Start from [assets/templates/review-payload.json](assets/templates/review-payload.json).
The `body` field carries:

- The verdict line (verbatim).
- A short summary of counts by severity.
- Findings with **no code ref** rendered as a collapsed `<details>` per
  severity bucket so they remain reviewable but do not pollute the inline thread.
- An idempotency marker as the last line (HTML comment), e.g.:

  ```
  <!-- gh-post-code-review:sha=<HEAD_SHA>:hash=<bodyHash> -->
  ```

The `comments[]` array carries one entry per anchored finding. Use **multi-line
comments** (`start_line` + `line` + `start_side` + `side`) when `start != end`,
otherwise a single-line comment. `position` is **not** used — anchor by
`line`/`side` against `commit_id = HEAD_SHA`.

### 5. Stage to `.work/`

Always write the payload to `.work/gh-review-<owner>-<repo>-<pr>-<ts>.json`
(create `.work/` if missing). Never delete staged files — they are history.

### 6. Address and tone (PR-author awareness)

Open the payload in memory and:

- Prepend the body with `Olá @${author.login},` if the input review is in
  PT-BR, or `Hi @${author.login},` if in English.
- Mirror the **input review's language** for any text the skill itself adds
  (counts, fold-out section titles). Do not translate review content.
- See [references/author-personas.md](references/author-personas.md) for
  optional `--persona-probe` flow that delegates a cheap subagent (`model: fast`,
  `readonly: true`) to look at the author's last 5 PRs and suggest tone.
  Off by default.

### 7. Preview + confirm

Print to the user:

- `event`, counts by severity, `head_sha`, payload path.
- The first inline finding (path:start-line, body head ≤ 200 chars).
- The verdict line.

Ask: **"Post this review now? (y / dry-run / abort)"** — never post without
explicit confirmation. `dry-run` returns the staged-only output contract.

### 8. Choose the post path

Decision matrix in [references/gh-cli-vs-api.md](references/gh-cli-vs-api.md).
Short version:

- **Use `gh pr review`** only when there are zero anchored comments AND the
  event is `APPROVE` or `COMMENT` with a single body. (`gh pr review` cannot
  attach multiple inline comments in one shot.)
- **Use `${CLAUDE_SKILL_DIR}/scripts/post-review.sh`** otherwise. It wraps:

  ```bash
  gh api -X POST "/repos/$OWNER/$REPO/pulls/$NUMBER/reviews" \
    --input "$PAYLOAD_PATH"
  ```

  The script re-fetches `headRefOid` immediately before posting and aborts
  with a non-zero exit if it differs from the SHA baked into payload `commit_id`,
  unless `--allow-sha-drift` is set. This prevents anchoring to a stale diff.

### 9. Idempotency

Before posting, list existing reviews by you:

```bash
gh api "/repos/$OWNER/$REPO/pulls/$NUMBER/reviews" \
  --jq '.[] | select(.user.login == "<viewer>") | {id, body, submitted_at}'
```

If any body contains the same `gh-post-code-review:sha=...:hash=...` marker,
present the user with three choices:

1. **skip** — return the existing `review_url` and exit.
2. **new** — post anyway (creates a second review).
3. **summary-only** — submit a comment-only follow-up referencing the existing
   review id (no inline duplication).

### 10. Capture and return

Parse the API response → fill the output contract JSON → emit it. Do not add
explanatory prose around the JSON.

## Safety Gates (must hold before posting)

1. PR is `OPEN`.
2. Repo in URL matches the `gh` working repo (or `--repo` was explicit).
3. `HEAD_SHA` matches at post time (re-fetched in step 8).
4. Payload file exists and parses as JSON.
5. Every inline comment's `path` exists in the PR diff (verify via
   `gh api /repos/.../pulls/N/files --paginate --jq '.[].filename'`).
   Drop comments whose path is not in the diff and add them to
   `skipped_findings` with `reason: "path not in PR diff"`.
6. User confirmed in step 7.

## Author Awareness

- **Default (cheap):** read `author.login` from `gh pr view` and `@mention`
  it in the body opener. Phrase BLOCKERs as directives, QUESTIONs as
  questions. Do not soften BLOCKER/HIGH content.
- **Opt-in (`--persona-probe`):** delegate to a subagent
  (`subagent_type: explore`, `readonly: true`, model: fast) with this prompt
  shape — see [references/author-personas.md](references/author-personas.md).

## Routing Table

| Need | Route to |
|---|---|
| Decide `gh pr review` vs. `gh api` for this review | [references/gh-cli-vs-api.md](references/gh-cli-vs-api.md) |
| Map verdict + severity to a review event | [references/severity-mapping.md](references/severity-mapping.md) |
| Parse ` ```start:end:path ` blocks | [references/code-ref-parsing.md](references/code-ref-parsing.md) |
| Adjust addressing/tone for the PR author | [references/author-personas.md](references/author-personas.md) |
| Payload skeleton | [assets/templates/review-payload.json](assets/templates/review-payload.json) |
| Parse review markdown to findings JSON | [scripts/parse-refs.py](scripts/parse-refs.py) |
| Post the review with SHA-drift guard | [scripts/post-review.sh](scripts/post-review.sh) |

## Gotchas

Failure modes GitHub's API punishes if you assume the obvious:

- **You cannot `APPROVE` / `REQUEST_CHANGES` your own PR.** GitHub rejects self-review with those events. When the authenticated viewer is the PR author (common when dogfooding on your own repos), fall back to a `COMMENT` event or a plain PR comment — don't let the post silently fail.
- **`gh pr review` can't attach multiple inline comments.** For more than one inline anchor you MUST use the REST `POST /reviews` path (the bundled `post-review.sh`). Silently dropping to `gh pr review` loses every inline finding but the first.
- **Anchor by `line` + `side` against `commit_id`, never `position`.** `position` is a diff offset that breaks on rebase; `line`/`side` pinned to `HEAD_SHA` is stable.
- **One out-of-diff path 422s the whole review.** GitHub rejects the entire review if any inline comment targets a file not in the PR diff — verify each path against `pulls/N/files` and fold the rest into the summary body (`skipped_findings`).
- **Re-fetch `HEAD_SHA` immediately before posting.** New commits can land between authoring and posting; the wrapper aborts on SHA drift unless `--allow-sha-drift` — don't override that blindly, it means your anchors are stale.
- **The idempotency marker is load-bearing.** Re-running without checking for the existing `gh-post-code-review:sha=...:hash=...` marker stacks duplicate reviews on the PR.

## What this skill is NOT

- Not a code-review author. Inputs are reviews, not diffs.
- Not a thread resolver — does not call `gh api ... /threads/.../resolve`.
- Not a `suggestion`-block generator (out of scope for v0.1).
- Not a merger.

## Out-of-scope follow-ups (tracked here for v0.2+)

- One-line `suggestion` blocks for `LOW` findings.
- Auto-resolve threads on follow-up reviews.
- Markdown linting of the input review.
