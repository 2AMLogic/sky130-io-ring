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
        """signoff/erc-supply-spec.json names the four VDD-tied clamp n-wells as boxes."""
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
        self.assertEqual(got, {tuple(round(v, 3) for v in b) for b in tie["well_requires_boxes"]})

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
            li = layout.layer(*T.LAYERS["tap"])
            c = cells["gpio"]
            r = db.Region(c.shapes(li)) - db.Region(g.box(5, 84, 9, 86))
            c.shapes(li).clear()
            c.shapes(li).insert(r)
        self.assert_flags(open_ring, "LU.1")

    def test_cell_too_deep(self):
        def deep(p, layout, cells, *_):
            cells["vss"].shapes(layout.layer(*T.LAYERS["met5"])).insert(g.box(0, 190, 10, 201))
        self.assert_flags(deep, "CELL.3")


if __name__ == "__main__":
    unittest.main()
