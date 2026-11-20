#!/usr/bin/env python3
"""PDK-independent harness helpers: ngspice log parsing and append-only records.

Names no PDK path, device or corner; callers pass those in. Stdlib only.

  simrec.py parse LOG                      -> JSON of RESULT lines and error flags
  simrec.py write RECORD --meta JSON [--log NAME=PATH]... [--expect NAME=R1,R2,...]...
      --expect: run NAME converged only if every named RESULT line is present
      and every numeric value in it is finite (a partial log is not converged)
"""
import argparse
import json
import math
import re
import sys
from pathlib import Path

RESULT_RE = re.compile(r"^RESULT\s+(.*)$")
ERROR_RE = re.compile(r"(?i)\b(error|singular matrix|no convergence|timestep too small|aborted)\b")


def parse_log(text):
    """Return ({name: {key: value}}, [error lines]) from `RESULT name k=v ...` lines."""
    results, errors = {}, []
    for line in text.splitlines():
        m = RESULT_RE.match(line.strip())
        if m:
            name, *pairs = m.group(1).split()
            vals = {}
            for p in pairs:
                k, _, v = p.partition("=")
                try:
                    vals[k] = float(v)
                except ValueError:
                    vals[k] = v
            results[name] = vals
        elif ERROR_RE.search(line):
            errors.append(line.strip())
    return results, errors


def check_expected(results, names):
    """Error strings for expected RESULT names that are missing or hold non-finite numbers."""
    errs = []
    for n in names:
        if n not in results:
            errs.append(f"missing expected RESULT {n}")
            continue
        for k, v in results[n].items():
            if isinstance(v, float) and not math.isfinite(v):
                errs.append(f"non-finite value in RESULT {n}: {k}={v}")
    return errs


def write_record(path, record):
    """Write a JSON record; records are append-only, so never replace one."""
    path = Path(path)
    if path.exists():
        raise FileExistsError(f"{path} exists; records are append-only, use a new name")
    path.write_text(json.dumps(record, indent=2, sort_keys=True) + "\n")


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__)
    sub = ap.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("parse")
    p.add_argument("log")
    w = sub.add_parser("write")
    w.add_argument("record")
    w.add_argument("--meta", required=True, help="JSON object merged into the record")
    w.add_argument("--log", action="append", default=[], metavar="NAME=PATH",
                   help="per-run log to parse; NAME is the run id")
    w.add_argument("--expect", action="append", default=[], metavar="NAME=R1,R2,...",
                   help="RESULT names run NAME must contain, all finite")
    args = ap.parse_args(argv)
    if args.cmd == "parse":
        res, err = parse_log(Path(args.log).read_text())
        json.dump({"results": res, "errors": err}, sys.stdout, indent=2)
        print()
        return 0 if res and not err else 1
    expect = {}
    for spec in args.expect:
        name, _, names = spec.partition("=")
        expect[name] = [n for n in names.split(",") if n]
    runs, ok = {}, True
    for spec in args.log:
        name, _, path = spec.partition("=")
        res, err = parse_log(Path(path).read_text())
        err = err + check_expected(res, expect.get(name, []))
        converged = bool(res) and not err
        ok &= converged
        runs[name] = {"converged": converged, "results": res, "errors": err, "log": path}
    record = json.loads(args.meta)
    record["runs"] = runs
    record["all_converged"] = ok
    write_record(args.record, record)
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
