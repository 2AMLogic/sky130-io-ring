"""sky130 sub-block cells built from the committed schematic netlists.

`build_block` turns one `.subckt` into a layout cell: its transistors, diodes
and resistor are drawn by sky130_devices, its subcircuit calls become child
cells (built the same way), and chanroute wires everything. Pins leave the
cell as met3 stubs on its top edge, so a parent routes them like device ports.

Cell frame: an n-type row at the bottom, a routing channel, a p-type row at the
top (mirrored about the cell's outer edge so its ports face the channel).
Layers: li1 / mcon / met1 inside devices and drops from them, met2 tracks,
met3 drops from child pins and exports. No layer number is named here; the
sky130 numbers are in sky130_devices.LAYERS.
"""
from collections import namedtuple
from pathlib import Path

import klayout.db as db

import chanroute as cr
import netlist_read as nr
import ringgeom as g
import sky130_devices as dev

NETLIST_DIR = Path(__file__).resolve().parent.parent / "design" / "netlists"
NETLIST_FILES = ["sky130_ioring_gpio.spice", "sky130_ioring_inv.spice", "sky130_ioring_nand2.spice",
                 "sky130_ioring_nand3.spice", "sky130_ioring_nor2.spice"]

# Guard rings (LU.1) around the output driver banks: subckt -> {row: ring net}.
GUARDED = {"sky130_ioring_gpio_drv": {"n": "VSS", "p": "VDDIO"}}
RING_MIN_OUTER = 21.0       # um; outer width of a guard ring around a driver bank

Y_N0 = 0.7                  # bottom margin: n row base
TRACK_PITCH = 0.5
TRACK_PITCH_M3 = 0.7        # met3 drops need 0.3 um between their ends
SEP_LI = 0.6                # met1 drops: minimum column separation of distinct nets
SEP_M3 = 0.85               # met3 drops / exports
GAP_UNIT = 0.6              # between units of one group
GAP_GROUP = 2.5             # between groups (n-well spacing 1.27 + well margins)
GAP_ITEM = 1.0
WELL_MARGIN = 0.6
HVI_MARGIN = 0.4
RING_W = 0.5

Built = namedtuple("Built", "cell w h pin_x extra")

# n-wells the generator drew, by body net, from the netlist (not from the drawing):
# {cell name: [(body net, thick oxide, (x0, y0, x1, y1) um in the cell's frame)]}.
# signoff/gen_erc_spec.py reads it to declare which wells the ERC ties must reach.
WELLS = {}


def load_subckts():
    out = {}
    for f in NETLIST_FILES:
        out.update(nr.parse(NETLIST_DIR / f, dev.DEVICE_MODELS))
    return out


class _Group:
    """Devices that share a well (p row) or hvi / substrate region (n row)."""

    def __init__(self, row, key, units, ring_net=None):
        self.row, self.key, self.units, self.ring_net = row, key, units, ring_net
        self.placed = []                      # (unit, local x)
        w = 0.0
        for i, u in enumerate(units):
            self.placed.append((u, w))
            w += u.w + GAP_UNIT
        self.core_w = w - GAP_UNIT
        self.core_h = max(u.h for u in units)
        self.rh = self.rv = 0.0
        if ring_net:
            self.rh = max(2.0, (RING_MIN_OUTER - self.core_w) / 2 - RING_W)
            self.rv = 2.0
        self.pad_x = self.rh + (RING_W if ring_net else 0.0)
        self.pad_y = self.rv + (RING_W if ring_net else 0.0)
        self.w = self.core_w + 2 * self.pad_x
        self.h = self.core_h + 2 * self.pad_y
        self.ring_port = None


class _Inst:
    def __init__(self, child, call, sub_pins):
        self.child, self.call = child, call
        self.w, self.h = child.w, child.h
        self.pins = list(zip(sub_pins, call.nets))


def _tap_for(kind, net, thick):
    return dev.tap(kind, net, thick)


