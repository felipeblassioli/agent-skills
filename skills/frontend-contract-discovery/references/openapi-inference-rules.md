# OpenAPI Inference Rules

Turn frontend evidence into the smallest honest OpenAPI draft. The goal is a
traceable contract, not a perfect backend mirror.

## Drafting Principles

- prefer observed behavior over completeness
- infer only what the frontend actually uses
- mark derived details as assumptions
- keep unknowns visible instead of filling them with plausible defaults

## Operation Mapping

| Code evidence | OpenAPI target | Guidance |
|---|---|---|
| string URL or path helper | `paths` key | convert obvious interpolations like `` `/users/${id}` `` into `/users/{id}` |
| `get`, `post`, `put`, `patch`, `delete` | HTTP method | if hidden by a wrapper, only infer when the wrapper is clear |
| `params`, `URLSearchParams`, query builder object | `parameters` with `in: query` | include only keys actually visible in code |
| path interpolation or route helper args | `parameters` with `in: path` | mark as required when interpolation is mandatory |
| `headers` object | operation headers or auth note | repeated `Authorization` patterns can justify a security note, not always a full scheme |
| `body`, `data`, `JSON.stringify(...)` | `requestBody` | derive content type from explicit headers or serialization style |
| runtime parser or validator | response schema or request schema | strongest schema source when tied to the same operation |
| response destructuring or property access | response schema refinement | use to narrow which fields the client truly depends on |
| `catch` branches or typed error handling | error response notes | avoid fabricating full error schemas unless the shape is explicit |

## Parameter Rules

- Path params come from interpolation or explicit route-builder arguments.
- Query params come from query builders, `params` objects, or `URLSearchParams`.
- Header parameters should be captured only when they are operation-specific and
  not better represented as an auth note.
- Do not invent pagination params just because a response looks list-shaped.

## Request Body Rules

- Use `application/json` only when JSON serialization or JSON headers are clear.
- If the client sends `FormData`, represent that honestly rather than coercing
  it into JSON.
- If only a partial payload shape is visible, include the observed fields and
  note the missing parts in `discover.log.md`.

## Response Rules

- Prefer runtime validators over plain TypeScript types.
- If only UI usage is visible, model the smallest response shape supported by
  that usage and mark it as partial.
- Arrays, pagination envelopes, and nested objects should be inferred only when
  the code shows them clearly.
- If multiple consumers use different subsets of the same response, model the
  broader visible shape and record which parts are weakly evidenced.

## Security And Servers

- Add a security note only when auth behavior is visible in shared headers,
  token helpers, or client wrappers.
- Do not invent a full `securitySchemes` block from one `Authorization` header
  unless the pattern is stable and repeated.
- Add `servers` only when base URLs or environment-derived origins are explicit.

## Confidence Rubric

Use these labels in both the spec notes and `discover.log.md`:

- **high**: path and method are explicit, plus request or response shape is
  backed by transport evidence and schema or usage evidence
- **medium**: the operation is clear, but one important part such as auth,
  optional fields, or full response shape is still inferred
- **low**: the operation name or purpose is plausible, but transport details are
  hidden, conflicting, or only weakly implied

## Unknowns Policy

Prefer these responses when evidence is thin:

- `unknown from frontend evidence`
- `assumed from usage pattern`
- `partially observed`
- `auth behavior visible but scheme not proven`

Avoid these failure modes:

- inventing enums, examples, or full schemas from naming alone
- copying backend-style completeness into a frontend-derived draft
- turning guessed fields into required properties without evidence
- treating a mock payload as proof of the live response

## Minimal OpenAPI Skeleton

Use a minimal document shape:

```yaml
openapi: 3.1.0
info:
  title: Inferred Frontend Contract
  version: 0.1.0
paths: {}
```

Add components only when multiple operations clearly share the same schema and
that extraction makes the draft easier to audit.

