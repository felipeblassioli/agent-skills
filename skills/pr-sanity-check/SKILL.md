---
name: pr-sanity-check
description: >
  Lightweight engineering and release judgment for an already-reviewed PR.
  Start from the PR, reconstruct the linked bug/board problem and related work,
  find the smallest coherent improvement worth shipping, and check that it
  actually helps production without unacceptable side effects.
  Use for pre-merge, pre-deploy, post-deploy, or reconsidering an older PR.
---

# PR sanity check

**Start from the PR; reason about the problem and the present production system.**
This is not another code review, a mandate to close the whole epic, or a guarantee
of safety. Decide: *is the problem worth addressing now, does this intervention
have positive marginal value, and what is the sensible release boundary?*

## Follow the evidence, proportionally

1. **Reconstruct purpose and business meaning.** Read the current PR/diff and
   target branch, then its referenced issue, bug report/board card, relevant
   discussion, and available read-only runtime evidence. Explain the affected
   business workflow, desired outcome, and invariants that must remain true.
   Treat descriptions and board priority as claims until corroborated.

2. **Find the surrounding problem, not merely nearby files.** Follow direct
   issue/epic/duplicate links, related PRs, mitigations and important recent
   changes. Look across services when they share a business event, data identity,
   invariant, or producer-consumer contract. Distinguish:
   - Same underlying cause vs. similar symptom.
   - Prerequisite/contract dependency vs. complementary improvement.
   - Actual Git conflict vs. semantic conflict despite a clean merge.
   - Root-cause prevention vs. historical repair, mitigation, visibility,
     or recovery.
   - Confirmed relationship vs. plausible relationship not yet verified.

   Keep discovery bounded: begin with direct references and their immediate
   dependencies. Expand only if an adjacent issue could change the goal,
   implementation, release ordering, or risk. Do **not** inventory the entire
   board by default or assume all related issues belong in one release.

3. **Ask whether acting now is worthwhile.** What is occurring *today* versus
   merely documented historically? Estimate affected distinct entities,
   rates/denominators, duration, severity, financial *meaning* (e.g., money lost
   vs. incorrectly classified), operator/customer burden, workarounds, and
   the cost/risk of delaying or doing nothing. Say when impact is unverified.
   Opportunity cost matters, but don't invent a board-wide priority rank.

4. **Find the minimum coherent intervention.** Compare status quo, this PR,
   a narrow correction, and (if useful) a related coordinated change or
   operational mitigation. A good slice may be imperfect, but must make an
   independently useful, observable improvement while preserving the business
   invariants it touches. Do not prefer the smallest diff if it creates bad
   records, duplicate effects, stranded state, or unverifiable success.
   Equally, don't withhold useful partial progress merely because a larger
   cluster remains unresolved. Identify where sequencing or one shared
   business contract genuinely requires coordination.

5. **Re-check present release reality.** Compare the proposed change against
   current main/integrated code, existing deployments, required configuration,
   consumers, recovery/rollback constraints and any verification plan. A green
   CI or conflict-free Git merge does not establish semantic compatibility.
   Inspect only the narrow execution paths needed to test a concrete concern.

6. **Define an outcome test, not just an error test.** Use the smallest existing
   set of production signals that distinguishes: intended business improvement;
   normal workflow health; collateral/semantic regression; and explicitly
   unsolved parts of the problem. Prefer paired numerators/denominators and
   before/after cohorts. An exception disappearing or a counter going to zero
   with no traffic is not enough. Reuse existing verification instead of
   creating process or telemetry by default.

## Judgment

Make **three separate judgments**:
- **Worth addressing now?** Yes / no / uncertain, with observed impact and cost of delay.
- **Is this approach valuable?** Sound / partially useful / unsound / uncertain.
- **What is the next action?** Ship this slice / small correction / prepare rollout /
  coordinate with named PRs / investigate one blocking question / defer or rethink.

If the PR belongs to a genuine multi-PR problem, include a **tiny relation map**:
related item → role in the workflow → dependency or conflict → must ship together?
Only include relationships that could change the decision; cap the overview and
link to evidence rather than copying dossiers. A coherent fix can span repos,
but a related issue does not automatically become a blocker.

Default to a concise briefing (~250–400 words), expanding only for a material
surprise. Include:
- **Why and why now:** business problem, affected population and important unknowns.
- **Fit in the broader work:** nearest related issues/PRs and relevant boundaries.
- **Decision:** the three judgments and one concrete next step.
- **Production glance:** successful outcome, collateral guardrail, and what
  remains unsolved, with baseline and observation window when available.
- **What would change the decision:** one or two discriminating facts.

Separate **observed**, **reported**, **inferred**, and **unknown** facts. For
important conclusions, link evidence and dates/SHAs. If the board, source or
runtime is inaccessible, explicitly bound the conclusion; do not guess.
Read-only by default: never merge, edit code, deploy, or mutate production.
