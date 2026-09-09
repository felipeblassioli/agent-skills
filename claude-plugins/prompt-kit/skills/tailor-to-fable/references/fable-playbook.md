# fable-playbook.md

The transform moves for `tailor-to-fable`, in full. Each move names the
**profile field** it reads (the volatile fact lives in
`~/.claude/model-profiles.md`, never here), the **prompt-audit rule** it aligns
with, and — where Anthropic publishes a ready-made block — the **canonical
snippet** to link to. Per the profile's own note, *link to the snippets at
`profile.source_url`; do not inline them* (they are volatile and not ours to
copy).

Mental model: the escalation-tier model is a collaborator smarter than the prompt
author. The transform removes what a smarter collaborator does not need (spelled-
out procedure, effort nagging, status scaffolding) and adds what an autonomous,
long-running one does (boundaries, progress-auditing, a memory surface, room to
orchestrate) — while avoiding the two moves that quietly demote it (reasoning
extraction, rejected params).

## Moves

### M1 — Frame the problem, withhold the solution
- **Reads:** `prescription_posture` (brief on Fable — over-prescription degrades).
- **Aligns:** prompt-audit R2 (prescription-posture).
- **Do:** State the outcome, the hard constraints, and the evidence to work from.
  Delete a prescribed step sequence. If the original prompt was a numbered
  procedure, collapse it to the goal + the invariants that must hold.
- **Keep:** genuine constraints and acceptance criteria are not over-prescription
  — a smarter collaborator still needs to know what "done" and "in bounds" mean.

