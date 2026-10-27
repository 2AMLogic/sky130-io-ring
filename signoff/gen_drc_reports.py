#!/usr/bin/env python3
"""Run `klt drc` (curated sky130 deck) on every committed stream in layout/gds/.

PDK-independent half: takes a stream list and a deck name, runs
`klt drc --deck <deck> --top <cell> --format json <stream>` from the repo root
(so recorded paths are repo-relative) and writes one envelope per stream under
the output directory. The ring report is written as ring.json (the one the
manifest cites for T1 item 3); the others as <cell>.json.

    python3 signoff/gen_drc_reports.py --klt "uvx --from klayout-tools==0.8.0 klt"

Exit 0 only if every report was written; a non-clean report is still written
(it is the evidence) but makes the script exit 4. Nothing is waived.
"""
import argparse
import os
import shlex
import subprocess
import sys

STREAMS = ["ring", "gpio", "vddio", "vdd", "vss", "corner",
           "fill_1", "fill_5", "fill_10", "fill_20"]


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--klt", default="klt", help="klt command (may be a quoted uvx line)")
    ap.add_argument("--deck", default="sky130")
    ap.add_argument("--gds-dir", default="layout/gds")
    ap.add_argument("--out-dir", default="signoff/evidence/drc")
    ap.add_argument("--prefix", default="sky130_ioring_", help="cell/stream name prefix")
    ap.add_argument("--streams", nargs="*", default=STREAMS)
    a = ap.parse_args()
    os.makedirs(a.out_dir, exist_ok=True)
    bad = 0
    for s in a.streams:
        cell = a.prefix + s
        gds = f"{a.gds_dir}/{cell}.gds"
        out = f"{a.out_dir}/{'ring' if s == 'ring' else cell}.json"
        p = subprocess.run(shlex.split(a.klt) + ["drc", "--deck", a.deck, "--top", cell,
                                                 "--format", "json", gds],
                           capture_output=True, text=True)
        if p.returncode not in (0, 2) and not p.stdout.strip():
            sys.exit(f"klt drc failed on {gds} (rc={p.returncode}): {p.stderr.strip()}")
        with open(out, "w") as f:
            f.write(p.stdout)
        print(f"{out}: rc={p.returncode}")
        if p.returncode != 0:
            bad += 1
    sys.exit(4 if bad else 0)


if __name__ == "__main__":
    main()
