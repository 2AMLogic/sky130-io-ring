#!/usr/bin/env python3
"""PDK-free evidence-format check. Stdlib only.

  1. Each evidence directory (design, layout, sim, measurements, spec) has a README.md.
  2. Each sim record (sim/<experiment>/record/*.json or .../records/*.json) is a JSON
     object with the required fields, a 40-hex pdk_revision, and repo-relative paths
     only (no absolute path, no `..`, no drive letter, no home directory).

Passes trivially when sim/ holds no records. Content is never judged: this checks
that a record is well formed, not that its numbers are right.

  check_evidence_format.py [REPO_ROOT]
"""
import json
import re
import sys
from pathlib import Path

EVIDENCE_DIRS = ["design", "layout", "sim", "measurements", "spec"]
REQUIRED_FIELDS = ["kind", "pdk_revision", "pdk_variant", "runs"]
REVISION_RE = re.compile(r"^[0-9a-f]{40}$")
PATH_KEY_RE = re.compile(r"(^|_)(path|paths|file|files|log|logs|netlist|netlists|dir)$")


def is_record(rel):
    parts = Path(rel).parts
    return (parts[0] == "sim" and rel.endswith(".json")
            and any(p in ("record", "records") for p in parts[1:-1]))


def bad_path(value):
    if not isinstance(value, str) or not value:
        return "not a non-empty string"
    if value.startswith(("/", "~", "\\")) or re.match(r"^[A-Za-z]:[\\/]", value):
        return "absolute path"
    if ".." in re.split(r"[\\/]", value):
        return "parent-directory component"
    return None


def walk_paths(node, where, errors):
    if isinstance(node, dict):
        for k, v in node.items():
            if PATH_KEY_RE.search(k) and isinstance(v, (str, list)):
                for item in (v if isinstance(v, list) else [v]):
                    why = bad_path(item)
                    if why:
                        errors.append(f"{where}: {k}={item!r} is not repo-relative ({why})")
            else:
                walk_paths(v, f"{where}.{k}", errors)
    elif isinstance(node, list):
        for i, v in enumerate(node):
            walk_paths(v, f"{where}[{i}]", errors)


def check_record(text, where):
    """Return a list of error strings for one record's JSON text."""
    try:
        rec = json.loads(text)
    except ValueError as exc:
        return [f"{where}: not valid JSON ({exc})"]
    if not isinstance(rec, dict):
        return [f"{where}: top level must be a JSON object"]
    errors = [f"{where}: missing required field {f!r}" for f in REQUIRED_FIELDS if f not in rec]
    rev = rec.get("pdk_revision")
    if "pdk_revision" in rec and not (isinstance(rev, str) and REVISION_RE.match(rev)):
        errors.append(f"{where}: pdk_revision {rev!r} is not a 40-hex revision")
    walk_paths(rec, where, errors)
    return errors


def check_tree(root):
    root = Path(root)
    errors = [f"missing {d}/README.md: every evidence directory carries a README"
              for d in EVIDENCE_DIRS if not (root / d / "README.md").is_file()]
    n = 0
    for p in sorted((root / "sim").rglob("*.json")) if (root / "sim").is_dir() else []:
        rel = p.relative_to(root).as_posix()
        if is_record(rel):
            n += 1
            errors += check_record(p.read_text(encoding="utf-8"), rel)
    return errors, n


def main(argv=None):
    root = (argv or sys.argv[1:] or ["."])[0]
    errors, n = check_tree(root)
    if errors:
        print("evidence-format check FAILED:", file=sys.stderr)
        for e in errors:
            print(f"  - {e}", file=sys.stderr)
        return 1
    print(f"evidence-format check passed: {len(EVIDENCE_DIRS)} READMEs, {n} sim record(s).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
