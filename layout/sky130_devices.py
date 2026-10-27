"""sky130 device drawers: MOS fingers, substrate / well taps, diodes, resistor.

Each drawer builds a `Unit`: a rectangle `w` x `h` in a local frame (x right,
y toward the routing channel, origin at the unit's outer corner) plus its ports.
`Unit.draw(pen)` paints it through a `Pen`, which places and optionally
mirrors the local frame. A port is (net, x, y) at the centre of a 0.3 um li1
pad; the block builder (sky130_cells.py) lands a mcon / met1 drop on it.

Rules used are the ones the klt sky130 deck checks (`klt deck rules --deck
sky130`) plus the usual drawing practice around them; nothing here is taken
from or traced against sky130_fd_io (decision 0001).
"""
import ringgeom as g

LAYERS = {
    "nwell": (64, 20), "diff": (65, 20), "tap": (65, 44), "poly": (66, 20),
    "licon1": (66, 44), "li1": (67, 20), "mcon": (67, 44),
    "met1": (68, 20), "via": (68, 44), "met2": (69, 20), "via2": (69, 44),
    "met3": (70, 20), "via3": (70, 44), "met4": (71, 20), "via4": (71, 44),
    "met5": (72, 20), "nsdm": (93, 44), "psdm": (94, 20), "pad": (76, 20),
    "npc": (95, 20), "hvi": (75, 20), "rpm": (86, 20),
    "res.mark": (66, 13), "diode.mark": (81, 23),
    "li1.label": (67, 5), "met1.label": (68, 5), "met2.label": (69, 5),
    "met3.label": (70, 5), "met4.label": (71, 5), "met5.label": (72, 5),
}

MOS_MODELS = {
    "sky130_fd_pr__nfet_01v8": ("n", False), "sky130_fd_pr__pfet_01v8": ("p", False),
    "sky130_fd_pr__nfet_g5v0d10v5": ("n", True), "sky130_fd_pr__pfet_g5v0d10v5": ("p", True),
}
DIODE_MODELS = {"sky130_fd_pr__diode_pd2nw_05v5": "p", "sky130_fd_pr__diode_pw2nd_05v5": "n"}
RES_MODEL = "sky130_fd_pr__res_high_po_1p41"
DEVICE_MODELS = set(MOS_MODELS) | set(DIODE_MODELS) | {RES_MODEL}

SW = 0.5          # source/drain strip width (diff)
LICON = 0.17
LI_W = 0.2        # li1 stripe over a contact column
PAD = 0.3         # li1 port pad
B = 0.77          # source bar bottom to diff bottom
SDM_EXT = 0.125   # implant beyond diff / tap


class Pen:
    """Paint boxes of a local frame into `cell`, shifted by (ox, oy), y optionally mirrored."""

    def __init__(self, layout, cell, ox=0.0, oy=0.0, flip=False):
        self.layout, self.cell, self.ox, self.oy, self.flip = layout, cell, ox, oy, flip

    def pt(self, x, y):
        return self.ox + x, (self.oy - y) if self.flip else (self.oy + y)

    def box(self, layer, x0, y0, x1, y1):
        ax, ay = self.pt(x0, y0)
        bx, by = self.pt(x1, y1)
        li = self.layout.layer(*LAYERS[layer])
        self.cell.shapes(li).insert(g.box(min(ax, bx), min(ay, by), max(ax, bx), max(ay, by)))

    def cbox(self, layer, cx, cy, w, h=None):
        h = w if h is None else h
        self.box(layer, cx - w / 2, cy - h / 2, cx + w / 2, cy + h / 2)


class Unit:
    def __init__(self, kind, w, h, ports, active, draw, body=None, thick=False, name=""):
        self.kind, self.w, self.h, self.ports = kind, w, h, ports
        self.active = active          # local (x0, y0, x1, y1) that wells / hvi must cover
        self.draw, self.body, self.thick, self.name = draw, body, thick, name


def _contacts(span_lo, span_hi):
    """Centres of a licon column that fits [span_lo, span_hi] with 0.06 end enclosure."""
    room = span_hi - span_lo
    n = max(1, int((room - LICON - 0.12) / 0.34) + 1)
    used = LICON + (n - 1) * 0.34
    first = span_lo + (room - used) / 2 + LICON / 2
    return [first + i * 0.34 for i in range(n)]


