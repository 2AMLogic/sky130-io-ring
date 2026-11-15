#!/usr/bin/env python3
"""Self-tests: each checker must reject a seeded defect and accept a good input.

CI runs this before trusting the checkers' verdicts. Stdlib only.
"""
import copy
import json
import tempfile
import unittest
from pathlib import Path

import check_append_only as ao
import check_evidence_format as ef
import check_lvs_reports as lr

GOOD = {
    "kind": "pdk-smoke",
    "pdk_revision": "f6eeac7dad085ffcc829ccfd721f7b4ce39edcf7",
    "pdk_variant": "sky130A",
    "runs": {"smoke": {"log": "logs/smoke.log"}},
}


def bad(**changes):
    rec = copy.deepcopy(GOOD)
    rec.update(changes)
    return json.dumps(rec)


class EvidenceFormat(unittest.TestCase):
    def test_good_record_passes(self):
        self.assertEqual(ef.check_record(json.dumps(GOOD), "r"), [])

    def test_missing_pdk_revision_rejected(self):
        rec = copy.deepcopy(GOOD)
        del rec["pdk_revision"]
        self.assertTrue(ef.check_record(json.dumps(rec), "r"))

    def test_short_pdk_revision_rejected(self):
        self.assertTrue(ef.check_record(bad(pdk_revision="f6eeac7"), "r"))

    def test_missing_required_field_rejected(self):
        rec = copy.deepcopy(GOOD)
        del rec["runs"]
        self.assertTrue(ef.check_record(json.dumps(rec), "r"))

    def test_absolute_path_rejected(self):
        self.assertTrue(ef.check_record(bad(runs={"s": {"log": "/home/u/smoke.log"}}), "r"))

    def test_parent_path_rejected(self):
        self.assertTrue(ef.check_record(bad(runs={"s": {"log": "../x/smoke.log"}}), "r"))

    def test_invalid_json_rejected(self):
        self.assertTrue(ef.check_record("{not json", "r"))

    def test_tree_empty_sim_passes_and_bad_record_fails(self):
        with tempfile.TemporaryDirectory() as t:
            root = Path(t)
            for d in ef.EVIDENCE_DIRS:
                (root / d).mkdir()
                (root / d / "README.md").write_text("x\n")
            self.assertEqual(ef.check_tree(root), ([], 0))
            rec = root / "sim" / "exp" / "record"
            rec.mkdir(parents=True)
            (rec / "record.json").write_text(bad(pdk_revision="nope"))
            errors, n = ef.check_tree(root)
            self.assertEqual(n, 1)
            self.assertTrue(errors)

    def test_tree_missing_readme_rejected(self):
        with tempfile.TemporaryDirectory() as t:
            errors, _ = ef.check_tree(t)
            self.assertEqual(len(errors), len(ef.EVIDENCE_DIRS))

    def test_dangling_log_rejected_with_base(self):
        # With a base, a path-shaped value must resolve; without one, the
        # check stays shape-only (the contrast between the two asserts is
        # what pins the existence behaviour).
        with tempfile.TemporaryDirectory() as t:
            rec = Path(t) / "record"
            rec.mkdir()
            self.assertEqual(ef.check_record(json.dumps(GOOD), "r"), [])
            errors = ef.check_record(json.dumps(GOOD), "r", base=rec)
            self.assertTrue(any("no such file" in e for e in errors))
            # shape errors still take precedence over the existence check
            shape = ef.check_record(bad(runs={"s": {"log": "/abs/x.log"}}), "r", base=rec)
            self.assertTrue(any("absolute path" in e for e in shape))

    def test_resolvable_log_passes_with_base(self):
        with tempfile.TemporaryDirectory() as t:
            rec = Path(t) / "record"
            (rec / "logs").mkdir(parents=True)
            (rec / "logs" / "smoke.log").write_text("x\n")
            self.assertEqual(ef.check_record(json.dumps(GOOD), "r", base=rec), [])

    def test_dir_shaped_value_passes_with_base(self):
        # PATH_KEY_RE matches `dir` and `dirs`; a directory is a valid target.
        with tempfile.TemporaryDirectory() as t:
            rec = Path(t) / "record"
            (rec / "logs").mkdir(parents=True)
            (rec / "logs" / "smoke.log").write_text("x\n")
            rec2 = dict(GOOD, runs={"smoke": {"log": "logs/smoke.log", "dir": "logs"}})
            self.assertEqual(ef.check_record(json.dumps(rec2), "r", base=rec), [])

    def test_resolvable_dirs_passes_with_base(self):
        with tempfile.TemporaryDirectory() as t:
            rec = Path(t) / "record"
            (rec / "logs").mkdir(parents=True)
            rec2 = dict(GOOD, runs={"smoke": {"dirs": "logs"}})
            self.assertEqual(ef.check_record(json.dumps(rec2), "r", base=rec), [])

    def test_dangling_dirs_rejected_with_base(self):
        # `dirs` is in PATH_KEY_RE, so a value naming a path that does not
        # exist fails exactly like a dangling `log`; before the regex matched
        # the key, such a reference passed CI silently.
        with tempfile.TemporaryDirectory() as t:
            rec = Path(t) / "record"
            (rec / "logs").mkdir(parents=True)
            rec2 = dict(GOOD, runs={"smoke": {"dirs": "nonexistent-dir"}})
            errors = ef.check_record(json.dumps(rec2), "r", base=rec)
            self.assertTrue(any("no such file" in e for e in errors))

    def test_dirs_list_value_checked_with_base(self):
        with tempfile.TemporaryDirectory() as t:
            rec = Path(t) / "record"
            (rec / "logs").mkdir(parents=True)
            rec2 = dict(GOOD, runs={"smoke": {"dirs": ["logs", "missing"]}})
            errors = ef.check_record(json.dumps(rec2), "r", base=rec)
            self.assertTrue(any("no such file" in e for e in errors))

    def test_existence_failure_message_names_missing_file(self):
        # The full reason phrase is composed in bad_path; an existence failure
        # must not borrow the shape-failure prefix ("is not repo-relative").
        with tempfile.TemporaryDirectory() as t:
            errors = ef.check_record(json.dumps(GOOD), "r", base=Path(t))
            self.assertTrue(any("no such file" in e for e in errors))
            self.assertFalse(any("is not repo-relative" in e for e in errors))

    def test_shape_failure_message_keeps_prefix(self):
        with tempfile.TemporaryDirectory() as t:
            shape = ef.check_record(bad(runs={"s": {"log": "/abs/x.log"}}), "r", base=Path(t))
            self.assertTrue(any("absolute path" in e for e in shape))
            self.assertTrue(any("is not repo-relative" in e for e in shape))

    def test_non_string_path_message_reads_sensibly(self):
        # A bare non-string value is not a path-shaped value (walk_paths only
        # descends into str/list); the non-string reason is reachable through
        # a list item, where bad_path composes the phrase.
        errors = ef.check_record(bad(runs={"s": {"netlist": [3]}}), "r")
        self.assertTrue(any("not a usable path" in e for e in errors))
        self.assertFalse(any("is not repo-relative" in e for e in errors))

    def test_no_path_value_passes_with_base(self):
        rec = copy.deepcopy(GOOD)
        del rec["runs"]["smoke"]["log"]
        with tempfile.TemporaryDirectory() as t:
            self.assertEqual(ef.check_record(json.dumps(rec), "r", base=Path(t)), [])

    def test_tree_dangling_log_fails_and_created_log_passes(self):
        # End-to-end, mirroring the real record/record.json + record/logs/
        # layout: the base is the record's own directory, NOT the repo root.
        with tempfile.TemporaryDirectory() as t:
            root = Path(t)
            for d in ef.EVIDENCE_DIRS:
                (root / d).mkdir()
                (root / d / "README.md").write_text("x\n")
            rec = root / "sim" / "probe" / "record"
            rec.mkdir(parents=True)
            (rec / "record.json").write_text(json.dumps(GOOD))
            errors, n = ef.check_tree(root)
            self.assertEqual(n, 1)
            self.assertTrue(any("no such file" in e for e in errors))
            (rec / "logs").mkdir()
            (rec / "logs" / "smoke.log").write_text("x\n")
            errors, n = ef.check_tree(root)
            self.assertEqual(errors, [])
            self.assertEqual(n, 1)


