# mysql2 security reference

Targets: `mysql2` and `mysql2/promise` on Node.js ≥ 18. Maps directly to OWASP A03 (Injection) with cross-cutting A05 hardening.

## 1. Parameterization (A03)

`mysql2` supports two prepared-statement APIs. Use one of them. Never interpolate user input into SQL strings.

```ts
import mysql from 'mysql2/promise';

// query(): client-side parameterization, escapes values into the SQL
const [rows] = await pool.query(
  'SELECT id, email FROM users WHERE email = ? LIMIT 1',
  [email],
);

// execute(): server-side prepared statement (preferred for repeat queries)
const [rows2] = await pool.execute(
  'SELECT id, email FROM users WHERE email = ? LIMIT 1',
  [email],
);
```

Rules:
- Use `?` placeholders for **values**. Never `${...}` template literals.
- `query()` escapes client-side; `execute()` uses real prepared statements. Both are safe against value-position injection. Prefer `execute()` for hot paths.
- Reject `null` / `undefined` upstream when a value is required; mysql2 binds them as `NULL` silently.

## 2. Identifiers cannot use `?` (A03)

Placeholders only bind values. Table and column names need the identifier escape `??`, with an allowlist.

```ts
const SORTABLE = new Set(['created_at', 'updated_at', 'email']);

function listUsers(sortBy: string, dir: 'ASC' | 'DESC') {
  if (!SORTABLE.has(sortBy)) throw new Error('invalid sort');
  const direction = dir === 'DESC' ? 'DESC' : 'ASC';   // never bind from user input
  return pool.query(
    'SELECT id, email FROM users ORDER BY ?? ' + direction + ' LIMIT 50',
    [sortBy],
  );
}
```

Rules:
- Sort direction, `LIMIT`, `OFFSET` keywords cannot be parameterized portably — validate against a fixed set, then concatenate.
- Always allowlist identifiers. `??` escaping prevents syntax injection but does not prevent referencing a column the user shouldn't see.

## 3. `LIKE` and `IN (...)` (A03)

```ts
// LIKE: escape % and _ in user input, then bind the whole pattern
function escapeLike(s: string) {
  return s.replace(/[\\%_]/g, (c) => '\\' + c);
}
const [rows] = await pool.execute(
  'SELECT id FROM users WHERE email LIKE ? ESCAPE \'\\\\\' LIMIT 50',
  [`%${escapeLike(term)}%`],
);

// IN (...): expand the placeholder, do not concatenate
const ids = [1, 2, 3];
const [rows2] = await pool.query(
  'SELECT id FROM posts WHERE id IN (?)',
  [ids],                                     // mysql2 expands the array
);
```

Rules:
- Bind the full `LIKE` pattern (`%foo%`) as a single parameter; do not concatenate `%` into the SQL string.
- `IN (?)` with `query()` expands an array. With `execute()` you must build `?, ?, ?` yourself — placeholder count must match.

## 4. Connection configuration (A05)

```ts
import mysql from 'mysql2/promise';

export const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 10,
  multipleStatements: false,        // MUST be false; default is false — never flip it
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: true } : undefined,
  charset: 'utf8mb4',
  dateStrings: true,                // avoid Date timezone surprises
  supportBigNumbers: true,
  bigNumberStrings: true,
});
```

Rules:
- `multipleStatements: false` is the default. **Never** enable it for code that handles user input. Enabling it turns any A03 finding into immediate full-DB compromise.
- Use TLS in production (`ssl.rejectUnauthorized: true`). Pinning a CA is stronger when the DB cert is internal.
- Bound `connectionLimit`. Unbounded pools amplify DoS into DB exhaustion.

## 5. Least-privilege DB user (A01, A05)

The Node app's MySQL user should have only what the app needs.

```sql
CREATE USER 'app'@'%' IDENTIFIED BY '...';
GRANT SELECT, INSERT, UPDATE, DELETE ON appdb.* TO 'app'@'%';
-- no GRANT, no FILE, no SUPER, no PROCESS, no CREATE USER, no DROP
REVOKE ALL ON mysql.* FROM 'app'@'%';
```

Rules:
- Migrations run under a separate user with DDL rights, not the app user.
- No `FILE` privilege — it enables `LOAD DATA INFILE` exfiltration through any A03.
- No `mysql.*` access. The app should not be able to read other accounts' hashes even if compromised.

## 6. Secrets and connection strings (A02, A05)

- Never log `pool.config` or `connection.config` — they contain the password.
- Read credentials from a secret manager or environment, never from a checked-in `.env` for production.
- Rotate the DB password on suspected leak; mysql2 has no automatic rotation hook — reload the pool on a rotation signal.

## 7. Errors and timeouts (A05, A09)

```ts
try {
  const [rows] = await pool.execute({
    sql: 'SELECT id FROM users WHERE email = ? LIMIT 1',
    values: [email],
    timeout: 2_000,                  // ms, query-level
  });
} catch (e: any) {
  // Never echo e.sqlMessage / e.sql to clients
  log.error({ code: e.code, errno: e.errno }, 'db_query_failed');
  throw new Error('db_unavailable');
}
```

Rules:
- Set per-query `timeout` for user-driven endpoints. Hung queries pin pool slots.
- `e.sql` and `e.sqlMessage` may include the bound values. Log them at `error` only, never in 5xx responses.
- Map driver errors to opaque domain errors before they reach the HTTP layer.

## 8. Stored procedures and dynamic SQL inside MySQL

If you must build SQL inside MySQL (`PREPARE ... FROM @sql`), all variables must come from `?` placeholders bound from the app side. Treat `EXECUTE IMMEDIATE` patterns as A03 by default and review.

## 9. Common mysql2 anti-patterns to flag

| Pattern | Why it fails | Fix |
|---|---|---|
| `` pool.query(`SELECT * FROM users WHERE email='${email}'`) `` | Classical A03 | `?` + values array |
| `pool.query('... ORDER BY ' + req.query.sort)` | Identifier injection | Allowlist + `??` |
| `multipleStatements: true` | One A03 → arbitrary statements | Keep `false`, split into separate calls |
| `connectionLimit` unset / very high | DoS amplifier | Bound to expected concurrency |
| App user with `GRANT ALL` | Lateral damage | Least privilege per §5 |
| `LIKE '%${term}%'` interpolated | A03 + broken `_`/`%` semantics | Escape and bind whole pattern |
| Echoing `err.sqlMessage` to clients | Leaks schema and bound values | Map to opaque error |
| Storing creds in `pool` config logged at boot | Secret leak | Redact / never log config |
