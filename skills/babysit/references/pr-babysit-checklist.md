# PR babysit checklist

Use this as a structured pass when triaging a PR. Skim first; go deep only on failing items.

## Comments

- [ ] List unresolved review threads only (ignore resolved).
- [ ] For each thread: note file/line or permalink, author, and whether it is actionable.
- [ ] Apply fixes only where you agree with the feedback; otherwise reply with a short rationale or ask a clarifying question.
- [ ] Prefer minimal diffs per thread; batch trivial nits when safe.

## Merge conflicts

- [ ] Confirm base branch name (e.g. `main`) and sync strategy (`gh pr merge` / rebase / merge branch — follow repo norms).
- [ ] If conflicts are mechanical (same change intent), resolve.
- [ ] If product intent diverges, stop and ask the user which side to keep.

## CI

- [ ] Identify failing jobs by name; open logs only for failing steps.
- [ ] Fix with the smallest change that addresses the root cause; avoid drive-by refactors.
- [ ] After push, re-check until required checks are green or you have a documented exception.

## Payload discipline

- When using `gh api` or JSON output, filter fields or use `--jq` so you do not load entire thread payloads into context unnecessarily.
