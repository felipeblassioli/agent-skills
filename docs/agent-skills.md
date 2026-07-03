# Agent Skills Catalog

This document catalogs the registry-managed Agent Skills in this repository and
the pack-bundled skills that install alongside Cursor packs.

`skill-registry.json` remains the source of truth for root skill versions,
targets, tags, and descriptions. If this document drifts, update it from the
registry rather than treating the prose as authoritative.

## Overview

Agent Skills are modular packages that extend agents with specialized knowledge,
task workflows, and routing instructions without loading the whole repository into
context upfront.

This repository currently tracks:

- **49 registry-managed root skills**.
- **13 pack-bundled skills** declared inside Cursor pack manifests.
- **48 root skills targeting Cursor**.
- **22 root skills targeting generic agents**.
- **1 Claude.ai-only skill**.
- **1 Gemini-targeted skill**.

## How Skills Work

### Activation

Skills activate from their frontmatter and registry descriptions. A strong skill
description says what the skill does and when to use it, while avoiding broad
phrasing that would trigger for unrelated tasks.

### Progressive Disclosure

Skills use three layers:

1. **Metadata**: `name`, `description`, registry tags, targets, and version.
2. **Instructions**: compact `SKILL.md` guidance loaded when the skill activates.
3. **Resources**: optional `references/`, `assets/`, and `scripts/` loaded only
   when needed.

### Root Skills vs Pack-Bundled Skills

Root skills live under `skills/<name>/`, are listed in `skill-registry.json`, and
are deployed by `scripts/skill-sync.sh`.

Pack-bundled skills live under `packs/<pack>/skills/<skillId>/`, are declared in
`pack.json` with `kind: "skill"`, and version with the containing pack unless
explicitly promoted to the root registry.

## Root Skills by Domain

### Authoring, Maintenance, and Agent Artifact Design

| Skill | Version | Targets | Use when |
| --- | --- | --- | --- |
| `bmad-specialist` | 1.1.0 | cursor, agents | Auditing or customizing installed BMAD projects and deciding where behavior belongs. |
| `nested-agents-routing` | 1.0.2 | cursor, agents | Designing repo-local agent guidance with `AGENTS.md`, Cursor rules, skills, packs, and bundled skills. |

> **Authoring / audit / maintain consolidated into `cursor-skill-studio` per
> [ADR-0005](./ADR/ADR-0005-skill-authoring-surface-consolidation.md).**
> The nine former root skills (`writing-cursor-skills`,
> `create-skill-from-refs`, `create-cursor-pack-from-refs`,
> `external-skill-intake`, `claude-plugin-to-cursor-pack`,
> `audit-skill-for-cursor`, `improving-agent-artifacts`,
> `personal-skill-maintainer`, `personal-pack-maintainer`) are now thin
> redirect stubs pointing at three bundled skills inside the
> `cursor-skill-studio` Cursor pack:
>
> - `/skill-studio-write` — greenfield authoring, distillation from
>   reference material, pack scaffolding, external skill intake,
>   Claude-plugin adaptation, eval / comparison loop.
> - `/skill-studio-audit` — single-skill compliance audit, improvement
>   recommendations, installed portfolio audit (overlap clusterer +
>   architecture checker + consolidation advisor), deep repo-first-party
>   overlap audit.
> - `/skill-studio-maintain` — root-skill and pack releases, registry
>   alignment, bundled-skill artifact edits, promotion / demotion,
>   maturity classification (ADR-0003), install verification.
>
> See the "Pack-Bundled Skills" section below for the canonical entries and
> [`packs/cursor-skill-studio/README.md`](../packs/cursor-skill-studio/README.md)
> for installation. The stubs are scheduled for full removal once the
> consolidation reaches PR 6 of ADR-0005.

### Review, GitHub, and Delivery Workflow

| Skill | Version | Targets | Use when |
| --- | --- | --- | --- |
| `babysit` | 1.0.0 | cursor, agents | Keeping a PR merge-ready by triaging comments, resolving clear conflicts, and fixing CI. |
| `code-review` | 1.0.0 | cursor | Reviewing code changes for correctness, security, performance, maintainability, and test gaps. |
| `commit-hygiene` | 1.0.0 | cursor | Preparing self-contained commits and reviewable PRs with production-impact context. |
| `gh-issue-verifier` | 1.0.0 | cursor | Verifying whether a GitHub issue is implemented with evidence from code, docs, history, and tests. |
| `gh-post-code-review` | 0.1.0 | cursor, agents | Posting a structured markdown code review to a GitHub PR. |
| `gh-pr-creator` | 1.0.0 | cursor | Creating or updating GitHub PRs with the repo template and staged body files. |
| `github-actions-release-topology` | 1.0.0 | cursor | Designing or hardening GitHub Actions release, promotion, cache, OIDC, and deployment topology. |
| `linear-specialist` | 1.0.0 | cursor, gemini | Auditing and tidying Linear boards against current work reality. |

