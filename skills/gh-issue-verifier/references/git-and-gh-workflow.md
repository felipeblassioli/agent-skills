# Git And GH Workflow

## Purpose

Use `gh` as the primary source for issue, PR, and repository context, then use git to confirm whether the codebase actually reflects the claimed fix.

## Primary Workflow

1. Run the evidence collector script first.
2. Confirm `repo_detected`, `repo_autodetected`, and any `api_errors` or truncation flags in the script output.
3. Read the issue body, labels, timeline clues, linked PRs, and linked commits.
4. Determine the verification mode:
   - issue-only
   - issue-vs-branch
   - issue-vs-pr
5. Inspect the target PR or branch if one is provided.
6. Inspect recent git history for related commits and touched files.
7. Open the most relevant code, docs, and tests for direct inspection.

## Command Strategy

Use the script first for low-noise collection:

```bash
bash scripts/collect-evidence.sh --issue 123
```
(from skill root)

Use `gh` directly only when the script output leaves ambiguity.

Preferred direct commands:

```bash
gh issue view 123 --repo owner/name --json number,title,body,url,state,labels,author
gh pr view 456 --repo owner/name --json number,title,url,state,mergedAt,headRefName,baseRefName,files
gh api repos/owner/name/issues/123/timeline?per_page=100 -H "Accept: application/vnd.github+json"
```

Use `jq` projections to keep output compact.

When the script reports:

- `repo_autodetected: true`
  confirm the repository matches the intended target before trusting the rest of the output
- `has_more_candidate_prs: true`
  treat linked-PR-derived file discovery as bounded, not exhaustive
- `has_more_candidate_files: true` or `has_more_candidate_tests: true`
  widen carefully instead of assuming the current candidate set is exhaustive
- `api_errors`
  treat missing evidence as potentially inaccessible, not necessarily absent

Use `gh` for:

- issue metadata
- issue body
- issue timeline clues
- linked PRs
- linked commits
- PR details and changed files

Use git next for:

- recent history in the affected area
- file-level diffs
- commit-level proof
- branch comparison when needed

## Search Window

- Start with script-provided candidates and the most likely recent history window.
- If results are ambiguous, widen the window before concluding no evidence exists.
- Record when the search window had to be widened because that lowers confidence in direct traceability.
- Prefer bounded widening such as 90 days to 180 days before exploring older history.

## Issue-Only Mode

In issue-only mode:

- verify whether the current codebase state appears to satisfy the issue
- inspect likely changed areas even if there is no linked PR
- do not assume current behavior from repository metadata alone
- if candidate files are empty, extract issue fingerprints and search with `rg` before widening to broad exploration

## Issue-vs-Branch Or PR Mode

In comparison mode:

- inspect the target branch or PR first
- determine whether the diff maps to the issue's problem statement and acceptance criteria
- verify whether tests in the target directly cover the scenario
- note any mismatch between issue scope and actual diff scope
- prefer target diff files over repository-wide search until ambiguity remains

## Escalation Rules

- If the issue text is vague, use linked PR discussion and commit context to narrow interpretation, but keep ambiguity visible.
- If GitHub links conflict with the inspected code, trust the inspected behavior more than the links.
- If the target PR is merged but the current branch differs materially, report that mismatch.
- If direct commands produce large output, project them through `jq` or return to the script path.

## Links

- Parsing rules: `issue-parsing.md`
- Evidence ranking: `evidence-ranking.md`
- Review targets: `code-docs-tests-review.md`
