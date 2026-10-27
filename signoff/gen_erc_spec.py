#!/usr/bin/env python3
"""Refresh the ring-coordinate boxes of `signoff/erc-supply-spec.json` (sky130 half).

The ERC spec classifies n-wells by box: a tie checks only the wells whose body
net the netlist says it is. The ring draws 7 VDD-body n-wells in every GPIO core
(the 1.8 V logic and the receiver's thick-oxide VDD pfet) next to the VDDIO
wells (level shifters, driver, pulls, ESD diodes), and no layer separates the
two classes (the ESD diode wells carry no hvi, the receiver's VDD pfet does).
The boxes therefore come from the generator's own record of which body net each
well was drawn for (`sky130_blocks.WELLS`), never from the drawn connectivity: a
tap that is not on the net its well was drawn for must still fail the tie.

    python3 signoff/gen_erc_spec.py            # rewrite the spec
    python3 signoff/gen_erc_spec.py --check    # exit 1 if the spec is out of date

Rewritten: `ties[ntap_vddio].well_excludes_boxes` and
`ties[ntap_vdd].well_requires_boxes` (VDD-body wells; the clamp-well boxes that
are not inside a GPIO core are kept as they are), and
`nets[VDD].unlabelled_allowed_boxes` (the GPIO core footprints, where the met3
signal routing between blocks is expected and is not a rail). Needs the pip
`klayout` module. Run it again whenever the GPIO cell or the ring placement moves.
"""
import argparse
import json
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = HERE.parent
sys.path.insert(0, str(REPO / "layout"))
import gen_ring  # noqa: E402
import sky130_blocks  # noqa: E402
import sky130_cells as tech  # noqa: E402

SPEC = HERE / "erc-supply-spec.json"
CORE = tech.PREFIX + "gpio_core"
SHRINK = 0.05            # um: keeps a box off the well next to the one it names


def _um(b, trans, dbu):
    t = b.transformed(trans)
    return [round(v * dbu, 3) for v in (t.left, t.bottom, t.right, t.top)]


def ring_boxes():
    """(VDD-body well boxes, GPIO core boxes) in ring coordinates, um."""
    import klayout.db as db
    params = gen_ring.spec_params()
    params["depth"] = tech.DEPTH
    layout, _, top, _, _ = gen_ring.build_layout(tech, params)
    dbu = layout.dbu
    want = {}
    for name, rows in sky130_blocks.WELLS.items():
        for body, _, (x0, y0, x1, y1) in rows:
            if body == "VDD":
                want.setdefault(name, set()).add(
                    (round(x0 / dbu), round(y0 / dbu), round(x1 / dbu), round(y1 / dbu)))
    wells = []
    it = top.begin_shapes_rec(layout.layer(*tech.LAYERS["nwell"]))
    while not it.at_end():
        b = it.shape().bbox()
        key = (b.left, b.bottom, b.right, b.top)
        if key in want.get(layout.cell(it.cell_index()).name, ()):
            x0, y0, x1, y1 = _um(b, it.trans(), dbu)
            wells.append([round(x0 + SHRINK, 3), round(y0 + SHRINK, 3),
                          round(x1 - SHRINK, 3), round(y1 - SHRINK, 3)])
        it.next()
    cores = []

    def walk(cell, trans):
        for inst in cell.each_inst():
            t = trans * inst.cplx_trans
            child = layout.cell(inst.cell_index)
            if child.name == CORE:
                cores.append(_um(child.bbox(), t, dbu))
            else:
                walk(child, t)
    walk(top, db.ICplxTrans())
    return sorted(wells), sorted(cores)


def refreshed(spec, wells, cores):
    new = json.loads(json.dumps(spec))
    for t in new["ties"]:
        keep = [b for b in t.get("well_requires_boxes", t.get("well_excludes_boxes", []))
                if not any(o[0] <= b[0] and b[2] <= o[2] and o[1] <= b[1] and b[3] <= o[3]
                           for o in cores)]
        if t["name"] == "ntap_vddio":
            t["well_excludes_boxes"] = keep + wells
        elif t["name"] == "ntap_vdd":
            t["well_requires_boxes"] = keep + wells
    for n in new["nets"]:
        if n["name"] == "VDD":
            n["unlabelled_allowed_boxes"] = cores
    return new


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--check", action="store_true", help="exit 1 if the spec would change")
    a = ap.parse_args()
    spec = json.loads(SPEC.read_text())
    wells, cores = ring_boxes()
    if not wells or not cores:
        sys.exit("no VDD-body wells / GPIO core found: the generator record is empty")
    new = refreshed(spec, wells, cores)
    text = json.dumps(new, indent=2) + "\n"
    print(f"{len(wells)} VDD-body wells, {len(cores)} GPIO cores")
    if a.check:
        if SPEC.read_text() != text:
            sys.exit(f"{SPEC} is out of date: run python3 signoff/gen_erc_spec.py")
        return
    SPEC.write_text(text)


if __name__ == "__main__":
    main()
