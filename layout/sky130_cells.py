"""sky130 device-level half of the I/O ring generator.

Layer numbers, rail bands, guard strips, the bond pad, the GPIO core and its
tie to rails and pad, and the device census. Device drawing is in
sky130_devices.py, sub-block cells in sky130_blocks.py. The PDK-independent half
(ring assembly, seam checks, stream writing, netlist reader, router) never
names a layer.

Provenance: every shape here is drawn from the proposed spec/io-ring.json rows,
generic sky130 layer numbers and the committed design/netlists/. No geometry is
taken from or traced against the foundry sky130_fd_io library (decision 0001);
that library is a comparison point only.

Honest scope of the cells: rails, continuous guard strips and a bond-pad stack
on every pad cell; in the GPIO, every device of the GPIO netlists at its
netlist W / L / m, wired, with guard rings round the pad-connected banks (driver, pulls, ESD); in
vddio / vdd, the supply clamp devices (sky130_clamp.py). Nothing here is
ESD-rated; DRC and LVS results are in signoff/ (LVS of the GPIO is a mismatch
on the netlist's diode cards only).
"""
import klayout.db as db

import ringgeom as g
import sky130_blocks as sb
import sky130_clamp as clamp
from sky130_devices import LAYERS  # noqa: F401  (LAYERS is part of this module's API)

NAME = "sky130"
PREFIX = "sky130_ioring_"

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


# ---- GPIO devices: the core block and its connection to rails and pad ---
CORE_Y0 = 63.0                 # core block bottom, distance from the die edge
CORE_X_LEFT = 12.7             # rows start here; to the left: supply spines + pad landing
SPINES = {"VSS": 10.0, "VDDIO": 6.0, "VDD": 2.0}
PAD_LAND_X = 5.0
PAD_JOIN_Y = 140.0             # where the met5 strap from the landing meets the pad metal
# Placement of the gpio netlist's sub-blocks (instance names without the X): two
# assemblies of two rows each.
ASSEMBLY_A = {"1": ("n", 0), "3": ("n", 1), "L1": ("p", 0), "L2": ("p", 1), "L3": ("p", 2)}
ASSEMBLY_B = {"L4": ("n", 0), "5": ("n", 1), "2": ("p", 0), "4": ("p", 1)}


def _core_block(ctx):
    """Build (once per layout) the GPIO core: every sub-block of the gpio netlist, wired.

    The assemblies export only the nets they share with each other (and the
    supplies / pad); a top-level pin used by one assembly is labelled inside it.
    """
    if "core" in ctx.__dict__:
        return ctx.core
    ctx.subckts = sb.load_subckts()
    ctx.blocks = {}
    ctx.block_args = {}
    top = ctx.subckts[PREFIX + "gpio"]
    by_name = {c.name: c for c in top.calls}
    asm_calls = []
    for tag, table in (("a", ASSEMBLY_A), ("b", ASSEMBLY_B)):
        inside = [by_name[n] for n in table]
        rest = [c for c in top.calls if c not in inside]
        shared = {n for c in rest for n in c.nets}
        name = f"{PREFIX}gpio_asm_{tag}"
        sub = sb.assemble(ctx.subckts, name, inside, shared)
        ctx.subckts[name] = sub
        mine = {n for c in inside for n in c.nets}
        ctx.block_args[name] = {
            "inline": False, "assign": table,
            "label_nets": [n for n in top.pins if n in mine and n not in shared]}
        asm_calls.append(sb.nr.Call(tag.upper(), list(sub.pins), name))
    core_name = f"{PREFIX}gpio_core"
    ctx.subckts[core_name] = sb.nr.Subckt(core_name, [], [], asm_calls)
    ctx.core = sb.build_block(
        ctx, core_name, inline=False, assign={"A": ("n", 0), "B": ("p", 0)}, x_left=CORE_X_LEFT,
        spines=SPINES, land=("PAD", PAD_LAND_X))
    return ctx.core


def _gpio_devices(ctx, cell, w):
    """Instantiate the core above the rails and tie its supplies and pad net to them."""
    core = _core_block(ctx)
    cell.insert(db.CellInstArray(core.cell.cell_index(), db.Trans(0, False, 0, g.U(CORE_Y0))))
    # supply spines continue as met2 down to a stack on the rail (VSS: the existing tie stack)
    for net, x in SPINES.items():
        ytie = {"VSS": (PSTRIP[0] + PSTRIP[1]) / 2, "VDDIO": (NSTRIP[0] + NSTRIP[1]) / 2,
                "VDD": sum(RAIL_BANDS["VDD"]) / 2}[net]
        ctx.add(cell, "met2", g.box(x - 0.5, ytie, x + 0.5, CORE_Y0))
    _stack(ctx, cell, SPINES["VDDIO"], (NSTRIP[0] + NSTRIP[1]) / 2, "met2", "met4")
    _stack(ctx, cell, SPINES["VDD"], sum(RAIL_BANDS["VDD"]) / 2, "met2", "met3", patch=3.0)
    # pad landing: via stack on the core's pad track, met5 strap up to the pad metal
    lx, ly = core.extra["land"]
    ly += CORE_Y0
    _stack(ctx, cell, lx, ly, "met2", "met5")
    y0, y1 = sorted((ly, PAD_JOIN_Y))
    ctx.add(cell, "met5", g.box(lx - 1.0, y0 - 1.0, lx + 1.0, y1 + 1.0))
    ctx.add(cell, "met5", g.box(lx - 1.0, PAD_JOIN_Y - 1.0, w / 2 - ctx.p["pad_open"] / 2, PAD_JOIN_Y + 1.0))


