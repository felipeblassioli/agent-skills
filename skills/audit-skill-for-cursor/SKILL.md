---
name: audit-skill-for-cursor
description: Use when the user asks to "audit", "review", or "improve" a specific skill or skills directory for context efficiency and correct progressive disclosure formatting.
disable-model-invocation: true
---

# Audit Skill for Cursor

## Overview
This skill audits and improves Cursor skills to ensure they function as context-efficient dispatchers, following progressive disclosure and TDD-driven documentation principles. 

## When to Use
- User asks to "audit", "review", or "check" a specific skill or `.cursor/skills` directory.
- User asks to "improve a skill for context efficiency".
- You need to verify if a skill meets registry progressive disclosure and gating standards.

## Do NOT Use When
- Creating a *new* skill from scratch (Use `cursor-skill-creator` or `writing-skills`).
- Testing code execution or running unit tests.
- Simply updating the registry or bumping a version.

## Core Pattern

1. **Resolve Targets**: Identify the skill directory or `SKILL.md` file.
2. **Execute Audit**: Follow the detailed audit and improvement procedure.
   - **REQUIRED**: Read [references/audit-procedure.md](references/audit-procedure.md).
3. **Reference Best Practices**: As part of the improvement proposals, consult the target-specific guidelines based on the agent ecosystem:
   - For Claude/Anthropic: [references/anthropic-best-practices.md](references/anthropic-best-practices.md)
   - For Cursor IDE: [references/cursor-best-practices.md](references/cursor-best-practices.md)
   - For Codex/Copilot: [references/codex-best-practices.md](references/codex-best-practices.md)
4. **Propose, Don't Apply**: Output an unapplied remediation plan (diffs/file moves). **Do NOT apply changes without explicit user confirmation.**

## Common Mistakes
- Applying changes automatically. (Always ask: "Do you want me to apply the remediation plan as proposed?")
- Writing heavy narrative in `SKILL.md`. (Move it to `references/`.)
