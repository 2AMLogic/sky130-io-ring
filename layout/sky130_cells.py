"""sky130 device-level half of the I/O ring generator.

Layer numbers, rail bands, guard strips and the placeholder pad / driver
geometry for the sky130 cells. The PDK-independent half (ring assembly, seam
checks, stream writing) is gen_ring.py and never names a layer.

Provenance: every shape here is drawn from the proposed spec/io-ring.json
rows and generic sky130 layer numbers. No geometry is taken from or traced
against the foundry sky130_fd_io library (decision 0001); that library is a
comparison point only.

Honest scope of the cells: rails, continuous guard strips, a bond-pad
stack and placeholder driver diffusions inside closed guard-ring annuli, plus
the supply clamp devices in vddio / vdd (sky130_clamp.py). The GPIO has no
gate wiring, level shifter or ESD device. Nothing here is ESD-rated.
"""
import klayout.db as db

import ringgeom as g
import sky130_clamp as clamp

NAME = "sky130"
PREFIX = "sky130_ioring_"

# GDS layer/datatype. Drawing layers per the sky130A layer map; label
# purposes use datatype 5.
LAYERS = {
    "nwell": (64, 20), "diff": (65, 20), "tap": (65, 44),
    "licon1": (66, 44), "li1": (67, 20), "mcon": (67, 44),
    "met1": (68, 20), "via": (68, 44), "met2": (69, 20), "via2": (69, 44),
    "met3": (70, 20), "via3": (70, 44), "met4": (71, 20), "via4": (71, 44),
    "met5": (72, 20), "nsdm": (93, 44), "psdm": (94, 20), "pad": (76, 20),
    "poly": (66, 20), "hvi": (75, 20), "npc": (95, 20), "capm": (89, 44),
    "urpm": (79, 20), "polyres": (66, 13),
    "met1.label": (68, 5), "met2.label": (69, 5), "met3.label": (70, 5), "met4.label": (71, 5), "met5.label": (72, 5),
}

# Net -> routing layer is read from the spec (CELL.5); only the vertical
# band each rail occupies is a sky130 layout choice. Distance from the die
# edge, um. Bands are 12 um wide against the 10 um spec minimum.
RAIL_BANDS = {"VSS": (10, 22), "VDDIO": (30, 42), "VDD": (50, 62)}
# Continuous guard conductors: the p+ substrate tap strip tied to VSS and
# the n-well / n+ tap strip tied to VDDIO. They run the full width of every
# edge cell and turn the corner, so they close around the ring (CELL.8).
PSTRIP = (12, 18)
NWELL = (24, 48)
NSDM = (32, 40)
NSTRIP = (33, 39)

PAD_METAL_MARGIN = 3.0      # met5 pad metal beyond the pad opening
PAD_CENTRE_Y = 147.5        # centre of the bond pad, distance from die edge
DEPTH = 195.0              # um, die edge to core side (spec CELL.3: <= 200)
CHAMFER = 4.0               # 45-degree chamfer / mitre leg at the corner
FILL_KINDS = "fill_{}"
KINDS = ("gpio", "vddio", "vdd", "vss", "corner")

# Via cuts: (cut layer, lower metal, upper metal, size, pitch). The lowest
# step starts at li1 via mcon.
STACK = [
    ("mcon", "li1", "met1", 0.17, 0.4),
    ("via", "met1", "met2", 0.15, 0.4),
    ("via2", "met2", "met3", 0.2, 0.4),
    ("via3", "met3", "met4", 0.2, 0.4),
    ("via4", "met4", "met5", 0.8, 1.6),
]


class Ctx:
    def __init__(self, layout, params):
        self.layout = layout
        self.p = params
        self.li = {n: layout.layer(*ld) for n, ld in LAYERS.items()}
        self.rail_layer = params["rail_layers"]   # net -> "metN"

    def add(self, cell, name, shape):
        cell.shapes(self.li[name]).insert(shape)

    def add_region(self, cell, name, region):
        cell.shapes(self.li[name]).insert(region)


def _stack(ctx, cell, cx, cy, bottom, top, patch=4.0):
    """Via stack at (cx, cy) from layer `bottom` up to `top` with landing patches."""
    started = False
    for cut, lo, hi, size, pitch in STACK:
        if lo == bottom:
            started = True
        if not started:
            continue
        n = max(1, int((patch - size) / pitch) + 1)
        n = min(n, 5) if size < 0.5 else 2
        ctx.add(cell, lo, g.cbox(cx, cy, patch))
        for b in g.via_array(cx, cy, size, pitch, n):
            ctx.add(cell, cut, b)
        ctx.add(cell, hi, g.cbox(cx, cy, patch))
        if hi == top:
            return
    raise ValueError("stack top not reached")


