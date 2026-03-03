# TypeScript Test Style Guidance (Tier-Aligned, Non-Classifying)

This reference defines **style constraints** for writing tests in TypeScript.

These rules are **NOT** used to classify test tiers. Tier classification is
defined in `tdd-classicist` and is based on:

- primary claim (the contract being proven)
- SUT boundary + real boundary count (\(0 / 1 / many\))

Style is still valuable: it reduces ambiguity and makes suites navigable.

---

## Style rules (MUST)

### 1) Exactly one primary claim per test

- Each test MUST have exactly one primary claim (one contract being proven).
- If a test proves multiple claims, split it.

### 2) Unit + boundary integration: use `test()`

For these tiers:
- `src/**/*.spec.ts?(x)` (unit)
- `test/integration/**/*.int.spec.ts` (boundary integration)

Rules:

- Tests MUST use `test()` (not `it()`).
- Test titles MUST be factual/outcome-shaped and MUST NOT start with “should”.

Examples (good):
- `test('throws when dt <= 0', ...)`
- `test('enforces unique(email)', ...)`
- `test('round-trips null mapping', ...)`
- `test('returns 404 when order does not exist', ...)`

Examples (bad):
- `it('should validate input', ...)`
- `test('should work', ...)`

### 3) Scenario tiers: scenario structure allowed

For these tiers:
- `test/functional/**/*.func.spec.ts`
- `test/contract/**/*.contract.spec.ts`
- `test/e2e/**/*.e2e.spec.ts`

Rules:

- Tests MAY use nested `describe('given ...')` / `describe('when ...')`.
- Tests MAY use `it()` and MAY use “should”.
- Titles MUST still be outcome-shaped (observable result), not vague intention.

Examples (good):
- `describe('given inactive user', () => it('returns 403', ...))`
- `it('should return 403 for inactive user', ...)` (allowed, outcome-shaped)

Examples (bad):
- `it('should work', ...)`
- `describe('given thing', () => it('does stuff', ...))`

---

## Why these rules exist

- `test()` for verification tiers reduces bikeshedding and keeps lower tiers
  factual and invariant-focused.
- Scenario tiers allow narrative framing because the primary claim is a story
  slice or contract, not a narrow invariant.

---

## Enforcement

These rules are intended to be mechanically enforceable by audit scripts.
See `scripts/audit-test-style.sh`.

