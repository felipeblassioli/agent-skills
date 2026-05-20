# Maturity and Backlog

Artifact maturity (L1–L3) determines how much documentation, testing, and
backlog discipline an artifact is expected to carry. The normative model
lives in ADR-0003; this reference is a thin pointer so maintainers do not
duplicate it inside the bundled skill.

## Authority

- [`docs/ADR/ADR-0003-artifact-maturity-model.md`](../../../../docs/ADR/ADR-0003-artifact-maturity-model.md)
  — maturity levels for root skills, pack-bundled skills, packs,
  scripts/tools, and repo-level guidance.
- [`docs/specs/artifact-maintenance-workflow.md`](../../../../docs/specs/artifact-maintenance-workflow.md)
  — practical workflow for backlog, specs, verification, and agent routing
  by maturity.

## Defaults to remember

- **Registry-managed packs** (anything listed in
  `cursor-pack-registry.json`) are **L3** by default and must keep
  `README.md`, `CHANGELOG.md`, `VERIFICATION.md`, `RELEASE-POLICY.md`, and
  `ROADMAP.md` aligned.
- **Root skills** listed in `skill-registry.json` should at least carry
  `SKILL.md`, `metadata.json`, and (for L2+) `CHANGELOG.md` and `README.md`.
- **Pack-bundled skills** version with the parent pack; their maturity is
  inherited from the pack (L3 if the pack is registry-managed).
- **Maintained scripts/tools** under `scripts/` are L2+ when they have a
  `SPEC.md`, tests under `scripts/<tool>/tests/`, and linked GitHub issues
  for concrete backlog slices.

## Backlog placement

| Topic | Where it lives |
|---|---|
| Durable product direction for a pack | `packs/<pack>/ROADMAP.md` |
| Concrete implementation slices | GitHub issues (linked from `ROADMAP.md` when they affect direction) |
| Cross-cutting governance decisions | `docs/ADR/ADR-XXXX-*.md` |
| Repo-level workflow changes | `docs/specs/<topic>.md` |
| Per-artifact spec for scripts | `scripts/<tool>/SPEC.md` |

If a backlog item changes durable product direction for any maintained
artifact, link the issue from `ROADMAP.md` (pack), `SPEC.md` (script), or
the relevant ADR. Do not let durable direction live only in chat or only in
GitHub issues.

## When to bump maturity

Promote an artifact to a higher maturity level (and accept its documentation
overhead) when one of the following becomes true:

- Other people start depending on its behavior.
- A release is published / a tag is cut / the artifact lands in a registry.
- A bug surfaces that would have been caught by tests or a SPEC.
- The artifact's scope grows beyond what fits in a single SKILL.md or
  README.

Demoting (or archiving) is also a maintenance decision; route it through the
same confirmation gate as a version bump.
