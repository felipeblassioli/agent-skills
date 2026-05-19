# Audit Procedure

This document contains the step-by-step logic for auditing and improving a Cursor skill.

## User Input
```text
$ARGUMENTS
```
Interpret $ARGUMENTS in this order:
1) Path to a skill root containing `SKILL.md` (e.g., `.cursor/skills/my-skill`)
2) Path to a skills directory containing skill subfolders (e.g., `.cursor/skills`)
3) Skill name (resolve to `.cursor/skills/<name>`)

Optional flags:
- `--all` (include all immediate subfolders containing `SKILL.md`)
- `--report-json` (append a JSON summary)
- `--deep-links` (validate links by reading referenced files)
- `--propose-only` (do not ask for confirmation; emit plan/diffs only)

## Operating Constraints
- STRICTLY READ-ONLY by default.
- Do NOT modify/create/move/delete files unless explicitly confirmed.
- Do NOT run scripts unless explicitly requested.

## Audit Workflow

### 1) Resolve Targets
- If empty: Audit `.cursor/skills` if it exists. Else stop.
- If path: If it contains `SKILL.md`, audit it. Else if `--all` is set, audit subfolders. Else stop.
- If bare name: Resolve to `.cursor/skills/<name>`.

### 2) Inventory Structure
For each discovered skill root:
- Record path, folder name, top-level entries, `SKILL.md`, `references/`, `assets/`, `scripts/`.
- Flag non-standard directories (e.g., `rules/`, `docs/`) that should be under `references/`.

### 3) Validate SKILL.md Frontmatter Invariants
Read ONLY YAML frontmatter:
- `name` exists and matches folder exactly (kebab-case).
- `description` exists.
- If `disable-model-invocation: true` is present unintentionally, flag as HIGH severity.

### 4) Index-style SKILL.md Audit
Read minimal body:
- H1 title
- First ~120 lines OR up to 4 headings.
- Check for applicability gates, routing tables, short decision procedures.
- Flag MEDIUM/HIGH if applicability gating is missing or rule text is bloated.

### 5) Link Integrity
- Validate relative links in `SKILL.md`.
- If `--deep-links`, ensure target files are readable.

### 6) Progressive Disclosure + Directory Hygiene
- Recommend moving `rules/` or massive texts to `references/`.
- Recommend moving templates/snippets to `assets/`.

### 7) Invocation Precision Audit
- Inspect `description` for specific triggers and anti-triggers.
- Flag HIGH if vague (e.g., "best practices").

## Improvement Workflow (Deep Check)

If optimizing for context efficiency and internal consistency:
1. **Detect Context Waste**: Identify repeated checks that should be scripts.
2. **Detect Duplication**: Identify claims repeated across multiple reference files. Propose a canonical source.
3. **Detect Contradiction**: Find MUST/MUST NOT pairs colliding in the same scope.

## Output Generation

### A) Findings Table
| ID | Skill | Category | Severity | Location(s) | Summary | Recommendation | Proposed Remediation |

### B) Remediation Plan (Unapplied)
- Proposed file operations (mkdir, mv, cp)
- Patch diffs (`diff --git`)
- Verification checklist

### C) Confirmation Gate
If `--propose-only` is NOT set, ask exactly:
**"Do you want me to apply the remediation plan (file moves + doc edits + optional scaffolding) as proposed? (yes/no)"**
If not an explicit "yes", do nothing.
