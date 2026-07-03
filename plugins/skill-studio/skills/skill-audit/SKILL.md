---
name: skill-audit
description: >-
  Audit a Claude skill for quality, context-efficiency, and best-practice
  compliance — classify its archetype, score the four principles and instruction
  craft, and return a report — or review a PORTFOLIO of skills for overlap and
  trigger collisions. Use when someone asks to audit, review, grade, "lint", or
  sanity-check a skill or plugin's quality; asks "does this skill follow best
  practices / is it well-scoped / is the description good enough to trigger / do
  these skills overlap or collide"; or wants a governance sweep across a set of
  skills. Read-only: it diagnoses and recommends, it does not edit. Do not use to
  create or scaffold a skill (use skill-create), to improve a skill or run
  eval/benchmark loops (use skill-enhance), or for versioning/release/CHANGELOG
  governance (use repo-governance:skill-maintainer).
---

# Skill Audit

Diagnose skills. Read-only: this skill inspects, scores, and recommends — it
never edits, renames, or moves files. Applying fixes is the sibling
`skill-enhance`; versioning/release is `repo-governance:skill-maintainer`. This
is a router — pick one branch, load only the references it names.

## Apply when

- Auditing / reviewing / grading / "linting" one skill or plugin for quality.
- "Does this skill follow best practices? Is it well-scoped? Is the description
  discriminative enough to trigger reliably?"
- A portfolio has trigger collisions, overlap, duplicate names, or vague
  descriptions, and the user wants to know which skills compete.
- A governance sweep across a set of skills.

## Do not apply when

- Creating or scaffolding a new skill → `skill-create`.
- Improving a skill, or running an eval / benchmark / A-B comparison loop →
  `skill-enhance` (this skill owns single-artifact review and portfolio overlap,
  not the improvement or eval loop).
- Versioning, release artifacts, or CHANGELOG governance →
  `repo-governance:skill-maintainer`.
- Just using a skill to do its own job → invoke that skill directly.

## Intent router

Pick exactly one branch.

| Signal | Branch | Primary references | Tooling |
|---|---|---|---|
| Audit / review one skill (or a small set) for compliance, archetype, context economy | **A. Single-skill compliance audit** | `references/single-skill-audit.md`, `references/platform-audit-lenses.md`, `references/report-format.md` | both scripts; optional `skill-architecture-checker` |
| Review a portfolio / directory of skills for overlap, trigger collisions, bad bundling | **B. Portfolio / overlap audit** | `references/portfolio-audit-workflow.md` (installed set) or `references/repo-skills-overlap-audit.md` (deep repo-first-party) | 3 subagents; `assets/templates/portfolio-audit-report.md` |

If the user only asks "does this one skill follow best practices?", that is
Branch A. If they ask "do these skills collide / which overlap?", that is
Branch B.

## Shared principles

Apply to every branch:

- **Read-only by default.** Propose, don't apply. Present the plan and pause for
  explicit approval before any file operation — even a rename, an anti-trigger
  edit, or an obvious deletion. This skill routes fixes; it does not make them.
- **A clean script run is not a PASS.** The scripts report mechanical facts;
  archetype fit, single-responsibility, and instruction craft still decide the
  verdict. Never grade off the JSON alone.
- **Cheap-agent-first.** Delegate directory scans and clustering to the bundled
  read-only subagents. Never read 50+ `SKILL.md` files in the main thread.
- **Expected outcome required.** Every recommendation states what measurably
  improves (faster routing, fewer reads, lower noise, better activation) and an
  effort/risk level. Without both it is unactionable.
- **Route fixes by name.** Concrete fixes go to `skill-enhance` (improvement) or
  `repo-governance:skill-maintainer` (versioning/release). Do not edit here.

## Branch A — Single-skill compliance audit

1. Resolve the target — a skill folder or a single `SKILL.md`. Audit the **real
   directory**, never `.` (the checker compares `name` to the folder basename).
2. **Run both scripts** — they cover different, complementary surfaces:
   - Token-economy / hot-path metrics (advisory, character-based, does not gate):
     ```
     python3 ${CLAUDE_SKILL_DIR}/scripts/skill_hot_path_audit.py <target> --json
     ```
   - Mechanical package / wiring signals (name/description limits,
     metadata/CHANGELOG presence, orphan/dangling references, gotchas-section
     presence, cross-package cache-copy hazards):
     ```
     bash ${CLAUDE_SKILL_DIR}/scripts/audit-skill.sh <skill-dir>
     ```
   Reach for the Python auditor for prompt-visible surface cost and duplication
   pressure; reach for the bash checker for package correctness and
   progressive-disclosure wiring. A single-skill audit runs **both**. See
   `references/single-skill-audit.md` for the schema fields to cite.
3. Apply the judgment the scripts cannot: **archetype fit**
   (`references/archetypes.md`), **the four principles**
   (`references/principles.md`), and **instruction craft**
   (`references/authoring-for-claude.md`).
4. Apply the **Claude / Claude Code** platform lens (and, for a non-Claude
   target, the generic-markdown lens) in `references/platform-audit-lenses.md`.
5. Optionally dispatch `skill-architecture-checker` for a compliance spot-check.
   Pass it the rules **in its prompt** (excerpted from the bundled principles) —
   it cannot read repo files.
6. Write the report using `references/report-format.md`: a per-skill scorecard
   (archetype + four principles + instruction craft + manifest), concrete
   evidence, and prioritized fixes routed by name. **Pause for approval.**

## Branch B — Portfolio / overlap audit

Choose the sub-branch by depth:

