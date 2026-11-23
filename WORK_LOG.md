# Work Log

Chronological record of merged PRs and closed issues, maintained by the Guide
triage role. Newest first.

### 2026-11-23

- **PR #190**: refactor: remove dead helpers, unused parameters and duplicate layer alias from layout generator
- **PR #186**: feat(sim): add G6 follow-up clamp-trigger probe (rise-time bracket, settled leakage)
- **Issue #189** (closed): Remove dead annulus helper, Draw wrapper, unused parameters/returns, and duplicate layer alias from layout generator
- **Issue #178** (closed): Gate G6 follow-up probe: resolve the clamp false-trigger transition between 1 us and 10 us supply rise, with a settled leakage

### 2026-11-22

- **PR #185**: test: fold ProseCitations seeded setup into check_after_replacement
- **Issue #179** (closed): Consolidate repeated setup in 40 prose citation tests

### 2026-11-21

- **PR #182**: feat: add single-corner GPIO probe and PDK-independent measurement deck
- **Issue #177** (closed): Add the first GPIO testbench: a single-corner (tt) probe of the drawn GPIO cell using the GE/GF rows' measurement definitions

### 2026-11-19

- **PR #174**: test: define deck/input hash fixtures once in ProseCitations
- **PR #172**: docs: resolve split-pin rule contradiction in citation checker docstrings
- **Issue #173** (closed): Define the deck and input hash fixtures once in the prose citation tests
- **Issue #170** (closed): Consolidate the conflicting split-pin rules in citation checker docstrings
- **PR #168**: sim: remove dead node() in clamp-probe, add decision 0005, re-attest item 9

### 2026-11-18

- **PR #166**: ci: add least-privilege permissions block and re-attest item 10
- **PR #164**: ci: add merge_group trigger; append-only gate fails closed on an unusable base
- **Issue #165** (closed): ci.yml: add an explicit least-privilege permissions block (CodeQL alert 3)
- **Issue #162** (closed): Merge queue: add the merge_group trigger and adapt the PR-metadata gates

### 2026-11-17

- **PR #158**: chore(loom): resync installed Loom to v0.19.1306

### 2026-11-16

- **PR #154**: chore(loom): resync installed Loom to v0.19.1302
- **PR #152**: ci: narrow prose split-pin lookahead to the immediately-next line
- **Issue #151** (closed): check_prose_citations: the split-pin lookahead also completes across a blank line and across list items

### 2026-11-15

- **PR #150**: ci: catch prose hash pins split across lines by a reflow
- **Issue #148** (closed): check_prose_citations: a pin de-pinned by an un-backticked path name, or by a reflow onto the next line, still degrades to membership silently
- **PR #147**: ci: error on near-miss prose hash pins that silently degrade to membership
- **PR #145**: ci: catch omitted, mis-attributed and fenced-away prose citations
- **PR #143**: ci: assert prose citations against the signoff evidence they cite
- **PR #142**: docs: state the path-key separator rule as R3 in sim/README.md and qualify the #134 citation
- **PR #139**: docs: qualify the sim probe-index preamble for the pdk-smoke outlier row
- **PR #131**: netlist: adopt klt netlist --relative-paths so committed netlists are checkout-independent
- **Issue #146** (closed): check_prose_citations: a role-pinned hash degrades silently to membership-only on three phrasing variants
- **Issue #144** (closed): check_prose_citations: three measured residual gaps in the citation-drift class
- **Issue #140** (closed): Record path-key separator convention is documented only in the CI-gate docs, not in sim/README.md's record field conventions
- **Issue #137** (closed): No CI check cross-validates signoff prose citations against the committed evidence JSON
- **Issue #127** (closed): sim/README.md probe-table preamble is inaccurate for pdk-smoke (no README.md, kind: pdk-smoke)
- **Issue #124** (closed): Committed netlists carry absolute host paths: adopt klt netlist --relative-paths so regeneration is checkout-independent
- **PR #138**: docs: state the path-key separator convention for evidence records
- **PR #136**: docs: quote DRC report's voltage_domain_warnings; fix stale deck hash in signoff README
- **PR #132**: refactor(sim): extract the copy-pasted run.sh preamble and record tail into sim/lib/run_common.sh
- **PR #135**: ci: enforce record field-naming (R1), document conventions, diode-unit erratum
- **PR #128**: fix: reason-appropriate path-check failures; check dirs values in evidence format
- **PR #129**: docs: align ROADMAP and rule-coverage claims with the committed DRC report
- **PR #126**: ci: gate LVS report contents and freshness, exit 6 on unverified bodies
- **PR #125**: ci: scope the append-only guard to sim/ record directories
- **PR #123**: fix: carry diode area/perim in instance units (um2/um), drop refuted x1e12 conversion
- **PR #121**: fix: attribute the four unmet T1 items to the recorded no_evidence reason
- **PR #117**: Add diode-unit-probe: settle sky130 diode area/perim unit as um2/um
- **PR #115**: docs: count the supply clamps in the ring DRC envelope
- **PR #114**: refactor(layout): drop dead state, the region wrapper and seven ignored parameters
- **PR #111**: ci: commit sim probe logs without -f and reject dangling log references
- **PR #91**: docs: roadmap as of 2026-11-13
- **Issue #134** (closed): Evidence checker: PATH_KEY_RE needs a separator, so logdir/logfile-style keys are never path-checked
- **Issue #130** (closed): Rule-coverage doc omits the DRC report's voltage_domain_warnings; signoff/README.md quotes a superseded deck hash
- **Issue #122** (closed): ROADMAP.md: two coverage/gate claims are conservative but imprecise against their own cited sources
- **Issue #120** (closed): sim/ record provenance: two fields misreport what they hold (misnamed unit suffix, and ciel recorded 'unavailable' when installed)
- **Issue #118** (closed): Evidence checker: existence failures report as 'is not repo-relative', plus two doc/comment inaccuracies
- **Issue #113** (closed): Consolidate the copy-pasted sim run.sh preamble and record tail into one sim/lib helper (copies have already drifted)
- **Issue #116** (closed): Layout generator converts diode area/perim by the refuted x1e12 convention; drawn and simulated diode geometry disagree by 1e12
- **Issue #109** (closed): The append-only guard freezes sim/README.md, so the sim index cannot be updated and is stale
- **Issue #107** (closed): Establish the unit convention for sky130 diode area/perim, so G1 sizing has a defined starting point
- **Issue #106** (closed): A new sim probe's record/logs/*.log is gitignored, and a dangling log reference passes CI
- **Issue #99** (closed): Remove dead state, a passthrough wrapper and 7 ignored parameters from the layout generator
- **Issue #93** (closed): README attributes the four unmet T1 items to spec ratification; the record says no_evidence
- **Issue #90** (closed): README understates ring DRC coverage: "(but no supply clamp)" contradicts layout/ and signoff/ READMEs

