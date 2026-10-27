# signoff

| File | Role |
|---|---|
| `block-manifest.json` | Input to `klt signoff`: `block`, `kind`, and an `evidence` map. Cites the item-1 design-sources attestation (`evidence/item1.json`, from `design/attest-inventory.json`), the item-2 layout attestation (`evidence/layout-attestation.json`), the item-3 ring DRC report (`evidence/drc/ring.json`), the item-9 testbench attestation (`evidence/item9.json`), the item-10 hygiene attestation (`evidence/item10.json`) and, unmet, the item-11 ERC report plus the `gpio` LVS report (see "Regenerate the ERC report"); paths are relative to the repo root where `klt` runs. Every other T1 row except 11 is `unmet` / `no_evidence`, which is the honest statement. |
| `attest/item9.json` | Attestation inventory for T1 item 9: the testbenches (`sim/pdk-smoke/run.sh`, `cold-start.sh`), the cold-start command and the PDK/tool pins (same values as `sim/pdk.json`, plus `klt`). |
| `evidence/item9.json` | Envelope produced by `klt signoff --attest 9`; never hand-written. It pins the inventory's hash and each listed file's hash. |
| `attest/item10.json` | Inventory for T1 item 10 (repo hygiene): `README.md`, `LICENSE`, `.github/workflows/ci.yml` must exist, and each listed PDK-free CI command must exit 0. |
| `evidence/item10.json` | The envelope `klt signoff --attest 10` produced from that inventory. Never hand-written; the grader refuses anything it did not produce. |
| `gen_drc_reports.py` | Runs `klt drc --deck sky130` on the ring and each cell stream in `layout/gds/` and writes the envelopes under `evidence/drc/`. |
| `evidence/drc/*.json` | `klt drc` envelopes, never hand-written: `ring.json` (cited for item 3) and one per cell stream beside it. |
| `gen_lvs_reports.py` | Runs `klt lvs` (sky130 deck, `reference.form: "subckt-call"`) on each stream in `layout/gds/` against `design/netlists/<cell>.spice` and writes the reports under `evidence/lvs/`. |
| `evidence/lvs/*.json` | `klt lvs --format json` reports, never hand-written. Only the cells `klt lvs` accepted have one (table below); the ring, `vddio` and `vdd` have none. |
| `erc-supply-spec.json` | The `klt erc` supply spec for the assembled ring: `VDDIO`, `VDD`, `VSS` as `"kind": "supply"` nets, a poly-li1-met5 stackup with labels on met3/met4/met5, and two checked `ties[]` (n+ tap in n-well on VDDIO, p+ tap in the substrate on VSS). `VDDIO` and `VDD` declare `roles` (met4, met3) so a severed rail shows as unlabelled conductor. `VSS` does not: met5 also carries the pad metal. |
| `gen_erc_report.py` | Runs `klt erc --findings-only` on the ring and writes `evidence/erc/ring.json`; `--negative` also writes `evidence/erc/ring-negative.json` from a scratch copy cut in two places. |
| `evidence/erc/*.json` | `klt erc` reports, never hand-written: `ring.json` (cited for item 11) and `ring-negative.json` (the same spec on a ring cut at two opposite sides, which must fail). |
| `signoff-record.json` | The verdict of record: the stdout of the pinned grader on the manifest. Never edited by hand. |

## Regenerate the record

```sh
uvx --from "klayout-tools==0.8.0" klt signoff --manifest signoff/block-manifest.json --format json > signoff/signoff-record.json
```

Redirect stdout (`-o` is only for `--attest`, below; `--repo-root` is not used here). Exit code 3 (report produced, items unmet) is expected.

The grader version is pinned in one place: `KLT_VERSION` in `.github/workflows/ci.yml`. The record embeds `source_doc_content_hash` and `grading_ruleset_id`, which change with the pin, so **a pin bump must regenerate the record in the same PR** (update the version in the command above too). Adding evidence to the manifest likewise requires regenerating.

## Regenerate the DRC reports (item 3)

```sh
python3 signoff/gen_drc_reports.py --klt "uvx --from klayout-tools==0.8.0 klt"
```

No PDK or standalone klayout is needed (curated deck). Exit 4 means a report is not clean; it is still written. If `ring.json` changes, update the item-3 `content_hash` in `block-manifest.json` (the input stream hash, equal to the item-2 hash) and regenerate the record. The manifest holds one file per item, so only `ring.json` is cited; the per-cell reports sit beside it.

