# Work Log

Chronological record of merged PRs and closed issues, maintained by the Guide
triage role. Newest first.

### 2026-10-29

- **PR #57**: fix(signoff): model VDD-bodied GPIO wells and label internal nets for clean ring ERC
- **Issue #56** (closed): ERC: 56 missing_tie + 1 unlabelled_conductor on the ring with GPIO devices (PR #54)

### 2026-10-27

- **PR #62**: docs(layout): drop stale TAP_SPAN literal from README
- **Issue #60** (closed): layout/README.md states TAP_SPAN as 14 um; sky130_blocks.py sets 18.0 um
- **PR #59**: feat(layout): ring every pad-connected GPIO bank and tap long groups for LU.2
- **Issue #53** (closed): GPIO: tap distance (LU.2) fails and only the driver banks have guard rings (LU.4)
- **PR #54**: feat: draw wired GPIO devices from the netlists, re-record DRC and LVS evidence
- **Issue #46** (closed): Draw device-bearing GPIO sub-block layout so klt lvs matches sky130_ioring_gpio
- **Issue #52** (closed): Clamp drawing shorts VDDIO, VDD and VSS in the ring (erc.supply_short)
- **PR #51**: feat(layout): draw supply clamp devices in vddio and vdd at netlist W/L/m
- **Issue #48** (closed): Draw supply clamp layout and get klt lvs past the MIM m=2 refusal for vddio, vdd and ring
- **PR #50**: feat(signoff): klt erc supply spec, ring ERC report and split-seam negative check
- **Issue #36** (closed): T1 item 11 (power delivery): klt erc supply spec for VDDIO/VDD/VSS ring continuity
- **PR #45**: feat(signoff): add klt lvs report generator and per-cell LVS evidence
- **Issue #33** (closed): T1 item 4 (LVS clean): klt lvs match of each cell and the ring against the item-1 netlists
- **Issue #47** (closed): x
- **PR #39**: feat(signoff): attest T1 item 10 repo hygiene, bump klt to 0.8.0
- **Issue #35** (closed): T1 item 10 (repo hygiene): hygiene inventory attested with klt signoff --attest 10, README reproduction section
- **PR #40**: feat(design): add sky130 I/O ring xschem sources and netlists for T1 item 1
- **Issue #30** (closed): T1 item 1 (design sources): xschem schematics and derived netlists for the GPIO, VDDIO/VDD/VSS pads, corner, fillers and the demonstration ring
- **PR #42**: feat(signoff): cite ring DRC report for T1 item 3 and re-check reports in CI
- **PR #38**: feat(signoff): attest T1 item 9 testbenches and check the attestation in CI
- **PR #37**: feat(layout): generate closed sky130 I/O ring stream and cite it for T1 item 2
- **Issue #34** (closed): T1 item 9 (testbenches shipped): testbench inventory over the PDK smoke and the cell benches, attested with klt signoff --attest 9
- **Issue #31** (closed): T1 item 2 (layout): drawn GDS for every ring cell and the assembled ring, generated and abutment-clean by construction

### 2026-10-24

- **PR #25**: docs: install ee-key and market-key reviewer trees; route spec review before ratification
- **Issue #23** (closed): Install the EE-key and market-key ratification reviewer trees (2am#5346 stage 2)

### 2026-10-23

- **PR #18**: ci: run spec/check_spec.py and PDK resolver self-test as gates
- **Issue #17** (closed): Wire spec/check_spec.py into CI: documented gate is never run

### 2026-10-22

- **PR #20**: docs(spec): evidence review of proposed I/O-ring spec; fix ESD paths, limits, latch-up sourcing

### 2026-10-21

- **PR #14**: Bump Repo Skills 0.24.3 -> 0.24.7

### 2026-10-20

- **PR #12**: build: wire check:ci to the PDK-free checks
- **Issue #10** (closed): Wire package.json check:ci stubs to the existing PDK-free checks

### 2026-10-17

- **PR #9**: ci: add signoff manifest, committed record and PDK-free evidence checks
- **PR #8**: feat(sim): pin sky130 PDK, add revision-refusing resolver and smoke record
- **PR #6**: docs(spec): propose I/O ring spec, decision records and klt rule coverage
- **PR #1**: chore(loom): Install Loom 0.19.1180
- **Issue #5** (closed): T1 item 10: add a block manifest, a committed signoff record and a PDK-free CI that keeps evidence formats valid
- **Issue #4** (closed): T1 item 9: pin sky130 (open_pdks f6eeac7 via ciel), split the harness for the port, and commit a smoke simulation
