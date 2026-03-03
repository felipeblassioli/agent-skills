---
name: migrate-turbi-libs
description: Opportunistically migrate away from deprecated @turbi/mysql, @turbi/types, and @turbi/config libraries when touching code that uses them. Use when editing files that import @turbi/mysql, @turbi/types (Result/ValueResult), or @turbi/config, or when creating new repositories, error handling, or configuration code. Triggers on tasks involving Filterable, ConnectionManager, ValueResult, Result, cachedConfig, setup(), setDefaultCredentials, or any @turbi/* import.
---

# Migrate Away from `@turbi` Libraries

Per [RFC-0001](../../../docs/rfc/0001-turbi-libs-are-harmful.md), three `@turbi/*` packages are deprecated due to SQL injection vulnerabilities, false type-safety, and global mutable state. When you encounter code using these packages, **opportunistically migrate** the touched code.

## Golden Rule

**Never introduce new usage of `@turbi/mysql`, `@turbi/types` Result classes, or `@turbi/config` global APIs.** When editing a file that imports them, migrate the touched functions — don't rewrite the entire file unless the user asks.

## Quick Decision Table

| You see… | Replace with… | Section |
|----------|---------------|---------|
| `import { Filterable, … } from '@turbi/mysql'` | Kysely query builder | [1](#1-turbi-mysql--kysely) |
| `new ConnectionManager` / `manager()` / `static pools` | `Kysely<Database>` instance via DI | [1](#1-turbi-mysql--kysely) |
| `pagination()` from `@turbi/mysql` | `.limit()` / `.offset()` on Kysely query | [1](#1-turbi-mysql--kysely) |
| `ValueResult` / `Result` / `.checkSuccess()` | Typed exception hierarchy (`AppError`) | [2](#2-turbi-types--typed-exceptions) |
| `import { config } from '@turbi/config'` | Explicit config param or `AppContext` | [3](#3-turbi-config--dependency-injection) |
| `setup()` / `setDefaultCredentials()` | `AppContext` created once, passed through | [3](#3-turbi-config--dependency-injection) |
| `let cachedConfig: any` / global `let pool` | Local const, no module-level mutable state | [3](#3-turbi-config--dependency-injection) |

---

## 1. `@turbi/mysql` → Kysely

### Why (critical)

- `Filterable.contains` has a **SQL injection** vulnerability (raw string interpolation).
- `notIn` has a parameter binding bug.
- `pagination()` interpolates values directly into SQL.
- The Filter class pattern requires touching 3 places per column.

### Migration pattern

1. **Define table types** (or use `kysely-codegen` to generate from DB):

```typescript
import { Generated, ColumnType, Selectable, Insertable, Updateable } from 'kysely';

interface WashersTable {
  id: Generated<number>;
  name: string;
  active: number;
  added: ColumnType<Date, string | undefined, never>;
}

interface Database {
  'schema.table': WashersTable;
}

export type Washer = Selectable<WashersTable>;
export type NewWasher = Insertable<WashersTable>;
export type WasherUpdate = Updateable<WashersTable>;
```

2. **Create DB instance** (no global singleton):

```typescript
import { Kysely, MysqlDialect } from 'kysely';
import { createPool } from 'mysql2';

export function createDb(config: { host: string; user: string; password: string; database: string }): Kysely<Database> {
  return new Kysely<Database>({
    dialect: new MysqlDialect({ pool: createPool({ ...config, connectionLimit: 25, enableKeepAlive: true }) }),
  });
}
```

3. **Replace Filter classes with plain criteria objects**:

```typescript
interface SearchCriteria {
  id?: number;
  nameContains?: string;
  active?: number;
  limit?: number;
  offset?: number;
}

export async function search(db: Kysely<Database>, criteria: SearchCriteria) {
  let query = db.selectFrom('schema.table').selectAll();
  if (criteria.id !== undefined) query = query.where('id', '=', criteria.id);
  if (criteria.nameContains !== undefined) query = query.where('name', 'like', `%${criteria.nameContains}%`);
  if (criteria.limit !== undefined) query = query.limit(criteria.limit);
  if (criteria.offset !== undefined) query = query.offset(criteria.offset);
  return query.execute();
}
```

4. **Transactions** — same interface, no separate wrappers:

```typescript
await db.transaction().execute(async (trx) => {
  const id = await insert(trx, data);
  await update(trx, id, { active: 1 });
});
```

### Coexistence

Kysely and `@turbi/mysql` can coexist — both use `mysql2`. During migration, Kysely can share an existing `mysql2.Pool` via a custom dialect.

---

## 2. `@turbi/types` → Typed Exceptions

### Why

- `ValueResult.checkSuccess()` throws — it's exceptions disguised as a Result type.
- All generics default to `any`, giving false type-safety.
- Type guards return `boolean` instead of type predicates.

### Migration pattern

1. **Use the typed error hierarchy**:

```typescript
export class AppError extends Error {
  constructor(
    message: string,
    public readonly code: string,
    public readonly statusCode: number = 500,
    public readonly cause?: unknown,
  ) {
    super(message);
    this.name = this.constructor.name;
  }
}

export class NotFoundError extends AppError {
  constructor(entity: string, id: string | number, cause?: unknown) {
    super(`${entity} ${id} not found`, 'NOT_FOUND', 404, cause);
  }
}

export class ValidationError extends AppError {
  constructor(message: string, public readonly fields?: Record<string, string>) {
    super(message, 'VALIDATION_ERROR', 400);
  }
}

export class ConflictError extends AppError {
  constructor(message: string, cause?: unknown) {
    super(message, 'CONFLICT', 409, cause);
  }
}

export class UnauthorizedError extends AppError {
  constructor(message: string = 'Unauthorized') {
    super(message, 'UNAUTHORIZED', 401);
  }
}
```

2. **Return data or throw** — no `ValueResult` wrapper:

```typescript
// Before
async function findById(id: number): Promise<ValueResult<Washer>> {
  const washer = await repo.findById(id);
  return new ValueResult(washer).checkNotEmptyValue({ code: 404 });
}

// After
async function findById(db: Kysely<Database>, id: number): Promise<Washer> {
  const washer = await db.selectFrom('wash.washers').selectAll().where('id', '=', id).executeTakeFirst();
  if (!washer) throw new NotFoundError('Washer', id);
  return washer;
}
```

3. **Centralized Express error handler**:

```typescript
export function errorHandler(err: unknown, _req: Request, res: Response, _next: NextFunction): void {
  if (err instanceof AppError) {
    res.status(err.statusCode).json({ success: false, error: { code: err.code, message: err.message } });
    return;
  }
  console.error('Unhandled error:', err);
  res.status(500).json({ success: false, error: { code: 'INTERNAL_ERROR', message: 'An unexpected error occurred' } });
}
```

### What NOT to do

- Don't introduce `neverthrow` or other Result-monad libraries — the codebase is exception-based and a full rewrite would be needed.
- Don't keep `ValueResult` "just for compatibility" in new code.

---

## 3. `@turbi/config` → Dependency Injection

### Why (critical)

- `cachedConfig` is `any`, mutated as a side-effect.
- `setup()` per request causes credential cross-contamination under concurrency.
- Version mismatches create duplicate config singletons.
- Errors are swallowed with no diagnostics.

### Migration pattern

1. **Define `AppContext`** — immutable, created once:

```typescript
export interface AppContext {
  db: Kysely<Database>;
  stage: 'production' | 'test' | 'rc';
  sender: { id: string; name: string; email: string; isService: boolean };
  credentials: Record<string, string>;
}
```

2. **Create context at module load, freeze, pass through**:

```typescript
const prodContext = createContext('production');
const testContext = createContext('test');

exports.api_fleet = functions.runWith({ timeoutSeconds: 300, memory: '512MB' })
  .https.onRequest((req, res) => fleet(req, res, prodContext));
```

3. **Providers receive credentials explicitly** — no `setDefaultCredentials()`:

```typescript
export async function getVehicle(credentials: Record<string, string>, vehicleId: number): Promise<Vehicle> {
  const res = await fetch(`${FLEET_API_URL}/vehicles/${vehicleId}`, {
    headers: { 'Content-Type': 'application/json', ...credentials },
  });
  if (!res.ok) throw new AppError('Fleet API error', 'PROVIDER_ERROR', res.status);
  return res.json();
}
```

### Key rules

- **Never** store credentials in module-level `let` variables.
- **Never** call `setup()` per-request — create context once at cold start.
- **Never** hard-code API keys in source — use environment variables or secret manager.

---

## Opportunistic Migration Checklist

When you touch a file that imports `@turbi/*`:

- [ ] Identify which `@turbi` packages the file uses
- [ ] For **functions you're editing**: migrate to the new pattern
- [ ] For **functions you're not editing**: leave unchanged (avoid scope creep)
- [ ] If creating a **new file** in the same domain: use only the new patterns
- [ ] Ensure the migrated code still compiles alongside unmigrated code
- [ ] Add the `kysely` / error hierarchy imports as needed
- [ ] Remove `@turbi/*` imports from the file **only if** all usages in the file are migrated

## Detailed Patterns

For complete before/after examples, table type definitions, and the full error hierarchy, see [reference.md](reference.md).
