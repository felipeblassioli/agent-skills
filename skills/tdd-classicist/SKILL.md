---
name: tdd-classicist
description:
  Classicist TDD methodology — test-first Red-Green-Refactor cycle, Meszaros
  test-double taxonomy (dummy/fake/stub/spy/mock), tiered test pyramid
  (unit → integration → functional → contract → regression → E2E), and
  assertion/doubles policies. Use when writing tests, choosing test doubles,
  naming test files, deciding test tier placement, or reviewing test quality.
  Do NOT use for test-runner configuration (see vitest-monorepo), CI pipeline
  setup, or framework-specific testing APIs.
---

# TDD — Classicist

Classicist by default, pragmatic about doubles, strict about test purpose and
boundaries. This skill encodes a complete testing methodology: the TDD cycle,
a precise test-double taxonomy, a tiered test pyramid, and assertion policies.

## Applicability Gate

Apply this skill when ALL of the following are true:

- You are writing, reviewing, or designing tests (not configuring test runners)
- The project uses TypeScript or JavaScript
- You need to decide: test tier placement, double type, assertion approach, or
  TDD cycle adherence

Do NOT apply when:

- Configuring `vitest.config.ts`, `jest.config.ts`, or `playwright.config.ts`
  (use `vitest-monorepo` or a framework-specific skill)
- Setting up CI pipelines or coverage thresholds
- Working in this skills repository itself

## Routing Table

| Topic | Route to |
|-------|----------|
| TDD cycle (Red-Green-Refactor, Iron Law) | [methodology-red-green-refactor](references/methodology-red-green-refactor.md) |
| "Should I mock/stub/fake this?" | [taxonomy-test-doubles](references/taxonomy-test-doubles.md) |
| "Where does this test go?" (tier + dir) | [taxonomy-test-tiers](references/taxonomy-test-tiers.md) |
| "What should I assert?" | [assertions-and-contracts](references/assertions-and-contracts.md) |
| "Is my test suite healthy?" | [suite-health](references/suite-health.md) |
| Classical vs mockist philosophy | [classical-vs-mockist](references/classical-vs-mockist.md) |
| Audit doubles usage in codebase | `scripts/audit-test-doubles.sh` |
| Test file boilerplate (unit) | [assets/templates/unit-test.ts](assets/templates/unit-test.ts) |
| Test file boilerplate (integration) | [assets/templates/integration-test.ts](assets/templates/integration-test.ts) |

## Procedure

1. **Identify the task type.** Is the user writing a new test, choosing a
   double, placing a test file, reviewing test quality, or fixing a bug?
2. **Route to the right reference.** Use the routing table above. Read only
   the reference file(s) needed — do not load all six.
3. **Apply the methodology.** Follow the normative rules (MUST/SHOULD/MAY)
   from the loaded reference.
4. **When writing tests,** always follow the Red-Green-Refactor cycle from
   `methodology-red-green-refactor.md`. No production code without a failing
   test first.
5. **When choosing doubles,** follow the tiered preference in
   `taxonomy-test-doubles.md`: stub → fake → spy → mock. Justify any mock.
6. **When placing tests,** follow the directory and naming conventions in
   `taxonomy-test-tiers.md`.

## Confirmation Policy

Do NOT apply changes derived from these rules without explicit user
confirmation. Present proposed test code and placement as diffs and wait for
approval.

## Related Skills

- **vitest-monorepo** — Vitest runner configuration and workspace setup
- **typescript-quality** — Typed clients, Zod validation, structured errors
- **esm-typescript** — ESM module patterns for `import.meta.url` in tests
