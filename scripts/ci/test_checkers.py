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
import check_prose_citations as pc

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

    def test_bare_suffix_key_skipped_by_convention(self):
        # A bare-suffix key (`logdir`, `logfile`, `basedir`) is NOT path-shaped:
        # PATH_KEY_RE requires the path word to be the whole key or follow an
        # underscore, and that separator anchor is a documented convention
        # (2AMLogic/sky130-io-ring#134), not an oversight. A record carrying a dangling
        # bare-suffix value is therefore accepted — this asserts the skip as
        # a decision, so a future pass that widens the regex has to confront
        # it deliberately. Widening was measured and rejected: a bare-suffix
        # pattern would newly match ordinary words like `profile`, `analog`
        # and `catalog`. The contrast below asserts the separator-form
        # spelling of the same key is still checked, so the skip is by the
        # convention, not by accident.
        with tempfile.TemporaryDirectory() as t:
            rec = Path(t) / "record"
            rec.mkdir()
            bare = dict(GOOD, runs={"smoke": {"logdir": "nope/"}})
            self.assertEqual(ef.check_record(json.dumps(bare), "r", base=rec), [])
            anchored = dict(GOOD, runs={"smoke": {"log_dir": "nope/"}})
            errors = ef.check_record(json.dumps(anchored), "r", base=rec)
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

    # --- R1 field-naming rule (issue #120) ---

    def sibling_record(self, **cards):
        rec = copy.deepcopy(GOOD)
        rec["runs"]["m"] = {"results": {"cards_m": cards}}
        return json.dumps(rec)

    def test_equal_sibling_with_unit_suffix_rejected(self):
        # The exact diode-unit-probe shape: two field names asserting
        # different unit domains for one and the same figure.
        errors = ef.check_record(
            self.sibling_record(cj_card_F_per_m2=7.4079e-16, cj_prescaled=7.4079e-16), "r")
        self.assertTrue(any("cj_card_F_per_m2" in e and "cj_prescaled" in e
                            and "unit-domain suffix" in e for e in errors))

    def test_error_names_object_and_both_keys(self):
        # The failure must name the offending object and every key in it.
        errors = ef.check_record(
            self.sibling_record(cjsw_card_F_per_m=9.88e-17, cjsw_prescaled=9.88e-17), "r")
        hit = [e for e in errors if "cjsw_prescaled" in e]
        self.assertEqual(len(hit), 1)
        self.assertIn("runs.m.results.cards_m", hit[0])
        self.assertIn("'cjsw_card_F_per_m'", hit[0])

    def test_leading_token_grouping_not_stem(self):
        # `cj_card_F_per_m2` and `cj_prescaled` share only a leading token, not
        # a suffix-stripped stem (cj_card vs cj) — a stem-based rule would let
        # this exact defect pass, so the test pins the grouping key itself.
        errors = ef.check_record(
            self.sibling_record(cj_card_F_per_m2=7.4079e-16, cj_prescaled=7.4079e-16), "r")
        self.assertTrue(any("leading token 'cj'" in e for e in errors))

    def test_distinct_sibling_values_pass(self):
        # Same key pair, genuinely different domains' numbers: the source
        # figure 7.4079e-4 F/m^2 next to the pre-scaled 7.4079e-16 F/um^2.
        rec = self.sibling_record(cj_card_source_F_per_m2=7.4079e-4,
                                  cj_prescaled_F_per_um2=7.4079e-16)
        self.assertEqual(ef.check_record(rec, "r"), [])

    def test_grandfathered_path_accepted(self):
        defect = self.sibling_record(cj_card_F_per_m2=7.4079e-16, cj_prescaled=7.4079e-16)
        self.assertEqual(
            ef.check_record(defect, "sim/diode-unit-probe/record/record.json"), [])
        # the grandfather is path-scoped, not a global amnesty
        self.assertTrue(ef.check_record(defect, "sim/other/record/record.json"))

    def test_equal_siblings_without_unit_suffix_pass(self):
        # Legitimately equal values under one leading token, no unit-domain
        # suffix anywhere: not the defect shape.
        rec = self.sibling_record(js_a=1.5, js_b=1.5, temp_set=27, temp_measured=27.0)
        self.assertEqual(ef.check_record(rec, "r"), [])

    def test_int_and_float_equal_values_rejected(self):
        # JSON 1 and 1.0 compare equal; the rule fires on numeric equality.
        errors = ef.check_record(
            self.sibling_record(cj_a_per_um2=1, cj_b_per_um2=1.0), "r")
        self.assertTrue(any("unit-domain suffix" in e for e in errors))

    def test_boolean_siblings_not_treated_as_numeric(self):
        rec = self.sibling_record(cj_flag_per_m2=True, cj_flag=True)
        self.assertEqual(ef.check_record(rec, "r"), [])

    def test_unit_suffix_variants_rejected(self):
        for pair in (("cj_x_per_m", "cj_y"), ("cj_x_per_um", "cj_y"),
                     ("cj_x_per_um2", "cj_y")):
            errors = ef.check_record(
                self.sibling_record(**{pair[0]: 2.0, pair[1]: 2.0}), "r")
            self.assertTrue(any("unit-domain suffix" in e for e in errors), pair)


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


