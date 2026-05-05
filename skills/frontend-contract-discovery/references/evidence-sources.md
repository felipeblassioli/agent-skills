# Evidence Sources

Start with the highest-signal frontend evidence and widen only when the contract
is still ambiguous.

## Search Order

1. Shared API clients and transport wrappers
2. Service modules and domain-specific request helpers
3. React Query hooks, SWR hooks, and mutation wrappers
4. Direct `fetch` or `axios` call sites
5. Runtime parsers, validators, and schema adapters near the call path
6. Component call sites that shape request payloads or consume response fields
7. Tests, mocks, fixtures, and docs only as supporting evidence

## Evidence Ranking

| Source | What it proves well | Confidence | Notes |
|---|---|---|---|
| Shared API client | base URL patterns, path builders, common headers, retry/auth wrappers | high | strongest place to normalize transport behavior |
| Service module | path, method, request body, params, response typing | high | often the clearest operation boundary |
| Query or mutation hook | operation purpose, variables, cache keys, response usage | medium-high | useful, but sometimes hides transport details |
| Direct `fetch` or `axios` call | method, URL, headers, body serialization | high | prefer when the call is not buried behind wrappers |
| Runtime validator or parser | response schema, optional fields, coercions | high | stronger than plain TypeScript types |
| Type alias or interface | field names, optionality, rough shape | medium | useful only when tied to the actual call path |
| Component consumption | response field usage, nullable handling, UI assumptions | medium | good for narrowing what the client truly depends on |
| Tests or mocks | examples, edge cases, error handling expectations | low-medium | treat as corroboration, not primary truth |
| README or inline docs | intent, naming, endpoint hints | low | never use alone to define the contract |

## Preferred Starting Points In React Codebases

Search first for:

- `fetch(`
- `axios.`
- `client.get(`, `client.post(`, `client.put(`, `client.delete(`
- `useQuery(`, `useMutation(`, `queryFn:`, `mutationFn:`
- files named like `api.ts`, `client.ts`, `services.ts`, `queries.ts`, `mutations.ts`

When a codebase uses wrapper layers, prefer reading from the outermost operation
boundary inward:

1. domain service or hook
2. shared client or transport helper
3. validator or response adapter
4. UI consumption sites

## Corroboration Rules

Prefer claims backed by at least two of these:

- transport evidence: actual request builder or HTTP call
- schema evidence: runtime validator, parser, or tightly-coupled response type
- usage evidence: component or hook behavior that depends on returned fields

*(For the confidence scoring rubric, refer to the OpenAPI Inference Rules).*

## Escalation And Stop Rules

Escalate the search only when:

- the method is hidden behind multiple wrappers
- path params or query params are assembled in separate layers
- the response shape differs between transport and UI usage
- auth or tenant headers appear conditionally

Stop and report low confidence when:

- there is no real HTTP evidence in the target area
- multiple wrappers disagree and no stronger source resolves the conflict
- the repository is mostly GraphQL, RPC, or generated SDK usage with no visible HTTP contract
- the code only shows names or types but not enough transport behavior to infer an operation safely

## Common Traps

- Reading components first and mistaking UI state for transport truth
- Treating query keys as endpoint paths
- Assuming a generated type proves the live payload shape
- Using tests or mocks as the only source of truth
- Expanding into backend implementation discovery when the skill is frontend-first