def mos(kind, thick, w, length, m, nets, name=""):
    """m fingers of W=w, L=length sharing source/drain strips. nets = (d, g, s, b).

    Even strips are the source, odd strips the drain; one poly bus joins the
    gates. Layout fingers count: m separate extracted devices, as the reference
    expands m= into m devices.
    """
    d, gate, s, b = nets
    pitch = length + SW
    xs = [1.0 + k * pitch for k in range(m + 1)]
    xg = xs[-1] + 0.65
    width = xg + 0.4
    top = B + w + 1.3
    cons = _contacts(B, B + w)
    ytop_con, ybot_con = cons[-1] + LICON / 2 + 0.06, cons[0] - LICON / 2 - 0.06
    x_riser = xs[0] - 0.75
    ypad = B + w + 1.15
    sdm = "nsdm" if kind == "n" else "psdm"
    srcs = [x for i, x in enumerate(xs) if i % 2 == 0]
    drns = [x for i, x in enumerate(xs) if i % 2 == 1]

    def draw(p):
        p.box("diff", xs[0] - SW / 2, B, xs[-1] + SW / 2, B + w)
        p.box(sdm, xs[0] - SW / 2 - SDM_EXT, B - SDM_EXT, xs[-1] + SW / 2 + SDM_EXT, B + w + SDM_EXT)
        for j in range(m):
            x0 = xs[j] + SW / 2
            p.box("poly", x0, B - 0.15, x0 + length, B + w + 0.4)
        p.box("poly", xs[0] + SW / 2, B + w + 0.4, xg + 0.2, B + w + 0.75)
        p.cbox("licon1", xg, B + w + 0.575, LICON)
        p.box("npc", xg - 0.3, B + w + 0.3, xg + 0.3, B + w + 0.85)
        p.box("li1", xg - PAD / 2, B + w + 0.4, xg + PAD / 2, B + w + 0.75)
        for x in xs:
            for y in cons:
                p.cbox("licon1", x, y, LICON)
        for x in srcs:
            p.box("li1", x - LI_W / 2, 0.0, x + LI_W / 2, ytop_con)
        for x in drns:
            p.box("li1", x - LI_W / 2, ybot_con, x + LI_W / 2, top)
        p.box("li1", x_riser - LI_W / 2, 0.0, srcs[-1] + LI_W / 2, 0.2)
        p.box("li1", x_riser - LI_W / 2, 0.0, x_riser + LI_W / 2, ypad + PAD / 2)
        p.box("li1", drns[0] - LI_W / 2, B + w + 1.0, drns[-1] + LI_W / 2, B + w + 1.2)
        p.cbox("li1", x_riser, ypad, PAD)
        p.cbox("li1", drns[0], ypad, PAD)

    ports = [(s, x_riser, ypad), (d, drns[0], ypad), (gate, xg, B + w + 0.575)]
    active = (xs[0] - SW / 2, B, xs[-1] + SW / 2, B + w)
    return Unit(kind, width, top + PAD / 2 - 0.15, ports, active, draw,
                body=b, thick=thick, name=name)


def tap(kind, net, thick=False):
    """Substrate (kind 'n': p+ tap) or n-well (kind 'p': n+ tap) contact, 0.5 x 1.0 um."""
    dop = "psdm" if kind == "n" else "nsdm"
    cons = _contacts(0.2, 1.2)

    def draw(p):
        p.box("tap", 0.3, 0.2, 0.8, 1.2)
        p.box(dop, 0.3 - SDM_EXT, 0.2 - SDM_EXT, 0.8 + SDM_EXT, 1.2 + SDM_EXT)
        for y in cons:
            p.cbox("licon1", 0.55, y, LICON)
        p.box("li1", 0.35, 0.25, 0.75, 1.15)
        p.cbox("li1", 0.55, 1.3, PAD)

    return Unit("tap_" + kind, 1.1, 1.45, [(net, 0.55, 1.3)], (0.3, 0.2, 0.8, 1.2), draw,
                body=net, thick=thick, name="tap")