class ProseCitations(unittest.TestCase):
    # The two marked regions and the evidence they cite, copied from the real
    # tree into a temp root so each defect is seeded, never hand-committed.
    REPO = Path(__file__).resolve().parents[2]
    FILES = (
        "signoff/README.md",
        "spec/klt-rule-coverage.md",
        "signoff/evidence/drc/ring.json",
    )
    BEGIN = ("<!-- cite:begin source=signoff/evidence/drc/ring.json "
             "requires=rules_skipped,deck_scope -->")
    SPEC_BEGIN = ("<!-- cite:begin source=signoff/evidence/drc/ring.json "
                  "requires=rules_checked,rules_skipped,"
                  "layers_in_stream_without_rules,deck_scope,"
                  "unmodeled_rules,voltage_domain_warnings -->")
    END = "<!-- cite:end -->"
    ESCAPE = " <!-- cite:historical -->"

    # One seeded off-by-one per count citation in each marked region.
    OFF_BY_ONE = (
        ("signoff/README.md",
         "`coverage.rules_skipped` is 36", "`coverage.rules_skipped` is 35"),
        ("signoff/README.md",
         "`deck_scope` is 23", "`deck_scope` is 22"),
        ("spec/klt-rule-coverage.md",
         "`rules_checked` (117)", "`rules_checked` (116)"),
        ("spec/klt-rule-coverage.md",
         "`rules_skipped` (36,", "`rules_skipped` (35,"),
        ("spec/klt-rule-coverage.md",
         "`layers_in_stream_without_rules` (6)",
         "`layers_in_stream_without_rules` (5)"),
        ("spec/klt-rule-coverage.md",
         "`deck_scope` (23)", "`deck_scope` (22)"),
        ("spec/klt-rule-coverage.md",
         "`unmodeled_rules` (54)", "`unmodeled_rules` (53)"),
        ("spec/klt-rule-coverage.md",
         "`voltage_domain_warnings` (1)", "`voltage_domain_warnings` (0)"),
    )

    def tree(self):
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        root = Path(tmp.name)
        for rel in self.FILES:
            dst = root / rel
            dst.parent.mkdir(parents=True, exist_ok=True)
            dst.write_text((self.REPO / rel).read_text())
        return root

    def seed(self, root, rel, old, new):
        path = root / rel
        text = path.read_text()
        self.assertIn(old, text, f"seed defect does not hit {rel}")
        path.write_text(text.replace(old, new, 1))

    def test_unmodified_tree_passes(self):
        self.assertEqual(pc.check_root(self.tree()), [])

    def test_real_tree_passes_with_historical_pins_untouched(self):
        # AC4: the four historical pins (spec/klt-rule-coverage.md, the
        # io-ring survey) sit outside every marked region and must never be
        # scanned; the only excused hash is the one real back-reference.
        self.assertEqual(pc.check_root(self.REPO), [])

    def test_stale_ascii_hash_rejected_and_file_named(self):
        # AC3: the #130/#136 defect — the README deck hash reverted to the
        # 2026-10-22 deck — must fail and name signoff/README.md.
        root = self.tree()
        self.seed(root, "signoff/README.md",
                  "sha256:029ef177...0bf7c", "sha256:ba0f9788...942e6")
        errors = pc.check_root(root)
        self.assertTrue(any("signoff/README.md" in e and "ba0f9788" in e
                            for e in errors), errors)

    def test_unknown_ascii_abbreviation_rejected(self):
        root = self.tree()
        self.seed(root, "signoff/README.md",
                  "sha256:029ef177...0bf7c", "sha256:deadbeef...12345")
        errors = pc.check_root(root)
        self.assertTrue(any("deadbeef...12345" in e for e in errors), errors)

    def test_stale_unicode_hash_rejected_without_escape(self):
        # AC6 (head-only, U+2026): with the escape stripped, the deliberate
        # back-reference becomes an unexcused stale hash.
        root = self.tree()
        self.seed(root, "spec/klt-rule-coverage.md", self.ESCAPE, "")
        errors = pc.check_root(root)
        self.assertTrue(any("ba0f9788…" in e and "does not match any hash" in e
                            for e in errors), errors)

    def test_stale_full_hash_rejected(self):
        # A full 64-hex token matching nothing in the source fails, prefix
        # form or not — the input-stream hash site is a real assertion.
        root = self.tree()
        bogus = "sha256:" + "f" * 64
        self.seed(root, "spec/klt-rule-coverage.md",
                  "sha256:8c026a33c7dc51842a84e91aa7f65a137bb5bae7ca792a877b919475806d74cc",
                  bogus)
        errors = pc.check_root(root)
        self.assertTrue(any("does not match any hash" in e for e in errors),
                        errors)

    def test_escape_on_current_hash_rejected(self):
        # AC5: a blanket suppression is itself a CI error — escaping a line
        # whose hash the source contains must fail, so cite:historical cannot
        # silently grow to cover current citations.
        root = self.tree()
        self.seed(root, "spec/klt-rule-coverage.md",
                  "0bf7c`,", "0bf7c`," + self.ESCAPE)
        errors = pc.check_root(root)
        self.assertTrue(any("matches the source" in e for e in errors), errors)

    def test_escape_hash_forms(self):
        # The real tree's single escape covers the U+2026 abbreviation; the
        # ASCII head...tail spelling of the same stale deck hash is excused
        # the same way when written deliberately.
        root = self.tree()
        self.seed(root, "spec/klt-rule-coverage.md",
                  "`ba0f9788…` pinned above, which the" + self.ESCAPE,
                  "`ba0f9788...942e6` pinned above, which the" + self.ESCAPE)
        self.assertEqual(pc.check_root(root), [])

    def test_count_off_by_one_rejected(self):
        for rel, old, new in self.OFF_BY_ONE:
            with self.subTest(citation=old):
                root = self.tree()
                self.seed(root, rel, old, new)
                errors = pc.check_root(root)
                field = old.split("`")[1].split("coverage.", 1)[-1]
                self.assertTrue(any(field in e and "is cited as" in e
                                    for e in errors), errors)

    def test_unknown_count_field_rejected(self):
        root = self.tree()
        self.seed(root, "spec/klt-rule-coverage.md",
                  "`deck_scope` (23)", "`deck_scope_typo` (23)")
        errors = pc.check_root(root)
        self.assertTrue(any("absent from" in e for e in errors), errors)

    def test_contents_list_is_not_a_count_citation(self):
        # `field` is `66/13`, ... cites contents, not this source's count —
        # documented out of the asserted grammar, so it must not fire.
        root = self.tree()
        self.seed(root, "signoff/README.md", "`66/13`, `69/5`",
                  "`99/13`, `69/5`")
        self.assertEqual(pc.check_root(root), [])

    def test_marker_mention_inside_inline_code_is_not_a_region(self):
        # Prose that documents the marker syntax inside backticks does not
        # itself open or close a region — the real "What CI checks" bullet
        # tripped the attestation before this rule existed.
        root = self.tree()
        self.seed(root, "signoff/README.md",
                  "Unmarked prose is never scanned",
                  "Wrapped prose uses `<!-- cite:begin source=x.json -->` / "
                  "`<!-- cite:end -->`. Unmarked prose is never scanned")
        self.assertEqual(pc.check_root(root), [])

    def test_missing_source_file_hard_error(self):
        # AC8: a check that cannot run must not look like one that passed.
        root = self.tree()
        self.seed(root, "signoff/README.md", self.BEGIN,
                  "<!-- cite:begin source=signoff/evidence/missing.json -->")
        errors = pc.check_root(root)
        self.assertTrue(any("missing.json" in e and "no such file" in e
                            for e in errors), errors)

    def test_unreadable_source_hard_error(self):
        root = self.tree()
        (root / "signoff/evidence/drc/ring.json").write_text("{not json")
        errors = pc.check_root(root)
        self.assertTrue(any("unreadable evidence JSON" in e for e in errors))

    def test_source_without_coverage_hard_error(self):
        root = self.tree()
        (root / "signoff/evidence/drc/ring.json").write_text('{"kind": "x"}')
        errors = pc.check_root(root)
        self.assertTrue(any("no coverage object" in e for e in errors), errors)

    def test_unterminated_region_hard_error(self):
        root = self.tree()
        self.seed(root, "signoff/README.md", self.END, "")
        errors = pc.check_root(root)
        self.assertTrue(any("unterminated cite region" in e
                            and "signoff/README.md" in e for e in errors))

    def test_end_without_begin_hard_error(self):
        root = self.tree()
        self.seed(root, "signoff/README.md", self.BEGIN + "\n", "")
        errors = pc.check_root(root)
        self.assertTrue(any("cite:end without cite:begin" in e
                            for e in errors), errors)

    def test_nested_begin_hard_error(self):
        root = self.tree()
        self.seed(root, "spec/klt-rule-coverage.md",
                  "`status: clean`, `violation_count: 0`.",
                  self.BEGIN + " `status: clean`, `violation_count: 0`.")
        errors = pc.check_root(root)
        self.assertTrue(any("nested cite:begin" in e for e in errors), errors)

    def test_omitted_required_count_citation_rejected(self):
        # The omitted-citation half of #130 (issue #144 gap 1): deleting a
        # whole count citation from a region that declares requires= must
        # fail — set-membership asserts what is present, never what is not.
        root = self.tree()
        path = root / "spec/klt-rule-coverage.md"
        text = path.read_text()
        old = ("- `voltage_domain_warnings` (1): the deck reads the `hvi` "
               "marker only for MOS")
        self.assertIn(old, text)
        i, j = text.index(old), text.index(self.END)
        path.write_text(text[:i] + text[j:])
        errors = pc.check_root(root)
        self.assertTrue(any("voltage_domain_warnings" in e
                            and "asserts none" in e for e in errors), errors)

    def test_omitted_citation_without_requires_still_passes(self):
        # requires= is opt-in per region: strip the declaration and the
        # omission is invisible again — a region without the declaration
        # behaves exactly as before.
        root = self.tree()
        path = root / "spec/klt-rule-coverage.md"
        text = path.read_text()
        self.assertIn(self.SPEC_BEGIN, text)
        text = text.replace(
            self.SPEC_BEGIN,
            "<!-- cite:begin source=signoff/evidence/drc/ring.json -->", 1)
        old = ("- `voltage_domain_warnings` (1): the deck reads the `hvi` "
               "marker only for MOS")
        i, j = text.index(old), text.index(self.END)
        path.write_text(text[:i] + text[j:])
        self.assertEqual(pc.check_root(root), [])

    def test_requires_absent_field_rejected(self):
        # A requires= naming a field the source's coverage does not have is
        # a hard error, so the declaration cannot rot into a no-op.
        root = self.tree()
        self.seed(root, "spec/klt-rule-coverage.md",
                  "requires=rules_checked,", "requires=nonexistent_field,")
        errors = pc.check_root(root)
        self.assertTrue(any("nonexistent_field" in e and "absent from" in e
                            for e in errors), errors)

    def test_role_pinned_hash_swap_rejected(self):
        # Issue #144 gap 2: the input-stream hash cited where the deck hash
        # is pinned. Both live in the same source, so set-membership alone
        # passes; the path pin must fail the mis-attribution.
        root = self.tree()
        self.seed(root, "spec/klt-rule-coverage.md",
                  "`provenance.deck.content_hash` is "
                  "`sha256:029ef177c1f4e872c13cc81093f94a02a9bbfe1f51939a"
                  "88194a83532d60bf7c`",
                  "`provenance.deck.content_hash` is "
                  "`sha256:8c026a33c7dc51842a84e91aa7f65a137bb5bae7ca792a"
                  "877b919475806d74cc`")
        errors = pc.check_root(root)
        self.assertTrue(any("provenance.deck.content_hash" in e
                            and "is cited as" in e for e in errors), errors)

    def test_role_pin_absent_path_rejected(self):
        # A pin naming a path the source does not have fails loudly, so the
        # pin cannot silently rot when the report schema moves.
        root = self.tree()
        self.seed(root, "spec/klt-rule-coverage.md",
                  "`provenance.deck.content_hash` is",
                  "`provenance.no.such.path` is")
        errors = pc.check_root(root)
        self.assertTrue(any("names a path absent from" in e for e in errors),
                        errors)

    def test_fenced_marker_example_is_inert(self):
        # Issue #144 gap 3: a fenced example of the convention opens no
        # region and asserts nothing. It used to fail closed with a loud
        # "no such file" / "unterminated region" from the example markers.
        root = self.tree()
        (root / "doc.md").write_text(
            "# documenting the convention\n\n"
            "```markdown\n"
            "<!-- cite:begin source=signoff/evidence/drc/ring.json -->\n"
            "prose with a `deck_scope` (99) count and a bogus hash\n"
            "<!-- cite:end -->\n"
            "```\n")
        self.assertEqual(pc.check_root(root), [])

    def test_fenced_block_inside_region_is_not_asserted(self):
        # Inside a real region a fence is inert too: illustrative hashes in
        # it are example syntax, not citations of this source. (A stale hash
        # hidden in a fence is a deliberate dodge, visible to review — the
        # same act as deleting the citation, which requires= guards.)
        root = self.tree()
        self.seed(root, "spec/klt-rule-coverage.md",
                  "Quoted from the report's `coverage` block:",
                  "Quoted from the report's `coverage` block:\n\n"
                  "```\nsha256:" + "f" * 64 + "\n```\n")
        self.assertEqual(pc.check_root(root), [])


if __name__ == "__main__":
    unittest.main()
