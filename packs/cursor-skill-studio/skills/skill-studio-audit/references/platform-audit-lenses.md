# Platform Audit Lenses

When auditing or improving a skill, also apply the lens that matches the target
ecosystem. Merged from the per-ecosystem references that previously lived under
`skills/audit-skill-for-cursor/references/` (Anthropic, Cursor, Codex).

Apply the **target-platform** lens only when the audited skill is intended for
that ecosystem; do not duplicate cross-platform rules already covered by
`references/single-skill-audit.md`.

---

## Cursor (IDE) lens

When the audited artifact ships into `.cursor/skills/` or `~/.cursor/skills/`,
also focus on IDE-specific capabilities, progressive disclosure, and UX.

### 1. Surface selection
Ensure the artifact actually belongs as a skill.
- **Rule**: If the guidance is pervasive and should apply to every chat without
  the user asking, it belongs as a `.cursor/rules/*.mdc` file, NOT a skill.
- **Check**: Does the skill describe project-wide persistent rules (like
  "Always use Tailwind")? If so, recommend converting it to an MDC rule.

### 2. Invocation modes
Cursor supports both auto-invocation and slash-command invocation.
- **Rule**: If the skill is meant to be a strictly invoked workflow
  (e.g., `/audit`), it MUST include `disable-model-invocation: true` in the
  frontmatter.
- **Check**: Audit whether the skill's intent aligns with its invocation
  settings.

### 3. Progressive disclosure (context saving)
Cursor relies on reading files on-demand.
- **Rule**: `SKILL.md` should read like a table of contents.
- **Rule**: Use explicit Read instructions in the `SKILL.md` dispatcher to
  instruct the agent to read `references/*` when necessary.
- **Check**: Look for inline code snippets, long templates, or API references
  inside `SKILL.md` and propose moving them to `assets/` or `references/`.

### 4. Hook and subagent hand-offs
- **Rule**: Cursor can spawn subagents. Skills should explicitly instruct when
  to use the Task tool (subagent) for parallel or deep tasks.
- **Check**: Ensure workflows that imply long-running parallel tasks
  explicitly mention dispatching subagents.

---

## Anthropic (Claude / Claude Code) lens

When the audited artifact ships into `~/.claude/skills/` or is consumed by
Claude Code / the Anthropic platform.

### 1. Claude Search Optimization (CSO)
Claude relies heavily on the `description` frontmatter field to decide whether
to load a skill.
- **Rule**: The description MUST start with "Use when ...".
- **Rule**: The description MUST NOT summarize the workflow. It must only
  contain the symptoms, triggers, and situational context.
- **Check**: Audit the `description` for workflow summaries. If found, propose
  a refactor to strictly list triggers.

### 2. Token efficiency
Claude has a large context window, but loading unnecessary skills degrades
performance and increases cost.
- **Rule**: `SKILL.md` must be an index (~200-500 words).
- **Rule**: Heavy reference material MUST be pushed to `references/`.
- **Check**: Measure `SKILL.md` size. Propose moving sections to `references/`
  when it grows past 500 words.

### 3. TDD for documentation
Anthropic agents perform best when boundaries are explicit and rationalizations
are closed.
- **Rule**: Skills should anticipate agent "rationalizations" (e.g., skipping
  tests because the change is small).
- **Check**: Ensure discipline-enforcing skills explicitly forbid workarounds
  (e.g., "Violating the letter of the rules is violating the spirit of the
  rules.").

### 4. Cross-referencing
- **Rule**: Use explicit requirement markers (e.g.,
  `**REQUIRED SUB-SKILL:** Use other-skill`).
- **Rule**: Do not use `@path/to/skill` as it force-loads context preemptively.
- **Check**: Audit for `@` mentions of other skills in `SKILL.md` and replace
  them with standard cross-references.

---

## Codex / generic Markdown agents lens

When the audited artifact is intended for GitHub Copilot, Codex, or generic
markdown-based agent systems.

### 1. Flat and explicit structure
Codex models benefit from flat, unambiguous declarative statements.
- **Rule**: Use active voice, verb-first naming.
- **Check**: Are the instructions clear, imperative, and formatted as bullet
  points or numbered lists?

### 2. Strict markdown parsing
- **Rule**: Avoid complex Graphviz (`.dot`) or Mermaid graphs if a simple
  Markdown list suffices, unless explicitly visualizing for a human partner
  via SVG rendering.
- **Check**: If a flowchart is present in `SKILL.md`, verify it represents a
  non-obvious decision point. Remove it if it is just a linear process.

### 3. Single source of truth
- **Rule**: Prevent duplicate instructions across files, as this confuses
  models that cannot prioritize context well.
- **Check**: Ensure `SKILL.md` does not repeat the exact same instructions
  found in `references/`.

### 4. Modality explicitness
- **Rule**: Use normative keywords strictly (`MUST`, `MUST NOT`, `SHOULD`,
  `SHOULD NOT`).
- **Check**: Audit for weak language ("it would be good to", "try to") and
  propose replacements with normative keywords.

---

## See Also

- `references/single-skill-audit.md` — cross-platform audit procedure used as
  the default lens.
- `../skill-studio-write/references/cursor-skill-standard.md` — the
  authoring-side standard. Link, do not duplicate, when explaining what a
  skill should look like.
- `docs/architecture.md` — repo-wide compliance target enforced by the
  `skill-architecture-checker` subagent.
