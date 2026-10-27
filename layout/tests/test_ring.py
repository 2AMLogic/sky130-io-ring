#!/usr/bin/env python3
"""Seam, rail-continuity and spec-value tests for the ring generator.

Each defect test seeds one fault into a good build and requires self_check to
name it; the good build must report nothing. Needs `klayout` (pip), no PDK.

  python3 layout/tests/test_ring.py
"""
import sys
import tempfile
import unittest
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))
import gen_ring as G  # noqa: E402
import ringgeom as g  # noqa: E402
import chanroute as cr  # noqa: E402
import netlist_read as nr  # noqa: E402
import sky130_blocks as sb  # noqa: E402
import sky130_cells as T  # noqa: E402
import klayout.db as db  # noqa: E402


def build():
    p = G.spec_params()
    p["depth"] = T.DEPTH
    layout, cells, top, size, placed = G.build_layout(T, p)
    return p, layout, cells, top, size, placed


def check(p, layout, cells, top, size, placed):
    return G.self_check(T, p, layout, cells, top, size, placed)


class Spec(unittest.TestCase):
    def test_values_come_from_spec(self):
        p = G.spec_params()
        self.assertEqual(p["pitch"], 80)
        self.assertEqual(p["rail_layers"], {"VSS": "met5", "VDDIO": "met4", "VDD": "met3"})
        self.assertEqual(p["fillers"], [1, 5, 10, 20])
        self.assertEqual(p["grid"], 0.005)
        self.assertLessEqual(T.DEPTH, p["depth_max"])

    def test_fill_composition(self):
        for n in (0, 1, 4, 37, 99, 437 - 400):
            self.assertEqual(sum(G.compose_fill(n, [1, 5, 10, 20])), n)
        with self.assertRaises(ValueError):
            G.compose_fill(3, [5, 20])


class Good(unittest.TestCase):
    def test_clean_build_has_no_findings(self):
        self.assertEqual(check(*build()), [])

    def test_close_first_set_present(self):
        seq = G.side_sequence(build()[0])
        for k in ("gpio", "vddio", "vss"):
            self.assertIn(k, seq)

    def test_clamp_devices_at_netlist_wlm(self):
        """vddio / vdd draw every clamp device at netlist W / L / m (finger counts)."""
        p, layout, cells, *_ = build()
        poly, diff = layout.layer(*T.LAYERS["poly"]), layout.layer(*T.LAYERS["diff"])
        for kind, fingers in (("vddio", 400 + 10 + 4 + 1 + 20 + 4 + 1),
                              ("vdd", 800 + 10 + 4 + 1 + 20 + 4 + 1)):
            reg = (db.Region(cells[kind].shapes(poly)).merged()
                   & db.Region(cells[kind].shapes(diff)).merged())
            self.assertEqual(reg.count(), fingers, kind)
        capm = layout.layer(*T.LAYERS["capm"])
        for kind in ("vddio", "vdd"):
            plates = list(db.Region(cells[kind].shapes(capm)).merged().each())
            self.assertEqual([(q.bbox().width(), q.bbox().height()) for q in plates],
                             [(g.U(30), g.U(33))] * 2, kind)

    def test_erc_spec_lists_the_vdd_clamp_wells(self):
        """signoff/erc-supply-spec.json names the four VDD-tied clamp n-wells as boxes (among others)."""
        import json
        spec = json.loads((HERE.parents[1] / "signoff" / "erc-supply-spec.json").read_text())
        tie = {t["name"]: t for t in spec["ties"]}["ntap_vdd"]
        p, layout, cells, top, *_ = build()
        nwell = layout.layer(*T.LAYERS["nwell"])
        got = set()
        for inst in top.each_inst():
            if inst.cell_index != cells["vdd"].cell_index():
                continue
            for q in db.Region(inst.cell.begin_shapes_rec(nwell)).merged().each():
                b = q.bbox().transformed(inst.trans)
                if max(b.width(), b.height()) < g.U(20):     # the clamp well, not the 80 x 24 guard well
                    got.add(tuple(round(v * layout.dbu, 3) for v in (b.left, b.bottom, b.right, b.top)))
        self.assertEqual(len(got), 4)
        self.assertLessEqual(got, {tuple(round(v, 3) for v in b) for b in tie["well_requires_boxes"]})

    def test_erc_spec_matches_the_generator_record(self):
        """The spec's VDD-well / GPIO-core boxes are what signoff/gen_erc_spec.py derives now."""
        import json
        sys.path.insert(0, str(HERE.parents[1] / "signoff"))
        import gen_erc_spec
        path = HERE.parents[1] / "signoff" / "erc-supply-spec.json"
        spec = json.loads(path.read_text())
        wells, cores = gen_erc_spec.ring_boxes()
        self.assertEqual(len(wells), 7 * len(cores))
        self.assertEqual(gen_erc_spec.refreshed(spec, wells, cores), spec)

    def test_reproducible_bytes(self):
        with tempfile.TemporaryDirectory() as a, tempfile.TemporaryDirectory() as b:
            ra, _, _ = G.generate(a, T)
            rb, _, _ = G.generate(b, T)
            self.assertEqual(G.sha256_file(ra), G.sha256_file(rb))


