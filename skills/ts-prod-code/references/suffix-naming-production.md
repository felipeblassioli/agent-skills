# Suffix naming — production files

One **primary responsibility per file**, encoded as a suffix. Suffixes map to layers and DDD building blocks. If a file's purpose changes, **rename** to the correct suffix in the same change.

## Production suffixes

### Presentation (inbound adapters)

| Suffix | Role | Example |
|---|---|---|
| `.controller.ts` | HTTP / message handler | `add-card.controller.ts` |

### Application (orchestration, no business rules)

| Suffix | Role | Example |
|---|---|---|
| `.usecase.ts` | One application use-case (thin orchestrator) | `add-card.usecase.ts` |
| `.service.ts` | Cross-cutting application service (no business rules) | `billing-sync.service.ts` |

### Domain (model + rules)

| Suffix | Role | Example |
|---|---|---|
| `.entity.ts` | Entity / aggregate root (identity + invariants) | `credit-card.entity.ts` |
| `.vo.ts` | Value object (immutable, by-value) | `card-token.vo.ts` |
| `.policy.ts` | Domain policy / domain service (stateless rules across entities) | `fraud-analysis.policy.ts` |
| `.event.ts` | Domain event (immutable fact) | `credit-card-added.event.ts` |

### Infrastructure (persistence + integrations)

| Suffix | Role | Example |
|---|---|---|
| `.repository.ts` | Repository **interface** (in `domain/`) **or** default impl | `credit-card.repository.ts` |
| `.repository.<tech>.ts` | Technology-specific repository impl (in `infra/`) | `credit-card.repository.pg.ts` |
| `.schema.ts` | Zod / codec / mapping schema (HTTP body, DB row, external payload) | `credit-card.schema.ts` |
| `.gateway.ts` | External API/SDK adapter (anti-corruption) | `adyen.gateway.ts` |

## Choosing the right suffix

Decision tree:

1. **Does it carry identity?** → `.entity.ts`
2. **Is it an immutable attribute compared by value?** → `.vo.ts`
3. **Stateless business rule across entities?** → `.policy.ts`
4. **Past-tense fact about something that happened?** → `.event.ts`
5. **Translates HTTP/queue ⇄ command DTO?** → `.controller.ts`
6. **Orchestrates one user intention, no business rules?** → `.usecase.ts`
7. **Cross-cutting application service (no business rules, used by many usecases)?** → `.service.ts`
8. **Persistence interface / impl?** → `.repository.ts` (interface in domain) and `.repository.<tech>.ts` (impl in infra)
9. **Validation/codec for an external payload?** → `.schema.ts`
10. **Wrapper for an external API/SDK that maps DTO ⇄ domain?** → `.gateway.ts`

## Hard rules

- **Never** mix two responsibilities in one file. No entity + repository, no controller + usecase, no schema + entity. Split.
- **Never** invent generic names (`utils.ts`, `helpers.ts`, `manager.ts`, `processor.ts`) inside feature code. If unclear:
  - Domain rule → `.policy.ts`
  - Orchestration → `.usecase.ts`
  - Adapter to external system → `.gateway.ts`
- **Never** use `.model.ts` (ambiguous). Pick `.entity.ts` or `.vo.ts`.
- **Never** put HTTP/SDK calls in a `.entity.ts`, `.vo.ts`, or `.policy.ts`.

## File naming

`kebab-case.<suffix>.ts`. Concept first, suffix last:

- ✅ `credit-card.entity.ts`, `card-token.vo.ts`, `fraud-analysis.policy.ts`
- ❌ `creditCardEntity.ts`, `Entity.creditCard.ts`, `customerModel.ts`

## Test suffixes

Test suffixes (`.test.ts`, `.contract.test.ts`, `.int.test.ts`, `.spec.ts`, `.stub.ts`, `.fake.ts`, `.spy.ts`, `.mock.ts`, `.builder.ts`, `.fixture.ts`) are owned by the sibling skill **ts-hermetic-testing**. See its `references/pyramid-and-placement.md` and `references/doubles-taxonomy.md`.

## Enforcement at review time

When reviewing a PR, check:

1. Each new file has exactly one main suffix from the table above.
2. If a file imports things that don't fit its suffix's layer (e.g. `.entity.ts` importing `axios`), the suffix is wrong, the imports are wrong, or both.
3. Renames during refactor have been applied (no `customer.service.ts` that is actually a usecase).
