#!/usr/bin/env python3
"""PDK-free append-only check for sim/ records. Stdlib only.

Protects evidence, not code: every file under a `record`/`records` directory
inside `sim/` is append-only — a pull request may add one, never modify,
delete or rename it (a rename is a delete of the old path). The harness and
index files around the records (`sim/README.md`, each probe's `README.md` and
`run.sh`, `sim/lib/*`, `sim/pdk.json`) stay modifiable, so the sim index can
track new probes and the harness can be maintained: spec/io-ring.md SIGN.6
("results are append-only") covers the results, not the code that produces
them. The `record*` glob is the same marker `.gitignore` uses for committed
evidence, so the two agree by construction. Reads `git diff --name-status`.

  check_append_only.py BASE_REF       # compares BASE_REF...HEAD
"""
import subprocess
import sys
from pathlib import Path

PROTECTED = "sim/"


def is_record_path(path):
    """True if `path` lies under a record/records directory inside sim/."""
    return any(p.startswith("record") for p in Path(path).parts[1:-1])


def violations(name_status):
    """Return error strings for `git diff --name-status --no-renames` output."""
    errors = []
    for line in name_status.splitlines():
        status, _, path = line.partition("\t")
        if (path.startswith(PROTECTED) and is_record_path(path)
                and status.strip() != "A"):
            errors.append(f"{path}: status {status.strip()!r}; sim/ records are append-only "
                          "(add a new record, do not edit or delete one)")
    return errors


def main(argv=None):
    args = argv or sys.argv[1:]
    if len(args) != 1:
        print(__doc__, file=sys.stderr)
        return 2
    out = subprocess.run(["git", "diff", "--name-status", "--no-renames", f"{args[0]}...HEAD", "--", PROTECTED],
                         check=True, capture_output=True, text=True).stdout
    errors = violations(out)
    if errors:
        print("append-only check FAILED:", file=sys.stderr)
        for e in errors:
            print(f"  - {e}", file=sys.stderr)
        return 1
    print(f"append-only check passed against {args[0]}.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
