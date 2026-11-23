# sim

Simulation harness. The PDK pin lives in one place, `sim/pdk.json`.

## PDK pin

sky130A from open_pdks `f6eeac7dad085ffcc829ccfd721f7b4ce39edcf7`, installed
with ciel 2.6.1 (root `~/.ciel`). Nothing else is current. A tree at any other
revision (for example a stale `~/.volare`) is refused, never used silently.

## Layout: PDK-independent vs sky130

| File | Half | Role |
|---|---|---|
| `lib/simrec.py` | PDK-independent | ngspice log parsing, append-only JSON record writing |
| `lib/gpio_measurements.sp` | PDK-independent | the GPIO measurement deck (stimuli, loads, extraction; spec rows GF / GE); the caller binds the cell, the model library and the rails |
| `lib/run_common.sh` | PDK-independent | the shared `run.sh` preamble (OUTDIR guard, ngspice check, workdir) and record tail (ngspice run, path scrub, tool versions, record write) |
| `pdk-smoke/run.sh` (driver skeleton) | mixed | the netlist emitters and model names are sky130; the preamble and record plumbing are shared (`lib/run_common.sh`) |
| `lib/pdk_env.sh` | sky130 | resolver: pin check, model-library path, corner file layout |
| `lib/smoke_devices.sh` | sky130 | the four-device smoke table shared by `pdk-smoke` and `corner-skew-probe` |
| `lib/test_pdk_env.sh` | sky130 | self-test of the resolver's refusal |
| `pdk.json` | sky130 | the pin and tool versions |

The port (`gf180-io-ring`) takes `lib/simrec.py` and `lib/run_common.sh` by
pinned reference and supplies its own `pdk.json`, `pdk_env.sh`, device table
and netlist emitters.

## Cold start

```sh
uvx --from ciel==2.6.1 ciel enable --pdk-family sky130 f6eeac7dad085ffcc829ccfd721f7b4ce39edcf7
# needs ngspice and python3 on PATH; ciel/xschem are only read for version strings
bash sim/lib/test_pdk_env.sh            # resolver self-test, no PDK needed
bash sim/pdk-smoke/run.sh /tmp/smoke    # reproduce the record (~1-2 min)
diff -r sim/pdk-smoke/record /tmp/smoke # should differ only if tool versions do
```

`run.sh` refuses to write into an existing directory: records are append-only.
Loading the sky130 model library takes about a minute per ngspice run on
ngspice-46, so the smoke runs one netlist.

## Probes

Each probe directory carries a `run.sh` (reproduce) and a `record/` with the
append-only evidence (`record.json` plus the logs and netlists that back it);
all but `pdk-smoke` also carry a `README.md` (what and why). All records are
single-corner runs, and all are `kind: probe` unless the row says otherwise;
none is item-5 evidence.

| Probe | Gate | Question |
|---|---|---|
| `pdk-smoke` | — | the PDK smoke test, not a design probe (`kind: pdk-smoke`, no `README.md`) — documented under [Smoke record](#smoke-record-pdk-smokerecord) below; do the pinned models load and converge? DC op + Id-Vgs of the 1.8 V core and 5 V thick-oxide families |
| `clamp-probe` | G6 | do the RC supply clamps turn on? `clamp_io` (ESD.4, 5 V) and `clamp_core` (ESD.5, 1.8 V), power-up ramps + HBM pulses |
| `clamp-trigger-probe` | G6 | where between 1 us and 10 us of supply rise does the false trigger stop (rise-time sweep with 0.25 us refinement), and what was the first probe's negative post-ramp supply current (settling runs at default and tightened solver tolerances)? |
| `corner-skew-probe` | G2 | does the sky130 skew set (`ff ss sf fs`) move the 5 V thick-oxide devices, or only the 1.8 V core? |
| `gpio-probe` | GF / GE | first GPIO bench: function, VOH / VOL, edge rate, delays, input thresholds and hysteresis, leakage and pull resistance of the drawn GPIO at `tt`, 27 C, nominal rails (no corner; not item-5 evidence) |
| `diode-probe` | G1 / ESD.3 | what do the GPIO pad diodes do at the ESD.2 current? (diode areas are unsized placeholders) |
| `diode-unit-probe` | G1 | what unit is the diode instance `area` / `perim` parameter in? measured at 27 C and 30 C |

## Record field conventions

Three rules for any new probe's record fields. The first two are violated by
`diode-unit-probe`, whose record predates them and is append-only — its README
carries the erratum:

- **R1 — a field name states the unit domain of the number it holds.** A card
  figure in its source domain and the same figure after the card's own
  pre-scaling are different numbers. Record the one you have, named for its
  domain: `cj_prescaled_F_per_um2` = `7.4079e-16` (F per um^2). Add a
  source-domain key only if it really holds the source figure:
  `cj_card_source_F_per_m2` = `7.4079e-4` (F per m^2). Never reuse a
  `_per_m2` / `_per_m` suffix for a per-um^2 / per-um number, and do not emit
  two keys for one figure. `scripts/ci/check_evidence_format.py` enforces the
  failure shape (equal-valued numeric siblings under one leading token with a
  unit-domain suffix on one of them); `diode-unit-probe` is grandfathered.
- **R2 — a free-text unit field is qualified.** A `units_comment` restating a
  model card's `; Units:` text must say those are **pre-conversion source**
  units, so it cannot contradict the record's own `conclusion`. (The
  `diode-unit-probe` record's bare `units_comment` asserts exactly the C2
  reading its `conclusion` refutes.)
- **R3 — a path key's separator is load-bearing.** A key counts as
  path-shaped only when the path word is the whole key or follows an
  underscore (`log`, `log_dir`, `out_file`); a bare-suffix spelling
  (`logdir`, `logfile`, `basedir`) is malformed by convention and
  **silently unchecked** — its value is never inspected, so a dangling or
  absolute path under it passes CI. The canonical full statement lives in
  the `check_evidence_format.py` bullet of `signoff/README.md`'s signoff
  CI-checks list and in that checker's module docstring.

## Smoke record (`pdk-smoke/record/`)

DC operating point and Id-Vgs sweep at `tt`, 27 C, of one NMOS and one PMOS from
the 1.8 V core family (`nfet_01v8`, `pfet_01v8`) and the thick-oxide family
(`nfet_g5v0d10v5`, `pfet_g5v0d10v5`). It shows the models load and converge. The
bias, W and L are arbitrary smoke values, not a device, supply or cell choice.
`record.json` names `pdk_revision` and the tool versions it ran under.
