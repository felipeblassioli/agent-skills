# Platform Audit Lens (Claude-first)

This skill is Claude-first. The default audit lens is the cross-platform
procedure in `references/single-skill-audit.md`; apply the **Claude / Claude
Code** lens below on top of it for every skill audited here. A short generic
Markdown-agent lens follows for skills authored for other markdown-based agents
(Codex, Copilot). The former Cursor-IDE lens has been dropped — this skill does
not audit Cursor packs.

Do not duplicate cross-platform rules already covered by
`references/single-skill-audit.md`; this file is only the platform-specific
overlay.

---

## Claude / Claude Code lens

The primary lens. Apply to every skill destined for a Claude Code plugin or
`~/.claude/skills/`.

### 1. Claude Search Optimization (CSO) — the description is the router

Claude decides whether to load a skill almost entirely from the `description`
frontmatter field.

- **Rule**: the description states WHAT the skill does and WHEN to use it, and
  is a little pushy to combat under-triggering — it is an activation tag, not a
  feature summary.
- **Rule**: it must be discriminative — the triggers and symptoms that
  distinguish *this* skill from its siblings, plus anti-triggers naming the
  sibling to use instead ("Do not use for X → use `other-skill`").
- **Check**: audit the description for a workflow summary or a wall of unrelated
  triggers (a single-responsibility smell). Propose a refactor to a tight
  WHAT + WHEN + anti-trigger tag. Cite `description_chars` from the hot-path
  auditor and the `long_description*` findings.

### 2. Context efficiency — `SKILL.md` is a lean hub

Claude's context is large but not free; every loaded skill competes for it.

- **Rule**: `SKILL.md` reads like a dispatcher — a symptom → file routing table
  that names its spoke files — kept well under the 500-line hard cap (ideally far
  less). Heavy reference material and long examples move to `references/`; output
  templates move to `assets/`.
- **Rule**: progressive disclosure is wired both ways. Every `references/*` file
  must be named from `SKILL.md` (an **orphan** reference is never loaded), and
  every named link must resolve (a **dangling** pointer is broken). Large
  references (> ~300 lines) carry a `## Contents` TOC.
- **Check**: measure `skill_md_lines` (hot-path auditor) and the checker's
  `heavy_references_without_toc`, `orphan_references`, `dangling_skill_links`.
  Propose moving inline detail out of `SKILL.md`.

### 3. Cache-safe references — never bare relative paths

Installed plugin skills are **copied to a cache**, so a filesystem path that
reaches outside the skill dir breaks at runtime.

- **Rule**: cross-skill references are **by name** (the model invokes a named
  sibling if installed), never `../../other-skill/...` relative links.
- **Rule**: bundled scripts are invoked through `${CLAUDE_SKILL_DIR}` /
  `${CLAUDE_PLUGIN_ROOT}`, never a bare `scripts/foo.sh` run-invocation.
- **Rule**: bundle everything the skill needs at runtime. A skill must **not**
  assume it can read repo files (e.g. a `docs/architecture.md`) that live outside
  its own tree — those rules must be inlined into a `references/*` doc. The
  compliance rules this repo cares about are bundled directly in
  `references/principles.md`, `references/archetypes.md`, and
  `references/authoring-for-claude.md` for exactly this reason.
- **Check**: the checker's `cross_package_relative_links` and
  `relative_bundled_script_calls`; the auditor's own `procedural_description`
  hint for router-style descriptions.

### 4. Instruction craft — right altitude, don't railroad

Claude follows instructions closely and a skill is reused across situations its
author never saw.

- **Rule**: state the goal, the hard constraints, and what "done" looks like;
  leave the mechanics to the model. Reserve exact steps for what the model can't
  infer or is unsafe to get wrong (non-obvious flags, IDs, safety gates). Move
  genuinely mechanical work to a script, not prose steps.
- **Rule**: anticipate rationalizations — a discipline-enforcing skill should
  close the escape hatches ("skipping tests because the change is small") rather
  than leave them open.
- **Rule**: cross-reference siblings by name (`Use other-skill`); do NOT use
  `@path/to/skill`, which force-loads context preemptively.
- **Check**: this is judgment the checker can't see — see
  `references/authoring-for-claude.md` for the full instruction-craft dimension.

### 5. First-run setup and gotchas

- **Rule**: a skill needing user/environment context (a channel, an ID, a base
  URL) should detect-ask-persist a `config.json` rather than hardcode it — and a
  distributed plugin skill must never ship a populated `config.json` with one
  installer's real values or a token.
- **Rule**: a knowledge/reference/integration skill earns its context with the
  non-obvious — a specific, falsifiable **Gotchas** section (trap + correct
  behavior + where to check) is its highest-signal content.
- **Check**: see `references/authoring-for-claude.md` §2–§4 and the checker's
  `gotchas_section` (presence only; quality is judgment).

---

## Generic Markdown-agent lens (Codex / Copilot)

Apply only when the audited skill is authored for a generic markdown-based agent
system rather than Claude.

### 1. Flat and explicit structure

- **Rule**: use active voice, verb-first instructions, and bullet/numbered lists.
- **Check**: are the instructions imperative and unambiguous?

### 2. Single source of truth

- **Rule**: do not duplicate instructions across files — models that can't
  prioritize context well get confused by conflicting copies.
- **Check**: ensure `SKILL.md` does not repeat verbatim what already lives in
  `references/`.

### 3. Modality explicitness

- **Rule**: use normative keywords strictly (`MUST`, `MUST NOT`, `SHOULD`,
  `SHOULD NOT`).
- **Check**: audit for weak language ("it would be good to", "try to") and
  propose normative replacements.

### 4. Diagrams earn their place

- **Rule**: prefer a Markdown list to a Mermaid/Graphviz graph unless the graph
  captures a genuinely non-obvious decision point (or is rendered for a human).
- **Check**: remove flowcharts that only depict a linear process.

---

## See Also

- `references/single-skill-audit.md` — the cross-platform audit procedure
  (default lens).
- `references/principles.md` — the four structural principles (bundled).
- `references/authoring-for-claude.md` — the instruction-craft dimension
  (bundled).
- `references/archetypes.md` — the archetype model (bundled).
