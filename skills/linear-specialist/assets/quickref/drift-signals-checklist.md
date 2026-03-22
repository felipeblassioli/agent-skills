# Drift Signals Checklist

Use this checklist when asking why a Linear board feels stale, noisy, or out of
sync.

## Project Framing Drift

- project description still describes an earlier phase of work
- project says repo is canonical but issues still hold stale design truth
- project status does not match the dominant state of its issues
- project contains workstreams that no longer belong together

## Hierarchy Drift

- parent issues have no meaningful child structure
- child issues are broader than their parent should allow
- standalone issues obviously belong under an epic or story tree
- issue tree exists, but current execution happens outside it

## Label Drift

- labels overlap heavily in meaning
- labels restate status instead of adding signal
- readiness labels are applied to under-shaped issues
- labels no longer influence triage or action

## Status Drift

- Todo is acting like backlog
- In Progress contains parked or abandoned work
- Done issues still represent active central work
- review states are skipped or semantically unclear

## Progress Drift

- issue status suggests active work, but recent evidence is weak or ambiguous
- issue description still frames work as future, but major pieces already exist
- issue says implementation is bounded, but repo reality suggests scope changed
- code or docs imply a follow-up split that Linear does not yet capture

## Documentation Drift

- issue references canonical docs that are missing, stale, or superseded
- project and issue descriptions disagree about source of truth
- acceptance criteria no longer match current architecture or implementation shape
- comments carry newer truth than the issue body

## Agent-Readiness Drift

- issue is labeled ready but requires guessing
- blockers or decisions are implied rather than explicit
- next executable action is unclear
- validation expectations are missing or outdated

## Cleanup Action Prompts

After spotting drift, ask:

- should this issue be reparented, split, or archived?
- should the status change?
- should labels be removed, renamed, or applied differently?
- should the issue body be rewritten to match current reality?
- should this become a project, epic, story, or follow-up issue?
- should this be marked blocked or decision-needed?
