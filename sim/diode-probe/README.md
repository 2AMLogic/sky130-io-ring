# diode-probe

Gate **G1 / ESD.3** single-corner probe of the GPIO pad diodes in
`design/netlists/sky130_ioring_gpio_esd.spice`, at the ESD.2 current. `tt`,
27 C, one ngspice process, the cell included unchanged. The record is
`kind: probe`: it is **not** item-5 evidence, covers no other corner, and says
nothing about ESD rating (ESD.10).

> **Every voltage below is the forward drop of a placeholder at a placeholder
> area, not a pad-diode drop.** `design/xschem/sky130_ioring_gpio_esd.sch`
> line 15 says so itself — *"Series R and diode areas are UNSIZED in the spec
> (ESD.3, gate G1): values here are placeholders."* The netlist instantiates
> `area=2e14 perim=6e7` on the pad pair, and at that area the models'
> saturation current is 4.30 mA (XDP) and **0.550 A** (XDN), which is why the
> drop at 1.33 A lands at 0.20 V and 0.05 V rather than near the ~0.7 V a
> silicon junction gives. Sizing the diodes is out of scope here (decision
> 0004); reporting these numbers without that sentence is not.

```sh
bash sim/diode-probe/run.sh /tmp/x          # ~40 s; default OUTDIR sim/diode-probe/record
diff -r sim/diode-probe/record /tmp/x       # empty unless tool versions differ
```

`run.sh` refuses to overwrite an existing output directory. Every analysis runs
one after another in a single ngspice process (the sky130 library is loaded
once); there is no corner or Monte Carlo set here (`spec/review-2026-10.md`
section 7 item 3 holds those).

## What is simulated

The cell is instantiated with `RXG` **unloaded** — the pad cell standing on its
own, no receiver — so `XRS` carries only what `XDLP` / `XDLN` draw. `VSS` is
node 0. `VDDIO` is the SUP.1 nominal **3.3 V** unless a row says otherwise.

1. **Gun self-tests**, no design device in the loop, run first so the stress
   network is established before any pad number is read from it:
   the ESD.2 gun (100 pF, 2 kV, 1.5 kohm) into a short, and into a 1 uF load
   whose final voltage *is* the delivered charge.
2. **Forced-current sweep**: a current source into (pad-positive) or out of
   (pad-negative) `PAD`, at 14 currents from 0 A to the ESD.2 peak
   1.33333 A = 2000 V / 1500 ohm, including 0.667 A (the ESD.2 1 kV row) and a
   cluster across 0.38 to 0.42 A where the pad voltage turns over. **Each
   current is its own operating point**, not a continuation of the previous
   one — see "Why not a `dc` sweep" below.
3. **Supply sensitivity** at the ESD.2 peak only, at VDDIO 2.97 / 3.30 / 3.63 V
   (the SUP.1 range) plus a 5.0 V comparison rail. The ESD.7 verdict lands on
   the *reverse-biased* diode, whose bias is set by the rail, not by the pad.
4. **ESD.2 HBM pulse**, one per polarity, each fired from several starting
   states: the natural operating point, the same fired at 500 ns instead of
   50 ns, the same with a 1 Gohm pad bleed changing the quiescent point, and
   two **diagnostics** that force the pad state with `.ic`. The three natural
   runs are the invariance check; the forced ones are not results.
   `pulse_qp` / `pulse_qn` repeat the natural case on the 5.0 V rail.

### Why not `uic`, and why not a `dc` sweep

The gun here is a voltage **step behind** the 100 pF capacitor, not a
pre-charged capacitor. `C*V` is the same 200 nC and the decay is the same
`R*C` = 150 ns, but the deck then has a real DC operating point, so the
transient needs neither `uic` nor a guessed `.ic` on the pad. That matters
because this pad node has no DC path except the diodes themselves: under `uic`
the solver's trajectory is set by the guess, and the reported "forward drop"
comes out as whatever was forced in. The two diagnostic replicas show exactly
that (Results, last table).

