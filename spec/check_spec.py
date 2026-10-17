#!/usr/bin/env python3
"""Keep spec/io-ring.md and spec/io-ring.json in agreement.

io-ring.json is the source of the rows; the tables in io-ring.md between
<!-- rows:begin GROUP --> and <!-- rows:end GROUP --> markers are rendered from
it. Usage:
    python3 -I spec/check_spec.py          # check (exit 1 on any disagreement)
    python3 -I spec/check_spec.py --write  # re-render the tables into io-ring.md
"""
import json
import re
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
COLS = ("id", "parameter", "target", "fallback", "stretch", "rationale", "pdk_independent")
NEGATION = re.compile(r"\b(not|no|never|nor|without|before|neither)\b", re.I)
CLAIM = re.compile(r"ESD-rated|qualified", re.I)


def cell(v):
    if isinstance(v, bool):
        return "yes" if v else "no"
    return str(v).replace("|", "\\|")


def render(rows):
    out = ["| " + " | ".join(COLS) + " |", "|" + "---|" * len(COLS)]
    out += ["| " + " | ".join(cell(r[c]) for c in COLS) + " |" for r in rows]
    return "\n".join(out)


def main(write):
    data = json.loads((HERE / "io-ring.json").read_text())
    md_path = HERE / "io-ring.md"
    md = md_path.read_text()
    errors = []
    ids = [r["id"] for r in data["rows"]]
    if len(ids) != len(set(ids)):
        errors.append("duplicate row ids in io-ring.json")
    for r in data["rows"]:
        for c in COLS:
            if c not in r or r[c] in ("", None):
                errors.append(f"{r.get('id')}: missing field {c}")
        if not isinstance(r.get("pdk_independent"), bool):
            errors.append(f"{r.get('id')}: pdk_independent must be true/false")
    names = [c["name"] for c in data["corners"]]
    if len(names) != len(set(names)):
        errors.append("duplicate corner names")
    for g in data["groups"]:
        rows = [r for r in data["rows"] if r["group"] == g["id"]]
        pat = re.compile(
            r"(<!-- rows:begin %s -->\n)(.*?)(<!-- rows:end %s -->)" % (g["id"], g["id"]), re.S)
        m = pat.search(md)
        if not m:
            errors.append(f"io-ring.md: no rows:begin/end markers for group {g['id']}")
            continue
        want = render(rows) + "\n"
        if write:
            md = md[:m.start(2)] + want + md[m.end(2):]
        elif m.group(2) != want:
            md_ids = re.findall(r"^\| ([A-Z]+\.\d+) \|", m.group(2), re.M)
            errors.append(f"group {g['id']}: table differs from io-ring.json "
                          f"(md ids {md_ids} vs json ids {[r['id'] for r in rows]})")
    lines = md.splitlines()
    for n, line in enumerate(lines, 1):
        # a wrapped sentence may carry its negation on the previous line
        if CLAIM.search(line) and not NEGATION.search(" ".join(lines[max(0, n - 2):n])):
            errors.append(f"io-ring.md:{n}: ESD-rated/qualified wording outside a negation")
    if write:
        md_path.write_text(md)
        print("io-ring.md tables re-rendered")
        return 0
    for e in errors:
        print("FAIL:", e)
    if not errors:
        print(f"OK: {len(ids)} rows, {len(names)} corners, md and json agree")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main("--write" in sys.argv))
