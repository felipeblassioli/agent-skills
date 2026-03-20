---
name: engineering-testing-strategy
description: Use when designing a test strategy, choosing test types and coverage priorities, or building a test plan for APIs, data pipelines, frontend systems, or infrastructure.
---

# Engineering Testing Strategy

Design a testing strategy that balances confidence, speed, and maintenance cost.

## Good Fits

- test planning for a new system or feature
- reviewing current coverage gaps
- deciding which test types belong at which layer

## Testing Pyramid

- unit tests: many, fast, focused
- integration tests: some, medium speed
- end-to-end tests: few, slow, highest confidence

## Coverage Focus

Prioritize:

- business-critical paths
- error handling
- edge cases
- security boundaries
- data integrity

Avoid over-investing in:

- trivial accessors
- framework internals
- throwaway scripts

## Useful Inputs

- the system or component being tested
- the riskiest user flows or failure modes
- current coverage pain points
- constraints on runtime, tooling, or maintenance budget

## Output

Produce a test plan covering:

- what to test
- which test type fits each area
- coverage goals
- sample test cases
- current coverage gaps

## Common Mistakes

- over-indexing on end-to-end tests for problems better covered lower down
- treating coverage percentage as the same thing as confidence
- writing a plan that ignores the most business-critical failure modes
