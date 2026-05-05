# Verification

This file is the committed release companion to `CHANGELOG.md`.

Each meaningful pack release should append:

- the validation commands that were run
- the validation scenario used when applicable
- the outcome
- the diagnosis that explains what still needs improvement

## Release 0.1.0 - 2026-03-21

## Goals

The validation aims to prove that:

- the pack is structurally valid
- the bundled skill remains explicit and compact
- the subagent performs bounded discovery rather than broad repo analysis
- the workflow can reason about the three reference examples without adding
  rules, hooks, or MCP artifacts

## Structural verification

The pack passed:

```bash
bash scripts/cursor-pack-verify.sh --pack=agentic-artifact-discovery
bash scripts/cursor-pack-sync.sh --pack=agentic-artifact-discovery --target=project --project-root="$PWD" --profile=lite --dry-run
bash scripts/cursor-pack-sync.sh --pack=agentic-artifact-discovery --target=user --profile=lite --dry-run
```

## Deep validation scenario

The first durable real-world validation targeted:

- `tmp/BMAD-METHOD`

The pack now includes committed evidence for this scenario under:

- `guides/verification-and-diagnosis.md`
- `verification-outputs/bmad-method/README.md`
- `verification-outputs/bmad-method/discovery-report.md`
- `verification-outputs/bmad-method/prompt-matrix.md`
- `verification-outputs/bmad-method/boundary-checks.md`

## Prompt-level validation targets

The first release is designed around these representative examples:

- `tmp/BMAD-METHOD`
- `tmp/superpowers`
- `tmp/claude-plugin-engineering`

The BMAD validation focused on these questions:

- can the workflow classify BMAD as a mixed agentic system instead of flattening
  it into a generic repo summary?
- can the subagent surface the high-signal files for flows, actors, and routing
  without flooding the parent context?
- does the pack preserve its anti-trigger boundary when prompted toward generic
  repo mapping, migration work, or debugging?

## What the BMAD validation proved

- the pack can explain BMAD as a `mixed-agentic-system` rather than misclassify
  it as only a skill tree or only a plugin bundle
- the workflow can identify the main user-facing surfaces:
  - `npx bmad-method install`
  - skill names exposed through merged help catalogs
  - agent personas such as `bmad-agent-pm`
- the workflow can identify the key runtime/helper surfaces:
  - `bmad-help`
  - `bmad-init`
  - module catalogs such as `module-help.csv`
  - installer merge logic that creates the runtime help catalog
- the workflow can explain a concrete planning flow from PM agent activation to
  PRD workflow execution with evidence
- the pack's biggest risk remains boundary drift, not missing raw discovery power

## Diagnosis

### 1. Boundary discipline remains the main quality risk

BMAD is large enough that the workflow could drift into generic repo mapping,
CLI internals, or ecosystem-wide explanation unless it stays anchored to user
surfaces, helper surfaces, and evidence-backed flows.

### 2. Catalog files are first-class discovery surfaces

For BMAD, `module-help.csv` and `bmad-help` are more important than directory
shape alone. The pack should keep teaching this pattern: look for routing
catalogs and thin entry skills before reading large support trees.

### 3. Source-only exploration still hides some post-install behavior

The repository shows the source catalogs and installer logic, but some generated
runtime artifacts appear only after installation. The pack should be explicit
when a source checkout is not the full runtime story.

### 4. One subagent is still enough for now

The BMAD pass was deep, but it did not reveal a second bounded helper role that
is clearly justified yet. The current split between exploration and synthesis is
still coherent.

## Outcome

Release `0.1.0` now has durable validation evidence anchored in a real target.
The pack is still early, but it is no longer relying only on structural checks
and intention-level prose.

For the longer-form narrative version of this validation, see
`guides/verification-and-diagnosis.md`.
