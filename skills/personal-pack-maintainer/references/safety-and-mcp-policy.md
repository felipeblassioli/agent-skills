# Safety and MCP Policy

## MCP policy

A pack MUST declare its `mcpPolicy`:

- `none`         — pack does not manage MCP configuration.
- `example-only` — pack may install example MCP configuration but MUST NOT promote it to live `mcp.json` automatically.

**Invariant:** the install path NEVER writes a live `mcp.json`. MCP examples ship as `mcp.example.json` (or under `assets/`) and require an explicit, separate user step to activate. MCP servers can access external systems and credentials; activation is a trust decision outside the pack installer.

## Hook policy

Hooks installed via packs MUST be:

- **bounded** — match a narrow set of events / file globs / command patterns,
- **inspectable** — small enough to read end-to-end without context loss,
- **explained** — purpose documented in the pack `README.md` and/or hook script header.

Reject hooks that:

- block broad command classes without a clear allowlist exception,
- exfiltrate file contents or run network calls,
- silently mutate user state outside `.cursor/` and the documented install paths.

## Project vs user invariants

- Project rules (`.cursor/rules/*.mdc` encoding repo policy) MUST stay project-only — declare them on `project-cursor` targets only, never `user-cursor`.
- Reusable subagents/skills/hooks MAY target both, but the pack must justify why they are safe at user scope.
- A bundled skill destined for global use SHOULD have a pack-scoped `skillId` to avoid colliding with shared `~/.cursor/skills/`.

## Bundled-skill safety

- Bundled skill bodies MUST stay skill-shaped under `packs/<pack>/skills/<skillId>/`.
- Do NOT duplicate a bundled skill's content into `.cursor/rules/`, hooks, or README prose. Duplication breaks update authority and inflates context.

## Install path safety

- Runtime artifacts MUST declare explicit `projectPath` / `userPath`. No implicit destinations.
- Installer must back up conflicts (`backupOnConflict: true`) and write a manifest (`manifestFile: ".cursor-pack-manifest.json"`) so restore is possible.
- Never recommend running `cursor-pack-sync.sh` without first doing `--dry-run` on a clean working tree.

## Common safety findings to flag

- Hook with `command: "*"` or no `matcher`.
- `mcpPolicy: "live"` (not a supported value — reject).
- Project rule artifact installed via `user-cursor`.
- Bundled skill duplicated into `.cursor/rules/` "for discoverability".
- Pack stages files outside `.work/cursor-pack-staging/` or writes backups outside `.work/cursor-pack-backups/`.
