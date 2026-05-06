---
name: ts-prod-code
description: >-
  Use when authoring or reviewing production TypeScript modules, choosing layer and
  suffix boundaries, modeling domain objects and ports, deciding error ownership,
  or wiring validation and observability at system boundaries.
---

# TypeScript Production Code

Authoring doctrine for type-safe, robust, observable TypeScript in a layered DDD codebase.

## Applicability gate

Apply this skill when ANY of the following is true:

- modeling a domain concept: entity, value object, domain policy, domain event
- writing or reviewing a controller, use-case, repository, schema, or gateway
- deciding the **suffix** and folder for a new TypeScript file
- designing the error model (throw vs `Result`, error class, HTTP mapping, layer ownership)
- adding structured logging or OTel trace/span correlation at a boundary
- enforcing strict typing rules (no `any`, no `enum`, brands, `satisfies`, `readonly`, single-nullish)
- validating inputs at a boundary with Zod

Do NOT apply this skill to:

| Situation | Route to |
|---|---|
| writing or fixing tests, choosing test tiers, or setting up hermetic test infrastructure | sibling skill `ts-hermetic-testing` |
| REST API design (paths, verbs, envelopes) | out of scope; do not invent guidance |
| PR descriptions, commit messages, branch hygiene | out of scope |
| frontend-specific concerns (React rendering, server components) | out of scope |
| infra provisioning, CI/CD configuration | out of scope |

## Routing table

| Need | Read |
|---|---|
| Strict typing rules at a glance (no `any`, brands, `satisfies`, `Result`, `readonly`, no floating promises) | [references/type-safety-checklist.md](references/type-safety-checklist.md) |
| Where does this file go? Which suffix? What can import what? | [references/module-layering.md](references/module-layering.md) |
| What's the right suffix for a production file? | [references/suffix-naming-production.md](references/suffix-naming-production.md) |
| Modeling an immutable attribute object (e.g. CardToken, Email, Money) | [references/value-objects.md](references/value-objects.md) |
| Modeling an entity with identity and invariants | [references/entities.md](references/entities.md) |
| Stateless business rule that crosses entities | [references/domain-policies.md](references/domain-policies.md) |
| Repository interface vs impl; gateway as anti-corruption | [references/repositories-and-gateways.md](references/repositories-and-gateways.md) |
| Throw or return `Result`? Error classes, cause chain, HTTP mapping, layer ownership | [references/error-model.md](references/error-model.md) |
| Structured logging at boundaries; OTel correlation; PII redaction | [references/observability.md](references/observability.md) |

## Hard rules (non-negotiable, applied without reading references)

1. **No `any`.** Use `unknown` and narrow. No double assertions. Prefer `satisfies` over `as`.
2. **No `enum` / `const enum`.** Use literal unions + `as const` maps.
3. **Internal absence is `undefined`.** Treat `null` as foreign; normalize at edges.
4. **`readonly` by default** for params and collections; accept `ReadonlyArray<T>`.
5. **Validate inputs at every boundary** (HTTP, queue, file, env, DB read) with a schema; derive types via `z.infer`.
6. **Never throw strings.** Use `Error` subclasses with stable `code` and optional `cause`.
7. **No floating promises.** `await`, `return`, chain, or explicit `void` with internal try/catch.
8. **One responsibility per file** encoded by suffix. Splitting roles (entity + repository in one file) is a fail.
9. **One throw → one log** at the boundary. Never log secrets/PII.
10. **Domain code never imports infrastructure.** Repositories/gateways are interfaces in the domain; impls live in infra.

## Procedure

When the user asks to write or review production code:

1. **Identify the layer** (presentation / application / domain / infrastructure) from the task verbs.
2. **Pick the suffix** before naming the file. If the responsibility doesn't fit one suffix, split.
3. **Validate at the boundary** (controller/gateway): Zod schema → infer types → narrow.
4. **Decide error category** (DomainError / ApplicationError / RecoverableInfrastructureError / FatalSystemError) and ownership: expected → `Result`; defect → throw.
5. **Write the smallest API surface**: explicit signatures, no implicit `any`, prefer purity, accept `ReadonlyArray<T>`.
6. **Translate at the edge**: infra error → domain error; domain → transport; never rethrow into the same layer.
7. **Log once** at the boundary with `event`, `code`, `message`, `traceId`/`spanId`, key context.
8. **Cross-check the dependency rule**: if `domain/*.entity.ts` imports `prisma` or `axios`, stop and refactor.

## Confirmation policy

- If the user asks to use `enum`, `any`, or to merge two responsibilities into one file, push back and propose the conformant alternative.
- If a file's responsibility changes during a refactor, rename it to the correct suffix in the same change.
- If a domain object is asked to call I/O (DB, HTTP, clock, UUID), reject and route the side effect to the use-case or repository.

## Sibling skill

For test authoring, test-tier placement, doubles, and hermeticity rules: **ts-hermetic-testing**.
