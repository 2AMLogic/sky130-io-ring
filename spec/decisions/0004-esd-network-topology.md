# 0004 — ESD network topology and evidence limits

- **Status**: proposed; ratification pending (human). Ratified by: _unrecorded_.
- **Date**: 2026-10-17
- **Rows**: ESD.1 to ESD.10, section 5 of `io-ring.md`.

## Decision

- Per GPIO pad: a primary diode pair (pad to VDDIO, VSS to pad), a series
  resistor into the driver and receiver, and a local clamp at the receiver gate.
- Supply clamps: RC-triggered large NMOS, thick-oxide between VDDIO and VSS,
  thin-oxide between VDD and VSS. No direct VDDIO-VDD clamp.
- Grounded-gate (snapback) clamps are the fallback only.

## Why this topology

The PDK models (diodes and MOS) describe forward conduction and the normal
operating range; they do not reproduce snapback or second breakdown (the
`esd_nfet_01v8` model is a 1.8 V thin-oxide structure only). A topology whose
discharge paths are forward diodes plus RC-triggered MOS clamps is the one
whose turn-on and current sharing a simulation can say something about. A
topology that relies on snapback would produce a rule-clean layout and no
pre-silicon evidence.

## What the evidence can and cannot show

See section 5.1 of `io-ring.md`. In short: turn-on, path choice, current
split and node voltage at the ESD.2 pulse can be simulated; failure current,
HBM/CDM pass level and latch-up immunity cannot. No cell is described as
ESD-rated; the 2 kV figure is a design target.

## Open item

ESD.7 needs the breakdown figure for each connected device from the PDK
documentation. It is not recorded here; the Builder who first sizes a clamp
adds it to this record.

## PDK-independent part

The topology classes (diode pair, secondary resistor and local clamp, RC
supply clamps, no direct cross-domain clamp), the path table, and the
evidence statement.

## PDK-specific part

Which devices implement each element, trigger time constant, device
breakdown values, and which models are valid at stress current.
