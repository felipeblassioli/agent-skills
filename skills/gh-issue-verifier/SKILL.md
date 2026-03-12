---
name: gh-issue-verifier
description: Verify whether a GitHub issue is implemented in the current codebase by collecting evidence from the GitHub issue, git history, docs, code, and tests, then producing a structured report with verdict, proof, gaps, confidence, and scope-clarity doubts. Use when the user asks whether an issue was resolved or whether a branch or PR truly satisfies a specific issue. Do not use for fixing code, implementation planning, or generic PR review that is not issue-grounded.
---

# GH Issue Verifier

## Applicability Gate

Use this skill only when the task is to determine whether a specific GitHub issue has been implemented, resolved, or sufficiently covered by the current branch, PR, or codebase state, using verifiable evidence from `gh`, git history, docs, code, and tests.

Use it when the user wants:
- proof that an issue is or is not implemented
- an issue verification report
- gaps, missing evidence, or residual risk
- doubts about issue clarity, scope, or acceptance criteria
- a comparison between an issue and the current branch or PR

Do not use it for:
- fixing code
- implementation planning
- writing or editing PR descriptions
- generic code review or generic PR review without a concrete issue-verification target
- assuming an issue is resolved based only on linked commits or PRs

## Inputs Required

Prefer live GitHub data via `gh`.

Minimum input:
- repository context, if needed
- issue number, or a direct issue URL

Optional comparison target:
- current branch
- PR number or PR URL
- explicit commit range

Fallback when `gh` is unavailable:
- pasted issue title and body

This skill supports both issue-only verification and issue-vs-branch-or-PR verification.

## Routing Table

- Minimal execution path and evidence budget: stay in `SKILL.md`
- Parse the issue and infer missing acceptance criteria: read `references/issue-parsing.md`
- Rank evidence strength and confidence: read `references/evidence-ranking.md`
- Run the `gh`-first verification workflow: read `references/git-and-gh-workflow.md`
- Inspect code, docs, and tests against the issue: read `references/code-docs-tests-review.md`
- Choose the final verdict honestly: read `references/verdict-rubric.md`
- Audit issue clarity and scope quality: read `references/scope-clarity-audit.md`
- Use the report, input, and checklist templates: read `assets/README.md`
- Use or extend the evidence-collection stub: read `scripts/README.md`

## Procedure

1. Run `scripts/collect-evidence.sh` first and use its JSON as the initial fact base.
2. Inspect only the top candidate files and candidate tests from the script output.
3. If the script reports no candidates, derive search anchors from the issue:
   - symbols or function names
   - file paths or directories
   - API routes
   - error strings
   - config keys
   Then search with `rg` in the most likely subsystem before widening further.
4. Read additional reference docs only when needed:
   - `issue-parsing.md` if the issue is vague
   - `code-docs-tests-review.md` when checking implementation logic
   - `evidence-ranking.md` and `verdict-rubric.md` when choosing the verdict
   - `scope-clarity-audit.md` when issue quality is weak
5. Widen the search only if the initial evidence is ambiguous or contradictory.
6. Produce a strictly observational report with:
   - verdict: `RESOLVED`, `NOT RESOLVED`, or `INCONCLUSIVE`
   - evidence of fix
   - documentation status
   - test coverage status
   - residual risks or gaps
   - confidence level
   - scope clarity doubts

## Minimal Execution Path

Default path:

1. Run the collector from the target repository root when possible:
   - `bash skills/gh-issue-verifier/scripts/collect-evidence.sh --issue <number>`
   - If running from the installed skill directory, pass `--repo-root /path/to/repo`
2. Inspect at most 5 candidate implementation files first.
3. Inspect at most 3 candidate test files first.
4. Decide whether more code or history needs to be opened.
5. Read only the minimum reference docs needed to resolve ambiguity.
6. Use `assets/templates/verification-report.md` for the final report.

Only widen the search when:

- no candidate files were found
- the issue is ambiguous
- metadata and code evidence conflict
- the target PR or branch appears only partially related
- the script reports bounded or truncated candidate lists

## Evidence Budget

- Start with the script output, not raw command output.
- Prefer summaries and short file lists over pasting terminal output.
- Avoid reading all reference docs in one pass.
- Avoid opening more files once the verdict can already be justified honestly.
- Prefer `INCONCLUSIVE` over expanding the search without a strong reason.

## Confirmation Policy

Keep the final report strictly observational. Do not suggest code fixes or refactors, do not claim resolution from weak signals alone, and use `INCONCLUSIVE` when evidence is missing, contradictory, truncated, or access-limited.

For evidence ranking and verdict thresholds, read:
- `references/evidence-ranking.md`
- `references/verdict-rubric.md`
