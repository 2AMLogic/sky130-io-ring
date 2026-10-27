# layout

Generated, not hand-drawn. `gen_ring.py` (PDK-independent ring assembly, spec
readers, seam checks, stream writer) drives a tech module; `sky130_cells.py` is
the sky130 half (layer numbers, rail bands, cell geometry); `ringgeom.py` holds
the geometry primitives. Cell numbers are read from `spec/io-ring.json`
(CELL.2/3/4/5/6/7/8/9, LU.1), not duplicated. To port, replace the tech module.

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
| `sky130_ioring_gpio` | pad + placeholder pad-connected diffusions in closed guard annuli (`PAD`) |
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

## What is not claimed

- Drivers are placeholder diffusions with no gates, level shifter, clamp or ESD
  device. Nothing here is ESD-rated or qualified; ESD sizing is decision 0004.
- DRC, LVS and ERC have not been run (separate issues). The generator checks
  its own spec values and seam continuity, not foundry rules.
- The only layers, widths and spacings checked are the ones the spec states; the
  rest are unchecked drawing choices until a deck runs on them.
- The spec is proposed, not ratified; re-check the CELL rows when it is.
- No geometry is taken from `sky130_fd_io` (decision 0001).

## Self-checks (run on every generation)

Spec values (pitch, depth, rail width/layer, fillers, grid, 45-degree edges),
every edge cell's rails and strips span x = 0..width at the same y-extent,
instances tile the ring with no gap or overlap, each continuous conductor
covers an independently constructed closed ring, and the two guard annuli in the
GPIO are closed.
