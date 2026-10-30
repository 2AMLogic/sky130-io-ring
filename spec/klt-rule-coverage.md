# klt rule coverage for the I/O rule classes (sky130)

Answers the first open question of issue #2: which I/O-specific rules does
klt's sky130 deck check today? A rule class listed "not checked" is a
friction item filed upstream, not a rule to ignore; signoff reports it as
"not checked", never "clean" (SIGN.1).

**Inspected**: klt `0.7.1.dev1765+gb61f753d0369`; sky130 curated deck content
hash `sha256:f3e6a304b5d7e02301b14643fab17e3a455e145b4ba684dc66b645c2016e5865`;
PDK sky130A, open_pdks `f6eeac7d`. Single local, read-only runs; no layout was
checked. The curated deck is `klt drc --deck sky130` (default engine); the
other engine, `klt drc --engine klayout`, runs the PDK's own KLayout deck
(`libs.tech/klayout/drc/sky130A_mr.drc`).

## Re-inspection 2026-10-22

Same open_pdks `f6eeac7d`; klt `0.7.1.dev2419+ga7dfbc5ce95d`; sky130 extraction
deck hash `sha256:ba0f97887e3d231aec8b54f1f52f2941ded0228f0234b6759712bcaca0e942e6`
(the survey below used the earlier hash). The deck is still marked
`released: False`. What changed, from `klt deck info` and `klt deck devices`:

- Diodes: the extraction deck now lists `diode_pw2nd_05v5`, `_lvt`, `_nvt`,
  `_11v0` and `diode_pd2nw_05v5`, `_lvt`, `_hvt`, `_11v0`. The "Protection diodes
  in LVS" row below is historical; #3803 is closed (klayout-tools PR #3863).
  Devices flagged ESD (`areaid.ed`) are excluded from diode recognition by
  design, so an ESD-marked clamp device is a separate question (not examined).
