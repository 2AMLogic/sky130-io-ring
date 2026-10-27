"""sky130 supply-clamp devices (RC trigger, inverter chain, big NMOS, MIM cap).

The device-level half of the `vddio` and `vdd` cells: draws, from the item-1
netlists (`design/netlists/sky130_ioring_clamp_{io,core}.spice`), every clamp
device at its netlist W / L / m, wires them with li1, met1 and vertical met2
straps, and ties the straps to the cell rails. Called by sky130_cells.py; the
PDK-independent ring assembly never sees it.

Provenance: shapes are drawn from the generic sky130 layer map and the rule
values the klt sky130 deck states; no geometry is taken from or traced against
the foundry sky130_fd_io library (decision 0001).

Honest scope: this is a connectivity-correct drawing of the netlist devices for
extraction / LVS / the curated DRC deck. Finger pitch, bus widths and strap
widths are drawing choices, not current-density or ESD sizing; nothing here is
ESD-rated or qualified, and metal widths were not checked against a foundry
electromigration or snapback rule (decision 0004).
"""
import ringgeom as g

# ------------------------------------------------------------ constants ----
SDW = 0.34          # source/drain region width between gates (licon + 2 x 0.085)
LICON = 0.17
LI_W = 0.17
BUS_H = 0.30        # met1 bus height (via1 enclosure 0.055 each side)
STRAP_W = 0.40      # met2 strap width
ROW_GAP = 0.9       # clear space between two rows' outermost metal

# Vertical stack of one finger row, offsets from the row origin `ry`:
TAP_Y = (0.0, 0.34)             # body tap strip
POLYBUS_Y = (0.62, 1.12)        # gate poly bus
DIFF_Y0 = 1.30                  # bottom of the diffusion
ENDCAP = 0.15                   # poly past the diffusion
DBUS_GAP = 0.70                 # diffusion top to drain bus centre

# met2 strap x centres in the strap zone at the left of every cell.
STRAP_X = {"VSS": 1.0, "VP": 1.9, "GATE": 2.8, "G2": 3.7, "G1": 4.6, "T": 5.5}
ARRAY_X0 = 7.0                  # first finger array x


def row_height(W):
    """Row origin to the top of its drain bus."""
    return DIFF_Y0 + W + DBUS_GAP + BUS_H / 2


class Draw:
    """Thin wrapper over the sky130 Ctx: add(layer, shape) into one cell."""

    def __init__(self, ctx, cell):
        self.ctx, self.cell = ctx, cell

    def __call__(self, layer, shape):
        self.ctx.add(self.cell, layer, shape)

    def region(self, layer, region):
        self.ctx.add_region(self.cell, layer, region)


def _licons(W):
    """Centre y offsets (from the diffusion bottom) of a contact column."""
    n = int((W - 0.12 - LICON) / 0.34) + 1
    span = (n - 1) * 0.34 + LICON
    y0 = (W - span) / 2 + LICON / 2
    return [y0 + i * 0.34 for i in range(n)]


def _via1(d, x, y):
    d("via", g.cbox(x, y, 0.15))


