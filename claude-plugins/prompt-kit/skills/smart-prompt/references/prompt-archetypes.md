# Prompt archetypes — the validated catalog

Shapes for prompts that run in a Claude Code session (the agent gathers context,
uses tools, asks questions). This file is the runtime data for `smart-prompt`:
parse the ```yaml `catalog` block, match the loose intent against each
archetype's `intent_signals`, then fill its `skeleton` with the universal slots
from `SKILL.md`.

Two provenance levels:

- **validated** — curated, sanitized, public-safe; earned its place (used on real
  work, passes `prompt-audit`, has a regression eval).
- **candidate** — seeded from the method but not yet earned through real use;
  promote via `growth-loop.md` once a real case proves it.

`routing` names a `model-recommender` **tier** (`deliberation` / `execution` /
`recon` / `escalation`), an effort, and a `where` (`session` / `delegate`) —
**never a model string, and never an Agent-tool alias.** Phased shapes list a
`phases` sequence; `smart-prompt` routes each phase independently, so a phase may
be delegated while the shape as a whole runs in the session. These are defaults:
`model-recommender` owns the final call, and `routing_rubric.consequence_override`
can raise a tier the catalog suggested.

```yaml
catalog:
  - id: context-anchored-planning
    provenance: validated
    intent_signals:
      - "study / read X and Y to learn how they do Z, then plan"
      - "anchor an implementation on an existing pattern or exemplar"
      - "turn a fuzzy goal into a reviewable implementation plan"
      - "plan before touching code (get-it-right-once)"
    routing:
      tier: deliberation
      effort: high
      where: session
    phases:
      - tier: recon        # gather the exemplars cheaply
        effort: low
      - tier: deliberation # extract the pattern, then plan
        effort: high
    slot_emphasis:
      - context-to-gather       # the anchors ARE the point; be concrete
      - anchors                 # name the patterns to match
      - acceptance-criteria     # a plan is done when it is reviewable
      - output-contract         # emit a plan artifact, not code
    skeleton: |
      Objective: produce an implementation plan for <goal>, anchored on how
      <exemplars> already <do the thing>. Plan only — write no product code.

      Context to gather (do this first, read-only):
      - Read <entry docs / README(s)>.
      - Study <exemplar A> and <exemplar B>: how they <gather context / structure
        the flow / enforce the contract>. Grep for <the mechanism>.
      - Note the concrete pattern each uses; cite file:line.

      Anchors / constraints:
      - Match <the established pattern> rather than inventing a new one.
      - Stay inside <scope>; do not refactor <out-of-scope area>.

      Clarify-first: if <the key ambiguity> is unresolved, ask before planning.

      Deliverable (output contract):
      - A plan: goal, the extracted pattern (with citations), the steps at
        outcome altitude, acceptance criteria, and the verification command.
      Acceptance: a reviewer can approve or reject the plan without reading code.

  - id: codebase-cartography
    provenance: validated
    intent_signals:
      - "map / explore an unfamiliar area or subsystem"
      - "where does X live / how does Y flow through the code"
      - "summarize how this repo does Z"
      - "read-only orientation before deciding anything"
    routing:
      tier: recon
      effort: low
      where: delegate
    slot_emphasis:
      - context-to-gather
      - output-contract         # a structured map, not a fix
      - stop-conditions         # do not start changing things
    skeleton: |
      Objective: map <area> and return a structured summary. Read-only — change
      nothing.

      Context to gather:
      - Glob / grep for <entry points, key terms>.
      - Read the files that own <the behavior>; trace <the flow> end to end.

      Output contract: entry points, the flow (as steps or a short list), the
      key files (file:line), and the one or two surprises worth knowing.
      Stop condition: stop at the map — do not implement or refactor.

  - id: investigation-diagnosis
    provenance: validated
    intent_signals:
      - "why is X failing / this breaks in prod but not locally"
      - "find the root cause of <error / stack trace>"
      - "diagnose before fixing"
    routing:
      tier: deliberation
      effort: high
      where: session
    phases:
      - tier: recon        # reproduce and localize
        effort: low
      - tier: deliberation # hypothesize and confirm
        effort: high
    slot_emphasis:
      - context-to-gather       # reproduce first
      - acceptance-criteria     # a confirmed cause, not a guess
      - clarify-first
    skeleton: |
      Objective: find and confirm the root cause of <symptom>. Diagnose first;
      propose a fix only after the cause is confirmed.

      Context to gather:
      - Reproduce <symptom> with <the smallest case>. Capture the actual output.
      - Isolate: bisect / trace / read the code path around <the failure point>.

      Method: state a hypothesis, then find the evidence that confirms or refutes
      it. Do not fix on a hunch.
      Clarify-first: if the environment or the expected behavior is unclear, ask.
      Acceptance: the cause is named with evidence (file:line, a repro, a log),
      and the proposed fix follows from it.

  - id: scoped-implementation
    provenance: validated
    intent_signals:
      - "implement <this already-specified unit>"
      - "make the change and prove it with <a check>"
      - "on-rails edit with a clear done-condition"
    routing:
      tier: execution
      effort: high
      where: delegate
    slot_emphasis:
      - acceptance-criteria
      - verification            # the named command that exits 0
      - anchors                 # match the codebase; stay in scope
    skeleton: |
      Objective: <the specific change>, scoped to <these files / this unit>.

      Context to gather: read <the touched files> and the nearest existing
      analog; match its style.

      Constraints: change only <scope>; do not alter public signatures / <X>.
      Acceptance: <the observable done-condition>.
      Verification: `<command>` exits 0. Run it; if it fails, iterate until green.
      Output: a summary of what changed and the verification result.

  - id: tracker-driven-epic-delivery
    provenance: validated          # promoted 2026-09-09 from 3 ledger candidates
    intent_signals:
      - "deliver this epic / tracking issue end to end, not a plan for it"
      - "work through the child issues in dependency order, one PR each"
      - "continue execution of a multi-item plan I already approved"
      - "own it autonomously and make the calls; open PRs as you go"
    routing:
      tier: deliberation           # the owner. Child units route independently.
      effort: xhigh
      where: session
    axes:
      # This shape has two dials. They are what distinguished the three ledger
      # candidates it replaces; collapsing them into one archetype with axes beat
      # keeping three near-duplicates.
      cadence:
        per-unit-gate: >
          stop after each reviewable unit and wait. Choose when the units are
          coupled, the plan is unproven, or a wrong unit is expensive to unwind.
        boundary-gated: >
          run to completion inside a stated boundary list; human checkpoints come
          from PR review, not from the loop. Choose when units are independent and
          each lands behind a review gate anyway.
      orchestration:
        single-agent: one agent owns every unit. Simpler; no constraint can be lost in a handoff.
        owner-orchestrator: >
          the owner keeps the judgment and delegates each scoped unit, pinning
          effective model selection per unit (matching definition or supported explicit
          call value). Verify actual usage rather than assuming savings; bound the
          owner's context — but every delegated brief must stand alone
          (prompt-audit R12/R13).
    slot_emphasis:
      - anchors                   # the tracker items ARE the spec; do not restate them
      - acceptance-criteria       # each item's own criteria, verbatim
      - verification              # a named command per unit, run before claiming done
      - boundaries                # what needs approval; what must never happen
      - output-contract           # one reviewable unit (usually one PR) per item
    skeleton: |
      Objective: deliver <epic / tracking item> end to end — <N> child items in
      the dependency order stated there, one reviewable unit per item.

      The spec of record is the tracker, not this prompt. Each child item carries
      its own scope, acceptance criteria, and definition of done; read them and
      treat them as authoritative rather than re-deriving them from here. If an
      item's stated decision proves wrong against the real code, stop and report
      instead of quietly re-deciding it.

      Before starting, reconcile: which items already landed, are in flight, or
      were superseded. Deliver what remains.

      Environment preconditions (a fresh session cannot rediscover these cheaply):
      - <worktree / checkout layout, and the command form that respects it>
      - <build or bootstrap step needed in a fresh working copy>
      - <CI gates that constrain the unit: title conventions, template checkboxes>

      Per unit: <the verification command>. Verify each done-claim against actual
      tool output — CI result, test output — before reporting it as done.

      Boundaries: <the hard list — no production mutations; never merge your own
      unit; items whose artifact requires human review by design>.

      Cadence: <per-unit gate | boundary-gated, per the axes above>.

      Keep a lessons file at <path>: corrections and confirmed approaches, with why
      each mattered, so the next pass does not start from zero.

      Deliverable: one reviewable unit per child item, each independently
      verifiable, plus a short close-out of what landed, what was deferred and why.

  - id: adversarial-review
    provenance: validated
    intent_signals:
      - "review this diff / PR / change"
      - "what's wrong with this before it merges"
      - "coverage-first, severity-ranked findings"
    routing:
      tier: deliberation
      effort: high
      where: session
    slot_emphasis:
      - output-contract         # ranked findings with confidence
      - anchors                 # judge against acceptance criteria
    skeleton: |
      Objective: review <the diff / PR> for correctness, safety, and whether it
      meets <its acceptance criteria>. Cover the whole change before filtering.

      Context to gather: read the diff and the code it touches; find the tests.

      Output contract: findings ranked most-severe first, each with a severity
      and a confidence and a file:line. Report full coverage — do not pre-filter
      to "only high-severity" (that drops recall); let the reader filter.
