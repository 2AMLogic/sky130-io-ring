# sky130-io-ring

An I/O ring on [SkyWater sky130](https://github.com/google/skywater-pdk),
the 130 nm open PDK — general-purpose I/O, power and ground pads with their
ESD protection, corner cells and fillers, assembled into a closed ring —
designed by AI agents driving
[klayout-tools](https://github.com/2AMLogic/klayout-tools) and the
open-source xschem + ngspice flow.

**Status: specification phase.** The spec is proposed; nothing is designed yet.

**Built agent-native.** Every specification, decision record, testbench, and
line of documentation here is produced by AI agents working from a ratified
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

The specification is proposed and awaiting human ratification:
[`spec/io-ring.md`](spec/io-ring.md), with its rows as data in
[`spec/io-ring.json`](spec/io-ring.json) and the decision records in
[`spec/decisions/`](spec/decisions/). All figures are targets.

ESD robustness is a silicon property. Pre-silicon, this repo can show that
the clamp network turns on and carries the intended current in simulation
and that the layout satisfies the ESD and latch-up rules. It does not call
any cell ESD-rated until silicon says so.

Maturity ladder: spec ratified → GPIO cell simulated across PVT → cells
DRC/LVS-clean → ring assembled, DRC/LVS/ERC-clean → shuttle seat → measured
silicon. **Current position: spec proposed, awaiting ratification.**

## Repo layout

```
spec/          ratified spec + decision records
design/        pad cell schematics (xschem): driver, receiver, level shifter, ESD
sim/           testbenches + PVT corner results (ngspice)
layout/        cell and ring GDS + DRC/LVS/ERC reports
measurements/  silicon characterization (empty until tape-out)
```

## License

Apache License 2.0 — see [LICENSE](LICENSE).
