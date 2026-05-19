# Pack Recommendation Metadata — Growth Spec

> Originally a reference inside `skills/create-cursor-pack-from-refs/`. Relocated
> to `docs/specs/` as part of ADR-0005 so it can grow as a durable spec rather
> than a hot-path skill reference.

The current pack schema is sufficient for install and validation, but too thin
for an advisory MCP server to answer questions like:

- "Which pack should I use for project guard-rails?"
- "Should this capability be a rule, subagent, hook, or MCP?"
- "Which profile is the safest starting point?"
- "When should I avoid this pack entirely?"

This document defines the machine-readable metadata that should exist before a
reliable recommender is built.

## Why existing metadata is not enough

Current fields already cover:

- pack identity
- installable targets
- available profiles
- artifact file locations
- high-level install policy

Current fields do **not** clearly encode:

- the pack's primary jobs-to-be-done
- who the pack is for
- when the pack is a bad fit
- which surface each artifact represents semantically
- whether an artifact is advisory, persistent, or runtime-enforcing
- how profile choice changes the recommendation

## Proposed metadata layers

### 1. Catalog-level recommendation metadata

Add a future `recommendation` block to `cursor-pack-registry.json` entries.

Suggested shape:

```json
{
  "recommendation": {
    "status": "draft",
    "audience": ["individual", "team-maintainer"],
    "jobs": [
      {
        "id": "guardrail-runtime",
        "label": "Add runtime guard-rails to Cursor usage",
        "keywords": ["hooks", "safety", "guardrails", "cursor"]
      }
    ],
    "outcomes": [
      "safer shell usage",
      "reviewable MCP examples"
    ],
    "avoidWhen": [
      "you only need a reusable knowledge skill",
      "you need live external-system integration instead of examples"
    ],
    "defaultTarget": "project-cursor",
    "defaultProfile": "lite",
    "safetyLevel": "advisory-with-optional-enforcement"
  }
}
```

### 2. Pack-contract metadata

Add a future top-level `recommendation` or `capabilities` block to `pack.json`.

Suggested responsibilities:

- describe the pack's intent in structured terms
- tie profiles to use cases, not just descriptions
- expose prerequisites and operational costs
- explain why the pack exists without forcing the recommender to scrape prose

Suggested fields:

| Field | Why it matters |
|---|---|
| `capabilities` | lets the recommender match user goals to packs |
| `prerequisites` | avoids recommending packs the environment cannot support |
| `operationalCosts` | warns when hooks, reviews, or maintenance overhead are involved |
| `recommendedStartingProfile` | answers "what should I try first?" |
| `antiUseCases` | avoids bad recommendations |

### 3. Artifact-level surface metadata

The recommender must know more than file paths. It needs semantic surface data
for every artifact.

Suggested future fields on each artifact:

```json
{
  "id": "rules",
  "surface": "rule",
  "intent": ["persistent-guidance"],
  "activationMode": "passive-persistent",
  "userVisible": true,
  "safetyImpact": "medium"
}
```

Recommended field meanings:

| Field | Meaning |
|---|---|
| `surface` | `subagent`, `rule`, `hook-config`, `hook-script`, `mcp-example`, `guide` |
| `intent` | why this artifact exists semantically |
| `activationMode` | `manual`, `passive-persistent`, `runtime-enforced`, `example-only` |
| `userVisible` | whether the user actively interacts with it |
| `safetyImpact` | relative operational sensitivity |

### 4. Surface selection metadata

Reliable surface recommendation also requires a shared vocabulary for when to
choose `skill`, `rule`, `subagent`, `hook`, or `MCP`.

Suggested future registry-level or shared-metadata structure:

```json
{
  "surfaceGuidance": [
    {
      "need": "reusable-knowledge",
      "recommendedSurface": "skill",
      "avoidSurfaces": ["hook"],
      "keywords": ["knowledge", "methodology", "reference"]
    }
  ]
}
```

This should stay advisory and read-only. It is not an installer contract.

## Minimum viable metadata before building the MCP

Do not build the recommender until all packs can answer these questions without
scraping prose:

1. What user goal does this pack solve?
2. Who is the intended audience?
3. What target/profile should be recommended first?
4. What makes this pack a bad fit?
5. Which surfaces are included, and what semantic role does each play?
6. Which surfaces are passive guidance versus runtime enforcement?

## Recommended rollout order

1. Capture the metadata draft for each new pack during authoring.
2. Validate that the metadata is stable across at least a few packs.
3. Promote the agreed fields into schema files.
4. Only then design the advisory MCP server around those stable fields.

## Non-goals

- automatic installation
- mutation of `.cursor/` or `mcp.json`
- using prose-only guides as the primary recommendation source
- conflating pack recommendation with live system configuration
