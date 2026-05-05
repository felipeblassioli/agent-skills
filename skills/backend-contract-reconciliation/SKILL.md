---
name: backend-contract-reconciliation
description: >-
  Take draft endpoint artifacts produced by frontend-contract-discovery and
  reconcile them with backend implementation truth using strict trace sources.
---

# Backend Contract Reconciliation

Take draft endpoint documentation (often produced by frontend inference) and upgrade it to a final, verified contract by finding the actual backend implementation.

This skill ensures that backend documentation is anchored in reality using strict code evidence (Trace Sources) rather than guesswork.

## Applicability Gate

Use this skill when ANY of the following are true:

- the user wants to reconcile a draft or frontend-inferred API doc with the backend
- the user wants to map a backend router to an API doc
- the user wants to add strict Trace Sources to an existing endpoint doc

Do NOT use this skill when:

- the user wants to infer the API from a React/frontend client (use `frontend-contract-discovery` instead)
- the task is to design a completely new API from scratch
- the task is to validate live endpoints against a running service

## Procedure

1. **Investigate the Backend.**
   - If the codebase is large or the router is unknown, use the `Task` tool (subagent `explore` or `generalPurpose`) to search for the path and verb without flooding your main context.
   - Once found, start from the matching router or controller.
   - Follow the execution path through controllers, services, and repositories to understand the full contract (auth, validation, payloads, errors).
   - Resolve discrepancies. If the frontend sends a field the backend ignores, or the backend requires a field the frontend missed, the backend implementation is the source of truth.

2. **Gather Trace Sources.**
   - Every non-obvious claim (validation rules, error codes, domain logic) MUST be supported by a Trace Source.
   - Trace Sources must link directly to the code.
   - Format: `[path/to/file.ts : L12-L26](https://<git-host>/<repo>/src/<commit>/path/to/file.ts#lines-12:26)` (If git permalinks are unavailable, use local paths like `- path/to/file.ts:12-26`).

3. **Draft the Final Document.**
   - Use the `Read` tool to read `assets/endpoint-doc-template.md`.
   - Upgrade the draft endpoint document to use this strict backend template.
   - Ensure the `Domain Logic Summary` accurately reflects the backend execution path, side effects, and state mutations.
   - Fill in the `Source Trace` section with the gathered evidence.

## Output Contract

For every reconciled endpoint, output the final markdown document following the `assets/endpoint-doc-template.md` structure.

If you encounter unversioned breaking changes or conflicting definitions that you cannot resolve from code evidence alone, STOP and ask the user for clarification before finalizing the document.
