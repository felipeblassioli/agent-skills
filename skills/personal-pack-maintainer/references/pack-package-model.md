# Pack Package Model

## Location

```text
packs/<name>/
```

`<name>` MUST match `^[a-z0-9-]+$`.

## Required files (registry-managed pack)

```text
packs/<name>/
├── pack.json            (Required — install contract)
├── README.md            (Required — purpose, targets, profiles)
├── CHANGELOG.md         (Required — Keep a Changelog)
├── VERIFICATION.md      (Required — release evidence)
├── RELEASE-POLICY.md    (Required — release rules)
└── ROADMAP.md           (Required — next improvements)
```

`scripts/cursor-pack-verify.sh` currently enforces the four release artifacts. A pack missing any of them MUST NOT be tagged for release.

## Optional payload

```text
packs/<name>/
├── .cursor/agents/                # subagents
├── .cursor/rules/                 # project rules (project-cursor only)
├── .cursor/hooks/                 # hook scripts
├── .cursor/hooks.project.json     # project hooks
├── .cursor/hooks.user.json        # user hooks
├── .cursor/mcp.example.json       # MCP example (never live)
├── skills/<skillId>/              # bundled skills (kind: "skill")
├── guides/                        # user-facing guidance
├── assets/                        # templates, examples
└── scripts/                       # workflow helpers
```

## Draft vs registered

A pack directory is **draft** until it has an entry in `cursor-pack-registry.json`.

- Drafts MAY omit the four release artifacts while being designed.
- Drafts CANNOT be installed by `scripts/cursor-pack-sync.sh`.
- Promoting to installable means: add registry entry, ensure all required files exist, run `cursor-pack-verify.sh`.

## Anti-patterns

- Treating a pack as a documentation dump (use a skill instead).
- Mixing unrelated runtime concerns into one pack (split by coherent runtime purpose).
- Inlining a bundled skill's body into `.cursor/rules/` or `README.md` instead of leaving it skill-shaped under `skills/<skillId>/`.
