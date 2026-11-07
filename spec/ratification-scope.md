# Ratification scope for issue #2

**Status: preparation only. Nothing is ratified by this file, by its author, or
by the key reviewers.** The operator ratifies (2am#5864, ruling 2026-10-22).
This file names exactly what a ratification PR would put in front of the
operator, so the EE-key and market-key reviews have a fixed target. It changes
no row value, no `spec/io-ring.json` status and no decision-record Status line.

Derived from `spec/io-ring.json` and `spec/review-2026-10.md` as of
`66c1d8d` (2026-10-24). `python3 -I spec/check_spec.py` passes.

## Decision records in scope

All four are *Proposed* and stay so until the operator records a ruling.

| Record | Rows it governs |
|---|---|
| `decisions/0001-draw-vs-adopt.md` | No row range; the record is decided before every other row (cell set and geometry) |
| `decisions/0002-supplies-and-device-flavors.md` | SUP.1 to SUP.6 |
| `decisions/0003-pvt-corner-set.md` | PVT.1 to PVT.5 (all held out, see below) |
| `decisions/0004-esd-network-topology.md` | ESD.1 to ESD.10 |

Records 0002, 0003 and 0004 each govern held-out rows, so the
operator should not read a ratification of the in-scope rows as ratifying the
whole record.

## Rule used to hold a row out

A row is **held out** when `spec/review-2026-10.md` section 3 (row classification)
or section 5 (gates G1 to G9) ties that specific row id to an open gate, or the
row's own text names the gate. Groups the review ties to a gate (for example
"PVT.1 to PVT.5") are held out as a group. A row the review calls "provisional"
without naming a gate is **in scope**: provisional rows are design targets the
operator can ratify as targets. No row is held out by inference, so the list
below is a floor, not a judgement that every other row is settled.

## In scope (43 rows)

- **SUP** (4): SUP.2, SUP.4, SUP.5, SUP.6
- **GF** (8): GF.1, GF.2, GF.3, GF.4, GF.5, GF.6, GF.7, GF.8
- **GE** (10): GE.1, GE.2, GE.3, GE.4, GE.5, GE.6, GE.7, GE.8, GE.9, GE.10
- **CELL** (7): CELL.1, CELL.2, CELL.3, CELL.6, CELL.7, CELL.8, CELL.9
- **ESD** (6): ESD.1, ESD.5, ESD.6, ESD.8, ESD.9, ESD.10
- **LU** (2): LU.1, LU.4
- **SIGN** (6): SIGN.1, SIGN.2, SIGN.3, SIGN.4, SIGN.5, SIGN.6

## Held out (16 rows)

| Row | Gate | Basis |
|---|---|---|
| SUP.1 | G3 | §3 "5.5 V stretch is open (G3)"; the row text cites G3 |
| SUP.3 | G1 | §3 SUP.1/SUP.3 margin provisional; row text cites G1 (no stress limit for the 5 V devices) |
| CELL.4 | G7 | §3 "Open"; bond-pad opening depends on shuttle / package (G7) |
| CELL.5 | G5 | §3 rail widths sized against an ESD peak current not yet computed (G5) |
| ESD.2 | G9 | §5 G9: HBM network values need the standard text |
| ESD.3 | G1 | row text cites G1; §3 ESD.3 to ESD.6 sizing unset |
| ESD.4 | G6 | row text cites G6 (1 µs vs the foundry 2 µs time constant) |
| ESD.7 | G1 | §3 "Rewritten, partly open (G1)"; row text cites G1 |
| LU.2 | G4 | §3 "interim target (10 µm)" vs sourced 15 µm fallback (G4) |
| LU.3 | G4 | §3 "Interim, unsourced"; row text cites G4 |
| LU.5 | G9 | §5 G9: latch-up test needs the standard text |
| PVT.1 | G2 | §3 PVT.1 to PVT.5; 5 V device skew handling not inspected (G2) |
| PVT.2 | G2 | as PVT.1 |
| PVT.3 | G2 | as PVT.1 |
| PVT.4 | G2 | as PVT.1 |
| PVT.5 | G2 | as PVT.1 |

Gate G8 (tool coverage of latch-up and ESD rules) holds out no row: it is a
tool gap, tracked upstream, not a value to ratify. Gate G8 is therefore absent
from the table.

Rows an operator may reasonably also want held, **not** held here because the
review does not tie them to a gate by id: ESD.5 and ESD.6 (section 3: "every
sizing value is unset"; G5 covers series resistance and clamp width) and ESD.1
(section 3 groups it with ESD.2, but G9 names only ESD.2). The operator decides.

## Arithmetic

In scope 43 + held out 16 = 59 rows in `spec/io-ring.json`; no row is in both lists.
