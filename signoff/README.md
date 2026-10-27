# signoff

| File | Role |
|---|---|
| `block-manifest.json` | Input to `klt signoff`: `block`, `kind`, and an `evidence` map. Cites the item-2 layout attestation (`evidence/layout-attestation.json`) and the item-10 hygiene attestation (`evidence/item10.json`), paths relative to the repo root where `klt` runs; every other T1 row is `unmet` / `no_evidence`, which is the honest statement. |
| `attest/item10.json` | Inventory for T1 item 10 (repo hygiene): `README.md`, `LICENSE`, `.github/workflows/ci.yml` must exist, and each listed PDK-free CI command must exit 0. |
| `evidence/item10.json` | The envelope `klt signoff --attest 10` produced from that inventory. Never hand-written; the grader refuses anything it did not produce. |
| `signoff-record.json` | The verdict of record: the stdout of the pinned grader on the manifest. Never edited by hand. |

## Regenerate the record

```sh
uvx --from "klayout-tools==0.8.0" klt signoff --manifest signoff/block-manifest.json --format json > signoff/signoff-record.json
```

Redirect stdout; with `--manifest`, `-o` is not accepted (it applies only to `--attest`). Exit code 3 (report produced, items unmet) is expected.

The grader version is pinned in one place: `KLT_VERSION` in `.github/workflows/ci.yml`. The record embeds `source_doc_content_hash` and `grading_ruleset_id`, which change with the pin, so **a pin bump must regenerate the record in the same PR** (update the version in the command above too). Adding evidence to the manifest likewise requires regenerating.

## Re-attest item 10

```sh
uvx --from "klayout-tools==0.8.0" klt signoff --attest 10 --inventory signoff/attest/item10.json -o signoff/evidence/item10.json
```

Then copy the envelope's `provenance.input.content_hash` into the `10` entry of `block-manifest.json` and regenerate the record (above). The envelope pins the raw-byte hash of `README.md`, `LICENSE` and `.github/workflows/ci.yml`, so **any later edit to those files is drift and fails CI's `--check`** (exit 3) until you re-attest. Make all edits to them first, attest last. Do not list the signoff freshness step or the `--attest --check` step itself in the inventory (circular).

The pin moved 0.7.0 -> 0.8.0 because `--attest` first ships in 0.8.0; the record was regenerated with it in the same change.

## What CI checks (`.github/workflows/ci.yml`, no PDK, ngspice or klayout)

- `scripts/ci/test_checkers.py`: the checkers reject seeded defects (run first).
- `scripts/ci/check_evidence_format.py`: `design/ layout/ sim/ measurements/ spec/` each have a README; every sim record (`sim/<experiment>/record{,s}/*.json`) has `kind`, `pdk_revision` (40-hex), `pdk_variant`, `runs`, and only repo-relative paths (keys such as `log`, `netlist`, `path`, `file`). Passes trivially with no records.
- Re-grade with the pinned grader; `signoff-record.json` must match byte for byte.
- `layout/tests/test_ring.py` and `scripts/ci/check_layout_reproducible.py` (installs the pip `klayout` module, no PDK): the generator's spec/seam checks reject seeded defects, and a fresh regeneration of `layout/gds/` is byte-identical to what is committed and to the attestation's hashes.
- Item-10 attestation: `klt signoff --attest 10 --inventory signoff/attest/item10.json --check signoff/evidence/item10.json` must match (the hygiene files are unchanged since attested and the inventory's commands exit 0).
- `scripts/ci/check_append_only.py` (pull requests): files under `sim/` may be added, not modified, deleted or renamed.

## What CI does not check

- That any number in a record is correct, or that a record was produced by a real run.
- DRC, LVS, simulation or ESD behaviour. Only T1 items 2 and 10 are `met`: item 2 says a stream exists and is reproducibly generated, nothing about it being rule-clean; item 10 says the README, license and CI exist and their commands run.
- Append-only on direct pushes to `main` (branch protection covers that), or records outside `sim/`.
- That the manifest's `evidence` is honest; the grader judges only what it cites.
