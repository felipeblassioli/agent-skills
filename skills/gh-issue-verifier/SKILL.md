---
name: gh-issue-verifier
description: Verify whether a GitHub issue is implemented in the current codebase by collecting evidence from the GitHub issue, git history, docs, code, and tests, then producing a structured report with verdict, proof, gaps, confidence, and scope-clarity doubts. Use when the user asks whether an issue was resolved or whether a branch or PR truly satisfies an issue. Do not use for fixing code, implementation planning, or generic PR review.
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
- generic code review without a concrete issue-verification target
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

## Verification Modes

### Issue-only

Determine whether the current codebase state appears to satisfy the issue.

### Issue vs branch or PR

Determine whether a specific branch or PR appears to satisfy the issue, and whether the evidence is strong enough to claim resolution.

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
2. Decide whether verification is issue-only or issue-vs-branch-or-PR.
3. Inspect only the top candidate files and candidate tests from the script output.
4. Read additional reference docs only when needed:
   - `issue-parsing.md` if the issue is vague
   - `code-docs-tests-review.md` when checking implementation logic
   - `evidence-ranking.md` and `verdict-rubric.md` when choosing the verdict
   - `scope-clarity-audit.md` when issue quality is weak
5. Widen the search only if the initial evidence is ambiguous or contradictory.
6. Record evidence for and against resolution.
7. Produce a strictly observational report with:
   - verdict: `RESOLVED`, `NOT RESOLVED`, or `INCONCLUSIVE`
   - evidence of fix
   - documentation status
   - test coverage status
   - residual risks or gaps
   - confidence level
   - scope clarity doubts

## Minimal Execution Path

Default path:

1. Run `scripts/collect-evidence.sh --issue <number>` (from skill root; or from repo root: `skills/gh-issue-verifier/scripts/collect-evidence.sh`).
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

## Evidence Budget

- Start with the script output, not raw command output.
- Prefer summaries and short file lists over pasting terminal output.
- Avoid reading all reference docs in one pass.
- Avoid opening more files once the verdict can already be justified honestly.
- Prefer `INCONCLUSIVE` over expanding the search without a strong reason.

## Evidence Hierarchy

Use stronger evidence before weaker evidence:

1. direct code-path inspection
2. targeted tests for the reported scenario
3. issue-linked PR or branch diffs
4. linked commits and timeline discussion
5. documentation or changelog updates
6. commit-message intent without direct proof

Do not treat lower-ranked signals as sufficient proof when higher-ranked checks are missing or contradictory.

## Delegation Policy

Use a faster subagent for bounded grunt work when available:

- collecting issue, PR, and commit facts
- narrowing candidate files and tests
- summarizing linked timeline evidence

Keep the main agent responsible for:

- interpreting ambiguity
- weighing contradictory signals
- choosing the verdict
- writing the final report

If a subagent is used, require it to return compact structured output rather than prose dumps.

## Confirmation Policy

- Do not suggest code fixes or refactors.
- Do not claim resolution from weak signals alone.
- Treat missing or ambiguous evidence as a reportable gap.
- Use `INCONCLUSIVE` when the evidence is insufficient.
- Keep recommendations strictly observational:
  - missing proof
  - missing tests
  - missing docs
  - scope ambiguity

## Verification Checklist

- [ ] The skill applies only when there is a concrete issue-verification target.
- [ ] `gh` is used as the preferred source when available.
- [ ] The correct reference doc is read for parsing, workflow, evidence, verdict, and scope audit.
- [ ] The final report uses the template shape from `assets/templates/verification-report.md`.
- [ ] The report stays strictly observational.
