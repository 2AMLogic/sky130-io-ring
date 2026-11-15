#!/usr/bin/env python3
"""LVS report-content check over signoff/evidence/lvs/*.json. Stdlib only.

`klt lvs --check` re-hashes the inputs a report was made from; this checker
reads what the report *says*. Every committed LVS report must:

  1. compare `match` and carry `body_verification.status: "verified"`;
  2. carry exactly the per-stream `counts.devices` and
     `body_verification.device_count` pinned in EXPECTATIONS below — a
     silent change in what the compare covered fails here. To move one,
     regenerate the report and update EXPECTATIONS in the same PR;
  3. agree with its declared `body_inspection` kind (see EXPECTATIONS).

`body_verification.device_count` counts bodies that FAILED to resolve to a
named net, not bodies inspected (klt 0.9.1; 2AMLogic/klayout-tools#5749), so
0 is the healthy value and no coverage floor is asserted from it. Streams
whose body check inspects nothing are declared here rather than implied by
the `verified` string: `empty_inspection` (devices present, none eligible —
`vddio`, whose clamp is entirely thick-oxide and extracts into the flavoured
class the body check does not read) and `vacuous` (zero devices on both
sides). `honest` means eligible bodies were inspected and all resolved.

  check_lvs_reports.py [REPO_ROOT]
"""
import json
import sys
from pathlib import Path

LVS_REL = "signoff/evidence/lvs"

HONEST = "honest"
EMPTY_INSPECTION = "empty_inspection"
VACUOUS = "vacuous"

DEVICE_KEYS = ("layout", "reference", "matched")

# Per-stream expectations, from the committed reports at klt 0.9.1.
# `body_inspection` kinds:
#   honest           - eligible bodies were inspected and all resolved: the
#                      gpio receiver/logic devices, the vdd cells' thin-oxide
#                      clamp bodies (815 of them across the ring), which a
#                      dropped rail label flips to `unverified`
#   empty_inspection - devices present but none eligible: vddio's clamp is
#                      entirely thick-oxide (signoff/README.md, "Regenerate
#                      the LVS reports"; 2AMLogic/klayout-tools#5749)
#   vacuous          - zero devices on both sides; nothing to inspect
EXPECTATIONS = {
    "ring.json": {"devices": {"layout": 6040, "reference": 6040, "matched": 6040},
                  "body_device_count": 0, "body_inspection": HONEST},
    "sky130_ioring_gpio.json": {"devices": {"layout": 111, "reference": 111, "matched": 111},
                                "body_device_count": 0, "body_inspection": HONEST},
    "sky130_ioring_vdd.json": {"devices": {"layout": 844, "reference": 844, "matched": 844},
                               "body_device_count": 0, "body_inspection": HONEST},
    "sky130_ioring_vddio.json": {"devices": {"layout": 444, "reference": 444, "matched": 444},
                                 "body_device_count": 0, "body_inspection": EMPTY_INSPECTION},
    "sky130_ioring_vss.json": {"devices": {"layout": 0, "reference": 0, "matched": 0},
                               "body_device_count": 0, "body_inspection": VACUOUS},
    "sky130_ioring_corner.json": {"devices": {"layout": 0, "reference": 0, "matched": 0},
                                  "body_device_count": 0, "body_inspection": VACUOUS},
    "sky130_ioring_fill_1.json": {"devices": {"layout": 0, "reference": 0, "matched": 0},
                                  "body_device_count": 0, "body_inspection": VACUOUS},
    "sky130_ioring_fill_5.json": {"devices": {"layout": 0, "reference": 0, "matched": 0},
                                  "body_device_count": 0, "body_inspection": VACUOUS},
    "sky130_ioring_fill_10.json": {"devices": {"layout": 0, "reference": 0, "matched": 0},
                                   "body_device_count": 0, "body_inspection": VACUOUS},
    "sky130_ioring_fill_20.json": {"devices": {"layout": 0, "reference": 0, "matched": 0},
                                   "body_device_count": 0, "body_inspection": VACUOUS},
}


def check_report(text, where, expect=None):
    """Return a list of error strings for one LVS report's JSON text.

    `expect` is the stream's EXPECTATIONS entry; without one the report is
    unexpected and nothing else is judged.
    """
    if expect is None:
        return [f"{where}: no pinned expectation for this report (add it to EXPECTATIONS)"]
    try:
        rep = json.loads(text)
    except ValueError as exc:
        return [f"{where}: not valid JSON ({exc})"]
    if not isinstance(rep, dict):
        return [f"{where}: top level must be a JSON object"]
    errors = []
    status = rep.get("status")
    if status != "match":
        errors.append(f"{where}: status {status!r} != 'match'")
    devices = None
    counts = rep.get("counts")
    if isinstance(counts, dict) and isinstance(counts.get("devices"), dict):
        devices = counts["devices"]
        for key in DEVICE_KEYS:
            if key not in devices:
                errors.append(f"{where}: counts.devices lacks {key!r}")
            elif devices[key] != expect["devices"][key]:
                errors.append(f"{where}: counts.devices.{key} {devices[key]!r} != "
                              f"{expect['devices'][key]!r}")
    else:
        errors.append(f"{where}: missing counts.devices block")
    bv = rep.get("body_verification")
    if not isinstance(bv, dict):
        errors.append(f"{where}: missing body_verification block")
    else:
        bv_status = bv.get("status")
        if bv_status != "verified":
            errors.append(f"{where}: body_verification.status {bv_status!r} != 'verified'")
        if "device_count" not in bv:
            errors.append(f"{where}: body_verification lacks device_count")
        elif bv["device_count"] != expect["body_device_count"]:
            errors.append(f"{where}: body_verification.device_count {bv['device_count']!r} "
                          f"!= {expect['body_device_count']!r}")
    kind = expect["body_inspection"]
    if devices is not None:
        if kind == VACUOUS and devices.get("layout") not in (None, 0):
            errors.append(f"{where}: declared body_inspection {VACUOUS!r} but "
                          f"counts.devices.layout is {devices.get('layout')!r}")
        if kind in (HONEST, EMPTY_INSPECTION) and devices.get("matched") == 0:
            errors.append(f"{where}: declared body_inspection {kind!r} but "
                          f"counts.devices.matched is 0")
    return errors


def check_tree(root):
    root = Path(root)
    lvs = root / LVS_REL
    errors = []
    seen = set()
    n = 0
    for p in sorted(lvs.glob("*.json")) if lvs.is_dir() else []:
        rel = p.relative_to(root).as_posix()
        n += 1
        seen.add(p.name)
        errors += check_report(p.read_text(encoding="utf-8"), rel, EXPECTATIONS.get(p.name))
    for name in sorted(EXPECTATIONS):
        if name not in seen:
            errors.append(f"{LVS_REL}/{name}: report file absent "
                          f"(every pinned stream must be present)")
    return errors, n


def main(argv=None):
    root = (argv or sys.argv[1:] or ["."])[0]
    errors, n = check_tree(root)
    if errors:
        print("lvs-report check FAILED:", file=sys.stderr)
        for e in errors:
            print(f"  - {e}", file=sys.stderr)
        return 1
    print(f"lvs-report check passed: {n} report(s) against {len(EXPECTATIONS)} "
          f"pinned stream expectations.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
