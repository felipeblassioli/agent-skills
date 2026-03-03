---
description: Improve a Cursor skill for context efficiency and correctness. Detect duplicates/inconsistencies/contradictions across references, propose scripts/assets to reduce token usage, and optionally propose Nx generators. Apply changes ONLY after explicit user confirmation.
---

## User Input

```text
$ARGUMENTS
```

Interpret $ARGUMENTS in this order:

1) Path to a skill root containing `SKILL.md`
2) Path to a skills directory containing skill subfolders
3) Skill name (resolve to `.cursor/skills/<name>`)

Optional flags:
- `--all` (when given a skills directory, include all subfolders containing SKILL.md)
- `--deep` (read full references; scan code blocks; do contradiction detection)
- `--propose-scripts` (include concrete scripts proposals)
- `--propose-assets` (include concrete templates/assets proposals)
- `--propose-generators` (Nx generators proposals IF skill scope is Nx)
- `--max-findings=<N>` (default 40, hard cap 80)
- `--report-json` (append a machine-readable JSON summary)

## Goal

Optimize the skill for Cursor-only usage and “intelligent auto-invocation”, by:

1) Minimizing context usage:
- SKILL.md must remain an index (routing + gating)
- detailed doctrine belongs in `references/`
- reusable snippets/templates belong in `assets/`
- repeated checks should become scripts (tools beat prose)

2) Reducing ambiguity:
- narrow triggers and add anti-triggers
- prefer deterministic procedures over guidelines

3) Internal consistency:
- detect duplicate rules, term drift, contradictory MUSTs
- propose a single source of truth per topic

4) Producing a concrete remediation plan:
- explicit file operations + patch diffs
- NO edits unless user confirms

## Operating Constraints

- READ-ONLY by default.
- Do NOT modify/create/move/delete files unless user confirms.
- Do NOT run scripts unless user asks explicitly.

## Outline

### Step by Step

1) Resolve targets

Same resolution rules as `audit-skill-for-cursor`.

2) Quick scan (fast path)

For each skill:
- read YAML frontmatter
- read SKILL.md first ~200 lines
- list `references/`, `assets/`, `scripts/` contents (shallow)

Decide if `--deep` is required:
- If the skill has multiple reference files and you need to evaluate duplicates/contradictions → require `--deep`.
- Otherwise proceed with shallow analysis.

3) Build “claim inventory” from references

Default mode (no `--deep`):
- Read headings + only lines containing normative keywords:
  - MUST, MUST NOT, SHOULD, SHOULD NOT, REQUIRED, NEVER
- Extract claims:
  - claim_id: `<file>#<heading>#<ordinal>`
  - modality
  - subject terms (best-effort)
  - location (file:line-range if available)

Deep mode (`--deep`):
- Also scan:
  - code blocks
  - repeated config fragments
  - example sections

4) Detect duplicates

- Cluster claims by:
  - same modality
  - similar subject
  - similar wording

Output:
- duplicate clusters with:
  - canonical file recommendation
  - files that should link to canonical instead of repeating

5) Detect inconsistencies (term drift)

- Identify repeated terms and definitions.
- Flag:
  - conflicting definitions
  - inconsistent file paths / naming conventions
  - divergent “preferred tool” instructions

Output:
- canonical definition proposal
- list of files to update

6) Detect contradictions

- Find pairs where:
  - one says MUST and other says MUST NOT for same subject in same scope
  - two “always” rules collide

Resolution policy:
- Prefer explicit scope.
- Prefer stricter/CRITICAL policies if encoded.
- Otherwise, present options and require user decision (do not guess).

7) Improve SKILL.md as an index (routing + gating)

Recommend SKILL.md include these sections (short, procedural):

A) Applicability Gate
- “Apply ONLY if…” (repo signals + task signals)
- “Do NOT apply if…”

B) Routing Table
- Symptom → (script + reference file)

C) Procedure
- Identify class
- Run script (if available)
- Open 1–2 references max
- Propose changes (diff)

D) Confirmation Gate
- “Do not apply changes unless user confirms.”

8) Tool-first proposals to reduce tokens

If `--propose-scripts`:
- Propose up to 5 scripts that output compact JSON.
- Each script proposal MUST include:
  - script name + path under `scripts/`
  - what it checks
  - inputs
  - output JSON schema
  - example output
  - how SKILL.md routes to it

If `--propose-assets`:
- Propose up to 10 assets (templates) for repeated snippets.
- Each asset proposal MUST include:
  - asset path under `assets/`
  - what it is for
  - how the agent should copy/use it

If `--propose-generators`:
- Only if skill scope is Nx.
- Propose up to 3 Nx generators that enforce invariants.
- Each proposal MUST include:
  - generator name
  - inputs
  - files created/updated
  - invariants enforced
  - how it replaces long textual rules

9) Output: Improvement Report