def _label(ctx, cell, layer, text, x, y):
    cell.shapes(ctx.li[layer]).insert(db.Text(text, g.U(x), g.U(y)))


def _edge_common(ctx, cell, w):
    """Rails and continuous guard strips spanning the full cell width [0, w]."""
    for net, (b0, b1) in RAIL_BANDS.items():
        ctx.add(cell, ctx.rail_layer[net], g.box(0, b0, w, b1))
    ctx.add(cell, "tap", g.box(0, PSTRIP[0], w, PSTRIP[1]))
    ctx.add(cell, "psdm", g.box(0, PSTRIP[0] - 1, w, PSTRIP[1] + 1))
    ctx.add(cell, "li1", g.box(0, PSTRIP[0], w, PSTRIP[1]))
    ctx.add(cell, "nwell", g.box(0, NWELL[0], w, NWELL[1]))
    ctx.add(cell, "tap", g.box(0, NSTRIP[0], w, NSTRIP[1]))
    ctx.add(cell, "nsdm", g.box(0, NSDM[0], w, NSDM[1]))
    ctx.add(cell, "li1", g.box(0, NSTRIP[0], w, NSTRIP[1]))
    for y0, y1 in (PSTRIP, NSTRIP):
        for b in g.row(0.5, w - 0.5, (y0 + y1) / 2, 0.17, 1.0):
            ctx.add(cell, "licon1", b)


def _tie_stacks(ctx, cell):
    """One local stack per guard strip up to its rail (pad-width cells only)."""
    ps = (PSTRIP[0] + PSTRIP[1]) / 2
    ns = (NSTRIP[0] + NSTRIP[1]) / 2
    _stack(ctx, cell, 10, ps, "li1", "met5")
    _stack(ctx, cell, 20, ns, "li1", "met4")


def _pad(ctx, cell, w):
    cx = w / 2
    half = ctx.p["pad_open"] / 2
    cy = PAD_CENTRE_Y
    ctx.add(cell, "pad", g.cbox(cx, cy, ctx.p["pad_open"]))
    m = half + PAD_METAL_MARGIN
    ctx.add(cell, "met5", g.cbox(cx, cy, 2 * m))
    return cx, cy


def _supply_pad(ctx, cell, w, net):
    cx, cy = _pad(ctx, cell, w)
    b0, b1 = RAIL_BANDS[net]
    rl = ctx.rail_layer[net]
    sx0, sx1 = cx - 5, cx + 5
    if net == "VSS":
        ctx.add(cell, "met5", g.box(sx0, b0, sx1, cy))
        _label(ctx, cell, "met5.label", "VSS", cx, (b0 + b1) / 2)
        return
    # stub on the rail's own layer up to the pad, then a stack to met5
    ctx.add(cell, rl, g.box(sx0, b0, sx1, cy + 5))
    _stack(ctx, cell, cx, cy, rl, "met5", patch=10.0)
    _label(ctx, cell, rl + ".label", net, cx, (b0 + b1) / 2)


