# Skill Quality Checklist

Run through this before presenting a new skill for final review.

## Structural checks

- [ ] `SKILL.md` exists at the skill root.
- [ ] `metadata.json` exists at the skill root (`version`, `author`, `date`,
  `abstract`; `source_contracts` when the skill teaches an external contract).
- [ ] `CHANGELOG.md` exists with an entry matching the `metadata.json` version.
- [ ] `SKILL.md` has YAML frontmatter with `---` delimiters.
- [ ] Frontmatter is **`name` + `description` only** (plus optional
  `allowed-tools`). No `version`/`last_reviewed`/`source_contracts` in it.
- [ ] `name` field: lowercase, hyphens only, max 64 chars.
- [ ] `name` field matches the parent folder name exactly.
- [ ] `description` field: non-empty, max 1024 chars, third person.
- [ ] `SKILL.md` body is under 500 lines.
- [ ] No empty directories (every dir has at least one file).
- [ ] No Windows-style paths (`\`) — use `/` everywhere.

## Description quality

- [ ] Written in **third person** (not "I can ..." or "You can ...").
- [ ] Includes **WHAT** — specific capabilities, not vague.
- [ ] Includes **WHEN** — trigger scenarios with concrete terms.
- [ ] Contains keywords a user would actually say.
- [ ] Anti-triggers ("Do not use when ...") are explicit when sibling skills
  share vocabulary.
- [ ] Does NOT include time-sensitive language ("before August 2025 ...").

## Scope and meaning

- [ ] The skill's job can be stated in one sentence.
- [ ] In-scope and out-of-scope lists are explicit.
- [ ] Triggers are concrete and realistic.
- [ ] Neighboring skills or surfaces are named when hand-offs matter.
- [ ] The skill does not hide multiple unrelated jobs behind one broad label.
- [ ] The authoring flow explicitly asked whether this should stay a skill
  instead of a subagent, command, hook, or a multi-surface plugin.

## Content quality

- [ ] Only includes information the agent doesn't already know:
  - General programming knowledge -> omit.
  - Well-documented public APIs -> omit or summarize.
  - Domain-specific rules, conventions, decisions -> include.
- [ ] Consistent terminology throughout (one term per concept).
- [ ] Tables used for structured data (not prose lists).
- [ ] Code examples are concrete and runnable, not abstract pseudocode.
- [ ] No verbose explanations of obvious concepts.
- [ ] Templates are realistic and reusable.
- [ ] Scripts, if present, are actually justified.

## Progressive disclosure

- [ ] SKILL.md is a dispatcher, not a dump — it routes to supporting files.
- [ ] Every reference file is linked directly from SKILL.md (routing table
  or inline link) — no multi-hop chains (the One-Hop Rule).
- [ ] Supporting files are focused: each covers one topic, under ~300 lines.
- [ ] Supporting files have "See Also" cross-references where relevant.

## Archetype compliance

### Knowledge Hub
- [ ] Routing table maps questions -> reference file paths.
- [ ] Applicability gate with "Apply when" and "Do NOT apply when".
- [ ] Procedure section with numbered steps.
- [ ] Confirmation policy defined.

### Tool Runner
- [ ] Decision table maps input patterns -> script invocations.
- [ ] Output contract defines the expected output format.
- [ ] Composition table shows how this skill feeds into others.
- [ ] Delegation guidance (when subagent vs direct) if output can be verbose.

### Workflow Executor
- [ ] Steps are numbered and sequential.
- [ ] Each step has concrete code/command examples.
- [ ] At least one complete worked example.
- [ ] Quick reference table at the bottom.

## Scripts (if present)

- [ ] Each script has a usage comment block at the top.
- [ ] Scripts are self-contained (bash + standard tools).
- [ ] Scripts handle errors explicitly (`set -euo pipefail` or equivalent).
- [ ] Scripts output structured data (JSON preferred).
- [ ] Scripts are marked executable.
- [ ] Bundled scripts referenced via `${CLAUDE_SKILL_DIR}/scripts/<name>`.
- [ ] SKILL.md makes clear whether to execute or read each script.

## Claude marketplace specifics

- [ ] Cross-skill references are **by name**, not relative filesystem links
  (installed plugins are copied to a cache; cross-package paths break).
- [ ] Bundled files inside the skill are referenced via `${CLAUDE_SKILL_DIR}` /
  `${CLAUDE_PLUGIN_ROOT}`.
- [ ] The skill lives in the right plugin/tier (sandbox vs official) and the
  plugin is listed in `.claude-plugin/marketplace.json`.
- [ ] No `disable-model-invocation` — Claude skills do not use it; keep the
  description tight so the model routes correctly.
- [ ] No private or credentialed details in a public marketplace skill.

## Packaging

- [ ] The skill folder contains only purposeful files.
- [ ] `plugin.json` version is set/bumped for a releasable change.
- [ ] `claude plugin validate ./plugins/<plugin> --strict` passes.
- [ ] `bash ${CLAUDE_SKILL_DIR}/scripts/validate-skill.sh <skill-dir>` passes.

## Anti-patterns to reject

| Anti-pattern | What to do instead |
|---|---|
| Name is `helper`, `utils`, `tools` | Use a descriptive name: `processing-pdfs`. |
| Description says "Helps with ..." | State what it does: "Processes PDF files ...". |
| SKILL.md > 500 lines | Move content to references/assets. |
| Governance fields in frontmatter | Move to `metadata.json`. |
| Multiple tools offered without a default | Pick one default, mention alternatives as escape hatch. |
| Explaining what LLMs already know | Remove — only include domain-specific knowledge. |
| Deeply nested references (A -> B -> C) | Flatten — link directly from SKILL.md. |
| Cross-skill relative links | Reference the other skill by name. |
| Empty directories in the tree | Remove them. |
| Generic examples with `foo`/`bar` | Use realistic examples from the user's domain. |

## Reject the skill until fixed if

- The description is vague.
- The boundary with a sibling skill is still fuzzy.
- The user would not know when to invoke it.
- The skill should really be a subagent, command, hook, or a multi-surface plugin.
- The scaffold contains placeholder files with no clear use.
- Frontmatter still carries governance fields that belong in `metadata.json`.
