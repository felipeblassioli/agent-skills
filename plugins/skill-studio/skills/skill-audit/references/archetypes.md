# Skill Archetypes

A durable skill fits cleanly into **exactly one** of these ten archetypes.
If a skill spans several, that is the strongest signal it is doing too much and
should be split (single responsibility). Use this list to classify the skill and
to sanity-check its scope and description.

| Archetype | What it is | Example names |
|---|---|---|
| **Library & API Reference** | Internal libs, CLIs, SDKs, gotchas | `billing-lib`, `platform-cli`, `events` |
| **Product Verification** | Drive the running product to verify behavior | `signup-driver`, `checkout`, `admin` |
| **Data & Analysis** | IDs, field names, query patterns | `funnel-query`, `grafana`, `datadog` |
| **Business Automation** | Multi-tool workflows collapsed to one command | `standup`, `tickets`, `weekly-recap` |
| **Scaffolding & Templates** | Framework-correct boilerplate | `new-app`, `migration`, `workflow` |
| **Code Quality & Review** | Methodology that ships better code | `adversarial`, `hypothesis`, `bughunt` |
| **CI/CD & Deployment** | Commit, push, deploy safely | `babysit-pr`, `deploy`, `cherry-pick` |
| **Incident Runbooks** | Symptom → investigation → report | `oncall`, `correlator`, `queue-debug` |
| **Infrastructure Ops** | Safety-gated cleanup & maintenance | `orphans`, `deps`, `cost-investigation` |
| **Safety Router / Orchestration Entry** | A cross-cutting entry skill that owns a safety/permission boundary and routes the how-to work to focused siblings by name | `platform-entry`, `deploy-gate` |

The **Safety Router** is the one archetype that is *expected* to reference many
sibling skills — that is its job, not a single-responsibility violation. Its
single responsibility is the boundary it owns (e.g. the project↔environment↔
permission matrix) plus the routing; it must not re-derive the focused skills'
guidance (see `principles.md` → handoff discipline).

## How to classify

1. Read the skill's `description` and `## Apply When`.
2. Pick the single archetype that best matches its core job.
3. If two or more fit equally, the skill likely bundles distinct jobs — flag it
   as a **split candidate** and name the archetypes it straddles.

## Mapping to this marketplace's plugins (illustrative)

The archetypes are the durable lens; these mappings are examples, not a
constraint:

- `repo-governance:skill-maintainer` → Code Quality & Review (methodology for
  versioning, releasing, and promoting skills that meet the contract).
- `skill-studio:skill-audit` → Code Quality & Review (read-only audit and
  scored report).
- A skill that documents a library, CLI, or SDK's gotchas → Library & API
  Reference.
- A skill that adds or reviews CI/deploy workflows → CI/CD & Deployment.
- An entry skill that owns a safety/permission boundary and routes the how-to
  work to focused siblings by name → Safety Router / Orchestration Entry.
- A sandbox skill under `blassioli` doing opportunistic migration is a good one
  to scrutinize for scope, since migration can drift into several jobs
  (Scaffolding & Templates / Code Quality & Review).

A skill that fits no archetype is either too generic (split or drop) or a
genuinely new category worth proposing to the marketplace owner.
