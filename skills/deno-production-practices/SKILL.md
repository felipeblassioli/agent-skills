---
name: deno-production-practices
description: >-
  Write production-grade Deno code with secure-by-default permissions, deliberate import and dependency strategy, testing conventions, and Node/npm interoperability rules. Use when authoring, reviewing, or migrating Deno applications, libraries, CLIs, scripts, or deno.json task workflows. Do NOT use for generic TypeScript quality patterns outside Deno.
license: MIT
compatibility:
  - Deno 2.x
  - TypeScript or JavaScript projects running on Deno
metadata:
  domain: runtime
  framework: deno
  language: typescript
---

# Deno Production Practices

Opinionated guidance for writing production-ready Deno code without importing unsafe Node habits by default.

## Applicability Gate

Apply this skill when ANY of the following are true:

- You are building or reviewing a service, CLI, script, or library that runs on `deno`
- You need to decide how a Deno project should handle permissions, tasks, and runtime boundaries
- You are migrating code from Node.js to Deno and need interop rules for `npm:` packages or CommonJS
- You need conventions for Deno imports, file naming, tests, or `deno.json` task design
- You want a production-readiness review for a Deno codebase before release

Do NOT apply when:

- The task is generic TypeScript quality, validation, or logging guidance not specific to Deno -> route to **typescript-quality**
- The task is about test doctrine or test-double strategy rather than Deno runtime conventions -> route to **tdd-classicist**
- The task is about fixing general ESM problems in a Node/TS toolchain rather than Deno runtime behavior -> route to **esm-typescript**

## Routing Table

| Question | Route to |
|----------|----------|
| "How is Deno different from Node for production code?" | [references/runtime-mental-model.md](references/runtime-mental-model.md) |
| "How should I structure imports and dependencies in Deno?" | [references/imports-and-dependencies.md](references/imports-and-dependencies.md) |
| "Which permissions should this Deno command or service get?" | [references/permissions-and-security.md](references/permissions-and-security.md) |
| "What coding and testing conventions should a Deno project follow?" | [references/style-and-testing.md](references/style-and-testing.md) |
| "How should I handle Node and npm compatibility in Deno?" | [references/node-and-npm-interop.md](references/node-and-npm-interop.md) |
| "What mistakes should I watch for in a Deno code review?" | [references/common-pitfalls.md](references/common-pitfalls.md) |
| "Is this Deno project ready for production release?" | [assets/checklists/production-readiness.md](assets/checklists/production-readiness.md) |

## Procedure

1. **Identify the runtime task.** Decide whether the user is designing a new Deno project, reviewing an implementation, or migrating from Node.
2. **Route to the right reference.** Read only the file needed for the active decision; do not load all references by default.
3. **Apply Deno-native defaults.** Prefer least-privilege permissions, ESM-first modules, explicit dependency choices, and Deno-native conventions before introducing Node compatibility layers.
4. **Call out runtime contracts explicitly.** If proposing commands, tasks, or tests, state the exact permissions and interop assumptions they rely on.
5. **Use the release checklist for final review.** Before calling a Deno project production-ready, run through the checklist and surface any permission, import, or interoperability risks.

## Confirmation Policy

Do NOT apply code or configuration changes derived from these rules without explicit user confirmation, especially when:

- widening runtime permissions
- introducing `npm:` dependencies or Node compatibility shims
- changing `deno.json` tasks or release-time command contracts

## Related Skills

- **typescript-quality** - complements this skill for validation, error handling, logging, and API hygiene once the Deno runtime decisions are clear
- **tdd-classicist** - use for deeper test strategy once the Deno-specific testing conventions are settled
- **esm-typescript** - use when the issue is a broader ESM toolchain problem outside Deno itself
