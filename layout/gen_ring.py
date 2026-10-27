#!/usr/bin/env python3
"""I/O ring generator: PDK-independent half.

Reads the cell-level numbers from spec/io-ring.json (CELL.* / LU.* rows, never
duplicated here), asks a tech module (default sky130_cells) to draw the cells,
assembles the closed ring from edge cells and four corner cells, runs the
spec/seam self-checks, and writes deterministic GDS streams.

Provenance: geometry is generated from the proposed spec rows and the tech
module's own drawing code. Nothing is copied from the foundry sky130_fd_io
library (decision 0001); it is a comparison reference only.

  python3 layout/gen_ring.py [--out DIR] [--tech MODULE] [--attest FILE]

This half names no layer and no process rule, so it can be stamped into the
gf180 port with only the tech module replaced. Needs `klayout` (pip) but no PDK.
"""
import argparse
import hashlib
import importlib
import json
import re
import sys
from importlib import metadata
from pathlib import Path

import klayout.db as db

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import ringgeom as g  # noqa: E402

REPO = HERE.parent
SPEC = REPO / "spec" / "io-ring.json"
TOP = "ring"
UM = "[µμ]m"

# South-edge order of one side; all four sides repeat it (rotated). The
# close-first set (GPIO, VDDIO/VSS pair, corner) is a subset of it.
SIDE_PADS = ("gpio", "vddio", "vss", "vdd", "gpio")
SIDE_LENGTH = 437   # um: five pad cells plus a 37 um filler run (any integer works)


# ---------------------------------------------------------------- spec ----
def _row(spec, rid):
    for r in spec["rows"]:
        if r["id"] == rid:
            return r
    raise SystemExit(f"spec row {rid} missing from {SPEC}")


def _num(pattern, text, rid):
    m = re.search(pattern, text)
    if not m:
        raise SystemExit(f"spec row {rid}: cannot read /{pattern}/ from {text!r}")
    return float(m.group(1))


def spec_params(path=SPEC):
    """Pull every cell-level number the generator depends on out of the spec."""
    spec = json.loads(Path(path).read_text())
    t = lambda rid: _row(spec, rid)["target"]  # noqa: E731
    pitch = _num(rf"(\d+(?:\.\d+)?)\s*{UM}", t("CELL.2"), "CELL.2")
    depth_max = _num(rf"<=\s*(\d+(?:\.\d+)?)\s*{UM}", t("CELL.3"), "CELL.3")
    pad_open = _num(r">=\s*(\d+(?:\.\d+)?)\s*" + UM[:-1], t("CELL.4"), "CELL.4")
    rails = dict((n, l) for n, l in re.findall(r"(VSS|VDDIO|VDD) on (met\d)", t("CELL.5")))
    if set(rails) != {"VSS", "VDDIO", "VDD"}:
        raise SystemExit(f"spec row CELL.5: cannot read rail layers from {t('CELL.5')!r}")
    rail_min = _num(rf">=\s*(\d+(?:\.\d+)?)\s*{UM}\s*wide", t("CELL.5"), "CELL.5")
    fillers = [int(x) for x in re.findall(r"\d+", t("CELL.6").split("µ")[0].split("μ")[0])]
    grid = _num(rf"(\d+(?:\.\d+)?)\s*{UM}\s*manufacturing grid", t("CELL.9"), "CELL.9")
    if "45-degree" not in t("CELL.7"):
        raise SystemExit("spec row CELL.7: expected a 45-degree chamfer")
    if "closed" not in t("LU.1"):
        raise SystemExit("spec row LU.1: expected closed guard rings")
    if int(pitch) != pitch:
        raise SystemExit("spec row CELL.9: pad pitch must be an integer number of um")
    return {
        "spec_version": spec["spec_version"], "spec_status": spec["status"],
        "pitch": int(pitch), "depth_max": depth_max, "pad_open": pad_open,
        "rail_layers": rails, "rail_min": rail_min, "fillers": sorted(fillers),
        "grid": grid,
    }


