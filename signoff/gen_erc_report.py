#!/usr/bin/env python3
"""Run `klt erc` (supply connectivity, T1 item 11) on the assembled ring.

PDK-independent half: takes a stream, a top cell and a spec path, runs
`klt erc --findings-only` from the repo root (so recorded paths are
repo-relative) and writes the report. The spec (`signoff/erc-supply-spec.json`)
holds every layer number; this script names none for the report itself.

    python3 signoff/gen_erc_report.py --klt "uvx --from klayout-tools==0.8.0 klt"

`--negative` also proves the spec can fail: it copies the ring stream into a
scratch directory, deletes a 2 um slab of every conductor layer on two opposite sides
(the ring is closed, so one cut leaves it connected), runs the same ERC on the
copy and writes `ring-negative.json`. It exits 4 if that run is NOT reported as
split, because then the clean result above would be vacuous. Needs the pip
`klayout` module; the committed stream is never modified.

Exit 0: report written and clean (no erc_findings). Exit 4: findings (the
report is still written; nothing is waived).
"""
import argparse
import json
import os
import shlex
import subprocess
import sys
import tempfile


def run_erc(klt, gds, top, spec, out):
    p = subprocess.run(shlex.split(klt) + ["erc", "--top", top, "--findings-only",
                                           "--omit-antenna-tables", "--compact",
                                           "--format", "json", gds, spec],
                       capture_output=True, text=True)
    if not p.stdout.strip():
        sys.exit(f"klt erc failed on {gds} (rc={p.returncode}): {p.stderr.strip()}")
    with open(out, "w") as f:
        f.write(p.stdout)
    return json.loads(p.stdout)


def split_ring(src, dst, top, layers, cuts):
    """Write a scratch copy of the stream with each `cuts` box removed on `layers`."""
    import klayout.db as db
    ly = db.Layout()
    ly.read(src)
    cell = ly.cell(top)
    cell.flatten(True)
    cut = db.Region()
    for box in cuts:
        cut.insert(db.Box(*[round(v / ly.dbu) for v in box]))
    for lay in layers:
        li = ly.layer(*lay)
        reg = db.Region(cell.shapes(li)) - cut
        cell.clear(li)
        cell.shapes(li).insert(reg)
    ly.write(dst)


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--klt", default="klt", help="klt command (may be a quoted uvx line)")
    ap.add_argument("--gds", default="layout/gds/sky130_ioring_ring.gds")
    ap.add_argument("--top", default="sky130_ioring_ring")
    ap.add_argument("--spec", default="signoff/erc-supply-spec.json")
    ap.add_argument("--out-dir", default="signoff/evidence/erc")
    ap.add_argument("--negative", action="store_true", help="also run the split-seam check")
    a = ap.parse_args()
    os.makedirs(a.out_dir, exist_ok=True)
    out = f"{a.out_dir}/ring.json"
    rep = run_erc(a.klt, a.gds, a.top, a.spec, out)
    nf = len(rep["erc_findings"])
    print(f"{out}: erc_status={rep['erc_status']} findings={nf} "
          + " ".join(f"{n['name']}={n['matched_islands']}" for n in rep["nets"]))
    rc = 4 if nf else 0
    if a.negative:
        # every conductor layer of the spec's stackup: the guard strips (li1) also
        # carry VSS and VDDIO around the ring, so cutting only the rails would not split them
        rails = [tuple(int(x) for x in s["layer"].split("/")) for s in json.load(open(a.spec))["stackup"][1:]]
        import klayout.db as db
        ly = db.Layout()
        ly.read(a.gds)
        bb = ly.cell(a.top).dbbox()
        xm = (bb.left + bb.right) / 2
        d = 100.0                                         # um, deeper than the cell depth
        cuts = [(xm, bb.bottom, xm + 2, bb.bottom + d), (xm, bb.top - d, xm + 2, bb.top)]
        with tempfile.TemporaryDirectory() as tmp:
            scratch = os.path.join(tmp, "ring-split.gds")
            split_ring(a.gds, scratch, a.top, rails, cuts)
            nout = f"{a.out_dir}/ring-negative.json"
            neg = run_erc(a.klt, scratch, a.top, a.spec, nout)
        # the scratch path is a temp file: record only the file name
        txt = open(nout).read().replace(scratch, "ring-split.gds")
        open(nout, "w").write(txt)
        split = [n["name"] for n in neg["nets"] if n["matched_islands"] != n["expected_islands"]]
        print(f"{nout}: findings={len(neg['erc_findings'])} split nets={split}")
        if not split:
            print("negative check FAILED: a cut ring was not reported as split", file=sys.stderr)
            rc = 4
    sys.exit(rc)


if __name__ == "__main__":
    main()
