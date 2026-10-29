# Changelog

## 0.2.1 — August 2026

- Verification isolation: added the install *cost* alongside the resolution check.
  v0.2.0 told the agent to confirm its toolchain resolves the fresh checkout but
  never named the ten-minute monorepo install that pushes agents toward the
  symlink shortcut in the first place — the run's feedback item 6 had two halves
  and only one was incorporated.

## 0.2.0 — August 2026

Revised from one real execution against a multi-story epic in a private
repository (all 10 eval assertions passed; the delivered slice's PR went green in
CI). Every change below closes a gap the run actually hit. The eval fixture and
run report describe that private codebase, so they live in a private workspace
rather than in this repository.

- `landed` now carries the issue-hygiene consequence. Six of seven landed
  artifacts on the epic had their issue still OPEN — the single most common
  state, and v0.1.0 had nowhere to put it.
- "someone else's work" re-scoped to "outside the epic you were handed, whoever
  authored it". The user authored every artifact on the epic, so the authorship
  reading licensed closing seven issues and a 26k-line PR unattended.
- "one slice in flight" → "one slice in flight *that you own*". The epic already
  had a 3-PR stack in flight; the literal reading meant idling behind work the
  session didn't create, on an entry point the description explicitly supports.
- Out-of-repo scope added to the blocking list. Two of one story's ACs are
  implementable only in another repo — neither a credential nor a product
  decision, and previously unaddressed.
- Rewriting the epic body is now explicitly sanctioned, and the note is
  explicitly *one* comment you edit. The run posted two overlapping ~6k-char
  reconciliations 56s apart.
- Verification-isolation warning added: symlinking `node_modules` into a fresh
  worktree made relative workspace links resolve back into a dirty checkout and
  produced two phantom type errors. Phantom passes are the worse half.
- Stop-early case reworded so a large remainder reads as the norm, not the
  exception.

## 0.1.0 — August 2026

Initial version.

- Autonomous-operation contract: decide reversible things, record decisions with
  their reversal cost, and the end-of-turn last-paragraph check.
- Explicit block list (credentials, prod/out-of-band writes, product-identity
  decisions, someone else's work) so "autonomous" has a boundary.
- Reconciliation as the warm-up step, with a six-label classification
  (landed / in flight / superseded / redundant / stale premise / still real)
  judged against the code rather than against artifact descriptions.
- Slice delivery with WIP=1, a named falsifier per slice, and rigor spent at
  irreversible seams.
- Resumability: state lives in the epic, not in a scratch file.

Deliberately thin on pragmatism doctrine itself — the 7-bullet "Pragmatic
delivery" section in `~/.claude/CLAUDE.md` is already always-on context, so this
skill covers only the epic-scale mechanics layered on top.
