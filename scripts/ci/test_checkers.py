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
        # PATH_KEY_RE matches `dir`/`dirs` too; a directory is a valid target.
        with tempfile.TemporaryDirectory() as t:
            rec = Path(t) / "record"
            (rec / "logs").mkdir(parents=True)
            (rec / "logs" / "smoke.log").write_text("x\n")
            rec2 = dict(GOOD, runs={"smoke": {"log": "logs/smoke.log", "dir": "logs"}})
            self.assertEqual(ef.check_record(json.dumps(rec2), "r", base=rec), [])

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


if __name__ == "__main__":
    unittest.main()
