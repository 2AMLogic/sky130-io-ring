# corner-skew-probe

Gate G2 **single-corner probe**: does the sky130 skew set (`ff ss sf fs`) move
the 5 V thick-oxide devices `nfet_g5v0d10v5` / `pfet_g5v0d10v5`, or only the
1.8 V core devices? `spec/review-2026-10.md` section 5 row `G2` holds rows
PVT.1 to PVT.5 out of the ratification scope on that question and assigns the
closing evidence to a Builder: "read the corner files and show a single-corner
probe; otherwise state it open".

The record is `kind: probe`. It is **not item-5 evidence**: it makes no device,
supply, bias or geometry *choice* (W, L and the bias are carried over from
`sim/pdk-smoke`), it changes no netlist, spec row or decision record, and it is
not a corner result — only one corner (`tt`, 27 C) is simulated.

```sh
bash sim/corner-skew-probe/run.sh /tmp/x    # ~25 s; default OUTDIR sim/corner-skew-probe/record
diff -r sim/corner-skew-probe/record /tmp/x # empty unless tool versions differ
```

`run.sh` refuses to overwrite an existing output directory. The two committed
logs are under the repo's blanket `*.log` ignore rule, so regenerating the
record and committing it needs `git add -f record/logs/*.log` (the same way
`sim/clamp-probe/record/logs/probe.log` is tracked). Everything below is
re-derived by `run.sh` from `$SKY130_MODEL_LIB`'s own `.include` chain on each
run; no path and no number is hardcoded.

## What the probe does

Two halves, in one `run.sh`, neither of them a corner sweep:

- **A. Card survey** (`record/logs/cards.log`, run id `cards`) — read-only, no
  simulation. For each of `tt ff ss sf fs` it resolves the `.lib <corner>`
  section of `sky130.lib.spice`, follows its MOS include to
  `corners/<corner>.spice`, and from there follows the include that names each
  of the four devices at that corner. It reports the resolved card, the
  `*.corner.spice` wrapper's two junction multipliers, the card's bin count,
  the reference bin's `vth0` / `toxe` / `u0`, and how many lines the card
  differs from the same device's `tt` card by.
- **B. Measured anchor** (`record/logs/probe.log`, run id `probe`) — **one**
  ngspice process, `tt`, 27 C: DC operating point of the same four devices at
  the `sim/pdk-smoke` bias, reporting drain current and the model's
  operating-point `vth`, `vdsat` and `gm`. Single-corner and local, which is
  what the host rules allow and what the `G2` row asks for.

In `record.json`, `runs.cards.converged` means the survey produced `RESULT`
lines with no error text — it is a file read, not a simulation. Only
`runs.probe` is simulated.