The forced-current points are solved independently rather than as one `dc`
sweep because the pad voltage is near-discontinuous in current at ~0.4 A (next
section). A `dc` continuation across that turnover returned intermediate
solutions of 2e4 to 5e6 A — non-physical, and silently so. The independent
operating points are monotone, and each carries `i_kcl_A`, the pad-node current
balance rebuilt from the four diode currents: `i_kcl_err_A` is below 2.6e-4 A on
all 34 points and below 2e-6 A on 23 of them.

## Results (tt, 27 C)

**Gun self-test.** Peak 1.33289 A against the ideal 1.33333 A (the 0.1 ns edge
costs 0.03 %); current at one tau / peak = 0.367879, against `1/e` = 0.367879;
the 1 uF load ends at 0.19998 V, i.e. **199.98 nC** delivered against the ideal
200 nC. The gun is right.

**Forced-current sweep, VDDIO = 3.3 V.** `vf` is the conducting pad diode's
forward voltage; `id` its own current. The remainder of the forced current is
carried by the *reverse* current of the opposite diode, and (above the
turnover) a few mA through `XRS` to the local pair.

| I forced | pad-positive: v(PAD) | XDP vf | XDP id | XDN id (reverse) | pad-negative: v(PAD) | XDN vf | XDN id |
|---|---|---|---|---|---|---|---|
| 0 | 0.26 mV | — | -3.08 mA | -3.08 mA | 0.26 mV | — | -3.08 mA |
| 1.333 mA | 0.37 mV | — | -3.08 mA | -4.41 mA | 0.148 mV | — | -1.75 mA |
| 13.33 mA | 1.41 mV | — | -3.08 mA | -16.4 mA | -0.853 mV | 0.853 mV | 10.3 mA |
| 133.3 mA | 14.08 mV | — | -3.08 mA | -136 mA | -9.49 mV | 9.49 mV | 130 mA |
| 0.300 A | 48.2 mV | — | -3.08 mA | -303 mA | -18.7 mV | 18.7 mV | 297 mA |
| 0.380 A | 112 mV | — | -3.08 mA | -383 mA | -22.3 mV | 22.3 mV | 377 mA |
| 0.390 A | 168 mV | — | -3.08 mA | -393 mA | -22.8 mV | 22.8 mV | 387 mA |
| 0.395 A | 622 mV | — | -3.08 mA | -397 mA | -23.0 mV | 23.0 mV | 392 mA |
| 0.400 A | **3.044 V** | — | -3.07 mA | -397 mA | -23.2 mV | 23.2 mV | 397 mA |
| 0.420 A | 3.365 V | 64.8 mV | 16.3 mA | -397 mA | -24.0 mV | 24.0 mV | 417 mA |
| 0.500 A | 3.422 V | 122 mV | 96.1 mA | -397 mA | -27.1 mV | 27.1 mV | 497 mA |
| 0.667 A (1 kV) | 3.457 V | 157 mV | 263 mA | -397 mA | -32.9 mV | 32.9 mV | 664 mA |
| 1.000 A | 3.486 V | 186 mV | 596 mA | -397 mA | -42.0 mV | 42.0 mV | 997 mA |
| **1.33333 A (2 kV)** | **3.5014 V** | **0.2014 V** | **0.9291 A** | **-0.3969 A** | **-0.04917 V** | **0.04917 V** | **1.3302 A** |

At the ESD.2 peak, pad-positive: `XDP` carries 0.9291 A forward, `XDN` carries
0.3969 A of **reverse** current, and 7.3 mA goes through `XRS` to the local
pair (`XDLN` -7.22 mA, `XDLP` -0.15 mA). `XRS` drops 3.486 V and holds `RXG` at
15.1 mV — 3.486 V / 7.37 mA implies about 0.47 kohm for `res_high_po_1p41`
`L=1.0`, which is also unsized (G5). Pad-negative: `XDN` carries 1.3302 A
forward and `XDP` only its -3.08 mA reverse saturation.