def mos_row(d, x0, ry, nf, W, L, kind, hv, s_net, d_net, g_net, tap_net):
    """One finger row at (x0, ry): nf fingers of W x L sharing S/D regions.

    kind 'n' or 'p'. Returns a dict of attachment points: bus y centres, x
    extents, the gate pad centre and the per-net buses the router must reach.
    """
    pitch = L + SDW
    xend = x0 + nf * pitch + SDW
    yd0 = ry + DIFF_Y0
    yd1 = yd0 + W
    ys = ry + (TAP_Y[0] + TAP_Y[1]) / 2          # source bus / tap centre
    yd = yd1 + DBUS_GAP                          # drain bus centre
    imp = "nsdm" if kind == "n" else "psdm"      # implant over the diffusion
    timp = "psdm" if kind == "n" else "nsdm"     # implant over the body tap

    d("diff", g.box(x0, yd0, xend, yd1))
    d(imp, g.box(x0 - 0.125, yd0 - 0.125, xend + 0.125, yd1 + 0.125))
    if hv:
        d("hvi", g.box(x0 - 0.3, yd0 - 0.3, xend + 0.3, yd1 + 0.3))
    # fingers and gate poly bus
    gx0 = x0 - 0.8
    d("poly", g.box(gx0, ry + POLYBUS_Y[0], xend, ry + POLYBUS_Y[1]))
    for i in range(nf):
        xa = x0 + i * pitch + SDW
        d("poly", g.box(xa, ry + 0.9, xa + L, yd1 + ENDCAP))
    # source / drain contacts, li1 strips
    cys = _licons(W)
    s_top = yd0 + cys[-1] + LICON / 2 + 0.08
    d_bot = yd0 + cys[0] - LICON / 2 - 0.08
    for i in range(nf + 1):
        xc = x0 + i * pitch + SDW / 2
        for cy in cys:
            d("licon1", g.cbox(xc, yd0 + cy, LICON))
        if i % 2 == 0:   # source: li1 down to the tap band
            d("li1", g.box(xc - LI_W / 2, ys - LI_W / 2, xc + LI_W / 2, s_top))
        else:            # drain: li1 up to the drain bus
            d("li1", g.box(xc - LI_W / 2, d_bot, xc + LI_W / 2, yd + LI_W / 2))
            d("mcon", g.cbox(xc, yd, LICON))
    # body tap strip (p+ in p-sub for n rows, n+ in the well for p rows)
    d("tap", g.box(x0, ry + TAP_Y[0], xend, ry + TAP_Y[1]))
    d(timp, g.box(x0 - 0.125, ry + TAP_Y[0] - 0.125, xend + 0.125, ry + TAP_Y[1] + 0.125))
    d("li1", g.box(x0, ys - LI_W / 2, xend, ys + LI_W / 2))
    xc = x0 + 0.2
    while xc <= xend - 0.2:
        d("licon1", g.cbox(xc, ys, LICON))
        xc += 0.68
    # met1 buses: source/tap (mcon every 3 um) and drain
    xs0 = STRAP_X[s_net] - 0.2
    xd0 = STRAP_X[d_net] - 0.2
    d("met1", g.box(xs0, ys - BUS_H / 2, xend, ys + BUS_H / 2))
    x = x0 + 0.2
    while x <= xend - 0.2:
        d("mcon", g.cbox(x, ys, LICON))
        x += 3.0
    d("met1", g.box(xd0, yd - BUS_H / 2, xend, yd + BUS_H / 2))
    # gate pad on the poly bus, left of the array
    gxc, gyc = x0 - 0.5, ry + (POLYBUS_Y[0] + POLYBUS_Y[1]) / 2
    d("licon1", g.cbox(gxc, gyc, LICON))
    d("npc", g.cbox(gxc, gyc, 0.4))
    d("li1", g.cbox(gxc, gyc, LI_W, 0.34))
    d("mcon", g.cbox(gxc, gyc, LICON))
    xg0 = STRAP_X[g_net] - 0.2
    d("met1", g.box(xg0, gyc - BUS_H / 2, gxc + 0.15, gyc + BUS_H / 2))
    # vias from the buses up to their straps
    _via1(d, STRAP_X[s_net], ys)
    _via1(d, STRAP_X[d_net], yd)
    _via1(d, STRAP_X[g_net], gyc)
    return {"x0": x0, "xend": xend, "y0": ry - 0.5, "y1": yd + BUS_H / 2,
            "ys": ys, "yd": yd, "yg": gyc, "yd0": yd0, "yd1": yd1}


# ----------------------------------------------------------- resistors ----
RES_W = 0.69        # xhigh poly resistor width (res_xhigh_po_0p69)
RES_PITCH = 3.2     # bar to bar


def _head(d, x, y):
    """Poly head contact: licon pair, npc, li1, mcon, met1 pad centred near x."""
    for dx in (0.4, 1.0):
        d("licon1", g.cbox(x + dx, y, LICON))
    d("npc", g.box(x - 0.1, y - 0.3, x + 1.4, y + 0.3))
    d("li1", g.box(x + 0.235, y - LI_W / 2, x + 1.165, y + LI_W / 2))
    d("mcon", g.cbox(x + 0.7, y, LICON))
    d("met1", g.cbox(x + 0.7, y, 0.3))


