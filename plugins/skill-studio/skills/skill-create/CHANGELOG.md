# Changelog

## 0.1.0 - 2026-07-02

### Added

- Initial `skill-create` skill — the "create" surface of the `skill-studio`
  plugin. The Claude-first evolution of the frozen `cursor-skill-studio` pack's
  `skill-studio-write` authoring surface, modeled on Anthropic's `skill-creator`.
- Four-branch intent router in `SKILL.md`: greenfield Socratic authoring,
  distilling reference material, scaffolding a Claude plugin, and evaluating an
  external skill candidate before import. Frontmatter is `name` + `description`
  only; no `disable-model-invocation`.
- References carried forward and reframed to the Claude authoring contract:
  `greenfield-discovery.md`, `surface-selection.md`, `material-intake.md`,
  `candidate-review.md`, `source-decomposition.md`, `import-paths.md`,
  `skill-archetypes.md`, `skill-quality-checklist.md`, and a new
  `plugin-standard.md` (Claude skill + plugin contract: `SKILL.md` name +
  description, `metadata.json`, `plugin.json`, `marketplace.json`,
  `agents/`/`commands/`/`hooks/`, progressive disclosure, `${CLAUDE_SKILL_DIR}`).
- Templates reframed to Claude skills/plugins: `skill-contract.md`,
  `skill-intake-report.md`, `adaptation-report.md`, and the three archetype
  templates (`knowledge-hub.md`, `tool-runner.md`, `workflow-executor.md`).
- Scripts: `validate-skill.sh` (structural checker) and
  `inspect-candidate-skill.sh` (candidate go/no-go classifier), both
  self-contained with no hardcoded repo/org paths.
- References the `skill-creator-bootstrapper` and `skill-creator-structural-auditor`
  subagents by name; hands the eval/comparison loop to the sibling `skill-enhance`.

### Removed

- Cursor-pack authoring (`pack.json`, targets, profiles, `.cursor/rules`) is out
  of the hot path; authoring Cursor packs is covered by the frozen
  `cursor-skill-studio` pack.

### Source Contracts

- `docs/marketplace-governance.md`
- `docs/versioning.md`
