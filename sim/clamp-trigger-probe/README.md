# clamp-trigger-probe

Gate G6 **follow-up single-corner probe** of the two RC supply clamps: `sky130_ioring_clamp_io` (ESD.4, VDDIO-VSS, 5 V) and `sky130_ioring_clamp_core` (ESD.5, VDD-VSS, 1.8 V). It resolves the two things the first probe (`sim/clamp-probe/`, 2AMLogic/sky130-io-ring#72) left open: **where between 1 us and 10 us of supply rise the false trigger stops**, and **what the negative post-ramp supply current of the 1 us rows was**. `tt`, 27 C, one ngspice process, the netlists in `design/netlists/` included unchanged. The record is `kind: probe`: it is **not** item-5 evidence, covers no other corner, says nothing about ESD rating (ESD.10), and proposes no supply rise-time requirement.

```sh
bash sim/clamp-trigger-probe/run.sh /tmp/x          # ~1-2 min; default OUTDIR sim/clamp-trigger-probe/record
diff -r sim/clamp-trigger-probe/record /tmp/x       # empty unless tool versions differ
```

`run.sh` refuses to overwrite an existing output directory. The operating point, the 19 ramp transients and the 4 settling transients run one after another in a single ngspice process (the sky130 library is loaded once); there is no corner or Monte Carlo set here (`spec/review-2026-10.md` section 7 item 3 holds those).

## What is simulated

- **Rise-time sweep**: VP from 0 to the nominal supply (5.0 V io, 1.8 V core) with a linear rise of 1 us to 10 us — every integer step plus 0.25 us steps from 5 us to 8 us across the transitions — then 50 us held at nominal, exactly the first probe's ramp circuit, hold and tran-step scheme, so the 1 us and 10 us rows compare with its record directly. Reported per rise time: peak GATE voltage, peak clamp NMOS current `Id(XMCL)` (the total, `mult` included), peak supply current (maximum magnitude of the source current) and the signed supply current at the end of the run.
- **Settling study of the 1 us ramp**: the same circuit held for 1.01 ms after the ramp, sampled at 2 us to 1 ms, run four times differing only in the transient grid and solver tolerances: three times at ngspice defaults (`tstep`/`tmax` = 50n/50n, 250n/510n, 252.5n/1.01u) and once at tightened tolerances (`reltol=1e-6`, `abstol=1e-15`, `vntol=1e-9`, 50n/50n). A separate DC-biased instance of each clamp gives the operating-point leakage.
- **ESD.7 comparison**: for every rise time, the peak |VDS| and |VGS| of each clamp transistor (`esd7_*` rows). For the io clamp (`nfet/pfet_g5v0d10v5`) the limits are VDS <= 11.0 V and VGS <= 5.5 V; a value beyond them is labelled `outside_model_validity`. The core clamp uses the thin-oxide family, for which no validity range is on record, so it is labelled `no_validity_range_on_record`, neither pass nor fail.

The transition criterion uses **round probe values, not extracted device thresholds**: peak GATE below 0.5 V and below 1.0 V (the first probe's HBM thresholds), and peak `Id(XMCL)` below 1 mA (between the 1 us and 10 us peaks of both clamps by three to six decades). The clamp is called off for a rise time only when all three are below their thresholds.

## Results (tt, 27 C)

Rise-time sweep. `Id(XMCL)` is the peak clamp NMOS drain current; `Isup` the peak supply current; `Ileak(end)` the signed supply current at the end of the 50 us hold (positive: supply delivers).

| Clamp | Rise | peak GATE | peak Id(XMCL) | peak Isup | Ileak(end) |
|---|---|---|---|---|---|
| io (5.0 V) | 1 us | 5.000 V | 1.25 A | 1.26 A | -62.3 uA (artifact, see below) |
| io | 2 us | 3.392 V | 722 mA | 724 mA | 3.4 nA |
| io | 3 us | 2.288 V | 364 mA | 364 mA | 1.5 nA |
| io | 4 us | 1.828 V | 222 mA | 222 mA | 10.1 nA |
| io | 5 us | 1.487 V | 124 mA | 124 mA | 3.1 nA |
| io | 5.25 us | 1.433 V | 110 mA | 110 mA | 6.3 nA |
| io | 5.5 us | 1.386 V | 97.1 mA | 97.1 mA | 8.4 nA |
| io | 5.75 us | 1.354 V | 89.4 mA | 89.4 mA | 5.8 nA |
| io | 6 us | 1.129 V | 40.1 mA | 40.1 mA | 4.5 nA |
| io | 6.25 us | 0.875 V | 4.86 mA | 4.87 mA | 7.6 nA |
| io | 6.5 us | 0.757 V | 770 uA | 775 uA | 7.2 nA |
| io | 6.75 us | 0.653 V | 126 uA | 130 uA | 5.3 nA |
| io | 7 us | 0.559 V | 22.9 uA | 27.2 uA | 6.4 nA |
| io | 7.25 us | 0.510 V | 9.62 uA | 18.8 uA | 5.6 nA |
| io | 7.5 us | 0.450 V | 3.22 uA | 12.6 uA | 5.9 nA |
| io | 7.75 us | 0.428 V | 2.17 uA | 15.3 uA | 7.1 nA |
| io | 8 us | 0.392 V | 1.12 uA | 13.5 uA | 5.9 nA |
| io | 9 us | 0.345 V | 482 nA | 12.3 uA | 5.9 nA |
| io | 10 us | 0.324 V | 316 nA | 11.2 uA | 5.9 nA |
| core (1.8 V) | 1 us | 1.800 V | 2.11 A | 2.12 A | -26.1 uA (artifact, see below) |
| core | 2 us | 1.382 V | 1.18 A | 1.18 A | 18 nA |
| core | 3 us | 1.072 V | 507 mA | 507 mA | 17.9 nA |
| core | 4 us | 0.937 V | 252 mA | 252 mA | 12.4 nA |
| core | 5 us | 0.855 V | 129 mA | 129 mA | 15.2 nA |
| core | 5.25 us | 0.834 V | 103 mA | 103 mA | 16.0 nA |
| core | 5.5 us | 0.731 V | 26.8 mA | 26.8 mA | 13.7 nA |
| core | 5.75 us | 0.556 V | 909 uA | 911 uA | 15.6 nA |
| core | 6 us | 0.432 V | 49.6 uA | 52.1 uA | 14.1 nA |
| core | 6.25 us | 0.358 V | 8.33 uA | 12.8 uA | 15.4 nA |
| core | 6.5 us | 0.311 V | 2.60 uA | 10.8 uA | 14.5 nA |
| core | 6.75 us | 0.281 V | 1.24 uA | 8.51 uA | 15.2 nA |
| core | 7 us | 0.259 V | 728 nA | 8.47 uA | 14.8 nA |
| core | 7.25 us | 0.246 V | 511 nA | 6.09 uA | 14.8 nA |
| core | 7.5 us | 0.235 V | 388 nA | 5.01 uA | 14.8 nA |
| core | 7.75 us | 0.227 V | 312 nA | 7.67 uA | 15.0 nA |
| core | 8 us | 0.220 V | 260 nA | 4.79 uA | 15.0 nA |
| core | 9 us | 0.203 V | 166 nA | 5.97 uA | 14.8 nA |
| core | 10 us | 0.193 V | 125 nA | 4.83 uA | 14.8 nA |

The transition brackets (thresholds: peak GATE 0.5 V, peak GATE 1.0 V, peak `Id(XMCL)` 1 mA — round probe values):

| Clamp | Criterion | Off bracket (last above / first below) |
|---|---|---|
| io | peak GATE < 1.0 V | (6 us, 6.25 us] — 1.129 V / 0.875 V |
| io | peak Id(XMCL) < 1 mA | (6.25 us, 6.5 us] — 4.86 mA / 770 uA |
| io | peak GATE < 0.5 V | (7.25 us, 7.5 us] — 0.510 V / 0.450 V |
| io | **combined (all three)** | **(7.25 us, 7.5 us]**, determined by GATE 0.5 V |
| core | peak GATE < 1.0 V | (3 us, 4 us] — 1.072 V / 0.937 V |
| core | peak Id(XMCL) < 1 mA | (5.5 us, 5.75 us] — 26.8 mA / 909 uA |
| core | peak GATE < 0.5 V | (5.75 us, 6 us] — 0.556 V / 0.432 V |
| core | **combined (all three)** | **(5.75 us, 6 us]**, determined by GATE 0.5 V |

Endpoint rows of each combined bracket: io at 7.25 us the clamp current is already three decades below 1 mA but peak GATE (0.510 V) still sits 10 mV above the 0.5 V probe value, and at 7.5 us all three criteria are below threshold; core at 5.75 us the clamp current is below 1 mA (909 uA) while peak GATE (0.556 V) is not yet below 0.5 V, and at 6 us all three are. The GATE-0.5 V boundaries are threshold-sensitive at this resolution — the 0.5 V and 1 mA values are probe choices, not device parameters.

Settling of the 1 us ramp (times from simulation start; the ramp ends at 1 us). Signed leakage, positive when the rail delivers. Operating-point leakage from the DC-biased instance: **io +6.49 nA, core +14.9 nA** — the same values the first probe's 1 ms-ramp rows read (6.5 nA, 14.9 nA).

| t | io, tight tolerances | core, tight tolerances | io, defaults 50n/50n | io, defaults 250n/510n | io, defaults 252.5n/1.01u |
|---|---|---|---|---|---|
| 2 us | +26.9 uA | +1.94 uA | +67.9 uA | +83.9 uA | +81.9 uA |
| 5 us | +0.367 uA | +0.179 uA | +32.4 uA | +29.6 uA | -159 uA |
| 10 us | +0.134 uA | +0.0947 uA | +22.8 uA | -38.3 uA | +142 uA |
| 20 us | +0.132 uA | +0.0938 uA | +14.6 uA | -170 uA | +107 uA |
| 51 us | +0.131 uA | +0.0929 uA | +11.0 uA | +93.5 uA | -1.08 uA |
| 100 us | +0.130 uA | +0.0915 uA | +10.8 uA | +115 uA | -164 uA |
| 300 us | +0.127 uA | +0.0857 uA | +10.5 uA | +132 uA | -151 uA |
| 500 us | +0.123 uA | +0.0800 uA | +10.2 uA | +76.9 uA | -138 uA |
| 700 us | +6.49 nA | +14.9 nA | +9.95 uA | +35.0 uA | -127 uA |
| 1 ms | +6.49 nA | +14.9 nA | +9.53 uA | -11.2 uA | +111 uA |

The same table's node evidence: `T1` and `T` (the trigger RC nodes) are within 10 mV of the rail by 5 us and print as the rail value (5.000 V / 1.800 V) from 10 us on in **all four runs**; `G2` holds the rail from 10 us on in all four. `G1` and `GATE` sit at their DC values in the two 50 ns-grid runs (`GATE` decays through the mV range during the first ~20 us — the clamp NMOS gate discharging through the output inverter's subthreshold leakage — and is below 12 uV from 51 us on, ~1e-8 V under tightened tolerances); in the two coarser default runs `G1`/`GATE` wander ±mV around DC with no consistent sign — the same timestep residue the supply current column shows. At the 51 us sample — 50 us after the ramp — the trigger network of both clamps is at its DC value in every run.

## Finding (a probe result for the reviewers; nothing is changed)

1. **The false trigger dies between 6.25 us and 7.5 us (io) and between 5.5 us and 6 us (core) of supply rise.** The combined off brackets (all three criteria below threshold) are **(7.25 us, 7.5 us] for the io clamp and (5.75 us, 6 us] for the core clamp**, in each case set by the peak-GATE-below-0.5 V criterion; the clamp-current criterion turns off earlier (io (6.25, 6.5] us, core (5.5, 5.75] us). Below those rise times the trigger fires hard (1.25 A io / 2.11 A core at 1 us, as in the first probe); just above them the clamp current is already three-plus decades below its 1 us peak. The thresholds are round probe values, not extracted device thresholds.
2. **The negative post-ramp supply current of the first probe's 1 us rows was a timestep artifact of the transient solver at default tolerances, not a circuit current.** Three observations, all in the record:
   - *No branch can carry it.* From 10 us after a 1 us ramp the trigger network is at its DC value in every run (`T1`, `T` at the rail to seven digits in all four; `GATE` below 12 uV from 51 us in the 50 ns-grid runs). The only DC path from the trigger network back to the supply is through the trigger resistors (about 125 kohm each, `res_xhigh_po_0p69`, L = 43, W = 0.69, 2 kohm/sq sheet); carrying 72 uA there would need ~9 V across the VP-T1 branch of a 5 V rail. The trigger capacitor discharging back through the supply — the first probe's candidate — is ruled out by `T1` and `T` sitting at the rail while the source "absorbs".
   - *It depends only on the timestep.* At the same instant (51 us, same node state) the signed supply current reads -62.3 uA at the sweep's grid (12.75n/51n), +11.0 uA at 50n/50n, +93.5 uA at 250n/510n and -1.08 uA at 252.5n/1.01u — magnitudes of microamps to tens of microamps and both signs, varying with nothing but `tstep`/`tmax`. A physical current cannot. The first probe's committed values (-72 uA io, -30 uA core, ngspice 46) are the same artifact; this record's same-grid sweep rows read -62.3 / -26.1 uA on ngspice 47.
   - *Tightened tolerances collapse it onto the operating point.* At `reltol=1e-6, abstol=1e-15, vntol=1e-9` the same transient reads within ~0.4 uA of the DC leakage from 5 us and **+6.49 nA (io) / +14.9 nA (core) at the 700 us, 1 ms and final samples — the operating-point leakage exactly** (the sub-µA plateau before that, decaying from 0.37 uA at 5 us, is the tightened solver's own residue band; no branch carries it either).
3. **Settled leakage and settling time.** Criterion: |I(t) - I_dc| <= 1 uA (absolute), confirmed over the remaining >= 0.5 ms of samples at >= 10 us spacing, tightened-tolerance run. Both clamps settle in the bracket **(2 us, 5 us] of simulation time — 1 us to 4 us after the ramp end** (the 2 us sample is still charging the trigger network: `T1` = 4.42 V of 5 V io, +26.9 uA; by 5 us `T1` is within 30 mV of the rail and the current is sub-µA). Settled leakage: **io +6.49 nA, core +14.9 nA**.
4. **ESD.7 (io clamp): every transistor of every rise-time case stays within 11.0 V / 5.5 V** — worst VDS 5.02 V (XMP3, 1 us) and worst VGS 5.01 V, all rows `within_esd7_model_range`. Unlike the first probe's HBM pulse, no ramp case leaves the model validity range. The core-clamp rows (worst VDS 1.81 V, worst VGS 1.80 V) are recorded unjudged (`no_validity_range_on_record`).
5. The 1 us and 10 us endpoints reproduce the first probe's rows (`sim/clamp-probe/record/`) to the third digit on ngspice 47 vs its ngspice 46 — e.g. io 1 us peak GATE 5.00006 V vs 5.00007 V, peak Id 1.24891 A vs 1.24892 A; io 10 us 0.3236 V vs 0.3284 V, 316 nA vs 349 nA — except the 1 us end-of-hold current, which is the artifact of point 2 and moves with the solver (−62.3 uA vs −71.8 uA).

These are for the spec review on 2AMLogic/sky130-io-ring#24 (gate G6); the trigger constant, the clamp sizing and any supply rise-time requirement are not changed or proposed by this probe.

## What this does not show

Not a corner or temperature result; not snapback, failure current or second breakdown (the models do not represent them); not the ESD.8 discharge paths; not an ESD rating. The supply is ideal (no package or rail impedance), the pad has no capacitance, and the VP node carries no other load, so absolute currents are upper-bound-style model numbers, not predictions. The transition brackets speak only for the tt, 27 C model at these two clamp netlists; the thresholds are probe values, and the 0.5 V GATE boundary in particular sits within 10 mV (io) and 56 mV (core) of the measured bracket edges, so a reviewer re-reading "off" with a different threshold will move the bracket by one refinement step.