- Marker-layer rules: `klt deck info` now prints a "NOT ENFORCED" list for sky130
  that includes `hvi.1`, `hvi.2a`, `hvntm.1`, `hvntm.2`, `hvtp.1`, `hvtp.2`,
  `hvtr.1`, `hvtr.2`, `pad.2` and `rdl.1/.2`; #3802 is closed by that disclosure
  (PR #3848), not by adding the checks. The curated deck's thick-oxide coverage is
  unchanged: still `nwell.enclosed.hvi.1` plus grid / angle rules.
- Rail continuity: documented as a `klt erc` nets/ties recipe (PR #3846); no new
  verb. Not exercised here (no layout yet).
- Latch-up and ESD: still no rule in either deck. klt's own docs now say the open
  `sky130A_mr.drc` defines none.
- New evidence for the latch-up row: the PDK's *Magic* tech file
  (`libs.tech/magic/sky130A.tech`) transcribes SkyWater tap-distance rules LU.2,
  LU.2.1 and LU.3 at 15 µm (6 µm where the chip-top latch-up marker is absent).
  That is a checker klt does not run; `klt tap-distance` can enforce 15 µm only if
  the caller supplies the figure (see `review-2026-10.md`, gate G4).

## How the numbers were obtained

```
klt deck rules --deck sky130 --format json     # 150 rules, 75 after dropping ongrid / angle rules
klt deck devices --deck sky130                 # device classes recognised for extraction / LVS
klt deck info                                  # same class list, release status
klt pdk corners --pdk sky130A                  # model-library corner names
klt ring-check --help ; klt tap-distance --help; klt erc --help
# native deck rule ids: the output(...) names in sky130A_mr.drc (178 unique ids)
```

## Coverage by rule class

| Class | Curated deck (`--engine curated`) | Native deck (`--engine klayout`) | Other klt command | Verdict | Upstream |
|---|---|---|---|---|---|
| Thick-oxide / high-voltage layers (hvi, hvntm, vhvi, uhvi) | Only `nwell.enclosed.hvi.1` (the HV n-well must sit inside the hvi marker); `hvi`, `hvntm`, `vhvi`, `uhvi` and `pad` carry only grid and angle rules | `hvi.1`, `hvi.2a`, `hvntm.1`, `hvntm.2`, `hvtp.*`, `hvtr.*`, `dnwell.1`, `dnwell.2`, `nwell.9`, `pad.2` | none | **Partly checked.** Width / spacing of the thick-oxide marker layers only via the native engine, which needs a standalone `klayout` binary | [klayout-tools#3802](https://github.com/2AMLogic/klayout-tools/issues/3802) |
| Latch-up distance (tap spacing) | No rule | No rule (no id contains latch / tap distance) | `klt tap-distance` computes a distance for a caller-supplied value | **Not checked by any deck.** The command exists; the foundry value is not in the deck. LU.2 / LU.3 use interim internal values | #3802 |
| Guard ring | No rule | No rule | `klt ring-check` asserts a layer set forms a single closed annulus (geometry only; no net or construction check) | **Checkable for closure only.** Construction (p+ ring on VSS, n+ ring on VDDIO) is not verified | #3802 |
| ESD (implant / marker / device rules) | No rule | No rule (no id contains esd) | none | **Not checked.** SIGN.5 reads "not checked" | #3802 |
| Protection diodes in LVS | (Original survey; superseded, see re-inspection above.) No diode class: classes are nfet, pfet, pnp, two MiM caps and eight resistor kinds | n/a | `klt extract` / `klt lvs` use the curated classes | **Not extracted.** A protection network would be missing from the extracted netlist | [klayout-tools#3803](https://github.com/2AMLogic/klayout-tools/issues/3803) |
| Ring continuity (rail through every abutment, no floating well) | n/a | n/a | `klt erc` is an antenna / connectivity-ratio check; `klt components` reports connected components but takes no expected nets and returns no pass / fail | **Not checked directly.** SIGN.4's interim method composes `klt components` and `klt tap-distance` | [klayout-tools#3804](https://github.com/2AMLogic/klayout-tools/issues/3804) |

The same two gaps exist for the `gf180mcu` deck and are already tracked
upstream (#3792, #3793); the sky130 reports are separate issues because the
decks and rule ids differ.

## What this means for the spec

- DRC "clean" (SIGN.1) means clean against the rules in the pinned deck. For
  the I/O classes above it says nothing about latch-up distance or ESD.
- The two latch-up distances in LU.2 / LU.3 are interim and flagged as such in
  the spec; they are replaced when the foundry figure is pinned.
- Corner names: `klt pdk corners --pdk sky130A` shows `tt ff ss sf fs` present,
  with `ff ss sf fs` marked "complete: no" (MOS-only skew); see decision 0003.

## Not checked in this survey

- Whether the curated deck's width / spacing rules for the thick-oxide
  devices' diffusion and poly match the 5 V device rules (the deck has one
  `diff.width.1` row; whether the 5 V device uses a different value was not
  examined).
- The native deck was read, not run: no layout exists yet.

## Reconciliation with the first committed DRC report (2026-10-27)

Source: `signoff/evidence/drc/ring.json`, `klt drc --deck sky130` by `klt`
0.8.0 on `layout/gds/sky130_ioring_ring.gds` (input
`sha256:e8e7ba2fc8680905f043a42b5bea053a5e4c03102ae086ba11e341917415089d`).
Deck `sky130`, `sha256:ba0f97887e3d231aec8b54f1f52f2941ded0228f0234b6759712bcaca0e942e6`,
`released: true` (the `released: False` above is older than this deck).
`status: clean`, `violation_count: 0`. The layout is placeholder drawing (no
gates, clamp or level shifter), so this is clean on rails, pad openings and
guard-ring geometry only.

Quoted from the report's `coverage` block:

- `layers_in_stream_without_rules` (3): `70/5`, `71/5`, `72/5` (in the stream, no rule applies).
- `rules_skipped` (57, all `no_applicable_geometry`): 57 rule ids including
  `nwell.enclosed.hvi.1`, the `hvi` / `hvntm` / `hvtp` / `hvtr` / `vhvi` / `uhvi`
  `.angle.1` and `.ongrid.1` rules, `poly.*`, `npc.*`, `capm*`, `rpm.*`.
- `deck_scope` (23): `cap2m capm ct difftap li licon m1 m2 m3 m4 m5 npc nsdm nwell poly psdm rpm urpm via via2 via3 via4 x`.
- `unmodeled_rules` (33) include `hvi.1`, `hvi.2a`, `hvntm.1/2`, `hvtp.1/2`, `hvtr.1/2`, `pad.2`, `rdl.1/2`.

Against the classes above:

| Class | Effect of the clean report |
|---|---|
| Thick-oxide / high-voltage layers | **Still not checked.** `nwell.enclosed.hvi.1` was skipped (no geometry) and `hvi.1`, `hvi.2a`, `hvntm.*`, `hvtp.*`, `hvtr.*` are unmodeled. |
| Latch-up distance | **Still not checked.** No rule in the deck. |
| Guard ring | **Not checked for construction.** Only the metal / diffusion rules in `deck_scope` apply. |
| ESD | **Still not checked.** |
| Metal width / spacing on met3-met5 | Checked (`m3`, `m4`, `m5` in `deck_scope`). |

The per-cell reports are standalone checks of each stream, except
`sky130_ioring_fill_1`, which is checked with `klt drc --tile 3x1` (abutment
context, klayout-tools#4253). Checked alone it reported one `met5.width.1`
(the 12 µm-wide rail is 1 µm long); judged among identical neighbours, as it is
placed, it is clean. Placed in the ring it was already clean. No waiver and no
spec change; the tiled report comes from a klt build on `main` after 0.8.0, see
`signoff/README.md`.