def _driver_blocks(ctx, cell):
    """Placeholder pad-connected diffusions inside closed guard-ring annuli."""
    ring_w = 1.5
    # NMOS-side: n+ diffusion inside a p+ tap annulus tied to VSS
    nx0, ny0, nx1, ny1 = 6, 70, 36, 100
    ctx.add_region(cell, "tap", g.annulus(nx0, ny0, nx1, ny1, ring_w))
    ctx.add_region(cell, "psdm", g.annulus(nx0 - 0.5, ny0 - 0.5, nx1 + 0.5, ny1 + 0.5, ring_w + 1.0))
    ctx.add_region(cell, "li1", g.annulus(nx0, ny0, nx1, ny1, ring_w))
    ctx.add(cell, "diff", g.box(12, 80, 30, 90))
    ctx.add(cell, "nsdm", g.box(11, 79, 31, 91))
    # PMOS-side: p+ diffusion in an n-well, inside an n+ tap annulus on VDDIO
    px0, py0, px1, py1 = 44, 70, 74, 100
    ctx.add(cell, "nwell", g.box(px0 - 4, py0 - 4, px1 + 4, py1 + 4))
    ctx.add_region(cell, "tap", g.annulus(px0, py0, px1, py1, ring_w))
    ctx.add_region(cell, "nsdm", g.annulus(px0 - 0.5, py0 - 0.5, px1 + 0.5, py1 + 0.5, ring_w + 1.0))
    ctx.add_region(cell, "li1", g.annulus(px0, py0, px1, py1, ring_w))
    ctx.add(cell, "diff", g.box(50, 80, 68, 90))
    ctx.add(cell, "psdm", g.box(49, 79, 69, 91))
    # contacts and li1 plates on both pad-connected diffusions
    for (x0, x1) in ((12, 30), (50, 68)):
        ctx.add(cell, "li1", g.box(x0, 80, x1, 90))
        for b in g.row(x0 + 1, x1 - 1, 85, 0.17, 1.0):
            ctx.add(cell, "licon1", b)
            ctx.add(cell, "mcon", b)
        ctx.add(cell, "met1", g.box(x0, 84, x1, 88))
    # PAD net: met1 trunk from both plates to a stack under the bond pad
    ctx.add(cell, "met1", g.box(30, 84, 50, 88))
    ctx.add(cell, "met1", g.box(38, 84, 42, 128))
    _stack(ctx, cell, 40, 126, "met1", "met5", patch=4.0)
    # ring ties: annulus -> met1 landing -> met2 strap down/up to the strip stack
    ps = (PSTRIP[0] + PSTRIP[1]) / 2
    ns = (NSTRIP[0] + NSTRIP[1]) / 2
    for b in g.row(7.0, 7.0, 85, 0.17, 1.0):
        ctx.add(cell, "mcon", b)
    ctx.add(cell, "met1", g.box(6, 82, 8, 88))
    ctx.add(cell, "via", g.cbox(7.0, 85, 0.15))
    ctx.add(cell, "met2", g.box(6, 13, 7.5, 88))
    ctx.add(cell, "met2", g.box(6, 13, 10, 17))
    ctx.add(cell, "mcon", g.cbox(73.0, 85, 0.17))
    ctx.add(cell, "met1", g.box(72, 82, 74, 88))
    ctx.add(cell, "via", g.cbox(73.0, 85, 0.15))
    ctx.add(cell, "met2", g.box(72, 35, 74, 88))
    ctx.add(cell, "met2", g.box(20, 35, 74, 37))


def build_edge(ctx, kind, w):
    cell = ctx.layout.create_cell(PREFIX + kind)
    _edge_common(ctx, cell, w)
    if kind.startswith("fill_"):
        return cell
    _tie_stacks(ctx, cell)
    if kind == "gpio":
        cx, cy = _pad(ctx, cell, w)
        _driver_blocks(ctx, cell)
        _label(ctx, cell, "met5.label", "PAD", cx, cy)
    else:
        _supply_pad(ctx, cell, w, {"vddio": "VDDIO", "vdd": "VDD", "vss": "VSS"}[kind])
        if kind in ("vddio", "vdd"):
            net = "VDDIO" if kind == "vddio" else "VDD"
            b0, b1 = RAIL_BANDS[net]
            clamp.build_clamp(clamp.Draw(ctx, cell), kind == "vdd",
                              (ctx.rail_layer[net], (b0 + b1) / 2), width=w)
    return cell


def build_corner(ctx, depth):
    cell = ctx.layout.create_cell(PREFIX + "corner")
    c = CHAMFER

    def band(layer, b0, b1):
        ctx.add(cell, layer, g.l_band(b0, b1, depth, c, c))

    for net, (b0, b1) in RAIL_BANDS.items():
        band(ctx.rail_layer[net], b0, b1)
    band("tap", *PSTRIP)
    band("psdm", PSTRIP[0] - 1, PSTRIP[1] + 1)
    band("li1", *PSTRIP)
    band("nwell", *NWELL)
    band("tap", *NSTRIP)
    band("nsdm", *NSDM)
    band("li1", *NSTRIP)
    # contacts along both arms, clear of the mitred corner
    for strip in (PSTRIP, NSTRIP):
        mid = (strip[0] + strip[1]) / 2
        for b in g.row(strip[1] + c + 0.5, depth - 0.5, mid, 0.17, 1.0):
            ctx.add(cell, "licon1", b)
            ctx.add(cell, "licon1", db.Box(b.p1.y, b.p1.x, b.p2.y, b.p2.x))
    return cell


def build_cells(layout, params, kinds):
    """Create the requested cells; return {kind: cell}."""
    ctx = Ctx(layout, params)
    out = {}
    for k in kinds:
        if k == "corner":
            out[k] = build_corner(ctx, params["depth"])
        elif k.startswith("fill_"):
            out[k] = build_edge(ctx, k, int(k.split("_")[1]))
        else:
            out[k] = build_edge(ctx, k, params["pitch"])
    return out


def mask_layers(params):
    """(name, layer-name, band) for every continuous conductor of the ring."""
    rails = [(n, params["rail_layers"][n], RAIL_BANDS[n]) for n in RAIL_BANDS]
    return rails + [("PSTRIP", "li1", PSTRIP), ("NSTRIP", "li1", NSTRIP),
                    ("PTAP", "tap", PSTRIP), ("NTAP", "tap", NSTRIP),
                    ("NWELL", "nwell", NWELL)]
