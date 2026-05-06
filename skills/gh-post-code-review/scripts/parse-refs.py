#!/usr/bin/env python3
"""Parse a structured code-review markdown into findings JSON.

stdin:  the review markdown
stdout: JSON array of findings:
  [
    {
      "id": "B1",
      "severity": "BLOCKER",   # BLOCKER | HIGH | MEDIUM | LOW | QUESTION
      "title": "Mechanism cannot solve ...",
      "body":  "...finding body without the fenced code-ref block...",
      "anchors": [
        {"path": "...", "start_line": 446, "line": 514, "side": "RIGHT"}
      ],
      "inline": true                      # false if no anchors
    },
    ...
  ]

The parser recognizes:
  - Severity section headers: `### BLOCKER`, `### HIGH`, etc. (case-sensitive).
  - Finding headers: lines like `**B1 — title**` or `**H2 — title**` where
    the prefix letter matches the current severity bucket
    (B/H/M/L/Q -> BLOCKER/HIGH/MEDIUM/LOW/QUESTION).
  - Code refs: fenced blocks whose info string matches `^\\d+:\\d+:.+$`.

Limitations:
  - `side` is always "RIGHT" (see references/code-ref-parsing.md).
  - Severity must be marked by `### <SEV>` headers; freeform text is ignored.
  - Verdict line and any text before the first severity header is returned
    in stderr metadata, not in the findings array.
"""
from __future__ import annotations

import json
import re
import sys
from typing import Optional

SEVERITIES = ["BLOCKER", "HIGH", "MEDIUM", "LOW", "QUESTION"]
SEV_BY_PREFIX = {"B": "BLOCKER", "H": "HIGH", "M": "MEDIUM", "L": "LOW", "Q": "QUESTION"}

SEV_HEADER_RE = re.compile(r"^###\s+(" + "|".join(SEVERITIES) + r")\s*$")
FINDING_HEADER_RE = re.compile(r"^\*\*([BHMLQ])(\d+)\s*[—\-:]\s*(.+?)\*\*\s*$")
FENCE_RE = re.compile(r"^([`~]{3,})\s*(.*)$")
CODE_REF_INFO_RE = re.compile(r"^(\d+):(\d+):(.+)$")


def parse(md: str) -> list[dict]:
    findings: list[dict] = []
    current_sev: Optional[str] = None
    current: Optional[dict] = None

    in_fence = False
    fence_marker = ""
    fence_info = ""
    fence_buf: list[str] = []

    def flush_finding():
        nonlocal current
        if current is None:
            return
        # Strip trailing blank lines from body.
        while current["body"] and not current["body"][-1].strip():
            current["body"].pop()
        current["body"] = "\n".join(current["body"]).strip()
        current["inline"] = bool(current["anchors"])
        findings.append(current)
        current = None

    for raw in md.splitlines():
        line = raw.rstrip("\n")

        if in_fence:
            # Closing fence?
            if line.startswith(fence_marker[0] * 3) and line.strip() == fence_marker:
                in_fence = False
                m = CODE_REF_INFO_RE.match(fence_info.strip())
                if m and current is not None:
                    start = int(m.group(1))
                    end = int(m.group(2))
                    path = m.group(3).strip()
                    if 0 < start <= end:
                        current["anchors"].append(
                            {
                                "path": path,
                                "start_line": start,
                                "line": end,
                                "side": "RIGHT",
                            }
                        )
                # Otherwise: regular fence; keep its text in the body.
                if not (m and current is not None):
                    if current is not None:
                        current["body"].append(fence_marker + (" " + fence_info if fence_info else ""))
                        current["body"].extend(fence_buf)
                        current["body"].append(fence_marker)
                fence_buf = []
                fence_info = ""
                fence_marker = ""
                continue
            fence_buf.append(line)
            continue

        # Opening fence?
        fm = FENCE_RE.match(line)
        if fm:
            in_fence = True
            fence_marker = fm.group(1)
            fence_info = fm.group(2)
            fence_buf = []
            continue

        sm = SEV_HEADER_RE.match(line)
        if sm:
            flush_finding()
            current_sev = sm.group(1)
            continue

        fhm = FINDING_HEADER_RE.match(line)
        if fhm and current_sev is not None:
            prefix = fhm.group(1)
            num = fhm.group(2)
            title = fhm.group(3).strip()
            expected = SEV_BY_PREFIX[prefix]
            if expected != current_sev:
                # Mismatch (e.g. an H2 under BLOCKER) — trust the header bucket.
                pass
            flush_finding()
            current = {
                "id": f"{prefix}{num}",
                "severity": current_sev,
                "title": title,
                "body": [],
                "anchors": [],
            }
            continue

        if current is not None:
            current["body"].append(line)

    flush_finding()
    return findings


def main() -> int:
    md = sys.stdin.read()
    findings = parse(md)
    json.dump(findings, sys.stdout, ensure_ascii=False, indent=2)
    sys.stdout.write("\n")
    counts = {sev: 0 for sev in SEVERITIES}
    for f in findings:
        counts[f["severity"]] += 1
    sys.stderr.write(f"parsed {len(findings)} findings: {counts}\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
