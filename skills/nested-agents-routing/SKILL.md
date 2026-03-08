---
name: nested-agents-routing
description: Design and review repository-local agent guidance using root and nested `AGENTS.md`, `.cursor/rules`, skills, and packs. Use when organizing monorepo AI instructions, deciding where routing knowledge should live, or authoring directory-specific `AGENTS.md` files for Cursor-first projects.
---

# Nested AGENTS Routing

Use this skill to decide which guidance belongs in `AGENTS.md`, nested
`AGENTS.md`, `.cursor/rules`, `skills/`, or `packs/`.

## When to Apply

Reference this skill when:

- creating or refactoring repo-local agent guidance
- deciding whether a rule belongs in root `AGENTS.md` or a nested file
- documenting monorepo routing knowledge for Cursor-first projects
- reviewing a repo for instruction overlap, drift, or over-nesting
- deciding whether reusable knowledge should become a `skill` instead

## When NOT to Apply

Do NOT use this skill when:

- the task is ordinary code implementation unrelated to agent guidance
- the user needs runtime enforcement rather than prompt guidance
- the question is only about live `.cursor/` install mechanics

## Canonical Model

Use `AGENTS.md` as the canonical nested instruction file in Cursor-first repos.

Split responsibilities like this:

| Surface | Owns | Best for |
|---|---|---|
| Root `AGENTS.md` | Repo invariants and routing map | shared commands, architecture boundaries, "where to look" guidance |
| Nested `AGENTS.md` | Local execution context | package-specific commands, folder structure, local workflows |
| `.cursor/rules/*.mdc` | Persistent cross-cutting policy | language rules, security policy, review guard-rails, scoped project guidance |
| `skills/` | Reusable knowledge and routing heuristics | guidance that should transfer across repos or users |
| `packs/` | Installable Cursor runtime assets | `.cursor/agents`, `.cursor/rules`, hooks, MCP examples, templates, guides |

## Root For Policy, Leaf For Execution

### Root `AGENTS.md`

Keep the root file short and invariant-focused.

Put these here:

- package manager, test, lint, and build entrypoints used across the repo
- architecture boundaries and generated-code policies
- repo-wide workflow constraints such as branch or PR conventions
- routing hints that tell the agent which directory or skill to consult next

Do not put large local runbooks here.

### Nested `AGENTS.md`

Add a nested file only when the subtree actually diverges from the root.

Good reasons:

- different language or framework
- different run/test/lint commands
- different folder structure or layering rules
- local fixtures, migrations, codegen, or release workflow

Bad reasons:

- restating root policy in another location
- copying language rules already covered by `.cursor/rules`
- adding a file "just in case" for a trivial subtree

## Authoring Workflow

1. Start with a thin root `AGENTS.md`.
2. Move cross-cutting policy into `.cursor/rules/*.mdc`.
3. Add a nested `AGENTS.md` only where workflows materially diverge.
4. Keep reusable methodology in a `skill` instead of duplicating it in repo files.
5. Use a `pack` only when you need installable `.cursor/` runtime assets or
   reusable templates and guides.

## Anti-Drift Rules

- Do not duplicate the same instruction across root `AGENTS.md`, nested
  `AGENTS.md`, and `.cursor/rules`.
- Keep nesting shallow: root plus one local layer is usually enough.
- Prefer links to focused docs over turning `AGENTS.md` into a handbook.
- If a rule must always apply, do not rely on `AGENTS.md` alone; use hooks for
  enforcement and `.cursor/rules` to explain the policy.

## Review Checklist

When reviewing an instruction layout, verify:

- root `AGENTS.md` contains invariants, not local runbooks
- each nested `AGENTS.md` owns only subtree-specific execution details
- `.cursor/rules` cover persistent cross-cutting policy
- skills carry reusable knowledge that should not be rewritten per repo
- packs provide runtime assets and templates, not repo-specific nested files

## Output Pattern

When advising on structure, present:

1. the recommended surfaces
2. the proposed file locations
3. which content moves to root `AGENTS.md`, nested `AGENTS.md`, `.cursor/rules`,
   a `skill`, or a `pack`
4. any duplication or conflict risks
