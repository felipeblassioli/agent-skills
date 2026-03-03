# Reference: `@turbi` Migration Patterns

Detailed before/after patterns for migrating away from `@turbi/mysql`, `@turbi/types`, and `@turbi/config`.

## Table of Contents

- [Kysely Database Types](#kysely-database-types)
- [Repository Migration (Full Example)](#repository-migration-full-example)
- [Error Hierarchy (Complete)](#error-hierarchy-complete)
- [AppContext Pattern (Complete)](#appcontext-pattern-complete)
- [Common Transformations](#common-transformations)
- [Coexistence During Migration](#coexistence-during-migration)

---

## Kysely Database Types

Use `kysely-codegen` to auto-generate from DB, or define manually:

```typescript
import { Generated, ColumnType, Selectable, Insertable, Updateable } from 'kysely';

interface WashersTable {
  id: Generated<number>;
  serviceProviderId: number;
  name: string;
  cpf: string;
  email: string;
  cellphone: string;
  uid: string;
  newuid: string | null;
  oldUid: string | null;
  projectId: string | null;
  dateOfBirth: string | null;
  documentURLs: string | null;
  podRoles: string | null;
  author: string;
  active: number;
  added: ColumnType<Date, string | undefined, never>;
  updated: ColumnType<Date, string | undefined, string | undefined>;
  excluded: ColumnType<Date, string | undefined, string | undefined>;
}

interface ServiceProviderTable {
  id: Generated<number>;
  name: string;
}

// Use 'schema.table' format for cross-schema queries
interface Database {
  'wash.washers': WashersTable;
  'serviceProvidersManagement.serviceProvider': ServiceProviderTable;
}

export type Washer = Selectable<WashersTable>;
export type NewWasher = Insertable<WashersTable>;
export type WasherUpdate = Updateable<WashersTable>;
```

---

## Repository Migration (Full Example)

### Before: `@turbi/mysql` Filter pattern (~78 lines per entity)

```typescript
import { Filterable, ConnectionManager, pagination } from '@turbi/mysql';
import { config } from '@turbi/config';

let pool: Pool;
let _db: Connection;

class WasherFilter {
  id = new Filterable<number>();
  serviceProviderId = new Filterable<number>();
  name = new Filterable<string>();
  cpf = new Filterable<string>();
  // ... 13 more fields, each with Filterable wrapper

  compile() {
    const where = this.id.compile('w.id')
      .concat(this.serviceProviderId.compile('w.serviceProviderId'))
      .concat(this.name.compile('w.name'))  // name.contains → SQL INJECTION
      // ... 13 more .concat() calls
    return { clauses: where.clauses.join(' AND '), values: where.values };
  }
}

export async function search(filter: WasherFilter, pg: IPagination) {
  const { clauses, values } = filter.compile();
  const where = clauses ? `WHERE ${clauses}` : '';
  const paginate = pagination(pg);  // raw interpolation
  const sql = `SELECT ... FROM wash.washers w ${where} ${paginate}`;
  const [rows] = await _db.query(sql, values);
  return rows;
}
```

### After: Kysely (~40 lines, type-safe, no injection)

```typescript
import { Kysely } from 'kysely';
import { Database, Washer } from './types';

interface WasherSearchCriteria {
  id?: number;
  serviceProviderId?: number;
  name?: string;
  nameContains?: string;
  cpf?: string;
  email?: string;
  uid?: string;
  active?: number;
  limit?: number;
  offset?: number;
}

export async function search(db: Kysely<Database>, criteria: WasherSearchCriteria): Promise<Washer[]> {
  let query = db
    .selectFrom('wash.washers as w')
    .innerJoin('serviceProvidersManagement.serviceProvider as sp', 'w.serviceProviderId', 'sp.id')
    .select([
      'w.id', 'w.serviceProviderId', 'w.name', 'sp.name as companyName',
      'w.cpf', 'w.email', 'w.cellphone', 'w.uid', 'w.newuid', 'w.oldUid',
      'w.projectId', 'w.dateOfBirth', 'w.podRoles', 'w.author',
      'w.active', 'w.added', 'w.updated', 'w.excluded', 'w.documentURLs',
    ]);

  if (criteria.id !== undefined) query = query.where('w.id', '=', criteria.id);
  if (criteria.serviceProviderId !== undefined) query = query.where('w.serviceProviderId', '=', criteria.serviceProviderId);
  if (criteria.name !== undefined) query = query.where('w.name', '=', criteria.name);
  if (criteria.nameContains !== undefined) query = query.where('w.name', 'like', `%${criteria.nameContains}%`);
  if (criteria.cpf !== undefined) query = query.where('w.cpf', '=', criteria.cpf);
  if (criteria.email !== undefined) query = query.where('w.email', '=', criteria.email);
  if (criteria.uid !== undefined) query = query.where('w.uid', '=', criteria.uid);
  if (criteria.active !== undefined) query = query.where('w.active', '=', criteria.active);
  if (criteria.limit !== undefined) query = query.limit(criteria.limit);
  if (criteria.offset !== undefined) query = query.offset(criteria.offset);

  return query.execute();
}

export async function insert(db: Kysely<Database>, washer: NewWasher): Promise<bigint> {
  const result = await db.insertInto('wash.washers').values(washer).executeTakeFirstOrThrow();
  return result.insertId!;
}

export async function update(db: Kysely<Database>, id: number, data: WasherUpdate): Promise<void> {
  await db.updateTable('wash.washers').set(data).where('id', '=', id).execute();
}

export async function count(db: Kysely<Database>, criteria: WasherSearchCriteria): Promise<number> {
  let query = db.selectFrom('wash.washers as w').select(db.fn.countAll<number>().as('qtd'));
  if (criteria.id !== undefined) query = query.where('w.id', '=', criteria.id);
  // ... same filter chain
  const result = await query.executeTakeFirstOrThrow();
  return result.qtd;
}
```

---

## Error Hierarchy (Complete)

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

### Express error handler

```typescript
import { Request, Response, NextFunction } from 'express';
import { AppError } from './errors';

export function errorHandler(err: unknown, _req: Request, res: Response, _next: NextFunction): void {
  if (err instanceof AppError) {
    res.status(err.statusCode).json({
      success: false,
      error: { code: err.code, message: err.message },
    });
    return;
  }
  console.error('Unhandled error:', err);
  res.status(500).json({
    success: false,
    error: { code: 'INTERNAL_ERROR', message: 'An unexpected error occurred' },
  });
}
```

---

## AppContext Pattern (Complete)

```typescript
import { Kysely, MysqlDialect } from 'kysely';
import { createPool } from 'mysql2';
import { Database } from './types';

export interface AppContext {
  db: Kysely<Database>;
  stage: 'production' | 'test' | 'rc';
  sender: { id: string; name: string; email: string; isService: boolean };
  credentials: Record<string, string>;
}

export function createContext(stage: 'production' | 'test' | 'rc'): AppContext {
  const config = loadConfig();  // pure function, no side effects
  const dbConfig = config.database['dbsqlt890'];

  return Object.freeze({
    db: new Kysely<Database>({
      dialect: new MysqlDialect({
        pool: createPool({ ...dbConfig, connectionLimit: 25, enableKeepAlive: true }),
      }),
    }),
    stage,
    sender: {
      id: config.origins.operation.id,
      name: config.origins.operation.name,
      email: config.origins.operation.name,
      isService: true,
    },
    credentials: {
      'X-TURBI-KEY': process.env.TURBI_API_KEY!,  // from env, never hard-coded
    },
  });
}
```

### Cloud Function wiring

```typescript
const prodContext = createContext('production');
const testContext = createContext('test');

exports.api_fleet = functions.runWith({ timeoutSeconds: 300, memory: '512MB' })
  .https.onRequest((req, res) => fleet(req, res, prodContext));

exports.api_fleet_test = functions.runWith({ timeoutSeconds: 300, memory: '512MB' })
  .https.onRequest((req, res) => fleet(req, res, testContext));
```

---

## Common Transformations

### `Filterable.contains` → Kysely `like`

```typescript
// Before (SQL INJECTION!)
const filter = new WasherFilter();
filter.name.contains = userInput;

// After (parameterized)
query = query.where('w.name', 'like', `%${criteria.nameContains}%`);
```

### `pagination()` → `.limit()` / `.offset()`

```typescript
// Before (raw interpolation)
const sql = `SELECT * FROM t ${pagination({ size: 10, number: 2 })}`;

// After (parameterized)
query = query.limit(10).offset(20);
```

### `ValueResult` → throw or return

```typescript
// Before
const result = new ValueResult(data);
result.checkNotEmptyValue({ code: 404, message: 'Not found' });
return result;

// After
if (!data) throw new NotFoundError('Entity', id);
return data;
```

### `config()?.database` → explicit parameter

```typescript
// Before
import { config } from '@turbi/config';
const dbConfig = config()?.database?.['dbsqlt890'] || {};

// After
function createDb(config: { host: string; user: string; password: string; database: string }) {
  return new Kysely<Database>({ dialect: new MysqlDialect({ pool: createPool(config) }) });
}
```

### `setDefaultCredentials()` → pass as argument

```typescript
// Before
import { IdentityProvider } from '@turbi/fleet-provider';
IdentityProvider.setDefaultCredentials({ 'X-TURBI-KEY': 'hardcoded-uuid' });

// After
async function callIdentityApi(credentials: Record<string, string>, ...args) {
  // credentials passed explicitly
}
```

---

## Coexistence During Migration

Both Kysely and `@turbi/mysql` use `mysql2` under the hood. They can coexist:

```typescript
import { Kysely, MysqlDialect } from 'kysely';
import { createPool, Pool } from 'mysql2';

// Shared pool used by both old and new code
const pool: Pool = createPool({ host, user, password, database });

// New code uses Kysely with the shared pool
const db = new Kysely<Database>({
  dialect: new MysqlDialect({ pool }),
});

// Old code continues using the pool directly until migrated
```

Migrate one domain/repository at a time. Don't attempt a big-bang rewrite.
