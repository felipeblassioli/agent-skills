# Module layering and the dependency rule

Bounded contexts are the **top-level modules**. Inside each context, four layers are stacked with a strict dependency direction.

## Top-level layout

```
src/
├── payments/                     ← bounded context
│   ├── api/         (.controller.ts)
│   ├── app/         (.usecase.ts)
│   ├── domain/      (.entity.ts, .vo.ts, .policy.ts, .event.ts, .repository.ts interface)
│   └── infra/       (.repository.<tech>.ts impl, .schema.ts, .gateway.ts)
├── fleet/                        ← another bounded context (same internal layering)
└── shared/                       ← cross-cutting only (logger, event-bus, design-system)
    ├── logger/
    └── event-bus/
```

**Rule**: a slice (bounded context) is full-stack — controllers at top, repositories/gateways at bottom — and never imports another slice's internals.

## Dependency direction

```
Presentation (.controller)
    ↓
Application (.usecase)
    ↓
Domain (.entity / .vo / .policy / .event / .repository interface)
    ↑
Infrastructure (.repository.<tech> impl / .schema / .gateway)
    ↓
Data access (SQL · NoSQL · HTTP client · queue)
```

Source-code dependencies always point **toward the domain core**. Infrastructure depends on the domain (it implements domain ports), but domain never imports infrastructure.

## Coupling rules

| From → To | Rule |
|---|---|
| Presentation → Application | Translate transport (HTTP/CLI/GraphQL) into a command DTO; never touch entities directly. |
| Application → Domain | Coordinate repositories and policies; transaction boundary starts/commits here; **never** call ORM/SDK directly. |
| Domain → Infrastructure | Allowed only via **interfaces** (`*.repository.ts`, `*.gateway.ts` interface). Domain owns the shape; infra implements. |
| Cross-context | Communicate only via **published domain events** or well-defined service APIs / `*.gateway.ts` anti-corruption adapters. **Never** import another context's entity. |

## Quick check

| Decision | Verdict |
|---|---|
| `credit-card.repository.pg.ts` imports `kysely` | ✅ infra only |
| `credit-card.entity.ts` imports `prisma` | ❌ breaks dependency rule |
| `add-card.usecase.ts` validates CPF with Zod schema | ❌ put CPF invariants in `cpf.vo.ts` |
| `adyen.gateway.ts` returns raw JSON | ❌ map to a `CardToken` value object before leaving infra |
| `fleet/usecase.ts` imports `payments/domain/credit-card.entity.ts` | ❌ cross-context coupling; use a published event |

## Public API of a slice (barrels)

Each context exposes an explicit public API via `index.ts`:

```ts
// src/payments/index.ts
export type { AddCardCommand, CreditCardAddedEvent } from "./public-types";
export { addCardUseCase } from "./app/add-card.usecase";
```

- Re-export commands, queries, domain events, and DTOs.
- **Never** re-export internal entities, repositories, gateways, or schemas.
- Prefer `export type { ... }` for type-only barrels.

## Test strategy by layer

| Layer | Default test tier (see ts-hermetic-testing) |
|---|---|
| Domain (entity, vo, policy) | Unit, no mocks; call directly with constructed data |
| Application (usecase) | Unit with in-memory repos/fakes for ports |
| Domain pipeline with deterministic output | Contract/golden tests when the observable artifact spans multiple pure stages |
| Infrastructure (repository, gateway) | Integration: real in-memory DB or in-process HTTP boundary with fake externals only |
| Presentation (controller) | Integration: route + validation + serialization in-process; promote to E2E for browser-visible journeys |
| End-to-end slice | E2E: browser + real stack, with only intentional external seams faked |

## Smells that break this layering

- "Service" classes that touch HTTP, the DB, and emit events all in one place. Split: controller + usecase + repository.
- A `usecase` that imports a Knex/Prisma client directly. Inject a repository interface instead.
- A `controller` that constructs entities from request bodies. Hand a command DTO to the usecase; let the usecase build the entity.
- Domain code that imports `@aws-sdk/...` or `axios`. Wrap in a `*.gateway.ts` and depend on its interface.
- A "shared" folder that grows business types. Move to a context.

## Further reading

- Evans, *Domain-Driven Design*, ch. 4 (Layered Architecture).
- Cockburn, *Hexagonal Architecture* (2005, 2024 update).
- Martin, *Clean Architecture* (2017), ch. 22 "The Dependency Rule", ch. 23 "Boundaries".
- Fowler, [Presentation Domain Data Layering](https://martinfowler.com/bliki/PresentationDomainDataLayering.html).
