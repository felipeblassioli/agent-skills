# Cursor Best Practices

When auditing or improving skills targeted for the Cursor IDE, focus on IDE-specific capabilities, progressive disclosure, and user experience.

## 1. Surface Selection
Ensure the artifact actually belongs as a skill.
- **Rule**: If the guidance is pervasive and should apply to every single chat without the user asking, it should be a `.cursor/rules/*.mdc` file, NOT a skill.
- **Check**: Does the skill describe project-wide persistent rules (like "Always use Tailwind")? If so, recommend converting it to an MDC rule.

## 2. Invocation Modes
Cursor supports skills that auto-invoke based on context, as well as slash-commands.
- **Rule**: If the skill is meant to be a strictly invoked workflow (e.g., `/audit`), it MUST include `disable-model-invocation: true` in the frontmatter.
- **Check**: Audit whether the skill's intent aligns with its invocation settings.

## 3. Progressive Disclosure (Context Saving)
Cursor relies on reading files on-demand.
- **Rule**: `SKILL.md` should read like a table of contents.
- **Rule**: Use the `Read` tool explicitly in the `SKILL.md` dispatcher to instruct the agent to read `references/*` when necessary.
- **Check**: Look for inline code snippets, long templates, or API references inside `SKILL.md` and propose moving them to `assets/` or `references/`.

## 4. Hook and Subagent Hand-offs
- **Rule**: Cursor can spawn subagents. Skills should explicitly instruct when to use the `Task` tool (subagent) for parallel or deep tasks.
- **Check**: Ensure workflows that imply long-running parallel tasks explicitly mention dispatching subagents.
