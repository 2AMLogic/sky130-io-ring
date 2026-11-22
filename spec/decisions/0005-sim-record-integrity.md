# 0005 — Simulation evidence integrity: records are append-only, harness scripts are hash-pinned

- **Status**: proposed; ratification pending (human). Ratified by: _unrecorded_.
- **Date**: 2026-11-19
- **Rows**: SIGN.6, section 8 of `io-ring.md` (results are append-only).
- **Review**: EE-key review (`ratification/ee-key/`): _not yet recorded_.
  Market-key review (`ratification/market-key/`): _not yet recorded_.
  Operator disposition: _not yet recorded_.

## Context

SIGN.6 requires that every signoff result records the PDK build, the klt
version and the deck content hash, and that results are append-only. The CI
append-only gate (`scripts/ci/check_append_only.py`) first protected all of
`sim/`, so even a behaviour-neutral fix to a harness script could not land on
a pull request. On 2026-11-18 the operator ruled (option (a), `/fleet:decide`
round 20261118-r16, recorded on issue #100) that the guard narrows to
records. PR #125 shipped the narrowed guard and its regression tests. This
record is the decision record that ruling asked for.

## Decision

- **Committed simulation records are append-only, with no exception.** A
  record is a file under `sim/<experiment>/record/` or `sim/<experiment>/records/`
  (`record{,s}/`), including its netlists and logs. Adding one is allowed;
  modifying, deleting or renaming one fails CI.
- **Harness scripts, shared libraries, READMEs and the PDK pin under `sim/`
  are not records** and may be edited in a pull request.
- **Script integrity is carried by the item-9 hash pin, not the append-only
  gate.** `signoff/attest/item9.json` lists `sim/pdk-smoke/run.sh`,
  `sim/pdk-smoke/cold-start.sh` and `sim/clamp-probe/run.sh`;
  `signoff/evidence/item9.json` pins their raw-byte hashes, and CI's
  `klt signoff --attest 9 --check` fails on any drift. Any edit to a listed
  script therefore requires re-attesting item 9 in the same PR, which re-runs
  the cold start locally (the cold start is `local_only`; CI re-checks hashes
  only).
- A cleanup that leaves the emitted netlist byte-identical to the committed
  record needs no re-run of any recorded simulation. The first such change is
  the removal of the shadowed `node()` definition and unused locals in
  `sim/clamp-probe/run.sh`, proven by emitting the snapshot deck and comparing
  it to `sim/clamp-probe/record/netlists/probe.sp`.

## What this does not change

- No recorded result, electrical limit or spec row is altered.
- The append-only gate's coverage of record directories is unchanged.
- It does not claim any cell is ESD-rated; see 0004 and section 5.1 of
  `io-ring.md`.
- `signoff/block-manifest.json` and `signoff/signoff-record.json` bind item 9
  to the inventory hash, which is untouched by a script edit, so they are not
  regenerated.

## PDK-independent part

The policy itself: records append-only, harness code hash-pinned, re-attest on
edit. It is stamped into `gf180-io-ring` unchanged.

## PDK-specific part

Which scripts are listed in the item-9 inventory and their hashes.
