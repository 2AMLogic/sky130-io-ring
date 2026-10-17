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
| `pdk-smoke/run.sh` (driver skeleton) | mixed | the `devices` table and model names are sky130; netlist/record plumbing is not |
| `lib/pdk_env.sh` | sky130 | resolver: pin check, model-library path, corner file layout |
| `lib/test_pdk_env.sh` | sky130 | self-test of the resolver's refusal |
| `pdk.json` | sky130 | the pin and tool versions |

The port (`gf180-io-ring`) takes `lib/simrec.py` by pinned reference and supplies
its own `pdk.json`, `pdk_env.sh` and device table.

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

## Smoke record (`pdk-smoke/record/`)

DC operating point and Id-Vgs sweep at `tt`, 27 C, of one NMOS and one PMOS from
the 1.8 V core family (`nfet_01v8`, `pfet_01v8`) and the thick-oxide family
(`nfet_g5v0d10v5`, `pfet_g5v0d10v5`). It shows the models load and converge. The
bias, W and L are arbitrary smoke values, not a device, supply or cell choice.
`record.json` names `pdk_revision` and the tool versions it ran under.