**Supply sensitivity at the ESD.2 peak.** The conducting diode's forward drop
does not move with the rail; the reverse bias on its partner moves 1:1.

| VDDIO | pad-positive: XDP vf | XDN reverse | verdict | pad-negative: XDN vf | XDP reverse | verdict |
|---|---|---|---|---|---|---|
| 2.97 V (SUP.1 min) | 0.2014 V | 3.171 V | within | 0.0492 V | 3.019 V | within |
| 3.30 V (SUP.1 nom) | 0.2014 V | 3.501 V | within | 0.0492 V | 3.349 V | within |
| 3.63 V (SUP.1 max) | 0.2014 V | 3.831 V | within | 0.0492 V | 3.679 V | within |
| 5.0 V (comparison) | 0.2013 V | **5.201 V** | **outside_model_validity** | 0.0492 V | **5.049 V** | **outside_model_validity** |

**ESD.2 HBM pulse.** `exc` is the pad's total voltage excursion over the whole
2 us window; `vf@ipk` the conducting diode's forward voltage at the instant the
pulse current peaks.

| run | rail | starting state | peak current | pad excursion | vf@ipk | forward drop |
|---|---|---|---|---|---|---|
| `pulse_pa` | 3.3 V | natural operating point | 1.33289 A | 575.95 nV | -3.29974 V | **not developed** |
| `pulse_pb` | 3.3 V | natural, fired at 500 ns | 1.33289 A | 575.94 nV | -3.29974 V | not developed |
| `pulse_pc` | 3.3 V | natural + 1 Gohm pad bleed | 1.33289 A | 575.95 nV | -3.29974 V | not developed |
| `pulse_qp` | 5.0 V | natural operating point | 1.33289 A | 591.68 nV | -4.99974 V | not developed |
| `pulse_na` | 3.3 V | natural operating point | 1.33289 A | 575.95 nV | -0.26054 mV | not developed |
| `pulse_nb` | 3.3 V | natural, fired at 500 ns | 1.33289 A | 575.93 nV | -0.26054 mV | not developed |
| `pulse_nc` | 3.3 V | natural + 1 Gohm pad bleed | 1.33289 A | 575.95 nV | -0.26054 mV | not developed |
| `pulse_qn` | 5.0 V | natural operating point | 1.33289 A | 591.68 nV | -0.26054 mV | not developed |

**Invariance (the check that separates a result from an artifact).** The three
natural pad-positive runs agree on the pad excursion to 3e-5 relative
(575.953 / 575.936 / 575.953 nV) and exactly on `vf@ipk` (-3.29974 V in all
three), across a 10x change in fire time and a 1 Gohm change to the quiescent
point. The pad-negative three likewise. The pulse figure is invariant — and it is invariant at **no forward
drop at all**.

**Why no drop develops, confirmed two ways.** The models' junction capacitance
at the 3.3 V quiescent point, read from ngspice (`cd_F` on every `dcop_*_i0`
line), is `XDP` 0.0793 F and `XDN` 0.2679 F: **0.3472 F on the pad node**. The
gun delivers 199.98 nC, so the pad can only move `Q/C` = **575.93 nV** — against
575.95 nV measured, 4e-5 relative. And at the current peak the diode
currents are pure displacement current, split in the ratio of their `cd`:
`XDP` +0.3016 A, `XDN` -1.0312 A, summing to the 1.3328 A in the pulse, with no
conduction in either.

**The forced-state diagnostics** (not results) show what forcing the pad gives:

| run | forced `.ic` on PAD, RXG | pad excursion | vf@ipk | reported as |
|---|---|---|---|---|
| `pulse_pd` | 5 V (1.7 V above the 3.3 V rail) | 1.188 V | **+0.644 V** | developed |
| `pulse_pe` | -0.05 V | 8.31 uV | -3.35 V | not developed |
| `pulse_nd` | 5 V | 1.188 V | -3.944 V | not developed |
| `pulse_ne` | -0.05 V | 7.18 uV | **+0.050 V** | developed |

