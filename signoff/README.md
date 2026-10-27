# signoff

| File | Role |
|---|---|
| `block-manifest.json` | Input to `klt signoff`: `block`, `kind`, and an `evidence` map. Cites the item-2 layout attestation (`evidence/layout-attestation.json`) and the item-9 testbench attestation (`evidence/item9.json`); paths are relative to the repo root where `klt` runs. Every other T1 row is `unmet` / `no_evidence`, which is the honest statement. |
| `attest/item9.json` | Attestation inventory for T1 item 9: the testbenches (`sim/pdk-smoke/run.sh`, `cold-start.sh`), the cold-start command and the PDK/tool pins (same values as `sim/pdk.json`, plus `klt`). |
| `evidence/item9.json` | Envelope produced by `klt signoff --attest 9`; never hand-written. It pins the inventory's hash and each listed file's hash. |
| `signoff-record.json` | The verdict of record: the stdout of the pinned grader on the manifest. Never edited by hand. |

## Regenerate the record

```sh
uvx --from "klayout-tools==0.8.0" klt signoff --manifest signoff/block-manifest.json --format json > signoff/signoff-record.json
```

Redirect stdout (`-o` is only for `--attest`, below). Exit code 3 (report produced, items unmet) is expected.

The grader version is pinned in one place: `KLT_VERSION` in `.github/workflows/ci.yml`. The record embeds `source_doc_content_hash` and `grading_ruleset_id`, which change with the pin, so **a pin bump must regenerate the record in the same PR** (update the version in the command above too). Adding evidence to the manifest likewise requires regenerating.

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
- Re-grade with the pinned grader; `signoff-record.json` must match byte for byte.
- `layout/tests/test_ring.py` and `scripts/ci/check_layout_reproducible.py` (installs the pip `klayout` module, no PDK): the generator's spec/seam checks reject seeded defects, and a fresh regeneration of `layout/gds/` is byte-identical to what is committed and to the attestation's hashes.
- `scripts/ci/check_append_only.py` (pull requests): files under `sim/` may be added, not modified, deleted or renamed.

## What CI does not check

- That any number in a record is correct, or that a record was produced by a real run.
- DRC, LVS, simulation or ESD behaviour. T1 items 2 (layout) and 9 (testbenches shipped) are `met`; item 2 says a stream exists and is reproducibly generated, nothing about it being rule-clean.
- Append-only on direct pushes to `main` (branch protection covers that), or records outside `sim/`.
- That the manifest's `evidence` is honest; the grader judges only what it cites.
