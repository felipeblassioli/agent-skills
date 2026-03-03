# Methodology — Red-Green-Refactor

The TDD cycle is the engine of classicist test-driven development. This
reference codifies the cycle, its verification gates, and the rationalizations
that undermine it.

---

## The Iron Law

```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
```

Write code before the test? Delete it. Start over. Implement fresh from tests.

- Do not keep it as "reference."
- Do not "adapt" it while writing tests.
- Do not look at it.
- Delete means delete.

---

## The Cycle

### RED — Write a Failing Test

Write one minimal test showing what should happen.

**Requirements:**
- One behavior per test.
- Clear name describing the contract being proven.
- Real collaborators when possible; stubs only for IO/nondeterminism.

### Verify RED — Watch It Fail

**MANDATORY. Never skip.**

Confirm:
- The test **fails** (not errors due to syntax/import/setup).
- The failure message matches what you expect.
- It fails because the **feature is missing** (not because of a typo or
  misconfiguration).

If the test passes immediately, you are testing existing behavior. Fix the test.

If the test errors (does not reach the assertion), fix the error and re-run
until it fails correctly at the assertion.

### GREEN — Write Minimal Code

Write the **simplest code** that makes the test pass.

- Do not add features the test does not require.
- Do not refactor other code.
- Do not "improve" beyond what the test demands.
- YAGNI: if the test does not ask for it, do not build it.

### Verify GREEN — Watch It Pass

**MANDATORY.**

Confirm:
- The new test passes.
- All existing tests still pass.
- Output is pristine (no errors, warnings, deprecation notices).

If the new test fails, fix the implementation (not the test).
If other tests fail, fix them now.

### REFACTOR — Clean Up (only after GREEN)

After green:
- Remove duplication.
- Improve names.
- Extract helpers.
- Simplify structure.

Rules during refactor:
- Keep all tests green.
- Do not add behavior.
- Do not change what the tests prove.

### REPEAT

Next failing test for the next behavior.

---

## When to Use TDD

**Always:**
- New features
- Bug fixes (write a regression test first)
- Behavior changes
- Refactoring that changes contracts

**Exceptions (ask your human partner):**
- Throwaway prototypes (but delete the prototype before real implementation)
- Generated code
- Pure configuration files

"Thinking 'skip TDD just this once'? Stop. That is rationalization."

---

## Common Rationalizations (and why they are wrong)

| Rationalization | Reality |
|----------------|---------|
| "Too simple to test" | Simple code breaks. A test takes 30 seconds. |
| "I'll test after" | Tests that pass immediately prove nothing. |
| "Tests after achieve the same goals" | Tests-after = "what does this do?" Tests-first = "what should this do?" |
| "Already manually tested" | Ad-hoc is not systematic. No record, cannot re-run. |
| "Deleting X hours is wasteful" | Sunk cost fallacy. Keeping unverified code is technical debt. |
| "Keep as reference, write tests first" | You will adapt it. That is testing-after. Delete means delete. |
| "Need to explore first" | Fine. Throw away the exploration, then start with TDD. |
| "Hard to test = skip testing" | Hard to test = hard to use. Listen to the test. Simplify the design. |
| "TDD will slow me down" | TDD is faster than debugging. Pragmatic = test-first. |
| "It's about spirit not ritual" | The ritual *is* the mechanism. Skip the ritual, lose the guarantee. |

---

## Red Flags — STOP and Start Over

- Code written before a test
- Test written after implementation
- Test passes immediately (not a valid red phase)
- Cannot explain why the test failed
- Tests added "later"
- Rationalizing "just this once"
- "I already manually tested it"
- "Keep as reference"
- "Already spent X hours, deleting is wasteful"
- "TDD is dogmatic, I'm being pragmatic"
- "This is different because..."

**All of these mean: delete code, start over with TDD.**

---

## Verification Checklist

Before marking work complete:

- [ ] Every new function/method has a test
- [ ] Watched each test fail before implementing
- [ ] Each test failed for the expected reason (feature missing, not typo)
- [ ] Wrote minimal code to pass each test
- [ ] All tests pass
- [ ] Output pristine (no errors, warnings)
- [ ] Tests use real collaborators (doubles only if justified)
- [ ] Edge cases and error paths covered

Cannot check all boxes? You skipped TDD. Start over.

---

## When Stuck

| Problem | Solution |
|---------|----------|
| Do not know how to test | Write the wished-for API first. Write the assertion first. Ask your human partner. |
| Test too complicated | Design too complicated. Simplify the interface. |
| Must mock everything | Code too coupled. Use dependency injection. Redesign. |
| Test setup huge | Extract helpers. Still complex? Simplify the design. |

---

## See Also

- [taxonomy-test-tiers.md](taxonomy-test-tiers.md) — which tier to write the test at
- [taxonomy-test-doubles.md](taxonomy-test-doubles.md) — choosing the right double
- [assertions-and-contracts.md](assertions-and-contracts.md) — what to assert