### TypeScript, JavaScript, and Backend Development

| Skill | Version | Targets | Use when |
| --- | --- | --- | --- |
| `deno-production-practices` | 1.0.0 | cursor, agents | Writing or reviewing production-grade Deno code and secure Deno workflows. |
| `esm-typescript` | 1.0.0 | cursor | Diagnosing and fixing ESM errors in TypeScript projects. |
| `firebase-functions-node` | 1.0.0 | cursor | Writing, testing, configuring, or migrating Firebase Cloud Functions for Node.js. |
| `hono-htmx-server` | 1.0.0 | cursor, agents | Building or reviewing server-side HTMX applications with Hono. |
| `kysely-typescript` | 1.0.0 | cursor, agents | Designing schemas, migrations, and type-safe SQL queries with Kysely. |
| `nx-monorepo` | 2.0.0 | cursor | Scaffolding or maintaining Nx TypeScript monorepos. |
| `ts-module-documentation` | 1.0.0 | cursor | Documenting public TypeScript modules, functions, variables, and types. |
| `typescript-error-handling` | 1.0.1 | cursor, agents | Choosing typed domain errors, result types, and robust recovery patterns in TypeScript. |
| `typescript-quality` | 1.0.0 | cursor | Applying TypeScript quality patterns for clients, validation, errors, logging, tracing, and PII redaction. |

### Testing and Verification

| Skill | Version | Targets | Use when |
| --- | --- | --- | --- |
| `hurl-testing` | 1.0.0 | cursor, agents | Writing and executing Hurl HTTP request tests safely. |
| `tdd-classicist` | 1.0.0 | cursor | Applying classicist TDD, test-double taxonomy, and test pyramid strategy. |
| `test-verifier` | 1.0.0 | cursor | Verifying working-tree changes against a multi-tier test pyramid. |
| `typescript-testing-organization` | 1.0.0 | cursor | Naming and organizing TypeScript tests by tier and suffix policy. |
| `vitest-monorepo` | 1.0.0 | cursor | Configuring Vitest discovery and workspace behavior in monorepos. |

### Frontend, UI, and Contract Discovery

| Skill | Version | Targets | Use when |
| --- | --- | --- | --- |
| `backend-contract-reconciliation` | 1.0.0 | cursor, agents | Reconciling frontend-discovered endpoint drafts with backend implementation truth. |
| `composition-patterns` | 1.0.0 | cursor, agents | Refactoring or designing React composition APIs and reusable component patterns. |
| `frontend-contract-discovery` | 0.2.2 | cursor, agents | Inferring HTTP contracts and evidence-backed OpenAPI drafts from frontend code. |
| `react-best-practices` | 1.0.0 | cursor, agents | Writing, reviewing, or refactoring React and Next.js performance-sensitive code. |
| `react-native-skills` | 1.0.0 | cursor, agents | Building performant React Native or Expo mobile applications. |
| `web-design-guidelines` | 1.0.0 | cursor, agents | Reviewing UI, UX, accessibility, and web interface quality. |

### Go, CLI, and Documentation

| Skill | Version | Targets | Use when |
| --- | --- | --- | --- |
| `go-command-line-applications` | 1.0.0 | cursor, agents | Authoring or reviewing Go command-line applications with stable command grammar and output contracts. |
| `go-package-documentation` | 1.0.0 | cursor, agents | Writing Go package-level documentation and `doc.go` files. |

### Cloud, Observability, and Operations

| Skill | Version | Targets | Use when |
| --- | --- | --- | --- |
| `gcloud-logging` | 1.0.0 | cursor | Querying and extracting Google Cloud Logging entries with `gcloud`. |
| `gcp-error-reporting-nodejs` | 1.0.1 | cursor, agents | Configuring or using Google Cloud Error Reporting in Node.js workloads. |
| `gcp-opentelemetry-nodejs` | 1.0.1 | cursor, agents | Instrumenting Node.js workloads with OpenTelemetry and Google Cloud structured logging. |
| `otel-semantic-conventions` | 1.0.0 | cursor, agents | Selecting, applying, or reviewing OpenTelemetry semantic convention attributes. |

