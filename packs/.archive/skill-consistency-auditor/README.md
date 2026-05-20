> **Deprecated — superseded by `cursor-skill-studio` (`skill-studio-audit`) per
> [ADR-0005](../../docs/ADR/ADR-0005-skill-authoring-surface-consolidation.md).**
> This pack still installs through `0.2.0` for one release window so existing
> installs keep working. Use `/skill-studio-audit` (Branch C — Installed
> portfolio audit) instead. The pack is scheduled to move to
> `packs/.archive/skill-consistency-auditor/` in the stub-removal PR.

# Skill Consistency Auditor Pack

This Cursor pack installs a read-only auditing workflow to help you keep
`~/.agents/skills/` and `~/.cursor/skills/` clean, composable, and aligned
with `docs/architecture.md`.

## Replacement

The functionality of this pack is fully covered by the `skill-studio-audit`
bundled skill in `cursor-skill-studio`:

- The `/skill-consistency-auditor-workflow` is now a redirect stub.
- The three subagents (`skill-overlap-clusterer`,
  `skill-architecture-checker`, `skill-consolidation-advisor`) are duplicated
  inside `cursor-skill-studio/.cursor/agents/` and remain functional there.
- The previously broken `assets/report-template.md` path is now installed at
  `.cursor/skills/skill-studio-audit/assets/templates/portfolio-audit-report.md`.

Install `cursor-skill-studio` and invoke `/skill-studio-audit` instead of this
pack going forward.

## Contents (legacy)

- **Bundled skill:** `/skill-consistency-auditor-workflow` (redirect stub).
- **Subagent:** `skill-overlap-clusterer` (groups skills heuristically by
  problem domain).
- **Subagent:** `skill-architecture-checker` (validates skills against
  repository architecture rules).
- **Subagent:** `skill-consolidation-advisor` (scores overlaps and proposes
  fixes).

The pack does not automatically delete skills; it surfaces structural drift
and proposes explicit consolidation paths.
