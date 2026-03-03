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