def resistor_chain(d, x0, ya, length, a_net, b_net):
    """Two series xhigh poly bars, a_net - R1 - T1 - R2 - b_net, joined at the
    far end by an unrouted poly head (the T1 node). Returns the top y."""
    yb = ya + RES_PITCH
    hl = 1.4
    xb0, xb1 = x0 + hl, x0 + hl + length
    for y in (ya, yb):
        yc = y + RES_W / 2
        d("poly", g.box(x0, y, xb1 + hl, y + RES_W))
        d("polyres", g.box(xb0, y, xb1, y + RES_W))
        d("urpm", g.box(xb0 - 0.2, yc - 0.7, xb1 + 0.2, yc + 0.7))
        d("psdm", g.box(xb0 - 0.2, yc - 0.7, xb1 + 0.2, yc + 0.7))
    d("poly", g.box(xb1, ya, xb1 + hl, yb + RES_W))      # T1 node, no contact
    ca, cb = ya + RES_W / 2, yb + RES_W / 2
    _head(d, x0, ca)
    _head(d, x0, cb)
    d("met1", g.box(STRAP_X[a_net] - 0.2, ca - BUS_H / 2, x0 + 0.85, ca + BUS_H / 2))
    d("met1", g.box(STRAP_X[b_net] - 0.2, cb - BUS_H / 2, x0 + 0.85, cb + BUS_H / 2))
    _via1(d, STRAP_X[a_net], ca)
    _via1(d, STRAP_X[b_net], cb)
    return {"a": ca, "b": cb, "top": yb + RES_W + 0.7}


# ------------------------------------------------------------ MIM cap ----
def mim_cap(d, xa, ym, w, l):
    """Bottom plate met3 (net bottom), capm + met4 top plate with a via3 array."""
    d("met3", g.box(xa - 0.2, ym - 0.2, xa + w + 0.2, ym + l + 0.2))
    d("capm", g.box(xa, ym, xa + w, ym + l))
    d("met4", g.box(xa + 0.3, ym + 0.3, xa + w - 0.3, ym + l - 0.3))
    for b in g.via_array(xa + w / 2, ym + l / 2, 0.2, 2.0, int((w - 1.6) / 2.0) + 1,
                         int((l - 1.6) / 2.0) + 1):
        d("via3", b)


def _via2_stack(d, x, y, top):
    """met2 -> via2 -> met3 (-> via3 -> met4) at (x, y); `top` is 'met3'/'met4'."""
    d("via2", g.cbox(x, y, 0.2))
    d("met3", g.cbox(x, y, 0.5))
    if top == "met4":
        d("via3", g.cbox(x, y, 0.2))
        d("met4", g.cbox(x, y, 0.5))


def _vss_stack(d, x, y):
    """met2 -> via2 -> via3 -> via4 under the met5 VSS rail."""
    d("via2", g.cbox(x, y, 0.2))
    d("met3", g.cbox(x, y, 0.5))
    d("via3", g.cbox(x, y, 0.2))
    d("met4", g.cbox(x, y, 1.4))
    d("via4", g.cbox(x, y, 0.8))


# ------------------------------------------------------------ the clamp ----
def clamp_spec(core):
    """(label, kind, W, m, s, d, g) per device from the item-1 netlists."""
    if core:
        return dict(L=0.15, hv=False, mcl=(5, 800), mn3=(3, 10), mn2=(1, 4),
                    mn1=(0.65, 1), mp3=(5, 20), mp2=(3, 4), mp1=(1, 1))
    return dict(L=0.5, hv=True, mcl=(5, 400), mn3=(5, 10), mn2=(2, 4),
                mn1=(1, 1), mp3=(5, 20), mp2=(5, 4), mp1=(2, 1))


