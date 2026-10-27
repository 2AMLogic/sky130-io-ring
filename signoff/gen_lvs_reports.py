#!/usr/bin/env python3
"""Run `klt lvs` on every committed stream in layout/gds/ against its schematic netlist.

PDK-independent half: takes a stream list, a deck name and a reference-netlist
directory, runs `klt lvs --format json` with an inline request from the repo
root (so recorded paths are repo-relative) and writes one report per stream
under the output directory. The ring report is written as ring.json; the others
as <cell>.json.

    python3 signoff/gen_lvs_reports.py --klt "uvx --from klayout-tools==0.8.0 klt"

Exit 0 only if every report was written and every status is `match`; a
`mismatch` report is still written (it is the evidence) but makes the script
exit 4. When `klt lvs` refuses a request (no report exists) the refusal is
printed, no file is written, the remaining streams still run and the script
exits 5. No hints, tolerances or ignored devices are passed: nothing is forced.

`klt lvs` extracts the layout flat, so a reference that defines sub-circuits is
compared flattened (`options.flatten_reference`, `--flatten-reference auto`);
with the reference one circuit, only the top-level devices, nets and pins are
compared, which is what the flat layout offers. A reference with no
sub-circuit is sent without that option.

`options.compare_mos_flavour` is always on: by default `klt lvs` treats a
thick-oxide and a thin-oxide MOS of the same polarity as the same device, which
would hide the one error an I/O cell is built around.
"""
import argparse
import json
import os
import shlex
import subprocess
import sys

STREAMS = ["ring", "gpio", "vddio", "vdd", "vss", "corner",
           "fill_1", "fill_5", "fill_10", "fill_20"]


def _subckts(path):
    with open(path) as f:
        return sum(1 for line in f if line.lstrip().lower().startswith(".subckt"))


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--klt", default="klt", help="klt command (may be a quoted uvx line)")
    ap.add_argument("--deck", default="sky130")
    ap.add_argument("--gds-dir", default="layout/gds")
    ap.add_argument("--netlist-dir", default="design/netlists")
    ap.add_argument("--out-dir", default="signoff/evidence/lvs")
    ap.add_argument("--prefix", default="sky130_ioring_", help="cell/stream name prefix")
    ap.add_argument("--streams", nargs="*", default=STREAMS)
    ap.add_argument("--flatten-reference", choices=["auto", "always", "never"], default="auto",
                    help="flatten a hierarchical reference before comparing (auto: when it "
                         "defines more than one .subckt)")
    a = ap.parse_args()
    os.makedirs(a.out_dir, exist_ok=True)
    bad = refused = 0
    for s in a.streams:
        cell = a.prefix + s
        req = {"layout": {"file": f"{a.gds_dir}/{cell}.gds", "deck": a.deck, "top": cell},
               "reference": {"netlist": f"{a.netlist_dir}/{cell}.spice", "top": cell,
                         "form": "subckt-call", "deck": a.deck}}
        out = f"{a.out_dir}/{'ring' if s == 'ring' else cell}.json"
        req["options"] = {"compare_mos_flavour": True}
        hierarchical = _subckts(req["reference"]["netlist"]) > 1
        if a.flatten_reference == "always" or (a.flatten_reference == "auto" and hierarchical):
            req["options"]["flatten_reference"] = True
        p = subprocess.run(shlex.split(a.klt) + ["lvs", "--format", "json", json.dumps(req)],
                           capture_output=True, text=True)
        if not p.stdout.strip() or '"error"' in p.stdout.split("\n", 3)[2]:
            msg = (json.loads(p.stdout)["error"]["message"] if p.stdout.strip() else p.stderr.strip())
            print(f"{cell}: NO REPORT (rc={p.returncode}): {msg}")
            refused += 1
            continue
        with open(out, "w") as f:
            f.write(p.stdout)
        status = json.loads(p.stdout)["status"]
        print(f"{out}: rc={p.returncode} status={status}")
        if status != "match":
            bad += 1
    sys.exit(5 if refused else 4 if bad else 0)


if __name__ == "__main__":
    main()
