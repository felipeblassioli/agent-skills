# Classical vs Mockist TDD

This reference explains the two major schools of TDD practice, codifies the
classicist stance adopted by this skill, and provides decision guidance for
when mockist techniques are justified.

Source: Martin Fowler, "Mocks Aren't Stubs"
(https://martinfowler.com/articles/mocksArentStubs.html)

---

## The Two Schools

### Classical TDD (Detroit style)

- Use **real objects** whenever possible.
- Use a test double only when the real collaborator is awkward (slow, nondeterministic, requires infrastructure).
- Verify by examining **state** of the SUT and its collaborators after exercising the behavior.
- The kind of double (stub, fake, spy) is chosen pragmatically; the choice is secondary to exercising real code paths.

### Mockist TDD (London style)

- Always use a **mock** for any collaborator with interesting behavior.
- Verify by checking that the SUT made the correct **calls** to its collaborators (behavior verification).
- Tests are designed outside-in: start at the outermost layer, mock everything below, and work inward.
- Emphasizes interface discovery and role interfaces.

---

## This Skill's Stance: Classicist by Default

**"Classicist by default, pragmatic about doubles, and strict about test
purpose and boundaries."**

This means:

1. **Exercise real code paths.** Tests SHOULD use real collaborators unless
   there is a concrete reason not to.
2. **Verify outcomes/state.** Tests MUST assert on observable results, not on
   call sequences, unless the call *is* the contract.
3. **Keep tests resilient to refactors.** If an internal implementation change
   (that preserves behavior) breaks a test, the test is over-specified.
4. **Mockist techniques are tools, not a philosophy.** Use them when they buy
   something concrete:
   - **Speed:** The real collaborator is too slow for the test tier.
   - **Isolation:** The real collaborator introduces nondeterminism (network,
     time, randomness).
   - **Hard-to-control dependencies:** The collaborator has side effects that
     cannot be observed via state (audit logs, metrics, event buses).
5. **Never turn tests into call-graph policing.** If the test asserts "method A
   calls method B with arguments X, Y, Z" and that call sequence is not the
   contract, the test is a liability.

---

## When to Use Mockist Techniques (Decision Guide)

Use behavior verification (mocks) when ALL of the following are true:

1. The interaction itself *is* the contract (e.g., "MUST emit an audit event
   with these fields").
2. There is no observable state change to verify instead.
3. A stub or spy does not provide sufficient verification.

Use stubs/fakes/spies (classicist doubles) when:

1. You need to control a dependency's return value → **stub**.
2. You need a working but non-production implementation → **fake**.
3. You need to verify a side-effect was triggered → **spy**.
4. The real collaborator is fast, deterministic, and available → **use the real thing**.

---

## Trade-offs Between the Schools

| Dimension | Classical | Mockist |
|-----------|-----------|---------|
| **Coupling to implementation** | Low — tests verify outcomes | High — tests verify call sequences |
| **Refactoring resilience** | High — implementation changes rarely break tests | Low — changing collaborator calls breaks tests |
| **Test isolation** | Lower — a bug in a collaborator causes cascading failures | Higher — only the SUT's test fails |
| **Fixture setup** | Can be complex (real object graphs) | Simpler (only SUT + mocks) |
| **Bug localization** | Requires looking at cascading failures | Immediate — only the SUT's tests fail |
| **Design pressure** | Middle-out / domain-first | Outside-in / interface-first |
| **Risk of false green** | Lower (exercising real code) | Higher (mocks may not match reality) |

### When cascading failures happen (classical)

A bug in a highly-used collaborator causes many tests to fail. This is a
feature, not a bug: the failures tell you the impact radius. The fix is:

1. Look at which tests fail.
2. Identify the root cause (usually the most recently changed code).
3. Fix the root cause; all cascading tests pass again.

If this is painful, the tests are too coarse-grained. The fix is finer-grained
unit tests, not more mocks.

---

## The Cache Exception

Some things are genuinely hard to verify via state, even in a classicist
approach. The canonical example: **a cache**. You cannot tell from state
whether a cache hit or miss occurred. This is a case where behavior
verification (verifying the cache was consulted, or that the source was *not*
called on a cache hit) is justified even for a classicist.

Other examples:
- Metrics emission (you care that metrics were recorded, not just the final state)
- Audit logging (the log entry is the contract)
- Circuit breaker state transitions

---

## Common Misapplications

| Misapplication | Why it is wrong | Fix |
|---------------|-----------------|-----|
| "Mock everything for isolation" | You are not testing real behavior | Use real objects; mock only what is awkward |
| "I always use London style because it is modern" | Style should match the testing goal, not fashion | Choose per-test based on what you are verifying |
| "Classicist means no mocks ever" | Classicist means mocks are a tool, not the default | Use mocks when justified; prefer stubs/fakes |
| "Behavior verification is always wrong" | Sometimes the behavior *is* the contract | Verify behavior when the call itself is what matters |

---

## See Also

- [taxonomy-test-doubles.md](taxonomy-test-doubles.md) — the Meszaros double types
- [assertions-and-contracts.md](assertions-and-contracts.md) — state vs behavior assertions
- [methodology-red-green-refactor.md](methodology-red-green-refactor.md) — the TDD cycle both schools share
