# gh-post-code-review

Post a structured code review (markdown) to a GitHub PR. Favors `gh` CLI;
falls back to `gh api POST /reviews` when the review has multiple inline
anchors or side-aware comments.

## When to use

- You (or another skill) produced a code review with severity buckets
  (`BLOCKER`, `HIGH`, `MEDIUM`, `LOW`, `QUESTION`) and inline code refs in
  Cursor's ` ```start:end:path ` form.
- You want it posted on a specific PR with the right review event,
  inline anchors, and an addressing line that mentions the PR author.

## When NOT to use

- You haven't written the review yet — see `blassioli-code-reviewer`.
- You want to triage existing review comments — see `babysit`,
  `get-pr-comments`.
- You want to open a PR — see `gh-pr-creator`.

## Quick start

1. Ensure `gh auth status` is green and you have `repo` scope.
2. Stage your review markdown anywhere readable (often `.work/review.md`).
3. Invoke the skill with the review file and a PR URL or
   `owner/repo#N`.
4. The skill will:
   - parse findings + code refs,
   - decide the review event from the verdict,
   - stage a payload to `.work/gh-review-...json`,
   - show a preview and ask to confirm,
   - post via `gh pr review` (single body) or `gh api` (multi-comment),
   - return strict JSON with the new review URL.

## Files

- `SKILL.md` — agent instructions.
- `metadata.json` — version + abstract.
- `CHANGELOG.md` — release history.
- `references/` — decision matrix, severity mapping, parsing rules, persona notes.
- `assets/templates/review-payload.json` — REST payload skeleton.
- `scripts/parse-refs.py` — markdown → findings JSON.
- `scripts/post-review.sh` — POST `/reviews` with SHA-drift guard.

## Safety

- Dry-run preview by default; never posts without explicit user confirmation.
- Verifies `headRefOid` matches at post time (aborts on drift unless overridden).
- Skips inline comments whose path is not in the PR diff.
- Idempotency marker in the review body lets the skill detect prior runs.

## Authoring

Skill follows the
[`skill-studio-write`](https://github.com/felipeblassioli/agent-skills/tree/main/packs/cursor-skill-studio/skills/skill-studio-write)
authoring contract (bundled skill inside the `cursor-skill-studio`
Cursor pack; supersedes the former `writing-cursor-skills` root skill
per ADR-0005). Edit `SKILL.md` directly; deploy via `bash scripts/skill-sync.sh --skill=gh-post-code-review`.