def compose_fill(length, widths):
    """Greedy composition of `length` (integer um) from filler widths."""
    widths = sorted(widths, reverse=True)
    if length < 0 or length != int(length):
        raise ValueError(f"filler run {length} must be a non-negative integer")
    out, rest = [], int(length)
    for w in widths:
        out += [w] * (rest // w)
        rest %= w
    if rest:
        raise ValueError(f"cannot fill {length} um with {widths}")
    return out


# ------------------------------------------------------------ assembly ----
def side_sequence(params):
    pads = list(SIDE_PADS)
    fill = SIDE_LENGTH - len(pads) * params["pitch"]
    return pads + [f"fill_{w}" for w in compose_fill(fill, params["fillers"])]


def kind_width(kind, params):
    return int(kind.split("_")[1]) if kind.startswith("fill_") else params["pitch"]


def needed_kinds(params):
    ks = ["corner"] + sorted(set(side_sequence(params)), key=side_sequence(params).index)
    return ks


def place(top, cells, params, depth):
    """Instantiate the closed ring; return [(kind, bbox_dbu)] of every instance."""
    seq = side_sequence(params)
    side = sum(kind_width(k, params) for k in seq)
    size = 2 * depth + side
    placed = []

    def put(kind, rot, x, y):
        cell = cells[kind]
        trans = db.Trans(rot, False, g.U(x), g.U(y))
        top.insert(db.CellInstArray(cell.cell_index(), trans))
        w = depth if kind == "corner" else kind_width(kind, params)
        h = depth
        placed.append((kind, db.Box(0, 0, g.U(w), g.U(h)).transformed(trans)))

    put("corner", 0, 0, 0)
    put("corner", 1, size, 0)
    put("corner", 2, size, size)
    put("corner", 3, 0, size)
    t = 0
    for k in seq:
        w = kind_width(k, params)
        put(k, 0, depth + t, 0)               # south, left to right
        put(k, 1, size, depth + t)            # east, bottom to top
        put(k, 2, size - depth - t, size)     # north, right to left
        put(k, 3, 0, size - depth - t)        # west, top to bottom
        t += w
    return size, placed


def build_layout(tech, params, kinds=None, with_top=True):
    layout = db.Layout()
    layout.dbu = g.DBU
    kinds = kinds or needed_kinds(params)
    cells = tech.build_cells(layout, params, kinds)
    if not with_top:
        return layout, cells, None, None, None
    top = layout.create_cell(tech.PREFIX + TOP)
    size, placed = place(top, cells, params, params["depth"])
    return layout, cells, top, size, placed


# --------------------------------------------------------- self-checks ----
def _angles_ok(layout):
    for c in layout.each_cell():
        for li in layout.layer_indexes():
            for s in c.shapes(li).each():
                if not s.is_polygon():
                    continue
                for e in s.polygon.each_edge():
                    dx, dy = abs(e.dx()), abs(e.dy())
                    if dx and dy and dx != dy:
                        return False
    return True


def self_check(tech, params, layout, cells, top, size, placed):
    """Return a list of failures; empty means every spec/seam assertion held."""
    bad = []
    depth = params["depth"]
    if abs(params["grid"] - g.GRID_UM) > 1e-12:
        bad.append(f"CELL.9: spec grid {params['grid']} != generator grid {g.GRID_UM}")
    if depth > params["depth_max"]:
        bad.append(f"CELL.3: depth {depth} > {params['depth_max']}")
    if params["pad_open"] < 55:
        bad.append("CELL.4: pad opening below the provisional 55 um minimum")
    if sorted(params["fillers"]) != [1, 5, 10, 20]:
        bad.append(f"CELL.6: filler widths {params['fillers']} != [1, 5, 10, 20]")
    for net, (b0, b1) in tech.RAIL_BANDS.items():
        if b1 - b0 < params["rail_min"]:
            bad.append(f"CELL.5: {net} rail {b1 - b0} um < {params['rail_min']} um")
    if not g.on_grid(layout):
        bad.append("CELL.9: a vertex is off the manufacturing grid")
    if not _angles_ok(layout):
        bad.append("CELL.7: a non-45/90 degree edge is drawn")

    # CELL.2 / CELL.3 / CELL.8 at the cell level
    for k, cell in cells.items():
        bb = cell.bbox()
        if k == "corner":
            if (bb.right, bb.top) != (g.U(depth), g.U(depth)) or bb.left < 0 or bb.bottom < 0:
                bad.append("CELL.7: corner shapes do not fill a depth x depth square frame")
            continue
        w = kind_width(k, params)
        if bb.right != g.U(w) or bb.left != 0:
            bad.append(f"CELL.2/8: {k} spans {bb.left}..{bb.right}, expected 0..{g.U(w)} dbu")
        if bb.top > g.U(depth):
            bad.append(f"CELL.3: {k} is deeper than {depth} um")
        for name, layer, (b0, b1) in tech.mask_layers(params):
            li = layout.layer(*tech.LAYERS[layer])
            reg = db.Region(cell.shapes(li)).merged()
            win = db.Region(g.box(-1, b0, w + 1, b1))
            got = reg & win
            want = db.Region(g.box(0, b0, w, b1))
            if (got ^ want).count() and name not in ("NWELL",):
                bad.append(f"CELL.8: {k} {name} does not span the full cell at y {b0}..{b1}")
            if name == "NWELL" and (want - got).count():
                bad.append(f"CELL.8: {k} NWELL strip has a gap")
    # LU.1: closed annuli around the pad-connected diffusions
    gp = cells.get("gpio")
    if gp is not None:
        tap = db.Region(gp.begin_shapes_rec(layout.layer(*tech.LAYERS["tap"]))).merged()
        rings = [p for p in tap.each() if p.holes() == 1]
        want = tech.GUARD_RINGS["gpio"]
        if len(rings) != want:
            bad.append(f"LU.1: expected {want} closed guard annuli in gpio, found {len(rings)}")

    if hasattr(tech, "device_checks"):          # drawn devices against the committed netlists
        bad += tech.device_checks(layout, cells, params)

    if top is None:
        return bad
    # CELL.8 ring level: instances tile with no gap or overlap
    union = db.Region()
    total = 0
    for _, bb in placed:
        union.insert(bb)
        total += bb.area()
    if union.merged().area() != total:
        bad.append("CELL.8: two cell instances overlap")
    ring_region = db.Region(g.box(0, 0, size, size)) - db.Region(
        g.box(depth, depth, size - depth, size - depth))
    if (union.merged() ^ ring_region).count():
        bad.append("CELL.8: instances leave a gap in (or spill outside) the ring annulus")

    # continuity: each continuous conductor covers an independently built ring
    c = tech.CHAMFER
    for name, layer, (b0, b1) in tech.mask_layers(params):
        li = layout.layer(*tech.LAYERS[layer])
        reg = db.Region(top.begin_shapes_rec(li)).merged()
        mask = g.ring_mask(size, b0, b1, c, c)
        mm = mask.merged()
        if not (mm.count() == 1 and mm.holes().count() == 1):
            bad.append(f"internal: {name} oracle is not a single closed ring")
        if (mm - reg).count():
            bad.append(f"CELL.8: {name} ({layer}) is not continuous around the ring")
    return bad


# -------------------------------------------------------------- output ----
def _opts():
    o = db.SaveLayoutOptions()
    o.format = "GDS2"
    o.gds2_write_timestamps = False
    o.gds2_libname = "sky130_io_ring"
    return o


def write_gds(layout, path, top=None):
    o = _opts()
    if top is not None:
        o.select_all_cells()
    layout.write(str(path), o)


def sha256_file(path):
    return "sha256:" + hashlib.sha256(Path(path).read_bytes()).hexdigest()


def generate(out_dir, tech):
    """Self-check, then write ring.gds and one GDS per cell. Returns the ring path."""
    params = spec_params()
    params["depth"] = tech.DEPTH
    layout, cells, top, size, placed = build_layout(tech, params)
    bad = self_check(tech, params, layout, cells, top, size, placed)
    if bad:
        raise SystemExit("layout self-check failed:\n  " + "\n  ".join(bad))
    out = Path(out_dir)
    out.mkdir(parents=True, exist_ok=True)
    for k in cells:
        cl = db.Layout()
        cl.dbu = g.DBU
        tech.build_cells(cl, params, [k])
        write_gds(cl, out / f"{tech.PREFIX}{k}.gds")
    ring = out / f"{tech.PREFIX}{TOP}.gds"
    write_gds(layout, ring)
    return ring, params, size


def attestation(tech, params, ring_rel, ring_hash, size):
    return {
        "schema_version": 1,
        "kind": "generic",
        "status": "pass",
        "t1_item": 2,
        "summary": (
            "closed I/O ring stream generated from the proposed spec (status "
            f"{params['spec_status']}, spec_version {params['spec_version']}); generator "
            "self-checks passed (CELL.2/3/5/7/8/9, LU.1). Not DRC- or LVS-checked."),
        "source": "layout/gen_ring.py",
        "provenance": {
            "klt_version": "n/a (written by layout/gen_ring.py)",
            "klayout_version": metadata.version("klayout"),
            "pdk": None,
            "deck": None,
            "input": {"path": {"path": ring_rel, "scope": "repo"}, "content_hash": ring_hash},
            "regeneration": {
                "generator": "python3 layout/gen_ring.py --out layout/gds",
                "regenerated_hash": ring_hash,
            },
        },
    }


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--out", default=str(HERE / "gds"))
    ap.add_argument("--tech", default="sky130_cells")
    ap.add_argument("--attest", help="also write the item-2 attestation envelope here")
    a = ap.parse_args(argv)
    tech = importlib.import_module(a.tech)
    ring, params, size = generate(a.out, tech)
    h = sha256_file(ring)
    print(f"{ring}  {h}  die {size} um square")
    if a.attest:
        rel = ring.resolve().relative_to(REPO).as_posix()
        Path(a.attest).write_text(json.dumps(
            attestation(tech, params, rel, h, size), indent=2, sort_keys=True) + "\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