class AppendOnly(unittest.TestCase):
    def test_add_passes(self):
        self.assertEqual(ao.violations("A\tsim/exp/record/new.json\nM\tREADME.md\n"), [])

    def test_modify_rejected(self):
        self.assertTrue(ao.violations("M\tsim/pdk-smoke/record/record.json\n"))

    def test_delete_rejected(self):
        self.assertTrue(ao.violations("D\tsim/pdk-smoke/record/record.json\n"))

    def test_outside_sim_ignored(self):
        self.assertEqual(ao.violations("D\tdesign/README.md\nM\tspec/io-ring.md\n"), [])

    def test_non_record_sim_paths_pass(self):
        # The guard protects evidence, not code or index: the harness and
        # index files around the records stay modifiable (issue #109).
        self.assertEqual(ao.violations("M\tsim/README.md\nM\tsim/lib/simrec.py\n"
                                       "M\tsim/clamp-probe/run.sh\nD\tsim/pdk.json\n"
                                       "A\tsim/new-probe/README.md\n"), [])

    def test_non_json_record_evidence_rejected(self):
        # A log inside record/ is evidence even though is_record() (which is
        # .json-only) would not match it; this pins the record-directory rule
        # over the is_record() shape.
        self.assertTrue(ao.violations("M\tsim/clamp-probe/record/logs/probe.log\n"))
        self.assertTrue(ao.violations("D\tsim/pdk-smoke/record/netlists/smoke.sp\n"))