def _make_groups(row, units, ring_net):
    by_key = {}
    for u in units:
        by_key.setdefault((u.body, u.thick), []).append(u)
    groups = []
    for (body, thick), us in by_key.items():
        taps = []
        if not ring_net:
            taps = [_tap_for("n" if row == "n" else "p", body, thick)]
        body_units = taps + us
        if not ring_net and sum(u.w for u in us) > 5.0:
            body_units = body_units + [_tap_for("n" if row == "n" else "p", body, thick)]
        groups.append(_Group(row, (body, thick), body_units, ring_net=ring_net))
    return groups


def _layout_row(items, x0=0.7):
    x = x0
    prev = None
    for it in items:
        if prev is not None:
            x += GAP_GROUP if isinstance(it, _Group) or isinstance(prev, _Group) else GAP_ITEM
        it.x = x
        x += it.w
        prev = it
    return x


class _Emit:
    def __init__(self, cell, layout, top_y):
        self.cell, self.layout, self.top_y = cell, layout, top_y
        self.pen = dev.Pen(layout, cell)

    def track(self, net, x0, x1, y):
        self.pen.box("met2", x0 - 0.25, y - 0.17, x1 + 0.25, y + 0.17)

    def drop(self, p, y):
        lo, hi = sorted((p.y, y))
        if p.kind == "li":
            self.pen.box("met1", p.x - 0.13, lo - 0.13, p.x + 0.13, hi + 0.17)
            self.pen.cbox("mcon", p.x, p.y, 0.17)
        elif p.kind == "m3":
            self.pen.box("met3", p.x - 0.2, lo - 0.2, p.x + 0.2, hi + 0.2)
        elif p.kind == "exp":                  # export stub ends on the cell's top edge
            self.pen.box("met3", p.x - 0.2, lo - 0.2, p.x + 0.2, hi)
        elif p.kind == "spine":                # supply spine runs down out of the cell
            self.pen.box("met2", p.x - 0.5, -0.5, p.x + 0.5, hi + 0.17)

    def via(self, p, y):
        if p.kind == "li":
            self.pen.cbox("met1", p.x, y, 0.34)
            self.pen.cbox("via", p.x, y, 0.15)
        elif p.kind in ("m3", "exp"):
            self.pen.cbox("via2", p.x, y, 0.2)


def flatten(subckts, sub, nets=None, prefix=""):
    """Devices of `sub` with every subcircuit call expanded; internal nets get `prefix`."""
    if nets is None:
        nets = {p: p for p in sub.pins}

    def net(n):
        return nets.get(n, prefix + n)

    out = [nr.Device(prefix + d.name, [net(n) for n in d.nets], d.model, d.params) for d in sub.devices]
    for c in sub.calls:
        child = subckts[c.subckt]
        out += flatten(subckts, child, dict(zip(child.pins, [net(n) for n in c.nets])),
                       prefix + c.name + ".")
    return out


def child_block(ctx, sname):
    """Build (once) the cell for a called subcircuit with its registered build arguments."""
    return build_block(ctx, sname, **getattr(ctx, "block_args", {}).get(sname, {}))


def assemble(subckts, name, calls, pins):
    """Synthetic subcircuit grouping `calls` (of a parent): pins = nets shared with the rest."""
    nets = []
    for c in calls:
        for n in c.nets:
            if n not in nets:
                nets.append(n)
    return nr.Subckt(name, [n for n in nets if n in pins], [], list(calls))


