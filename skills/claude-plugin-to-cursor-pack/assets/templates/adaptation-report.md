# Claude Plugin Adaptation Report

- Candidate path: `<path>`
- Desired target name: `<name or unknown>`
- Source shape: `<claude-plugin | mixed-plugin-folder | docs-only | unknown>`
- Recommended shape: `<pack-only | skill-only | pack-plus-repo-skills | pack-with-bundled-skills | docs-only>`
- Classification: `<ready-to-adapt | adapt-with-review | stop-and-rework>`

## Source Classification

- Manifest: `<pack-runtime | claude-only | docs-reference | ignore>`
- MCP config: `<pack-runtime | docs-reference | ignore>`
- Workflow skills or prompts: `<skill-guidance | docs-reference | ignore>`
- Runtime-only assets: `<paths or none>`
- Guidance assets: `<paths or none>`
- Excluded assets: `<paths or none>`

## Recommended Destination Paths

- Pack assets: `<packs/<name>/... or none>`
- Repo-root companion skills: `<skills/<name>/... or none>`
- Pack-bundled skills: `<packs/<name>/skills/<folder>/... + pack.json kind: skill or none>`
- Docs or references: `<path or none>`

## Blocking Concerns

- `<issue or none>`

## Migration Notes

- `<why this decomposition is the smallest correct shape>`
- `<how to treat MCP trust and portability>`
- `<whether Claude-only command UX should be preserved, adapted, or dropped>`

## MVP Next Step

- `<smallest safe next action>`
