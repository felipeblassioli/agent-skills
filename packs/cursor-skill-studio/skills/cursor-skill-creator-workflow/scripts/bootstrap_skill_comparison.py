#!/usr/bin/env python3
"""Create a deterministic workspace for comparing two skills.

The script scaffolds eval directories and metadata only. It does not execute
agents, grade outputs, or overwrite existing workspaces unless a new comparison
name or iteration is chosen.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


def slugify(value: str) -> str:
    slug = re.sub(r"[^a-z0-9]+", "-", value.lower()).strip("-")
    return slug or "eval"


def utc_now() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def load_evals(path: Path) -> dict[str, Any]:
    try:
        data = json.loads(path.read_text())
    except FileNotFoundError:
        raise SystemExit(f"evals file not found: {path}") from None
    except json.JSONDecodeError as exc:
        raise SystemExit(f"invalid JSON in {path}: {exc}") from None

    evals = data.get("evals")
    if not isinstance(evals, list) or not evals:
        raise SystemExit("evals JSON must contain a non-empty 'evals' array")

    for index, item in enumerate(evals):
        if not isinstance(item, dict):
            raise SystemExit(f"evals[{index}] must be an object")
        if not item.get("prompt"):
            raise SystemExit(f"evals[{index}] is missing 'prompt'")

    return data


def next_iteration_dir(comparison_dir: Path) -> Path:
    existing = [
        int(match.group(1))
        for child in comparison_dir.glob("iteration-*")
        if (match := re.fullmatch(r"iteration-(\d+)", child.name))
    ]
    next_number = max(existing, default=0) + 1
    return comparison_dir / f"iteration-{next_number}"


def write_json(path: Path, data: dict[str, Any]) -> None:
    path.write_text(json.dumps(data, indent=2) + "\n")


def build_workspace(args: argparse.Namespace) -> Path:
    evals_path = Path(args.evals).resolve()
    evals_data = load_evals(evals_path)

    comparison_name = slugify(args.comparison_name)
    workspace_root = Path(args.workspace_root)
    comparison_dir = workspace_root / comparison_name
    iteration_dir = (
        comparison_dir / f"iteration-{args.iteration}"
        if args.iteration
        else next_iteration_dir(comparison_dir)
    )

    if iteration_dir.exists():
        raise SystemExit(
            f"iteration already exists: {iteration_dir}. Choose another --iteration "
            "or comparison name."
        )

    labels = [args.label_a, args.label_b]
    if labels[0] == labels[1]:
        raise SystemExit("labels must be different")

    comparison_dir.mkdir(parents=True, exist_ok=True)
    iteration_dir.mkdir(parents=True)

    # Keep a workspace-local copy so later runs remain reproducible if the source
    # eval file changes.
    write_json(comparison_dir / "evals.json", evals_data)

    created_at = utc_now()
    configurations = [
        {
            "label": args.label_a,
            "skill_path": args.skill_a,
            "role": args.role_a,
        },
        {
            "label": args.label_b,
            "skill_path": args.skill_b,
            "role": args.role_b,
        },
    ]

    manifest = {
        "comparison_name": comparison_name,
        "created_at": created_at,
        "iteration": iteration_dir.name,
        "configurations": configurations,
        "evals_path": "evals.json",
        "runs_per_configuration": args.runs,
    }
    write_json(comparison_dir / "comparison_manifest.json", manifest)

    inventory = {
        "generated_at": created_at,
        "skills": [
            {
                "label": config["label"],
                "skill_path": config["skill_path"],
                "role": config["role"],
            }
            for config in configurations
        ],
        "findings": [],
    }
    write_json(comparison_dir / "skill_inventory.json", inventory)

    for index, item in enumerate(evals_data["evals"]):
        eval_id = item.get("id", index)
        eval_name = item.get("name") or item.get("eval_name") or f"eval-{eval_id}"
        eval_dir = iteration_dir / f"eval-{eval_id}-{slugify(str(eval_name))}"
        eval_dir.mkdir()

        metadata = {
            "eval_id": eval_id,
            "eval_name": str(eval_name),
            "prompt": item["prompt"],
            "expected_output": item.get("expected_output", ""),
            "files": item.get("files", []),
            "assertions": item.get("expectations", item.get("assertions", [])),
        }
        write_json(eval_dir / "eval_metadata.json", metadata)

        for label in labels:
            for run_number in range(1, args.runs + 1):
                outputs_dir = eval_dir / label / f"run-{run_number}" / "outputs"
                outputs_dir.mkdir(parents=True)

    return comparison_dir


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Bootstrap a .work skill comparison workspace"
    )
    parser.add_argument("--comparison-name", required=True)
    parser.add_argument("--skill-a", required=True)
    parser.add_argument("--skill-b", required=True)
    parser.add_argument("--evals", required=True, help="Path to evals.json")
    parser.add_argument(
        "--workspace-root",
        default=".work/skill-creator",
        help="Root directory for comparison workspaces",
    )
    parser.add_argument("--iteration", type=int, help="Iteration number to create")
    parser.add_argument("--runs", type=int, default=1, help="Runs per skill/eval")
    parser.add_argument("--label-a", default="skill-a")
    parser.add_argument("--label-b", default="skill-b")
    parser.add_argument("--role-a", default="baseline")
    parser.add_argument("--role-b", default="candidate")

    args = parser.parse_args(argv)
    if args.runs < 1:
        parser.error("--runs must be >= 1")
    if args.iteration is not None and args.iteration < 1:
        parser.error("--iteration must be >= 1")
    return args


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv or sys.argv[1:])
    comparison_dir = build_workspace(args)
    print(f"Created comparison workspace: {comparison_dir}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
