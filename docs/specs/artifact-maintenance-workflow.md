# Artifact Maintenance Workflow

Use this workflow when creating, reviewing, or changing repository artifacts:
skills, pack-bundled skills, scripts/tools, Cursor packs, rules, hooks, and
agent-facing documentation.

For the governing decision, see
`docs/ADR/ADR-0003-artifact-maturity-model.md`.

## Core Rule

Classify the artifact before editing it.

1. Identify the artifact type.
2. Determine its maturity level.
3. Read the artifact's durable contract.
4. Update the contract before changing mature behavior.
5. Verify with the level-appropriate evidence.

Do not infer product scope only from the current implementation. Mature
artifacts should have a spec, roadmap, README, release policy, or linked issue
that explains what the implementation is supposed to mean.

## Maturity Levels

| Level | Name | When to use | Required maintenance behavior |
| --- | --- | --- | --- |
| L0 | Experimental | Scratch work, intake, spikes, temporary imports | Keep scope local; do not present as maintained |
| L1 | Usable | Personal-use artifact with a stable entrypoint | Preserve required files and make usage discoverable |
| L2 | Maintained | Reused artifact, stable CLI/behavior, or recurring backlog | Maintain a durable contract, tests or verification notes, and issue links |
| L3 | Released/Critical | Registry-managed pack, safety-sensitive workflow, or broad reuse | Maintain release evidence, changelog/roadmap, strict validation, and change gates |

## Artifact Routing

### Root Skills: `skills/<name>/`

Read first:

- `docs/ADR/ADR-0002-governed-skill-maintenance-model.md`
- `docs/ADR/ADR-0003-artifact-maturity-model.md`
- `docs/specs/skill-authoring-checklist.md`
- the skill's `SKILL.md`, `metadata.json`, and maintainer docs

Expected files by maturity:

| Level | Expected files |
| --- | --- |
| L1 | `SKILL.md`, `metadata.json`, registry entry when registry-managed |
| L2 | L1 plus `CHANGELOG.md`, `README.md` when maintained or imported |
| L3 | L2 plus stronger validation evidence; keep `SKILL.md` compact |

Add `SPEC.md` to a root skill only when the skill has tool-like behavior,
multi-step policy semantics, or complex backlog that cannot be maintained well in
`README.md` or `CHANGELOG.md`.

Before changing a maintained skill:

- Confirm whether the behavior change requires a version bump.
- Update `metadata.json`, `skill-registry.json`, and `CHANGELOG.md` together
  when bumping.
- Keep `SKILL.md` as the hot path; move heavy explanation to `references/`.

### Pack-Bundled Skills: `packs/<pack>/skills/<skillId>/`

Read first:

- `docs/ADR/ADR-0002-governed-skill-maintenance-model.md`
- `docs/specs/agentic-skill-pack-authoring.md`
- the containing pack's `pack.json`, `README.md`, and `CHANGELOG.md`

Rules:

- Bundled skills version with the containing pack by default.
- The pack owns the roadmap and release evidence unless the skill is promoted.
- Promotion to `skills/<name>/` requires explicit registry and changelog work.

### Scripts And Tools: `scripts/`

Read first:

- `docs/ADR/ADR-0003-artifact-maturity-model.md`
- the script header and any companion `scripts/<tool>/SPEC.md`
- tests under `scripts/<tool>/tests/`
- related GitHub issues for planned behavior

L2 scripts/tools should have:

- usage in the script header or README
- `scripts/<tool>/SPEC.md`
- tests or documented verification
- future-work or backlog links for known enhancements

The reference pattern is:

```text
scripts/<tool>.sh
scripts/<tool>/SPEC.md
scripts/<tool>/tests/run-tests.sh
```

Before changing a maintained script/tool:

- Update `SPEC.md` first when CLI behavior, safety behavior, output, or
  persistence changes.
- Add or update tests before implementation when feasible.
- Keep destructive behavior explicit and backed up.
- Link a GitHub issue for backlog items that are not implemented in the same
  change.

### Cursor Packs: `packs/<name>/`

Read first:

- `docs/specs/cursor-pack-specification.md`
- `docs/specs/pack-authoring-checklist.md`
- `docs/cursor-packs.md`
- the pack's `README.md`, `ROADMAP.md`, `RELEASE-POLICY.md`, and
  `VERIFICATION.md`

Registry-managed packs are L3 by default. Maintain:

- `pack.json`
- `README.md`
- `CHANGELOG.md`
- `VERIFICATION.md`
- `RELEASE-POLICY.md`
- `ROADMAP.md`

Before changing a pack:

- Update `ROADMAP.md` for future work and `CHANGELOG.md` for released behavior.
- Run `scripts/cursor-pack-verify.sh` for affected target/profile combinations.
- Keep project-only and user-level install behavior explicit.

### Agent Guidance: `AGENTS.md`, `.cursor/rules/`, Local Skills

Read first:

- `AGENTS.md`
- `.cursor/rules/*` that match the changed paths
- any local skill being changed under `skills/`

Rules:

- Put durable repository doctrine in ADRs or `docs/specs/`.
- Keep `AGENTS.md` as routing guidance, not a duplicated policy manual.
- Use `.cursor/rules/` for short enforcement cues that should apply before file
  edits.
- Update local maintainer skills when future agents need to discover the policy
  through skill routing.
- Update the repository root `CHANGELOG.md` when changing cross-cutting
  governance, workflow, ADR, rule, or maintainer-skill behavior.

## Backlog Workflow

Use this loop for feature evolution:

1. Capture the idea in a GitHub issue when it is a concrete implementation slice.
2. Link the issue from the artifact's `SPEC.md`, `ROADMAP.md`, or README if the
   idea affects durable product direction.
3. Update the durable contract before implementation.
4. Add tests or verification notes that prove the new behavior.
5. Close or update the issue from the PR with validation evidence.

Issue titles should be concrete and scoped:

```text
feat(skill-directory-sync): add pretty human output mode
docs(skill-studio-maintain): route through ADR-0003
test(cursor-pack-sync): cover backup restore metadata
```

## Promotion Checklist

Promote an artifact when at least two are true:

- It is used in more than one workflow or agent surface.
- It has safety-sensitive filesystem, network, deployment, or credential impact.
- It has recurring backlog or multiple follow-up issues.
- It is registry-managed or installed by a pack.
- Future agents are likely to change it without the original author present.

Promotion steps:

- [ ] Assign the target maturity level.
- [ ] Add or update the durable contract (`SPEC.md`, README, ROADMAP, or ADR).
- [ ] Add tests or verification notes.
- [ ] Link open backlog issues.
- [ ] Update `AGENTS.md`, `.cursor/rules/`, or maintainer skills if routing
  changes.
- [ ] Add release evidence if promoting to L3.

## Demotion And Archival

Demote or archive an artifact when it no longer has an active maintenance
promise.

- Mark the deprecation in the durable contract.
- Remove or close stale backlog links.
- Preserve enough history for users to understand replacement guidance.
- Do not silently delete registry-managed or pack-managed artifacts without a
  separate removal plan.

## Quick Examples

`scripts/skill-directory-sync.sh` is L2 because it has stable CLI behavior,
filesystem safety requirements, tests, and future backlog. Changes such as
`--pretty`, `--json`, or restore support must start in
`scripts/skill-directory-sync/SPEC.md`.

`packs/cursor-companion/` is L3 when registry-managed because it installs runtime
assets and has release artifacts.

A small self-contained root skill may remain L1 with only `SKILL.md`,
`metadata.json`, and registry metadata until it develops release history,
source-contract risk, or recurring backlog.
