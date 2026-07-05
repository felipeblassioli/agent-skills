# Growth loop — capture real wins, promote the good ones

How `smart-prompt` learns from use without leaking anything. Two stores, one
human gate between them:

```
real usage ──capture──▶ ~/.claude/smart-prompt-ledger.md ──promote (human)──▶ references/prompt-archetypes.md
   (raw, private)          (append-only, never committed)      (sanitized, public, versioned)
```

Why split: this plugin lives in a **public** repo. Raw cases hold real work and
may contain project-internal detail. Raw capture therefore stays **outside** the
plugin (in `~/.claude/`, like `model-profiles.md`); only sanitized, generalized
archetypes are promoted into the bundled catalog.

## Capture (the auto-offer after each shaping)

After emitting a shaped prompt, offer to record the case. Record only a **genuine
win** — the shaped prompt was actually run (or the user confirms it is what they
wanted) and it hit the goal. Do not record every shaping; a ledger of noise is
worthless.

**Sanitize before writing (hard rule):** strip secrets, credentials, tokens, and
internal hostnames/IPs; minimize personal data; generalize project-internal names
where they are not essential to the shape. If a case cannot be sanitized without
losing its point, do not capture it.

Append to `~/.claude/smart-prompt-ledger.md` (create it if missing). Format:

```markdown
## <YYYY-MM-DD> · <archetype-id | "candidate:<name>"> · uses:<n>
- intent: <the loose intent, sanitized>
- shaped: <the shaped prompt, sanitized — or the 2–3 slots that mattered most>
- outcome: <what the agent did and whether it hit the goal>
- generalize: yes | no — <one line: would this shape help beyond this task?>
```

For a `candidate:` case (no archetype fit at shaping time), name the shape you
used so recurring candidates are easy to spot.

## Promote (human-gated — never automatic)

Promotion changes a public, versioned file, so it is a deliberate step the user
approves — never done silently during a shaping.

Promote when a ledger pattern has **earned** it:

1. **Recurs** — the same shape shows up across multiple entries (a repeated
   `candidate:<name>`, or an existing archetype used in a new, generalizable way).
2. **Generalizes** — `generalize: yes`, and it is not one project's quirk.
3. **Is safe** — fully sanitized; no project-internal detail survives.

Then:

- Add or refine the entry in `references/prompt-archetypes.md` with
  `provenance: validated`, a clean generic `skeleton`, and `intent_signals` drawn
  from how the real intents were phrased.
- Add a regression case under `evals/` (a loose intent → the archetype it should
  match + the slots the shaped prompt must contain), and record the promotion in
  the iteration baseline.
- Bump the skill `version` and add a `CHANGELOG.md` entry naming the archetype.

Leave the ledger entries in place (mark them promoted); the ledger is the
evidence trail for why the catalog looks the way it does.

## What not to do

- Do not commit the ledger, or paste raw ledger content into the catalog.
- Do not invent archetypes to pad the catalog — an unearned archetype is a
  `candidate` at best, and belongs in the ledger, not the validated set.
- Do not let the catalog and the ledger disagree on an archetype's shape: the
  catalog is the promoted truth; the ledger is raw input to it.