def _grid(lo, hi, pitch):
    """Centres of a licon grid that fits [lo, hi] with 0.2 um end margins."""
    n = max(1, int((hi - lo - 0.4 - LICON) / pitch) + 1)
    used = (n - 1) * pitch
    first = (lo + hi) / 2 - used / 2
    return [first + i * pitch for i in range(n)]


def diode(kind, area, perim, nets, name=""):
    """Junction diode of the given area / perimeter (SPICE units 1e-12 m^2 and 1e-6 m).

    kind 'p': p+ diff in an n-well (pd2nw), nets = (anode, cathode); the cathode
    is the well, tied by the group's n-taps. kind 'n': n+ diff in the substrate
    (pw2nd), nets = (anode, cathode); the anode is the substrate, tied by p-taps.
    The marker layer covers the diff, as the deck's diode devices require.
    """
    a_um2, p_um = area * 1e-12, perim * 1e-6
    half = p_um / 2
    disc = half * half / 4 - a_um2
    if disc < -1e-9:
        raise ValueError(f"diode {name}: area {a_um2} / perimeter {p_um} not a rectangle")
    r = max(disc, 0.0) ** 0.5
    dw, dh = round(half / 2 + r, 3), round(half / 2 - r, 3)
    x0, y0 = 0.6, 0.5
    xs, ys = _grid(x0, x0 + dw, 0.68), _grid(y0, y0 + dh, 0.68)
    cx = x0 + dw / 2
    ypad = y0 + dh + 0.6
    dop = "psdm" if kind == "p" else "nsdm"
    port_net = nets[0] if kind == "p" else nets[1]
    body = nets[1] if kind == "p" else nets[0]

    def draw(p):
        p.box("diff", x0, y0, x0 + dw, y0 + dh)
        p.box(dop, x0 - SDM_EXT, y0 - SDM_EXT, x0 + dw + SDM_EXT, y0 + dh + SDM_EXT)
        p.box("diode.mark", x0, y0, x0 + dw, y0 + dh)
        for x in xs:
            for y in ys:
                p.cbox("licon1", x, y, LICON)
        p.box("li1", xs[0] - LI_W / 2, ys[0] - LI_W / 2, xs[-1] + LI_W / 2, ys[-1] + LI_W / 2)
        p.box("li1", cx - LI_W / 2, ys[-1], cx + LI_W / 2, ypad)
        p.cbox("li1", cx, ypad, PAD)

    return Unit(kind, dw + 2 * x0, ypad + PAD / 2, [(port_net, cx, ypad)],
                (x0, y0, x0 + dw, y0 + dh), draw, body=body, name=name)


def res_high_po(length, nets, name=""):
    """res_high_po_1p41: 1.41 um wide poly strip of the given length, contacted at both ends.

    nets = (a, b, bulk). The 66/13 marker bounds the body (it sets L); rpm is
    wider than the body to meet its own minimum width.
    """
    w, head = 1.41, 1.0
    y0 = 0.5
    cy = y0 + w / 2
    xa, xb = head / 2, head + length + head / 2
    ypad = y0 + w + 0.6

    def draw(p):
        p.box("poly", 0, y0, 2 * head + length, y0 + w)
        p.box("psdm", -SDM_EXT, y0 - SDM_EXT, 2 * head + length + SDM_EXT, y0 + w + SDM_EXT)
        p.box("res.mark", head, y0 - 0.1, head + length, y0 + w + 0.1)
        p.box("rpm", head - 0.3, y0 - 0.2, head + length + 0.3, y0 + w + 0.2)
        for x in (xa, xb):
            p.cbox("licon1", x, cy, LICON)
            p.cbox("npc", x, cy, 0.5)
            p.box("li1", x - 0.2, cy - 0.2, x + 0.2, ypad)
            p.cbox("li1", x, ypad, PAD)

    return Unit("n", 2 * head + length, ypad + PAD / 2, [(nets[0], xa, ypad), (nets[1], xb, ypad)],
                (0, y0, 2 * head + length, y0 + w), draw, body=nets[2], name=name)
