---
name: babysit
description: >-
  Keep a PR merge-ready by triaging comments, resolving clear conflicts, and
  fixing CI in a loop.
disable-model-invocation: true
---
# Babysit PR
Your job is to get this PR to a merge-ready state.

Check PR status, comments, and latest CI and resolve any issues until the PR is ready to merge.

## Merge-readiness report (each loop)

Before you end a turn or pause this workflow, output a short merge-readiness block:

- **PR / branch:** …
- **Unresolved comments:** count; list what still blocks merge (or “none”).
- **Merge conflicts:** none | in progress | needs human (one line why).
- **CI:** green | failing (which checks) | pending.
- **Merge blocked by:** one line, or **ready to merge** if appropriate.

## Workflow

1. Comments: Review every active unresolved comment (including Bugbot) before acting. When fetching GitHub comments, filter out resolved threads first. Read only each comment body and the minimum location/URL needed to act on it; do not read the entire JSON output or other unnecessary payload data. Fix only comments you agree with; explain when you disagree or are unsure.
2. Merge conflicts: When there are conflicts, sync with base branch. Resolve merge conflicts only when intent is clearly the same, otherwise stop and ask for clarification.
3. CI: Fix CI issues that come up with small scoped fixes. Push them and re-watch CI until mergeable + green + comments triaged.

For a structured triage pass, read [references/pr-babysit-checklist.md](references/pr-babysit-checklist.md).
