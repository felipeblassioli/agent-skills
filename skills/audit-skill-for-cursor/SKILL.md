---
name: audit-skill-for-cursor
description: >-
  [DEPRECATED — replaced by `skill-studio-audit` (Branch A — Single-skill
  compliance audit) in the `cursor-skill-studio` pack per ADR-0005] Single-skill
  audit for context-efficient dispatchers, progressive disclosure, and cheap-
  agent delegation. This stub remains for one release window so existing
  installs keep working and so links from older specs still resolve. Do not
  invoke; route the user to `/skill-studio-audit` instead.
disable-model-invocation: true
---

# Audit Skill for Cursor — Deprecated

This skill has been replaced by the `skill-studio-audit` bundled skill inside
the `cursor-skill-studio` Cursor pack per
[ADR-0005](../../docs/ADR/ADR-0005-skill-authoring-surface-consolidation.md).

## What to do instead

Route the user to `/skill-studio-audit`, then follow **Branch A
(Single-skill compliance audit)** in
`packs/cursor-skill-studio/skills/skill-studio-audit/SKILL.md`.

Branch A covers the full single-skill audit procedure (Context Litmus Test,
trigger accuracy, progressive disclosure, strict outputs, cheap-agent
delegation), the per-ecosystem lenses (Cursor / Anthropic / Codex), and the
optional `skill-architecture-checker` spot-check.

## Removal plan

This directory is scheduled for full removal in the stub-removal PR per
ADR-0005. Reference files under `references/` remain in place during the
deprecation window so older links keep resolving.
