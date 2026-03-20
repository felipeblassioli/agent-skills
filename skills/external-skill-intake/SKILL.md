---
name: external-skill-intake
description: Evaluate a candidate Cursor skill from another repository or arbitrary path, decide whether it should be imported into this repository, and route the import through the correct normalization path. Use when the user wants to bring a skill into `felipeblassioli/agent-skills`, compare an external skill against this repo's conventions, or review a skill-like folder before importing it.
---

# External Skill Intake

Review a skill candidate before importing it into this repository.

This skill exists to prevent low-quality or non-repo-native skills from being
copied into `skills/` without checking:

- whether the source is actually a skill
- whether the folder already matches Cursor skill conventions
- whether the skill fits this repository's structure and metadata standards
- whether the existing `scripts/skill-import.sh` path applies, or manual
  normalization is required

## Applicability Gate

Use this skill when ANY of the following are true:

- the user wants to bring a skill from another repo or filesystem path into this
  repository
- the source is not clearly a canonical `.cursor/skills/<name>/` skill
- the user wants a go/no-go recommendation before importing
- the user wants to know whether a candidate skill can be imported directly or
  needs adaptation first

Do NOT use this skill when:

- the source is already known to be a repo-local skill inside this repository
- the user only wants to sync or deploy an existing registered skill
  - use `skill-registry`
- the user wants to create a brand-new skill from notes or docs rather than
  evaluate an existing skill candidate
  - use `create-skill-from-refs`

## Inputs Required

Minimum input:

- a candidate path

Optional input:

- expected skill name
- source repository context
- desired target scope or tags

Accepted candidate shapes:

- a direct skill folder containing `SKILL.md`
- a project root containing `.cursor/skills/<name>/`
- a repo folder that looks like a skill but is not yet normalized

## Routing Table

- Inspect the candidate and get the first classification:
  `scripts/inspect-candidate-skill.sh`
- Apply the review rubric and understand import readiness:
  `references/candidate-review.md`
- Choose the correct import path for canonical versus non-canonical sources:
  `references/import-paths.md`
- Use the structured intake report template:
  `assets/templates/intake-report.md`

## Procedure

1. Run `scripts/inspect-candidate-skill.sh <candidate-path> [expected-name]`.
2. Read the JSON output before opening additional files.
3. Classify the candidate:
   - `ready` if it has a valid `SKILL.md`, valid frontmatter, and no blocking
     issues
   - `adapt` if it is a real skill candidate but needs normalization
   - `reject` if it is not a usable skill source yet
4. If the result is `ready` or `adapt`, read
   `references/candidate-review.md` to check repo fit:
   - scope clarity
   - trigger quality
   - hot-path size
   - supporting file layout
   - script safety
5. Choose the import path from `references/import-paths.md`:
   - canonical `.cursor/skills/<name>` source -> use `scripts/skill-import.sh`
   - arbitrary skill-like folder -> copy and normalize into `skills/<name>/`
   - weak candidate -> stop and ask the user whether to refine or reject it
6. Before any import, present a short intake report using
   `assets/templates/intake-report.md`.
7. Only after approval:
   - copy or normalize the skill into `skills/<name>/`
   - add or fix `metadata.json`
   - add the `skill-registry.json` entry
   - optionally deploy later via `skill-registry`

## Output Contract

Return a concise recommendation with:

- source shape
- classification: `ready`, `adapt`, or `reject`
- blocking issues
- adaptation needs
- suggested destination path under `skills/`
- recommended next step

When the source is weak or ambiguous, prefer `adapt` or `reject` over optimistic
import guidance.

## Confirmation Policy

- Do not import on inspection alone.
- Do not overwrite an existing skill in `skills/` without explicit approval.
- Do not run `scripts/skill-import.sh --force` unless the user explicitly wants
  replacement.
- Keep the first pass cheap: inspect the candidate and open only the most
  relevant files before deciding.
