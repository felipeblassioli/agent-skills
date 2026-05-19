# Skill Consistency Auditor Pack

This Cursor pack installs a read-only auditing workflow to help you keep `~/.agents/skills/` and `~/.cursor/skills/` clean, composable, and aligned with `docs/architecture.md`.

## Contents

- **Bundled skill:** `/skill-consistency-auditor-workflow`
- **Subagent:** `skill-overlap-clusterer` (groups skills heuristically by problem domain)
- **Subagent:** `skill-architecture-checker` (validates skills against repository architecture rules)
- **Subagent:** `skill-consolidation-advisor` (scores overlaps and proposes fixes)

## When to Use

Use the `/skill-consistency-auditor-workflow` explicit skill when:
- you notice agents picking the wrong skill
- you suspect a new skill overlaps with an existing one
- you have migrated a large batch of skills and need to clean up aliases or duplicates

The pack does not automatically delete skills; it surfaces structural drift and proposes explicit consolidation paths.
