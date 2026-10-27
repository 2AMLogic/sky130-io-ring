# design

Hand-authored xschem schematics for the sky130 I/O ring (`xschem/*.sch`, with a
`.sym` each), and the SPICE netlists `klt netlist` derives from them
(`netlists/*.spice`). This is T1 checklist item 1 (design sources); the
inventory is `attest-inventory.json`, the envelope is
`../signoff/evidence/item1.json`.

Built against the **proposed** spec (`spec/io-ring.md`, decisions 0001-0004 are
not ratified). Re-check the cells when they ratify (#24). Nothing here is
ESD-rated, qualified or simulated for ESD: HBM 2 kV is a design target. The
foundry `sky130_fd_io` is a comparison only (decision 0001); no schematic or
netlist was copied from it.

## Regenerate and check

```sh
bash design/regen.sh            # rewrite design/netlists/*.spice from design/xschem/*.sch
bash design/regen.sh --check    # write nothing; exit 3 if a netlist drifted from its schematic
bash design/netlist.sh [--check] <cell>      # one cell
klt signoff --attest 1 --inventory design/attest-inventory.json -o signoff/evidence/item1.json
klt signoff --attest 1 --inventory design/attest-inventory.json --check signoff/evidence/item1.json
```

Needs `klt` >= 0.8 (`--attest`), xschem and the pinned PDK (`sim/pdk.json`).
Serial, one `klt netlist` (one xschem process) per cell, local; never call
`xschem` directly. `xschemrc` sets the symbol path (this directory, then the
PDK's `libs.tech/xschem` from `$PDK_ROOT`) and `top_is_subckt` so every netlist
is a real `.subckt`. A parent netlist (e.g. the ring) also contains every child
subcircuit.

After editing a `.sch` or `.sym`: run `regen.sh`, regenerate the attestation
envelope, update `content_hash` for item 1 in `signoff/block-manifest.json`,
and regenerate `signoff/signoff-record.json` (`signoff/README.md`). A new cell
must also be added to `attest-inventory.json` (sources + derived).

CI has no xschem or PDK, so the freshness commands are `local_only`: CI runs
`--attest --check`, which re-hashes every source and netlist and the
envelope but does not re-netlist. The tamper check (edit a `.sch`, no regen)
fails both `regen.sh --check` and `--attest --check`.

## Cells

Names match the layout streams in `layout/gds/` (`sky130_ioring_*`) so layout
versus schematic can key on them (#31, #33).

| Cell | Role |
|---|---|
| `sky130_ioring_gpio` | GPIO pad cell; instantiates the sub-blocks below |
| `sky130_ioring_vddio`, `_vdd`, `_vss` | supply pads; the bond pad is the rail (no separate `PAD` pin). `vddio`/`vdd` carry the RC clamp, `vss` is empty |
| `sky130_ioring_corner`, `_fill_{1,5,10,20}` | rail-only, empty subcircuit body on purpose |
| `sky130_ioring_ring` | 4 corners + 4 sides of `gpio vddio vss vdd gpio fill_20 fill_10 fill_5 fill_1 fill_1`, the same sequence as `layout/gen_ring.py`, around an empty core |
| `gpio_logic`, `gpio_ls` (x4), `gpio_drv`, `gpio_pulls`, `gpio_esd`, `gpio_rcv` | GPIO sub-blocks |
| `clamp_io`, `clamp_core` | RC-triggered NMOS supply clamps (VDDIO-VSS thick, VDD-VSS thin) |
| `inv`, `nand2`, `nand3`, `nor2` | thin-oxide VDD-domain gates |

## Pin-name convention

Every cell carries the same rail names: `VDDIO`, `VDD`, `VSS` (one ground,
SUP.5). GPIO pins: `A` core data to pad, `OE` output enable, `IE` input enable,
`PU`/`PD` pull select, `Y` pad data to core, `PAD` bond pad. The ring exposes
the GPIO pins per pad as `A0..A7`, `OE0..`, `PAD0..`; rails are shared by
name across all 44 instances, which is what ring-seam LVS connects on.

## Device families and ESD network

- I/O domain (VDDIO 3.3 V): `nfet_g5v0d10v5` / `pfet_g5v0d10v5` (decision 0002).
  Core domain (VDD 1.8 V): `nfet_01v8` / `pfet_01v8`. The level-down inverter
  runs `g5v0d10v5` devices from VDD so no thin-oxide gate sees the VDDIO swing.
- ESD (decision 0004, ESD.3-ESD.5): diode PAD to VDDIO (`diode_pd2nw_05v5`) and
  VSS to PAD (`diode_pw2nd_05v5`); series resistor (`res_high_po_1p41`) from PAD
  into the receiver, plus a local diode clamp at the receiver gate; RC-triggered
  large NMOS clamps with an xhigh-poly / MIM RC (~1 us) and a three-stage
  inverter chain; no direct VDDIO-VDD clamp.

## Assumptions and OPEN items (recorded, not decided here)

- **All sizing is a placeholder** (device W/L/mult, diode areas, RC values,
  Schmitt feedback, pull L). The spec leaves series R, diode areas, clamp
  device (standard vs `esd_nfet_g5v0d10v5`, gate G5) and the trigger time
  constant (gate G6) open. Sizing is set by simulation (T1 item 9, #34).
- **No series resistor in the driver path**: ESD.3 says "into the driver and
  receiver"; a resistor on the driver drain fights GE.1/GE.2 (VOH/VOL), so the
  driver drain sits on `PAD` and only the receiver has the series R. Raise
  against `spec/` with a decision record if the spec means both.
- **Pad cells for VDDIO/VDD/VSS have no `PAD` pin**; the pad is the rail.
- **Diode `area`/`perim` units are unresolved.** Values follow the foundry's
  convention (um2 x 1e12, um x 1e6). In a quick ngspice 46 operating-point
  probe the sky130 diode wrapper conducted in both directions at `area=2e14`
  and at the symbol default `1e12`, so these must be settled before any ESD
  simulation. This is a model question for #34, not a claim about the cells.
- A throwaway transient on the GPIO with the four diodes removed showed drive
  high/low and the IE gate behaving as drawn; the pulls were slower than the
  window. It is not recorded evidence (no corners, no record).
- Hysteresis (GF.7), edge rate (GE.3/GE.4), drive (GE.1/GE.2), pull resistance
  (GE.10) and the supply-sequencing leakage (SUP.6) are unverified.
