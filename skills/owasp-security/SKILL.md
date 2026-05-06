---
name: owasp-security
description: Route Node.js/TypeScript backend security questions to the matching OWASP Top 10 category and the correct library reference (express, mysql2). Use when securing Express endpoints, parameterizing mysql2 queries, hardening sessions/headers/CORS, or classifying a finding as A01–A10. Do NOT use for React/frontend XSS, cloud or Kubernetes hardening, cryptography theory, or non-Node stacks.
---

# OWASP Security (Node.js)

Dispatcher skill. Maps a backend security question to one OWASP category and one library-specific reference. Heavy details live one hop away.

## Applicability gate

Apply when ALL are true:

- Stack is Node.js / TypeScript on the server.
- Question is about preventing, classifying, or fixing a vulnerability.
- The relevant library is one of: `express`, `mysql2`, `bcrypt`, `jsonwebtoken`, `otplib`, or generic `node:crypto` / `URL` / `fetch`.

Do NOT apply when:

- Frontend XSS, React `dangerouslySetInnerHTML`, DOM sanitization → defer.
- ORM specifics (Prisma, Knex, Sequelize, TypeORM, Drizzle) → not yet covered, refuse and ask.
- Cloud/IAM/K8s/network posture → out of scope.
- Cryptography algorithm choice or key-management design → out of scope.
- "Make this secure" with no framework signal → ask one targeted question first; do not guess.

## Routing table

| Signal in the question / snippet | Open exactly one |
|---|---|
| `app.use`, `req`, `res`, middleware, `helmet`, `cors`, session cookie, CSP, rate limit, error handler, `trust proxy`, body limits | [references/express.md](references/express.md) |
| `mysql2`, `pool.query`, `connection.execute`, `?` placeholders, identifier escape, `LIKE`, `IN (...)`, `multipleStatements`, prepared statements | [references/mysql2.md](references/mysql2.md) |
| `bcrypt`, password hashing, `jsonwebtoken`, JWT rotation, refresh tokens, password reset, MFA, TOTP, `otplib` | [references/auth-patterns.md](references/auth-patterns.md) |
| Outbound `fetch`, server-side URL fetch from user input, webhook callbacks, image proxies, metadata endpoint | [references/ssrf-and-egress.md](references/ssrf-and-egress.md) |
| Need to classify a finding as A01..A10 | [references/owasp-top10-map.md](references/owasp-top10-map.md) |
| Pre-deploy / pre-merge security review | [assets/pre-deploy-checklist.md](assets/pre-deploy-checklist.md) |

If two signals match, prefer the **library** reference (`express.md` / `mysql2.md`) over the OWASP map. If none match, refuse per the applicability gate.

## Procedure (strict)

1. Identify the framework + library from the snippet or question. If ambiguous, ask exactly one clarifying question and stop.
2. Open exactly one reference file from the routing table. Do not pre-load the rest.
3. Apply the smallest fix from that reference. Quote the OWASP category for traceability.
4. Emit the finding using the output contract below. No conversational prose.

## Output contract

Return findings as a JSON array. One element per issue. No prefix, no suffix, no commentary.

```json
[
  {
    "owasp": "A03",
    "title": "SQL injection via string concatenation",
    "file": "src/users/repo.ts",
    "lines": "42-44",
    "library": "mysql2",
    "fix": "Replace template literal with `?` placeholder + values array.",
    "reference": "references/mysql2.md#parameterization"
  }
]
```

When proposing a code change, also include a unified diff in a fenced ```diff block immediately after the JSON. Never inline rewrites in prose.

## Anti-patterns this skill refuses

- Generic "secure my app" with no language or library context.
- React/JSX XSS, DOMPurify, browser CSP enforcement.
- Choosing between AES-GCM vs ChaCha20-Poly1305 (cryptography theory).
- Postgres-specific SQL, Prisma `$queryRaw`, Knex, Sequelize, Drizzle.
- Infrastructure posture (TLS termination, WAF rules, K8s NetworkPolicy).

For these, state the skill does not cover the topic and suggest the appropriate skill or that one be created.

## Scope coverage matrix

| Library | Covered |
|---|---|
| express (4.x / 5.x) | yes |
| mysql2 / mysql2/promise | yes |
| bcrypt, jsonwebtoken, otplib | yes (auth-patterns) |
| node:crypto, node:url, global fetch | yes (limited) |
| Prisma, Knex, Sequelize, TypeORM, Drizzle | no — refuse |
| Fastify, Koa, Hapi, NestJS | no — refuse |
| pg (node-postgres) | no — refuse |

## Resources (external, on-demand only)

- OWASP Top 10 (2021): https://owasp.org/Top10/
- OWASP Cheat Sheet Series: https://cheatsheetseries.owasp.org/
- Node.js security best practices: https://nodejs.org/en/learn/getting-started/security-best-practices
