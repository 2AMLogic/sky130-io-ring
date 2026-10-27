"""PDK-independent geometry primitives for the I/O ring generator.

No layer numbers, no process rules: everything here takes coordinates in um
and returns klayout objects. The sky130 half lives in sky130_cells.py.

All coordinates are in um and snapped to the manufacturing grid (spec CELL.9)
before they reach the database, so a value that is not on grid is rounded,
never silently emitted off grid.
"""
import klayout.db as db

DBU = 0.001        # database unit, um
GRID_UM = 0.005    # manufacturing grid (spec CELL.9); asserted against the spec
_STEP = round(GRID_UM / DBU)


def U(x):
    """um -> integer dbu, snapped to the manufacturing grid."""
    return round(x / GRID_UM) * _STEP


def box(x0, y0, x1, y1):
    return db.Box(U(x0), U(y0), U(x1), U(y1))


def cbox(cx, cy, w, h=None):
    """Box of size w x h centred on (cx, cy)."""
    h = w if h is None else h
    return box(cx - w / 2, cy - h / 2, cx + w / 2, cy + h / 2)


def poly(points):
    return db.Polygon([db.Point(U(x), U(y)) for x, y in points])


def l_band(b0, b1, depth, co, ci):
    """L-shaped band in the lower-left corner cell frame.

    The band occupies distance [b0, b1] from the die edge on both arms and
    runs out to `depth` (the corner cell edge). The outer vertex is cut by a
    45-degree chamfer of leg `co`; the inner (reflex) vertex is filled by a
    45-degree mitre of leg `ci`.
    """
    return poly([
        (depth, b0), (b0 + co, b0), (b0, b0 + co), (b0, depth),
        (b1, depth), (b1, b1 + ci), (b1 + ci, b1), (depth, b1),
    ])


def chamfered_square(lo, hi, c):
    """Axis-aligned square [lo,hi]^2 with each corner cut by a 45-degree leg c."""
    return poly([
        (lo + c, lo), (hi - c, lo), (hi, lo + c), (hi, hi - c),
        (hi - c, hi), (lo + c, hi), (lo, hi - c), (lo, lo + c),
    ])


def ring_mask(size, b0, b1, co, ci):
    """Closed ring band at distance [b0, b1] from the edge of a size x size die.

    Built independently of the cells (outer chamfered square minus the inner
    square with its corners filled), so it is a valid oracle for them.
    """
    outer = db.Region(chamfered_square(b0, size - b0, co))
    inner = db.Region(chamfered_square(b1, size - b1, ci))
    return outer - inner


def annulus(x0, y0, x1, y1, w):
    """Closed rectangular annulus: outer box minus the box inset by w."""
    return db.Region(box(x0, y0, x1, y1)) - db.Region(box(x0 + w, y0 + w, x1 - w, y1 - w))


def via_array(cx, cy, size, pitch, nx, ny=None):
    """nx x ny array of size x size squares at `pitch`, centred on (cx, cy)."""
    ny = nx if ny is None else ny
    out = []
    for i in range(nx):
        for j in range(ny):
            x = cx + (i - (nx - 1) / 2) * pitch
            y = cy + (j - (ny - 1) / 2) * pitch
            out.append(cbox(x, y, size))
    return out


def row(x0, x1, y, size, pitch):
    """Squares of `size` along y from x0 to x1 at `pitch`, first centre at x0."""
    out = []
    x = x0
    while x <= x1 + 1e-9:
        out.append(cbox(x, y, size))
        x += pitch
    return out


def on_grid(layout):
    """True when every vertex in every cell is a multiple of the grid."""
    for ci in layout.each_cell():
        for li in layout.layer_indexes():
            for s in ci.shapes(li).each():
                if s.is_box():
                    pts = [s.box.p1, s.box.p2]
                elif s.is_polygon():
                    pts = list(s.polygon.each_point_hull())
                    for h in range(s.polygon.holes()):
                        pts += list(s.polygon.each_point_hole(h))
                else:
                    continue
                if any(p.x % _STEP or p.y % _STEP for p in pts):
                    return False
    return True
