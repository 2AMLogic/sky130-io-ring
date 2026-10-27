# layout

Generated, not hand-drawn. The PDK-independent half names no layer and no
rule: `gen_ring.py` (ring assembly, spec readers, seam checks, stream writer),
`ringgeom.py` (geometry primitives), `netlist_read.py` (reads the committed
`design/netlists/*.spice`) and `chanroute.py` (single-channel router). The
sky130 half is `sky130_cells.py` (layer numbers, rail bands, edge cells, the
GPIO core and its connection to rails and pad), `sky130_blocks.py` (turns a
`.subckt` into a cell of wired devices) and `sky130_devices.py` (MOS fingers,
taps, diodes, poly resistor). Cell numbers are read from `spec/io-ring.json`
(CELL.2/3/4/5/6/7/8/9, LU.1), device sizes from the netlists; neither is
duplicated. To port, replace the `sky130_*` modules.

```sh
pip install klayout==0.30.10          # no PDK needed
python3 layout/gen_ring.py --attest signoff/evidence/layout-attestation.json
python3 layout/tests/test_ring.py     # seeded-defect tests
python3 scripts/ci/check_layout_reproducible.py .
```

After regenerating, update the `content_hash` for item 2 in
`signoff/block-manifest.json` and regenerate `signoff/signoff-record.json`
(`signoff/README.md`).

## Streams (`gds/`)

Written without timestamps, so output is byte-identical across runs.

| Cell | Role |
|---|---|
| `sky130_ioring_gpio` | pad (`PAD`) and every device of the GPIO netlists, wired: 106 MOS fingers, 4 junction diodes, 1 poly resistor (see below) |
| `sky130_ioring_vddio`, `_vdd`, `_vss` | supply pads tied to their rail (net labels `VDDIO`, `VDD`, `VSS`) |
| `sky130_ioring_corner` | square corner, edge = cell depth, rails and strips turn 90 degrees with 45-degree chamfer/mitre, no pad |
| `sky130_ioring_fill_{1,5,10,20}` | rails and guard strips only |
| `sky130_ioring_ring` | closed ring: 4 corners + 4 identical sides (five pad cells, 37 um of filler) |

Pin/net names (`PAD`, `VSS`, `VDDIO`, `VDD`) are labels on met5/met4/met3 label
purposes and are the inputs to DRC/LVS/ERC; keep them stable.

## What is drawn (die edge at y = 0, local frame of an edge cell)

- Pitch 80 um, depth 195 um (spec: 80, <= 200). Rails 12 um wide: VSS met5 at
  10-22, VDDIO met4 at 30-42, VDD met3 at 50-62 um from the die edge (layers
  from CELL.5), identical in every cell.
- Continuous guard strips on every edge cell and around the corners: p+ tap
  strip (VSS) and n-well with n+ tap strip (VDDIO). Pad cells tie them to the
  rails by via stacks.
- Bond pad: 55 um opening on `pad`, met5 metal 61 um. 55 um is the provisional
  minimum (CELL.4 is OPEN).

## GPIO devices

`sky130_ioring_gpio` instantiates `sky130_ioring_gpio_core`, which holds the
sub-blocks of `design/netlists/sky130_ioring_gpio.spice` in two assemblies of
two rows each (`gpio_asm_a`: logic, pull network, three level shifters;
`gpio_asm_b`: fourth level shifter, receiver, driver, ESD diodes and resistor).
Each sub-block is its own cell (`gpio_logic`, `gpio_ls`, `gpio_drv`,
`gpio_pulls`, `gpio_esd`, `gpio_rcv`) with the called `inv` / `nand2` / `nand3` /
`nor2` drawn inline.

| Netlist devices | Drawn as |
|---|---|
| `nfet_01v8`, `pfet_01v8`, `nfet_g5v0d10v5`, `pfet_g5v0d10v5` (`m` = `m` fingers) | one poly gate per finger at the netlist W and L over shared diffusion strips; 52 n + 54 p fingers, of which 31 n + 33 p are thick-oxide (`hvi`) |
| `diode_pd2nw_05v5`, `diode_pw2nd_05v5` | rectangular diff at the netlist `area` / `perim` (200 um2 / 60 um and 10 um2 / 14 um) under the diode marker; p+ in an n-well, n+ in the substrate |
| `res_high_po_1p41` | 1.41 um poly strip, L = 1.0 um under the resistor marker and `rpm`, contacted at both ends |

- Every p group sits in its own n-well, tied by n+ taps; a thick-oxide well is
  enclosed by `hvi`, and the VDDIO and VDD wells are separate. Substrate taps
  tie the n groups to VSS.
- LU.1: the 10 driver NMOS fingers sit inside a closed p+ tap annulus (VSS) and
  the 20 driver PMOS fingers inside a closed n+ tap annulus (VDDIO) in their
  own well. No other device has a ring.
- Wiring: li1 / mcon / met1 inside devices, met2 tracks, met3 pins and drops.
  VSS, VDDIO and VDD leave the core on met2 spines at x = 2, 6, 10 um; VSS joins
  the existing tie stack, VDDIO and VDD get a stack on their rail. `PAD` goes
  through a stack on the core's pad track and a met5 strap to the pad metal.
  Rails and pad are named by labels (`VSS`, `VDDIO`, `VDD`, `PAD`), the six
  signal pins by labels on their tracks.
- Bank widths and strap widths are layout choices, not sized for ESD current.

## What is not claimed

- Nothing here is ESD-rated or qualified. The diodes and the resistor are the
  netlist's, drawn at its area / perimeter; no clamp is drawn (the supply clamp
  is a separate issue) and ESD sizing is decision 0004.
- DRC passes the curated `sky130` deck (`signoff/README.md`); that deck has
  no rule for thick-oxide drawing beyond `nwell.enclosed.hvi.1` (the report's
  `voltage_domain_warnings`), none for latch-up, tap spacing or guard-ring
  construction. `klt tap-distance` on `sky130_ioring_gpio.gds` fails the LU.2
  target: worst n-diff to p-tap 22.7 um and worst p-diff to n-tap per well
  22.7 um (target 10 um, foundry figure 15 um), because taps sit at group ends
  only. LU.4 holds for the driver NMOS only: the pull-down NMOS and the n+
  ESD diode on the pad have no ring. Both are tracked in #53.
- LVS of this cell is `mismatch` only because `klt lvs` cannot read the
  reference's four diode cards (2AMLogic/klayout-tools#4319); all 107 other
  reference devices match. ERC has not been run. The comparison is flat
  (`signoff/README.md`).
- Metal and via widths, current density and electromigration are not
  checked; parasitics are not extracted.
- The spec is proposed, not ratified; re-check the CELL rows when it is.
- No geometry is taken from `sky130_fd_io` (decision 0001).

## Self-checks (run on every generation)

Spec values (pitch, depth, rail width/layer, fillers, grid, 45-degree edges),
every edge cell's rails and strips span x = 0..width at the same y-extent,
instances tile the ring with no gap or overlap, each continuous conductor
covers an independently constructed closed ring, the two guard annuli in the
GPIO are closed, and the drawn GPIO devices equal the netlists': each MOS
finger's kind, oxide, W and L, each diode's kind and area, and the resistor's
L, read back from the geometry and compared with `design/netlists/`.