def build_block(ctx, sname, inline=True, assign=None, x_left=0.7, spines=None, land=None,
                no_export=(), label_nets=()):
    """Cell for `sname`.

    inline: draw the devices of called subcircuits in this cell's own rows (one channel)
      instead of placing a child cell per call.
    assign: {call name: (row, rank)} puts child cells in the n or p row; default balances widths.
    x_left: x of the first item (room for `spines` / `land`).
    spines: {net: x} met2 stubs running down from the net's track to the cell's bottom edge, at
      x left of every row; their tracks are ordered so no track crosses a spine.
    land: (net, x): the net's track is the highest and extends to x, where the parent lands a
      via stack; the track's end position is returned in Built.extra["land"].
    no_export: pins that leave by spine / land instead of a met3 stub.
    label_nets: nets that get a name label on their track (top-level pins of the design that
      no parent cell exports).
    """
    if sname in ctx.blocks:
        return ctx.blocks[sname]
    sub = ctx.subckts[sname]
    layout = ctx.layout
    guard = GUARDED.get(sname, {})
    spines = spines or {}
    devices, calls = (flatten(ctx.subckts, sub), []) if inline else (sub.devices, sub.calls)

    n_units, p_units = [], []
    for d in devices:
        if d.model in dev.MOS_MODELS:
            kind, thick = dev.MOS_MODELS[d.model]
            u = dev.mos(kind, thick, d.params["W"], d.params["L"], int(d.params["m"]), d.nets, d.name)
            (n_units if kind == "n" else p_units).append(u)
        elif d.model in dev.DIODE_MODELS:
            kind = dev.DIODE_MODELS[d.model]
            u = dev.diode(kind, d.params["area"], d.params["perim"], d.nets, d.name)
            (n_units if kind == "n" else p_units).append(u)
        elif d.model == dev.RES_MODEL:
            n_units.append(dev.res_high_po(d.params["L"], d.nets, d.name))
        else:
            raise NotImplementedError(f"{sname}: device {d.name} ({d.model})")
    groups = {"n": _make_groups("n", n_units, guard.get("n")) if n_units else [],
              "p": _make_groups("p", p_units, guard.get("p")) if p_units else []}
    insts = [_Inst(child_block(ctx, c.subckt), c, ctx.subckts[c.subckt].pins) for c in calls]

    rows = {"n": list(groups["n"]), "p": list(groups["p"])}
    if assign:
        for inst in sorted(insts, key=lambda i: assign[i.call.name][1]):
            rows[assign[inst.call.name][0]].append(inst)
    else:
        width = {r: sum(it.w + GAP_GROUP for it in rows[r]) for r in rows}
        for inst in sorted(insts, key=lambda i: -i.w):
            r = "n" if width["n"] <= width["p"] else "p"
            rows[r].append(inst)
            width[r] += inst.w + GAP_ITEM
    wn = _layout_row(rows["n"], x_left)
    wp = _layout_row(rows["p"], x_left)
    hn = max([it.h for it in rows["n"]] or [0.0])
    hp = max([it.h for it in rows["p"]] or [0.0])

    nets = []
    for src in (sub.pins, *(d.nets for d in devices), *(c.nets for c in calls)):
        for n in src:
            if n not in nets:
                nets.append(n)
    land_gap = 3.0

    # rows are vertically placed once the channel height is known; port columns do not depend on it
    def make_xy(y_outer):
        return {"n": lambda x, y: (x, Y_N0 + y), "p": lambda x, y: (x, y_outer - y)}

    def collect(dx, y_outer):
        xy = make_xy(y_outer)
        got = {"n": [], "p": []}
        for r, items in rows.items():
            shift = dx if r == "p" else 0.0
            ports = got[r]
            for it in items:
                if isinstance(it, _Group):
                    for u, ux in it.placed:
                        for net, px, py in u.ports:
                            x, y = xy[r](it.x + shift + it.pad_x + ux + px, it.pad_y + py)
                            ports.append(cr.Port(net, x, y, "li"))
                    if it.ring_net:
                        ports.append(_ring_port(it, r, shift, xy, got["n"] + got["p"]))
                else:
                    for pin, net in it.pins:
                        px = it.x + shift + it.child.pin_x[pin]
                        py = Y_N0 + it.child.h if r == "n" else y_outer - it.child.h
                        ports.append(cr.Port(net, px, py, "m3"))
        return got

    # a spine at larger x must stay below the tracks of nets whose spines are further left
    chain = sorted(spines, key=lambda n: -spines[n])
    fixed = {(a, b): TRACK_PITCH for a, b in zip(chain, chain[1:])}
    if land:
        fixed.update({(n, land[0]): TRACK_PITCH for n in nets if n != land[0]})
    sep = {"li": (SEP_LI, TRACK_PITCH, (0.26, 0.45)), "m3": (SEP_M3, TRACK_PITCH_M3, (0.4, 0.7))}
    dx = 0.0
    while True:
        got = collect(dx, 0.0)
        need, hard = dict(fixed), False
        for kind, (s_, d_, same) in sep.items():
            lo = [p for p in got["n"] if p.kind == kind]
            hi = [p for p in got["p"] if p.kind == kind]
            hard |= bool(cr.column_conflicts(lo, s_, same) or cr.column_conflicts(hi, s_, same))
            for pair in cr.vertical_constraints(lo, hi, s_):
                need[pair] = max(need.get(pair, 0.0), d_)
        order = None if hard else cr.order_nets(sub.pins + [n for n in nets if n not in sub.pins], need)
        if order:
            break
        dx = round(dx + 0.05, 3)
        if dx > 8:
            raise ValueError(f"{sname}: no conflict-free column placement")
    ys = cr.track_layout(order, set(nets), 0.0, TRACK_PITCH, need, {land[0]: land_gap} if land else None)
    y_t0 = Y_N0 + hn + 0.6
    y_outer = y_t0 + max(ys.values()) + TRACK_PITCH + hp
    height = y_outer + 0.7
    ys = {n: round(y_t0 + y, 3) for n, y in ys.items()}
    got = collect(dx, y_outer)
    ports = got["n"] + got["p"]
    wcell = max(wn, wp + dx) + 0.7

    # ---- export columns
    pins_out = [p for p in sub.pins if p not in no_export]
    taken = [p.x for p in ports if p.kind == "m3"]
    while True:
        try:
            cols = cr.free_columns(taken, x_left, wcell - 0.6, len(pins_out), SEP_M3)
            break
        except ValueError:
            wcell += 1.0
    exports = [cr.Port(pin, x, height, "exp") for pin, x in zip(pins_out, cols)]
    pin_x = dict(zip(pins_out, cols))
    extra_ports = [cr.Port(n, x, 0.0, "spine") for n, x in spines.items()]
    if land:
        extra_ports.append(cr.Port(land[0], land[1], 0.0, "land"))

    cell = layout.create_cell(sname)
    emit = _Emit(cell, layout, height)
    tracks = cr.route(ports + exports + extra_ports, ys, emit)
    for net in label_nets:
        x0 = min(p.x for p in ports + exports + extra_ports if p.net == net)
        cell.shapes(layout.layer(*dev.LAYERS["met2.label"])).insert(
            db.Text(net, g.U(x0), g.U(tracks[net])))

    # ---- draw rows
    for r, items in rows.items():
        flip = r == "p"
        shift = dx if flip else 0.0
        for it in items:
            if isinstance(it, _Group):
                _draw_group(layout, cell, it, r, it.x + shift, Y_N0 if r == "n" else y_outer, flip)
            else:
                x0 = it.x + shift
                if flip:
                    t = db.Trans(0, True, g.U(x0), g.U(y_outer))
                else:
                    t = db.Trans(0, False, g.U(x0), g.U(Y_N0))
                cell.insert(db.CellInstArray(it.child.cell.cell_index(), t))

    extra = {"land": (land[1], tracks[land[0]])} if land else {}
    built = Built(cell, wcell, height, pin_x, extra)
    ctx.blocks[sname] = built
    return built


