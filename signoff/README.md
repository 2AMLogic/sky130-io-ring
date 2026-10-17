# signoff

| File | Role |
|---|---|
| `block-manifest.json` | Input to `klt signoff`: `block`, `kind`, and an `evidence` map. Empty today, so every T1 row is `unmet` / `no_evidence`, which is the honest statement. |
| `signoff-record.json` | The verdict of record: the stdout of the pinned grader on the manifest. Never edited by hand. |

## Regenerate the record

```sh
uvx --from "klayout-tools==0.7.0" klt signoff --manifest signoff/block-manifest.json --format json > signoff/signoff-record.json
```

Redirect stdout; with 0.7.0 `-o` and `--repo-root` are not accepted. Exit code 3 (report produced, items unmet) is expected.

The grader version is pinned in one place: `KLT_VERSION` in `.github/workflows/ci.yml`. The record embeds `source_doc_content_hash` and `grading_ruleset_id`, which change with the pin, so **a pin bump must regenerate the record in the same PR** (update the version in the command above too). Adding evidence to the manifest likewise requires regenerating.

## What CI checks (`.github/workflows/ci.yml`, no PDK, ngspice or klayout)

- `scripts/ci/test_checkers.py`: the checkers reject seeded defects (run first).
- `scripts/ci/check_evidence_format.py`: `design/ layout/ sim/ measurements/ spec/` each have a README; every sim record (`sim/<experiment>/record{,s}/*.json`) has `kind`, `pdk_revision` (40-hex), `pdk_variant`, `runs`, and only repo-relative paths (keys such as `log`, `netlist`, `path`, `file`). Passes trivially with no records.
- Re-grade with the pinned grader; `signoff-record.json` must match byte for byte.
- `scripts/ci/check_append_only.py` (pull requests): files under `sim/` may be added, not modified, deleted or renamed.

## What CI does not check

- That any number in a record is correct, or that a record was produced by a real run.
- DRC, LVS, simulation or ESD behaviour. No T1 row is `met`.
- Append-only on direct pushes to `main` (branch protection covers that), or records outside `sim/`.
- That the manifest's `evidence` is honest; the grader judges only what it cites.
