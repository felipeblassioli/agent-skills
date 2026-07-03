---
description: "Resolve a GitHub bug report end-to-end — fetch the issue, root-cause it, implement a fix on a branch, and open a draft PR linking it. Two hard stops for approval — before any code is written, and before anything is pushed."
argument-hint: "<issue-url | owner/repo#123 | #123 | bug description>"
allowed-tools: Bash, Read, Edit, Write, Grep, Glob, WebFetch, Task, Skill, AskUserQuestion
---

# Resolve a GitHub bug report

Take the bug report in **$ARGUMENTS** from report to merge-ready fix: fetch it,
root-cause it, implement the fix on a branch, and open a **draft** PR that links the
issue. There are two hard stops for human approval — one before any code is written,
one before anything is pushed.

This command orchestrates the `blassioli` diagnosis skills when the bug is a production
error (`error-reporting`, `error-trace-rootcause`, `gcp-log-triage`) and hands the PR
step to `gh-pr-creator` when that skill is available.

## Input

`$ARGUMENTS` may be:

- a GitHub issue URL — `https://github.com/<owner>/<repo>/issues/123`
- a shorthand — `owner/repo#123`, `#123`, or a bare `123` (resolved against the current repo)
- free text — a bug description, a pasted stack trace, or a Cloud Logging / Error
  Reporting URL

If `$ARGUMENTS` is empty, ask which bug to resolve and stop.

## Procedure

### 0. Establish context (read-only)

- Confirm tooling: `gh auth status`, and that the target repo is reachable
  (`gh repo view <owner/repo>`). If `gh` is missing or unauthenticated, stop and say so.
- Resolve the reference and fetch it:
  `gh issue view <n> --repo <owner/repo> --json number,title,body,labels,comments,state,url,assignees`.
  Read the body **and the comments** — repro steps, versions, and the real signal often
  live in the thread, not the title.
- Note linked artifacts: stack traces, failing tests, log / Error-Reporting URLs,
  commit/PR references, and the affected service + environment.

### 1. Reproduce & understand

- Map the report to code with `Grep`/`Glob` and read the relevant files.
- If the report gives repro steps or names a failing test, run them and see the failure
  first-hand. A bug you cannot reproduce or pin to a line is not ready to fix — say
  what's missing and stop.
- If the bug is a **production error** (a log/trace/Error-Reporting URL or a GCP stack),
  invoke the matching sibling skill for a code-level root cause:
  - rank / scope by blast radius → **`error-reporting`**
  - one error → the bug behind it → **`error-trace-rootcause`**
  - noisy logs / "what is actually failing" → **`gcp-log-triage`**

### 2. Root-cause

State the root cause in 1–2 sentences (the **first** failure and why), the exact
`file:line`, and the fix direction. Separate the symptom from the cause — do not patch
the outer `catch` and call it done.

### 3. ⛔ Checkpoint A — approve the plan (before writing any code)

Present: (a) issue identity, (b) reproduction status, (c) root cause + `file:line`,
(d) the proposed fix and its blast radius, (e) the test plan. **Wait for explicit
approval.** If the cause is uncertain or the fix is risky, say so and offer options
rather than guessing.

### 4. Implement the fix

- Branch off the repo's default branch — **never** commit on `main`/`master`. Name it
  `fix/<issue-number>-<short-slug>`.
- Make the **smallest change that fixes the root cause.** Match the surrounding code's
  style and idioms. No drive-by refactors.
- Add or update a test that fails without the fix and passes with it.

### 5. Verify

Run the repo's tests / build / lint for the area you touched. Report results honestly —
if something fails or you skipped a step, say so. Do not claim "fixed" without evidence.

### 6. ⛔ Checkpoint B — approve before pushing

Show the diff summary, the test results, and the intended commit + PR. **Wait for
explicit approval to push.**

### 7. Open the PR (draft)

- Commit with a conventional message that references the issue (e.g. `fix: … (#123)`).
- Push the branch and open a **draft** PR whose body contains `Fixes #<n>` (or `Closes
  #<n>`) so the issue auto-closes on merge.
- Prefer the **`gh-pr-creator`** skill if it is available (it stages the body in `.work/`
  and follows the repo's PR template); otherwise use `gh pr create --draft` with a body
  that walks through **problem → root cause → fix → testing**.
- Return the PR URL.

### 8. Report

Summarize: the issue, the root cause, the fix, the tests, the PR link, and anything left
for the reviewer (follow-ups, risks, anything you could not verify).

## Guardrails

- **Two hard stops** (Checkpoints A and B). Never write code before A; never push before B.
- One issue per run → one focused branch → one draft PR.
- Read-only until Checkpoint A. A diagnosis-only request stops after Step 2.
- Never force-push, never commit to the default branch, and never close the issue by hand
  — let the merge close it.
- If you cannot reproduce or root-cause the bug, stop with a clear "here's what I need."
  A wrong fix is worse than no fix.
