---
name: smart-prompt
description: >-
  Shapes a loose intent into a well-formed prompt for a Claude Code session that
  can gather context, use tools, and ask questions. Matches the intent to a
  validated archetype, fills its slots (objective, context to gather, anchors,
  clarify-first questions, acceptance criteria, verification, output contract),
  routes the tier via model-recommender, and self-checks the result with
  prompt-audit. Use when you have a rough idea of what to ask an agent and want
  it reshaped to hit a specific goal, when you type /smart-prompt with a loose
  instruction, or to turn "read X and study Y to figure out Z" into an
  executable agentic prompt.
---

# smart-prompt

> **Requires** the bundled `references/prompt-archetypes.md` (the archetype
> catalog) and the sibling skills `model-recommender` (tier routing) and
> `prompt-audit` (self-check). Routing reads `~/.claude/model-profiles.md` via
> model-recommender; if that file is absent, still shape the prompt and name the
> routing archetype, but flag the model string as unresolved — never guess one.

Turn a loose intent into the best-shaped prompt for an agent that can gather
context, use tools, and ask questions. smart-prompt **authors** the structure
the user did not write; it does not run the task. (Contrast: `prompt-audit`
critiques a prompt that already exists and fixes violations conservatively;
smart-prompt builds a prompt from an intent and a goal.)

## What a shaped prompt contains — the universal slots

Every strong agentic prompt fills these; the archetype tunes which matter most:

- **Objective** — the goal as an outcome, not a script of steps.
- **Context to gather** — concrete first moves (read these files, grep for X,
  glob Y) so the agent anchors on real code before acting.
- **Anchors / constraints** — patterns to match, boundaries to stay inside, what
  not to touch.
- **Clarify-first** — questions to ask the user *before* acting, when the intent
  is ambiguous or expensive to get wrong.
- **Plan / Do at the right altitude** — outcome-level instruction, not
  step-locked prose that throttles the agent's own judgment.
- **Acceptance criteria** — how the agent and the user know it is done.
- **Verification** — the command or check that proves it.
- **Output contract** — what to return, and in what shape.
- **Stop conditions** — when to stop and report instead of pressing on.

## Procedure

1. **Read the intent and the goal.** The text after `/smart-prompt`, or the
   loose request, is the intent. Name the specific goal it reaches for.
2. **Match an archetype.** Load `references/prompt-archetypes.md`, parse its
   ```yaml `catalog` block, and match the intent against each archetype's
   `intent_signals`. Pick the best fit. If none fits, shape from the universal
   slots directly and mark it a candidate new archetype (see growth-loop).
3. **Gather light context — cheaply.** If the intent names real paths or repos
   (e.g. `refs/README.md`, a cloned project), glance at them (Read/Glob/Grep)
   only enough to make the shaped prompt's "Context to gather" steps concrete and
   correct. This is shaping, not doing — implement nothing here.
4. **Route the tier.** Call `model-recommender` on the underlying task to resolve
   its archetype → tier + effort. Emit the tier name; let model-recommender own
   the model string. Never write a model string into the shaped prompt.
5. **Fill the slots.** Instantiate the archetype's skeleton with the intent's
   specifics. Bake "ask before X" into the prompt where the clarify-first slot
   calls for it. Keep the altitude high — specify outcomes, not keystrokes.
6. **Self-check with prompt-audit.** Run `prompt-audit` on the shaped prompt and
   apply its fixes, so what is emitted would pass its own linter. Never emit a
   prompt that trips a `block`.
7. **Emit**, then **offer capture** (see growth-loop).

## Output

```
Archetype: <archetype-id>  →  routing: <tier> tier, effort <effort>
```

Then the shaped prompt in a fenced block, ready to paste or run as its own
session. Then a one-line audit note (`prompt-audit: clean`, or the fixes
applied). Then the capture offer.

## Growing the catalog from real use

After emitting, **offer to record the case** to the ledger — this is how the
catalog learns which shapes actually worked. Capture rules, the ledger format,
and the human-gated promotion path (ledger → a new validated archetype + a
regression eval) live in `references/growth-loop.md`; load it when capturing or
promoting.

**Confidentiality (hard rule).** The ledger and any promoted archetype must be
sanitized — strip secrets, credentials, and internal hostnames/IPs, and minimize
personal data before writing. Promoted archetypes land in a public catalog;
generalize away anything project-internal.

## Composition

- `model-recommender` — owns tier/effort/model; smart-prompt calls it and never
  restates routing data or a model string.
- `prompt-audit` — owns prompt critique; smart-prompt calls it as the final gate,
  so it authors prompts that pass the linter rather than duplicating its rules.
- Both read `~/.claude/model-profiles.md`; smart-prompt inherits that single
  source of truth transitively and hardcodes nothing.
