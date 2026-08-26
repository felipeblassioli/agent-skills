# Changelog

All notable changes to this skill are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html)
as recorded in `metadata.json` (or `assets/metadata.json` / registry) for this skill.

## 1.1.0 - 2026-08-26

### Added

- **Binding rules (honesty and scope)** section: hard constraints the authoring agent must
  not violate — no fabricated evidence/SHAs/coverage, no `deve passar`, never mark the
  human-review checkbox, never claim break-the-fix rigor without a real proof, honest
  provenance, don't overstep the verify skills. A template can't enforce honesty; the
  authoring agent must.
- **"Earn every sentence"** guidance under "What makes a good PR" (landed as "No AI slop",
  reframed before release): no diff-restatement, no marketing adjectives, length tracks diff
  size, honest `N/A` over padding, facts over opinion, no hedging that hides a gap. The
  "Autoria e rigor" row now links to the binding rules.
- **Gotchas** section consolidating the traps previously scattered in prose: machine-parsed
  markers are load-bearing, HTML comments don't nest, the `assets/` reference copy drifts
  (read the repo's live template at runtime), and the fabrication/human-box traps
  (cross-linked to Binding rules) — each as trap + correct action + where-to-check.
- **Stricter alignment with the turbi-guard verify skills** (`pre-merge-verify` /
  `post-deploy-verify`). The authoring skill now encodes, as hard rules, the same
  falsifiability bar those skills enforce at run time — previously it lived only in the
  template's vanishing HTML comments:
  - Binding rule **"Author only falsifiable proofs"** — every `[PD-n]` and every claimed
    break-the-fix must fail when the change didn't happen; non-discriminating proofs are
    rejected (`post-deploy-verify`'s core discipline, applied at authoring time).
  - Binding rule **"`INCONCLUSIVE` is an honest verdict, never a PASS"** — distinct from
    `não executado` and from a substantiated PASS/FAIL.
  - "Verificação pós-deploy" Comentários row now requires **one change class**, each
    `[OB-n]`↔`[PD-n]` **revision-scoped + falsifiable**, a RED baseline, an explicit
    rollback trigger, and the **body-declaration ↔ evidence-comment split** (body points to
    the `<!-- post-deploy-verification -->` stub; no duplication).
  - New Gotcha: **a non-discriminating / unscoped-window post-deploy proof is a false PASS.**

- **Reviewer pass as a mandatory workflow step** (new step 5, before `gh pr create`/`edit`)
  plus [references/reviewer-pass.md](references/reviewer-pass.md). The body was already
  required to avoid slop; nothing made the agent *re-read it as the reviewer* once drafting
  was done. Drafting is generative and cutting is adversarial to it — the two stances don't
  mix in one pass, so authoring guidance alone kept producing bodies that restated the diff.
  What the pass adds:
  - A closed **keep-list** — intent, constraints, **decisions**, **invariants**, risks,
    verification — mapped to the template sections. `Decisions` (what was rejected and why)
    and `Invariants` (what must stay true) were absent from the skill: they are what a
    reviewer most wants and a machine-drafted body most often lacks.
  - Two **per-sentence** tests replacing the old per-section advice: *diff-redundancy*
    (would the reviewer learn this faster from the diff?) and *decision* (does it change how
    they review it?). "True but inert" is a delete.
  - **Delete-only** rule: the pass never adds a factual claim. Editing after context has
    faded is where invented test counts, SHAs, and revision names appear.
  - **Honest-gap floor**: the pass may not cut `não executado`, `INCONCLUSIVE`, an `N/A` plus
    its reason, the local≠CI ceiling, the unchecked human-review box, an `[OB-n]`/`[PD-n]`
    pair, a break-the-fix, an accepted risk, or a follow-up. Those are keep-list content
    (risk/verification); dropping one to look concise upgrades a gap into an implied PASS.
  - Cut-list of release-notes tells (changelog bullets, `Resumo` that recaps the sections,
    emoji headings, `Este PR introduz…`), voice guidance (concise human engineer), two worked
    before/after rewrites, and an exit checklist — all in the reference, not the hot path.
- New Gotcha: **a conciseness pass that deletes an honest gap makes the PR worse** — diff the
  draft against the submitted body and confirm no gap or proof vanished and no new claim
  appeared.

### Changed

- **`Como?` no longer encourages a file inventory table.** It previously showed
  `| Arquivo | Mudança |` as a good pattern with no constraint, which is the diff-restatement
  the same skill forbids elsewhere. Now: lead with the decision and the invariant; the table
  is only for orienting on a diff too large to hold in the head, every row must say something
  the path doesn't, and the table is dropped when no row survives.
- `assets/body-example.md` reworked to dogfood the pass — it is now labelled as *post*-pass
  output and carries a rejected alternative, an explicit invariant, and a concrete
  observed-failure `Por que?` instead of a shouty banner and a restated file list.
- Moved the `compatibility` block out of `SKILL.md` frontmatter into `metadata.json`
  (the Agent Skills loader reads only `name` + `description` from frontmatter).
- Extracted the worked body-file example from `SKILL.md` into
  [assets/body-example.md](assets/body-example.md) to keep the hot path lean; `SKILL.md`
  now points to it.

- Comentários guidance now documents filling the repo template's `###` subsections
  (turbi-guard: **Autoria e rigor** / **Risco antes do merge** / **Verificação pós-deploy**),
  with a subsection→skill map; body example dogfoods all three (incl. the N/A pós-deploy path).
- `Por que?` now demands the concrete failure/observed behaviour, not a vague "improving X".
- Strengthened the reference-copy note: always read the repo's live template at runtime;
  `assets/pull_request_template.md` is a fallback that may lag. Refreshed that copy to the
  three-subsection shape. (turbiteam/turbi-guard #508/#509.)

## [1.0.0] - 2026-03-20

### Added

- Added `CHANGELOG.md`. Earlier releases are summarized from git history and `metadata.json` only.
