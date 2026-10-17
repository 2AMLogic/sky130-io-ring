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


class AppendOnly(unittest.TestCase):
    def test_add_passes(self):
        self.assertEqual(ao.violations("A\tsim/exp/record/new.json\nM\tREADME.md\n"), [])

    def test_modify_rejected(self):
        self.assertTrue(ao.violations("M\tsim/pdk-smoke/record/record.json\n"))

    def test_delete_rejected(self):
        self.assertTrue(ao.violations("D\tsim/pdk-smoke/record/record.json\n"))

    def test_outside_sim_ignored(self):
        self.assertEqual(ao.violations("D\tdesign/README.md\nM\tspec/io-ring.md\n"), [])


if __name__ == "__main__":
    unittest.main()
