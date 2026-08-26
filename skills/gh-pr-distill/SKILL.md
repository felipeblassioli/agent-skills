---
name: gh-pr-distill
description: Rewrite a PR body around what a reviewer actually needs. Use for "distill this PR", "tighten the description", "this body is a thesis", or after a long implementation session where the PR body grew with the investigation.
---

# Distill a PR body

A reviewer arrives with the diff open and finite attention.

Apply one question to every paragraph, bullet, table row, and proof:

**If this disappeared, would a competent reviewer be materially worse at reviewing this PR?**

If not, remove it.

## Workflow

1. Read the diff, linked issue/context, current body, and required template.
2. Run the question over the existing body.
3. Rewrite what survives from the final understanding of the change. Preserve conclusions; discard the investigation chronology.
4. Preserve the repository's required sections, markers, and language.

## What usually disappears

- Diff narration and file inventories.
- Investigation chronology.
- CI, worktree, and tooling history.
- Exhaustive test counts.
- Repeated evidence for an already-supported claim.
- Performative rigor.
- Implementation details that do not change how the diff should be reviewed.

## What usually survives

- Why the change exists.
- The observable behavioral change.
- Non-obvious decisions and the invariants they protect.
- Where reviewer attention is actually needed.
- The strongest verification evidence.
- Meaningful scope boundaries, accepted risks, and known gaps.

## Guardrails

- Optimize for reviewer understanding, not shortness.
- A subtlety that determines correctness earns its lines.
- Preserve honest gaps such as "not run", "inconclusive", or accepted risk. Removing them turns uncertainty into an implied pass.
- Do not introduce claims unsupported by the diff or other verified context.
- Required template sections and markers stay even when their useful content is brief.
