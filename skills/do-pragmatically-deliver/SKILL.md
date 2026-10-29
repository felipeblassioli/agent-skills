---
name: do-pragmatically-deliver
description: Own an epic end to end and autonomously deliver it in verifiable slices, starting by reconciling the epic against work that already landed, is in flight, or was superseded. Use whenever someone hands over an epic, initiative, milestone, or multi-story GitHub issue and wants progress rather than a plan to approve — "deliver epic #688", "own this end to end", "just get this done", "/do-pragmatically-deliver <epic>" — or any ask that names a parent issue and expects the decisions and unknowns to be owned rather than asked about. Also use when picking up an epic mid-flight in a later session, or when an epic's scope no longer matches the code and needs reconciling before more work is added to it.
---

# Pragmatically deliver an epic

You own `<epic>` — the code, the decisions, the unknowns, and the proof it works. It
was handed to you because someone wants progress, not a plan to approve.

Read it first. A GitHub issue: `gh issue view <n> --comments` plus its sub-issues. Prose:
what the user wrote *is* the epic. Everything below assumes you know what it actually asks
for, including its acceptance criteria and what it declares out of scope.

## You are operating autonomously

The user is not watching and cannot answer mid-task, so "Want me to…?" just stops the
work. For reversible actions that follow from the epic, proceed. Before ending your turn,
read your own last paragraph: if it is a plan, an analysis, a question, a list of next
steps, or a promise about work you haven't done ("I'll…", "let me know when…"), that is
unfinished work — do it now, with tool calls. End your turn when a slice is delivered, or
when you are blocked on something only the user can provide.

Genuinely blocking: credentials, production writes and anything another team executes by
hand, a product decision that changes what the thing *is*, and work that can only happen
in a repo or system you cannot reach. Nearly everything else is yours — architecture,
sequencing, naming, what to cut, which invariant to protect, whether a shim earns its
keep. When you hit an unknown, decide it and record the decision and its reversal cost
where a maintainer will meet it. A recorded decision is worth more than a deferred
question.

## Start by reconciling, not building

Epics rot. The most expensive way to fail here is to build something that already sits in
an open PR, or to deliver a story whose premise a merge last week invalidated. So before
any code:

Walk everything the epic references *and* everything that plausibly overlaps — sub-issues,
linked PRs open and merged and closed-unmerged, recent commits on the main branch, and
issues sharing the epic's nouns even when nothing links them. Judge each against the code
as it is now, never against its own description. Then label it:

- **landed** — prove it from the symbol, test, route, or migration in main, not from the
  merge. Then say whether its issue or PR is still open: landed code sitting under an open
  issue is the commonest rot you'll find and the cheapest thing you'll fix all day
- **in flight** — which PR, how close, what it's blocked on
- **superseded** — a different change already achieved this
- **redundant** — two artifacts doing one job
- **stale premise** — still open, but reality moved underneath it
- **still real** — genuinely remaining work

While you're in there, check the epic's acceptance criteria are still achievable *here*.
Some will turn out to live in another repo or another team's system — that isn't blocked on
a human, it's out of your reach: deliver the part that is in reach and name the remainder
as work of its own.

Then reconcile: rewrite the epic's scope so it describes what is actually left. Tick off
what landed, point at what's in flight, say plainly what is now out of scope and why, and
correct any claim the epic makes about itself that the code contradicts — that correction
is part of the job, not an overstep. Put it where the next person will hit it: the epic's
own body and checklist plus one comment, never a scratch file. Keep it to *one* comment and
edit that one if you revise it; two overlapping reconciliations are worse than either
alone. For anything outside the epic you were handed — closing a sibling issue, retargeting
someone's PR — propose rather than perform, whoever authored it. Being the author is not
the same as having asked.

Usually the remainder is large and you go deliver the first slice. But if reconciliation
shows the epic is already done, or that what's left is one small thing, say so and stop.
That is a successful outcome, not a short turn.

## Then deliver, one slice at a time

Take the smallest slice that is coherent end to end — the behavior works across every
boundary it touches, instead of relocating the unresolved part downstream — and actually
finish it: code, test, PR, evidence. Then take the next one. Keep one slice in flight *that
you own*; a stack of four half-finished PRs is worth less than one merged. Work the epic
already had in flight before you arrived doesn't count against you — unblock it or route
around it, but don't idle behind it.

You are delivering into someone's codebase, so follow its conventions for branches,
worktrees, commits, PR bodies and CI, and use its own skills where it has them rather than
inventing a parallel way of working.

Name the falsifier before you write the code: the test, assertion, query, log line, or
metric that would show you were wrong. If you can't name one, building it is the first
slice. "Tests pass" is only true if you ran them and read the output — say which command,
and if something is red, say that plainly instead of reporting around it. If you verify in
a fresh worktree or container, budget for the install — a monorepo can cost ten minutes —
rather than improvising a shortcut, and confirm your toolchain is really resolving *that*
checkout. Dependencies borrowed from the tree you copied from hand you phantom failures,
and worse, phantom passes.

Spend your rigor where mistakes don't come back: persistence, contracts other people call,
credentials, authorization, idempotency, ownership. Move fast in internals you could
rewrite tomorrow. When you run out of room, cut features and convenience — never an
invariant.

## Leave the epic resumable

An epic rarely finishes in one turn and the next session starts cold, so keep the state in
the epic itself: what landed, what's open and where, what you decided and why. Then report
what shipped, what behavior changed, how it was verified, what's still open, and the single
next slice.
