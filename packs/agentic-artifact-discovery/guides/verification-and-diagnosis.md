# Verification And Diagnosis

This document records the first thorough real-world validation of
`agentic-artifact-discovery` against `tmp/BMAD-METHOD` and explains what that
validation actually proved.

## Why BMAD-METHOD

`tmp/BMAD-METHOD` is a strong early validation target because it is not a simple
skill folder or a simple plugin bundle. It combines:

- a public npm install surface
- a large skill and workflow tree
- persona-style agent skills
- module catalogs that drive routing
- installer logic that materializes runtime help files
- heavy support collateral such as tests, templates, website content, and CLI
  helpers

That mix is exactly the kind of target the pack claims it can help explain.

## Validation goals

The BMAD validation aimed to prove that the pack can:

- classify the target correctly without flattening it into generic repo mapping
- find the highest-signal surfaces for user entry points and helper behavior
- explain at least one concrete cross-file workflow with evidence
- stay within boundary when prompts try to pull it toward debugging, migration,
  or broad architecture review

## Structural verification

The pack passed:

```bash
bash scripts/cursor-pack-verify.sh --pack=agentic-artifact-discovery
bash scripts/cursor-pack-sync.sh --pack=agentic-artifact-discovery --target=project --project-root="$PWD" --profile=lite --dry-run
bash scripts/cursor-pack-sync.sh --pack=agentic-artifact-discovery --target=user --profile=lite --dry-run
```

## Validation method

The validation followed the pack's intended operating model:

1. Start from the bundled skill boundary.
2. Use the exploration role to inventory and classify the target cheaply.
3. Ground the final report in a few source-of-truth files rather than reading
   the whole repository.
4. Record stable outputs under `verification-outputs/bmad-method/`.

The high-signal grounding files were:

- `tmp/BMAD-METHOD/README.md`
- `tmp/BMAD-METHOD/package.json`
- `tmp/BMAD-METHOD/src/bmm-skills/module-help.csv`
- `tmp/BMAD-METHOD/src/core-skills/bmad-help/SKILL.md`
- `tmp/BMAD-METHOD/src/bmm-skills/2-plan-workflows/bmad-agent-pm/SKILL.md`
- `tmp/BMAD-METHOD/src/bmm-skills/2-plan-workflows/bmad-create-prd/workflow.md`

## What the pack got right

### 1. It classified BMAD as a mixed agentic system

This was the right top-level read.

BMAD is not only:

- a skill tree
- a workflow library
- a plugin bundle
- a CLI tool

It is a mixed artifact where those surfaces reinforce each other.

### 2. It surfaced the real user entry points

The validation showed three key entry categories:

- install via `npx bmad-method install`
- invoke skills and commands through the help/catalog layer
- activate persona-style agent skills such as `bmad-agent-pm`

That is more useful than a generic directory summary because it tells a user how
they would actually enter the system.

### 3. It found the routing surfaces, not just the pretty docs

The strongest discovery signal did not come only from the README. It came from:

- `module-help.csv`
- `bmad-help`
- thin `SKILL.md` entrypoints
- workflow files such as `workflow.md`

This is an important validation result for the pack: many agentic systems hide
their true routing logic in catalogs and orchestration docs.

### 4. It could explain a concrete planning flow

The pack could support a real cross-file flow:

1. user activates a PM-facing entry surface
2. the PM agent loads `bmad-init`
3. the PM capability table exposes `CP`
4. `CP` routes to `bmad-create-prd`
5. the PRD workflow enforces step-file execution

That is a meaningful discovery result, not just an inventory list.

## What the validation exposed

### 1. Boundary drift is still the biggest failure mode

BMAD contains a lot of tempting noise:

- website source
- test suites
- installer templates for many IDEs
- validators and build helpers

Without discipline, the pack could become a generic repo explainer. The BMAD
validation confirms that the pack should keep emphasizing user surfaces,
catalogs, and flow transitions first.

### 2. Catalog-driven systems need stronger heuristics

BMAD's workflow state and routing live heavily in CSV and skill metadata. The
pack should become better at noticing that pattern early:

- look for `module-help.csv`
- look for helper skills that read generated catalogs
- look for thin entry skills that delegate to workflow files

### 3. Source-only views can miss generated runtime state

Some runtime behavior becomes clearer only after install-time generation. The
source repository alone is not always the full execution story. The pack should
be explicit when a checkout reveals source-of-truth inputs but not all generated
runtime artifacts.

## Durable evidence

The committed BMAD evidence lives here:

- `verification-outputs/bmad-method/discovery-report.md`
- `verification-outputs/bmad-method/prompt-matrix.md`
- `verification-outputs/bmad-method/boundary-checks.md`

These files are intentionally curated and stable. Raw transcripts or repeated
scratch runs should stay in `.work/`.

## Diagnosis summary

The BMAD pass validates the pack's core concept:

- a narrow bundled skill
- a cheap exploration role
- stable report output
- strong anti-trigger boundaries

The next improvement work should focus less on adding more runtime surfaces and
more on sharpening discovery heuristics for large catalog-driven systems.
