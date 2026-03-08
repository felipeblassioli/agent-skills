---
applyTo: "packs/**,cursor-pack-registry.json,scripts/cursor-pack-*.sh"
---

Review changes under `packs/` and the cursor-pack registry/scripts as installable runtime packaging, not as generic docs or JSON edits.

When a PR adds or changes a pack, verify the packaging contract:
- `cursor-pack-registry.json` contains a matching pack entry with the right `path`, `targets`, `profiles`, and description.
- `packs/<name>/pack.json` exists and its `name` and `version` match the registry entry.
- artifact `source` paths in `pack.json` exist and only reference targets and profiles the pack declares.

Mirror the high-signal checks from `scripts/cursor-pack-verify.sh`:
- required release artifacts exist: `CHANGELOG.md`, `VERIFICATION.md`, `RELEASE-POLICY.md`, `ROADMAP.md`
- subagent markdown starts with valid frontmatter and includes required fields
- rules files under `.cursor/rules` have frontmatter and stay under 500 lines
- hook config JSON is valid and referenced hook scripts exist and are executable
- MCP example JSON is valid and does not contain hardcoded secrets
- pack content avoids machine-specific absolute paths, personal usernames, or real credentials

Treat pack changes as operationally sensitive:
- flag install-policy drift between `cursor-pack-registry.json` and `pack.json`
- flag artifacts that would install to unsupported locations
- flag hooks or MCP examples that exceed the pack's stated safety posture
- flag missing validation evidence such as `bash scripts/cursor-pack-verify.sh --pack=<name>`

If a PR mixes pack packaging changes with unrelated skill or repo-policy edits, call out the scope issue unless the coupling is necessary and explained.
