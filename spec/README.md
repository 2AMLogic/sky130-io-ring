# spec

The specification of the I/O ring. **Status: proposed, pending EE-key
and market-key review, then operator ratification.**

| File | What it is |
|---|---|
| [`io-ring.md`](io-ring.md) | The spec: every parameter as target / fallback / stretch with rationale, the ESD section, the corner set |
| [`io-ring.json`](io-ring.json) | The same rows as data (`pdk_independent`, `statistical` flags, and the 75 named corners) |
| [`check_spec.py`](check_spec.py) | Confirms the markdown tables and the data agree: `python3 -I spec/check_spec.py` (`--write` re-renders the tables) |
| [`klt-rule-coverage.md`](klt-rule-coverage.md) | Which I/O rule classes klt's sky130 deck checks, with the upstream issue for each gap |
| [`review-2026-10.md`](review-2026-10.md) | Evidence review of the proposal: sources, sourced / provisional / open classification, remaining gates, validation plan. Ratifies nothing |
| [`decisions/`](decisions/) | Decision records: 0001 draw vs adopt, 0002 supplies and devices, 0003 PVT corners, 0004 ESD topology |

Per the 2026-10-22 ruling (2am#5864), the EE-key and market-key reviewers
(`ratification/ee-key/`, `ratification/market-key/`) review a spec PR first,
as input; the operator then ratifies, and the ratification is recorded in the
decision record. Authors cannot ratify their own design. Agents do not relax
a ratified row to make a result pass.