```

## Flagship example — `context-anchored-planning`

The before/after that seeded this archetype (both referenced projects are
public, so this example is public-safe):

**Loose intent (`/smart-prompt ...`):**

> read refs/README.md and study gsd-core and obra/superpowers cloned in this refs
> directory to know how they gather context to anchor an implementation
> (plan → implementation plan)

**Shaped prompt (emitted):**

```
Objective: produce an implementation plan for anchoring our implementation flow
on how gsd-core and obra/superpowers gather context. Plan only — write no code.

Context to gather (read-only, do this first):
- Read refs/README.md for how the refs dir is laid out.
- Study refs/gsd-core and refs/obra-superpowers: how each gathers context before
  it commits to an implementation (what it reads, in what order, how it decides
  it has "enough"). Grep for the context-gathering / planning entry points; cite
  file:line for each mechanism you find.
- Extract the shared pattern and where the two differ.

Anchors / constraints:
- Anchor the plan on the pattern these two actually use; do not invent a new one.
- Scope the plan to the context-gathering → plan step; exclude execution.

Clarify-first: if "our implementation flow" maps to more than one place in this
repo, ask which one before planning.

Deliverable (output contract):
- A plan: the goal, the extracted context-gathering pattern (with citations from
  both projects), the steps at outcome altitude, acceptance criteria, and the
  verification for the plan.
Acceptance: a reviewer can approve/reject the plan without reading the source.
```

```
Archetype: context-anchored-planning  →  routing: deliberation tier, effort high
(gather phase → recon/low; plan phase → deliberation/high)
prompt-audit: clean
```

Note how the shaping added everything the loose intent left implicit: read-only
first, cite-your-anchors, a clarify-first gate, an explicit plan-not-code output
contract, and a done-condition — the difference between "go do a thing" and a
prompt an agent can execute well and a human can review.

## Adding or refining an archetype

New archetypes are **earned**, not invented at will — see `growth-loop.md`. When
one is promoted: add its entry here (with `provenance: validated`), bump the
skill version and CHANGELOG, and add a regression case under `evals/`.
