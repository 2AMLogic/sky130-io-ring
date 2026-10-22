# 0002 — Supplies, ground topology and device flavors

- **Status**: proposed; ratification pending (human). Ratified by: _unrecorded_.
- **Date**: 2026-10-17
- **Rows**: SUP.1 to SUP.6.

## Decision

- Three supply nets: VDDIO (3.3 V ±10 %), VDD (1.8 V ±10 %), and a single VSS.
- I/O-domain devices are the 5 V gate-oxide family (`nfet_g5v0d10v5`,
  `pfet_g5v0d10v5`), run at no more than 3.63 V. Core-side and level-shifter
  core half use the 1.8 V thin-oxide family.
- One ground net: the substrate is common, so separate I/O and core ground pads
  would not isolate anything and would add pad-type pairs. Separate grounds are
  the fallback.
- 5 V-tolerant input is stretch: it needs a receiver whose devices never see
  more than their oxide limit while the pad is at 5.5 V, which is the hardest
  rule item on this block.

## Review addendum, 2026-10-22

The PDK states model validity for the 5 V family as VDS 0 to 11.0 V and VGS 0 to
5.5 V (NMOS), mirrored for the PMOS. 3.63 V VDDIO is inside it. These are model
ranges, not absolute maxima, so the 5.5 V pad stretch is not yet backed by a
stress limit: a 5.5 V pad against a 3.3 V VDDIO leaves a 5.5 V VGS/VDS on
receiver devices at the very edge of validity. The foundry `gpiov2` is not
over-voltage tolerant (Table 101), which confirms the stretch placement. Status:
still proposed.

## Alternatives rejected

- 1.8 V I/O on the thin-oxide family: no thick-oxide rules exercised.
- 5 V nominal I/O: removes the headroom that makes the 3.3 V case a check.

## PDK-independent part

Three supply nets, one ground, thick-oxide devices for the I/O domain, thin
oxide in the core domain, 5 V tolerance as stretch.

## PDK-specific part

Device names, the 3.3 V and 1.8 V values, and the `_g5v0d10v5` family. The
`gf180mcu` port uses its own thick-oxide family and its own supply values.