def _guard_rings():
    """Closed guard annuli per cell kind: one per guarded row of each block the netlist calls."""
    subckts = sb.load_subckts()
    return {"gpio": sb.guard_ring_count(subckts, PREFIX + "gpio")}


GUARD_RINGS = _guard_rings()


def build_edge(ctx, kind, w):
    cell = ctx.layout.create_cell(PREFIX + kind)
    _edge_common(ctx, cell, w)
    if kind.startswith("fill_"):
        return cell
    _tie_stacks(ctx, cell)
    if kind == "gpio":
        cx, cy = _pad(ctx, cell, w)
        _gpio_devices(ctx, cell, w)
        _label(ctx, cell, "met5.label", "PAD", cx, cy)
        for net, (b0, b1) in RAIL_BANDS.items():      # name the rails, as the supply pads do
            layer = ctx.rail_layer[net]
            _label(ctx, cell, layer + ".label", net, w / 2, (b0 + b1) / 2)
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


# ---- device census: the generator's own check that drawn devices are the netlist's ----
def _expected_devices(subckts):
    """(kind, thick, W, L) per extracted MOS finger of the gpio netlist, plus diode / resistor lists."""
    mos, dio, res = [], [], []
    for d in sb.flatten(subckts, subckts[PREFIX + "gpio"]):
        if d.model in sb.dev.MOS_MODELS:
            kind, thick = sb.dev.MOS_MODELS[d.model]
            mos += [(kind, thick, round(d.params["W"], 3), round(d.params["L"], 3))] * int(d.params["m"])
        elif d.model in sb.dev.DIODE_MODELS:
            dio.append((sb.dev.DIODE_MODELS[d.model], round(d.params["area"] * 1e-12, 3)))
        else:
            res.append(round(d.params["L"], 3))
    return sorted(mos), sorted(dio), sorted(res)


def _drawn_devices(layout, cell):
    """The same three lists read back from the drawn geometry of `cell` (hierarchy flattened)."""
    def region(name):
        return db.Region(cell.begin_shapes_rec(layout.layer(*LAYERS[name]))).merged()

    poly, diff, nwell, hvi = region("poly"), region("diff"), region("nwell"), region("hvi")
    mos = []
    for gate in (poly & diff).each():
        b = gate.bbox()
        one = db.Region(gate)
        kind = "p" if (one & nwell).count() else "n"
        thick = bool((one & hvi).count())
        mos.append((kind, thick, round(b.height() * g.DBU, 3), round(b.width() * g.DBU, 3)))
    dio = []
    nsdm = region("nsdm")
    for m in region("diode.mark").each():
        one = db.Region(m)
        dio.append(("n" if (one & nsdm).count() else "p", round(m.area() * g.DBU * g.DBU, 3)))
    res = [round(m.bbox().width() * g.DBU, 3) for m in region("res.mark").each()]
    return sorted(mos), sorted(dio), sorted(res)


def device_checks(layout, cells, params):
    """Findings (strings) if the drawn gpio devices differ from design/netlists/ -- empty if equal."""
    gp = cells.get("gpio")
    if gp is None:
        return []
    want = _expected_devices(sb.load_subckts())
    got = _drawn_devices(layout, gp)
    bad = []
    for name, w, d in zip(("MOS finger (kind, thick, W, L)", "diode (kind, area)", "resistor L"), want, got):
        if w != d:
            missing = [x for x in w if x not in d or w.count(x) > d.count(x)]
            extra = [x for x in d if x not in w or d.count(x) > w.count(x)]
            bad.append(f"DEV: gpio {name}: netlist has {len(w)}, drawn {len(d)}; "
                       f"undrawn {sorted(set(missing))[:4]}, unexpected {sorted(set(extra))[:4]}")
    return bad


def mask_layers(params):
    """(name, layer-name, band) for every continuous conductor of the ring."""
    rails = [(n, params["rail_layers"][n], RAIL_BANDS[n]) for n in RAIL_BANDS]
    return rails + [("PSTRIP", "li1", PSTRIP), ("NSTRIP", "li1", NSTRIP),
                    ("PTAP", "tap", PSTRIP), ("NTAP", "tap", NSTRIP),
                    ("NWELL", "nwell", NWELL)]
