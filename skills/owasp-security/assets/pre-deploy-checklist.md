# Pre-deploy security checklist (Node.js / Express / mysql2)

Run before promoting to production. Each item links to the reference section that contains the fix.

## Authentication (A02, A07)
- [ ] Passwords hashed with bcrypt cost ≥ 12, or argon2id — [auth-patterns.md §1](../references/auth-patterns.md)
- [ ] JWT `verify` pins `algorithms: ['HS256' | 'RS256']` — [auth-patterns.md §2](../references/auth-patterns.md)
- [ ] Access TTL ≤ 15 min, refresh tokens rotated and revocable — [auth-patterns.md §3](../references/auth-patterns.md)
- [ ] Password reset is single-use, hashed-at-rest, ≤ 1 h TTL, constant response — [auth-patterns.md §4](../references/auth-patterns.md)
- [ ] MFA secrets encrypted at rest; recovery codes hashed — [auth-patterns.md §5](../references/auth-patterns.md)
- [ ] Auth endpoints rate-limited per (IP, account) — [express.md §5](../references/express.md)

## Authorization (A01)
- [ ] Default-deny: every router requires `authenticate` unless explicitly public — [express.md §7](../references/express.md)
- [ ] Ownership enforced **in the SQL `WHERE`**, not after fetch — [express.md §7](../references/express.md), [mysql2.md §1](../references/mysql2.md)
- [ ] 404 (not 403) for unauthorized lookups to avoid existence oracle — [express.md §7](../references/express.md)
- [ ] Mass-assignment blocked via `z.object(...).strict()` on writes — [express.md §6](../references/express.md)

## Input / output (A03, A04, A08)
- [ ] All `req.body` / `req.query` / `req.params` validated with Zod at route boundary — [express.md §6](../references/express.md)
- [ ] String fields capped (`.max(...)`) — [express.md §6](../references/express.md)
- [ ] mysql2 uses `?` placeholders for values, `??` + allowlist for identifiers — [mysql2.md §1,§2](../references/mysql2.md)
- [ ] `LIKE` patterns escaped and bound as a single parameter — [mysql2.md §3](../references/mysql2.md)
- [ ] `child_process.exec(userInput)` never used; `execFile` with arg array instead — [express.md §10](../references/express.md)

## Infrastructure / config (A05)
- [ ] `app.disable('x-powered-by')` and `helmet()` enabled — [express.md §1](../references/express.md)
- [ ] `trust proxy` set to integer hop count, never `true` — [express.md §1](../references/express.md)
- [ ] `express.json({ limit: '...' })` and `urlencoded({ limit: '...' })` bounded — [express.md §1](../references/express.md)
- [ ] CSP configured with nonce; no `'unsafe-inline'` / `'unsafe-eval'` — [express.md §3](../references/express.md)
- [ ] CORS allowlist explicit; no `origin: '*'` with `credentials: true` — [express.md §4](../references/express.md)
- [ ] Session cookies: `httpOnly`, `secure` in prod, `sameSite: 'lax'` minimum — [express.md §2](../references/express.md)
- [ ] mysql2 pool: `multipleStatements: false`, TLS in prod, bounded `connectionLimit` — [mysql2.md §4](../references/mysql2.md)
- [ ] DB user has least privilege; migrations under separate user — [mysql2.md §5](../references/mysql2.md)
- [ ] Secrets from secret manager / env, never in repo, never in logs — [mysql2.md §6](../references/mysql2.md)

## Outbound / SSRF (A10)
- [ ] User-supplied URLs go through `parseUserUrl` + `resolvePublic` + IP-pinned fetch — [ssrf-and-egress.md §1–§3](../references/ssrf-and-egress.md)
- [ ] `redirect: 'manual'`; redirects re-validated through the same guard — [ssrf-and-egress.md §3](../references/ssrf-and-egress.md)
- [ ] connect / headers / body / total timeouts set on every outbound call — [ssrf-and-egress.md §3](../references/ssrf-and-egress.md)
- [ ] Egress firewall denies RFC1918 + cloud metadata; IMDSv2 enforced — [ssrf-and-egress.md §4](../references/ssrf-and-egress.md)

## Logging & monitoring (A09)
- [ ] Central error handler maps internal errors to opaque messages in prod — [express.md §8](../references/express.md)
- [ ] `err.sqlMessage`, `err.sql`, request bodies never sent to clients — [mysql2.md §7](../references/mysql2.md)
- [ ] Auth events logged: login success/failure, password reset, MFA enroll/disable, role change
- [ ] Logs do not contain passwords, tokens, session ids, or DB credentials

## Components (A06)
- [ ] `npm audit` clean (or each finding documented and accepted)
- [ ] Renovate / Dependabot enabled
- [ ] Lockfile committed; CI installs from lockfile only
