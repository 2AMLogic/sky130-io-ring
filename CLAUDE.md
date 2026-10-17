# sky130-io-ring — agent instructions

Open-source canary block: an I/O ring on SkyWater sky130 — GPIO, power and
ground pads with ESD, corner and filler cells — designed and verified by AI
agents.

- **PDK**: SkyWater sky130 (open PDK). Analog: xschem + ngspice. Layout, DRC,
  LVS and ERC through klayout-tools (`klt`).
- **The I/O rules are the point, and the risk.** Thick-oxide devices, guard
  rings, latch-up spacing, ESD path sizing and ring-rail continuity are the
  rule surface this block exists to stress. First establish which of those
  rules klt's sky130 deck actually checks; a rule it does not check is a
  friction item to file, not a rule to ignore. Expect the tools to be
  weakest at the pad boundary and the cell-to-cell ring seam.
- **ESD is not proven in simulation.** Simulated clamp turn-on and current
  sharing, plus rule-clean layout, is what pre-silicon evidence can show.
  Never describe a cell as ESD-rated or qualified; an HBM figure is a design
  target until measured.
- **Scope discipline.** No `consumes:` edge is declared. The foundry
  `sky130_fd_io` library is the reference and comparison: cite it, do not
  copy its geometry, and record honestly where it already solves a problem.
  The core and the package are out of scope.
- **This repo is master for a port.** `gf180-io-ring` is `ported_from` this
  repo and inherits its cell set, spec structure, harness and decision
  records. Keep the PDK-independent half (testbench logic, harness, ring
  assembly scripts) separable from the sky130 device-level half, so it can
  be stamped into the port rather than rewritten (`REUSE.md` in
  `2AMLogic/2am`).
- **Friction protocol (the canary's job)**: every time klayout-tools is
  awkward, missing a capability, or wrong for what you need, file an issue at
  `2AMLogic/klayout-tools` describing the tool gap generically — that tracker
  is scoped to the tool, so keep design-specific detail out of it and describe
  the gap, not the design.
- **Verification is the product**: no claim without a testbench. PVT corners
  on every recorded analog result; recorded results are append-only evidence.
- Spec changes go through `spec/` with a decision record; agents do not relax
  the ratified spec to make results pass.
- **One GPIO cell, one supply pair and a corner close first.** The full ring
  and the stretch features wait until those three are DRC/LVS-clean.