A) Summary per skill
- Top 3 context hotspots
- Top 3 ambiguity hotspots
- Counts: duplicates / inconsistencies / contradictions
- Top 5 highest-leverage improvements

B) Findings table (max N)
| ID | Category | Severity | Location(s) | Summary | Recommendation | Remediation Sketch |

Categories:
- ContextWaste
- Ambiguity
- Duplication
- Inconsistency
- Contradiction
- ToolingOpportunity

C) Duplicate clusters
D) Contradiction pairs (with resolution options)
E) Tooling proposals (scripts/assets/generators)

10) Output: Remediation Plan (unapplied)

- Proposed file operations
- Proposed diffs
- Verification checklist

11) Confirmation gate

Ask exactly:
“Do you want me to apply the remediation plan (file moves + doc edits + optional scaffolding) as proposed? (yes/no)”

- If not explicit “yes”: do nothing.

12) Optional JSON summary

If `--report-json` is set, append:
- totals + per-skill statistics


// .cursor/commands/create-skill-2.md
---
description: Create or refactor a Cursor-only skill under `.cursor/skills/<skill>`, optimized for intelligent auto-invocation and low token usage (index SKILL.md + references/assets/scripts). Do NOT write files until user confirms each phase.
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

Produce a Cursor-only skill that:

1) Auto-invokes precisely (high precision):
- tight description triggers + explicit anti-triggers
- applicability gate in SKILL.md

2) Minimizes context usage:
- SKILL.md is an index and routing layer
- doctrine goes into `references/`
- templates into `assets/`
- repeated checks into `scripts/` (JSON output)

3) Supports safe editing:
- any proposed codebase changes are gated behind user confirmation

## Operating Constraints

- No file writes until the user confirms the proposed plan for the phase.
- After each phase, present a short plan and ask: “Proceed? (yes/no)”.

## Outline

### Phase 1 — Discovery (one screen)

Ask (do not write files yet):
1) Skill name (kebab-case, must match folder name)
2) One-sentence description with triggers AND anti-triggers
3) Scope boundaries (what this skill explicitly does NOT cover)
4) Reference categories (3–8 categories)
5) Whether the skill should include scripts/assets
6) If Nx-based: whether you want generator support

Then output:
- Proposed applicability gate text
- Proposed routing table headings

Ask: “Proceed to design the file tree? (yes/no)”

### Phase 2 — Design (propose, then confirm)

Propose the directory tree under `.cursor/skills/<skill-name>/`:

```
.cursor/skills/<skill-name>/
  SKILL.md
  references/
    README.md
  assets/
    README.md
  scripts/
    README.md
```

Design rules:
- `SKILL.md` stays lean: gating + routing + procedure
- `references/` holds detailed doctrine
- `assets/` holds copyable templates
- `scripts/` holds audits producing compact JSON

If `refactor` mode:
- propose a move plan from existing directories (e.g., `rules/` → `references/rules/`)

Ask: “Proceed to scaffold files? (yes/no)”

### Phase 3 — Scaffold (after yes)

Create (or propose diffs for refactor):

1) `SKILL.md` (index-only)
- YAML frontmatter with `name` and `description`
- Sections:
  - Applicability Gate
  - Routing Table
  - Procedure
  - Confirmation Policy

2) `references/README.md`
- “Source of truth” policy
- Index of reference documents

3) `assets/README.md`
- How to use templates (copy → customize)

4) `scripts/README.md`
- How to run scripts
- Output contract (JSON)

If `--with-scripts`:
- scaffold one generic script stub `scripts/audit.mjs` (or `audit.sh`) with JSON output contract (no implementation required if you don’t want it)

If `--with-assets`:
- scaffold placeholders under `assets/templates/`

If `--with-nx-generator`:
- scaffold placeholder notes in `references/nx-generator.md` describing intended generator behavior

Stop and ask: “Proceed to add initial reference docs now? (yes/no)”

### Phase 4 — Populate references (after yes)

For each category:
- create one reference doc with:
  - Purpose
  - Rules (normative MUST/SHOULD)
  - Exceptions/escape hatches
  - Links to assets and scripts

If refactoring an existing skill:
- propose a consolidation plan:
  - detect duplicates
  - select canonical docs
  - convert repeated snippets into assets

Stop and ask: “Proceed to finalize routing table and links? (yes/no)”

### Phase 5 — Finalize routing and verification (after yes)

- Update `SKILL.md` routing table to point to:
  - scripts (preferred) for facts
  - reference docs for rationale and standards
- Add verification checklist:
  - skill appears in Cursor
  - auto-invocation happens only with triggers
  - links resolve

Stop and ask: “Finalize and write files as proposed? (yes/no)”

## Output Requirements

Every phase output MUST include:
- Proposed file operations (unexecuted until confirmed)
- Proposed diffs (unapplied until confirmed)
- A strict confirmation gate question

## Context

$ARGUMENTS