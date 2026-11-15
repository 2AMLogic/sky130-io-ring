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

Each probe directory carries a `README.md` (what and why), a `run.sh`
(reproduce) and a `record/` with the append-only evidence (`record.json` plus
the logs and netlists that back it). All records are single-corner `kind:
probe` runs unless the row says otherwise; none is item-5 evidence.

| Probe | Gate | Question |
|---|---|---|
| `pdk-smoke` | — | do the pinned models load and converge? DC op + Id-Vgs of the 1.8 V core and 5 V thick-oxide families |
| `clamp-probe` | G6 | do the RC supply clamps turn on? `clamp_io` (ESD.4, 5 V) and `clamp_core` (ESD.5, 1.8 V), power-up ramps + HBM pulses |
| `corner-skew-probe` | G2 | does the sky130 skew set (`ff ss sf fs`) move the 5 V thick-oxide devices, or only the 1.8 V core? |
| `diode-probe` | G1 / ESD.3 | what do the GPIO pad diodes do at the ESD.2 current? (diode areas are unsized placeholders) |
| `diode-unit-probe` | G1 | what unit is the diode instance `area` / `perim` parameter in? measured at 27 C and 30 C |

## Smoke record (`pdk-smoke/record/`)

DC operating point and Id-Vgs sweep at `tt`, 27 C, of one NMOS and one PMOS from
the 1.8 V core family (`nfet_01v8`, `pfet_01v8`) and the thick-oxide family
(`nfet_g5v0d10v5`, `pfet_g5v0d10v5`). It shows the models load and converge. The
bias, W and L are arbitrary smoke values, not a device, supply or cell choice.
`record.json` names `pdk_revision` and the tool versions it ran under.
