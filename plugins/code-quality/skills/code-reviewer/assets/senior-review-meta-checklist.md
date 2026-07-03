# Senior Review Meta-Checklist

Apply this pass **before issuing the verdict**, after the workload-specific lenses are done. It catches the kind of mistakes that are not technical defects but make the review wrong overall.

## Steel-man

- [ ] I wrote (or could write) the strongest argument *for* this change as-is, before issuing BLOCKERs.
- [ ] If the author has more context than I do (recent incident, deprecation deadline, partner constraint), my findings still hold or I noted the assumption.

## Asymmetric risk

- [ ] If the change is **small but the blast radius is large** (auth, billing, schema, money, security, data deletion), severities are tilted **up**.
- [ ] If the change is **large but isolated** (UI copy, internal tooling, dev-only code), severities are tilted **down**.
- [ ] Reversibility was weighed: the same defect in reversible vs irreversible code is not the same severity.

## Scope and intent

- [ ] PR title and description match the actual diff scope.
- [ ] Drive-by changes to shared modules are flagged for separation, or accepted with explicit justification.
- [ ] Plan / spec / linked issue is reviewed and tasks are checked against the diff. Silent omissions and silent additions are surfaced.

## Rollback and reversibility

- [ ] Rollback plan exists or is not needed because the change is feature-flagged off by default.
- [ ] Migrations are backward-compatible during rollout overlap or have a documented multi-phase plan.
- [ ] The PR can be reverted cleanly without orphaning durable state.

## 3-AM signal

- [ ] If this paged me at 3 AM, the logs / metrics / traces would tell me **which** user, **which** entity, **which** dependency, and **what to do next** — without a redeploy.
- [ ] Alerts that are added or modified map to user impact or operator action and link to a runbook.
- [ ] No silent error swallowing along the new code paths.

## Calibration

- [ ] Findings are concrete (file:line, evidence, consequence, fix), not vibes.
- [ ] Duplicate findings are grouped.
- [ ] BLOCKERs are reserved for data loss, security, contract breaks, irreversible duplication, or unsafe deploy behavior.
- [ ] LOW / nit findings are clearly separated from production-impacting findings so the author can see signal from noise.
- [ ] Defects (invariant violations, "should never happen" cases) are not silently retried as failures, swallowed in catch blocks, or downgraded to generic 500s.

## Final question

- [ ] If I were on call for this service this weekend, would I want this merged as-is?
