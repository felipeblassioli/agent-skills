---
name: frontend-contract-discovery
description: >-
  Use when the user wants to infer HTTP contracts and endpoint documentation from a
  React or TypeScript frontend instead of relying on a backend-owned source of truth.
---

# Frontend Contract Discovery

Infer the HTTP contract a React frontend actually uses, then turn that evidence
into a cautious OpenAPI draft, per-endpoint docs, and a durable discovery log.

This skill is strict by default:

- stay frontend-first in v1
- prefer observed evidence over guessed completeness
- stop and report low confidence instead of inventing missing contract details
- keep drift findings append-only rather than silently rewriting history

## Applicability Gate

Use this skill when ANY of the following are true:

- the user wants to infer an API contract from a React or TypeScript frontend
- the user wants an OpenAPI draft reconstructed from client call sites
- the user wants a `discover.log.md` with evidence, confidence, and assumptions
- the user wants a lightweight drift check between frontend usage and a spec

Do NOT use this skill when:

- the backend source of truth already exists and only needs review
- the task is to design a brand-new API
- the task is to validate live endpoints against a running service
- the repository is primarily GraphQL, websocket, RPC, or non-HTTP
- the task is generic repository mapping rather than contract reconstruction
- the task is to reconcile frontend evidence against backend implementation truth

## Inputs Required

Minimum useful input:

- a repository or directory to inspect
- confirmation that the target is a React or TypeScript frontend, or permission
  to verify that first

Optional but helpful:

- an existing spec to compare against
- preferred output paths for `openapi.yaml`, endpoint docs, and
  `discover.log.md`
- any known API client directories, hooks, or service modules

If the user gives no output paths, suggest:

- `<target-root>/contract-discovery/openapi.yaml`
- `<target-root>/contract-discovery/endpoints/`
- `<target-root>/contract-discovery/discover.log.md`

## Routing Table

| Need | Route to |
|---|---|
| Decide where to look first in a React codebase | Use the `Read` tool on `references/evidence-sources.md` |
| Map code observations into OpenAPI safely | Use the `Read` tool on `references/openapi-inference-rules.md` |
| Write the evidence log consistently | Use the `Read` tool on `assets/discover-log-template.md` |
| Run a lightweight manual drift pass | Use the `Read` tool on `assets/drift-checklist.md` |
| Write one evidence-backed endpoint document per inferred operation | Use the `Read` tool on `assets/endpoint-doc-template.md` |

## Procedure

1. **Verify the target is supported.**
   - Confirm the codebase is frontend-first and has real HTTP evidence such as
     `fetch`, `axios`, query hooks, service wrappers, or typed API clients.
   - If the repo lacks clear HTTP call sites, stop and report that confidence is
     too low for this workflow.
2. **Collect the strongest evidence first.**
   - Start from shared API clients, service modules, and direct HTTP call sites.
   - Use component-level call sites only to fill gaps in request or response
     usage.
   - Use the `Read` tool to read `references/evidence-sources.md` before widening the search.
   - For large codebases, use the `Task` tool (subagent `explore` or `generalPurpose`) to parallelize searching for API call sites.
3. **Normalize operations.**
   - Group evidence by `path + method`.
   - Extract path params, query params, headers, request bodies, auth hints, and
     response shapes that are actually visible in code.
4. **Infer cautiously.**
   - Map observations into OpenAPI using `references/openapi-inference-rules.md`
     (fetch using the `Read` tool).
   - Mark uncertain fields as assumptions. Do not invent servers, auth schemes,
     enum values, or error models that are not evidenced.
   - Leave scalar types and formats generic or omitted unless runtime evidence,
     validation, or parsing proves them.
5. **Draft the OpenAPI spec.**
   - Produce the smallest useful spec that reflects observed behavior.
   - Prefer incomplete-but-traceable output over polished speculation.
6. **Draft endpoint documents.**
   - Use the `Read` tool to read `assets/endpoint-doc-template.md`.
   - Generate one endpoint markdown document per normalized `method + path`.
   - Keep every section evidence-bound. If a field is not directly observed, mark
     it as `unknown` or as an explicit assumption instead of filling it from
     convention.
   - Prefer compact `unknown` notes over large placeholder tables when sparse
     evidence would otherwise create low-signal noise.
   - Extract a companion `{VERB}_{path_segments}.response.json` only when the
     success payload is large enough to help review and the structure is actually
     evidenced in code.
7. **Write `discover.log.md`.**
   - Use the `Read` tool to read `assets/discover-log-template.md`.
   - Every operation or schema claim must include evidence, confidence, and
     assumptions.
8. **Run the drift protocol when a spec exists.**
   - Use the `Read` tool to read `assets/drift-checklist.md`.
   - Record drift items as `observed`, `suspected`, or `resolved`.
9. **Return an honest summary.**
   - Report what was inferred confidently, what remains ambiguous, and which
     follow-ups would most reduce uncertainty.

## Output Contract

Default outputs:

- `openapi.yaml` or `openapi.json`
- `discover.log.md`
- Individual endpoint markdown docs, one per inferred operation. Naming scheme: `{VERB}_{path_segments_joined_by_underscores}.md` (e.g. `POST_resource_{id}.md`)
- Optional response payload snapshots when useful and evidenced: `{VERB}_{path_segments_joined_by_underscores}.response.json` (e.g. `POST_resource_{id}.response.json`)

Every inferred operation should carry:

- **Claim:** the contract statement being made
- **Evidence:** exact files, symbols, or snippets that support it. Favor git remote permalinks (e.g. `https://github.com/org/repo/blob/<sha>/path/to/file.ts#L10-L20`) if possible, fallback to local paths.
- **Confidence:** `high`, `medium`, or `low`
- **Assumptions:** what was derived rather than directly observed
- **Drift risk:** what is most likely to change or already diverge

## Confirmation Policy

- Confirm output paths unless the user already specified them.
- Confirm a different artifact set only if the user explicitly wants to skip the
  default per-endpoint docs.
- If multiple competing client layers disagree, explain the conflict before
  choosing one as primary evidence.
- If confidence stays low after reading the high-signal sources, stop instead of
  manufacturing a full spec.

## Common Mistakes

- **Broadening the job too early.** This skill is not a generic frontend-plus-
  backend contract mining workflow. Keep v1 focused on React frontend evidence.
- **Returning evidence only in chat.** The durable artifacts are part of the
  job. Write `discover.log.md` instead of leaving the audit trail implicit.
- **Treating endpoint docs as optional.** Per-endpoint markdown is part of the
  default deliverable, not an afterthought once the spec is done.
- **Treating type names as contract truth.** A TypeScript type helps, but it is
  weaker than an actual request builder, validator, or runtime parser tied to a
  call site.
- **Promoting guesses into facts.** If an auth scheme, error shape, or response
  field is not evidenced, mark it as an assumption or unknown.
- **Inferring scalar types from names alone.** A key like `ttlSeconds` or
  `orderId` does not prove `number` or `string` unless runtime evidence backs
  that claim.
- **Silently overwriting drift.** Drift should be logged with evidence, not
  hidden by rewriting the spec without explanation.

