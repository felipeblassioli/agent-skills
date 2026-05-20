# Release Artifacts

Every registry-managed pack MUST commit and maintain these top-level files. `scripts/cursor-pack-verify.sh` enforces their existence.

## `CHANGELOG.md`

- Format: Keep a Changelog.
- One entry per released version. Newest at top.
- Reference the bumped pack version (matches `pack.json` and registry).
- Group changes: `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`.
- Mention any important contract assumptions or validation notes re-checked during the release.

## `VERIFICATION.md`

Release evidence. For each released version, capture:

- commands run (verifier + dry-runs for every relevant target/profile),
- key output snippets (what the dry-run proved),
- backup/restore probe results when the install touches existing files,
- what the release explicitly did NOT verify (gaps).

This is the artifact a reviewer reads to trust the release.

## `RELEASE-POLICY.md`

Per-pack release rules:

- which target/profile combinations must be verified before tag,
- who can authorize a release (single maintainer is fine for personal repo),
- when a major bump is required (breaking artifact id/path/profile changes, hook/MCP policy changes, target removal),
- the commit/PR shape required (keep pack content changes focused; avoid mixing unrelated pack, skill, and build changes).

## `ROADMAP.md`

Forward-looking notes:

- next planned bump and its scope,
- known follow-ups such as uninstall, restore hardening, or schema-validation improvements,
- deprecations to land in the next minor/major.

Keep it short. Roadmap items that have shipped move into `CHANGELOG.md`.

## Release tag

Independent versioning per pack. Use:

```text
pack-<name>@<version>
```

Examples: `pack-cursor-companion@1.4.0`, `pack-node-test-verifier@0.3.1`.

GitHub Releases are the publication record. Pack release archives SHOULD use a stable top-level folder (`pack-<name>/...`).

## Release-time invariants (cross-checks)

- `pack.json.version` == `cursor-pack-registry.json.packs.<name>.version` == `CHANGELOG.md` newest entry.
- `VERIFICATION.md` includes commands run for the new version, not stale evidence from an earlier release.
- The release commit stays focused on the pack change, and the PR targets `felipeblassioli/agent-skills`.
