# gpio-probe

First **single-corner probe** of the drawn GPIO cell (`sky130_ioring_gpio`, `design/netlists/`, included unchanged). `tt`, 27 C, nominal rails (VDDIO 3.30 V, VDD 1.80 V), one ngspice process. The record is `kind: probe`: it is **not** item-5 evidence, ratifies nothing and grades no spec row.

Two records now sit here. `record/` is the original baseline (pull-up PMOS `MPU` at W = 1, L = 4 um). `record-mpu-w2p5/` re-runs the same bench and deck after the pull-up resize (#181) with only `MPU` widened to W = 2.5 um (L, nf and the pull-down device untouched); both were produced by this `run.sh` at the same pinned operating point, so the two `record.json` files differ only where the resized pull-up can reach.

```sh
bash sim/gpio-probe/run.sh /tmp/x          # ~2 min; default OUTDIR sim/gpio-probe/record
diff -r sim/gpio-probe/record /tmp/x       # empty unless tool versions differ
```

`run.sh` refuses an existing output directory (records are append-only). It binds the cell (a `gpio_dut` adapter subcircuit), the pinned model library and the rails; the stimuli, loads and `.meas`-style extraction are in [`sim/lib/gpio_measurements.sp`](../lib/gpio_measurements.sp), which names no PDK, model or path, so the port takes it by pinned reference and the later corner request (#7) reuses it unchanged. A record is `converged` only if every `RESULT` line the deck can print is present and finite (`simrec.py --expect`).

## What is measured (RESULT names; every line carries `row=` and, where the row has one, `proposed_target=` as text; no pass/fail field)

| RESULT | Rows | Definition |
|---|---|---|
| `st_drv_*`, `st_drv_*_ie0` | GF.1, GF.2, GF.8 | OE=1, both data levels: PAD (I/O domain) and Y (core domain); with IE=0 Y is held low |
| `st_in_*`, `st_in_*_ie0` | GF.2, GF.8 | OE=0, PAD forced to 0 / VDDIO, IE on / off: Y level |
| `st_hz_*` vs `st_contention_*` | GF.1 | OE=0 with PAD forced against the data level: pad current (high-Z) next to OE=1 (driving) as reference |
| `st_pu/pd/both/off_free`, `_mid` | GF.3 | pulls individually, both asserted, both off: floating PAD level and the current at PAD = VDDIO/2. "Both" matches "off" (both disabled), not two active pulls |
| `st_inh_pu`, `st_inh_pd` and `_ref` | GF.3 | pull inhibited while OE=1 (PAD forced at the rail the pull would drive toward) against the same pull with OE=0 |
| `st_voh`, `st_vol` | GE.1, GE.2 | 4 mA drawn from / injected into PAD, A/OE set for the level |
| `edge_rate_10pF` | GE.3, GE.4 | 20-80 % rise, 80-20 % fall into 10 pF, and slew = 0.6 x VDDIO / edge time in V/ns. A edges are 0.1 ns |
| `delay_output_path_10pF`, `delay_input_path` | GE.7, GE.8 | 50-50 %: A (0.90 V) rising/falling to PAD (1.65 V) rising/falling, 10 pF; PAD (ideal 0.1 ns edge) to Y, same thresholds. Directions are paired (rise to rise, fall to fall) |
| `input_thresholds` | GE.5 | 30 us up / 30 us down PAD ramp, IE on. `vih_obs` = PAD when Y rises through VDD/2 on the rising ramp; `vil_obs` = PAD when Y falls through VDD/2 on the falling ramp; Y read at PAD = 0.3 and 0.7 x VDDIO in both directions |
| `input_hysteresis` | GF.7 | `vih_obs - vil_obs`, observed at 27 C (the row's target says 25 C) |
| `leakage_sweep` | GE.6 | OE=0, pulls off, IE on; PAD DC-swept 0..VDDIO in 34 points; largest absolute settled pad current, its sign (positive = into the cell) and bias. Baseline: the pulls-off current at VDDIO/2 is `st_off_mid` |
| `pull_resistance` | GE.10 | (VDDIO - 1.65 V) / net pull-up current and 1.65 V / net pull-down current, net of the pulls-off current at the same bias |

Currents `i_pad_into_dut_A` are what the PAD force source supplies into the pin (positive = into the cell); `il_A` > 0 sinks from PAD. GE.9 (toggle rate) is left out: it is defined at a corner this probe does not run.

## Reading the tt numbers (no verdicts; the rows are proposed and mostly name other corners)

- GE.10: the baseline (`record/`) measured the pull-up at about 98 kohm and the pull-down about 31 kohm at 1.65 V, against a proposed range of 20-60 kohm at all corners — the pull-up was far outside it at tt, which was filed as #181. After resizing only `MPU` (W 1 -> 2.5 um, L = 4 um held), `record-mpu-w2p5/` measures:

  | | `record/` (MPU W = 1) | `record-mpu-w2p5/` (MPU W = 2.5) |
  |---|---|---|
  | pull-up `r_pullup_ohm` | 97,972.4 | 40,043.5 |
  | pull-down `r_pulldown_ohm` | 30,769.9 | 30,769.9 |
  | pulls-off `st_off_mid.i_pad_into_dut_A` | 1.75078e-11 | 1.75078e-11 |
  | pull-up `st_pu_mid.i_pad_into_dut_A` | -1.68415e-05 | -4.12051e-05 |

  The pull-up lands inside the proposed range at tt and mid-way between its bounds; the pull-down and pulls-off rows are bit-identical, so the resize moved nothing else in the control path. This is one corner: the row binds at all corners and is not re-graded here; the row itself is not edited.
- GE.7: the output-path fall delay is 4.2 ns at tt, against a proposed 5 ns at the ss / 125 C corner, which this probe does not run.
- GE.1 / GE.2 / GE.3 / GE.5 / GE.6 / GE.8 / GF.7 values sit in the record next to their targets; compare only with the corner in mind.

## What this probe does not show

No corner (the targets of GE.1-4, GE.6-8 name ss / ff / hot / cold corners), no temperature other than 27 C, no Monte Carlo, no post-layout (schematic netlist only, no parasitics), no ESD claim (the pad diodes are in the netlist but no stress is applied), and it is **not item-5 evidence**. The P1-P9 path simulations and every corner set stay behind ratification (`spec/review-2026-10.md` section 7 item 3). Y is unloaded; GE.3 / GE.4 / GE.7 use a 10 pF PAD load only.
