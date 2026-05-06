# Contract and golden-file testing

Use this layer when the observable contract is larger than one pure function but still does not require I/O. The goal is to protect a deterministic artifact or end-to-end pure pipeline.

## Scope

- Pure pipelines such as `snapshot -> planner -> serializer`.
- Golden outputs such as CSV, JSON, markdown, or ordered domain plans.
- Determinism checks: the same input must produce byte-identical output across reruns.
- Structured failure contracts for infeasible or invalid scenarios.

## Placement

- Put these suites under `test/contract/<area>/`.
- Use `*.contract.test.ts`.
- Keep committed expected outputs under a nearby `golden/` directory.

Example:

```text
test/contract/core-engine/
├── success.contract.test.ts
├── infeasible.contract.test.ts
├── determinism.contract.test.ts
└── golden/
    └── balanced-week.csv
```

## What to verify

1. **Success path**: realistic inputs produce the expected artifact exactly.
2. **Failure path**: infeasible inputs return the expected structured error.
3. **Determinism**: repeated runs over the same input stay byte-identical.

## Golden-file rules

- Commit the golden file to version control.
- Compare exact bytes when order and formatting are part of the contract.
- Treat golden updates as deliberate behavior changes, not incidental snapshot churn.
- Keep fixtures realistic enough to exercise ordering and edge-case interactions.

## Minimal example

```ts
import { readFileSync } from "node:fs";
import { join } from "node:path";
import { describe, expect, it } from "vitest";

import { generateScheduleCsv } from "../../packages/core/src/generate-schedule";
import { sampleSnapshot } from "../__fixtures__/sample-snapshot";

const goldenPath = join(import.meta.dirname, "golden", "balanced-week.csv");

describe("generateScheduleCsv", () => {
  it("matches the committed golden output", () => {
    const actual = generateScheduleCsv(sampleSnapshot);
    const expected = readFileSync(goldenPath, "utf8");

    expect(actual).toBe(expected);
  });
});
```

## Anti-patterns

- Putting database or HTTP calls in a contract/golden suite. Promote those to integration or E2E.
- Using contract tests as vague snapshots for unstable internal shapes.
- Updating the golden file without explaining why the observable output changed.
- Testing only the happy path when infeasibility or determinism are core promises.
