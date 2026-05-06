# OWASP Top 10 (2021) → reference map

Use this only to classify a finding. For fixes, jump to the library reference.

| Code | Name | Typical Node.js manifestation | Open |
|---|---|---|---|
| A01 | Broken Access Control | Missing ownership check, IDOR via numeric IDs, mass assignment | [express.md §7](express.md), [mysql2.md §5](mysql2.md) |
| A02 | Cryptographic Failures | Plaintext passwords, weak bcrypt cost, JWT without `algorithms`, plain TOTP secret, missing TLS to DB | [auth-patterns.md](auth-patterns.md), [mysql2.md §4,§6](mysql2.md) |
| A03 | Injection | SQL string concat, identifier injection, `child_process.exec(userInput)`, NoSQL `$gt` payloads | [mysql2.md §1–§3](mysql2.md), [express.md §6,§10](express.md) |
| A04 | Insecure Design | No rate limit on auth, unbounded request body, no recovery codes for MFA | [express.md §5,§6](express.md), [auth-patterns.md §5](auth-patterns.md) |
| A05 | Security Misconfiguration | `x-powered-by`, default helmet off, `trust proxy: true`, `multipleStatements: true`, stack traces in 5xx | [express.md §1,§3,§4,§8](express.md), [mysql2.md §4,§5](mysql2.md) |
| A06 | Vulnerable & Outdated Components | Stale `express`, `mysql2`, `jsonwebtoken`; transitive CVEs | `npm audit`, Dependabot/Renovate; outside skill scope |
| A07 | Identification & Auth Failures | No refresh rotation, account enumeration on reset, weak password rules, no MFA | [auth-patterns.md](auth-patterns.md), [express.md §5](express.md) |
| A08 | Software & Data Integrity | Mass assignment via `req.body`, unsigned webhooks, mutable npm tags in CI | [express.md §6](express.md); supply-chain pinning is outside this skill |
| A09 | Security Logging & Monitoring | Logging passwords/tokens, no audit trail for auth events, leaking `err.sqlMessage` | [express.md §8](express.md), [mysql2.md §7](mysql2.md) |
| A10 | SSRF | Unvalidated outbound `fetch`, hostname-only allowlist, auto-follow redirects | [ssrf-and-egress.md](ssrf-and-egress.md) |

## How to classify

1. Pick the **primary** category — the one a determined attacker would exploit first. Cross-cutting issues (most are) get a single primary plus a note.
2. If two are tied, prefer the one with the larger blast radius (A03 > A05; A01 > A04).
3. Quote the category code (`A01`–`A10`) in every finding, and link the reference and section that contains the fix.