class Defects(unittest.TestCase):
    def assert_flags(self, mutate, needle):
        state = build()
        mutate(*state)
        found = check(*state)
        self.assertTrue(any(needle in f for f in found), f"{needle!r} not in {found}")

    def test_rail_gap_in_a_cell(self):
        def cut(p, layout, cells, *_):
            li = layout.layer(*T.LAYERS["met4"])
            c = cells["vss"]
            r = db.Region(c.shapes(li)) - db.Region(g.box(30, 25, 35, 45))
            c.shapes(li).clear()
            c.shapes(li).insert(r)
        self.assert_flags(cut, "VDDIO")

    def test_rail_on_wrong_y_extent(self):
        def shift(p, layout, cells, *_):
            li = layout.layer(*T.LAYERS["met3"])
            c = cells["gpio"]
            c.shapes(li).clear()
            c.shapes(li).insert(g.box(0, 52, 80, 64))
        self.assert_flags(shift, "VDD")

    def test_instances_overlap(self):
        def overlap(p, layout, cells, top, size, placed):
            placed.append(("gpio", db.Box(g.U(100), 0, g.U(180), g.U(10))))
        self.assert_flags(overlap, "overlap")

    def test_off_grid_vertex(self):
        def off(p, layout, cells, *_):
            cells["fill_5"].shapes(layout.layer(*T.LAYERS["met1"])).insert(db.Box(0, 0, 1001, 1000))
        self.assert_flags(off, "off the manufacturing grid")

    def test_non_45_degree_edge(self):
        def bevel(p, layout, cells, *_):
            pts = [db.Point(0, 0), db.Point(g.U(10), 0), db.Point(g.U(10), g.U(3))]
            cells["fill_5"].shapes(layout.layer(*T.LAYERS["met1"])).insert(db.Polygon(pts))
        self.assert_flags(bevel, "45/90")

    def test_open_guard_ring(self):
        def open_ring(p, layout, cells, *_):
            drv = layout.cell("sky130_ioring_gpio_drv")
            li = layout.layer(*T.LAYERS["tap"])
            ring = [r for r in db.Region(drv.shapes(li)).merged().each() if r.holes() == 1][0]
            b = ring.bbox()
            cut = g.box(b.left * g.DBU - 1, (b.bottom + b.top) / 2 * g.DBU - 0.3,
                        b.left * g.DBU + 1, (b.bottom + b.top) / 2 * g.DBU + 0.3)
            r = db.Region(drv.shapes(li)) - db.Region(cut)
            drv.shapes(li).clear()
            drv.shapes(li).insert(r)
        self.assert_flags(open_ring, "LU.1")

    def test_cell_too_deep(self):
        def deep(p, layout, cells, *_):
            cells["vss"].shapes(layout.layer(*T.LAYERS["met5"])).insert(g.box(0, 190, 10, 201))
        self.assert_flags(deep, "CELL.3")


def gates(layout, cellname):
    """Every poly-over-diff gate rectangle drawn in (or below) the named cell."""
    cell = layout.cell(cellname)
    poly = db.Region(cell.begin_shapes_rec(layout.layer(*T.LAYERS["poly"]))).merged()
    diff = db.Region(cell.begin_shapes_rec(layout.layer(*T.LAYERS["diff"]))).merged()
    return list((poly & diff).each())


def erase(layout, cellname, layer, keep_if):
    """Drop, from one cell's own shapes on `layer`, the boxes for which keep_if(box) is false."""
    cell = layout.cell(cellname)
    li = layout.layer(*T.LAYERS[layer])
    kept = [s.box for s in cell.shapes(li).each() if s.is_box() and keep_if(s.box)]
    n = cell.shapes(li).size()
    cell.shapes(li).clear()
    for b in kept:
        cell.shapes(li).insert(b)
    return n - len(kept)


