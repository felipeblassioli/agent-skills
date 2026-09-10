# prompt-kit

An experimental personal Claude Code plugin for routing advice, prompt authoring
and prompt review. It recommends decisions; it does not switch models, intercept
Agent calls or guarantee cost savings. Its shared profile file is refreshed by
agents following instructions, not by an autonomous updater.

## Skills

- **`prompt-kit:model-recommender`** — chooses placement (`session`, `delegate`,
  `fresh_session`) separately from tier and supported effort. Checks effective
  model selection and reassesses failed runs before changing capability.
- **`prompt-kit:smart-prompt`** — shapes loose intent into an agentic prompt and
  checks it with `prompt-audit`. Passes the chosen tier to the handoff writer.
- **`prompt-kit:prompt-audit`** — returns tagged findings and a corrected prompt.
  `block` is an audit-output severity, not deterministic runtime enforcement.
- **`prompt-kit:tailor-to-fable`** — explicit escalation-tier prompt tailoring,
  plus a fresh-session handoff mode that preserves the selected tier and effort.
  A fresh context can use the same model; the skill name does not upgrade it.

The skills preserve user authorization and profile-supported settings. Independent
investigation can confirm a conclusion, refute it, find no additional defect, or
remain inconclusive. A handoff must not require an error to exist.

## Shared profiles

The skills and `loop-compiler` read `~/.claude/model-profiles.md`. The installed
copy is outside this repository; this PR does not update it. To install the
example manually, first preserve any existing configuration:

```bash
mkdir -p ~/.claude
cp -n claude-plugins/prompt-kit/model-profiles.example.md ~/.claude/model-profiles.md
# Set meta.reviewer and refresh the snapshot against the intended runtime.
```

The file contains fenced YAML mappings. Consumers merge the top-level mappings:

- `routing_rubric` and `execution_signals`: experimental decision policies.
- `staleness_rule` and `context_cost_rule`: **top-level**, not under `meta`.
- `tier_to_model` and `delegation_aliases`: Claude-specific target bindings.
- Per-model profiles: explicit `model_id`, `tier`, `delegation_alias`, supported
  settings, source URLs and separate API/prompting verification dates.

Model and alias identifiers are repeated in profile identity fields so the guard
can reject a mapping to an absent or mismatched profile. These are snapshots,
not proof of current model availability or the installed tool schema. Legacy
profiles without either identity field remain supported: the hook checks unique
tier coverage, while consumers verify the candidate profile's key/source against
the resolved target before quoting model-specific settings or posture. If identity
cannot be verified, routing can still propose a target but withholds profile advice.
Legacy structural acceptance does not certify model/alias identity. Once any
identity field is added, every profile must supply both; partial adoption warns.
Likewise, `reassess_when` and `reassess` are optional together. Without them,
consumers treat legacy `escalate_when` events as reassessment triggers, not proof
that stronger capability is needed. No installed-file migration is required.
Keep aliases and API parameters scoped to the harness/version where verified.

An omitted subagent call parameter may resolve through an intentional named-agent
configuration. Check definition/default precedence and applicable restrictions;
only actual task/usage metadata establishes which model executed. Read the
[Claude subagent reference](https://code.claude.com/docs/en/sub-agents#choose-a-model)
for version-dependent behavior rather than assuming universal inheritance.

## Load and validate

```bash
claude --plugin-dir /path/to/agent-skills/claude-plugins/prompt-kit
```

Ask for a model recommendation or invoke a namespaced skill to check discovery.
That smoke check does not prove routing quality. The plugin version controls
cached updates; restart or reload after changing the plugin.

The SessionStart hook emits additional context when the profile is missing or
structurally inconsistent. It checks fenced YAML, required policy blocks, tier
coverage, and (when the identity extension is present) exact model/profile identity
and agreement of delegation aliases. It
stays silent on a consistent file. It is advisory and returns exit 0 even for a
warning; it never blocks an Agent invocation.

Dependencies: Python 3 and **Mike Farah yq v4**. Missing dependencies report that
validation is unavailable. Dates are checked by the consuming skills when using
a profile, rather than generating repeated startup staleness warnings.

```bash
bash claude-plugins/prompt-kit/hooks/check-model-profiles.sh claude-plugins/prompt-kit/model-profiles.example.md
python3 claude-plugins/prompt-kit/hooks/tests/test-model-profiles.py
```

The hook accepts an optional file path for isolated validation; SessionStart uses
the installed default. Tests never modify that installed file or call a model.

## Evidence and provider scope

The transcript analysis in [evidence.md](docs/evidence.md) motivated the policy.
Its list-price counterfactuals do not establish savings, subscription billing or
quality equivalence. Synthetic hook tests prove structural checks only. Per-skill
`evals/evals.json` files specify behavioral cases; their existence is not a passed
benchmark. Earlier bootstrap results remain in `evals/baselines/`.

The recommendation is to retain a shared decision procedure with separate Claude
and Codex profiles and runtime instructions, **after a bounded evaluation**.
Codex packaging, configuration and end-to-end routing are not implemented here.
See [portability and evaluation recommendation](docs/portability.md) for the
capability boundary, representative comparisons and stop conditions. The later
context-admission/cache project is independent of these corrections.