### 2026-11-14

- **PR #110**: fix(layout): name every rail band in every edge cell so clamp bodies resolve to VSS
- **PR #108**: feat(sim): add G2 corner-skew probe for the 5 V thick-oxide devices
- **PR #105**: sim: add the G1/ESD.3 pad-diode probe at the ESD.2 current
- **PR #104**: test: collapse the twin open-guard-ring tests into one loop over GUARDED
- **PR #103**: refactor: drop the unread KINDS constants and the _tap_for pass-through
- **PR #101**: refactor(layout): draw clamp contact columns from the one sky130_devices rule
- **Issue #98** (closed): Collapse the duplicated open-guard-ring tests into one loop over GUARDED (and cover gpio_pulls)
- **Issue #97** (closed): Remove duplicated licon rule math: sky130_clamp._licons is sky130_devices._contacts
- **Issue #96** (closed): Single-corner probe: pad diode forward drop at the ESD.2 pulse current
- **Issue #95** (closed): vdd LVS report has body_verification "unverified" for 815 nfet bodies; find the cause
- **Issue #94** (closed): Gate G2 probe: do the sky130 skew corners move the 5 V devices?
- **Issue #88** (closed): Remove the never-used KINDS and FILL_KINDS constants from layout/sky130_cells.py
- **PR #89**: docs: align README status, evidence and layout block with the signoff record
- **Issue #86** (closed): README overstates and understates repo state: four claims contradicted by signoff evidence (fix requires re-pinning the item-10 attestation)

### 2026-11-12

- **PR #83**: Bump Repo Skills 0.25.10 -> 0.26.1

### 2026-11-10

- **PR #80**: chore: remove diag_lvs_without_diodes.py and fix stale gpio LVS note
- **Issue #75** (closed): Remove diag_lvs_without_diodes.py: klt 0.9.x resolves the diode cards it works around

### 2026-11-07

- **PR #77**: Bump Repo Skills 0.25.1 -> 0.25.10

### 2026-11-06

- **PR #74**: feat(sim): add G6 single-corner RC clamp probe
- **Issue #72** (closed): Add the G6 single-corner probe: RC supply clamps under a power-up ramp and an HBM pulse
- **PR #73**: feat(signoff): bump klt to 0.9.1 and cite ring LVS match for item 4
- **PR #70**: chore(signoff): bump klt to 0.9.0 and regenerate evidence; gpio LVS matches
- **Issue #44** (closed): Draw device-bearing GPIO and clamp layout so klt lvs can match the cells and the ring

### 2026-10-31

- **PR #68**: Bump Repo Skills 0.24.7 -> 0.25.1

### 2026-10-30

- **PR #66**: feat: check fill_1 DRC in abutment context with klt --tile
- **Issue #32** (closed): T1 item 3 (DRC clean): klt drc clean on every cell and the assembled ring, coverage quoted against spec/klt-rule-coverage.md

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