The "forward drop" reads 0.644 V, 0.050 V, or nothing, depending only on the
state forced in — `pulse_ne` returns exactly the 0.05 V it was given. Those
runs exit 0 with no convergence or timestep message. This reproduces the
`uic`-based figures recorded during curation of
2AMLogic/sky130-io-ring#96 (0.267 / 0.714 / 0.864 / 1.004 V) and identifies
their cause: with 0.35 F on the pad node, the node's state at pulse time is
whatever it started at, and nothing in the ESD.2 pulse can change it.

## ESD.7 and the model validity range

Every diode line in the record carries a `validity` token from the vocabulary
already on record in `sim/clamp-probe/run.sh`
(`outside_model_validity` / `within_esd7_model_range` /
`no_validity_range_on_record`), applied to all four diodes of the cell — `XDP`,
`XDN`, `XDLP`, `XDLN` — not only the conducting one. `XRS`
(`res_high_po_1p41`) carries `no_validity_range_on_record`: no range for it was
read into `spec/review-2026-10.md`.

ESD.7 states junction diodes valid for `|V| <= 5.0 V`. Across the whole SUP.1
supply range nothing in this cell leaves that window, in either polarity, at
any current up to the ESD.2 peak; on the 5.0 V comparison rail the
reverse-biased partner does, in both polarities, and is labelled
`outside_model_validity` there. Under the pulse the largest magnitude on any
diode is the rail itself (3.29974 V at 3.3 V, 4.99974 V at 5.0 V), because the
pad does not move.

**A `within_esd7_model_range` verdict here is not a pass on ESD.3, and the
record must not be read as one.** The window is a *voltage* bound. Gate G1's
actual gap is that these models carry **no current validity range at all**,
which is why `current_validity=no_current_validity_range_on_record` sits on
every diode line including the ones that pass the voltage check. The models'
own forward knee `ik`, scaled by the instantiated area, is 9.52e18 A (`XDP`)
and 2.6e17 A (`XDN`) — 17 to 18 orders of magnitude above the 1.33 A probe
current, so high-injection roll-off never engages and the drop is set by
`isat`, `n` and nothing else. Those figures are printed on the
`model_limits_*` lines; they are read from the pinned PDK's model cards by
`run.sh`, not written into it.

**The unit of `area` is not established by this probe.** `isat_A` and
`ik_times_area_A` are the ngspice level-3 area scaling (`js*area + jsw*perim`,
`ik*area`), and the arithmetic is confirmed against the simulator: the ideal
diode equation at `isat` = 0.550 A, `n` = 1.2928, 27 C gives 41 mV at 1.333 A
against 49 mV measured, and at `isat` = 4.30 mA, `n` = 1.3632 gives 190 mV
against 201 mV measured. But the model card sets `area = 1.0e+12` itself while
`res_generic_nd__hv` in the same tree instantiates these diodes with
`area='w*l*0.5'` where `w`/`l` default to 1, so no unit is inferable from
either. Do not read a unit into the table above.

## G1 / ESD.3 findings (probe results for the reviewers; nothing is changed)

1. **At the placeholder areas the pad pair does not behave as a diode pair.**
   `XDN`'s reverse saturation current is 0.397 A at 27 C, so a pad-positive
   stress is shunted to VSS by the *reverse* leakage of the VSS-to-pad diode
   until that saturates at about 0.40 A; only then does the pad rise and `XDP`
   begin to conduct. The pad voltage goes from 0.168 V at 0.390 A to 3.365 V at
   0.420 A — a near-discontinuity, with a 0.397 A reverse-leakage path to VSS
   permanently in place. At rest 3.08 mA circulates from VDDIO through `XDP`'s
   reverse leakage, the pad, and `XDN` to VSS.
