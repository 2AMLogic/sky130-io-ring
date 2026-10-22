# 0001 — Draw every cell, or adopt some `sky130_fd_io` cells

- **Status**: proposed; ratification pending (human). Ratified by: _unrecorded_.
- **Date**: 2026-10-17
- **Decided before**: every other row in `spec/io-ring.md` (the survey can overturn cell-set and geometry rows).

## Survey

Read from the installed PDK (open_pdks `c6d73a35`, `libs.ref/sky130_fd_io/`; the
klt-resolved install `f6eeac7d` carries the same library family). The upstream
source is the SkyWater `sky130_fd_io` library in
[google/skywater-pdk](https://github.com/google/skywater-pdk); the `sky130_ef_io`
wrappers are the open-source shuttle layer on top of it.

| Item | What the library ships |
|---|---|
| GPIO | `sky130_ef_io__gpiov2_pad` (and `_wrapped`), 80.000 x 197.965 µm (LEF SIZE) |
| Core-side pins | `DM[2:0]` drive mode, `OE_N`, `INP_DIS`, `IB_MODE_SEL`, `VTRIP_SEL`, `SLOW`, `HLD_H_N`, `HLD_OVR`, `ENABLE_H`, `ENABLE_VDDA_H`, `ENABLE_VSWITCH_H`, `ANALOG_EN/SEL/POL`, `OUT`, `IN`, `IN_H`, `TIE_HI_ESD`, `TIE_LO_ESD` (Liberty pin list) |
| Supply pads | `vddio`, `vssio`, `vdda`, `vssa`, `vccd`, `vssd`, each in `_hvc` / `_lvc` forms and as `_clamped` variants; 75.000 x 197.965 µm |
| Corner | `sky130_ef_io__corner_pad`, 200.000 x 204.000 µm |
| Fillers | `com_bus_slice` 1, 5, 10, 20 µm wide, 197.965 µm deep; plus disconnect / connect slices |
| Other | `analog_pad`, `analog_esd_pad`, `analog_noesd_pad`, `bare_pad` (65.4 x 75.4 µm) |
| Characterisation | Liberty files per corner (about 600 files across the library); the GPIO cell is characterised at 1.8 V core and 3.3 V I/O among many others |
| ESD structure | Present in the cells (the supply-pad variants are named `_clamped`; the GPIO has `PAD_A_ESD` pins and `TIE_*_ESD`). The library does not document the clamp topology beyond layout and netlist; this record does not infer a topology from it |
| Supply range | The GPIO's Liberty files are named for VDDIO from 1.65 V to 5.5 V |

## Decision

1. **Draw every cell** (GPIO, VDDIO / VDD / VSS pads, corner, fillers). The
   block exists to exercise the I/O rules with new geometry (README, CLAUDE.md).
   Adopting a foundry cell would exercise none of them.
2. **Adopt nothing into the layout.** Foundry geometry is not copied (scope
   rule). Pitch and depth figures are cited for comparison only.
3. **Use the foundry cells as the comparison oracle**: for the GPIO, compare
   our simulated edge rates, delays and levels against the foundry Liberty at
   matching corners; compare our dimensions against the LEF sizes above.

## Where the foundry cell already does this correctly

Recorded as results, not as gaps to close:

- A fully programmable GPIO with hysteresis, slew and threshold selection, a
  1.71-5.5 V VDDIO operating range, and level shifting, in a single 80 µm-pitch
  cell. (Correction 2026-10-22: an earlier draft said "5 V tolerance" here. The
  foundry user guide, Table 101, lists over-voltage tolerance as "No" for
  `gpio` and `gpiov2` and "Yes" for `gpio_ovtv2` and `sio_macro`. So this repo's
  5.5 V pad stretch has no `gpiov2` precedent; the foundry solves it in a
  different cell.) Our row set
  deliberately asks for far less (GF.4 to GF.6 are stretch).
- The same filler widths (1, 5, 10, 20 µm). We arrive at the same set because
  it covers any 1 µm multiple; CELL.6 records it as convergent, not copied.
- Clamped supply pads that carry their own ESD clamp. The user guide describes
  a rail-based scheme with an RC clamp per power domain (2 µs time constant on
  the HV clamp), about 150 ohm in series at the core access, and states the clamps
  are "robust up to 3.3KV HBM". That is the foundry's own statement about its
  cell; it is not evidence about any cell drawn here.
- Per-corner Liberty models, which our simulated results can be compared with.

## Consequences

- CELL.2 / CELL.3 / CELL.4 are our own numbers, compared against 80 / 197.965 /
  65.4 x 75.4 µm.
- Foundry cells are not instantiated in any test ring.

## Review addendum, 2026-10-22

Status unchanged: proposed. The survey table above was read from the installed
library; the foundry user guide
(<https://skywater-pdk.readthedocs.io/en/main/contents/libraries/sky130_fd_io/docs/user_guide.html>)
adds the supply range, the rail-based ESD description and the over-voltage
table. The guide states no pad pitch or cell widths, so CELL.2 / CELL.3
comparisons stay on the installed LEF sizes. The guide says `sky130_fd_io__gpio`
is not publicly available; `gpiov2` and `gpio_ovtv2` are. The draw decision
stands; the evidence behind it is the CLAUDE.md purpose, not a finding about the
foundry cell.

## PDK-independent part

The method: survey the vendor I/O library first, draw everything that the
block is meant to stress, use the vendor cell as an oracle, and record where
the vendor cell already solves the problem. The port repeats the survey against
its own PDK's I/O library (gf180mcu has one) before copying this decision.

## PDK-specific part

The survey table, cell names, sizes and the `sky130_fd_io` / `sky130_ef_io`
split.
