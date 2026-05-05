# BMAD-METHOD Validation Scenario

## Metadata

- Pack: `agentic-artifact-discovery`
- Pack version: `0.1.0`
- Validation date: `2026-03-22`
- Target path: `tmp/BMAD-METHOD`
- Scenario type: deep discovery validation

## What this scenario is meant to prove

This scenario tests whether the pack can explain a large, mixed agentic system
without drifting into generic repository mapping.

Specifically, it checks whether the pack can:

- classify BMAD correctly
- identify the main user-facing and helper surfaces
- explain at least one real cross-file workflow
- preserve anti-trigger boundaries

## Scenario artifacts

- `discovery-report.md`
- `prompt-matrix.md`
- `boundary-checks.md`
