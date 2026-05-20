---
title: Artifact maturity model
status: draft
date: 2026-05-19
owner: felipeblassioli
adr: 0003
---

# ADR-0003: Artifact maturity model

## Context

This repository now maintains several kinds of reusable agent artifacts:

- root skills under `skills/<name>/`
- pack-bundled skills under `packs/<pack>/skills/<skillId>/`
- Cursor packs under `packs/<name>/`
- operational scripts under `scripts/`
- repository guidance such as `AGENTS.md`, `.cursor/rules/`, and docs specs

ADR-0001 defines registry-driven releases for skills and packs. ADR-0002
defines the governed maintenance model for skill-shaped artifacts. The remaining
gap is maturity: not every artifact should carry the same documentation and
verification burden, but mature artifacts need durable intent, backlog tracking,
and agent-facing edit rules.

The `skill-directory-sync` tool is the first clear example. It is not a skill or
pack, but it has a behavior contract in `scripts/skill-directory-sync/SPEC.md`,
tests, and a backlog surface for future features such as human-friendly console
output. That pattern should be explicit so future tools and complex skills do
not drift into undocumented behavior.

## Decision

We will classify repository artifacts by maturity level and apply governance
requirements according to artifact type and maturity.

Backlog ownership is hybrid:

- durable product intent lives in repository docs such as ADRs, `SPEC.md`,
  `README.md`, and `ROADMAP.md`
- concrete implementation slices live in GitHub issues and pull requests
- AI agents must read the relevant maturity policy and artifact contract before
  changing mature behavior

## Maturity Levels

| Level | Name | Meaning | Minimum maintenance contract |
| --- | --- | --- | --- |
| L0 | Experimental | Scratch, imported, or exploratory artifact with no stability promise | Clear local purpose or issue context; no release promise |
| L1 | Usable | Works for personal use and may be synced or invoked by agents | Entrypoint docs, ownership signal, and required manifest files for the artifact type |
| L2 | Maintained | Recurring use, stable behavior, or tool-like behavior that future agents may change | Durable behavior contract, tests or verification notes, and linked backlog |
| L3 | Released/Critical | Registry-managed, pack-managed, safety-sensitive, or broadly reused artifact | Release evidence, changelog or roadmap, stronger verification, and explicit change gates |

Maturity is not permanent. Artifacts can be promoted when they become reused or
safety-sensitive, and demoted when they are intentionally deprecated or archived.
Promotion is a documentation and verification decision, not only a code move.

## Artifact Policy

### Root Skills

Root skills under `skills/<name>/` remain governed by ADR-0002.

- L1 root skills require `SKILL.md`, `metadata.json`, and an entry in
  `skill-registry.json` when registry-managed.
- L2 root skills should add `CHANGELOG.md` and `README.md` when they evolve over
  time, are imported, are source-contract-heavy, or act as maintainer guidance.
- L2 root skills may add `SPEC.md` only when the skill behaves like a tool,
  complex workflow, or policy contract that needs durable scope semantics.
- L3 root skills require release and validation evidence appropriate to their
  risk, but should still keep `SKILL.md` compact.

### Pack-Bundled Skills

Pack-bundled skills follow ADR-0002 and version with their containing pack unless
explicitly promoted to root skills.

- L1 bundled skills require `SKILL.md`, `metadata.json`, and `kind: "skill"` in
  the containing `pack.json`.
- L2/L3 maintenance evidence usually belongs at the pack level unless the skill
  is being promoted.

### Cursor Packs

Registry-managed Cursor packs are L3 by default because they install runtime
assets and already have a richer release contract.

They continue to require:

- `README.md`
- `CHANGELOG.md`
- `VERIFICATION.md`
- `RELEASE-POLICY.md`
- `ROADMAP.md`
- validation through `scripts/cursor-pack-verify.sh`

Experimental packs may begin below L3 only when they are not registry-managed and
are clearly marked as local or exploratory.

### Scripts And Tools

Scripts under `scripts/` start at L1 when they are small helpers and become L2
when they have stable user-facing behavior, safety-sensitive filesystem effects,
or recurring backlog.

L2 scripts/tools should have:

- usage in the script header or a companion README
- `scripts/<tool>/SPEC.md` for behavior, safety, output, and non-goals
- tests or documented verification under `scripts/<tool>/tests/`
- future-work or backlog links for planned behavior changes

The `skill-directory-sync` tool is the reference L2 script pattern.

### Repository Guidance

Repository-level guidance such as `AGENTS.md`, `.cursor/rules/`, and local
maintainer skills provides the operational routing for this ADR.

