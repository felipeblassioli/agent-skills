---
applyTo: "skill-registry.json,scripts/*.sh"
---

Review `skill-registry.json` and skill-management scripts as part of the installable packaging contract for the repository.

When a PR adds or changes a skill, verify registry consistency:
- the skill key matches the folder name
- `metadata.json.version` matches the registry version
- `description`, `targets`, `scope`, and `tags` fit the actual skill content
- `path` is present only when the skill is not stored at `skills/<name>/`

Flag registry drift aggressively:
- new skill files without a registry entry
- registry entries that describe capabilities the skill does not actually provide
- version changes without matching metadata updates
- packaging or deployment script changes that silently alter skill behavior without PR explanation

When reviewing `scripts/skill-import.sh`, `scripts/skill-sync.sh`, or `scripts/skill-version.sh`, focus on whether they preserve the required contract from `AGENTS.md` and `skill-registry.json`.

Treat packaging changes as high-impact. If a PR mixes skill content edits with unrelated registry or script changes, call out the scope issue unless the coupling is necessary and explained.
