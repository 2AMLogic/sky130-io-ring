# Roadmap

An I/O ring on SkyWater sky130 (GPIO, supply pads with ESD clamps, corner and
filler cells, closed into a demonstration ring), drawn by a generator and
checked with klayout-tools (`klt`), xschem and ngspice.

Status as of 2026-11-13, `main` @ `3042d4c`. Tracker read the same day.
The verdict of record is [`signoff/signoff-record.json`](signoff/signoff-record.json);
this file explains it and orders the work, and never overrides it.

## Where it stands

The block is graded against the klayout-tools T1 checklist (tracker #3). The
committed record, graded by klt 0.9.1, reads **7 of 11 T1 items met**:

| Item | Status | Evidence |
|---|---|---|
| 1 Design sources | met | xschem sources and derived netlists under `design/`, `signoff/evidence/item1.json` (#30) |
| 2 Layout | met | generated streams in `layout/gds/`, byte-reproducible in CI, `signoff/evidence/layout-attestation.json` (#31) |
| 3 DRC clean | met | `signoff/evidence/drc/ring.json`, clean against the curated `sky130` deck only (#32) |
| 4 LVS clean | met | `signoff/evidence/lvs/ring.json`, flat `match` (#33, #44, PR #73) |
| 5 Corner verification vs a ratified spec | unmet, `no_evidence` | spec is not ratified (#2) |
| 6 Monte Carlo for statistical rows | unmet, `no_evidence` | waits on #2 |
| 7 Post-layout verification | unmet, `no_evidence` | waits on #2 |
| 8 Characterization report | unmet, `no_evidence` | waits on #2 |
| 9 Testbenches shipped | met | `signoff/evidence/item9.json`: PDK smoke, cold start, clamp probe (#34) |
| 10 Repo hygiene | met | `signoff/evidence/item10.json` (#35) |
| 11 Power delivery (structural) | met | `signoff/evidence/erc/ring.json` plus the ring LVS report (#36, PR #57) |

What "met" does and does not cover is stated in
[`signoff/README.md`](signoff/README.md). In short:

- DRC is clean on the deck's modeled rules. Thick-oxide marker rules, latch-up
  distance, guard-ring construction and ESD rules are **not checked by any klt
  sky130 deck** ([`spec/klt-rule-coverage.md`](spec/klt-rule-coverage.md)).
- LVS is a flat comparison. The GPIO resistor's geometry is not compared and
  its `R` is a placeholder; `vdd` reports `body_verification: unverified`.
- The only analog results are two single-corner records: the PDK smoke
  (`sim/pdk-smoke/`) and the RC clamp probe (`sim/clamp-probe/`, #72). The
  probe is `kind: probe`, not item-5 evidence, and it found that both clamps
  turn fully on during a 1 us supply ramp.
- The spec ([`spec/io-ring.md`](spec/io-ring.md), 59 rows, four decision
  records) is **proposed, not ratified**. Nine gates G1 to G9 remain open
  ([`spec/review-2026-10.md`](spec/review-2026-10.md) section 5).

The layout rungs of the README's maturity ladder are evidenced ahead of its
first rung (spec ratified); the remaining T1 work is on the analog side. The
README status lines and the 2026-10-17 checklist in tracker #3 lag this state.

## Now

Can start today; each is one PR.

1. **Revise the ratification-scope PR.** PR #27 (`spec/ratification-scope.md`,
   43 rows in scope, 16 held out by gate) carries `loom:changes-requested`
   from the EE-key review and has not moved since 2026-10-25. Done when the
   required changes in that review are addressed on the PR head and it is back
   at `loom:review-requested`. Issue #24. Blocks: nothing.
2. **Bring the README in line with the committed evidence.** It still says
   "nothing is designed yet", "no supply clamp" in the DRC drawing and "no ERC
   result". Done when those lines match `signoff/README.md`, the item-10
   attestation is re-made (README is hash-pinned) and CI is green. No issue
   yet (seed 1).
3. **Close the read-only half of gate G2.** Read the 5 V device corner files
   of the pinned PDK and run one single-corner probe per skew corner showing
   whether `ff ss sf fs` move the 5 V NMOS. Done when a `kind: probe` record
   and README exist under a new `sim/` directory and the finding is stated.
   No issue yet (seed 2).
4. **Explain `body_verification: unverified` on the `vdd` LVS report** (815
   `nfet` bodies; `gpio` and `ring` are `verified`). Done when the report
   reads `verified` after a generator or label fix, or the cause is written
   in `signoff/README.md` with the upstream klayout-tools issue linked. No
   issue yet (seed 3).
5. **Diode forward-drop probe at the ESD.2 current** (review section 7,
   item 2). Done when a `kind: probe` record reports the forward drop of the
   pad diodes at the HBM peak current and labels anything beyond the diode
   model's stated range as outside model validity. No issue yet (seed 4).
6. **Resolve where the clamp trigger stops false-triggering.** The G6 probe
   has points at 1 us (fully on) and 10 us (off) only, and the post-ramp
   supply current had not settled. Done when a new probe record brackets the
   transition rise time for both clamps and reports a settled leakage. No
   issue yet.

## Next

- **Operator ratification of the in-scope rows and records** (#2), once PR
  #27 is revised and both key reviews are re-run on the new head. Unparks #7.
- **Item 5, corner verification.** The path simulations P1 to P9 and any
  corner set are explicitly "not before ratification of 0004" (review
  section 7). Done when a corner-matrix record covers every ratified row with
  per-row pass/fail and item 5 reads `met`.
- **Pad timing parameters** (#7): a decision record on adopting them, the
  named rows in `spec/io-ring.md`, and a PDK-independent testbench and record
  schema under `sim/lib/`. Parked on #2.
- **Items 6, 7, 8** follow item 5: Monte Carlo for whichever ratified rows
  are statistical, the suite re-run on the extracted netlist, and one
  aggregated characterization report.
- **Point tracker #3 at the record.** Its own acceptance criterion says it
  closes with a pointer once a manifest and committed record exist; both do.

## Later

- **Clamp trigger constant and sizing** (G5, G6): 1 us against the foundry
  clamp's documented 2 us. Question first: what supply rise time must the
  ring tolerate, and is a clamp held on after the pulse acceptable?
- **5.5 V pad tolerance** (SUP.1 stretch, G3). Question first: G1, a stress
  limit for the 5 V devices that is more than model validity.
- **Thick-oxide marker rules** (`hvi.*`, `hvntm.*`): checkable only through
  the PDK's native KLayout deck (`klt drc --engine klayout`), which was read
  but never run here. Question first: is a run on the ring reproducible in CI?

## Blocked and waiting

- **#2, spec ratification**: an operator step after the key reviews. Every
  unmet T1 item waits on it.
- **G1, G4, G9**: need foundry or standards documents read by a person (5 V
  device stress limits; the latch-up section, and a source for LU.3 or its
  deletion; JS-001 and JESD78 text).
- **G7, bond-pad opening and pitch**: needs a shuttle's pad rule; none is
  selected. The drawn 55 um opening is provisional.
- **G8, latch-up and ESD rule coverage upstream**: klayout-tools #3802, #3803
  and #3804 are closed by narrower changes. Whether to reopen #3802 or file a
  fresh report is an open decision (review section 6).

## Not planned

- The core, the package and bond-wire modelling.
- Any ESD rating claim before measured silicon. Simulated clamp behaviour is
  a model figure, never a rating.
