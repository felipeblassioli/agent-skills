# Authentication patterns reference

Targets: `bcrypt`, `jsonwebtoken`, `otplib`, `node:crypto`. Maps to OWASP A02 (Cryptographic Failures) and A07 (Identification and Authentication Failures).

## 1. Password hashing — bcrypt

```ts
import bcrypt from 'bcrypt';

const COST = 12;                                 // 2026 baseline; bench on prod hardware

export const hashPassword = (plain: string) => bcrypt.hash(plain, COST);
export const verifyPassword = (plain: string, hash: string) => bcrypt.compare(plain, hash);
```

Rules:
- Cost ≥ 12, tuned so a single hash takes ~250–500 ms on production CPU. Re-bench yearly.
- bcrypt truncates input at **72 bytes**. For passphrases, pre-hash with SHA-256 then base64 before bcrypt, or use argon2id.
- Never log the plaintext, the hash, or the resulting JWT.
- Constant-time comparison is built into `bcrypt.compare`; never compare hashes with `===`.

Alternative: `argon2` (`argon2id`, `memoryCost: 19456`, `timeCost: 2`, `parallelism: 1`) is recommended by OWASP for new systems. Use bcrypt only when argon2 is unavailable.

## 2. JWT issuance and verification (A07, A02)

```ts
import jwt from 'jsonwebtoken';

const ACCESS_TTL = '15m';
const REFRESH_TTL = '7d';

export function issue(userId: string, sessionId: string) {
  const access = jwt.sign(
    { sub: userId, sid: sessionId },
    process.env.JWT_SECRET!,
    { algorithm: 'HS256', expiresIn: ACCESS_TTL, issuer: 'api', audience: 'web' },
  );
  const refresh = jwt.sign(
    { sub: userId, sid: sessionId, typ: 'refresh' },
    process.env.JWT_REFRESH_SECRET!,             // distinct secret
    { algorithm: 'HS256', expiresIn: REFRESH_TTL, issuer: 'api', audience: 'web' },
  );
  return { access, refresh };
}

export function verifyAccess(token: string) {
  return jwt.verify(token, process.env.JWT_SECRET!, {
    algorithms: ['HS256'],                       // pin algorithm, not array of options
    issuer: 'api',
    audience: 'web',
  });
}
```

Rules:
- Always pass `algorithms: [...]` to `verify`. Without it, `none` and key-confusion attacks (HS/RS swap) are possible.
- Access tokens short (5–15 min). Refresh tokens longer, **rotated on use** and **revocable** (store `sid` server-side, mark revoked rows).
- Distinct secrets for access vs refresh; distinct keys per environment; ≥ 32 bytes random.
- Validate `iss` and `aud`. Reject tokens missing `exp`.
- Never put PII or roles you cannot afford to be stale into the token. Look up authoritative state on each request for sensitive operations.

## 3. Refresh token rotation (A07)

- On `/refresh`: verify, look up `sid` in DB, mark old refresh as used, issue new pair, store new `sid`.
- If a refresh token marked "used" is presented again → treat as theft: revoke all sessions for that user, force re-login.

## 4. Password reset (A07, A04)

```ts
import crypto from 'node:crypto';

export async function startReset(email: string) {
  const user = await users.findByEmail(email);
  // Always do the same amount of work; do not branch externally on existence
  const raw = crypto.randomBytes(32).toString('base64url');
  const hash = crypto.createHash('sha256').update(raw).digest('hex');
  const expiresAt = new Date(Date.now() + 60 * 60 * 1000);

  if (user) await resets.upsert({ userId: user.id, hash, expiresAt });
  if (user) await mailer.send(email, `${process.env.WEB_URL}/reset?token=${raw}`);
  // Constant response regardless of whether user exists:
  return { ok: true };
}
```

Rules:
- Token: ≥ 32 random bytes, single-use, ≤ 1 hour TTL, stored hashed (DB leak does not enable reset).
- Same response and similar timing for "user exists" and "user does not" — prevents account enumeration.
- Invalidate all existing sessions on successful reset.

## 5. MFA / TOTP (A07)

```ts
import { authenticator } from 'otplib';
import QRCode from 'qrcode';
import crypto from 'node:crypto';

authenticator.options = { window: 1 };           // ±30s drift; do not increase

export async function enrollTotp(userId: string, accountLabel: string) {
  const secret = authenticator.generateSecret();
  // Store encrypted at rest; never plain
  await users.update(userId, { totpSecretEnc: encryptAtRest(secret) });
  const otpauth = authenticator.keyuri(accountLabel, 'MyApp', secret);
  return { qr: await QRCode.toDataURL(otpauth) };
}

export function verifyTotp(token: string, secret: string) {
  // otplib uses constant-time HMAC compare internally
  return authenticator.verify({ token, secret });
}
```

Rules:
- Encrypt the TOTP secret at rest with a key managed outside the DB (KMS / Secret Manager).
- Rate-limit TOTP attempts per user (e.g. 5 / 15 min) — TOTP has only 6 digits.
- Generate one-time recovery codes at enrollment; store hashed; consume on use.
- Re-prompt for MFA on sensitive actions (password change, MFA disable, payout add).

## 6. Session vs JWT — pick one

Use **server-side sessions** (Redis-backed, opaque cookie id) as the default for first-party web apps. They are revocable instantly and survive secret rotation.

Use **JWT** when:
- You have multiple services that need to verify tokens without a shared session store, or
- A native or third-party client needs a bearer token.

Do not mix both for the same surface.

## 7. Common auth anti-patterns to flag

| Pattern | Why it fails | Fix |
|---|---|---|
| `bcrypt.hash(p, 8)` | Too cheap by 2026 | Cost ≥ 12, bench |
| `jwt.verify(t, secret)` no `algorithms` | `alg=none` / key-confusion | Pin `algorithms: ['HS256']` |
| Long-lived JWT with no revocation list | Cannot kick a stolen token | Short TTL + refresh rotation + `sid` store |
| `if (user) return error('exists')` on reset | Account enumeration | Constant response and timing |
| Plain-text TOTP secret in DB | One leak → full MFA bypass | Encrypt at rest |
| `password === user.password` | Plaintext storage + timing leak | bcrypt/argon2 + `compare` |
| Roles baked into long-lived JWT | Stale privileges after revoke | Check authoritative DB row for sensitive ops |
