# GSD Token Economy And Skill Routing

## Sources

- [gsd-build/get-shit-done#2792](https://github.com/gsd-build/get-shit-done/issues/2792) - namespace meta-skills, keyword-tag descriptions, and context utilization guard proposal.
- [gsd-build/gsd-2#5546](https://github.com/gsd-build/gsd-2/pull/5546) - merged implementation of provider-boundary token auditing, request-time tool scoping, prompt-visible skill filtering, and capped repeated workflow context.
- [Token consumption savings evidence](https://github.com/gsd-build/gsd-2/blob/main/docs/token-consumption-savings-evidence.md) - measured audit buckets used by the PR.

## Executive Summary

The GSD work converges on one practical rule: agent capability should stay
available, but prompt-visible routing surfaces must be small, relevant, and
measured at the final provider boundary.

Issue #2792 frames the architectural direction: replace flat eager listings
with hierarchical or lazy routing, make descriptions keyword-dense routing tags,
and warn when context utilization approaches the point where reasoning quality
can degrade.

PR #5546 implements the operational version in GSD-2: measure the final payload,
scope tools per request, filter visible skills without unloading them, cap
repeated workflow context, and keep a full-tools escape hatch for cases where
the narrow surface is insufficient.

## What The Issue Proposed

The issue argues that the main problem is not only verbose descriptions or too
many skills, but a flat eager architecture that asks the model to route across a
large surface every turn.

Key proposals:

- Namespace meta-skills: expose a handful of router skills such as workflow,
  project, review, context, manage, and ideate, then route inside that namespace
  to the leaf skill.
- Keyword-tag descriptions: use compact, pipe-separated phrases optimized for
  model routing instead of human prose.
- Context utilization guard: warn around 60% context usage and hard-warn around
  70%, treating context pressure as a quality risk, not only a cost concern.

The estimated prompt-listing reduction in the proposal was large: 86 eager
entries collapse to 6 namespace entries, moving the full install close to the
minimal install's prompt cost while preserving capability.

## What The PR Implemented

The merged PR attacks the same class of problem closer to the provider boundary:

- `PI_TOKEN_AUDIT=1` emits metadata-only payload summaries after final prompt
  construction and tool filtering.
- VS Code/sidebar display separates cumulative session spend from live context
  utilization, avoiding misleading "context percentage" UI.
- Request-time tool filtering narrows the provider-compatible tool surface just
  before send.
- GSD workflow, auto, guided, run, and doctor paths get scoped tool surfaces,
  with `PI_GSD_FULL_TOOLS=1` as an escape hatch.
- Prompt-visible skill filtering narrows `<available_skills>` without unloading
  skills from the runtime.
- Repeated workflow protocol, hidden context, task summaries, replan blockers,
  doctor-heal reports, memory, and knowledge payloads use capped excerpts.

Measured evidence from the PR:

| Surface | Tool count avg | Tool schema chars avg | Custom chars avg | Estimated input tokens avg |
| --- | ---: | ---: | ---: | ---: |
| Initial minimal-tools sample | 44 | 43,971 | 55,657 | 45,504 |
| Auto before strict scoping | 105 | 80,272 | 25,025 | n/a |
| Auto after strict scoping | 15 | 17,224 | 22,026 | n/a |
| `gsd-auto` run 5 | 15 | 16,818 | 16,499 | 20,775 |
| `gsd-run` run 5 | 102 | 76,520 | 104,122 | 73,367 |
| `gsd-doctor-heal` run 5 | 103 | 76,953 | 29,468 | 46,309 |

Tool-result replay stayed at zero in sampled logs, so replay compression was
deferred. This is a useful constraint: optimize the bucket that is actually hot,
not the one that merely sounds plausible.

## Distilled Patterns

### Measure Where The Model Actually Pays

Token estimates inside intermediate layers can be misleading. The useful audit
point is the final provider payload, after hooks, prompt assembly, context
transforms, compatibility filtering, and request-specific scoping.

For skill and pack work, this means audits should ask: what is visible to the
model on the hot path, not only what files exist in the repository.

### Separate Availability From Visibility

A skill or tool can remain installed, callable, and documented while being
hidden from the default routing surface. This preserves capability without
making the model repeatedly filter irrelevant choices.

This distinction maps directly to skill-pack design:

- Installed surface: everything the pack can provide.
- Prompt-visible surface: only the small set needed for the current routing
  decision.
- Explicit invocation surface: escape hatch for advanced or rare paths.

### Prefer Hierarchical Routing Over Flat Menus

Large flat menus impose a recurring decision tax. A router-first design reduces
the active choice set, then expands only inside the selected namespace.

For skill studio, this supports the current consolidated entry-point model:
`skill-studio-write`, `skill-studio-audit`, and `skill-studio-maintain` are
better hot-path surfaces than many first-class root skills.

### Optimize Descriptions For Routing

Descriptions are model-routing metadata, not marketing copy. Compact
keyword/tag descriptions often preserve intent with lower token cost and less
ambiguity.

Good routing descriptions:

- stay short;
- use task nouns and user intent phrases;
- avoid "Use when..." boilerplate;
- move flags, options, and procedure into references or argument hints.

### Cap Repeated Context, Preserve Pointers

Repeated protocols, reports, knowledge files, and task summaries should be
excerpted or capped by default. The prompt should carry the decision-relevant
slice plus a pointer to the source, not repeatedly inline the full document.

### Keep An Escape Hatch

Scoped surfaces can be wrong. GSD's `PI_GSD_FULL_TOOLS=1` preserves an explicit
way to bypass narrow request surfaces. Skill packs should document similar
escape hatches when aggressive scoping could hide a valid path.

## Implications For Cursor Skill Studio

### Add Token-Economy Review To Audits

`skill-studio-audit` can grow a token-economy check that reviews:

- number of hot-path entry points;
- frontmatter description length and keyword quality;
- whether rare procedures are in references instead of `SKILL.md`;
- whether installed capability is being confused with prompt-visible routing;
- duplicated workflow text across bundled skills, agents, rules, and READMEs.

The output should be a short ranked set of reductions with expected behavior
risk, not a broad rewrite request.

### Make Routing Surface Design Explicit

`skill-studio-write` already routes across greenfield, reference distillation,
pack scaffolding, external intake, Claude-plugin adaptation, and eval loops.
Future guidance should explicitly name this as a router pattern and ask authors
to decide:

- what is the minimal first-hop routing surface;
- which leaf capabilities should stay explicit-only;
- which details belong in references rather than the entry `SKILL.md`;
- what fallback should expose the full surface when routing is uncertain.

### Add Evidence Templates

Skill Studio could benefit from a lightweight evidence template modeled after
the GSD PR:

- baseline hot-path prompt-visible assets;
- before/after description length or token estimate;
- repeated-context buckets found;
- files moved from hot path into references;
- behavior checks or eval prompts used to verify routing still works.

This keeps optimization tied to evidence rather than aesthetics.

### Treat UI Copy Carefully

The PR's distinction between cumulative session spend and live context
utilization applies to docs too. Skill Studio documentation should avoid
presenting total tokens, installed artifact count, or repository size as direct
proxies for live prompt pressure.

## Follow-Up Candidates

- Add a `docs/research/` intake convention for source links, distilled patterns,
  and possible skill-pack changes.
- Add a Skill Studio reference on "routing surface design" with examples of
  flat skills, consolidated routers, and explicit-only leaves.
- Add an audit checklist item for frontmatter descriptions: short, tag-like,
  intent-rich, and free of procedural detail.
- Add a pack verification helper that reports hot-path `SKILL.md` size,
  description length, bundled skill count, and duplicate routing language.
- Consider a context-pressure warning pattern for long-running authoring or
  audit sessions, especially when the session accumulates plans, reviews, and
  generated evidence.

## Open Questions

- How should Cursor packs represent prompt-visible scoping when the runtime does
  not expose the same hooks as GSD-2?
- Should Skill Studio prefer three stable routers forever, or add namespace
  routers only when a branch has grown beyond a manageable decision surface?
- What threshold should trigger a description rewrite: characters, estimated
  tokens, ambiguity, or measured routing failures?
- Can a simple local script estimate enough hot-path pressure to be useful, or
  does this require runtime/provider-boundary telemetry?
