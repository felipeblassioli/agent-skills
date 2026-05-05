# Discovery Log

## Run Context

- Target repository:
- Target directory:
- Investigator:
- Date:
- Intended outputs:
  - `<target-root>/contract-discovery/openapi.yaml`
  - `<target-root>/contract-discovery/discover.log.md`

## Scope Guard

- Target codebase is React or TypeScript frontend: yes/no
- Real HTTP evidence found: yes/no
- Out-of-scope conditions encountered:

## Evidence Inventory

List the strongest sources first. Favor git remote permalinks (e.g. `https://github.com/org/repo/blob/<sha>/path/to/file.ts#L10-L20`) if possible, fallback to local paths.

- `https://github.com/...` or `path/to/file.ts` — shared client / service / hook / component / validator
- `https://github.com/...` or `path/to/file.ts` — why it matters

## Inferred Operations

Repeat this block per operation.

### Operation: `GET /resource/{id}`

- Claim:
- Evidence: (Favor git remote permalink if possible)
  - `https://github.com/...` or `path/to/file.ts` — transport evidence
  - `https://github.com/...` or `path/to/file.ts` — schema or usage evidence
- Confidence: `high` / `medium` / `low`
- Assumptions:
- Drift risk:
- OpenAPI sections affected:

## Schema Notes

List only schemas that are visible enough to matter.

### Schema: `Resource`

- Observed fields:
- Weakly-evidenced fields:
- Source files:
- Notes:

## Auth And Transport Notes

- Base URL evidence:
- Auth header evidence:
- Tenant or environment-specific behavior:
- Retry / timeout / wrapper notes:

## Known Unknowns

- unknown from frontend evidence:
- partially observed:
- conflicting sources:

## Drift Watchlist

Append-only. Do not rewrite older entries silently.

### Drift Item

- Status: `observed` / `suspected` / `resolved`
- Operation:
- Claim:
- Code evidence: (Favor git remote permalink if possible, e.g. `https://github.com/...`)
- OpenAPI section:
- Why this may drift:
- Follow-up:

## Recommended Follow-Ups

- highest-value file or subsystem to inspect next
- evidence still needed to upgrade low-confidence items
- items that should be checked against backend truth later

