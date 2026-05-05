# Pack Authoring Checklist

Use this checklist when creating or revising anything under `packs/`.
For the full contract, see `docs/specs/cursor-pack-specification.md`. For
install and upgrade guidance, see `docs/guides/cursor-packs.md`.

## Fit

- [ ] I can explain in one sentence why this should be a pack and not only a skill.
- [ ] The pack value is primarily runtime capability, installation shape, or reusable operating mode.
- [ ] The pack has one coherent runtime purpose rather than unrelated bundled assets.

## Runtime Boundary

- [ ] I separated guidance concerns from runtime concerns.
- [ ] Any related skill teaches usage or routing rather than mirroring pack contents.
- [ ] The pack does not become a document dump for material better expressed as a skill.
- [ ] Bundled skills are not duplicated into `.cursor/rules`, hooks, or README;
  they stay skill-shaped under the pack's `source` tree.

## Install Shape

- [ ] If this pack is installable, it is registered in `cursor-pack-registry.json`.
- [ ] Registry-managed packs include `README.md`, `CHANGELOG.md`,
  `VERIFICATION.md`, `RELEASE-POLICY.md`, and `ROADMAP.md`.
- [ ] Targets are explicit and correct.
- [ ] Profiles map to real operating modes, not vague labels.
- [ ] Artifacts are grouped by runtime responsibility.
- [ ] User-target and project-target behavior are clearly separated.
- [ ] Runtime artifacts define `projectPath` for `project-cursor` targets and
  `userPath` for `user-cursor` targets.
- [ ] Any bundled skills use `kind: "skill"` with an explicit, pack-scoped
  `skillId` (see `docs/specs/agentic-skill-pack-authoring.md`).
- [ ] Bundled skill install paths (`.cursor/skills/` vs `~/.cursor/skills/`) are
  documented in the pack README when the pack ships skills.

## Safety and Policy

- [ ] Hook behavior is understandable and narrow.
- [ ] MCP examples remain examples and are never treated as live config by default.
- [ ] Project-only assets remain project-only.
- [ ] The pack does not encourage hidden escalation or broad trust assumptions.

## Docs and Discoverability

- [ ] `pack.json` makes the install contract obvious.
- [ ] The README explains purpose, targets, and profiles without duplicating every asset.
- [ ] Runtime caveats are documented where the installer or user will actually need them.
- [ ] The top-level docs are compact enough to stay readable and cheap.

## Delegation and Authoring Process

- [ ] I used cheaper agents first for inventory, comparison, and audit work.
- [ ] I reserved the primary agent for synthesis and final decisions.
- [ ] I asked subagents for bounded findings rather than long narratives.
- [ ] Not every agent had to read the same runtime corpus.

## Validation

- [ ] I validated the pack for the relevant target and profile combinations.
- [ ] I checked for collisions between rules, hooks, agents, and examples.
- [ ] I verified that install behavior matches the documented contract.
- [ ] I confirmed that safe defaults remain safe after installation.

## Final Readiness

- [ ] A future editor can tell where to add a new runtime artifact.
- [ ] The pack remains coherent as it evolves.
- [ ] The artifact is installable, bounded, and clear about what it does not manage.
