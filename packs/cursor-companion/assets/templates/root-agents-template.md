# Project Agent Guide

Use this file for repository-wide invariants and routing hints.

## Repo overview

- summarize the repo shape in 2-4 bullets
- name the main top-level workspaces or product areas

## Shared commands

- install: `...`
- test: `...`
- lint: `...`
- build: `...`

## Architecture boundaries

- list the import or dependency boundaries that always apply
- note generated or vendor-managed paths that must not be edited

## Routing hints

- if working in `apps/...`, read that subtree's `AGENTS.md` if present
- if the task is cross-cutting policy, consult `.cursor/rules/*.mdc`
- if the task requires reusable methodology, use the matching `skill`

## Workflow constraints

- branch or PR conventions
- validation expectations before commit or PR

## Keep out of this file

- subtree-specific runbooks
- language-specific guidance already covered by `.cursor/rules`
- long design docs or handbooks
