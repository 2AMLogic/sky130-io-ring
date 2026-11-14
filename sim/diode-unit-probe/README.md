# diode-unit-probe

Settles the **unit convention of the instance `area` / `perim` parameters** of
`sky130_fd_pr__diode_pd2nw_05v5` and `sky130_fd_pr__diode_pw2nd_05v5`
(2AMLogic/sky130-io-ring#107), so that G1 sizing (decision 0004) has a defined
starting point. PR #105's `sim/diode-probe/` deliberately declined to infer
the unit; this probe settles it by measurement.

`tt` corner, 27 C, plus a companion deck at 30 C (the cards' own `tref`).
Two ngspice processes, each a single-corner run of operating points only — no
corners, no Monte Carlo, no parallel jobs. No device is resized and no ESD
rating is stated anywhere.

```sh
bash sim/diode-unit-probe/run.sh /tmp/x     # ~10 s; default OUTDIR sim/diode-unit-probe/record
diff -r sim/diode-unit-probe/record /tmp/x  # empty unless tool versions differ
```

`run.sh` refuses to overwrite an existing output directory.

## Conclusion

**The instance `area` is um^2 and `perim` is um.** With `area=2500 perim=200`
the device is a plausible pad diode (1.0 pF at the 3.3 V rail, 1.37 V forward
drop at the ESD.2 peak current). The design netlists' placeholders
`area=2e14 perim=6e7` therefore instantiate a **2e14 um^2 = 200 m^2** diode,
and the local pair `area=1e13 perim=1.4e7` a 1e13 um^2 device — the
placeholders are not merely unsized, they are ~11 to 12 orders of magnitude
above any plausible pad diode.

All three candidate conventions are disposed of explicitly:

| Candidate | Meaning | Verdict |
|---|---|---|
| C1 | instance value is um^2 / um | **confirmed** (both paths, both models) |
| C2 | instance value is m^2 / m — the cards' literal `; Units:` comments | numerically indistinguishable from C1 at the same instance values, but **refuted on physical consistency**: under C2 the measured capacitance density would be 1e12 times below the cards' own stated F/m^2 figure, and one instance unit would be 1 m^2 of diode |
| C3 | instance value is um^2 x 1e12 / um x 1e6 — the reading `design/README.md` recorded before this probe | **refuted by a factor 1e12 on BOTH paths**: the measured per-unit coefficients are 1e12 times the C3 prediction, on the capacitance path and the current path alike |

## Method

Instantiate each model at known instance values, then read **ngspice's own
output** — junction capacitance `@d<name>[cd]`, device current
`@d<name>[id]`, and the node voltage under a forced 1.33333 A (the ESD.2 peak
current, 2000 V / 1500 ohm) — and compare the per-unit coefficients against
the model cards under each candidate.

The per-unit coefficients are extracted by **differences between instances**,
which cancels the second (area or perimeter) term and any bias derating
exactly, and needs no corner-multiplier evaluation:

- `cj_eff  = (cd(area=10, perim=1) - cd(area=1, perim=1)) / 9`
- `cjsw_eff = (cd(area=1, perim=10) - cd(area=1, perim=1)) / 9`
- implied saturation current at 0.6 V forward: `s_i = id / exp(0.6/(n*Vt))`,
  then `js_eff = (s2-s1)/9`, `jsw_eff = (s3-s1)/9`

Instance matrix: `a=1 p=1`, `a=10 p=1`, `a=1 p=10`, `a=1 pj=1` (the
`perim=`/`pj=` alias check), and `a=2500 p=200` (realistic scale). Anchors at
the forced current: `a=2500 p=200`, `a=25000 p=2000` (1x and 10x — the
linearity-in-area check at high current), and `a=2e14 p=6e7` (what the design
netlists' placeholder actually means). Both models
(`pd2nw`, `pw2nd`) get the full set.

## Why the forward point is 0.6 V: the GMIN floor

ngspice's default `GMIN = 1e-12 S` conductance is in parallel with every
junction. At a raw diode with `js`-scale saturation current, the floor's
`GMIN*V` dominates below ~0.4 V — and below that, current is **not linear in
instance area**. The deck records the low-bias rows as a measured
demonstration of exactly that, not as results (27 C, `pd2nw`):

| bias | measured id (a=1,p=1) | hand, junction only | ratio | hand + GMIN*V | ratio | id(a=10)/id(a=1) |
|---|---|---|---|---|---|---|
| 0.2 V | 3.525e-13 A | 1.524e-13 A | 2.3x | 3.524e-13 A | 1.000 | **1.114** (not 10) |
| 0.3 V | 2.908e-12 A | 2.608e-12 A | 1.1x | 2.908e-12 A | 1.000 | 1.236 |
| 0.4 V | 4.488e-11 A | 4.447e-11 A | 1.0x | 4.487e-11 A | 1.000 | 1.261 |

(A hand formula with only the junction term cannot reproduce the measured
current at 0.2 V; adding `GMIN*V` reproduces it exactly. `pw2nd` shows the
same effect more weakly because its `js` is 128x larger, so its junction term
stays above the floor further down.) **A low-bias operating point cannot
settle this unit question**; the 0.6 V primary point sits far above the floor.

## Results (tt, 27 C; the 30 C companion where stated)

### Capacitance path — `cj` / `cjsw` (cards pre-scale these: `*1e-12`, `*1e-6`)

Measured per-unit coefficient vs the card's pre-scaled figure:

| coefficient | pd2nw | ratio to card | pw2nd | ratio to card |
|---|---|---|---|---|
| `cj_eff` (27 C) | 7.380191e-16 F/unit | 0.9963 | 1.339747e-15 F/unit | 0.9954 |
| `cjsw_eff` (27 C) | 9.888911e-17 F/unit | 1.0009 | 3.673556e-17 F/unit | 1.0204 |
| `cj_eff` (30 C) | 7.407660e-16 F/unit | 1.0000 | 1.342937e-15 F/unit | 0.9978 |
| `cjsw_eff` (30 C) | 9.899933e-17 F/unit | 1.0020 | 3.673667e-17 F/unit | 1.0204 |

The measured coefficients equal the pre-scaled card figures to ~2% — and are
**1e12 times the C3 prediction** (7.4079e-28 F/unit for pd2nw's `cj`). The
derating check agrees: at 3.3 V reverse the measured `cd` of the `a=1 p=1`
device is 0.997x the hand value
`cj_ps*(1+3.3/pb)^-mj + cjsw_ps*(1+3.3/php)^-mjsw` for both models.

Only under C1 (instance = um^2) is the card's `; Units: farad/meter^2`
comment physically true post-conversion: measured `cj_eff` per 1e-12 m^2
gives back the comment's 0.00074079 F/m^2 (x1.0000 at 30 C). Under C2 the
same measurement would have to mean 7.4079e-16 F/m^2 — the comment's figure
divided by 1e12.

### Current path — `js` / `jsw` (cards pre-scale nothing here)

Measured per-unit coefficient vs the card's raw figure:

| coefficient | pd2nw | ratio to card | pw2nd | ratio to card |
|---|---|---|---|---|
| `js_eff` (27 C) | 1.541477e-17 A/unit | 0.7175 | 1.977586e-15 A/unit | 0.7191 |
| `jsw_eff` (27 C) | 5.096842e-16 A/unit | 0.6339 | 3.877480e-16 A/unit | 0.6462 |
| `js_eff` (30 C) | 2.150535e-17 A/unit | 1.0010 | 2.738704e-15 A/unit | 0.9959 |
| `jsw_eff` (30 C) | 8.015139e-16 A/unit | 0.9969 | 5.892806e-16 A/unit | 0.9821 |

At the cards' own `tref = 30` the raw figures apply **per instance unit** to
within 0.2-1.8% for both models and both coefficients. At 27 C the ratio is
0.63-0.72 — a temperature artifact (the cards' `eg`/`xti`/`tref = 30`
temperature scaling of the saturation current, run 3 C below the reference),
**common to every candidate hypothesis, and far too small to restore any
1e12 factor**. The companion deck exists precisely to show that.

The forced-current anchors confirm the whole form, at the ESD.2 peak
1.33333 A, against
`V = n*Vt*ln(I/isat + 1) + I*rs/area` with `isat = js*area + jsw*perim`
(raw application) and `rs` scaled by the instance area:

| instance | pd2nw meas / hand (27 C) | rel | pd2nw meas / hand (30 C) | rel |
|---|---|---|---|---|
| a=2500 p=200 | 1.37354 / 1.35866 V | +1.1% | 1.36905 / 1.36905 V | +2.8e-6 |
| a=25000 p=2000 | 1.00435 / 0.989478 V | +1.5% | 0.999048 / 0.999048 V | -4.3e-7 |
| a=2e14 p=6e7 | 0.214112 / 0.202416 V | +5.8% | 0.204439 / 0.204439 V | +2.7e-8 |

`pw2nd` at 30 C: 1.40041 / 1.40039 V (+1.7e-5), 0.85175 / 0.851743 (+7.7e-6),
0.0415697 / 0.0415697 (-1.8e-7). The 10x-area anchor pair shifts by exactly
the predicted amount (isat x10 and rs /10), so current **is linear in
instance area** at high current for both models. At the placeholders'
`a=2e14`: `isat` = 4.30 mA (`pd2nw`) / **0.550 A** (`pw2nd`) — reproducing
`sim/diode-probe`'s recorded figures and explaining its "below the turn-on of
a silicon junction" drops as pure placeholder scaling, under the settled unit.

### The `perim=` / `pj=` alias — asserted, not assumed

The `a=1 pj=1` and `a=1 perim=1` instances return **bit-identical** `cd` and
`id` at every recorded bias in both decks, and both report `perim = 1` from
the device's own readback (`@d<name>[perim]`). The repo's `perim=` spelling
reaches the device.

## What the cards' `; Units:` comments actually describe

The card pre-scaling is **not uniform**, which is why the two paths were
checked separately:

| parameter | card figure (pd2nw) | on-card factor | comment says | effective with instance um^2/um |
|---|---|---|---|---|
| `cj` | 0.00074079 x 1e-12 | *1e-12 | farad/meter^2 | F/**um^2** — comment describes the pre-conversion source unit |
| `cjsw` | 9.88e-011 x 1e-6 | *1e-6 | farad/meter | F/**um** — same |
| `ik` | 4.76e-008/1e-12 | /1e-12 | amper/meter^2 | A/**um^2** — same |
| `js` | 2.1483e-017 | **none** | amper/meter^2 | applied raw per instance unit = A/**um^2**; comment describes units the simulator never converts |
| `jsw` | 8.04e-016 | **none** | amper/meter | applied raw per instance unit = A/**um**; same |
| `rs` | 600 | **none** | ohm (ohm/meter^2 if area defined) | applied as 600/area per instance unit = ohm x um^2; the anchors fit it to 0.003% |

So: for `cj` / `cjsw` / `ik` the meter comments are the *source* units that
the on-card factor converts from; for `js` / `jsw` / `rs` there is no
conversion and the meter comments do **not** describe the units the instance
numbers are in. `sim/diode-probe`'s `model_limits_*` lines (`js*area`,
`ik*area`) were already computing the correct per-instance-unit arithmetic;
this probe supplies the unit those numbers are in.

Cross-check against the PDK's own usage: its FET subcircuits instantiate
`diode_pw2nd_05v5` with `area=8.7 pj=60.58` for a `w=60u` device
(`sky130_fd_pr__nfet_20v0_iso__subcircuit.pm3.spice`) — 8.7 um^2 / 60.58 um,
physically sensible only under C1. (The `res_generic_nd__hv`
`area='w*l*0.5'` usage that once looked like counter-evidence is a different
wrapper whose `w`/`l` are themselves in um.)

## Context rows (what the placeholders mean; nothing is resized)

| instance (netlist value) | cd at ~0 V | forward drop at 1.33333 A |
|---|---|---|
| `pd2nw a=2500 p=200` (plausible scale) | 1.865 pF | 1.374 V (27 C) |
| `pw2nd a=2500 p=200` | 3.357 pF | 1.403 V (27 C) |
| `pd2nw a=2e14 p=6e7` (netlist placeholder) | **0.1476 F** | **0.214 V** |
| `pw2nd a=2e14 p=6e7` | **0.268 F** | **0.0492 V** |

The placeholder rows reproduce `sim/diode-probe`'s recorded 0.0793 F
(`pd2nw` at the 3.3 V rail, i.e. this 0.1476 F derated) and 0.2679 F
(`pw2nd`) junction capacitances and the 0.2014 V / 0.0492 V forced-current
drops: those numbers are the behaviour of a 2e14 um^2 = 200 m^2 device, not
of anything buildable. At `a=2500 p=200` the same model gives 1.0 pF at the
3.3 V rail and a normal junction forward drop. **This table records what the
placeholder means, not a sizing proposal** — sizing is gate G1 / decision
0004, and every number here is single-corner (`tt`) at that.

## What this does not show

Not a corner or temperature result: `tt` at 27 C (plus the 30 C
`tref`-reference deck for the unit question itself). No ESD rating and no
sizing recommendation — the 2500/200 rows exist to show the unit produces
physically sensible devices, nothing more. Not an assertion about the
*drawn* layout: the layout generator currently converts netlist values by
the refuted C3 factor (`layout/sky130_devices.py` computes `area * 1e-12`),
so the drawn 200 um2 rectangles and the netlist placeholders disagree by
1e12 — reconciled as an open item in `layout/README.md` and its own issue,
not silently here. `sim/diode-probe/` was not touched (the `sim/` tree is
append-only; this probe is a new directory).

## Notes on the record

- `record/record.json` carries both decks as runs: `main_tt27` and
  `tref30_check`, `all_converged: true`, `errors` empty. The only simulator
  message is the known benign warning already documented in
  `sim/diode-probe` ("IKR too small - model effect disabled", the cards'
  `ikr = 0`).
- The low-bias rows (0.2 / 0.3 / 0.4 V) are recorded with the junction-only
  and junction+GMIN hand values in the table above; in the record they are
  raw `id_A` rows (`fwd_*`), and `cap_*` rows carry `cd_F`. The
  current-sourced instances rest at ~0 V during the capacitance stages
  (forced current still 0 A), so their `cd` rows are labelled
  `bias_source=0A_current_source` rather than inheriting the stage bias.
- `record/netlists/probe_tt27.sp` and `probe_tref30.sp` are the generated
  decks with `$PDK_ROOT` in place of absolute paths;
  `record/logs/*.log` are scrubbed the same way. Nothing in `record/`
  contains an absolute path.
- `tools.ngspice` in the record is the version this host ran (47);
  `tools.ciel` is `unavailable`, as in `sim/clamp-probe` and
  `sim/diode-probe`. The committed log needed `git add -f` (blanket `*.log`
  gitignore; tracked for removal by #106).
- `sim/README.md`'s probe index is **not** updated: the `sim/` append-only
  guard freezes it until #109 lands.
