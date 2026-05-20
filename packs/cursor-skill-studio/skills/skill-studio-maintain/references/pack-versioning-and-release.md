# Pack Versioning and Release

Pack version authority lives in `pack.json` and the `cursor-pack-registry.json`
entry. Bumping a pack requires aligning both, refreshing release artifacts,
and verifying the install path before tagging.

## Bump command

```bash
bash scripts/cursor-pack-version.sh <pack> patch|minor|major
```

The script updates `pack.json.version` and the matching
`cursor-pack-registry.json` entry in lockstep. It does not edit the release
artifacts; those are updated by hand in the same PR.

## Required post-bump updates

Every pack version bump MUST update, in the same PR:

- `packs/<pack>/CHANGELOG.md` — Keep a Changelog entry describing what
  changed (Added / Changed / Deprecated / Fixed / Removed / Verification).
- `packs/<pack>/VERIFICATION.md` — commands run, outcome, residual risks.
  `VERIFICATION.md` is the artifact a reviewer reads to trust the release;
  it is not optional.
- `packs/<pack>/ROADMAP.md` — move completed items into a "Shipped" section
  and update "In progress" / "Next".

Other release artifacts (`README.md`, `RELEASE-POLICY.md`) are updated only
when their content actually changes.

## Pre-release ritual

Before tagging or merging a release, run:

```bash
bash scripts/cursor-pack-verify.sh --pack=<name>
bash scripts/cursor-pack-sync.sh --pack=<name> --target=project \
     --project-root=".work/<scratch>" --profile=<profile> --dry-run
bash scripts/cursor-pack-sync.sh --pack=<name> --target=user \
     --profile=<profile> --dry-run
```

Record the copied/updated/conflict counts in `VERIFICATION.md`. Run one
dry-run per profile that the pack ships.

## Release tag

When cutting a release, tag the commit `pack-<name>@<version>`
(for example `pack-cursor-skill-studio@0.6.0`). Do not reuse the
`skill-<name>@<version>` scheme — that is reserved for root skill releases
governed by `scripts/skill-version.sh`.

## See Also

- `references/manifest-and-registry.md` — schema and registry alignment.
- `references/pack-release-artifacts.md` — full release artifact contract.
- `references/pack-lifecycle-scripts.md` — verify / install / restore flow.
- [`docs/ADR/ADR-0001-registry-driven-releases-for-skills-and-packs.md`](../../../../docs/ADR/ADR-0001-registry-driven-releases-for-skills-and-packs.md) — release model.
