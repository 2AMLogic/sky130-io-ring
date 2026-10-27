#!/usr/bin/env python3
"""Diagnostic, not evidence: does `klt lvs` find any difference besides the diode cards?

`klt lvs` cannot read the reference's diode cards (2AMLogic/klayout-tools#4319),
so the committed `gpio` report is a `mismatch` whose errors all name them. This
script re-runs the comparison with the diodes taken out of BOTH sides, in a
scratch directory, and prints the result. Nothing is written under signoff/.

  - layout: the diode marker layer (`--marker`) is deleted from every cell of
    the stream, so the diffusions stay and are wired but extract as no device;
  - reference: every card whose line mentions `--card` is dropped.

    python3 signoff/diag_lvs_without_diodes.py --klt "uvx --from klayout-tools==0.8.0 klt"

Exit 0 if the masked comparison is `match`, 4 if it is not. A `match` here does
not make item 4 met: the diodes are the part of the cell this does not compare.
"""
import argparse
import json
import os
import shlex
import subprocess
import sys
import tempfile

import klayout.db as db


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--klt", default="klt")
    ap.add_argument("--deck", default="sky130")
    ap.add_argument("--cell", default="sky130_ioring_gpio")
    ap.add_argument("--gds-dir", default="layout/gds")
    ap.add_argument("--netlist-dir", default="design/netlists")
    ap.add_argument("--marker", default="81/23", help="diode marker layer/datatype in the stream")
    ap.add_argument("--card", default="diode_", help="drop reference cards containing this text")
    a = ap.parse_args()
    layer, datatype = (int(x) for x in a.marker.split("/"))

    layout = db.Layout()
    layout.read(os.path.abspath(f"{a.gds_dir}/{a.cell}.gds"))
    li = layout.find_layer(layer, datatype)
    dropped = 0
    if li is not None:
        for cell in layout.each_cell():
            dropped += cell.shapes(li).size()
            cell.shapes(li).clear()
    with open(f"{a.netlist_dir}/{a.cell}.spice") as f:
        lines = f.read().splitlines()
    kept = [x for x in lines if a.card not in x]

    with tempfile.TemporaryDirectory() as tmp:
        gds, ref = os.path.join(tmp, "masked.gds"), os.path.join(tmp, "masked.spice")
        layout.write(gds)
        with open(ref, "w") as f:
            f.write("\n".join(kept) + "\n")
        req = {"layout": {"file": gds, "deck": a.deck, "top": a.cell},
               "reference": {"netlist": ref, "top": a.cell, "form": "subckt-call", "deck": a.deck},
               "options": {"flatten_reference": True, "compare_mos_flavour": True}}
        p = subprocess.run(shlex.split(a.klt) + ["lvs", "--format", "json", json.dumps(req)],
                           capture_output=True, text=True)
    try:
        d = json.loads(p.stdout)
    except ValueError:
        sys.exit(f"klt lvs gave no report (rc={p.returncode}): {p.stderr.strip() or p.stdout.strip()}")
    if "error" in d:
        sys.exit(f"klt lvs refused the masked request: {d['error']['message']}")
    print(f"masked {dropped} marker shape(s) and {len(lines) - len(kept)} reference card(s)")
    print(f"status={d['status']} counts={json.dumps(d['counts'])}")
    for m in d["mismatches"]:
        if m["severity"] == "error":
            print(f"  error {m['category']}: {m['description'][:120]}")
    sys.exit(0 if d["status"] == "match" else 4)


if __name__ == "__main__":
    main()
