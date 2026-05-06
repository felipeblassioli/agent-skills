# Parsing Cursor `start:end:path` code refs

Cursor renders existing-code citations as fenced blocks whose info string is
`START:END:PATH`. Example:

````
```446:514:functions/application/routes/v2/risk.v2.route.js
router.post('/keep-alive/monitor/:monitorId/tick', async (req, res, next) => {
  ...
});
```
````

The skill parses these into GitHub inline comment anchors.

## Grammar

- Info string regex: `^(\d+):(\d+):(.+)$`
- Group 1 = `start_line` (1-indexed, inclusive).
- Group 2 = `line` (1-indexed, inclusive). For single-line refs, `start == line`.
- Group 3 = `path` relative to repo root (no leading `/`).
- The fenced body is shown to humans; the GitHub anchor uses only the
  numbers + path.

## Mapping to GitHub `comments[]`

For each parsed ref:

```json
{
  "path": "<group3>",
  "side": "RIGHT",
  "start_side": "RIGHT",
  "start_line": <group1>,
  "line": <group2>
}
```

If `start_line == line`, omit `start_line` and `start_side` (single-line
form).

## `side` selection

- Default: `RIGHT` (the new file in the diff).
- If the finding text mentions a **deleted** line ("removed in this PR",
  "this previously did X"), set `side: "LEFT"`. The parser cannot reliably
  detect this; surface as a warning and let the user toggle.

## Multiple refs per finding

If a single finding has multiple fenced refs, emit one inline comment per
ref. They share the same `body` (with the finding's text) but each anchors
to its own range. The first ref carries the finding's full body; subsequent
refs carry a short pointer like `↑ see <id>`.

## Findings with no code ref

Set `inline: false` and fold into the top-level review body (per
`severity-mapping.md`). Common cases: `QUESTION`s, `MEDIUM` infrastructure
notes, "What was verified" sections.

## Edge cases

- **`start > end`** — invalid; warn and skip the ref (treat as no code ref).
- **`path` not in PR diff** — skip with `reason: "path not in PR diff"`;
  surface in `skipped_findings`. This commonly happens when the review
  cites a file the author didn't actually touch.
- **Lines outside the diff hunks** — GitHub may reject. Validate via
  `gh api /repos/O/R/pulls/N/files --paginate --jq '.[].filename'` for
  presence; line-range checking against patch hunks is best-effort
  (parse `@@ -a,b +c,d @@` and require `c <= start && line <= c+d-1`).
- **Refs in fenced blocks of fenced blocks** — the parser must scan fence
  pairs left-to-right and ignore nested fences (use `````` and `\`\`\`` both
  treated as fences; track fence count).
- **Refs across renamed files** — GitHub anchors must use the **new** path.
  If the review cites the old path, skip with a clear `reason`.
