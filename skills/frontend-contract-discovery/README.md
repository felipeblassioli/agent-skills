# Frontend Contract Discovery

Find the HTTP contracts a React frontend consumes, draft an evidence-backed OpenAPI spec, and record traceable findings in discover.log.md.

## When To Use

Use this skill when a user asks:
- "Can you infer the OpenAPI contract from my React frontend?"
- "Draft an OpenAPI spec based on the API calls we make in the client."
- "Check if our frontend API calls have drifted from the expected spec."
- "Document the API endpoints used by this React app in a discover.log.md file."

## What This Skill Maintains

- **Hot path:** `SKILL.md` (Applicability gate, routing, and core procedure)
- **References:** `references/evidence-sources.md` (Where to look for API calls), `references/openapi-inference-rules.md` (How to map observations safely)
- **Assets:** `assets/discover-log-template.md` (Log template), `assets/drift-checklist.md` (Drift evaluation checklist)

## Release And Validation

To validate this skill before a release:
```bash
bash scripts/skill-sync.sh --skill=frontend-contract-discovery --dry-run
```

To sync this skill locally:
```bash
bash scripts/skill-sync.sh --skill=frontend-contract-discovery
```

## Related Skills Or Packs

- `kysely-typescript` - For backend SQL query building and typed contracts.
- `hono-htmx-server` - For HTMX-driven APIs.
- `test-verifier` - To run tests related to contract or API changes.