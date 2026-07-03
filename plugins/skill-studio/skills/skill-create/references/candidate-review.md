# Candidate Review

Use this rubric after `scripts/inspect-candidate-skill.sh` says the source is at
least a plausible skill. It is the go/no-go decision for importing an external
skill candidate before you adapt it.

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

Treat the candidate as `adapt` when it is real but not native to this
marketplace yet:

- folder name does not match the `name` frontmatter
- `metadata.json` is missing
- the frontmatter carries governance fields (`version`, `source_contracts`,
  `last_reviewed`) that belong in `metadata.json`
- the description is too vague or too broad
- the main `SKILL.md` carries too much reference material
- the candidate mixes multiple workflows with no clear trigger surface
- scripts exist but lack usage comments or structured output
- references are deep, scattered, or rely on nested hops
- cross-skill references use relative filesystem links instead of by-name
  handoffs or `${CLAUDE_SKILL_DIR}` / `${CLAUDE_PLUGIN_ROOT}` for bundled files

## Repo Fit Checklist

Confirm the candidate fits this marketplace's Claude-first standard:

- one clear reason to exist
- description says both WHAT it does and WHEN it should trigger
- `SKILL.md` frontmatter is `name` + `description` only (plus optional
  `allowed-tools`); governance/freshness lives in `metadata.json`
- top-level `SKILL.md` is a routing surface, not a full manual
- supporting details live one hop away under `references/`, `assets/`, or
  `scripts/`
- scripts are narrow, deterministic, and obviously tied to the skill's purpose
- nothing encourages copying live config from another repository without review

## Strong Import Signals

The candidate is a good import target when most of these are true:

- the skill has a precise trigger vocabulary
- the main file is compact and easy to scan
- references and templates are clearly named
- supporting scripts are self-contained
- the skill fills a real gap in this marketplace's catalog
- the imported result will still make sense after it lands in a plugin

## Decision Rule

Use this simple rule:

- `ready` when there are no blocking issues and only minor polish remains
- `adapt` when the skill is worth importing but must be normalized first
- `reject` when the skill is not safely or usefully importable yet

## See Also

- `references/import-paths.md` — choose the import path once the decision is made.
- `references/plugin-standard.md` — the Claude package shape to normalize toward.