2. **The forward drop at the ESD.2 current is below the physical turn-on of a
   silicon junction**, 0.2014 V (`XDP`) and 0.0492 V (`XDN`) at 1.33333 A,
   because `isat` scales with the placeholder area. This is a model result at a
   placeholder size, not a pad-diode figure.
3. **Under the ESD.2 pulse neither pad diode conducts at all.** The
   instantiated areas put 0.347 F of junction capacitance on the pad, so the
   gun's 200 nC moves the pad by 576 nV and the whole 1.33 A flows as
   displacement current. **The pulse-time forward drop is therefore not a
   recordable quantity at these areas** — and any non-zero figure obtained by
   forcing an initial condition on the pad is an artifact of the forcing, as
   the diagnostics above show by returning the forced value.
4. **The pulse figure and the sweep figure are two different quantities** and
   are not reconciled here. The sweep gives a steady-state forward drop at a
   forced current; the pulse gives the response of the pad node to 200 nC of
   charge. At these areas the second says nothing about the diodes.
5. **ESD.7 is satisfied on the voltage window across the whole SUP.1 supply
   range, and that is not evidence for ESD.3.** The rail sets the reverse bias:
   at 5.0 V (not a SUP.1 point) the reverse-biased partner is outside the
   window at the ESD.2 current in both polarities, which is how the 5.864 V
   reverse excursion recorded during curation arose — that measurement used an
   ideal 5 V VDDIO, which SUP.1 does not specify.
6. **The secondary stage works at the placeholder sizes**, for what that is
   worth: at the pad-positive ESD.2 peak `XRS` drops 3.486 V and `RXG` sits at
   15.1 mV while `XDLN` sinks 7.22 mA. Both the series resistance and the local
   clamp are unsized (G5), so this is a shape, not a number to rely on.

These are for the spec review on 2AMLogic/sky130-io-ring#24. Nothing here
resizes a device, changes a netlist, or moves a spec row.

## What this does not show

Not a corner or temperature result (`tt`, 27 C only; `spec/review-2026-10.md`
section 7.3 withholds any corner set until decision 0004 ratifies). Not
snapback, second breakdown or failure current — the models do not represent
them, and the `bv` / `ibv` parameters on the `model_limits_*` lines are fit
parameters, not ratings. Not the ESD.8 discharge paths P1 to P9: the supply
rails here are ideal voltage sources with no rail resistance and no supply
clamp in the loop, so no current split through ESD.4 is shown. Not an ESD
rating, and not a sizing proposal for the diodes or the series resistor. The
pad has no package or probe capacitance beyond the devices' own junctions, the
receiver is absent, and `RXG` is unloaded — so the local pair's numbers are not
independent of the pad's.

## Notes on the record

- **ngspice emits `Warning: sky130_fd_pr__diode_p{d2nw,w2nd}_05v5: IKR too
  small - model effect disabled!` once per model.** They are in the log and are
  not scrubbed: `ikr` is `0` in both cards, so the *reverse* knee is disabled.
  The *forward* knee `ik` is set, and is the one reported above. These are the
  only warnings in the run; `all_converged` is `true` and `errors` is empty.
  A non-converging point would appear in the record through
  `sim/lib/simrec.py`'s error detection rather than be dropped.
- `tools.ngspice` in the record is `47`, the version this host actually ran;
  `sim/pdk.json` pins the PDK revision, not the simulator, and records state
  the versions they ran under (`sim/pdk.json` note). `tools.ciel` is
  `unavailable` because `ciel` is not on this host's PATH, as for
  `sim/clamp-probe`.
- `record/netlists/probe.sp` is the generated deck with `$PDK_ROOT` in place of
  the absolute library path; `record/netlists/sky130_ioring_gpio_esd.spice` is
  the cell copied unchanged with its line-1 `sch_path` comment scrubbed.
  `record/logs/probe.log` is path-scrubbed the same way. Nothing under
  `sim/diode-probe/record/` contains an absolute path.
