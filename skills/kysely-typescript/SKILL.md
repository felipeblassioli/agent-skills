---
name: kysely-typescript
description: >-
  Type-safe SQL query building in TypeScript using Kysely. Use when writing or
  reviewing Kysely queries, schema types, migrations, raw SQL snippets, dynamic
  filters, conditional selects, transactions, or reusable query helpers.
---

# Kysely TypeScript Knowledge Hub

Use Kysely so TypeScript describes the SQL you are actually going to run.
Preserve inference by default; when a query must become dynamic or raw, make the
unsafe boundary small, typed, and reviewable.

## Applicability Gate

Apply this skill when ANY of the following are true:

- The user asks to write or modify a database query using Kysely
- The user is designing a TypeScript schema for Kysely (the `Database` interface)
- The user asks whether Kysely code is still type-safe
- The user uses raw SQL, dynamic identifiers, conditional selects, or reusable helpers
- The user encounters a type instantiation error in a Kysely query
- The user asks how to build dynamic queries, CTEs, or reusable query helpers
- The user needs to write a database migration using Kysely

Do NOT apply when:

- The task is generic TypeScript quality with no Kysely or SQL surface
- The task is ORM relation modeling; Kysely is a query builder, not an ORM

## Routing Table

| Question | Route to |
|----------|----------|
| "How should I keep this Kysely code type-safe?" | [references/type-safety-first.md](references/type-safety-first.md) |
| "How do I define my database interface or get started?" | [references/getting-started.md](references/getting-started.md) |
| "How do I align TypeScript types with what the DB returns?" | [references/data-types.md](references/data-types.md) |
| "How do I build queries conditionally based on variables?" | [references/conditional-queries.md](references/conditional-queries.md) |
| "How do I fix 'Type instantiation is excessively deep'?" | [references/troubleshooting.md](references/troubleshooting.md) |
| "How do I reuse joined tables safely without duplicating?" | [references/deduplicate-joins.md](references/deduplicate-joins.md) |
| "How do I compile queries without executing them?" | [references/execution-flow.md](references/execution-flow.md) |
| "How do I write raw expressions, function calls, or subqueries?" | [references/expressions.md](references/expressions.md) |
| "How do I write a custom dialect or use a plugin?" | [references/extending.md](references/extending.md) |
| "How do I query Kysely's introspection or relation metadata?" | [references/relation-metadata.md](references/relation-metadata.md) |
| "How do I log queries or debug SQL output?" | [references/logging.md](references/logging.md) |
| "How do I write Kysely database migrations?" | [references/migrations.md](references/migrations.md) |
| "How do I write raw SQL or use the `sql` template tag?" | [references/raw-sql.md](references/raw-sql.md) |
| "How do I map or use database relations?" | [references/relations.md](references/relations.md) |
| "How do I extract query logic into reusable functions?" | [references/reusable-helpers.md](references/reusable-helpers.md) |
| "How do I pass query builders between functions?" | [references/splitting-queries.md](references/splitting-queries.md) |
| "How do I use DB schemas (like Postgres 'public')?" | [references/schemas.md](references/schemas.md) |

## Procedure

1. **Identify the task type.** What is the user trying to do with Kysely?
2. **Load the type-safety policy when it matters.** Read
   [references/type-safety-first.md](references/type-safety-first.md) for
   schema design, raw SQL, dynamic filters, conditional selects, reusable
   helpers, type errors, or Kysely code review.
3. **Route to the right reference.** Use the routing table above.
   Read only the reference file(s) needed — do not load all.
4. **Apply the methodology.** Follow the normative rules from the
   loaded reference.
5. **Verify the boundary.** Check that strict TypeScript accepts the query and
   that declared column types match the runtime values returned by the driver.

## Confirmation Policy

Do NOT execute destructive migrations or large schema changes without explicit user
confirmation. Present proposed code as diffs and wait for approval.
