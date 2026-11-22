#!/usr/bin/env python3
"""Regenerate the layout streams and require them to match what is committed.

  1. Re-runs layout/gen_ring.py into a scratch directory (the generator's own
     spec/seam self-checks run as part of that) and compares every stream byte
     for byte with layout/gds/.
  2. Requires signoff/evidence/layout-attestation.json to bind the committed ring
     stream by hash and to claim the hash of the fresh regeneration.

Needs `pip install klayout` but no PDK. Judges only that the committed streams
are what the generator produces; DRC/LVS of them are separate checks.

  check_layout_reproducible.py [REPO_ROOT]
"""
import hashlib
import json
import subprocess
import sys
import tempfile
from pathlib import Path

RING = "sky130_ioring_ring.gds"

root = Path(sys.argv[1] if len(sys.argv) > 1 else ".").resolve()
gds = root / "layout" / "gds"
att = json.loads((root / "signoff/evidence/layout-attestation.json").read_text())
bad = []

with tempfile.TemporaryDirectory() as scratch:
    subprocess.run([sys.executable, str(root / "layout/gen_ring.py"), "--out", scratch],
                   check=True, cwd=root)
    fresh = {p.name: p.read_bytes() for p in Path(scratch).glob("*.gds")}

committed = {p.name: p.read_bytes() for p in gds.glob("*.gds")}
for name in sorted(fresh.keys() | committed.keys()):
    if name not in committed:
        bad.append(f"{name}: generated but not committed")
    elif name not in fresh:
        bad.append(f"{name}: committed but no longer generated")
    elif fresh[name] != committed[name]:
        bad.append(f"{name}: committed stream differs from a fresh regeneration")

if RING in fresh:
    want = "sha256:" + hashlib.sha256(fresh[RING]).hexdigest()
    prov = att["provenance"]
    if prov["regeneration"]["regenerated_hash"] != want:
        bad.append("attestation regenerated_hash does not match a fresh regeneration")
    if prov["input"]["content_hash"] != want:
        bad.append("attestation input.content_hash does not match the ring stream")
else:
    bad.append(f"{RING} was not generated")

if bad:
    print("layout reproducibility check FAILED:\n  " + "\n  ".join(bad))
    print("Regenerate: python3 layout/gen_ring.py --attest signoff/evidence/layout-attestation.json")
    print("then update the content_hash in signoff/block-manifest.json and regenerate")
    print("signoff/signoff-record.json (signoff/README.md).")
    sys.exit(1)
print(f"{len(fresh)} streams reproduce byte for byte; attestation matches.")
