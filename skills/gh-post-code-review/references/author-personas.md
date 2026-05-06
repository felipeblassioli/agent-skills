# PR-author addressing and tone

Two modes: **default (cheap)** and **opt-in `--persona-probe`**.

## Default (cheap)

Read `author.login` from `gh pr view --json author` and prepend the review
body with one of:

- English review: `Hi @${login}, thanks for the patch — review below.`
- PT-BR review: `Olá @${login}, valeu pelo patch — review abaixo.`

Tone rules that apply to **all** authors:

- BLOCKER / HIGH findings remain directives. Do not soften.
- QUESTIONs are phrased as questions, never as asks.
- Never restate the diff back to the author. Cite by `path:line`.
- Never call the code "bad" or "wrong" — describe the failure mode.

The skill never modifies the **input** review's wording. It only adds the
addressing line, count summary, fold sections, and the idempotency marker.

## Opt-in `--persona-probe`

When the user invokes the skill with `--persona-probe`, delegate to a
subagent (cheap, read-only) before posting:

```
subagent_type: explore
model: fast
readonly: true
description: "Probe PR author seniority signals"
prompt: |
  For GitHub user "${login}" in repo "${owner}/${repo}":
  1. List their last 5 merged PRs (gh search prs --author "${login}" --repo "${owner}/${repo}" --state merged --limit 5).
  2. For each, count review comments received and whether they were the PR author or a reviewer.
  3. Output STRICT JSON ONLY:
     {"signals": {"merged_count": N, "avg_comments_received": X.X, "common_reviewers": [...]},
      "suggested_tone": "concise" | "explanatory" | "mentor"}
  No prose. No additional commentary.
```

Use the result only to choose ONE of three tone presets for the addressing
block (not for finding bodies):

| `suggested_tone` | Addressing block change |
|---|---|
| `concise` | Drop "thanks for the patch — review below"; use a single line. |
| `explanatory` | Add a one-sentence "I've grouped findings by severity; BLOCKERs first." |
| `mentor` | Add a one-sentence pointer to the relevant docs/RFCs if the review cited any. |

Never use persona signals to change BLOCKER / HIGH content or to skip findings.

## Anti-patterns

- Do not infer seniority from name, avatar, or org membership.
- Do not change the verdict based on author seniority.
- Do not add emojis unless the input review used them.
- Do not @mention reviewers other than the PR author without explicit user
  instruction.
