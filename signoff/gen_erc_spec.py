#!/usr/bin/env python3
"""Place per-cell VDD-bodied n-well boxes in ring coordinates (T1 item 11).

PDK-independent half: reads the ring stream's top-level instances and
`signoff/erc-well-supply.json` (cell -> VDD-bodied well boxes, um, cell frame),
transforms each box by every instance's placement, and rewrites
`ties[].well_requires_boxes` of the VDD n-well tie and `well_excludes_boxes` of
the VDDIO n-well tie in the spec. Nothing else in the spec is touched. The ring
is placed by layout/gen_ring.py; rerun this after any placement change.

    python3 signoff/gen_erc_spec.py             # rewrite the spec in place
    python3 signoff/gen_erc_spec.py --check     # exit 1 if the spec is stale

Needs the pip `klayout` module.
"""
import argparse
import json
import sys

import klayout.db as db


def placed_boxes(gds, top, supply):
    ly = db.Layout()
    ly.read(gds)
    out = []
    for inst in ly.cell(top).each_inst():
        for box in supply["cells"].get(inst.cell.name, []):
            b = inst.trans.trans(db.Box(*[round(v / ly.dbu) for v in box]))
            out.append([round(v * ly.dbu, 3) for v in (b.left, b.bottom, b.right, b.top)])
    return sorted(out)


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--gds", default="layout/gds/sky130_ioring_ring.gds")
    ap.add_argument("--top", default="sky130_ioring_ring")
    ap.add_argument("--spec", default="signoff/erc-supply-spec.json")
    ap.add_argument("--supply", default="signoff/erc-well-supply.json")
    ap.add_argument("--vdd-tie", default="ntap_vdd")
    ap.add_argument("--vddio-tie", default="ntap_vddio")
    ap.add_argument("--check", action="store_true")
    a = ap.parse_args()
    boxes = placed_boxes(a.gds, a.top, json.load(open(a.supply)))
    spec = json.load(open(a.spec))
    ties = {t["name"]: t for t in spec["ties"]}
    ties[a.vdd_tie]["well_requires_boxes"] = boxes
    ties[a.vddio_tie]["well_excludes_boxes"] = boxes
    text = json.dumps(spec, indent=2) + "\n"
    if a.check:
        if open(a.spec).read() != text:
            sys.exit(f"{a.spec} is stale: rerun signoff/gen_erc_spec.py")
        return
    open(a.spec, "w").write(text)
    print(f"{a.spec}: {len(boxes)} VDD-bodied well boxes")


if __name__ == "__main__":
    main()