### Security and Compliance

| Skill | Version | Targets | Use when |
| --- | --- | --- | --- |
| `owasp-security` | 0.2.0 | cursor, agents | Securing Node.js/TypeScript backends with OWASP Top 10 routing and library-specific guidance. |

### Product, Planning, and Requirements

| Skill | Version | Targets | Use when |
| --- | --- | --- | --- |
| `prd` | 0.1.0 | cursor, agents | Drafting or refining product requirements documents with implementation-ready structure. |

### Claude.ai and Platform-Specific Skills

| Skill | Version | Targets | Use when |
| --- | --- | --- | --- |
| `vercel-deploy-claimable` | 1.0.0 | claude | Deploying apps to Vercel with claimable ownership transfer. |

## Pack-Bundled Skills

Pack-bundled skills are installed through `scripts/cursor-pack-sync.sh`, not
`scripts/skill-sync.sh`. They are scoped to their containing pack and should not
be added to `skill-registry.json` unless intentionally promoted.

| Pack | Bundled skill | Purpose |
| --- | --- | --- |
| `agentic-artifact-discovery` | `agentic-artifact-discovery-workflow` | Entry point for exploring skill systems, workflow frameworks, subagent bundles, and plugin-like artifacts. |
| `cursor-companion` | `cursor-companion-pack-overview` | Orientation skill for the companion pack's subagents, rules, hooks, MCP examples, and guides. |
| `cursor-skill-studio` | `skill-studio-write` | Consolidated authoring surface: greenfield skills, distillation from refs, pack scaffolding, external intake, Claude-plugin adaptation, eval/comparison loop. Invoke `/skill-studio-write`. |
| `cursor-skill-studio` | `skill-studio-audit` | Consolidated audit surface: single-skill compliance, improvement recommendations, installed portfolio audit, deep repo-first-party overlap audit. Invoke `/skill-studio-audit`. |
| `cursor-skill-studio` | `skill-studio-maintain` | Consolidated maintain surface: root-skill and pack releases, registry alignment, bundled-skill artifact edits, promotion/demotion, maturity classification, install verification. Invoke `/skill-studio-maintain`. |
| `engineering-workflows` | `engineering-architecture` | Architecture decision and design guidance. |
| `engineering-workflows` | `engineering-code-review` | Structured code review workflow guidance. |
| `engineering-workflows` | `engineering-debug` | Systematic debugging workflow guidance. |
| `engineering-workflows` | `engineering-deploy-checklist` | Pre-deployment verification and rollback planning guidance. |
| `engineering-workflows` | `engineering-documentation` | Technical documentation workflow guidance. |
| `engineering-workflows` | `engineering-incident-response` | Incident triage, communication, and postmortem guidance. |
| `engineering-workflows` | `engineering-standup` | Standup update synthesis guidance. |
| `engineering-workflows` | `engineering-system-design` | System, service, API, and data-model design guidance. |
| `engineering-workflows` | `engineering-tech-debt` | Technical debt identification and prioritization guidance. |
| `engineering-workflows` | `engineering-testing-strategy` | Test strategy and test plan guidance. |

## Creating or Updating Skills

### Root Skill Checklist

1. Create or update `skills/<name>/SKILL.md`.
2. Keep frontmatter limited to `name` and `description` unless there is a strong
   provenance reason.
3. Keep heavy detail in one-hop support files.
4. Update `metadata.json` when behavior changes.
5. Update `skill-registry.json` for new skills, version changes, targets, tags,
   or deployment metadata.
6. Update `CHANGELOG.md` for maintained skills when releasing behavior changes.
7. Validate with the appropriate sync or validation command.

### Pack-Bundled Skill Checklist

1. Create or update `packs/<pack>/skills/<skillId>/SKILL.md`.
2. Keep `skillId` pack-scoped to avoid collisions in shared Cursor skill paths.
3. Declare the bundled skill in `pack.json` with `kind: "skill"`.
4. Version and release it with the containing pack.
5. Promote it to `skill-registry.json` only when it should become an independent
   root skill.

## Related Documents

- [Architecture](./architecture.md)
- [Agentic Skill and Pack Authoring Specification](./specs/agentic-skill-pack-authoring.md)
- [Skill Authoring Checklist](./specs/skill-authoring-checklist.md)
- [Cursor Packs Guide](./cursor-packs.md)
- [Governed Skill Maintenance Model](./ADR/ADR-0002-governed-skill-maintenance-model.md)
