# Skill Package Model

## Root Skills

Root skills live under `skills/<name>/`. The package shape MUST follow this model:

```text
skills/<name>/
├── SKILL.md        (Required)
├── metadata.json   (Required)
├── CHANGELOG.md    (Expected if listed in skill-registry.json)
├── README.md       (Recommended for human usage/maintained skills)
├── references/     (Optional: detailed guidance out of hot path)
├── assets/         (Optional: templates, checklists)
└── scripts/        (Optional: deterministic tools)
```

### File Responsibilities
- `SKILL.md`: The agent hot path. Contains trigger surface, applicability gate, anti-triggers, short procedure, and routing. Do NOT carry long maintenance history here.
- `metadata.json`: Machine-readable metadata (`version`, `author`, `date`, `abstract`, and optional provenance). Prefer ISO dates.
- `CHANGELOG.md`: Human-readable release history (Keep a Changelog style).
- `README.md`: Human usage and maintainer guide.

### SKILL.md Frontmatter

Default frontmatter stays light. ONLY include `name` and `description`.

```yaml
---
name: skill-name
description: Use when ...
---
```

Do NOT include `version` or `last_reviewed` in the frontmatter unless it materially improves routing or provenance.
