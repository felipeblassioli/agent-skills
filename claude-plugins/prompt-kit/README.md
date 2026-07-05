# prompt-kit

A personal Claude Code plugin that codifies two things I otherwise do by hand in
chat: **model routing** and **prompt quality**. Both skills read from one shared,
self-refreshing reference so they never drift from each other — or from my
`loop-compiler` plugin.

## Skills

Both are namespaced under the plugin once enabled:

- **`prompt-kit:model-recommender`** — give it a task; it returns the durable
  verdict first (archetype → tier + effort + one-line reason), then resolves
  today's model string. Recommends per phase when a task spans plan / implement
  / review.
- **`prompt-kit:prompt-audit`** — give it a draft prompt (optionally a target
  model); it adversarially finds what will underperform (archetype mismatch,
  unstated "above and beyond", negative instructions, missing success criteria
  or "why", structure that wants XML tags or examples) and returns tagged
  findings plus a rewritten, linter-fixed prompt.

## The shared source of truth lives in `~/.claude`, not in this plugin

Both skills — and `loop-compiler` — read **`~/.claude/model-profiles.md`** at
runtime. It is deliberately **outside** the plugin so multiple tools share one
copy. It contains:

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
skills read it at runtime). A reference copy is maintained alongside my dotfiles.

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
`model-recommender`) and "audit this prompt: …" (should fire `prompt-audit`).
Skill edits to `SKILL.md` take effect immediately in-session; other changes
(hooks, new files) need `/reload-plugins` or a restart.

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
│   └── prompt-audit/
│       ├── SKILL.md                    # adversarial audit procedure + output contract
│       ├── prompt-audit-rules.md       # the rule set (R1–R11) loaded at runtime
│       ├── metadata.json · CHANGELOG.md
│       └── evals/                      # evals.json + baselines/
├── docs/
│   ├── goal.md                         # purpose + definition of done
│   └── evidence.md                     # verification log
└── README.md
```
