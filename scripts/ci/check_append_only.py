#!/usr/bin/env python3
"""PDK-free append-only check for sim/ records. Stdlib only.

A pull request may add files under sim/, never modify, delete or rename one
(a rename is a delete of the old path). Reads `git diff --name-status`.

  check_append_only.py BASE_REF       # compares BASE_REF...HEAD
"""
import subprocess
import sys

PROTECTED = "sim/"


def violations(name_status):
    """Return error strings for `git diff --name-status --no-renames` output."""
    errors = []
    for line in name_status.splitlines():
        status, _, path = line.partition("\t")
        if path.startswith(PROTECTED) and status.strip() != "A":
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