def _ring_port(grp, row, shift, xy, ports):
    """Port on the channel-side edge of the guard ring, clear of the group's own columns."""
    own = [p.x for p in ports]
    y_local = grp.pad_y + grp.core_h + grp.rv + RING_W / 2
    lo = grp.x + shift + RING_W
    hi = lo + grp.w - 2 * RING_W
    x = lo + 0.5
    while x < hi:
        if all(abs(x - o) >= SEP_LI + 0.1 for o in own):
            break
        x += 0.05
    gx, gy = xy[row](x, y_local)
    return cr.Port(grp.ring_net, gx, gy, "li")


def _draw_group(layout, cell, grp, row, gx, base_y, flip):
    """Draw a group's units, its well / hvi / guard ring. (gx, base_y) = local origin."""
    def at(lx, ly):
        return gx + lx, (base_y - ly) if flip else (base_y + ly)

    for u, ux in grp.placed:
        ox, oy = at(grp.pad_x + ux, grp.pad_y)
        u.draw(dev.Pen(layout, cell, ox, oy, flip))
    pen = dev.Pen(layout, cell, gx, base_y, flip)
    ax0 = min(grp.pad_x + ux + u.active[0] for u, ux in grp.placed)
    ax1 = max(grp.pad_x + ux + u.active[2] for u, ux in grp.placed)
    ay0 = grp.pad_y + min(u.active[1] for u, _ in grp.placed)
    ay1 = grp.pad_y + max(u.active[3] for u, _ in grp.placed)
    thick = grp.key[1]
    if grp.ring_net:                      # the n-well must enclose its own guard ring
        ax0, ay0, ax1, ay1 = 0.0, 0.0, grp.w, grp.h
    if grp.row == "p":
        wb = (ax0 - WELL_MARGIN, ay0 - WELL_MARGIN, ax1 + WELL_MARGIN, ay1 + WELL_MARGIN)
        pen.box("nwell", *wb)
        (x0, y0), (x1, y1) = pen.pt(wb[0], wb[1]), pen.pt(wb[2], wb[3])
        WELLS.setdefault(cell.name, []).append(
            (grp.key[0], thick, (min(x0, x1), min(y0, y1), max(x0, x1), max(y0, y1))))
        if thick:
            pen.box("hvi", wb[0] - 0.3, wb[1] - 0.3, wb[2] + 0.3, wb[3] + 0.3)
    elif thick:
        pen.box("hvi", ax0 - HVI_MARGIN, ay0 - HVI_MARGIN, ax1 + HVI_MARGIN, ay1 + HVI_MARGIN)
    if grp.ring_net:
        _draw_ring(pen, grp)