### M2 — Strip inherited scaffolding
- **Reads:** profile notes ("skills tuned for prior models are often too
  prescriptive here and can degrade output").
- **Aligns:** prompt-audit R6 (effort-not-wording), R7 (stale-scaffolding).
- **Remove:** "think step by step / think hard / be extremely thorough" (that is
  the effort lever, M7), "summarize progress every N tool calls," rigid output
  templates for exploratory work, and behaviour enumerations copied from
  Opus/Sonnet-era prompts.

### M3 — Guard the long leash
- **Reads:** `verbosity: runs-long`; notes "can take unrequested actions" and
  "audit progress claims against tool results."
- **Do:** State boundaries explicitly — files/systems not to touch, actions that
  need approval before execution (anything outward-facing or irreversible). Add
  one line: audit each progress claim against actual tool results before reporting
  it done. This is the anti-fabricated-status move for long autonomous runs.
- **Snippet:** link the *progress-audit* and *boundaries* blocks at
  `profile.source_url`.

### M4 — Never ask it to echo reasoning
- **Reads:** `refusal_triggers.reasoning_extraction`, `fallback`.
- **Aligns:** prompt-audit R3 (reasoning-echo-trap, severity `block`).
- **Do:** Remove any "show / explain / transcribe / walk me through your
  reasoning as the response." It can trip the refusal and cause a **silent
  fallback to `profile.fallback`** — the run looks like Fable but is not. If the
  user needs reasoning visibility, read the adaptive thinking blocks and surface
  progress via a send-to-user tool, not by making reasoning the answer.

### M5 — Enable orchestration
- **Reads:** `subagent_posture: spawns-readily`.
- **Aligns:** prompt-audit R8 (orchestrator-subagent-posture).
- **Do:** If the work decomposes, frame it as parallelisable and authorise
  long-lived subagents / async orchestration. Say which parts are small enough to
  do directly, so it does not over-delegate trivially direct work.
- **Also do — pin the subagents' tier.** A subagent whose `model` is unset inherits
  the caller's, so authorising fan-out from the escalation tier silently runs every
  delegated unit there. Observed: four subagents ran on the escalation tier because
  their orchestrator did, on briefs that already carried the method — i.e. units
  that were scoped enough to route down. Instruct the run to resolve
  `delegation_aliases[tier]` per unit and pass it explicitly. (prompt-audit R12
  blocks the omission.)

### M6 — Give it a memory file
- **Reads:** profile note ("performs well with a place to write/reference
  lessons — a markdown memory file").
- **Do:** For multi-hour or multi-phase runs, point it at a markdown file to
  record decisions, dead ends, and lessons, and to re-read before major steps.

### M7 — Set the run config, not worded effort
- **Reads:** `effort_default` (high; xhigh for capability-sensitive),
  `thinking_default` (adaptive-only — summarized output, no extended-thinking
  budgets), `rejected_params`, `fallback`.
- **Aligns:** prompt-audit R6 (effort-not-wording), R9 (rejected-params).
- **Do:** Emit the run config as configuration — `effort: high|xhigh`,
  `thinking: adaptive`, drop any rejected params (they 400), configure the
  server/client-side fallback. Do not encode effort as adjectives in the prompt.

### M8 — Coverage-first for review/finding tasks
- **Reads:** profile note on literal filtering.
- **Aligns:** prompt-audit R10 (review-literal-filtering).
- **Do:** For a review/audit/finding task, ask for full coverage with confidence +
  severity at the finding stage; move filtering/ranking to a separate downstream
  step. "Only high-severity" at finding time drops recall on a literal follower.

## Refusal caution
`profile.refusal_triggers` also lists domain areas (e.g. offensive-cyber,
bio/life-sciences) where even benign work can trip a refusal → silent fallback.
When the task is in that territory, flag it: the tailored prompt cannot guarantee
the run stays on the escalation model.

### M9 — When the target is a fresh session, emit a handoff brief
- **Reads:** `execution_signals.session_lifecycle.hand_off` + `.externalize`.
- **Aligns:** prompt-audit R13 (context-assumed-not-carried, severity `block`).
- **When:** `model-recommender` answered `where: fresh_session` — you want an
  independent re-derivation, not a stronger model inside a transcript whose framing
  you already distrust. The brief *is* the externalized state; write it to a file.
- **Do:** the brief must stand alone. Sections, in the order that worked:

  1. **Title = the defect as a claim**, not a request to look at something.
  2. **Who is asking, and what you want back** — an independent read, not
     confirmation.
  3. **Your own retracted errors, stated plainly, then: assume another one exists
     and go find it.** This is the move that earns the handoff. Without it the fresh
     session tends to ratify your framing; with it, it hunts.
  4. **"Treat everything below as a hypothesis, including the numbers"** — name
     which numbers came from your own queries and are worth re-deriving.
  5. **Orientation** — the system, then the defect as you currently frame it, then
     the consequence chain.
  6. **Evidence, and the instruments that produced it** — plus **the confound you
     must reproduce**: the thing that already fooled you once.
  7. **What constrains the fix** (invariants, compatibility, operational limits).
  8. **Your current leaning, labelled as the thing you most want challenged**, with
     the alternatives you can see and have *not* properly evaluated.
  9. **Still open**, each item with its reachability — a log retention window, a
     stale checkout, a query engine's missing features. An open question nobody can
     reach is not an open question.
  10. **How to verify independently** — every path named, and the environment's
      sharp edges (stale branches, tool version limits).
  11. **Boundaries** — what is read-only, what needs approval, what must not leave
      the machine. M3 lands here.
  12. **What you need back** — coverage-first (M8), plus "what would have to be true
      for you to change your mind" and "what in my evidence does not hold up."
  13. **Autonomy close** — work end to end, fan out (M5) with tiers pinned,
      audit progress claims against tool results (M3), keep a lessons file (M6).

- **Label every premise `verified` or `assumed`.** The value of a fresh context is
  independent derivation, and it cannot re-derive what it cannot separate from
  assertion. This is the R13 discipline.
- **Cost note:** a handoff is not a saving on its own — the fresh session re-reads
  what it needs. It pays off because it starts from a short prefix and a corrected
  frame (`meta.context_cost_rule`), not because it skips work.

## Anti-over-tailoring
A strong, already-outcome-oriented prompt needs little. If the input is a
well-framed hard problem with clear boundaries, the honest output is a small
diff (usually M4 + M7) — not a rewrite. Wanting to gut a good prompt means the
transform miscalibrated; recheck before emitting.

The same restraint applies to M9: a handoff brief is long because it must be
self-contained, not because length is the point. The one that worked ran ~200
lines for a multi-week investigation. A one-hour problem does not need that, and a
brief padded past what the receiving session must know is just context cost paid
twice.
