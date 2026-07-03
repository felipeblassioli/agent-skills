# Source Adaptation Report

Use this when decomposing a mixed source tree (an external plugin folder, a
skill folder, or a pile of files) into Claude-native artifacts.

- Candidate path: `<path>`
- Desired target name: `<name or unknown>`
- Source shape: `<plugin-tree | skill-folder | docs-only | unknown>`
- Recommended shape: `<standalone-skill | plugin-with-one-skill | plugin-with-multiple-surfaces | docs-only>`
- Tier: `<sandbox | official>`
- Classification: `<ready-to-adapt | adapt-with-review | stop-and-rework>`

## Source Classification

- Skill guidance: `<paths or none>`
- Subagent candidates: `<paths or none>`
- Command candidates: `<paths or none>`
- Hook candidates: `<paths or none>`
- MCP config: `<example-only after ${env:VAR} scrub | docs | ignore>`
- Docs / human-only: `<paths or none>`
- Excluded (cache/generated/secrets/vendor-only): `<paths or none>`

## Recommended Destination Paths

- Skill(s): `<plugins/<plugin>/skills/<name>/ or none>`
- Subagents: `<plugins/<plugin>/agents/<name>.md or none>`
- Commands: `<plugins/<plugin>/commands/<name>.md or none>`
- Hooks: `<plugins/<plugin>/hooks/ or none>`
- Docs / references: `<path or none>`

## Blocking Concerns

- `<issue or none>`

## Migration Notes

- `<why this decomposition is the smallest correct shape>`
- `<how to treat MCP trust and portability>`
- `<which cross-refs must become by-name handoffs or ${CLAUDE_SKILL_DIR} paths>`
- `<whether another vendor's command UX should be adapted or dropped>`

## MVP Next Step

- `<smallest safe next action>`