Agents should:

1. identify the artifact type before editing
2. determine the artifact maturity level from this ADR and local docs
3. read the relevant `SPEC.md`, README, ROADMAP, ADR, or GitHub issue
4. update the durable contract before changing mature behavior
5. add or update tests, validation notes, or release evidence according to level

## Backlog Model

Backlog items should not live only in prose comments or chat history.

- Use GitHub issues for concrete implementation slices.
- Use `SPEC.md` future-work sections for script/tool behavior proposals.
- Use pack `ROADMAP.md` files for pack-level roadmap items.
- Use skill `README.md` or `CHANGELOG.md` only for maintainer context and
  release history, not as a substitute for issue tracking.
- Link issues from durable docs when a future change is already known.

For example, a proposed `skill-directory-sync --pretty` flag should be tracked as
a GitHub issue and referenced from `scripts/skill-directory-sync/SPEC.md` until
it is specified, tested, and implemented.

## Rationale

A uniform policy would either under-govern mature tools or overburden small
skills. A maturity ladder lets the repository keep cheap authoring for simple
artifacts while still creating clear contracts for artifacts that agents and
humans repeatedly modify.

This model also separates intent from execution. ADRs and specs explain what an
artifact is allowed to become; issues and PRs track the next change. That split
is important for AI agents because it gives them stable context before they
start editing and avoids treating a single issue comment as the entire product
definition.

## Consequences

### Positive

- Mature tools and packs get clear behavior contracts before feature work.
- Agents have a predictable route for deciding which docs to read and update.
- Backlog items become traceable without forcing every idea into an ADR.
- The existing `skill-directory-sync` pattern becomes reusable.
- Small skills can remain lightweight until they actually need more governance.

### Negative

- Maintainers must decide maturity level before changing ambiguous artifacts.
- Some existing scripts may need follow-up specs or tests as they become L2.
- Docs and GitHub issues can drift if links are not updated during implementation.

### Neutral

- This ADR does not require every root skill to gain a `SPEC.md`.
- This ADR does not change ADR-0001 release tags or ADR-0002 skill packaging.
- Validation can grow incrementally instead of enforcing every rule immediately.

## Alternatives Considered

| Option | Pros | Cons | Why rejected |
| --- | --- | --- | --- |
| Require the same files for every artifact | Simple rule, easy to audit | Creates boilerplate for small skills and experiments | Too heavy for a personal multi-surface repo |
| Use only GitHub issues for backlog | Low repository churn, visible execution | Product intent becomes scattered across issue comments | Too weak for durable agent guidance |
| Use only repo ROADMAP files | Offline and reviewable | Harder to slice execution and discuss individual changes | GitHub issues are better for implementation tracking |
| Keep current informal model | No migration cost | Future tools can drift without specs or tests | Already showing strain around script/tool evolution |

## Implementation Notes

Adopt this ADR through documentation and agent guidance first:

1. Add a practical workflow spec at
   `docs/specs/artifact-maintenance-workflow.md`.
2. Update `AGENTS.md` so agents route through maturity checks before editing.
3. Update the `skill-studio-maintain` bundled skill (in the
   `cursor-skill-studio` Cursor pack, formerly the `personal-skill-maintainer`
   root skill per ADR-0005) to include ADR-0003.
4. Add or update Cursor rules when deterministic agent direction is useful.
5. Seed `skill-directory-sync` with a linked backlog item for `--pretty`.

## Validation Strategy

This ADR is implemented when:

- `docs/ADR/README.md` indexes ADR-0003
- `AGENTS.md` points agents to the maturity workflow
- `docs/specs/artifact-maintenance-workflow.md` explains how to apply the model
- maintainer skill guidance references ADR-0003
- `skill-directory-sync` has a tracked future-work item for `--pretty`

## References

- ADR-0001: `docs/ADR/ADR-0001-registry-driven-releases-for-skills-and-packs.md`
- ADR-0002: `docs/ADR/ADR-0002-governed-skill-maintenance-model.md`
- `docs/specs/artifact-maintenance-workflow.md`
- `scripts/skill-directory-sync/SPEC.md`
- `scripts/skill-directory-sync/tests/run-tests.sh`
- `AGENTS.md`
- `packs/cursor-skill-studio/skills/skill-studio-maintain/SKILL.md`
  (consolidates the former `skills/personal-skill-maintainer` and
  `skills/personal-pack-maintainer` root skills per ADR-0005)

## Changelog

| Date | Author | Change |
| --- | --- | --- |
| 2026-05-19 | felipeblassioli | Initial draft |