- **Installed / quick portfolio audit** — follow
  `references/portfolio-audit-workflow.md`. Inventory the target directory, then
  dispatch the three subagents in sequence:
  1. `skill-overlap-clusterer` — heuristic clustering (scope with a glob filter
     on >~50 skills or the output is noise).
  2. `skill-architecture-checker` — compliance pass on the folders the clusterer
     flagged, with rules passed in the prompt.
  3. `skill-consolidation-advisor` — synthesize into a scored overlap report,
     passing it the format from `assets/templates/portfolio-audit-report.md`.
- **Deep repo-first-party overlap audit** (consolidation-ADR input) — follow
  `references/repo-skills-overlap-audit.md`: normalized inventory → cluster A
  (description) → cluster B (body) → cluster C (registry/tags) → single arbiter
  pass. Use several cheap subagents in parallel for the inventory and cluster
  passes; reserve one arbiter subagent to reconcile.

Present the report using `assets/templates/portfolio-audit-report.md` (augmented
with the inventory JSON and per-cluster outputs for the deep path). **Pause for
approval.** Apply renames, anti-triggers, or archives only after explicit
approval, and route them to a maintainer skill.

## Subagents

Bundled with this plugin (`agents/`), all read-only:

| Subagent | Use when |
|---|---|
| `skill-overlap-clusterer` | Branch B: heuristic clustering of a directory by description + body similarity. |
| `skill-architecture-checker` | Branch A spot-check; Branch B compliance pass. Pass the compliance rules in its prompt — it cannot read repo files. |
| `skill-consolidation-advisor` | Branch B: synthesize cluster + architecture outputs into a scored consolidation report. |

Prefer subagents over inline work whenever the task is bounded, read-heavy, and
would otherwise bloat the main context.

## Script signals vs your judgment

| The scripts report (deterministic / advisory) | You judge |
|---|---|
| `name`/`description` present, `name_matches_folder`, `legacy_fields`, `description_chars`, `long_description*` | description quality: discriminative? WHAT + WHEN? pushy enough to trigger? |
| `skill_md_lines`, `router_too_long`, `heavy_references_without_toc`, `orphan_references`, `dangling_skill_links`, `scripts`, `non_executable_scripts` | is detail correctly pushed to references/scripts? is the hot path a lean hub dispatching to spokes? do large refs carry a TOC? are orphan/dangling refs a real wiring gap or benign? |
| `cross_package_relative_links`, `relative_bundled_script_calls` | archetype fit; single responsibility; cache-safety of references |
| `duplication_buckets`, `multi_skill_shared_phrase` | is the repetition real waste, or coincidental shared vocabulary? |
| `metadata_json`, `changelog`, `readme`, `evals.*` | composability, maintainability, and whether behavior is backed by evidence |
| `gotchas_section` (presence only) | instruction craft: right altitude (no railroading)? sound first-run setup (no committed user values)? earns its context? is the gotchas section high-quality (or fine to be absent for this archetype)? |

## Gotchas

- **A clean script run is not a PASS.** The scripts report mechanical/advisory
  facts only; archetype fit, single-responsibility, and instruction craft decide
  the verdict. An all-green skill can still be a SPLIT CANDIDATE or NEEDS WORK.
- **Audit the real directory, not `.`.** `name_matches_folder` compares the
  frontmatter `name` to the folder basename, so `audit-skill.sh .` reports a
  false mismatch. Pass the path (`plugins/<plugin>/skills/<skill>`).
- **Run BOTH scripts.** They cover different surfaces:
  `skill_hot_path_audit.py` is prompt-visible token economy (advisory,
  character-based — it never calls a tokenizer, so cite its char counts, don't
  restate them as token estimates); `audit-skill.sh` is mechanical package and
  wiring correctness. Neither substitutes for the other.
- **`orphan_references` and `dangling_skill_links` are heuristics — confirm by
  eye.** Orphan is a basename substring match (a name in prose but never linked
  still reads as "wired in"); dangling only scans in-skill relative `.md` links
  in `SKILL.md`. Verify before routing a fix.
- **`gotchas_section` is presence-only.** Any gotchas/pitfalls/caveats heading
  flips it `true` regardless of quality, and its absence is expected for a
  scaffolding or pure-router skill. Judge quality and archetype — not the boolean.
- **Subagents cannot read repo files.** `skill-architecture-checker` compares
  against the rules **in its prompt**. Excerpt them from the bundled
  `references/principles.md` / `references/archetypes.md`; never assume a repo
  path exists.
- **`skill-overlap-clusterer` is noise on >~50 skills.** Scope it with a glob
  filter (e.g. `gsd-*`) before dispatching.
- **Audits propose; they never apply.** File operations happen only after
  explicit approval, and this skill routes them to a maintainer — even renames,
  anti-trigger edits, and obvious deletions.

## Output contracts

| Branch | Final artifact |
|---|---|
| A | Per-skill scorecard (archetype + four principles + instruction craft + manifest) with concrete evidence and a prioritized, routed fix list — see `references/report-format.md`. |
| B | Filled `assets/templates/portfolio-audit-report.md`: executive summary, clusters, compliance violations, proposed actions with confidence scores. |

## See Also

- `references/single-skill-audit.md` — single-skill procedure.
- `references/portfolio-audit-workflow.md`,
  `references/repo-skills-overlap-audit.md` — portfolio branches.
- `references/principles.md`, `references/archetypes.md`,
  `references/authoring-for-claude.md`, `references/platform-audit-lenses.md`,
  `references/report-format.md` — the judgment doctrine (bundled).
- `assets/templates/portfolio-audit-report.md` — portfolio report template.