**Why no drain current at `ff ss sf fs`.** That is a corner sweep: five
separate model-library loads, because the 88 (5 V) / 108-180 (1.8 V) binned
`.model` names collide across corners and cannot share a deck. A grid goes to
`klt sim` on the batch fleet, and `spec/review-2026-10.md` section 7 item 3
withholds any corner set until decision 0004 ratifies (#24). So the
per-corner figures here are read from the cards and the measured figure is
`tt` only. See "What this does not show".

## The corner files (AC 2)

Each `.lib <corner>` section of
`$PDK_ROOT/sky130A/libs.tech/ngspice/sky130.lib.spice` includes exactly one MOS
corner file, `corners/<corner>.spice`. That file includes, per device and with
one exception noted below, a 20-line `*.corner.spice` wrapper which sets two
junction multipliers and includes the
real `*.pm3.spice` card (24 498 / 24 497 lines for the 5 V NMOS / PMOS,
48 819 and 30 058 for `nfet_01v8` / `pfet_01v8`). Paths below are relative to
`$PDK_ROOT/sky130A/libs.ref/sky130_fd_pr/spice/`; `<c>` is each of
`tt ff ss sf fs`, and the five files per row are distinct (see the diff column
in the next section).

| Device | Wrapper (junction multipliers) | Model card |
|---|---|---|
| `nfet_g5v0d10v5` | `sky130_fd_pr__nfet_g5v0d10v5__<c>.corner.spice` | `sky130_fd_pr__nfet_g5v0d10v5__<c>.pm3.spice` |
| `pfet_g5v0d10v5` | `sky130_fd_pr__pfet_g5v0d10v5__<c>.corner.spice` | `sky130_fd_pr__pfet_g5v0d10v5__<c>.pm3.spice` |
| `pfet_01v8` | `sky130_fd_pr__pfet_01v8__<c>.corner.spice` | `sky130_fd_pr__pfet_01v8__<c>.pm3.spice` |
| `nfet_01v8` | **none** — `corners/<c>.spice` includes the card directly | `sky130_fd_pr__nfet_01v8__<c>.pm3.spice` |

`nfet_01v8` is the one device of the four with no wrapper, so it is the one
device with no per-corner junction multipliers; its area/perimeter junction
parameters are the same at all five corners. That asymmetry is in the library,
not in this probe.

Each device is named on a fixed line of `corners/<c>.spice` at every corner:
line 21 (`nfet_g5v0d10v5`), 18 (`pfet_g5v0d10v5`), 2 (`nfet_01v8`), 6
(`pfet_01v8`). The `esd_nfet_g5v0d10v5` / `esd_pfet_g5v0d10v5` variants are
included per corner too (lines 24 and 17); they belong to the ESD gates (G5,
G6), not to G2, and are not probed here.

## Per-corner card parameters (AC 3)

Reference-bin values, i.e. the first `.model` card in each file. The
percentage in brackets is the deviation from the same device's `tt` card.
`diff` is `diff tt <corner> | grep -c '^[<>]'`, so it counts both sides of
each changed line — halve it to compare with a one-directional line count.

`toxe` (effective oxide thickness, m):

| Device | tt | ff | ss | sf | fs |
|---|---|---|---|---|---|
| `nfet_g5v0d10v5` | 1.16e-08 | 1.11128e-08 (-4.20%) | 1.20872e-08 (+4.20%) | 1.0904e-08 (-6.00%) | 1.2296e-08 (+6.00%) |
| `pfet_g5v0d10v5` | 1.175e-08 | 1.12565e-08 (-4.20%) | 1.22435e-08 (+4.20%) | 1.2455e-08 (+6.00%) | 1.1045e-08 (-6.00%) |
| `nfet_01v8` | 4.148e-09 | 3.9966e-09 (-3.65%) | 4.2994e-09 (+3.65%) | 3.9323e-09 (-5.20%) | 4.3637e-09 (+5.20%) |
| `pfet_01v8` | 4.23e-09 | 4.07561e-09 (-3.65%) | 4.38439e-09 (+3.65%) | 4.44996e-09 (+5.20%) | 4.01004e-09 (-5.20%) |

`vth0` (reference-bin base value, V) and `u0`:

| Device | quantity | tt | ff | ss | sf | fs |
|---|---|---|---|---|---|---|
| `nfet_g5v0d10v5` | `vth0` | 0.78882 | 0.791968 (+0.40%) | 0.785543 (-0.42%) | 0.793111 (+0.54%) | 0.784341 (-0.57%) |
| `pfet_g5v0d10v5` | `vth0` | -1.011028 | -0.979018 (+3.17%) | -1.042752 (-3.14%) | -1.057134 (-4.56%) | -0.964555 (+4.60%) |
| `nfet_01v8` | `vth0` | 0.5190093 | 0.52129956 (+0.44%) | 0.5164001 (-0.50%) | 0.521494355 (+0.48%) | 0.5160869 (-0.56%) |
| `pfet_01v8` | `vth0` | -1.05955351 | -1.0498303 (+0.92%) | -1.069709 (-0.96%) | -1.069382 (-0.93%) | -1.047954 (+1.09%) |
| `nfet_g5v0d10v5` | `u0` | 0.0421082 | 0.0426101 (+1.19%) | 0.0413323 (-1.84%) | 0.0418565 (-0.60%) | 0.0419527 (-0.37%) |
| `pfet_g5v0d10v5` | `u0` | 0.0209856 | 0.0213783 (+1.87%) | 0.0204141 (-2.72%) | 0.0207994 (-0.89%) | 0.0209529 (-0.16%) |
| `nfet_01v8` | `u0` | 0.0318614 | 0.0323787 (+1.62%) | 0.0311586 (-2.21%) | 0.0319905 (+0.41%) | 0.0314621 (-1.25%) |
| `pfet_01v8` | `u0` | 0.0104766 | 0.0104306 (-0.44%) | 0.0106298 (+1.46%) | 0.0097753 (-6.69%) | 0.011074 (+5.70%) |

Junction multipliers from the `*.corner.spice` wrapper (`a` = area, `p` =
perimeter), bin count, and the card diff against `tt`:

| Device | bins | quantity | tt | ff | ss | sf | fs |
|---|---|---|---|---|---|---|---|
| `nfet_g5v0d10v5` | 88 | `a` / `p` | 0.99505 / 1.0144 | 0.87078 / 0.84883 | 1.1193 / 1.1801 | 0.81753 / 0.77786 | 1.1726 / 1.2510 |
| | | `diff` | 0 | 4770 | 4770 | 4770 | 4770 |
| `pfet_g5v0d10v5` | 88 | `a` / `p` | 1.0050 / 1.0090 | 0.95405 / 0.96374 | 1.0559 / 1.0542 | 1.0777 / 1.0736 | 0.93222 / 0.94436 |
| | | `diff` | 0 | 7260 | 7964 | 7964 | 7192 |
| `nfet_01v8` | 180 | `a` / `p` | absent | absent | absent | absent | absent |
| | | `diff` | 0 | 12646 | 12646 | 12758 | 12754 |
| `pfet_01v8` | 108 | `a` / `p` | 0.99626 / 1.0009 | 0.93001 / 0.93439 | 1.0625 / 1.0675 | 1.0909 / 1.0960 | 0.90161 / 0.90587 |
| | | `diff` | 0 | 8834 | 8830 | 8830 | 8830 |

**Reading `vth0` honestly.** These cards are geometry-binned (88 to 180
`.model` cards each), and a bin's `vth0` carries `lvth0` / `wvth0` / `pvth0`
geometry corrections, so a bin's base `vth0` is **not** the threshold voltage of
a given W/L. The reference bin is quoted here as a card-level indicator that is
comparable corner-to-corner, not as a device threshold. The physical threshold
of the probe's geometry is the measured `vth_op_V` in the next section.
`run.sh` also records which bin covers the probe's W/L under the stated rule
(`lmin <= L < lmax`, `wmin <= W < wmax`, on the scaled geometry: the library
sets `.option scale=1.0u`): bin 63 for both 5 V devices, 62 for `nfet_01v8`,
71 for `pfet_01v8`, one match each under that rule. Both W = 1.0 µm and the
two L values sit exactly on a bin's lower bound, so ngspice's own pick could
be the adjacent bin; nothing above depends on it, because the reference bin,
`toxe` and the card diff are all bin-independent.

## Measured anchor (tt, 27 C, one ngspice run)

DC operating point, W = 1.0 µm for all four, L = 0.5 µm (5 V) / 0.15 µm
(1.8 V), gate and drain at the nominal supply (NMOS) or source and bulk at the
supply with gate and drain at 0 (PMOS). **W, L and the bias are carried over
verbatim from `sim/pdk-smoke/run.sh` and are not design values** — the point of
reusing them is that the currents below are directly comparable with the
committed smoke record.

| Device | Vsup | Id (supply) | Id (model) | `vth` at op | `vdsat` | `gm` |
|---|---|---|---|---|---|---|
| `nfet_g5v0d10v5` | 5.0 V | 654.5 µA | 650.8 µA | 0.8329 V | 1.3774 V | 171.3 µS |
| `pfet_g5v0d10v5` | 5.0 V | 351.7 µA | 351.7 µA | 0.7503 V | 2.2214 V | 104.5 µS |
| `nfet_01v8` | 1.8 V | 501.0 µA | 501.0 µA | 0.7693 V | 0.3622 V | 532.2 µS |
| `pfet_01v8` | 1.8 V | 200.7 µA | 200.7 µA | 0.5100 V | 0.8405 V | 238.2 µS |

All four converged. The supply currents match the committed
`sim/pdk-smoke/record` operating-point currents to every recorded digit
(654.509 µA, 351.682 µA, 501.046 µA, 200.748 µA, in table order), even though
that record was produced on ngspice-46 and this one on ngspice-47 — so this
`tt` operating point is unchanged across those two ngspice versions.
`vth` / `vdsat` / `gm` are model operating-point values at this bias, not
device specifications.

## G2 finding (a probe result for the reviewers; nothing is changed)

1. **The library does apply skew to the 5 V devices.** Every one of
   `ff ss sf fs` selects a *distinct* `*.pm3.spice` card and a *distinct*
   `*.corner.spice` wrapper for both `nfet_g5v0d10v5` and `pfet_g5v0d10v5`;
   none of them falls back to the `tt` card. G2's open question is answered
   **yes**.
2. **The 5 V skew is wider than the 1.8 V skew, on the clearest indicator.**
   `toxe` moves ±4.20% at `ff`/`ss` and ±6.00% at `sf`/`fs` for the 5 V pair,
   against ±3.65% and ±5.20% for the 1.8 V pair. The junction multipliers skew
   further still on the 5 V NMOS (0.818 to 1.173 area, 0.778 to 1.251
   perimeter), where `nfet_01v8` has none at all.
3. **The n/p sense of `sf` and `fs` is consistent between the two families.**
   At `sf` the n-device has the thinnest oxide and the p-device the thickest; at
   `fs` the reverse — for the 5 V pair exactly as for the 1.8 V pair. So a
   named skew corner means the same thing for an I/O device as for a core
   device.
4. **`vth0` is not where the 5 V skew mostly lives.** The reference-bin `vth0`
   moves 0.40 to 0.57% on `nfet_g5v0d10v5` (and 0.44 to 0.56% on `nfet_01v8`),
   while `pfet_g5v0d10v5` moves 3.14 to 4.60%. The dominant skewed quantities
   are `toxe` and the junction multipliers, with `u0` under 3% everywhere
   except `pfet_01v8` at `sf`/`fs`.
5. **`complete: no` does not mean "unskewed", and is not evidence on G2.**
   `klt pdk corners --pdk sky130A` prints `mos=skewed resistor_cap=typical`
   for all four skew corners, and this probe records directly that each of the
   five `.lib tt|ff|ss|sf|fs` sections includes
   `r+c/res_typical__cap_typical.spice` (`rc_include=` in `cards.log`). So
   "complete: no" says *the passives are typical at this corner* — the passive
   skew lives in the separate `ll hh hl lh` sections, out of 51 `.lib` sections
   in total. `spec/klt-rule-coverage.md` is accurate as written ("MOS-only
   skew"); what does not follow is the inference from it to the 5 V devices,
   and that inference is why G2 was left open.

These are for the spec review on 2AMLogic/sky130-io-ring#24. No spec row,
decision record or `spec/io-ring.json` value is changed by this probe; the
result is input to the review.

## What this does not show

- **No corner-to-corner current, delay or leakage figure.** Only `tt`/27 C is
  simulated. That the cards differ does not say by how much a *circuit*
  response moves; that needs a corner set, which goes through `klt sim`
  (`--wait-for-capacity 600`) on the batch fleet after decision 0004 ratifies,
  and is explicitly out of scope here.
- **No temperature sweep, no Monte Carlo, no mismatch.** `mc_mm_switch` and
  `mc_pr_switch` are 0 in all five sections; the `*_mm` sections and the `mc`
  section are untouched here.
- **Nothing about the `ll hh hl lh` passive corners**, the 16 combined
  MOS+passive sections (`sf_ll` to `fs_lh`) and their 16 `_mm` variants, the
  `esd_*` device variants, or whether the 75-corner choice in PVT.5 is the
  right set — that judgement is the review's, not this probe's.
- **Nothing about absolute-maximum ratings, oxide stress or ESD** (gates G1,
  G5, G6, and ESD.10). The reference-bin and operating-point numbers are model
  parameters, not device limits or measured silicon.
