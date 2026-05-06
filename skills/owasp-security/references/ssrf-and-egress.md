# SSRF and outbound egress reference

Targets: any server code that fetches a URL whose host is influenced by user input — webhooks, image proxies, link previews, OAuth discovery, OpenGraph scrapers. Maps to OWASP A10 (SSRF) with cross-cutting A05.

## Threat model

A request like `POST /preview { url: "http://169.254.169.254/latest/meta-data/" }` lets an attacker pivot off your server to:

- Cloud metadata endpoints (AWS `169.254.169.254`, GCP `metadata.google.internal`, Azure `169.254.169.254`).
- Internal services on `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`, `127.0.0.0/8`, `::1`, `fc00::/7`, `fe80::/10`.
- Localhost admin ports.
- Smuggled protocols: `file://`, `gopher://`, `dict://`.

DNS rebinding makes naive hostname allowlists insufficient: the resolver returns a public IP at validation time and a private IP at fetch time.

## 1. URL validation (A10)

```ts
import { URL } from 'node:url';

const ALLOWED_PROTOCOLS = new Set(['http:', 'https:']);
const ALLOWED_HOSTS = new Set(['api.example.com', 'cdn.example.com']);

export function parseUserUrl(input: string): URL {
  let u: URL;
  try { u = new URL(input); } catch { throw new Error('invalid_url'); }
  if (!ALLOWED_PROTOCOLS.has(u.protocol)) throw new Error('protocol_not_allowed');
  if (u.username || u.password) throw new Error('userinfo_not_allowed');
  if (!ALLOWED_HOSTS.has(u.hostname)) throw new Error('host_not_allowed');
  if (u.port && !['', '80', '443'].includes(u.port)) throw new Error('port_not_allowed');
  return u;
}
```

Rules:
- Reject anything that is not `http:` or `https:`. Block `file:`, `ftp:`, `gopher:`, `dict:`, `data:`.
- Reject embedded credentials (`http://attacker@target/`).
- Validate the **port** as well; `http://example.com:22/` should be refused unless port is in your allowlist.

## 2. IP-level guard (A10) — required even with allowlist

DNS allowlisting alone does not prevent rebinding. Resolve to an IP, validate the IP, then connect to that **same IP** with the original `Host` header.

```ts
import dns from 'node:dns/promises';
import net from 'node:net';

const PRIVATE_V4 = [
  /^0\./, /^10\./, /^127\./, /^169\.254\./,
  /^172\.(1[6-9]|2[0-9]|3[01])\./, /^192\.168\./, /^100\.(6[4-9]|[7-9][0-9]|1[01][0-9]|12[0-7])\./, // CGNAT
];
const PRIVATE_V6 = [/^::1$/, /^fc/i, /^fd/i, /^fe[89ab]/i, /^::ffff:/i];

function isPrivate(ip: string) {
  if (net.isIPv4(ip)) return PRIVATE_V4.some((r) => r.test(ip));
  if (net.isIPv6(ip)) return PRIVATE_V6.some((r) => r.test(ip));
  return true; // unknown → reject
}

export async function resolvePublic(host: string): Promise<string> {
  const records = await dns.lookup(host, { all: true, verbatim: true });
  if (records.length === 0) throw new Error('dns_empty');
  for (const r of records) if (isPrivate(r.address)) throw new Error('private_ip');
  return records[0].address;
}
```

Rules:
- Reject if **any** resolved address is private (multi-A-record rebinding defense).
- Block IPv4-mapped IPv6 (`::ffff:10.0.0.1`) — without this, `10.0.0.0/8` is reachable through IPv6.
- Block CGNAT (`100.64.0.0/10`) and link-local in addition to RFC1918.

## 3. Safe fetch (A10)

```ts
import { fetch, Agent } from 'undici';

const SAFE_AGENT = new Agent({
  connect: { timeout: 3_000, rejectUnauthorized: true },
  bodyTimeout: 5_000,
  headersTimeout: 3_000,
});

export async function safeFetch(userInput: string) {
  const url = parseUserUrl(userInput);
  const ip = await resolvePublic(url.hostname);

  const target = new URL(url.toString());
  target.hostname = ip;                                // pin to validated IP

  const res = await fetch(target, {
    redirect: 'manual',                                // re-validate every hop
    headers: { host: url.hostname },                   // preserve SNI/vhost
    dispatcher: SAFE_AGENT,
    signal: AbortSignal.timeout(8_000),
  });

  if (res.status >= 300 && res.status < 400) {
    const next = res.headers.get('location');
    if (!next) throw new Error('bad_redirect');
    return safeFetch(new URL(next, url).toString()); // recurse with full revalidation
  }
  return res;
}
```

Rules:
- `redirect: 'manual'`. Auto-following redirects bypasses your IP guard the moment the target redirects to `http://127.0.0.1/`.
- Pin the connection to the resolved public IP; send the original `Host`. This is the cheapest DNS-rebinding defense.
- Always set timeouts (connect, headers, body, total). SSRF often pivots into slow-loris-style resource exhaustion.
- Cap response size (`Content-Length` check + streaming byte counter); abort if exceeded.

## 4. Egress posture (A05, A10)

Defense in depth at the network layer:

- Run the service in a subnet whose egress NAT/firewall denies RFC1918, link-local, and cloud metadata IPs.
- On AWS, require IMDSv2 and set `HttpPutResponseHopLimit=1` so a compromised container cannot hop to metadata.
- On GCP, set `Metadata-Flavor: Google` enforcement and prefer Workload Identity over metadata-token reads from app code.

Application-level guards remain mandatory — defense in depth, not in alternatives.

## 5. Common SSRF anti-patterns to flag

| Pattern | Why it fails | Fix |
|---|---|---|
| `await fetch(req.body.url)` | Direct SSRF | `safeFetch` with parse + IP guard + pinning |
| Hostname allowlist only | DNS rebinding bypass | Resolve + validate IPs every fetch |
| `redirect: 'follow'` | Redirect to private IP bypasses guard | `'manual'` + recurse with revalidation |
| Validating URL but fetching the original string | TOCTOU between parse and fetch | Build the request from the parsed `URL` object |
| Trusting `Content-Length` only | Servers can lie | Stream + count bytes, abort on cap |
| No timeouts | Slow-target resource exhaustion | connect/headers/body/total timeouts |
