# Release Policy

This pack follows the repository's governed maintenance model (ADR-0002) and maturity model (ADR-0003).

## Versioning Rules

- **Major**: Breaking changes to the install manifest shape or the removal of core subagents.
- **Minor**: New subagents, new profiles, or significant workflow expansions.
- **Patch**: Trigger fixes, prompt tweaks in the subagents, or documentation updates.

## Verification Requirements

Before tagging a release, you must:
1. Run `bash scripts/cursor-pack-verify.sh --pack=skill-consistency-auditor`
2. Test the auditor workflow on a real directory.
3. Update `VERIFICATION.md` with the run results.
4. Document the changes in `CHANGELOG.md` and review `ROADMAP.md` for remaining priorities.
