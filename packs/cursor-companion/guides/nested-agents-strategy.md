# Nested AGENTS Strategy

Use this guide when a Cursor project needs repository-local routing knowledge
without bloating root instructions.

## Core split

- root `AGENTS.md`: repo invariants, architecture boundaries, shared commands,
  and routing hints
- nested `AGENTS.md`: subtree-specific execution context where workflows truly
  diverge
- `.cursor/rules/*.mdc`: persistent cross-cutting policy, including path-scoped
  language or review guidance
- `skills/`: reusable knowledge and routing logic that should transfer across
  repositories
- `packs/`: installable `.cursor/` runtime assets plus reusable guides and
  templates

## Recommended pattern

Use "root for policy, leaf for execution".

```text
repo/
├── AGENTS.md
├── .cursor/
│   └── rules/
│       ├── monorepo.mdc
│       └── typescript.mdc
├── apps/
│   ├── web/
│   │   └── AGENTS.md
│   └── api/
│       └── AGENTS.md
└── packages/
    └── shared/
        └── AGENTS.md
```

## What belongs in root `AGENTS.md`

- package manager and shared test/lint/build entrypoints
- repo-wide architecture and dependency boundaries
- generated-code and safety policies
- short routing notes that point the agent to the right subtree or skill

Keep it short. If a detail matters only inside one subtree, move it down.

## What belongs in nested `AGENTS.md`

- local run, test, lint, codegen, or migration commands
- local folder layout and layering rules
- fixture, mock, schema, or release notes specific to the subtree
- stack-specific conventions that do not apply repo-wide

Only add a nested file when future work in that subtree will benefit from it.

## When to avoid another nested file

- the content only repeats root instructions
- the guidance is really a language policy better expressed as a rule
- the subtree is too small to justify its own execution playbook
- the knowledge should be shared across projects, which makes it a skill instead

## Anti-drift rules

- do not duplicate the same instruction across root `AGENTS.md`, nested
  `AGENTS.md`, and `.cursor/rules`
- keep nesting shallow; root plus one local layer is the default
- prefer linking to focused docs instead of growing `AGENTS.md` into a handbook
- if a policy is non-negotiable, enforce it with hooks and explain it with rules

## Templates

Start from:

- `assets/templates/root-agents-template.md`
- `assets/templates/package-agents-template.md`

Customize them for the project after installation. The pack provides the
templates, but the repository should own the resulting `AGENTS.md` files.
