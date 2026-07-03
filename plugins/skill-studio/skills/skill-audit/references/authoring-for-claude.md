# Authoring for Claude (instruction craft)

## Contents

- [1. Right altitude — don't railroad Claude](#1-right-altitude--dont-railroad-claude)
- [2. Think through setup (first-run config)](#2-think-through-setup-first-run-config)
- [3. Don't state the obvious — earn the context](#3-dont-state-the-obvious--earn-the-context)
- [4. Build a gotchas section](#4-build-a-gotchas-section)

These practices are about *how a skill's instructions are written for a model to
read* — the prose in `SKILL.md` and `references/` — not its scope or packaging
(those are the four principles in [principles.md](principles.md)). A skill can
pass all four structural principles and still behave badly because of how its
instructions are written: pitched at the wrong altitude, or silent about the
context it needs from the user. Audit the body against each practice below; cite
the offending prose as evidence and route the rewrite to `skill-maintainer`.

## 1. Right altitude — don't railroad Claude

Claude follows instructions closely, and a skill is reused across situations its
author never saw. Over-specified, step-locked instructions make the model
brittle: it marches through hardcoded steps even when the situation calls for a
different path. Give the model the information and constraints it needs, then let
it choose how to get there.

Pitch instructions at the right **altitude**:

- **Too low (railroading):** a numbered script of exact commands for work that
  needs judgment. Breaks the moment reality differs from the author's mental
  model.
- **Too high (vague):** "handle the cherry-pick" with no goal, no constraints, no
  definition of done. The model has nothing to anchor on.
- **Right altitude:** state the goal, the hard constraints, and what "done" looks
  like; leave the path to the model.

Example — cherry-picking a commit:

> **Too prescriptive (railroaded)**
> 1. Run `git log` to find the commit.
> 2. Run `git cherry-pick <hash>`.
> 3. If there are conflicts, run `git status` to list them.
> 4. Open each conflicting file.
> 5. For each `<<<` marker, decide which side to keep.
> 6. Run `git add` on each resolved file, then…

> **Better**
> Cherry-pick the commit onto a clean branch. Resolve conflicts preserving
> intent. If it can't land cleanly, explain why.

The rewrite names the goal (cherry-pick onto a clean branch), the constraint
(preserve intent), and the escape hatch (explain why if it can't) — and trusts
the model with mechanics it already knows.

### When exact steps ARE right

Precision is not the enemy — *misplaced* precision is. Spell out the exact thing
when the model genuinely can't infer it and getting it wrong is costly:

- non-obvious flags, env vars, IDs, endpoints, magic strings, or ordering that
  matters
- safety gates and confirmations before irreversible actions
- API / contract specifics the model can't guess

The test: would a competent engineer, given the goal and constraints, reliably
choose this step themselves? If yes, state the goal, not the step. If no (it's
non-obvious, or unsafe to get wrong), spell it out.

### Railroading vs. "make it a script"

This interacts with context efficiency ([principles.md](principles.md) §3):

- If the railroaded steps are **judgment work** (e.g. resolving conflicts by
  intent), the fix is to *raise the altitude* — goal + constraints, not steps.
- If they are **genuinely mechanical and deterministic** (same commands every
  time, no judgment), the fix is to move them into a **script**, not to keep them
  as prose steps. Prose step-lists for mechanical work are the worst of both:
  brittle like a script, unreliable like prose.

### Audit signals (judgment — the checker can't see this)

- long numbered step-lists in `SKILL.md` that hardcode exact commands for work
  that obviously needs judgment
- instructions enumerating every branch of a decision tree the model could
  navigate itself
- "do exactly X" with no stated goal, so the model can't adapt when X doesn't fit
- brittleness: the steps assume one repo layout, one error shape, one happy path

This is typically a **warn** (a quality smell), escalating to **fail** only when
the railroading would plausibly make the skill do the wrong thing in a common
variation.

**Fix routing:** quote the over-prescriptive passage, give the goal+constraints
rewrite (or "move to a script" when the work is mechanical), and hand it to
`skill-maintainer`.

## 2. Think through setup (first-run config)

Some skills need context only the user has — which Slack channel to post to, a
project ID, an API base URL. Don't hardcode it (it breaks for everyone else) and
don't re-ask on every run. The pattern: read a `config.json` from the skill dir
at the top of `SKILL.md`, ask the user if it's missing, persist their answers,
and proceed from the saved config thereafter.

Example (`standup-post`):

> ## Your config
> !`cat ${CLAUDE_SKILL_DIR}/config.json 2>/dev/null || echo "NOT_CONFIGURED"`
>
> ## Instructions
> If the config above is `NOT_CONFIGURED`, ask the user which Slack channel and
> for a sample standup they liked, then write the answers to
> `${CLAUDE_SKILL_DIR}/config.json`. Otherwise, post to the saved channel using
> the saved format.

The `` !`...` `` line runs as a shell command before Claude reads the prompt, so
the config (or `NOT_CONFIGURED`) is already in context when the instructions are
read. For structured, multiple-choice setup questions, instruct Claude to use the
**AskUserQuestion** tool rather than free-text prose — it gives the user a clean
choice UI and a more reliable answer.

### Plugin caveat: where written config lives

The example writes config into the skill dir, which is ideal for a *personal*
skill. Plugin skills are different: they are copied to a **cache**
(`${CLAUDE_SKILL_DIR}` resolves there — see [principles.md](principles.md) §2–3).
Reading bundled defaults from that path is fine, but user config *written* into
the cached skill dir is machine-local and can be wiped on `claude plugin update`
or reinstall, and is never shared across a team. For a distributed plugin skill,
prefer a user- or project-scoped config path that survives updates — and never
ship one user's real values to every installer.

### Audit signals (judgment — the checker can't see this)

- a skill that needs user/environment context but hardcodes it, or fails/guesses
  when it is absent instead of asking
- **a committed, populated `config.json`** shipping one user's real values
  (channel, IDs, tokens) to everyone — config should ship absent or as a template
  and be written at first run
- multiple-choice setup questions asked as free-text prose where AskUserQuestion
  would be cleaner
- (plugin) user config written into `${CLAUDE_SKILL_DIR}` with no acknowledgment
  that the cache copy is ephemeral and per-machine

Usually a **warn**; a committed `config.json` leaking real user values (or a
token) is a **fail** — a maintainability and privacy problem, not just a smell.

**Fix routing:** name the missing setup step or the leaking file, give the
detect-ask-persist rewrite (and the durable config location for plugin skills),
and hand it to `skill-maintainer`.

## 3. Don't state the obvious — earn the context

Claude already knows how to code and can read the repo. A skill that restates
what the model would do by default adds tokens without adding value — and worse,
dilutes the signal that *is* novel. A knowledge skill earns its place only by the
non-obvious: project- and domain-specific facts, surprising invariants, and taste
that pushes the model off its defaults.

The test for every line: **would Claude reliably do this anyway, without being
told?** If yes, cut it. If the model's default diverges from what's correct here,
keep it — that divergence is the whole value.

Worth its context (pushes the model off its priors):

- gotchas and surprising defaults — "proration rounds DOWN, not to nearest cent";
  "idempotency keys expire after 24h, not 7d"; "refunds need the charge ID, not
  the invoice ID"
- non-obvious invariants and ordering — "test-mode skips the `invoice.finalized`
  hook"
- taste that diverges from the model's defaults — Anthropic's frontend-design
  skill was built by iterating with customers to steer Claude away from its go-to
  patterns (the Inter font, purple gradients)

Not worth its context (the model already does this):

- general coding/process advice — "write clean code", "add tests", "handle errors"
- paraphrased public API docs or well-known tool usage — point to the README or
  source instead of restating what the model already has
- a one-line skill that just says "see the README" — no hard-won knowledge yet,
  so it isn't earning a skill

The positive counterpart — *actively cultivating* that non-obvious knowledge in a
**Gotchas** section — is §4.

This is the knowledge-skill twin of §1: §1 says don't dictate the *path* the model
can find itself; this says don't restate the *facts* the model already has. Both
come down to respecting what Claude knows and spending context only where it
changes behavior.

### Audit signals (judgment — the checker can't see this)

- a body padded with generic coding/process advice or paraphrased public docs
- a "knowledge" skill that mostly points elsewhere without adding specifics
- the inverse, done well: a dense, specific gotchas/invariants section is a
  strong PASS signal even when the skill is short

Usually a **warn** (wasted context, diluted signal); a skill that is *entirely*
obvious restatement is a **fail** — it should not exist as a skill.

**Fix routing:** point at the obvious passages to cut and name the kind of
non-obvious detail that would make the skill earn its place; hand to
`skill-maintainer`.

## 4. Build a gotchas section

A skill's **Gotchas** section is usually its highest-signal content: the failure
points Claude actually trips on, written down so the next run doesn't repeat them.
This is the positive form of §3 — §3 says cut the obvious; this says cultivate the
non-obvious and keep adding to it. A good gotcha names the **trap, the correct
behavior, and where to check** — specific and falsifiable, not "be careful here".

The traps worth capturing (from real failure modes):

- **Data-model traps** — the schema behaves unlike its shape suggests: "the
  `subscriptions` table is append-only; take the row with the highest `version`,
  not the most recent `created_at`."
- **Identity / naming mismatches across boundaries** — one value, different names:
  "`@request_id` in the API gateway and `trace_id` in the billing service are the
  same value."
- **Lying signals / false success** — a status that doesn't mean what it says:
  "staging returns `200` even when the Stripe webhook didn't actually process —
  check `payment_events` for the real state."

Cultivate it over time: add a line each time Claude trips on something. The skill
compounds in value as it accumulates the surprises a fresh model would miss — a
maintenance behavior, so it pairs with the skill's `CHANGELOG.md` (see
[principles.md](principles.md) §4).

### Audit signals

- `gotchas_section` (checker, **presence only**) — does any heading look like a
  gotchas / pitfalls / caveats section? Whether its **absence** matters is
  judgment: for a Library & API Reference, Data & Analysis, or integration skill,
  no gotchas section is a **warn** — the highest-signal content is missing, or the
  skill has not been battle-tested. For a pure scaffolding or routing skill it may
  be fine.
- (judgment) vague gotchas ("watch out for X") that don't state the specific trap
  and the correct action are low value; the inverse — specific, falsifiable
  gotchas with where-to-verify — is a strong PASS signal.

**Fix routing:** for a knowledge skill missing gotchas, recommend seeding one from
known failure modes; for vague gotchas, recommend rewriting each as trap + correct
behavior + where-to-check. Hand to `skill-maintainer`.
