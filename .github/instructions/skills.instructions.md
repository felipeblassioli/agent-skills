---
applyTo: "skills/**"
---

Review changes under `skills/` as installable skill packages, not as generic markdown edits.

For a newly added or renamed skill, verify the package contract:
- `SKILL.md` exists at the skill root.
- `metadata.json` exists at the skill root.
- `skill-registry.json` contains a matching entry for the skill.

Review `SKILL.md` frontmatter carefully:
- It must start with `---`.
- `name` must exactly match the folder name and use lowercase letters, numbers, and hyphens only.
- `description` should be non-empty, written in third person, and clearly say WHAT the skill does and WHEN to use it using terms a user would actually say.

Review skill quality, not just structure:
- `SKILL.md` should act as a dispatcher and stay concise. Prefer routing to focused files in `references/`, `assets/`, or `scripts/` instead of dumping everything into one file.
- Supporting files should be linked directly from `SKILL.md`. Flag deep reference chains, vague routing, or generic filler that the model already knows.
- Prefer concrete, domain-specific examples over abstract pseudocode.
- Flag descriptions or names that are vague, generic, or misleading.

Mirror the checks from `skills/create-skill-from-refs/scripts/validate-skill.sh` and the authoring checklist:
- broken relative links from `SKILL.md`
- empty directories
- Windows-style paths in markdown
- non-executable shell scripts under `scripts/`
- `SKILL.md` approaching or exceeding the 500-line limit
- secrets, credentials, or unsafe instructions in skill content

For standard skills, prefer structures like `skills/kysely-typescript/SKILL.md`: an applicability gate, direct routing table, short procedure, and confirmation policy for risky actions.

In PR review, ask for evidence when it is missing. For skill additions or substantial rewrites, expect validation such as:
- `bash skills/create-skill-from-refs/scripts/validate-skill.sh skills/<name>`
- `bash scripts/skill-sync.sh --list` or `bash scripts/skill-sync.sh --dry-run`

If a PR changes skill content but also includes unrelated registry, build, or repo-config edits, flag the scope creep.
