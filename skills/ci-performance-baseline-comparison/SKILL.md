---
name: ci-performance-baseline-comparison
description: >-
  Use when CI optimizations have been implemented and need to be measured against
  a known baseline run. Use when collecting GitHub Actions job timings, computing
  deltas, building comparison tables, and posting a structured PR comment with
  Mermaid charts. Triggers on tasks like "compare CI before/after", "post
  optimization results to PR", "show how much faster the pipeline is now".
---

# CI Performance Baseline Comparison

## Overview

After applying CI optimizations, you must collect real run data, compute deltas vs
a pre-optimization baseline, and post a structured PR comment. The comment is the
evidence artifact that closes the optimization loop.

---

## Step 1 — Identify Runs

| Run type | How to find |
|:---|:---|
| **Baseline** | Last successful run on `main` *before* the optimization PR was opened |
| **Cold cache** | First push of the optimization PR (all caches empty) |
| **Warm cache** | A subsequent source-only push on the same PR (caches populated) |

```bash
# list recent runs on main (baseline candidates)
gh run list --branch=main --limit 10 --json databaseId,conclusion,createdAt,displayTitle

# list runs for the optimization PR branch
gh run list --branch=<branch> --limit 5 --json databaseId,conclusion,status,url
```

---

## Step 2 — Collect Job Timings

```bash
# dump all job names + durations for a run (seconds)
gh run view <run-id> --json jobs \
  --jq '.jobs[] | {name: .name, duration: (.completedAt | . as $end | ..startedAt // $end)}'

# simpler: view job log headers to read wall-clock from the summary
gh run view <run-id>
```

Extract per-job **start offset** (seconds after run start) and **duration** from the
`gh run view` summary table. Record:

| Job | Start | Duration |
|:---|:---|:---|
| `changes` | 0s | Xs |
| `quality` | Xs | Ym Zs |
| `firebase-dry-run` | Xs | Ym Zs |
| `pr-standalone-local` | Xs | Ym Zs |
| `diff-dev` | Xs | Ym Zs |
| `required-pr-checks` | Xs | Ys |

**Critical path** = longest chain from first job start to last required-check finish.

---

## Step 3 — Compute Deltas

| Metric | Formula |
|:---|:---|
| Delta | `optimized − baseline` (negative = improvement) |
| % | `(delta / baseline) × 100` (negative = improvement) |

---

## Step 4 — Build the PR Comment

Stage the comment body in `.work/pr-comment-<slug>.md` and post with:

```bash
gh pr comment <PR-number> --body-file .work/pr-comment-<slug>.md
```

### Comment Structure (in order)

1. **Header** — title + one-line status (all goals met / partial / blocked)
2. **Executive Summary Table** — key metrics with Baseline | Optimized | Delta | %
3. **Mermaid Bar Chart** — visual comparison by job duration
4. **Timeline Tables** — Before (serial) and After (parallel + cache) side by side
5. **Optimizations Applied Table** — one row per change, file(s), impact
6. **Success Checklist** — acceptance criteria from the original issue/plan
7. **Validation Runs Table** — run IDs, type (baseline/cold/warm), date, note

---

## Mermaid xychart-beta Template

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'primaryColor': '#ff6b6b', 'secondaryColor': '#51cf66'}}}%%
xychart-beta
    title "Duração por Job (Baseline vs Otimizado)"
    x-axis [quality, pr-standalone-local, firebase-dry-run, diff-dev]
    y-axis "Minutos" 0 --> 20
    bar [<baseline values as decimals>]
    bar [<optimized values as decimals>]
```

> Convert seconds to minutes for readability: `614s → 10.23`.  
> First `bar` = Baseline 🔴, second `bar` = Otimizado 🟢.  
> GitHub renders Mermaid natively in PR comments.

---

## Executive Summary Table Template

```markdown
| Métrica | Baseline | Otimizado (Warm Cache) | Delta | % |
|:---|:---|:---|:---|:---|
| **Caminho Crítico** | ~Xm Ys | **~Am Bs** | **-Cm Ds** | **-E%** |
| **Wall Clock Total** | ~Xm Ys | **~Am Bs** | **-Cm Ds** | **-E%** |
| Início `<key-job>` (após `changes`) | Xm Ys | **Am Bs** | -Cm Ds | -E% |
| Duração `quality` (cache hit) | Xm Ys | **Am Bs** | -Cm Ds | -E% |
```

---

## Common Mistakes

| Mistake | Fix |
|:---|:---|
| Using cold-cache run as "optimized" | Always report **warm-cache** as the headline number; call out cold separately |
| Measuring wall-clock only | Report **critical path** (longest dependency chain) separately — it's what the developer waits for |
| Missing cold-cache data | Cold run shows worst-case; include it so reviewers know the first-push cost |
| Posting comment before CI finishes | Poll with `gh pr checks <N> --watch`; never report partial timings |
| Forgetting footnotes for anomalies | If a job regressed (e.g., standalone +13%), explain why with a footnote |

---

## Real-World Impact (turbi-guard PR #248)

| Run type | Critical path | vs Baseline |
|:---|:---|:---|
| Baseline (`main`, pre-optimization) | 15m 08s | — |
| Cold cache (first PR push) | ~19m 33s (standalone) | +29% (expected) |
| **Warm cache (source-only push)** | **8m 11s** | **-46%** |

Goal was ≤ 11 min warm-cache. Achieved 8m 15s. Optimizations: firebase-dry-run
parallelization, Dockerfile COPY reorder, Helm chart cache, BuildKit probe.