What item 3 claims: the closed ring stream is clean against the curated `sky130` deck's modeled rules (`deck_scope` in the report), on **placeholder** drawing, with the spec still proposed (the CELL rows are re-checked on ratification). `coverage.layers_in_stream_without_rules` is `70/5`, `71/5`, `72/5`; `coverage.rules_skipped` is 57 rule ids, all `no_applicable_geometry`; `deck_scope` is 23 layers/groups (m1-m5, via-via4, nwell, difftap, poly, licon, li, npc, nsdm, psdm, capm, cap2m, rpm, urpm, ct, x); deck hash `sha256:ba0f9788...942e6`. It does **not** claim thick-oxide, latch-up, guard-ring-construction or ESD compliance: the deck does not check them (`spec/klt-rule-coverage.md`, "Reconciliation").

Known per-cell finding, not waived: `sky130_ioring_fill_1.json` is `violations` (one `met5.width.1`): checked alone, the 1 µm filler's met5 rail segment is 1 µm wide in the short direction. The placed ring is clean. The generator cannot widen it without overlapping neighbours (CELL.8); tool gap filed as 2AMLogic/klayout-tools#4226; left for spec review rather than relaxed here.

## Regenerate the LVS reports (item 4)

```sh
python3 signoff/gen_lvs_reports.py --klt "uvx --from klayout-tools==0.8.0 klt"
for f in signoff/evidence/lvs/*.json; do uvx --from klayout-tools==0.8.0 klt lvs --check "$f"; done
```

No hints, tolerances, `device_map` or ignored devices are passed. Exit 4: a report is `mismatch` (still written). Exit 5: `klt lvs` refused a request, so no report exists for that cell (the refusal is printed).

