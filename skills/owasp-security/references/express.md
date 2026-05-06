# Express security reference

Targets: Express 4.x and 5.x on Node.js ≥ 18. Patterns assume TypeScript but apply to JS.

## 1. Hardened bootstrap (A05)

```ts
import express from 'express';
import helmet from 'helmet';
import cors from 'cors';
import cookieParser from 'cookie-parser';

const app = express();

app.disable('x-powered-by');
app.set('trust proxy', 1); // exactly the number of proxies in front; never `true` blindly

app.use(helmet());
app.use(express.json({ limit: '100kb' }));         // bound body size; defaults are too generous
app.use(express.urlencoded({ extended: false, limit: '100kb' }));
app.use(cookieParser(process.env.COOKIE_SECRET));
```

Rules:
- Never set `trust proxy: true`. It accepts any `X-Forwarded-For`, breaking rate limiting and IP allowlists. Set the integer hop count.
- Always cap `express.json` / `urlencoded`. Default 100kb is fine for JSON APIs.
- `helmet()` defaults are safe; override CSP explicitly (see §3).

## 2. Sessions and cookies (A02, A07)

```ts
import session from 'express-session';

app.use(session({
  name: 'sid',                                     // not the default `connect.sid`
  secret: process.env.SESSION_SECRET!,             // ≥ 32 bytes random
  resave: false,
  saveUninitialized: false,
  cookie: {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'lax',                               // 'strict' breaks OAuth callbacks
    maxAge: 24 * 60 * 60 * 1000,
    path: '/',
  },
}));
```

Rules:
- `httpOnly: true` always. JS-readable session cookies are XSS-amplifiers.
- `secure: true` in production. Behind a TLS-terminating proxy this requires `trust proxy` set correctly.
- `sameSite`: `'lax'` is the default safe choice. Use `'strict'` only if you accept that cross-site navigations lose the session.
- Rotate the session id on privilege change (`req.session.regenerate(cb)` after login).

## 3. Content Security Policy (A05, A03)

```ts
app.use(helmet.contentSecurityPolicy({
  useDefaults: true,
  directives: {
    defaultSrc: ["'self'"],
    scriptSrc: ["'self'", "'strict-dynamic'", (req, res) => `'nonce-${(res as any).locals.cspNonce}'`],
    styleSrc: ["'self'"],
    imgSrc: ["'self'", 'data:', 'https:'],
    connectSrc: ["'self'"],
    frameAncestors: ["'none'"],
    objectSrc: ["'none'"],
    baseUri: ["'self'"],
    formAction: ["'self'"],
    upgradeInsecureRequests: [],
  },
}));
```

Rules:
- Generate a per-request nonce and inject it into `<script nonce>`. Avoid `'unsafe-inline'`.
- Drop `'unsafe-eval'` everywhere; refactor instead.
- `frameAncestors: ['none']` replaces the legacy `X-Frame-Options: DENY`; helmet sends both.

## 4. CORS (A05, A01)

```ts
const allowed = new Set(['https://app.example.com']);

app.use(cors({
  origin: (origin, cb) => {
    if (!origin) return cb(null, false);          // block tools without origin in prod
    cb(null, allowed.has(origin));
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
  maxAge: 600,
}));
```

Rules:
- Never `origin: '*'` together with `credentials: true` — browsers reject it and it signals misconfig.
- Reflect the origin only after allowlist check; do not echo `req.headers.origin` blindly.
- Preflight cache (`maxAge`) keeps things fast without weakening policy.

## 5. Rate limiting and slow-down (A04, A07)

```ts
import rateLimit from 'express-rate-limit';

const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  limit: 300,
  standardHeaders: 'draft-7',
  legacyHeaders: false,
});

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  limit: 10,
  skipSuccessfulRequests: true,                    // count only failures
  keyGenerator: (req) => `${req.ip}:${req.body?.email ?? ''}`,
});

app.use('/api/', apiLimiter);
app.use('/api/auth/', authLimiter);
```

Rules:
- Auth endpoints: limit per (IP, account) pair; otherwise credential stuffing rotates IPs to bypass per-IP limits.
- In multi-instance deployments use a shared store (`rate-limit-redis`); the in-memory default is per-process.
- `trust proxy` must be correct or `req.ip` is the proxy's IP.

## 6. Input validation at the edge (A03, A04, A08)

```ts
import { z } from 'zod';

const Body = z.object({
  email: z.string().email().max(254),
  age: z.number().int().min(13).max(120),
});

app.post('/users', (req, res, next) => {
  const parsed = Body.safeParse(req.body);
  if (!parsed.success) return res.status(400).json({ errors: parsed.error.issues });
  // parsed.data is now typed and bounded
  next();
});
```

Rules:
- Validate at the route boundary. Do not pass `req.body` directly to repos or queries.
- Always cap string lengths; unbounded strings are a DoS vector through downstream regex/JSON.
- Reject unknown keys (`z.object(...).strict()`) on write endpoints to block mass assignment (A08/A01).

## 7. Authorization checks (A01)

```ts
function authenticate(req, res, next) {
  if (!req.session?.userId) return res.status(401).json({ error: 'unauthorized' });
  next();
}

function requireRole(...roles: string[]) {
  return (req, res, next) =>
    roles.includes(req.session?.role) ? next() : res.status(403).json({ error: 'forbidden' });
}

app.get('/api/invoices/:id', authenticate, async (req, res) => {
  const invoice = await repo.findOwned(req.params.id, req.session.userId);
  if (!invoice) return res.status(404).end();      // 404, never 403, to avoid existence oracle
  res.json(invoice);
});
```

Rules:
- Ownership is enforced **in the query** (`WHERE id = ? AND owner_id = ?`), not in a post-fetch `if`.
- Return 404 for both missing and unauthorized — do not leak existence.
- Default-deny: every router needs a base `authenticate` unless explicitly marked public.

## 8. Error handler (A05, A09)

```ts
app.use((err, req, res, _next) => {
  req.log?.error({ err, path: req.path, userId: req.session?.userId }, 'unhandled');
  const safe = process.env.NODE_ENV === 'production' ? 'internal_error' : err.message;
  res.status(err.status ?? 500).json({ error: safe });
});
```

Rules:
- The error handler is the **last** `app.use`. Without it, Express 4 leaks stacks; Express 5 returns a default page.
- Never echo `err.message` to clients in production.
- Log structured fields (`req.id`, `userId`, `path`); never log request bodies that may contain credentials.

## 9. File uploads (A03, A04)

- Use `multer` with `limits.fileSize` and `limits.files`. Reject in `fileFilter` by sniffed magic bytes, not extension.
- Store outside the web root; serve via signed URLs.
- Never `path.join(uploadDir, req.body.filename)` — strip to a UUID.

## 10. Common Express anti-patterns to flag

| Pattern | Why it fails | Fix |
|---|---|---|
| `app.set('trust proxy', true)` | Spoofable `X-Forwarded-For` | Integer hop count |
| `app.use(cors())` with no options | Reflects any origin, allows credentials in some setups | Allowlist + explicit `credentials` |
| `res.send(err)` | Leaks stacks/PII | Central error handler |
| `eval`, `new Function`, `child_process.exec(userInput)` | RCE | `execFile` with arg array; never `exec` |
| `app.use(express.json())` with no `limit` | Body-flood DoS | `{ limit: '100kb' }` |
| Inline `<script>` without nonce | CSP cannot be tightened | Nonce-based CSP |
| `res.cookie('x', v)` without options | Default is non-`httpOnly`, non-`secure` | Set both, plus `sameSite` |
