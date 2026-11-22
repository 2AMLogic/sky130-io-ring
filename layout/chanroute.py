"""Single-channel router (PDK-independent): no layer numbers, no process rules.

Two rows of items face a horizontal channel. Every net gets its own horizontal
track in the channel; every port of the net drops vertically to that track.
Because a track and a drop are on different layers and every port has a column
of its own, nets cannot touch: a drop only meets a track at its own via.

The caller supplies an `emit` object with

    track(net, x0, x1, y)      horizontal track of `net` spanning x0..x1 at y
    drop(port, y)              vertical drop of the port from port.y to y
    via(port, y)               track/drop junction at (port.x, y)

and keeps `port.x` distinct per net (see `column_conflicts`).
"""
from collections import namedtuple

EPS = 1e-6
Port = namedtuple("Port", "net x y kind")


def column_conflicts(ports, sep, same_net=None):
    """Pairs of ports whose drops would collide.

    Ports on different nets closer than `sep` collide. Ports on one net collide
    when their gap `same_net` = (merge, apart) is neither merged (< merge) nor
    clear (>= apart): two drops that nearly touch break the layer's spacing rule.
    """
    bad = []
    pts = sorted(ports, key=lambda p: p.x)
    reach = max(sep, same_net[1] if same_net else 0.0)
    for i, p in enumerate(pts):
        for q in pts[i + 1:]:
            d = q.x - p.x
            if d >= reach - EPS:
                break
            if q.net != p.net:
                if d < sep - EPS:
                    bad.append((p, q))
            elif same_net and same_net[0] - EPS <= d < same_net[1] - EPS:
                bad.append((p, q))
    return bad


def vertical_constraints(low_ports, high_ports, sep):
    """(a, b) pairs: net a's track must lie below net b's.

    `low_ports` drop upward to their track, `high_ports` drop downward. A low
    and a high drop whose columns are closer than `sep` would overlap unless
    the low port's track is below the high port's track.
    """
    below = set()
    for p in low_ports:
        for q in high_ports:
            if p.net != q.net and abs(p.x - q.x) < sep - EPS:
                below.add((p.net, q.net))
    return below


def order_nets(nets, below):
    """Track order (lowest first) satisfying `below`; None if the constraints cycle."""
    left = list(nets)
    out = []
    while left:
        for n in left:
            if not any(b == n and a in left for a, b in below):
                out.append(n)
                left.remove(n)
                break
        else:
            return None
    return out


def free_columns(taken, lo, hi, count, sep, step=0.05):
    """`count` x positions in [lo, hi], each `sep` from `taken` and from each other."""
    out = []
    x = lo
    while x <= hi + 1e-9 and len(out) < count:
        if all(abs(x - t) >= sep - EPS for t in taken) and all(abs(x - o) >= sep - EPS for o in out):
            out.append(round(x, 3))
            x += sep
        else:
            x += step
    if len(out) < count:
        raise ValueError(f"no room for {count} columns of pitch {sep} in {lo}..{hi}")
    return out


def track_layout(order, present, y0, pitch, need=None, gaps=None):
    """Track y per net: `pitch` above the previous track, at least need[(a, b)] above net a's
    track for each constraint, plus gaps[net]. Only nets in `present` get a track."""
    need, gaps = need or {}, gaps or {}
    ys, prev = {}, None
    for net in order:
        if net not in present:
            continue
        y = y0 if prev is None else ys[prev] + pitch
        for (a, b), d in need.items():
            if b == net and a in ys:
                y = max(y, ys[a] + d)
        ys[net] = round(y + gaps.get(net, 0.0), 3)
        prev = net
    return ys


def route(ports, ys, emit, merge=0.26):
    """Draw every net's track at ys[net] and drop each of its ports to it.

    A port whose drop lies within `merge` of an earlier drop of the same net
    (same kind) merges with it, so it gets no via of its own.
    """
    for net, y in ys.items():
        mine = sorted((p for p in ports if p.net == net), key=lambda p: (p.kind, p.x))
        emit.track(net, min(p.x for p in mine), max(p.x for p in mine), y)
        last = {}
        for p in mine:
            emit.drop(p, y)
            if p.kind not in last or p.x - last[p.kind] >= merge - EPS:
                emit.via(p, y)
                last[p.kind] = p.x
    return ys
