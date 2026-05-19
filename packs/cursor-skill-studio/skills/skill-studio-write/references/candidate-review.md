# Candidate Review

Use this rubric after `scripts/inspect-candidate-skill.sh` says the source is at
least a plausible skill.

## Hard Reject Signals

Reject the candidate for import when ANY of these are true:

- no `SKILL.md`
- missing `name` frontmatter
- missing `description` frontmatter
- `name` is not lowercase hyphenated text
- the folder contains unrelated project code and no clear skill boundary
- the candidate depends on repo-specific files that are not being imported with
  it and cannot be reasonably reconstructed

## Adaptation Signals

Treat the candidate as `adapt` when it is real but not repo-native yet:

- folder name does not match the `name` frontmatter
- `metadata.json` is missing
- the description is too vague or too broad
- the main `SKILL.md` carries too much reference material
- the candidate mixes multiple workflows with no clear trigger surface
- scripts exist but lack usage comments or structured output
- references are deep, scattered, or rely on nested hops

## Repo Fit Checklist

Confirm the candidate fits this repository's standards:

- one clear reason to exist
- description says both WHAT it does and WHEN it should trigger
- top-level `SKILL.md` is a routing surface, not a full manual
- supporting details can live one hop away under `references/`, `assets/`, or
  `scripts/`
- scripts are narrow, deterministic, and obviously tied to the skill's purpose
- nothing encourages copying live config from another repository without review

## Strong Import Signals

The candidate is a good import target when most of these are true:

- the skill has a precise trigger vocabulary
- the main file is compact and easy to scan
- references and templates are clearly named
- supporting scripts are self-contained
- the skill fills a real gap in this repository's catalog
- the imported result will still make sense after registry sync

## Decision Rule

Use this simple rule:

- `ready` when there are no blocking issues and only minor polish remains
- `adapt` when the skill is worth importing but must be normalized first
- `reject` when the skill is not safely or usefully importable yet