class LvsReports(unittest.TestCase):
    NAME = "sky130_ioring_gpio.json"

    def good(self, name=None):
        name = name or self.NAME
        exp = lr.EXPECTATIONS[name]
        return json.dumps({
            "status": "match",
            "mismatch_count": 0,
            "counts": {"devices": dict(exp["devices"])},
            "body_verification": {"status": "verified", "device_classes": [],
                                  "device_count": exp["body_device_count"],
                                  "finding_count": 0},
        })

    def expect(self, name=None):
        return lr.EXPECTATIONS[name or self.NAME]

    def mutated(self, fn, name=None):
        rep = json.loads(self.good(name))
        fn(rep)
        return json.dumps(rep)

    def populate(self, root, skip=None, extra=None):
        d = Path(root) / "signoff" / "evidence" / "lvs"
        d.mkdir(parents=True)
        for name in lr.EXPECTATIONS:
            if name != skip:
                (d / name).write_text(self.good(name))
        if extra:
            (d / extra).write_text(self.good())
        return d

    def test_good_report_passes(self):
        self.assertEqual(lr.check_report(self.good(), "r", self.expect()), [])

    def test_mismatch_status_rejected(self):
        errors = lr.check_report(
            self.mutated(lambda r: r.update(status="mismatch")), "r", self.expect())
        self.assertTrue(any("'mismatch'" in e and "status" in e for e in errors))

    def test_body_verification_unverified_rejected(self):
        # the pre-#110 shape: the compare matched, the bodies did not resolve
        def seed(r):
            r["body_verification"] = {"status": "unverified", "device_classes": ["nfet"],
                                      "device_count": 815, "finding_count": 1}
        errors = lr.check_report(self.mutated(seed), "r", self.expect())
        self.assertTrue(any("body_verification.status" in e for e in errors))
        self.assertTrue(any("body_verification.device_count" in e for e in errors))

    def test_missing_body_verification_rejected(self):
        # a missing key must never read as satisfied
        errors = lr.check_report(
            self.mutated(lambda r: r.pop("body_verification")), "r", self.expect())
        self.assertTrue(any("missing body_verification" in e for e in errors))

    def test_missing_counts_devices_rejected(self):
        errors = lr.check_report(
            self.mutated(lambda r: r.pop("counts")), "r", self.expect())
        self.assertTrue(any("counts.devices" in e for e in errors))

    def test_devices_count_drift_rejected(self):
        def seed(r):
            r["counts"]["devices"]["matched"] = 110
        errors = lr.check_report(self.mutated(seed), "r", self.expect())
        self.assertTrue(any("counts.devices.matched" in e for e in errors))

    def test_device_count_drift_rejected(self):
        def seed(r):
            r["body_verification"]["device_count"] = 2
        errors = lr.check_report(self.mutated(seed), "r", self.expect())
        self.assertTrue(any("body_verification.device_count" in e for e in errors))

    def test_zero_device_count_is_not_a_coverage_floor(self):
        # device_count counts unresolved bodies, not inspected ones (klt#5749):
        # the vacuous and empty-inspection streams carry 0 and must pass
        for name in ("sky130_ioring_vss.json", "sky130_ioring_vddio.json"):
            self.assertEqual(lr.check_report(self.good(name), "r", self.expect(name)), [])

    def test_unknown_report_rejected(self):
        errors = lr.check_report(self.good(), "r", None)
        self.assertTrue(any("no pinned expectation" in e for e in errors))

    def test_invalid_json_rejected(self):
        self.assertTrue(lr.check_report("{not json", "r", self.expect()))

    def test_non_object_top_level_rejected(self):
        self.assertTrue(lr.check_report("[]", "r", self.expect()))

    def test_vacuous_stream_with_devices_rejected(self):
        # the body_inspection declaration is load-bearing, not prose
        name = "sky130_ioring_corner.json"

        def seed(r):
            r["counts"]["devices"] = {"layout": 3, "reference": 3, "matched": 3}
        errors = lr.check_report(self.mutated(seed, name), "r", self.expect(name))
        self.assertTrue(any("body_inspection" in e for e in errors))

    def test_honest_stream_with_no_devices_rejected(self):
        def seed(r):
            r["counts"]["devices"] = {"layout": 0, "reference": 0, "matched": 0}
        errors = lr.check_report(self.mutated(seed), "r", self.expect())
        self.assertTrue(any("body_inspection" in e for e in errors))

    def test_tree_all_reports_pass(self):
        with tempfile.TemporaryDirectory() as t:
            self.populate(t)
            errors, n = lr.check_tree(t)
            self.assertEqual(errors, [])
            self.assertEqual(n, len(lr.EXPECTATIONS))

    def test_tree_absent_report_rejected(self):
        with tempfile.TemporaryDirectory() as t:
            self.populate(t, skip="sky130_ioring_vdd.json")
            errors, _ = lr.check_tree(t)
            self.assertTrue(any("report file absent" in e and "sky130_ioring_vdd.json" in e
                                for e in errors))

    def test_tree_unexpected_report_rejected(self):
        with tempfile.TemporaryDirectory() as t:
            self.populate(t, extra="sky130_ioring_extra.json")
            errors, n = lr.check_tree(t)
            self.assertEqual(n, len(lr.EXPECTATIONS) + 1)
            self.assertTrue(any("no pinned expectation" in e for e in errors))

    def test_tree_tampered_status_rejected(self):
        with tempfile.TemporaryDirectory() as t:
            d = self.populate(t)
            rep = json.loads((d / "ring.json").read_text())
            rep["status"] = "mismatch"
            (d / "ring.json").write_text(json.dumps(rep))
            errors, _ = lr.check_tree(t)
            self.assertTrue(any("ring.json" in e and "'mismatch'" in e for e in errors))

    def test_tree_invalid_json_rejected(self):
        with tempfile.TemporaryDirectory() as t:
            d = self.populate(t)
            (d / "sky130_ioring_gpio.json").write_text("{broken")
            errors, _ = lr.check_tree(t)
            self.assertTrue(any("not valid JSON" in e for e in errors))

    def test_tree_empty_directory_rejected(self):
        # nothing on disk must not read as ten passing streams
        with tempfile.TemporaryDirectory() as t:
            (Path(t) / "signoff" / "evidence" / "lvs").mkdir(parents=True)
            errors, n = lr.check_tree(t)
            self.assertEqual(n, 0)
            self.assertEqual(len(errors), len(lr.EXPECTATIONS))


if __name__ == "__main__":
    unittest.main()
