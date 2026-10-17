# 0003 — PVT corner set

- **Status**: proposed; ratification pending (human). Ratified by: _unrecorded_.
- **Date**: 2026-10-17
- **Rows**: PVT.1 to PVT.5.

## Confirmation against the model library

`sky130.lib.spice` in the inspected PDK (open_pdks `f6eeac7d`) defines
sections `tt sf ff ss fs` (MOS skew, typical R and C), `ll hh hl lh` (R and C
skew only), the combined `<mos>_<rc>` forms such as `ss_ll`, and `_mm` mismatch
forms for Monte Carlo. `klt pdk corners --pdk sky130A` lists the same names and
marks `ff ss sf fs` as "complete: no" because they skew MOS only. The issue's
five process names exist unchanged. The 5 V NMOS appears in each corner file; this record
does not claim how it is skewed (not inspected).

## Decision

Process `tt ff ss sf fs`, temperature -40 / 25 / 125 °C, supply codes
`nn hh ll hl lh` (the last two cross the supplies to stress the level shifter),
giving 75 named corners `<process>_<temp>_<supply>`, listed in
`io-ring.json`. Process skew is MOS-only; RC skew sections and Monte Carlo
sections are stretch (PVT.1).

## Consequences

Recorded analog results name a corner from this set. Multi-corner runs go
through `klt sim` and the batch fleet, never hand-run grids.

## PDK-independent part

Naming scheme and the supply-code convention; the 5 x 3 x 5 structure.

## PDK-specific part

Section names, voltages, and the choice to hold RC at typical.
