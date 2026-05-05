---
name: github-actions-release-topology
description: Use when creating, reviewing, or hardening GitHub Actions CI/CD workflows where deployment topology, promotion safety, release identity, cache discipline, OIDC, environments, or production readiness matter.
---

# GitHub Actions Release Topology

Use this skill when creating, reviewing, or hardening GitHub Actions CI/CD
pipelines where topology, deployment sequencing, promotion safety, release
identity, cache correctness, or environment boundaries matter.

## Applicability Gate

Use when the user asks to:

- create or refactor a GitHub Actions CI/CD workflow;
- review whether a pipeline is production-ready;
- split quality, dev deploy, production promotion, or preview environment
  workflows;
- make deploys deterministic and auditable;
- add release identity manifests or deployment evidence;
- evaluate cache, artifact, branch protection, runner, OIDC, or environment
  safety.

Do not use for:

- framework-specific test authoring;
- ordinary GitHub Actions syntax questions where release topology does not
  matter;
- platform-specific runner mechanics alone;
- opening, updating, or formatting pull requests.

If a specialized local skill covers the platform, use this skill for topology
and promotion semantics, then route platform mechanics to that skill.

## Operating Principles

A high-quality pipeline is:

- strict: failed quality, identity, or deploy preconditions fail closed;
- deterministic: deploys and promotions identify the exact source or artifact;
- auditable: every shared-environment mutation leaves durable evidence;
- separated: PR validation, main quality, dev deploy, and prod promotion have
  explicit contracts;
- cache-efficient: caches accelerate but never become correctness inputs;
- documented: diagrams and prose match executable workflow behavior;
- security-aware: fork PRs, self-hosted runners, secrets, OIDC, and
  environments have explicit boundaries.

## Procedure

1. Map the current or intended topology.
2. Separate validation from mutation.
3. Identify every mutable boundary: branch refs, reusable workflows, registries,
   caches, generated artifacts, secrets, and environments.
4. Define the promotion contract before writing jobs.
5. Require release evidence for every shared dev or prod deploy.
6. Check security gates: fork PRs, same-repo guards, permissions, environments,
   required checks, concurrency, and cancellation.
7. Check cache and artifact discipline.
8. Compare documentation against workflow behavior.
9. Report critical findings before design suggestions.

For detailed criteria, read `references/topology-review-checklist.md`.

## Reference Routing

Open `references/topology-review-checklist.md` when the request involves
production readiness, deployment sequencing, release evidence, preview
environments, branch protection, OIDC, secrets, caches, artifacts, or documented
workflow topology.

## Confirmation Gate

When changing workflow files, propose the workflow graph and patch plan before
editing unless the user has explicitly asked for implementation.

## Output Contract

For reviews, return:

- current topology;
- findings ordered by severity;
- hidden coupling or overclaiming;
- residual risks;
- concrete next steps.

For designs, return:

- proposed workflow graph;
- required checks and branch protection;
- deploy and promotion contracts;
- release identity manifest fields;
- cache and artifact policy;
- documentation updates;
- open risks and deferred work.
