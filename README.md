# sky130-io-ring

An I/O ring on [SkyWater sky130](https://github.com/google/skywater-pdk),
the 130 nm open PDK — general-purpose I/O, power and ground pads with their
ESD protection, corner cells and fillers, assembled into a closed ring —
designed by AI agents driving
[klayout-tools](https://github.com/2AMLogic/klayout-tools) and the
open-source xschem + ngspice flow.

**Status: spec proposed, cells drawn and rule-checked.** The spec is proposed
and awaiting review and ratification, so every figure in it is a target. The
cells and the closed ring are drawn and streamed, and the signoff verdict of
record ([`signoff/signoff-record.json`](signoff/signoff-record.json)) grades
**7 of 11** T1 items met — design sources, layout, DRC, LVS, testbenches, repo
hygiene and structural power delivery. The four unmet items all grade against a
ratified spec. There is no PVT simulation and no ESD result.

**Built agent-native.** Every specification, decision record, testbench, and
line of documentation here is produced by AI agents working from a written
spec and an append-only evidence trail — not human-authored work that agents
merely assisted with. Verification is the product: every claim traces to a
recorded result under PVT corners. Where the agents hit friction with the
open-source tooling — most often
[klayout-tools](https://github.com/2AMLogic/klayout-tools) — that friction is
filed as a public issue against the tool itself, so the fix benefits everyone
using sky130, not just this repo.

## Why this block, on this node

Most canaries are core blocks. The I/O ring is the part of a chip where the
rules are least like core rules: thick-oxide devices for the I/O supply,
guard rings around every driver, latch-up spacing between the I/O and core
wells, ESD paths sized for currents a core cell never sees, and a ring whose
supply rails must stay continuous through every cell that abuts. That is the
rule surface this block exists to stress, and most of it is untested ground
for the tools.

sky130 ships its own I/O library (`sky130_fd_io`). This repo does not wrap
or re-tile it; it draws its own cells so that every I/O-specific rule gets
exercised by new geometry, and it uses the foundry library as the reference
and comparison. Whether to draw every cell or adopt some foundry cells is
the first question for the spec (see [decision 0001](spec/decisions/0001-draw-vs-adopt.md)). Where the honest answer is
"the foundry cell already does this correctly," record that — it is a real
result.

The ring is also the master for its port: `gf180-io-ring` inherits this
repo's cell set, spec structure and verification harness. Decisions made
here should be written so a second PDK can follow them.

## Scope

- **In scope**: a bidirectional GPIO pad cell (driver, receiver, core-side
  level shifting, primary and secondary ESD), I/O-supply and core-supply
  pad cells with their clamps, a corner cell, filler cells, and a small
  demonstration ring that closes around an empty core.
- **Not in scope**: the core, the package, bond-wire modelling, and any ESD
  rating claim before measured silicon.

## Specification

The specification is proposed and awaiting EE-key and market-key review, then operator
ratification (2026-10-22 ruling, 2am#5864):
[`spec/io-ring.md`](spec/io-ring.md), with its rows as data in
[`spec/io-ring.json`](spec/io-ring.json) and the decision records in
[`spec/decisions/`](spec/decisions/). All figures are targets.

ESD robustness is a silicon property. Pre-silicon, this repo can show that
the clamp network turns on and carries the intended current in simulation
and that the layout satisfies the ESD and latch-up rules. It does not call
any cell ESD-rated until silicon says so.

Maturity ladder: spec ratified → GPIO cell simulated across PVT → cells
DRC/LVS-clean → ring assembled, DRC/LVS/ERC-clean → shuttle seat → measured
silicon. **Current position: spec proposed, awaiting EE-key and market-key review, then operator ratification.**

## Reproduce every result

Every result in this repo is a command. From the repo root:

```sh
# The four CI checkers, the PDK resolver self-test (no PDK needed)
python3 scripts/ci/test_checkers.py
python3 -I scripts/ci/check_evidence_format.py .
python3 -I spec/check_spec.py
bash sim/lib/test_pdk_env.sh

# Layout generator and stream reproducibility (needs: pip install "klayout==0.30.10")
python3 layout/tests/test_ring.py
python3 scripts/ci/check_layout_reproducible.py .

# PDK smoke: models load and converge. Needs the pinned PDK (sim/pdk.json) and ngspice.
bash sim/pdk-smoke/run.sh /tmp/pdk-smoke-out

# Ring DRC report against the curated sky130 deck: stream and deck hashes still match (DRC is not re-run)
uvx --from "klayout-tools==0.9.1" klt drc --check signoff/evidence/drc/ring.json

# Signoff verdict of record and the item-10 hygiene attestation, with the pinned grader
uvx --from "klayout-tools==0.9.1" klt signoff --manifest signoff/block-manifest.json --check signoff/signoff-record.json
uvx --from "klayout-tools==0.9.1" klt signoff --attest 10 --inventory signoff/attest/item10.json --check signoff/evidence/item10.json
```

How to regenerate the record and the attestation is in
[`signoff/README.md`](signoff/README.md). CI (`.github/workflows/ci.yml`) runs
the same commands.

**What exists, and what does not:** DRC of the ring against the curated
`sky130` deck reports clean on drawing that includes every device of the GPIO
netlists (but no supply clamp); the deck does not cover every I/O rule
(thick-oxide, latch-up and guard-ring rules among them); deck coverage is in
[`signoff/README.md`](signoff/README.md). LVS has run per cell and on the ring: with klt 0.9.1 the GPIO, the two supply clamps, the ring,
the corner, fillers and `vss` are `match` against their reference netlists (flat comparison; the
resistor geometry is not compared). Ring ERC reproduces clean against the
ring's supply spec ([`signoff/evidence/erc/ring.json`](signoff/evidence/erc/ring.json)):
`VDDIO`, `VDD` and `VSS` are each one island through every abutment seam and
every declared well-tap tie holds, and a negative control confirms that a ring
cut at two opposite edges still splits all three. That is supply continuity and
well ties — not antenna, latch-up or IR drop. There is no ESD result and no PVT
simulation of any cell. Nothing above claims one.

## Repo layout

```
spec/          proposed spec + decision records
design/        pad cell schematics (xschem) + netlists: driver, receiver, level shifter, ESD
sim/           testbenches, the PDK pin and a single-corner clamp probe (ngspice)
layout/        cell and ring GDS + the generator and its tests
signoff/       DRC/LVS/ERC evidence, the attestations and the signoff record
ratification/  EE-key and market-key reviewer rubrics
scripts/       the CI checkers
measurements/  silicon characterization (empty until tape-out)
```

## License

Apache License 2.0 — see [LICENSE](LICENSE).
