# Local Agent Guide

Use this file only for subtree-specific execution context.

## Scope

- describe the directory this file governs
- explain how it differs from the root `AGENTS.md`

## Local commands

- run: `...`
- test: `...`
- lint: `...`
- build or codegen: `...`

## Local structure

- describe the important folders and their responsibilities
- note fixture, schema, migration, or generated-code locations

## Local conventions

- naming, layering, or data-flow rules specific to this subtree
- framework or service details not shared repo-wide

## Escalation points

- if policy is cross-cutting, move it to `.cursor/rules`
- if guidance should be reused across repos, make it a `skill`
- if behavior must be enforced, use hooks instead of prompt text alone

## Keep out of this file

- root-level repo policy already defined elsewhere
- generic language guidance already covered by rules
- details that belong in product docs rather than agent routing context
