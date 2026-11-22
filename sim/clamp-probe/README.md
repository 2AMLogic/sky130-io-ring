# clamp-probe

Gate G6 **single-corner probe** of the two RC supply clamps: `sky130_ioring_clamp_io` (ESD.4, VDDIO-VSS, 5 V) and `sky130_ioring_clamp_core` (ESD.5, VDD-VSS, 1.8 V). `tt`, 27 C, one ngspice process, the netlists in `design/netlists/` included unchanged. The record is `kind: probe`: it is **not** item-5 evidence, covers no other corner, and says nothing about ESD rating (ESD.10); an HBM figure here is a simulation figure of a model, not a measured one.

```sh
bash sim/clamp-probe/run.sh /tmp/x          # ~1 min; default OUTDIR sim/clamp-probe/record
diff -r sim/clamp-probe/record /tmp/x       # empty unless tool versions differ
```

`run.sh` refuses to overwrite an existing output directory. The 8 power-up ramps and the 2 HBM pulses run one after another in a single ngspice process (the sky130 library is loaded once); there is no corner or Monte Carlo set here (`spec/review-2026-10.md` section 7 item 3 holds those).

## What is simulated

- **Power-up ramp**: VP from 0 to the nominal supply (5.0 V io, 1.8 V core) with a linear rise of 1 us, 10 us, 100 us and 1 ms, then 50 us held at nominal. Ideal voltage source, VSS grounded, no load on VP.
- **HBM pulse (ESD.2)**: 100 pF charged to 2 kV discharged through 1.5 kohm into VP, VSS grounded, 10 us window. The pulse itself decays with tau = 150 ns (R x C).
- **ESD.7 comparison**: for every probe, the peak |VDS| and |VGS| of each clamp transistor (`esd7_*` lines). For the io clamp (`nfet/pfet_g5v0d10v5`) the limits are VDS <= 11.0 V and VGS <= 5.5 V; a value beyond them is labelled `outside_model_validity`. The core clamp uses the thin-oxide family, for which no validity range is on record (`review-2026-10.md` did not read one), so it is labelled `no_validity_range_on_record`, neither pass nor fail.

## Results (tt, 27 C)

Power-up ramp. `Id(XMCL)` is the peak clamp NMOS drain current (the total, `mult` included); `Isup` the peak supply current; `Ileak` the supply current 50 us after the ramp ended (positive: supply delivers).

| Clamp | Rise | peak GATE | peak Id(XMCL) | peak Isup | Ileak |
|---|---|---|---|---|---|
| io (5.0 V) | 1 us | 5.00 V | 1.25 A | 1.26 A | -72 uA (not settled) |
| io | 10 us | 0.33 V | 349 nA | 11 uA | 6.0 nA |
| io | 100 us | 0.20 V | 25.9 nA | 0.61 uA | 6.4 nA |
| io | 1 ms | 0.15 V | 9.5 nA | 50 nA | 6.5 nA |
| core (1.8 V) | 1 us | 1.80 V | 2.11 A | 2.11 A | -30 uA (not settled) |
| core | 10 us | 0.19 V | 125 nA | 5.3 uA | 14.8 nA |
| core | 100 us | 0.13 V | 16 nA | 0.19 uA | 14.9 nA |
| core | 1 ms | 0.09 V | 5.6 nA | 27 nA | 14.9 nA |

HBM pulse (2 kV, 100 pF, 1.5 kohm):

| Clamp | peak VP | peak Id(XMCL) | GATE above 1.0 V | GATE above 0.5 V | GATE at 9.9 us |
|---|---|---|---|---|---|
| io | 8.59 V | 1.31 A | 0.66 us | longer than the 10 us window | 0.51 V |
| core | 4.78 V | 1.35 A | 0.19 us | 1.4 us | 0.28 V |

The pulse peaks at 1.33 A (2000 V / 1500 ohm); both clamps carry about all of it. The "above" thresholds (0.5 V and 1.0 V) are round probe values, not an extracted threshold voltage of the clamp NMOS.

ESD.7 (io clamp): in the ramps every transistor stays within 11.0 V / 5.5 V. In the HBM pulse the clamp NMOS `XMCL` itself reaches VDS 8.59 V and VGS 5.19 V (within), but `XMP1` (VGS 8.6 V), `XMN2` (VGS 6.9 V) and `XMP3` (VGS 6.8 V) of the trigger chain are **outside model validity**, so their HBM behaviour is not established by this probe. The core-clamp voltages are in the record, unjudged.

## G6 finding (a probe result for the reviewers; nothing is changed)

1. **Both clamps turn fully on during a 1 us power-up ramp** (GATE follows VP to the rail, 1.25 A io / 2.11 A core, limited only by the ideal source). That is false triggering: a ~1 us trigger constant does not tolerate a 1 us supply rise. At 10 us the GATE node peaks at 0.33 V (io) and 0.19 V (core) and the drawn current is nA to uA. Where between 1 us and 10 us the trigger stops is not resolved by these four points.
2. After the 1 us ramps the supply current was still negative 50 us later (the supply absorbing 30 to 72 uA), so the "leakage" of those two rows is a decaying transient, not a settled value. The cause was not investigated.
3. On the HBM pulse the io clamp's GATE stays above 0.5 V for the whole 10 us window (0.51 V at 9.9 us), far longer than the ~150 ns pulse; the core clamp for about 1.4 us. Whether a held-on clamp is acceptable after the pulse is not decided here.
4. Three io trigger-chain transistors exceed the ESD.7 model range in the HBM pulse (above), so the trigger's pulse behaviour is outside what the model supports.

These are for the spec review on 2AMLogic/sky130-io-ring#24; the trigger constant and the clamp sizing are not changed by this probe.

## What this does not show

Not a corner or temperature result; not snapback, failure current or second breakdown (the models do not represent them); not the ESD.8 discharge paths; not an ESD rating. The supply is ideal (no package or rail impedance), the pad has no capacitance, and the VP node carries no other load, so absolute currents are upper-bound-style model numbers, not predictions.
