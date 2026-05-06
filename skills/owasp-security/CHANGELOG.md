# Changelog

All notable changes to the `owasp-security` skill are documented here.
Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versioning: [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-05-06

### Changed
- Refactored `SKILL.md` from a 537-line knowledge dump into a ~80-line dispatcher with strict applicability gate, routing table, and JSON output contract.
- Narrowed scope to Node.js / TypeScript backend (Express, mysql2, bcrypt, jsonwebtoken, otplib). Other ORMs and frameworks are now explicit anti-triggers.

### Added
- `references/express.md` — hardened bootstrap, sessions, CSP, CORS, rate limiting, validation, authorization, error handler, common anti-patterns.
- `references/mysql2.md` — `?` value placeholders, `??` identifier escaping with allowlist, `LIKE`/`IN` patterns, pool config, least-privilege DB user, error handling.
- `references/auth-patterns.md` — bcrypt cost guidance, JWT issuance and verification with pinned algorithms, refresh rotation, password reset, TOTP MFA.
- `references/ssrf-and-egress.md` — URL parsing, IP guard with DNS-rebinding defense, IP-pinned `safeFetch`, manual redirect handling, egress posture.
- `references/owasp-top10-map.md` — A01–A10 classification with links into the library references.
- `assets/pre-deploy-checklist.md` — actionable checklist linked to the corresponding reference sections.
- `metadata.json` (was missing) — version, author, date, abstract.
- `CHANGELOG.md` (was missing).

### Removed
- React `dangerouslySetInnerHTML` / DOMPurify guidance — out of scope for a backend dispatcher.
- ORM-specific snippets (Prisma, Knex, Mongoose) — anti-trigger; refer to dedicated skills when they exist.
- Inline 400+ lines of TypeScript copy-paste examples — moved to library references and trimmed to the minimum useful patterns.

## [0.1.0] - prior

### Added
- Initial unversioned `SKILL.md` with OWASP Top 10 overview and inline TypeScript examples covering authentication, validation, headers, sessions, logging, and SSRF (537 lines, no metadata, no references, not registered).