def _split(m, per):
    n = -(-m // per)
    base, extra = divmod(m, n)
    return [base + (1 if i < extra else 0) for i in range(n)]


def build_clamp(d, core, vp_rail, y_start=66.0, y_vss_tie=16.0, mim_y=156.2,
                width=80.0):
    """Draw the full clamp into `d`'s cell.

    vp_rail = (layer, y) where the VP strap ties into the cell's own rail band.
    Returns a dict of what was drawn (rows, device counts) for the self-checks.
    """
    sp = clamp_spec(core)
    L, hv = sp["L"], sp["hv"]
    pitch = L + SDW
    fit = int((width - 3.0 - ARRAY_X0 - SDW) / pitch)       # fingers per row
    use = {n: [] for n in STRAP_X}            # net -> y of every via1 on its strap
    rows = []

    def add_row(kind, W, nf, s, dn, gn, ry):
        r = mos_row(d, ARRAY_X0, ry, nf, W, L, kind, hv, s, dn, gn, s)
        use[s].append(r["ys"]); use[dn].append(r["yd"]); use[gn].append(r["yg"])
        rows.append((kind, W, nf))
        return r

    ry = y_start
    n_rows = []
    for nf in _split(sp["mcl"][1], fit):
        n_rows.append(("n", sp["mcl"][0], nf, "VSS", "VP", "GATE"))
    n_rows.append(("n", sp["mn3"][0], sp["mn3"][1], "VSS", "GATE", "G2"))
    n_rows.append(("n", sp["mn2"][0], sp["mn2"][1], "VSS", "G2", "G1"))
    n_rows.append(("n", sp["mn1"][0], sp["mn1"][1], "VSS", "G1", "T"))
    for kind, W, nf, s, dn, gn in n_rows:
        add_row(kind, W, nf, s, dn, gn, ry)
        ry += row_height(W) + ROW_GAP
    # PFET region: one n-well (hvi encloses it for the thick-oxide devices)
    ry += 2.0
    well_y0 = ry - 0.6
    xmax = ARRAY_X0
    p_rows = [("p", sp["mp3"][0], sp["mp3"][1], "VP", "GATE", "G2"),
              ("p", sp["mp2"][0], sp["mp2"][1], "VP", "G2", "G1"),
              ("p", sp["mp1"][0], sp["mp1"][1], "VP", "G1", "T")]
    for kind, W, nf, s, dn, gn in p_rows:
        r = add_row(kind, W, nf, s, dn, gn, ry)
        xmax = max(xmax, r["xend"])
        ry += row_height(W) + ROW_GAP
    well_y1 = ry - ROW_GAP + 0.6
    d("nwell", g.box(ARRAY_X0 - 0.9, well_y0, xmax + 0.6, well_y1))
    if hv:
        d("hvi", g.box(ARRAY_X0 - 1.1, well_y0 - 0.2, xmax + 0.8, well_y1 + 0.2))
    # resistor chain VP - R1 - T1 - R2 - T
    ry += 1.5
    res = resistor_chain(d, ARRAY_X0, ry, 43.0, "VP", "T")
    use["VP"].append(res["a"]); use["T"].append(res["b"])
    # MIM: two 30 x 33 caps, bottom plate T, top plate VSS
    xa1, xa2 = 4.2, 46.0
    for xa in (xa1, xa2):
        mim_cap(d, xa, mim_y, 30.0, 33.0)
    y_bot1 = mim_y + 5.0
    _via2_stack(d, STRAP_X["T"], y_bot1, "met3")
    use["T"].append(y_bot1)
    y_bot2 = mim_y + 1.0
    d("met2", g.box(STRAP_X["T"] - 0.2, y_bot2 - 0.2, xa2 + 15.3, y_bot2 + 0.2))
    _via2_stack(d, xa2 + 15.0, y_bot2, "met3")
    use["T"].append(y_bot2)
    ytop = mim_y + 33.0 + 1.3
    d("met4", g.box(STRAP_X["VSS"] - 0.25, ytop - 0.2, xa2 + 30.0 - 0.3, ytop + 0.2))
    d("met4", g.box(xa1 + 14.8, mim_y + 33.0 - 0.3, xa1 + 15.2, ytop + 0.2))
    d("met4", g.box(xa2 + 14.8, mim_y + 33.0 - 0.3, xa2 + 15.2, ytop + 0.2))
    _via2_stack(d, STRAP_X["VSS"], ytop, "met4")
    use["VSS"].append(ytop)
    # rail ties
    use["VSS"].append(y_vss_tie)
    _vss_stack(d, STRAP_X["VSS"], y_vss_tie)
    vl, vy = vp_rail
    use["VP"].append(vy)
    _via2_stack(d, STRAP_X["VP"], vy, "met4" if vl == "met4" else "met3")
    # met2 straps
    for net, ys in use.items():
        d("met2", g.box(STRAP_X[net] - STRAP_W / 2, min(ys) - 0.3,
                        STRAP_X[net] + STRAP_W / 2, max(ys) + 0.3))
    return {"rows": rows, "top": res["top"], "uses": {k: len(v) for k, v in use.items()}}
