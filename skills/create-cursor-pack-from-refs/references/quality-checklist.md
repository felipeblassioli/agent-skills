# Quality Checklist for Cursor Packs

Run this checklist after scaffolding a pack and before presenting it for final
review.

## Structural checks

- [ ] `packs/<name>/pack.json` exists
- [ ] `packs/<name>/README.md` exists
- [ ] every created directory contains at least one file
- [ ] `pack.json.name` matches the folder name exactly
- [ ] `pack.json.version` matches the registry version
- [ ] `cursor-pack-registry.json` points to the correct pack path

## Release artifact checks

- [ ] evolving packs include `CHANGELOG.md`
- [ ] evolving packs include `VERIFICATION.md`
- [ ] evolving packs include `RELEASE-POLICY.md`
- [ ] evolving packs include `ROADMAP.md`
- [ ] `CHANGELOG.md` points readers to verification evidence
- [ ] `VERIFICATION.md` records commands, outcomes, and diagnosis
- [ ] `scripts/cursor-pack-verify.sh` passes the release-artifact checks

## Artifact checks

- [ ] every artifact `source` exists
- [ ] every artifact has at least one target and one profile
- [ ] every artifact destination path matches the intended target surface
- [ ] only approved surfaces were scaffolded
- [ ] no empty `.cursor/agents`, `.cursor/rules`, `.cursor/hooks`, or `guides`
  directories remain

## Surface-specific checks

### Subagents

- [ ] each subagent file starts with YAML frontmatter
- [ ] each subagent has `name` and `description`
- [ ] optional `model`, `readonly`, and `background` values are valid

### Rules

- [ ] each rule starts with YAML frontmatter
- [ ] each rule has a `description`
- [ ] each rule is comfortably under 500 lines

### Hooks

- [ ] hook config files are valid JSON
- [ ] referenced hook scripts exist
- [ ] referenced hook scripts are executable
- [ ] pack-local hook commands are preferred

### MCP examples

- [ ] MCP example JSON is valid
- [ ] no real credentials are present
- [ ] `${env:VAR}` interpolation is used where secrets would otherwise appear
- [ ] the example stays example-only and does not pretend to be live config

## Recommendation metadata checks

- [ ] the pack's jobs-to-be-done are written down in machine-readable draft form
- [ ] included surfaces have explicit intent and activation mode
- [ ] `avoidWhen` or anti-fit conditions are documented
- [ ] target/profile recommendations are explicit enough for a future advisory
  MCP to reason about them

## Repo fit checks

- [ ] the pack does not auto-install itself
- [ ] the pack does not overwrite live `mcp.json`
- [ ] the pack does not encode machine-specific absolute paths
- [ ] the pack does not include personal usernames or local filesystem details
- [ ] operational guidance exists when the pack includes non-obvious trade-offs

## Verification

- [ ] `bash scripts/cursor-pack-verify.sh --pack=<name>` passes
- [ ] warnings are reviewed and either fixed or intentionally accepted
- [ ] any deferred schema work is captured outside the production pack contract
- [ ] release verification evidence is committed when the pack changed materially
