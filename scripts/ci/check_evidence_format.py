#!/usr/bin/env python3
"""PDK-free evidence-format check. Stdlib only.

  1. Each evidence directory (design, layout, sim, measurements, spec) has a README.md.
  2. Each sim record (sim/<experiment>/record/*.json or .../records/*.json) is a JSON
     object with the required fields, a 40-hex pdk_revision, and repo-relative paths
     only (no absolute path, no `..`, no drive letter, no home directory). Each
     path-shaped value must also resolve, relative to the record's own directory,
     to a file or directory that exists — a dangling reference fails.
  3. Field-naming well-formedness (R1 of sim/README.md's "Record field
     conventions"): within one object, numeric sibling keys sharing a leading
     parameter token (text before the first `_`) must not hold exactly equal
     values while any of them carries a `_per_m2` / `_per_m` / `_per_um2` /
     `_per_um` suffix — that shape means two field names assert different
     unit domains for one and the same figure. Grouping is on the leading
     token, not a suffix-stripped stem (stem splitting cannot pair
     `cj_card_F_per_m2` with `cj_prescaled`). `sim/diode-unit-probe/record/record.json`
     is grandfathered: it is append-only evidence committed before this rule
     and cannot be corrected in place — its own `conclusion` and the erratum
     in its README carry the correct reading (2AMLogic/sky130-io-ring#120).

Passes trivially when sim/ holds no records. Content is otherwise never judged
beyond field-naming well-formedness (rule 3 below): this checks that a record
is well formed, that its referenced files are present, and that field names do
not contradict each other about unit domains — it never judges whether a
recorded number is itself right.

  check_evidence_format.py [REPO_ROOT]
"""
import json
import re
import sys
from pathlib import Path

EVIDENCE_DIRS = ["design", "layout", "sim", "measurements", "spec"]
REQUIRED_FIELDS = ["kind", "pdk_revision", "pdk_variant", "runs"]
REVISION_RE = re.compile(r"^[0-9a-f]{40}$")
PATH_KEY_RE = re.compile(r"(^|_)(path|paths|file|files|log|logs|netlist|netlists|dir|dirs)$")
UNIT_SUFFIX_RE = re.compile(r"_per_(m2|m|um2|um)$")

# R1 field-naming rule grandfather: this record predates the rule (sim/README.md,
# "Record field conventions"), is append-only evidence, and cannot be corrected
# in place — its own `conclusion` and the erratum in sim/diode-unit-probe/README.md
# carry the correct reading. It is the only committed record the rule would
# reject. (2AMLogic/sky130-io-ring#120)
GRANDFATHERED_FIELD_NAMES = {"sim/diode-unit-probe/record/record.json"}


def is_record(rel):
    parts = Path(rel).parts
    return (parts[0] == "sim" and rel.endswith(".json")
            and any(p in ("record", "records") for p in parts[1:-1]))


def bad_path(value, base=None):
    """Return the full reason phrase for a rejected path value, or None.

    The phrase is composed here — the only place that knows which condition
    fired — so each failure names its own defect instead of borrowing the
    shape-failure prefix ("is not repo-relative").
    """
    if not isinstance(value, str) or not value:
        return "is not a usable path (not a non-empty string)"
    if value.startswith(("/", "~", "\\")) or re.match(r"^[A-Za-z]:[\\/]", value):
        return "is not repo-relative (absolute path)"
    if ".." in re.split(r"[\\/]", value):
        return "is not repo-relative (parent-directory component)"
    if base is not None and not (Path(base) / value).exists():
        return "does not exist (no such file)"
    return None


def walk_paths(node, where, errors, base=None):
    if isinstance(node, dict):
        for k, v in node.items():
            if PATH_KEY_RE.search(k) and isinstance(v, (str, list)):
                for item in (v if isinstance(v, list) else [v]):
                    why = bad_path(item, base)
                    if why:
                        errors.append(f"{where}: {k}={item!r} {why}")
            else:
                walk_paths(v, f"{where}.{k}", errors, base)
    elif isinstance(node, list):
        for i, v in enumerate(node):
            walk_paths(v, f"{where}[{i}]", errors, base)


def check_field_names(node, where, errors, path=""):
    """R1 (issue #120): a field name states the unit domain of its number.

    Within one object, group numeric sibling keys by their leading parameter
    token (text before the first `_`) and reject a group in which two or more
    keys hold exactly equal values while any carries a `_per_(m2|m|um2|um)`
    suffix — the shape of two names asserting different unit domains for one
    figure (`cj_card_F_per_m2` == `cj_prescaled`). Booleans are not numeric;
    a key pair that is equal but carries no unit-domain suffix passes.
    """
    if isinstance(node, dict):
        groups = {}
        for k, v in node.items():
            if isinstance(v, bool) or not isinstance(v, (int, float)):
                continue
            groups.setdefault(k.split("_", 1)[0], []).append((k, v))
        for lead, members in sorted(groups.items()):
            by_value = {}
            for k, v in members:
                by_value.setdefault(v, []).append(k)
            for value, keys in sorted(by_value.items(), key=lambda kv: str(kv[0])):
                if len(keys) < 2:
                    continue
                suffixed = [k for k in keys if UNIT_SUFFIX_RE.search(k)]
                if not suffixed:
                    continue
                errors.append(
                    f"{where}{path}: sibling keys {', '.join(repr(k) for k in keys)} "
                    f"(leading token {lead!r}) hold exactly equal value {value!r} "
                    f"while {', '.join(repr(k) for k in suffixed)} carries a "
                    f"unit-domain suffix — a field name must state the unit domain "
                    f"of the number it holds (R1, sim/README.md 'Record field "
                    f"conventions'); record the one figure you have, named for "
                    f"its actual domain")
        for k, v in node.items():
            check_field_names(v, where, errors, f"{path}.{k}")
    elif isinstance(node, list):
        for i, v in enumerate(node):
            check_field_names(v, where, errors, f"{path}[{i}]")


def check_record(text, where, base=None):
    """Return a list of error strings for one record's JSON text.

    `base` is the directory the record's path-shaped values resolve against
    (the record's own directory); without it only the shape is checked.
    """
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
    walk_paths(rec, where, errors, base)
    if where not in GRANDFATHERED_FIELD_NAMES:
        check_field_names(rec, where, errors)
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
            errors += check_record(p.read_text(encoding="utf-8"), rel, base=p.parent)
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
