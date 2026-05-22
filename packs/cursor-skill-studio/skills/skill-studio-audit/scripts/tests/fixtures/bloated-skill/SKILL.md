---
name: bloated-skill
description: >-
  Performs detailed end-to-end project reporting across multiple repositories,
  including initial scoping, environment detection, dependency analysis, build
  configuration, runtime checks, and final summary generation. Use when the
  user mentions reporting, status, summaries, dashboards, repo health, build
  health, dependency reports, or quarterly reviews. Do not use when the user
  only wants a quick check (use clean-skill instead) or when the request is
  about installation, governance, or release tagging. Invoke explicitly via
  /bloated-skill so the routing layer attaches the right context window. This
  skill exists to demonstrate description bloat for the hot-path auditor
  fixture and intentionally exceeds the description_warn threshold of 500
  characters so the snapshot test can verify the warn-tier finding fires.
disable-model-invocation: true
---

# Bloated Skill

A fixture demonstrating prompt-visible bloat. Contains an Applicability
Gate whose first bullet mirrors the description, plus a body heading
that also appears in the description.

## Applicability Gate

- Performs detailed end-to-end project reporting across multiple repositories.
- Triggers on reporting, status, summaries, dashboards.

## Initial scoping environment detection dependency analysis

This heading repeats a long phrase already present in the description to
exercise the description_repeats_body_heading bucket.

## Procedure

1. Do thing.
2. Do other thing.
