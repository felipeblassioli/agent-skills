# Anthropic Best Practices

When auditing or improving skills targeted for Claude (via Claude Code or the Anthropic platform), ensure the skill adheres to the following principles derived from Anthropic's documentation best practices and `writing-skills.md`.

## 1. Claude Search Optimization (CSO)
Claude relies heavily on the `description` frontmatter field to decide whether to load a skill.
- **Rule**: The description MUST start with "Use when...".
- **Rule**: The description MUST NOT summarize the workflow. It must only contain the symptoms, triggers, and situational context.
- **Check**: Audit the `description` for workflow summaries. If found, propose a refactor to strictly list triggers.

## 2. Token Efficiency
Claude has a large context window, but loading unnecessary skills degrades performance and increases costs.
- **Rule**: `SKILL.md` must be an index (< 200-500 words).
- **Rule**: Heavy reference material MUST be pushed to `references/`.
- **Check**: Measure the word count of `SKILL.md`. Propose moving sections to `references/` if it exceeds 500 words.

## 3. TDD for Documentation
Anthropic agents perform best when boundaries are explicit and rationalizations are closed.
- **Rule**: Skills should anticipate agent "rationalizations" (e.g., skipping tests because the change is small).
- **Check**: Ensure discipline-enforcing skills explicitly forbid workarounds (e.g., "Violating the letter of the rules is violating the spirit of the rules.")

## 4. Cross-Referencing
- **Rule**: Use explicit requirement markers (e.g., `**REQUIRED SUB-SKILL:** Use other-skill`).
- **Rule**: Do not use `@path/to/skill` as it force-loads context preemptively.
- **Check**: Audit for `@` mentions of other skills in `SKILL.md` and replace them with standard cross-references.
