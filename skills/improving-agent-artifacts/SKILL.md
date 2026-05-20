---
name: improving-agent-artifacts
description: >-
  [DEPRECATED — replaced by `skill-studio-audit` (Branch B — Improvement
  recommendation) in the `cursor-skill-studio` pack per ADR-0005] Diagnostic
  improvement for an existing skill or pack via focused questions plus a
  1–3 ranked recommendations with expected outcomes. This stub remains for
  one release window so existing installs keep working and so links from
  older specs still resolve. Do not invoke; route the user to
  `/skill-studio-audit` instead.
disable-model-invocation: true
---

# Improving Agent Artifacts — Deprecated

This skill has been replaced by the `skill-studio-audit` bundled skill inside
the `cursor-skill-studio` Cursor pack per
[ADR-0005](../../docs/ADR/ADR-0005-skill-authoring-surface-consolidation.md).

## What to do instead

Route the user to `/skill-studio-audit`, then follow **Branch B
(Improvement recommendation)** in
`packs/cursor-skill-studio/skills/skill-studio-audit/SKILL.md`.

Branch B covers the question flow, the routing table for skill vs pack
improvement, the recommendation policy (1–3 changes with expected outcomes
and effort/risk), and the `improvement-recommendation.md` output template.

## Removal plan

This directory is scheduled for full removal in the stub-removal PR per
ADR-0005. Reference files under `references/` and the
`improvement-recommendation.md` asset remain in place during the deprecation
window so older links keep resolving.