class Devices(unittest.TestCase):
    """The drawn gpio devices must be the netlists' devices, finger for finger."""

    def assert_flags(self, mutate, needle="DEV:"):
        state = build()
        self.assertTrue(mutate(*state), "the seeded defect changed nothing")
        found = check(*state)
        self.assertTrue(any(needle in f for f in found), f"{needle!r} not in {found}")

    def test_census_counts_every_finger(self):
        p, layout, cells, *_ = build()
        want, _, _ = T._expected_devices(T.sb.load_subckts())
        got, _, _ = T._drawn_devices(layout, cells["gpio"])
        self.assertEqual(want, got)
        # 20 + 10 driver fingers of W=5 L=0.5 are part of it (gpio_drv: m=20 and m=10)
        self.assertEqual(got.count(("p", True, 5.0, 0.5)), 20)
        self.assertEqual(got.count(("n", True, 5.0, 0.5)), 10)

    def test_missing_gate_finger(self):
        def cut(p, layout, *_):
            one = gates(layout, "sky130_ioring_gpio_drv")[0].bbox()
            return erase(layout, "sky130_ioring_gpio_drv", "poly",
                         lambda b: not (b.left == one.left and b.bottom <= one.bottom and b.top >= one.top))
        self.assert_flags(cut)

    def test_wrong_gate_width(self):
        def thin(p, layout, *_):
            cell = layout.cell("sky130_ioring_gpio_pulls")
            li = layout.layer(*T.LAYERS["diff"])
            before = db.Region(cell.shapes(li)).area()
            reg = db.Region(cell.shapes(li)) - db.Region(db.Box(-10**7, g.U(2.0), 10**7, 10**7))
            cell.shapes(li).clear()
            cell.shapes(li).insert(reg)
            return before - reg.area()
        self.assert_flags(thin)

    def test_pmos_without_nwell(self):
        def drop(p, layout, *_):
            return erase(layout, "sky130_ioring_gpio_ls", "nwell", lambda b: False)
        self.assert_flags(drop)

    def test_thick_device_without_hvi(self):
        def drop(p, layout, *_):
            return erase(layout, "sky130_ioring_gpio_rcv", "hvi", lambda b: False)
        self.assert_flags(drop)

    def test_missing_diode_marker(self):
        def drop(p, layout, *_):
            cell = layout.cell("sky130_ioring_gpio_esd")
            li = layout.layer(*T.LAYERS["diode.mark"])
            first = next(cell.shapes(li).each())
            cell.shapes(li).erase(first)
            return 1
        self.assert_flags(drop)

    def test_missing_resistor_marker(self):
        def drop(p, layout, *_):
            return erase(layout, "sky130_ioring_gpio_esd", "res.mark", lambda b: False)
        self.assert_flags(drop)


class Router(unittest.TestCase):
    def test_same_column_needs_vertical_order(self):
        low = [cr.Port("a", 1.0, 0, "li")]
        high = [cr.Port("b", 1.2, 9, "li"), cr.Port("c", 5.0, 9, "li")]
        below = cr.vertical_constraints(low, high, 0.6)
        self.assertEqual(below, {("a", "b")})
        self.assertEqual(cr.order_nets(["b", "a", "c"], below), ["a", "b", "c"])

    def test_cyclic_constraints_are_refused(self):
        self.assertIsNone(cr.order_nets(["a", "b"], {("a", "b"), ("b", "a")}))

    def test_close_ports_on_different_nets_collide(self):
        a = cr.Port("a", 1.0, 0, "li")
        self.assertTrue(cr.column_conflicts([a, cr.Port("b", 1.4, 0, "li")], 0.6))
        self.assertFalse(cr.column_conflicts([a, cr.Port("b", 1.6, 0, "li")], 0.6))

    def test_same_net_gap_must_merge_or_clear(self):
        a = cr.Port("a", 1.0, 0, "m3")
        near = cr.Port("a", 1.5, 9, "m3")
        self.assertTrue(cr.column_conflicts([a, near], 0.85, (0.4, 0.7)))
        self.assertFalse(cr.column_conflicts([a, cr.Port("a", 1.2, 9, "m3")], 0.85, (0.4, 0.7)))
        self.assertFalse(cr.column_conflicts([a, cr.Port("a", 1.8, 9, "m3")], 0.85, (0.4, 0.7)))

    def test_tracks_keep_required_distance(self):
        ys = cr.track_layout(["a", "b", "c"], {"a", "b", "c"}, 10.0, 0.5, {("a", "c"): 1.2})
        self.assertEqual(ys, {"a": 10.0, "b": 10.5, "c": 11.2})

    def test_free_columns_respect_taken(self):
        cols = cr.free_columns([2.0], 0.0, 5.0, 3, 0.85)
        self.assertEqual(len(cols), 3)
        self.assertTrue(all(abs(c - 2.0) >= 0.85 - 1e-6 for c in cols))
        with self.assertRaises(ValueError):
            cr.free_columns([2.0], 0.0, 1.0, 3, 0.85)


class NetlistReader(unittest.TestCase):
    def test_reads_devices_and_calls(self):
        subs = sb.load_subckts()
        drv = subs["sky130_ioring_gpio_drv"]
        self.assertEqual(drv.pins, ["PG", "NG", "PAD", "VDDIO", "VSS"])
        self.assertEqual({d.name: int(d.params["m"]) for d in drv.devices}, {"MP": 20, "MN": 10})
        self.assertEqual([c.subckt for c in subs["sky130_ioring_gpio_ls"].calls], ["sky130_ioring_inv"])
        flat = sb.flatten(subs, subs["sky130_ioring_gpio_ls"])
        self.assertEqual(len(flat), 6)

    def test_unknown_card_is_refused(self):
        with tempfile.TemporaryDirectory() as d:
            f = Path(d) / "x.spice"
            f.write_text(".subckt t a b\nR1 a b 1k\n.ends\n")
            with self.assertRaises(ValueError):
                nr.parse(f, set())


if __name__ == "__main__":
    unittest.main()
