# Type-Safety First

Kysely is most valuable when the TypeScript type is a faithful description of
the SQL result. Prefer designs that keep Kysely's inferred types intact.

## Default Policy

| Situation | Prefer | Avoid |
|---|---|---|
| Table definitions | `Database` table interfaces plus `Selectable`, `Insertable`, `Updateable` | Reusing table interfaces as query result DTOs |
| Nullable columns | `column: T | null` | Optional table properties for nullable DB columns |
| Generated or operation-specific columns | `Generated<T>` or `ColumnType<Select, Insert, Update>` | Making callers supply generated values |
| Driver-returned values | Align types with the database driver runtime output | Declaring the type you wish the driver returned |
| Dynamic filters | Additive `where` calls or expression arrays | Untyped string concatenation |
| Conditional selections | Branch explicitly for exact unions, or use `$if` for optional fields | Reassigning a narrowed builder and expecting its output type to change |
| Reusable helpers | `Expression<T>`, `ExpressionBuilder`, `ref`, `val`, `fn` | Hard-coded column names inside raw SQL |
| Raw SQL | `sql<T>` with normal substitutions and typed refs | `sql.raw`, `sql.id`, `sql.ref`, `sql.table` with unchecked input |
| Deep query types | `$assertType<T>()` with structurally equal output types | `Simplify<T>` as a fix for TypeScript recursion errors |

## Review Checklist

- The `Database` type reflects the database and driver, not domain wishes.
- Query result types are inferred where possible; explicit result types are used
  only at module boundaries or with `$assertType<T>()`.
- Dynamic selections use `$if` only when optional result fields are acceptable.
  Use separate branches when the caller needs exact discriminated unions.
- Helper functions accept `Expression<T>` inputs and avoid assumptions about
  the caller's visible tables unless that constraint is intentional.
- Raw SQL substitutions use normal `${value}` parameters by default. Identifier
  helpers are used only with trusted, allowlisted names.
- Every raw expression has the narrowest honest output type, for example
  `sql<string>`, `sql<SqlBool>`, or `sql<{ count: number }[]>`.

## Patterns

### Keep schema types operation-aware

```ts
import type { ColumnType, Generated, Insertable, Selectable, Updateable } from 'kysely'

interface PersonTable {
  id: Generated<number>
  first_name: string
  last_name: string | null
  created_at: ColumnType<Date, string | undefined, never>
}

type Person = Selectable<PersonTable>
type NewPerson = Insertable<PersonTable>
type PersonUpdate = Updateable<PersonTable>
```

### Preserve inference in conditional selections

```ts
const person = await db
  .selectFrom('person')
  .select('first_name')
  .$if(includeLastName, (qb) => qb.select('last_name'))
  .where('id', '=', id)
  .executeTakeFirstOrThrow()

// person.last_name is optional because runtime decides whether it was selected.
```

If the caller needs exact return shapes, branch and return inside each branch
instead of reassigning the query builder.

### Type raw SQL through expressions

```ts
import { sql, type Expression, type SqlBool } from 'kysely'

function lower(expr: Expression<string>) {
  return sql<string>`lower(${expr})`
}

function isOlderThan(age: Expression<number>) {
  return sql<SqlBool>`age > ${age}`
}

const rows = await db
  .selectFrom('person')
  .select(['id', 'first_name'])
  .where(({ ref, val }) => isOlderThan(val(60)))
  .where(({ eb, ref }) => eb(lower(ref('first_name')), '=', 'jennifer'))
  .execute()
```

Normal `${}` substitutions become parameters. Do not use `sql.raw`, `sql.id`,
`sql.ref`, or `sql.table` with user-controlled strings.

## Type Errors Are Signals

When TypeScript rejects a Kysely query, first assume the query shape has lost
context:

1. Check whether a helper hard-codes a table that is not always visible.
2. Check whether a mutable builder reassignment downcasted the output type.
3. Check whether raw SQL bypassed `ref`, `val`, `fn`, or `Expression<T>`.
4. For `TS2589`, use `$assertType<T>()` at subquery/CTE boundaries with a
   structurally equal type.

Do not silence Kysely type errors with `as any`. If a cast is unavoidable at an
external boundary, isolate it next to validation or driver configuration and
document why the runtime value matches the declared type.
