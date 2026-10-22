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
installed PDK also ships `sky130_fd_pr__esd_nfet_g5v0d10v5` and `esd_pfet_g5v0d10v5`,
but as fixed-geometry models: the NMOS has 10 W bins at L = 0.55 µm only; an
earlier draft of this record named only `esd_nfet_01v8`). A topology whose
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

ESD.7 needed a breakdown figure for each connected device. The 2026-10-22 review
found the PDK publishes **model validity ranges, not breakdown ratings**:
`nfet_g5v0d10v5` VDS 0 to 11.0 V, VGS 0 to 5.5 V, VBS 0 to -5.5 V; `pfet_g5v0d10v5`
mirrored; `esd_nfet_g5v0d10v5` VDS 0 to 11.0 V, VGS 0 to 5.0 V; junction diodes
|V| 0 to 5.0 V with no current or area range
(<https://skywater-pdk.readthedocs.io/en/main/rules/device-details.html>, read
via a page summary; confirm against the page). ESD.7 now uses those ranges as
the pass condition and reports anything beyond them as "outside model validity".
No gate-oxide or junction stress limit, and no failure current, was found. They
stay open (gate G1) and are not invented.

## Review addendum, 2026-10-22

Unchanged: the topology classes and that every claim is bounded by model
validity. Corrected: the path table (P1 route now matches the topology; reverse
supply-pair paths added), and the clamp-device choice (standard 5 V NMOS vs the
fixed-geometry ESD NMOS) and the trigger time constant are recorded as open
(gates G5, G6). The reverse supply paths run through clamp-NMOS body diodes,
which are the least-covered part of the models. Status: still proposed.

## PDK-independent part

The topology classes (diode pair, secondary resistor and local clamp, RC
supply clamps, no direct cross-domain clamp), the path table, and the
evidence statement.

## PDK-specific part

Which devices implement each element, trigger time constant, device
breakdown values, and which models are valid at stress current.
