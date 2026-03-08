# Release Policy

`cursor-companion` is a maintained reference pack. Keep these release artifacts
committed:

- `CHANGELOG.md`
- `VERIFICATION.md`
- `ROADMAP.md`

## Minimum release expectations

1. update `pack.json.version`
2. update `cursor-pack-registry.json`
3. update `CHANGELOG.md`
4. append verification evidence in `VERIFICATION.md`
5. revise `ROADMAP.md` if next steps changed

## Verification standard

Every meaningful release should record:

- `bash scripts/cursor-pack-verify.sh --pack=cursor-companion`
- relevant dry-run install commands for changed targets or profiles
