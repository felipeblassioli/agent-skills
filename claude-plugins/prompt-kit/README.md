# prompt-kit

A personal Claude Code plugin that codifies the prompt work I otherwise do by
hand in chat: **model routing**, **prompt quality**, and **prompt authoring**.
The skills read from one shared, self-refreshing reference so they never drift
from each other — or from my `loop-compiler` plugin.

## Skills

All are namespaced under the plugin once enabled:

- **`prompt-kit:model-recommender`** — give it a task; it returns the durable
  verdict first (archetype → tier + effort + one-line reason), then resolves
  today's model string. Recommends per phase when a task spans plan / implement
  / review.
- **`prompt-kit:prompt-audit`** — give it a draft prompt (optionally a target
  model); it adversarially finds what will underperform (archetype mismatch,
  unstated "above and beyond", negative instructions, missing success criteria
  or "why", structure that wants XML tags or examples) and returns tagged
  findings plus a rewritten, linter-fixed prompt.
- **`prompt-kit:smart-prompt`** — give it a *loose intent* (e.g. `/smart-prompt
  read refs/README.md and study X and Y to anchor an implementation`); it matches
  a validated archetype and shapes the intent into a full agentic prompt
  (objective, context to gather, anchors, clarify-first, acceptance, verification,
  output contract), routing the tier via `model-recommender` and self-checking
  with `prompt-audit`. It **authors** structure (generative) where `prompt-audit`
  **critiques** an existing prompt (adversarial); the two compose. It learns from
  use — after each shaping it offers to capture the case to an external,
  never-committed ledger, and recurring generalizable cases are promoted (with
  your approval) into its bundled catalog.
- **`prompt-kit:tailor-to-fable`** — give it a prompt *or* a rough idea when you
  have already decided to run the escalation-tier model (Fable 5 today) on a hard,
  ambiguous, long-horizon problem (e.g. `/tailor-to-fable <an over-prescribed
  prompt>`); it commits to that target and runs one directed transform —
  un-prescribe (state the problem, drop the step-script), strip scaffolding
  inherited from literal-following models, set boundaries + progress-auditing for
  long autonomous runs, avoid the reasoning-extraction refusal that silently falls
  back to Opus, enable subagent orchestration, and emit the run config
  (effort/thinking/fallback) instead of wording effort into the prompt. It reads
  the escalation model and its posture from `model-profiles.md` (hardcodes
  nothing) and gates through `prompt-audit`.

The four compose: `model-recommender` picks the model, `smart-prompt` shapes an
any-tier prompt, `prompt-audit` gates the result — and when the answer is "the
smartest model on a hard problem," `tailor-to-fable` tunes the prompt to that
target's posture.

## The shared source of truth lives in `~/.claude`, not in this plugin

