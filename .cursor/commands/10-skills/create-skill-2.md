---
description: Create or refactor a Cursor skill under `.cursor/skills/<skill>` by first clarifying whether the work should be a skill at all, then defining the skill's job, scope, triggers, anti-triggers, and lean file layout. Do NOT write files until user confirms each phase.
---

## User Input

```text
$ARGUMENTS
```

Supported forms:
- `new <skill-name>` (create a new skill)
- `refactor <path-or-skill-name>` (refactor an existing skill to Cursor layout)

Optional flags:
- `--with-scripts` (scaffold audit scripts stubs)
- `--with-assets` (scaffold common template placeholders)
- `--with-nx-generator` (only if this is an Nx skill; scaffold generator placeholder)

## Goal

Produce a Cursor skill that:

1) Auto-invokes precisely (high precision):
- tight description triggers + explicit anti-triggers
- applicability gate in SKILL.md

2) Minimizes context usage:
- SKILL.md is an index and routing layer
- doctrine goes into `references/`
- templates into `assets/`
- repeated checks into `scripts/` (JSON output)

3) Has a clear reason to exist:
- the skill owns one coherent recurring job
- the boundary with neighboring skills, rules, hooks, commands, or packs is explicit
- the user and agent share the same meaning for what the skill is for

4) Supports safe editing:
- any proposed codebase changes are gated behind user confirmation

## Operating Constraints

- No file writes until the user confirms the proposed plan for the phase.
- After each phase, present a short plan and ask: “Proceed? (yes/no)”.
- Prefer the smallest viable skill. Do not scaffold files or directories with no clear purpose.
- Treat `SKILL.md` as a dispatcher, not a knowledge dump. Keep it lean and route to direct supporting files.
- Prefer instructions over scripts unless deterministic execution, validation, or compact machine-readable output is needed.
- Descriptions must be written in third person and include both WHAT the skill does and WHEN to use it.
- Use explicit anti-triggers and sibling boundaries when overlap is possible.

## Outline

### Phase 0 — Suitability and Meaning (one screen)

Ask (do not write files yet):
1) What recurring job should this artifact own?
2) Why is a skill the right surface instead of:
   - a `.cursor/rules` rule
   - a reusable command
   - a subagent
   - a hook
   - a Cursor pack
3) What does this skill mean in one sentence?
   - ask for the job-to-be-done, not the implementation
4) What is explicitly in scope?
5) What is explicitly out of scope?
6) What neighboring skills or concepts could overlap with it?
7) What user phrases should trigger it?
8) What phrases or situations should NOT trigger it?

Then output:
- Recommended surface (`skill` vs another surface) with rationale
- Proposed job statement
- Proposed scope boundary:
  - In scope
  - Out of scope
- Proposed overlap notes or sibling hand-offs

If the work is better expressed as a rule, command, subagent, hook, or pack, say so clearly and stop before scaffolding.

Ask: “Proceed to skill discovery? (yes/no)”

### Phase 1 — Discovery (one screen)

Ask (still do not write files yet):
1) Skill name (kebab-case, must match folder name)
2) Target location: project `.cursor/skills/` or global `~/.cursor/skills/`
3) One-sentence description with WHAT + WHEN + anti-triggers
4) Primary archetype:
   - Knowledge Hub
   - Tool Runner
   - Workflow Executor
   - Hybrid
5) Core artifact targets the skill will read, write, or reason about
6) Whether the skill should be implicit, explicit-only, or slash-command-only
7) What detailed knowledge belongs in:
   - `references/`
   - `assets/`
   - `scripts/`
8) Whether scripts/assets are actually needed
9) If Nx-based: whether you want generator support

Discovery quality rules:
- Make the description concrete and third person.
- Include words a user would actually say.
- Use anti-triggers for overlap control.
- Prefer one dominant job over a bundle of adjacent tasks.
- If two candidate skills are emerging, split them now instead of creating a vague umbrella skill.

Then output:
- Proposed description
- Proposed applicability gate text
- Proposed routing, decision, or workflow headings
- Proposed confirmation policy

Ask: “Proceed to design the file tree? (yes/no)”

### Phase 2 — Design (propose, then confirm)

Propose the smallest useful directory tree under `.cursor/skills/<skill-name>/`.
Only include directories that will contain real content:

