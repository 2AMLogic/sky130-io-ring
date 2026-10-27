# signoff

| File | Role |
|---|---|
| `block-manifest.json` | Input to `klt signoff`: `block`, `kind`, and an `evidence` map. Cites the item-1 design-sources attestation (`evidence/item1.json`, from `design/attest-inventory.json`), the item-2 layout attestation (`evidence/layout-attestation.json`), the item-3 ring DRC report (`evidence/drc/ring.json`) and the item-9 testbench attestation (`evidence/item9.json`); paths are relative to the repo root where `klt` runs. Every other T1 row is `unmet` / `no_evidence`, which is the honest statement. |
| `attest/item9.json` | Attestation inventory for T1 item 9: the testbenches (`sim/pdk-smoke/run.sh`, `cold-start.sh`), the cold-start command and the PDK/tool pins (same values as `sim/pdk.json`, plus `klt`). |
| `evidence/item9.json` | Envelope produced by `klt signoff --attest 9`; never hand-written. It pins the inventory's hash and each listed file's hash. |
| `gen_drc_reports.py` | Runs `klt drc --deck sky130` on the ring and each cell stream in `layout/gds/` and writes the envelopes under `evidence/drc/`. |
| `evidence/drc/*.json` | `klt drc` envelopes, never hand-written: `ring.json` (cited for item 3) and one per cell stream beside it. |
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

## Regenerate the item-9 envelope

```sh
uvx --from "klayout-tools==0.8.0" klt signoff --attest 9 --inventory signoff/attest/item9.json -o signoff/evidence/item9.json
```

Needs the pinned PDK and ngspice (`sim/pdk.json`): it runs `sim/pdk-smoke/cold-start.sh` (one smoke run, about a minute) into a temporary directory. Then update the `content_hash` for item 9 in `block-manifest.json` (the inventory's `sha256`, printed as `inventory:`) and regenerate the record. `klt` 0.8.0 is the first release with `--attest`; CI's 0.7.0 pin did not have it, hence the bump. Any edit to the inventory, or to a listed file, requires re-attesting.

The cold start is declared `local_only`: CI's `--attest 9 --check` re-checks file presence and hashes and lists it as `[SKIP]`; it never re-runs the smoke. The committed `pass` comes from a local run. Item 9 grades that testbenches, a cold start and pins exist, not that any number is right; the smoke only shows the models load and converge.

## What CI checks (`.github/workflows/ci.yml`, no PDK, ngspice or klayout)

- `klt signoff --attest 9 --check`: the item-9 envelope still reproduces from the inventory and listed files (cold start skipped, see above).
- `scripts/ci/test_checkers.py`: the checkers reject seeded defects (run first).
- `scripts/ci/check_evidence_format.py`: `design/ layout/ sim/ measurements/ spec/` each have a README; every sim record (`sim/<experiment>/record{,s}/*.json`) has `kind`, `pdk_revision` (40-hex), `pdk_variant`, `runs`, and only repo-relative paths (keys such as `log`, `netlist`, `path`, `file`). Passes trivially with no records.
- `klt signoff --attest 1 --check` on the item-1 envelope (`--attest` needs klt >= 0.8.0, hence the pin): re-hashes every source and netlist in `design/attest-inventory.json`. The re-netlist freshness commands are `local_only`, so CI does not re-run xschem; they run locally via `design/regen.sh --check`.
- `klt drc --check` on every `evidence/drc/*.json`: the input stream and deck still hash as recorded (cheap mode; the DRC is not re-run, so a stale report after a stream edit fails).
- Re-grade with the pinned grader; `signoff-record.json` must match byte for byte.
- `layout/tests/test_ring.py` and `scripts/ci/check_layout_reproducible.py` (installs the pip `klayout` module, no PDK): the generator's spec/seam checks reject seeded defects, and a fresh regeneration of `layout/gds/` is byte-identical to what is committed and to the attestation's hashes.
- `scripts/ci/check_append_only.py` (pull requests): files under `sim/` may be added, not modified, deleted or renamed.

## What CI does not check

- That any number in a record is correct, or that a record was produced by a real run.
- LVS, simulation or ESD behaviour, or that a DRC report's rules are the right ones. T1 items 1, 2, 3 and 9 are `met`. Item 1 says schematics and freshness-checked netlists exist (CI does not re-netlist); item 2 says a stream exists and is reproducibly generated; item 3 is clean against the curated deck only (coverage above); item 9 says testbenches, a cold start and pins exist.
- Append-only on direct pushes to `main` (branch protection covers that), or records outside `sim/`.
- That the manifest's `evidence` is honest; the grader judges only what it cites.
