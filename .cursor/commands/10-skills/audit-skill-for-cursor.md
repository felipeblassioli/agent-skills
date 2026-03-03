---
description: Audit a Cursor skill (or skills directory) for Cursor compatibility, safe auto-invocation, and index-style SKILL.md quality. Propose a remediation plan and unapplied diffs; apply ONLY after explicit user confirmation.
---

## User Input

```text
$ARGUMENTS
```

Interpret $ARGUMENTS in this order:

1) Path to a skill root containing `SKILL.md` (e.g., `.cursor/skills/my-skill`)
2) Path to a skills directory containing skill subfolders (e.g., `.cursor/skills`)
3) Skill name (resolve to `.cursor/skills/<name>`)

Optional flags:
- `--all` (when auditing a skills directory, include all immediate subfolders containing `SKILL.md`)
- `--report-json` (append a JSON summary)
- `--deep-links` (validate links by reading referenced files; default is path-only existence checks)
- `--propose-only` (do not ask for confirmation; emit plan/diffs only)

## Goal

Produce a read-only audit report that answers:

1) Is the skill discoverable and usable by Cursor?
2) Will the agent apply it “intelligently” (high-precision auto-invocation) rather than over-applying it?
3) Is `SKILL.md` behaving as a high-signal index (progressive disclosure) rather than a bloated rulebook?
4) Are `references/`, `assets/`, and `scripts/` used appropriately to minimize context usage?

Then propose a remediation plan (unapplied) with:
- explicit file operations (mkdir/mv/cp)
- patch-style diffs

Edits MUST NOT be applied unless the user explicitly confirms.

## Operating Constraints

- STRICTLY READ-ONLY by default.
- Do NOT modify/create/move/delete files.
- Do NOT run scripts unless the user explicitly requests it during this command run.
- If `--propose-only` is set, do not prompt for confirmation.

## Outline

### Step by Step

1) Resolve audit targets

- If $ARGUMENTS is empty:
  - If `.cursor/skills` exists, audit it.
  - Else stop: “Provide a skill name or path. Expected `.cursor/skills/<skill>`.”

- If $ARGUMENTS is a path:
  - If it contains `SKILL.md`: audit that one skill.
  - Else treat it as skills directory:
    - If `--all` is set: audit all immediate subfolders containing `SKILL.md`.
    - Else stop and ask user to pass `--all` or specify a skill.

- If $ARGUMENTS is a bare name:
  - Resolve to `.cursor/skills/<name>`; if missing, stop with a clear error.

2) Inventory structure (top-level only)

For each discovered skill root:
- Record:
  - root path
  - folder name
  - top-level entries
  - presence of required `SKILL.md`
  - presence of optional directories: `references/`, `assets/`, `scripts/`
  - presence of “non-standard” directories (e.g., `rules/`, `docs/`, `templates/`) that likely belong under `references/` or `assets/`

3) Validate SKILL.md frontmatter invariants

Read ONLY YAML frontmatter and validate:
- `name` exists
- `description` exists
- `name` matches parent folder name EXACTLY
- `name` uses kebab-case `[a-z0-9-]+`

Also record:
- `disable-model-invocation` (if present)
- `compatibility` (if present)
- `metadata` (if present)

Audit rule for your stated intent (intelligent auto-usage):
- If `disable-model-invocation: true` is present, flag as HIGH severity unless the skill is intentionally slash-only.

4) Index-style SKILL.md audit (minimal body read)

Read the minimal body needed to audit “index quality”:
- H1 title
- the first ~120 lines OR up to the first 4 headings (whichever is smaller)
- any explicit links to other files

Check for these index signals (recommended, not required):
- Applicability gate (“Apply only if…”, clear triggers and anti-triggers)
- Routing table (symptom → reference/script)
- Decision procedure (short, deterministic steps)
- Confirmation gate language for changes (if the skill proposes edits)

Flag as MEDIUM/HIGH if:
- SKILL.md is missing applicability gating AND description is broad (likely over-invocation)
- SKILL.md duplicates large rule text instead of linking to `references/`

5) Link integrity

- Build a list of relative links in `SKILL.md`.
- Validate that targets exist.
- If `--deep-links` is set:
  - Open the referenced files and validate they exist and are readable.

6) Progressive disclosure + directory hygiene

- If there is a `rules/` (or similar) directory at the skill root:
  - Flag as MEDIUM.
  - Recommend moving it under `references/` (e.g., `references/rules/`).
- If there are templates or config snippets at the root:
  - Recommend moving to `assets/`.

7) Invocation precision audit

Evaluate whether the agent will apply the skill “intelligently”:
- Inspect `description` for:
  - specific triggers (error strings, tasks, repo signals)
  - anti-triggers (explicit “do not apply outside…”)
- If description is vague (e.g., “best practices for TypeScript”), flag HIGH.
- Recommend tightening `description` and adding an applicability gate in the body.

8) Severity model

- CRITICAL: Skill not discoverable or invalid frontmatter (missing required fields, name mismatch)
- HIGH: Likely mis-invocation (broad description + no gating), slash-only field present unintentionally, broken links
- MEDIUM: Progressive disclosure weak, reference material misplaced, missing routing table
- LOW: Minor editorial / organization improvements

9) Output: Audit Report (Markdown)

Output MUST include:

A) Findings table (stable IDs)
| ID | Skill | Category | Severity | Location(s) | Evidence | Recommendation | Proposed Remediation |

B) Per-skill summary
- Discoverable: yes/no
- Frontmatter valid: yes/no
- Invocation mode: auto vs slash-only (current + recommended)
- Index quality: pass/warn/fail (with reasons)
- Optional dirs present: references/assets/scripts
- Link integrity: ok/broken

C) Metrics
- skills audited
- findings by severity
- broken links count
- SKILL.md approximate size (lines)

10) Output: Remediation plan (unapplied)

A) Proposed file operations (NOT executed)
- mkdir -p …
- mv …
- cp …

B) Proposed diffs (NOT applied)
- Provide `diff --git` patches for every file change.

C) Verification checklist
- Skill appears in Cursor Skills UI
- Agent uses it only when triggers match
- Links resolve

11) Confirmation gate

If `--propose-only` is NOT set, ask exactly:
“Do you want me to apply the remediation plan as proposed? (yes/no)”

- If not an explicit “yes”: do not apply any changes.

12) Optional JSON summary

If `--report-json` is set, append:
- totals
- per-skill finding counts
- recommended actions (array)


// .cursor/commands/improve.md
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