```text
.cursor/skills/<skill-name>/
  SKILL.md
  references/        # only if needed
  assets/            # only if needed
  scripts/           # only if needed
```

Design rules:
- `SKILL.md` stays lean: gate + routing + procedure + confirmation rules
- `references/` holds domain-specific doctrine and rationale
- `assets/` holds copyable templates, quickrefs, checklists, or decision trees
- `scripts/` holds executable audits or deterministic helpers with compact output
- Do not create empty directories or placeholder files without a clear near-term use
- Keep references one link deep from `SKILL.md`

If `refactor` mode:
- propose a move plan from existing directories
- collapse redundant files
- identify content that belongs in `references/`, `assets/`, or `scripts/`
- call out any parts that should become a separate sibling skill instead

Ask: “Proceed to scaffold files? (yes/no)”

### Phase 3 — Scaffold (after yes)

Create (or propose diffs for refactor):

1) `SKILL.md` (lean dispatcher)
- YAML frontmatter with `name` and `description`
- Optional `disable-model-invocation: true` if this should be explicit-only
- Use the archetype to choose sections, but typically include:
  - Applicability Gate
  - Routing Table, Decision Table, or Numbered Workflow
  - Procedure
  - Confirmation Policy
  - Related Skills / Hand-offs when overlap matters

2) `references/*` only if needed
- one focused file per topic
- each file should capture domain-specific rules, not generic filler
- add direct links from `SKILL.md`

3) `assets/*` only if needed
- copyable templates, checklists, quickrefs, or examples
- realistic examples preferred over abstract placeholders

4) `scripts/*` only if needed
- each script must say whether to execute or read it
- output should be compact and structured; JSON preferred for audits/helpers
- avoid scaffolding scripts if instructions alone are enough

If `--with-scripts`:
- scaffold one generic script stub `scripts/audit.mjs` (or `audit.sh`) with JSON output contract (no implementation required if you don’t want it)

If `--with-assets`:
- scaffold placeholders under `assets/templates/`

If `--with-nx-generator`:
- scaffold placeholder notes in `references/nx-generator.md` describing intended generator behavior

Stop and ask: “Proceed to add initial supporting docs now? (yes/no)”

### Phase 4 — Populate Supporting Files (after yes)

For each needed reference category:
- create one focused doc with:
  - Purpose
  - Rules (normative MUST/SHOULD)
  - Exceptions/escape hatches
  - Links to assets and scripts

For each needed asset category:
- create concrete templates, checklists, or examples that save tokens or reduce ambiguity

For each needed script:
- keep it deterministic and self-contained
- make output easy for the agent to parse and summarize

If refactoring an existing skill:
- propose a consolidation plan:
  - detect duplicates
  - select canonical docs
  - convert repeated snippets into assets
  - remove vague or generic content the model already knows
  - tighten boundaries and add anti-triggers where overlap exists

Stop and ask: “Proceed to finalize routing table and links? (yes/no)”

### Phase 5 — Finalize routing and verification (after yes)

- Update `SKILL.md` routing table to point to:
  - scripts (preferred) for facts
  - reference docs for rationale and standards
- Add verification checklist:
  - `name` matches folder name
  - description is third person and includes WHAT + WHEN
  - anti-triggers are explicit where needed
  - `SKILL.md` stays concise
  - direct links resolve
  - no empty directories
  - no Windows-style paths
  - auto-invocation happens only with intended triggers
  - the skill boundary is understandable in one sentence
  - neighboring skills are not accidentally duplicated

Stop and ask: “Finalize and write files as proposed? (yes/no)”

## Output Requirements

Every phase output MUST include:
- Proposed file operations (unexecuted until confirmed)
- Proposed diffs (unapplied until confirmed)
- A strict confirmation gate question

When discussing meaning and scope, prefer this format:

```markdown
## Proposed Skill Meaning

- Job: <one recurring job>
- In scope: <flat list>
- Out of scope: <flat list>
- Triggers: <phrases users would say>
- Anti-triggers: <phrases or situations that should route elsewhere>
- Related surfaces: <rules / commands / hooks / sibling skills>
```

Before any write phase, restate:
- why this should be a skill
- what the skill owns
- what it does not own

## Context

$ARGUMENTS

