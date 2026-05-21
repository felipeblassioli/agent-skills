#!/usr/bin/env python3
"""Hot-path auditor for Cursor skills and packs.

Produces advisory, evidence-only JSON describing prompt-visible source
surfaces (frontmatter descriptions, SKILL.md routers, named duplication
buckets). The auditor does not call a tokenizer and does not classify by
abstract token estimates. See
`docs/superpowers/specs/2026-05-21-skill-studio-token-economy-audit-design.md`
for the contract, thresholds, and design decisions (D1-D10).
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any

SCHEMA_VERSION = 1
GENERATED_BY = "skill_hot_path_audit.py"

THRESHOLDS = {
    "description_info": 300,
    "description_warn": 500,
    "description_error": 1024,
    "router_lines_warn": 350,
    "router_lines_error": 500,
    "shared_phrase_min_words": 8,
    "description_heading_phrase_min_words": 5,
}

CAVEATS = [
    "All metrics are character counts of source files; the auditor does not call any tokenizer.",
    "Findings are advisory and do not gate releases.",
    "Roughly 1 token ~= 4 characters for common English models -- use only to ballpark.",
]


def parse_frontmatter(content: str) -> tuple[dict[str, str], str]:
    """Return (frontmatter_dict, body). Supports plain scalars and `>-` blocks."""
    if not content.startswith("---"):
        return {}, content
    parts = content.split("---", 2)
    if len(parts) < 3:
        return {}, content
    frontmatter_text = parts[1]
    body = parts[2].lstrip("\n")

    metadata: dict[str, str] = {}
    lines = frontmatter_text.splitlines()
    i = 0
    while i < len(lines):
        line = lines[i]
        stripped = line.strip()
        if not stripped or ":" not in stripped or stripped.startswith("#"):
            i += 1
            continue
        key, _, rest = stripped.partition(":")
        key = key.strip()
        rest = rest.strip()
        if rest in (">", ">-", "|", "|-"):
            collected: list[str] = []
            i += 1
            while i < len(lines) and (lines[i].startswith("  ") or lines[i].strip() == ""):
                if lines[i].strip():
                    collected.append(lines[i].strip())
                i += 1
            metadata[key] = " ".join(collected)
            continue
        rest = rest.strip("'\"")
        metadata[key] = rest
        i += 1
    return metadata, body


_HEADING_RE = re.compile(r"^(#{1,3})\s+(.+?)\s*$", re.MULTILINE)
_LINK_RE = re.compile(r"\]\(([^)]+)\)")


def _normalize_phrase(text: str) -> str:
    text = re.sub(r"[`*_~\[\]()<>#.,;:!?\"'/]", " ", text)
    text = text.replace("-", " ")
    text = re.sub(r"\s+", " ", text)
    return text.strip().lower()


def _word_count(text: str) -> int:
    return len(text.split())


def _extract_applicability_bullets(body: str) -> list[str]:
    bullets: list[str] = []
    capture = False
    for line in body.splitlines():
        m = re.match(r"^#{1,3}\s+(.*)", line)
        if m:
            heading = m.group(1).lower()
            capture = "applicability" in heading
            continue
        if capture:
            bullet = re.match(r"^\s*[-*]\s+(.*)", line)
            if bullet:
                bullets.append(bullet.group(1).strip())
    return bullets


def _description_repeats_body_heading(description: str, body: str, min_words: int) -> list[dict[str, str]]:
    if not description:
        return []
    desc_norm = _normalize_phrase(description)
    findings: list[dict[str, str]] = []
    seen: set[str] = set()
    for match in _HEADING_RE.finditer(body):
        heading = match.group(2)
        heading_norm = _normalize_phrase(heading)
        if not heading_norm or _word_count(heading_norm) < min_words:
            continue
        if heading_norm in desc_norm and heading_norm not in seen:
            seen.add(heading_norm)
            findings.append({
                "bucket": "description_repeats_body_heading",
                "evidence": f"Heading '{heading.strip()}' also appears in the frontmatter description.",
            })
    return findings


def _applicability_gate_repeats_description(description: str, body: str) -> list[dict[str, str]]:
    if not description:
        return []
    desc_norm = _normalize_phrase(description)
    out: list[dict[str, str]] = []
    for bullet in _extract_applicability_bullets(body):
        bnorm = _normalize_phrase(bullet)
        if not bnorm or _word_count(bnorm) < 4:
            continue
        if bnorm in desc_norm or desc_norm in bnorm:
            out.append({
                "bucket": "applicability_gate_repeats_description",
                "evidence": f"Applicability bullet '{bullet[:80]}' overlaps with the description.",
            })
            break  # one entry per skill is enough as evidence
    return out


def audit_skill(skill_dir: Path) -> dict[str, Any]:
    skill_md = skill_dir / "SKILL.md"
    if not skill_md.exists():
        raise SystemExit(f"Error: SKILL.md not found in {skill_dir}")
    content = skill_md.read_text(errors="replace")
    metadata, body = parse_frontmatter(content)

    name = metadata.get("name", skill_dir.name)
    description = metadata.get("description", "")
    disable_invocation = metadata.get("disable-model-invocation", "false").strip().lower() == "true"

    lines = body.splitlines()
    description_chars = len(description)
    body_chars = len(body)

    refs_dir = skill_dir / "references"
    assets_dir = skill_dir / "assets"
    scripts_dir = skill_dir / "scripts"

    def _count(p: Path) -> int:
        if not p.exists():
            return 0
        return sum(1 for entry in p.iterdir() if entry.is_file())

    links = _LINK_RE.findall(body)

    findings: list[dict[str, Any]] = []
    if description_chars > THRESHOLDS["description_error"]:
        findings.append({
            "id": "description_exceeds_cursor_limit",
            "severity": "error",
            "value": description_chars,
            "threshold": THRESHOLDS["description_error"],
            "rationale": "Cursor's hard frontmatter description limit; descriptions above this are truncated or rejected.",
        })
    elif description_chars > THRESHOLDS["description_warn"]:
        findings.append({
            "id": "long_description",
            "severity": "warn",
            "value": description_chars,
            "threshold": THRESHOLDS["description_warn"],
            "rationale": "Above description_warn (calibrated against studio routers); consider keyword-tag form.",
        })
    elif description_chars > THRESHOLDS["description_info"]:
        findings.append({
            "id": "long_description_info",
            "severity": "info",
            "value": description_chars,
            "threshold": THRESHOLDS["description_info"],
            "rationale": "Above description_info soft target for compact routing tags.",
        })

    if len(lines) > THRESHOLDS["router_lines_error"]:
        findings.append({
            "id": "router_over_hard_cap",
            "severity": "error",
            "value": len(lines),
            "threshold": THRESHOLDS["router_lines_error"],
            "rationale": "Above the validate-skill.sh hard cap for SKILL.md length.",
        })
    elif len(lines) > THRESHOLDS["router_lines_warn"]:
        findings.append({
            "id": "router_too_long",
            "severity": "warn",
            "value": len(lines),
            "threshold": THRESHOLDS["router_lines_warn"],
            "rationale": "Above inspect-candidate-skill.sh warning length; move detail to references.",
        })

    procedural_markers = ("Invoke explicitly via", "Use when")
    if disable_invocation and any(marker in description for marker in procedural_markers):
        findings.append({
            "id": "procedural_description",
            "severity": "info",
            "value": None,
            "threshold": None,
            "rationale": "Router skill (disable-model-invocation: true) still pays description cost; prefer keyword-tag form over 'Use when' prose.",
        })

    duplication = (
        _description_repeats_body_heading(description, body, THRESHOLDS["description_heading_phrase_min_words"])
        + _applicability_gate_repeats_description(description, body)
    )
    duplication.sort(key=lambda d: (d["bucket"], d["evidence"]))
    findings.extend({
        "id": d["bucket"],
        "severity": "info",
        "value": None,
        "threshold": None,
        "rationale": d["evidence"],
    } for d in duplication)
    findings.sort(key=lambda f: (f["id"], str(f.get("value"))))

    return {
        "identity": {
            "path": str(skill_dir),
            "name": name,
            "description": description,
            "disable_model_invocation": disable_invocation,
        },
        "hot_path_metrics": {
            "skill_md_lines": len(lines),
            "skill_md_body_chars": body_chars,
            "description_chars": description_chars,
        },
        "package_shape": {
            "references_count": _count(refs_dir),
            "assets_count": _count(assets_dir),
            "scripts_count": _count(scripts_dir),
            "direct_links_count": len(set(links)),
        },
        "duplication_buckets": duplication,
        "findings": findings,
    }


def _multi_skill_shared_phrases(skill_results: list[dict[str, Any]], pack_dir: Path, min_words: int) -> list[dict[str, Any]]:
    by_skill: dict[str, set[str]] = {}
    for sk in skill_results:
        path = Path(sk["identity"]["path"]) / "SKILL.md"
        text = path.read_text(errors="replace") if path.exists() else ""
        _, body = parse_frontmatter(text)
        words = _normalize_phrase(body).split()
        phrases: set[str] = set()
        for i in range(0, max(0, len(words) - min_words + 1)):
            phrases.add(" ".join(words[i : i + min_words]))
        by_skill[sk["identity"]["name"]] = phrases

    phrase_to_skills: dict[str, list[str]] = {}
    for name, phrases in by_skill.items():
        for phrase in phrases:
            phrase_to_skills.setdefault(phrase, []).append(name)

    out: list[dict[str, Any]] = []
    seen_substrings: list[str] = []
    for phrase, names in sorted(phrase_to_skills.items()):
        if len(set(names)) < 2:
            continue
        if any(phrase in longer for longer in seen_substrings):
            continue
        seen_substrings.append(phrase)
        out.append({
            "bucket": "multi_skill_shared_phrase",
            "phrase": phrase,
            "skills": sorted(set(names)),
        })
    return out[:20]  # cap output noise


def _pack_readme_duplicates_intent_table(pack_dir: Path, skill_results: list[dict[str, Any]]) -> list[dict[str, Any]]:
    readme = pack_dir / "README.md"
    if not readme.exists():
        return []
    readme_text = _normalize_phrase(readme.read_text(errors="replace"))
    out: list[dict[str, Any]] = []
    for sk in skill_results:
        skill_md = Path(sk["identity"]["path"]) / "SKILL.md"
        if not skill_md.exists():
            continue
        text = skill_md.read_text(errors="replace")
        for row in re.findall(r"^\|\s*([^|]{6,80})\s*\|\s*([^|]{6,80})\s*\|", text, flags=re.MULTILINE):
            cell0 = _normalize_phrase(row[0])
            cell1 = _normalize_phrase(row[1])
            if (
                _word_count(cell0) >= 3
                and _word_count(cell1) >= 3
                and cell0 in readme_text
                and cell1 in readme_text
            ):
                out.append({
                    "bucket": "pack_readme_duplicates_intent_table",
                    "evidence": f"README mirrors '{row[0].strip()}' / '{row[1].strip()}' from {sk['identity']['name']}.",
                })
                break
    return out


def _audit_rules(pack_dir: Path) -> list[dict[str, Any]]:
    rules_dir = pack_dir / ".cursor" / "rules"
    if not rules_dir.exists():
        return []
    out: list[dict[str, Any]] = []
    for path in sorted(rules_dir.glob("*.mdc")):
        text = path.read_text(errors="replace")
        meta, _ = parse_frontmatter(text)
        always_apply = meta.get("alwaysApply", "false").strip().lower() == "true"
        description = meta.get("description", "")
        out.append({
            "path": str(path.relative_to(pack_dir)),
            "always_apply": always_apply,
            "description_chars": len(description),
        })
    return out


def _audit_agents(pack_dir: Path) -> list[dict[str, Any]]:
    agents_dir = pack_dir / ".cursor" / "agents"
    if not agents_dir.exists():
        return []
    out: list[dict[str, Any]] = []
    for path in sorted(agents_dir.glob("*.md")):
        text = path.read_text(errors="replace")
        meta, _ = parse_frontmatter(text)
        description = meta.get("description", "")
        out.append({
            "path": str(path.relative_to(pack_dir)),
            "description_chars": len(description),
        })
    return out


def audit_pack(pack_dir: Path) -> dict[str, Any]:
    skills_dir = pack_dir / "skills"
    skills: list[dict[str, Any]] = []
    if skills_dir.exists():
        for child in sorted(skills_dir.iterdir()):
            if child.is_dir() and (child / "SKILL.md").exists():
                skills.append(audit_skill(child))

    pack_json = pack_dir / "pack.json"
    pack_desc_chars = 0
    if pack_json.exists():
        try:
            data = json.loads(pack_json.read_text(errors="replace"))
            pack_desc_chars = len(data.get("description", ""))
        except json.JSONDecodeError:
            pack_desc_chars = 0

    cross_buckets = (
        _multi_skill_shared_phrases(skills, pack_dir, THRESHOLDS["shared_phrase_min_words"])
        + _pack_readme_duplicates_intent_table(pack_dir, skills)
    )
    cross_buckets.sort(key=lambda d: (d["bucket"], d.get("phrase", d.get("evidence", ""))))

    return {
        "name": pack_dir.name,
        "pack_json_description_chars": pack_desc_chars,
        "rules": _audit_rules(pack_dir),
        "agents": _audit_agents(pack_dir),
        "cross_skill_duplication_buckets": cross_buckets,
    }


def audit_target(path: Path) -> dict[str, Any]:
    if (path / "pack.json").exists():
        pack_audit = audit_pack(path)
        return {
            "schema_version": SCHEMA_VERSION,
            "generated_by": GENERATED_BY,
            "target_kind": "pack",
            "thresholds": THRESHOLDS,
            "skills": [audit_skill(Path(s)) for s in sorted(str(p) for p in (path / "skills").iterdir() if p.is_dir() and (p / "SKILL.md").exists())] if (path / "skills").exists() else [],
            "pack": pack_audit,
            "runtime_observations": None,
            "caveats": CAVEATS,
        }
    if (path / "SKILL.md").exists():
        return {
            "schema_version": SCHEMA_VERSION,
            "generated_by": GENERATED_BY,
            "target_kind": "skill",
            "thresholds": THRESHOLDS,
            "skills": [audit_skill(path)],
            "runtime_observations": None,
            "caveats": CAVEATS,
        }
    children = [c for c in sorted(path.iterdir()) if c.is_dir() and (c / "SKILL.md").exists()]
    if not children:
        raise SystemExit(f"Error: no SKILL.md or pack.json found under {path}")
    return {
        "schema_version": SCHEMA_VERSION,
        "generated_by": GENERATED_BY,
        "target_kind": "skills_dir",
        "thresholds": THRESHOLDS,
        "skills": [audit_skill(c) for c in children],
        "runtime_observations": None,
        "caveats": CAVEATS,
    }


def _canonicalize_for_snapshot(result: dict[str, Any], root: Path) -> dict[str, Any]:
    """Strip absolute paths so snapshots are stable across machines."""
    text = json.dumps(result)
    text = text.replace(str(root.resolve()), "<ROOT>")
    return json.loads(text)


def main() -> None:
    parser = argparse.ArgumentParser(description="Hot-path auditor for Cursor skills and packs.")
    parser.add_argument("path", type=Path, help="Path to a skill folder, skills dir, or pack folder")
    parser.add_argument("--json", action="store_true", help="Pretty-print JSON to stdout (default).")
    parser.add_argument(
        "--write-snapshot",
        type=Path,
        default=None,
        help="Write canonicalized JSON to this file (paths relative to <path>). Overwrites the file.",
    )
    args = parser.parse_args()

    target = args.path.resolve()
    if not target.exists():
        raise SystemExit(f"Error: {target} does not exist")

    result = audit_target(target)

    if args.write_snapshot:
        canon = _canonicalize_for_snapshot(result, target)
        args.write_snapshot.write_text(json.dumps(canon, indent=2, sort_keys=True) + "\n")
        print(f"Wrote snapshot to {args.write_snapshot}")
        return

    print(json.dumps(result, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