| Cell | `status` | `power_connectivity` | Note |
|---|---|---|---|
| `corner`, `fill_1`, `fill_5`, `fill_10`, `fill_20`, `vss` | `match` | `unchecked` | Vacuous: schematic and layout both have zero devices; the layout has 1 net against 3 reference pins, and the pins were paired by the comparer (a `warning`, "paired ambiguously"). This shows the flow runs, not that supply wiring is right. |
| `gpio` | `mismatch` | `unchecked` | 20 errors. The layout has 0 devices (placeholder diffusions, `layout/README.md`); the reference has devices. The reference's four diode cards are also `reference.unresolved_subckt_call` (2AMLogic/klayout-tools#4319), and the resistor `L`/`W`/`A`/`P` are not compared (`device.geometry_not_compared`). |
| `vddio`, `vdd`, `ring` | no report | n/a | `klt lvs` refuses the reference: `sky130_fd_pr__cap_mim_m3_1` with `m=2` cannot be converted (2AMLogic/klayout-tools#4318). The netlist was not edited to get past it. |

Item 4 stays `unmet`: the ring has no report, and `gpio` is `mismatch`. Item 4 adds nothing to the manifest. `net_correspondence` for VDDIO/VDD/VSS (needed by item 11) does not exist yet.

## Regenerate the ERC report (item 11)

```sh
python3 signoff/gen_erc_report.py --klt "uvx --from klayout-tools==0.8.0 klt" --negative
uvx --from klayout-tools==0.8.0 klt erc --check signoff/evidence/erc/ring.json
```

`--negative` needs the pip `klayout` module. Exit 4: the ring has findings, or the cut ring was not reported as split.

Result: `erc_status` `clean`, one island each for `VDDIO`, `VDD` and `VSS`, no `erc.unconnected_net` / `erc.supply_short` / `erc.missing_tie`, both ties `checked`, unlabelled conductor 0 on met4 and met3. The cut copy (2 um slab through every stackup conductor at the south and north edges) splits all three supplies into two islands each. Cutting only the rails does **not** split `VDDIO` or `VSS`: the guard strips on li1 carry them around the ring too, so the rails are redundantly continuous. `--findings-only` skips antenna accumulation (the ring has no gates), so the envelope's `status` is `not_checked`; `erc_status` is the verdict. `layers_in_stream_without_declaration` is `65/20` (diff), `76/20` (pad), `93/44` (nsdm) and `94/20` (psdm); the spec declares none of them as conductors.

What this shows: the generator's **placeholder** rails and strips are connected through the abutment seams. It says nothing about final geometry, ESD or IR drop.

Item 11 stays `unmet`. It is a compound item (`klt signoff` needs an `erc` part and an `lvs` part), and the ring has no LVS report (2AMLogic/klayout-tools#4318), so item 4 cannot be `met`. The manifest cites the ERC report plus the only LVS report that exists for a supply-carrying cell, `gpio` (`mismatch`), so the grader renders `lvs_did_not_pass` and records the supplies the ERC run covered (`detail.power_delivery.supply_nets`), instead of `wrong_kind` for a lone ERC part. That `gpio` report is not the ring's LVS and is cited only to reach that reason. Swap it for the ring report once #4318 is fixed and the compare matches. Related tool gap: 2AMLogic/klayout-tools#4193.

## Regenerate the item-9 envelope

```sh
uvx --from "klayout-tools==0.8.0" klt signoff --attest 9 --inventory signoff/attest/item9.json -o signoff/evidence/item9.json
```

Needs the pinned PDK and ngspice (`sim/pdk.json`): it runs `sim/pdk-smoke/cold-start.sh` (one smoke run, about a minute) into a temporary directory. Then update the `content_hash` for item 9 in `block-manifest.json` (the inventory's `sha256`, printed as `inventory:`) and regenerate the record. `klt` 0.8.0 is the first release with `--attest`; CI's 0.7.0 pin did not have it, hence the bump. Any edit to the inventory, or to a listed file, requires re-attesting.

The cold start is declared `local_only`: CI's `--attest 9 --check` re-checks file presence and hashes and lists it as `[SKIP]`; it never re-runs the smoke. The committed `pass` comes from a local run. Item 9 grades that testbenches, a cold start and pins exist, not that any number is right; the smoke only shows the models load and converge.

## Re-attest item 10

```sh
uvx --from "klayout-tools==0.8.0" klt signoff --attest 10 --inventory signoff/attest/item10.json -o signoff/evidence/item10.json
```

Then copy the envelope's `provenance.input.content_hash` into the `10` entry of `block-manifest.json` and regenerate the record (above). The envelope pins the raw-byte hash of `README.md`, `LICENSE` and `.github/workflows/ci.yml`, so **any later edit to those files is drift and fails CI's `--check`** (exit 3) until you re-attest. Make all edits to them first, attest last. Do not list the signoff freshness step or the `--attest --check` step itself in the inventory (circular).

The pin moved 0.7.0 -> 0.8.0 because `--attest` first ships in 0.8.0; the record was regenerated with it in the same change.

## What CI checks (`.github/workflows/ci.yml`, no PDK, ngspice or klayout)

- `klt signoff --attest 9 --check`: the item-9 envelope still reproduces from the inventory and listed files (cold start skipped, see above).
- `scripts/ci/test_checkers.py`: the checkers reject seeded defects (run first).
- `scripts/ci/check_evidence_format.py`: `design/ layout/ sim/ measurements/ spec/` each have a README; every sim record (`sim/<experiment>/record{,s}/*.json`) has `kind`, `pdk_revision` (40-hex), `pdk_variant`, `runs`, and only repo-relative paths (keys such as `log`, `netlist`, `path`, `file`). Passes trivially with no records.
- `klt signoff --attest 1 --check` on the item-1 envelope (`--attest` needs klt >= 0.8.0, hence the pin): re-hashes every source and netlist in `design/attest-inventory.json`. The re-netlist freshness commands are `local_only`, so CI does not re-run xschem; they run locally via `design/regen.sh --check`.
- `klt drc --check` on every `evidence/drc/*.json`: the input stream and deck still hash as recorded (cheap mode; the DRC is not re-run, so a stale report after a stream edit fails).
- Re-grade with the pinned grader; `signoff-record.json` must match byte for byte.
- `layout/tests/test_ring.py` and `scripts/ci/check_layout_reproducible.py` (installs the pip `klayout` module, no PDK): the generator's spec/seam checks reject seeded defects, and a fresh regeneration of `layout/gds/` is byte-identical to what is committed and to the attestation's hashes.
- Item-10 attestation: `klt signoff --attest 10 --inventory signoff/attest/item10.json --check signoff/evidence/item10.json` must match (the hygiene files are unchanged since attested and the inventory's commands exit 0).
- `scripts/ci/check_append_only.py` (pull requests): files under `sim/` may be added, not modified, deleted or renamed.

## What CI does not check

- That any number in a record is correct, or that a record was produced by a real run.
- LVS, simulation or ESD behaviour, or that a DRC report's rules are the right ones. T1 items 1, 2, 3, 9 and 10 are `met`. Item 1 says schematics and freshness-checked netlists exist (CI does not re-netlist); item 2 says a stream exists and is reproducibly generated; item 3 is clean against the curated deck only (coverage above); item 9 says testbenches, a cold start and pins exist; item 10 says the README, license and CI exist and their commands run.
- Append-only on direct pushes to `main` (branch protection covers that), or records outside `sim/`.
- That the manifest's `evidence` is honest; the grader judges only what it cites.