def _draw_ring(pen, grp):
    """Closed tap annulus (+ implant, li1, contacts) around the group's core."""
    ox0, oy0, ox1, oy1 = 0.0, 0.0, grp.w, grp.h
    ix0, iy0, ix1, iy1 = RING_W, RING_W, grp.w - RING_W, grp.h - RING_W
    dop = "psdm" if grp.row == "n" else "nsdm"
    # (box, long axis): top / bottom bars span the full width, side bars sit between
    bars = [((ox0, oy0, ox1, iy0), "x"), ((ox0, iy1, ox1, oy1), "x"),
            ((ox0, iy0, ix0, iy1), "y"), ((ix1, iy0, ox1, iy1), "y")]
    for (x0, y0, x1, y1), axis in bars:
        pen.box("tap", x0, y0, x1, y1)
        pen.box(dop, x0 - dev.SDM_EXT, y0 - dev.SDM_EXT, x1 + dev.SDM_EXT, y1 + dev.SDM_EXT)
        pen.box("li1", x0, y0, x1, y1)
        if axis == "x":
            x = x0 + 0.4
            while x <= x1 - 0.4:
                pen.cbox("licon1", x, (y0 + y1) / 2, dev.LICON)
                x += 1.0
        else:
            y = y0 + RING_W + 0.4
            while y <= y1 - RING_W - 0.4:
                pen.cbox("licon1", (x0 + x1) / 2, y, dev.LICON)
                y += 1.0
