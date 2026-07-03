# Single-Skill Audit Procedure

Step-by-step logic for auditing one skill (or a small set) for quality,
context-efficiency, and best-practice compliance. Read-only: it diagnoses and
recommends; it does not edit. Route every concrete fix to a maintainer skill
(`repo-governance:skill-maintainer` in this marketplace).

## Target resolution

Resolve the target in this order:

1. A skill root containing `SKILL.md` (e.g. `plugins/<plugin>/skills/<skill>`).
2. A directory containing skill subfolders (audit each with `SKILL.md`).
3. A bare skill name (resolve to the skill folder it names).

Audit the skill's **real directory**, never `.` — the checker compares the
frontmatter `name` to the folder basename, so `audit-skill.sh .` reports a false
mismatch.

## Operating constraints

- Read-only by default. Do not modify, create, move, or delete files.
- Propose, don't apply. Present the remediation plan and pause for approval
  before any file operation — even a rename, an anti-trigger edit, or an obvious
  deletion.

## Workflow

### 1. Inventory structure

For each skill root, record: path, folder name, top-level entries, `SKILL.md`,
`references/`, `assets/`, `scripts/`, `metadata.json`, `CHANGELOG.md`. Flag
non-standard directories (`rules/`, `docs/`) that should live under
`references/`.

### 2. Run both bundled scripts (do not re-derive their signals by hand)

Run both — they cover different surfaces and are complementary:

- **`skill_hot_path_audit.py` (advisory token-economy / hot-path metrics)**
  ```
  python3 ${CLAUDE_SKILL_DIR}/scripts/skill_hot_path_audit.py <target> --json
  ```
  Character-based, advisory, does not gate. Cite the v1 schema fields directly —
  do NOT paraphrase them as token estimates (the auditor never calls a
  tokenizer):
  - `skills[].hot_path_metrics.description_chars`, `.skill_md_lines`
  - `skills[].findings[].id` — one of `long_description_info`,
    `long_description`, `description_exceeds_cursor_limit`, `router_too_long`,
    `router_over_hard_cap`, `procedural_description`
  - `skills[].duplication_buckets[]` — `description_repeats_body_heading`,
    `applicability_gate_repeats_description`
  - `thresholds` — the rule values the auditor used
  - for a pack/plugin target: `pack.cross_skill_duplication_buckets`
    (`multi_skill_shared_phrase`, `pack_readme_duplicates_intent_table`)

  Treat `procedural_description` as a routing-style hint, not a defect: it fires
  only when `disable-model-invocation: true` AND the description still uses
  `Use when` / `Invoke explicitly via` prose.

- **`audit-skill.sh` (mechanical package / wiring signals)**
  ```
  bash ${CLAUDE_SKILL_DIR}/scripts/audit-skill.sh <skill-dir>
  ```
  Deterministic facts the model should not eyeball: name/description present,
  `name_matches_folder`, `legacy_fields`; `skill_md_lines`,
  `heavy_references_without_toc`, `orphan_references`, `dangling_skill_links`,
  `scripts`, `non_executable_scripts`, `relative_bundled_script_calls`;
  `cross_package_relative_links` (cache-copy hazard); `gotchas_section`
  (presence only); `metadata_json`/`changelog`/`readme` presence; and the
  `evals` suite + baseline signal.

**When to reach for which:** run the Python auditor for prompt-visible surface
cost and duplication pressure (description bloat, router length, repeated
phrasing). Run the bash checker for package correctness and progressive-
disclosure wiring (metadata/CHANGELOG presence, orphan/dangling references,
cross-package link hazards, gotchas-section presence). A single-skill audit runs
**both**.

### 3. Apply the judgment dimensions the scripts cannot

A clean script run is **not** a PASS. Apply, citing evidence:

- **Archetype fit** — does the skill fit cleanly into exactly one archetype? A
  skill that straddles several is a split candidate. See
  `references/archetypes.md`.
- **The four principles** — single responsibility, composability, context
  efficiency, maintainability. See `references/principles.md`.
- **Instruction craft** — right altitude (not railroading with step-locked
  prose), sound first-run setup (detect-ask-persist config, AskUserQuestion for
  choices, no committed user values), earns its context (non-obvious knowledge,
  not restating what the model already knows), and a quality gotchas section. See
  `references/authoring-for-claude.md`.
- **Platform lens** — apply the Claude / Claude Code lens (and, for a non-Claude
  target, the generic-markdown lens) in `references/platform-audit-lenses.md`.

### 4. Frontmatter invariants (spot-check)

- `name` exists and matches the folder exactly (kebab-case).
- `description` exists and states WHAT + WHEN.
- Governance/freshness fields (`version`, `source_contracts`, `last_reviewed`)
  belong in `metadata.json`, not the frontmatter — flag `legacy_fields`.
- `disable-model-invocation: true` present unintentionally is HIGH severity.

### 5. Deep-check for context waste (optional)

When optimizing for context efficiency and internal consistency:

1. **Context waste** — repeated mechanical checks that should be a script.
2. **Duplication** — a claim repeated across multiple reference files; propose a
   canonical source.
3. **Contradiction** — MUST / MUST NOT pairs colliding in the same scope.

### 6. Optional subagent spot-check

Dispatch `skill-architecture-checker` on the target folder for a fast
compliance pass. Pass it the architecture rules in your prompt (the compliance
rules are bundled in `references/principles.md` and `references/archetypes.md`) —
do NOT assume it can read a repo file.

## Output

Write the report using `references/report-format.md`:

- **Findings table** — ID, skill, category, severity, location(s), summary,
  recommendation, proposed remediation.
- **Remediation plan (unapplied)** — proposed file operations and patch diffs,
  each with an expected outcome and effort/risk level.
- **Confirmation gate** — present the plan and pause for explicit approval. Route
  each fix to a maintainer skill by name; do not edit here.

## See Also

- `references/report-format.md` — scorecard shape and severity rubric.
- `references/platform-audit-lenses.md` — Claude-first platform overlay.
- `references/principles.md`, `references/archetypes.md`,
  `references/authoring-for-claude.md` — the judgment doctrine (bundled).
