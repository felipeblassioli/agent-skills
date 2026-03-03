# Decision Tree — Choose a Test Double

Use this procedure to determine which type of test double to use (or whether
to use the real collaborator). Start at step 1.

Derived from [taxonomy-test-doubles.md](../../references/taxonomy-test-doubles.md).

---

## Procedure

### 1. Can you use the real collaborator?

The real collaborator is fast, deterministic, in-process, and does not require
infrastructure setup.

- **Yes** → **Use the real collaborator.** No double needed. (This is the
  classicist default.)
- **No** → Continue to step 2.

### 2. Why can you not use the real collaborator?

| Reason | Go to |
|--------|-------|
| It requires infrastructure (DB, network, queue, filesystem) | Step 3 |
| It is slow or expensive | Step 3 |
| It is nondeterministic (time, randomness, external state) | Step 3 |
| It has side effects that cannot be observed via state | Step 4 |
| You just need to fill a parameter list (the collaborator is not exercised) | Use a **Dummy** |

### 3. Do you need the collaborator to behave realistically?

- **Yes, it needs working behavior** (e.g., supports queries, maintains state)
  → **Fake** (e.g., in-memory repository, in-memory event bus).
- **No, you just need it to return specific values** → **Stub** (canned
  responses, simplest option).

### 4. Do you need to verify a side-effect was triggered?

"Side-effect" = something the SUT does to/through the collaborator that is part
of the contract (e.g., "must send an email", "must emit an audit event").

- **Yes, and you can verify it via recorded data** (e.g., check a list of
  sent messages) → **Spy** (records calls; you assert on the recording).
- **Yes, and the interaction protocol itself is the contract** (specific calls
  in a specific order, not just "it was called") → **Mock** (behavior
  verification). Justify this choice in the test name or a comment.
- **No** → Go back to step 3; you likely need a stub or fake.

---

## Summary Flowchart

```
Can use real collaborator? ──yes──→ Use real (no double)
  │no
  ▼
Just filling a param list? ──yes──→ Dummy
  │no
  ▼
Needs working behavior? ──yes──→ Fake
  │no
  ▼
Just need return values? ──yes──→ Stub
  │no
  ▼
Verify side-effect triggered?
  │yes, via recorded data ──→ Spy
  │yes, protocol is contract ──→ Mock (justify!)
  │no ──→ Re-examine; likely Stub or Fake
```

---

## Red Flags (reconsider the design)

- **3+ mocks in one test** → SUT is too coupled. Redesign before adding mocks.
- **Mocking what you own** (and the real thing is cheap) → Use the real thing.
- **Asserting call order when order does not matter** → Use a spy or stub instead.
- **Every collaborator is mocked** → You are testing a call graph, not behavior.
