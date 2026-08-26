# gh-pr-distill

Maintainer notes. The skill itself is [SKILL.md](SKILL.md).

## What it is

A small skill in the [cursor-team-kit](https://github.com/cursor/team-kit) register — one
deletion test, a four-step workflow, two lists, guardrails. It rewrites a PR body around
what a reviewer needs and drops what they can get faster from the diff.

It is deliberately *not* the whole PR workflow. Related skills:

- **`gh-pr-creator`** — authoring a body inside a templated repo: comment markers, `.work/`
  staging, the honesty rules about fabricated evidence and human-only checkboxes.
- **`gh-pr-make-reviewable`** — the same distillation discipline at much greater depth:
  diagnose-before-rewrite, worked before/after rewrites, a context-collection script.
  Reach for that one when a body resists distillation; reach for this one by default.

## Why this shape

Five candidates were drafted before this one. The shipped body is a hybrid of two of them:
the deletion test from **C** as the organizing principle, with the keep/cut lists from **B**
demoted to illustrations of that question rather than rules of their own.

That ordering matters. In B the lists *are* the skill, so a shape not on a list has no
verdict. In C the question is the skill and the lists are examples, so an unfamiliar
paragraph still gets judged. B's lists were kept because the question alone left too much to
run-to-run variance.

Two guardrails were added that appear in neither candidate brief: honest gaps survive the
rewrite (removing a "not run" turns uncertainty into an implied pass), and the rewrite
introduces no claim the diff doesn't support. Both exist because a shortening pass eats
exactly those two things first.

The rejected candidates are recorded below rather than described, so a future editor can
judge the tradeoff instead of taking this note's word for it.

## Candidate B — keep/cut lists as the spine

```markdown
---
name: gh-pr-distill
description: Rewrite a PR body around what a reviewer actually needs, and cut what they can get faster from the diff. Use for "distill this PR", "tighten the PR description", "this body is a thesis", or before asking someone to review a long branch.
---

# Distill a PR body

A reviewer arrives with the diff open and finite attention. Everything in the body competes with the code for it.

## Keep

- Why the change exists — the concrete failure or need, not "improve X".
- The observable behavioral change: response, side effect, schema, timing, error.
- Non-obvious decisions, and the invariants they protect.
- What deserves attention — say where the risk actually is.
- The single strongest piece of verification.
- Scope boundaries and known gaps.

## Cut

- Diff narration and file-by-file lists.
- Investigation chronology: what you suspected first, what you tried next.
- CI and worktree history.
- Exhaustive test counts.
- The second and third piece of evidence for a claim already made.
- Performative rigor: "carefully", "comprehensive", "rigorously verified".
- Implementation detail that does not change how the diff is reviewed.

## Workflow

1. Read the diff, the linked issue, and the current body; note the template and its language.
2. Draft only the Keep list, written from the final understanding of the change.
3. Apply with `gh pr edit --body-file`, or `gh pr create --body-file` when there is no PR yet.

## Guardrails

- Preserve required template sections and comment markers.
- Do not optimize for shortness — a subtlety that decides correctness earns its lines.
- Keep gaps and unrun checks. Removing them silently upgrades a gap into a pass.
- Add no claim the old body and the diff do not already support.
```

## Candidate C — the gate as the whole skill

```markdown
---
name: gh-pr-distill
description: Apply one test to every paragraph of a PR body — if it disappeared, would a competent reviewer be materially worse at reviewing this PR? — and rewrite what fails. Use for "distill this PR", "clean up the description", or after a long session where the body grew.
---

# Distill a PR body

One question decides every paragraph:

**If this disappeared, would a competent reviewer be materially worse at reviewing this PR?**

If not, it goes. That is the whole skill; the rest is how to apply it honestly.

## Workflow

1. Read the diff, the linked issue, and the current body. A paragraph can only be judged against the change it describes.
2. Run the question over every paragraph, table row, bullet, and proof.
3. Rewrite what survives from the final understanding of the change — the reviewer needs the conclusion, not the search that found it.
4. Apply with `gh pr edit --body-file`, or `gh pr create --body-file` when no PR exists.

## What usually fails the test

Diff narration, investigation chronology, CI and worktree history, test-count dumps, a second proof of an already-proven claim, performative rigor, and implementation detail that changes nothing about the review.

## What usually passes

Why the change exists, what observably changed, a non-obvious decision and the invariant it protects, where the risk is, the strongest single verification, and a scope boundary or known gap.

## Guardrails

- The test is about the reviewer, not about length. A subtlety that decides correctness passes even when it is long.
- Required template sections and markers stay, whatever the test says about their contents.
- "Not run", "inconclusive", an accepted risk: these pass the test. Cutting one turns a gap into an implied pass.
- The rewrite may remove and compress. It may not invent evidence the old body and diff do not support.
```

## Not yet done

No evals. The behaviour worth testing is the tension in the guardrails: whether the deletion
test cuts narrative without also cutting correctness-bearing nuance and honest gaps.
`gh-pr-make-reviewable` carries a fixture (`evals/fixtures/thesis-body.md`) built for exactly
that check, and it would work here unchanged.