`model-recommender` and `prompt-audit` — and `loop-compiler` — read
**`~/.claude/model-profiles.md`** at runtime (`smart-prompt` inherits it
transitively via `model-recommender`; `tailor-to-fable` reads it directly to
resolve the escalation tier and that model's posture). It is deliberately
**outside** the plugin so multiple tools share one copy. It contains:

- **§1 Routing rubric** (durable): archetype → tier + effort. Names *tiers*,
  never model strings.
- **§2 Tier → model table** (volatile): **the only place a concrete `claude-*`
  id appears.**
- **§3 Per-model profiles** (volatile): behavioral deltas + `source_url` +
  `last_verified`.
- **§4 Staleness rule** (durable): before advising, if a needed profile is
  missing or older than its `last_verified` window, fetch its canonical page and
  refresh it.

### Durable vs volatile — the governing principle

Cross-model prompting technique (XML structure, examples, stating the "why", the
current-generation shift to literal instruction-following) is **durable** and
embedded in the skills. Per-model deltas and concrete model strings are
**volatile** and externalized to `model-profiles.md`, which self-refreshes.
**Nothing in this plugin hardcodes a model id or a per-model tip** — so nothing
rots on the next model release; only §2/§3 of the shared file do, and they
refresh on their own.

If `~/.claude/model-profiles.md` does not exist, create it before first use (the
skills read it at runtime). This repo ships a template —
[`model-profiles.example.md`](model-profiles.example.md) — to copy and adapt:

```bash
cp claude-plugins/prompt-kit/model-profiles.example.md ~/.claude/model-profiles.md
# then set meta.reviewer and refresh §2/§3 per meta.staleness_rule
```

The example's model strings and per-model profiles are a **snapshot** captured on
their `last_verified` dates; they go stale on the next model release and
self-refresh in the live file via the staleness rule. Do not treat the committed
dates as current.

## Local install

This is a personal plugin, distributed by path — no marketplace required.

```bash
# Run Claude Code with the plugin loaded from disk:
claude --plugin-dir /path/to/agent-skills/claude-plugins/prompt-kit

# Or, from a checkout of this repo, point at the plugin directory directly.
```

Alternatively, add it through the `/plugin` interface as a local plugin, or drop
it into a personal marketplace. Because `.claude-plugin/plugin.json` sets a
`version`, updates only land when the version is bumped.

**Verify it loaded:** start a session and check the skills trigger —
ask "which model should I use to design a rate limiter?" (should fire
`model-recommender`), "audit this prompt: …" (should fire `prompt-audit`),
`/smart-prompt <a loose intent>` (should fire `smart-prompt`), and
`/tailor-to-fable <a prompt>` (should fire `tailor-to-fable`). Skill edits to
`SKILL.md` take effect immediately in-session; other changes (hooks, new files)
need `/reload-plugins` or a restart.

A **SessionStart guard** (`hooks/check-model-profiles.sh`) fails loudly at the
session boundary if `~/.claude/model-profiles.md` is missing, so a fresh install
surfaces the missing dependency up front instead of mid-audit. It is silent when
the file is present.

## Governance / promotion

Each skill ships `metadata.json` (version + org-free author + abstract),
`CHANGELOG.md`, and an `evals/` suite (`evals.json` + a `baselines/` snapshot) so
it can be promoted into a governed marketplace. The iteration-0 baselines are
honest bootstraps — they record only the cases actually run and mark the full
with-vs-baseline benchmark as pending; see each skill's `evals/baselines/`.

## Layout

```
prompt-kit/
├── .claude-plugin/
│   └── plugin.json                     # manifest (name, version, author — org-free)
├── hooks/
│   ├── hooks.json                      # SessionStart guard registration
│   └── check-model-profiles.sh         # warns if ~/.claude/model-profiles.md is missing
├── skills/
│   ├── model-recommender/
│   │   ├── SKILL.md                    # routing procedure (parses the shared file at runtime)
│   │   ├── metadata.json · CHANGELOG.md
│   │   └── evals/                      # evals.json + baselines/
│   ├── prompt-audit/
│   │   ├── SKILL.md                    # adversarial audit procedure + output contract
│   │   ├── prompt-audit-rules.md       # the rule set (R1–R11) loaded at runtime
│   │   ├── metadata.json · CHANGELOG.md
│   │   └── evals/                      # evals.json + baselines/
│   ├── smart-prompt/
│   │   ├── SKILL.md                    # shaping method + universal slots + composition
│   │   ├── references/
│   │   │   ├── prompt-archetypes.md    # the validated archetype catalog (loaded at runtime)
│   │   │   └── growth-loop.md          # ledger format + human-gated promotion
│   │   ├── metadata.json · CHANGELOG.md
│   │   └── evals/                      # evals.json + baselines/
│   └── tailor-to-fable/
│       ├── SKILL.md                    # escalation-tier transform + composition
│       ├── references/
│       │   └── fable-playbook.md       # the transform moves + canonical snippet pointers
│       ├── metadata.json · CHANGELOG.md
│       └── evals/                      # evals.json + baselines/
├── docs/
│   ├── goal.md                         # purpose + definition of done
│   └── evidence.md                     # verification log
└── README.md
```
