# sky130-io-ring specification

**Status: proposed, pending human ratification.** An agent drafted this
document. Ratification is a human decision and is recorded in the decision
records under `decisions/`; until a record says "ratified", every row is a
proposal. Agents do not relax a ratified row to make a result pass.

All figures are design targets. The rows live in [`io-ring.json`](io-ring.json),
which is the source; the tables below are rendered from it and
`python3 -I spec/check_spec.py` fails if they disagree (`--write` re-renders).

Each row has `id | parameter | target | fallback | stretch | rationale |
pdk_independent`. A row marked `pdk_independent = yes` states a structure,
function or method that carries over to another PDK unchanged; `no` means the
value depends on sky130 (device names, voltages, dimensions). Rows in the
JSON also carry `statistical` (a Monte Carlo candidate for T1 item grading).
Where a row is `yes` but quotes a number, the number is still sky130's and the
`gf180-io-ring` port re-derives it; the structure is what it inherits.

**PDK inspected**: sky130A, open_pdks `f6eeac7d` (the install klt resolves),
klt `0.7.1.dev1765+gb61f753d0369`, sky130 deck content hash
`sha256:f3e6a304b5d7e02301b14643fab17e3a455e145b4ba684dc66b645c2016e5865`.
The `sky130_fd_io` survey read a second install (open_pdks `c6d73a35`).
Pinning the PDK is issue #4, not this spec.

## Decision records

| Record | Decides |
|---|---|
| [0001 draw vs adopt](decisions/0001-draw-vs-adopt.md) | Draw every cell; use `sky130_fd_io` as reference and comparison |
| [0002 supplies and device flavors](decisions/0002-supplies-and-device-flavors.md) | VDDIO / VDD / ground and which devices each uses |
| [0003 PVT corner set](decisions/0003-pvt-corner-set.md) | The 75 named corners |
| [0004 ESD network topology](decisions/0004-esd-network-topology.md) | Per-pad and supply protection, evidence limits |

Rule coverage of klt's sky130 deck: [`klt-rule-coverage.md`](klt-rule-coverage.md).

## 1. Supplies and device flavors

<!-- rows:begin SUP -->
| id | parameter | target | fallback | stretch | rationale | pdk_independent |
|---|---|---|---|---|---|---|
| SUP.1 | I/O supply VDDIO | 3.3 V ±10% (2.97 / 3.30 / 3.63 V) | — | Input tolerates a pad voltage up to 5.5 V with VDDIO = 3.3 V | 3.3 V is the common GPIO level and sits inside the range the foundry GPIO documents (Liberty files named for 1.65-5.5 V VDDIO). 5 V tolerance is the hardest I/O-rule item, so it is stretch, not target. | no |
| SUP.2 | Core interface VDD | 1.8 V ±10% (1.62 / 1.80 / 1.98 V), level-shifted inside the pad | — | — | Matches the thin-oxide core devices; the pad cell owns the level shift so the core never sees VDDIO. | no |
| SUP.3 | I/O-domain device flavor | sky130_fd_pr 5 V gate-oxide devices (nfet_g5v0d10v5 / pfet_g5v0d10v5) operated at <= 3.63 V | — | Same flavor; input stage reworked for 5.5 V pad swing | Thick-oxide devices are the point of this block (CLAUDE.md). The 3.3 V I/O supply needs a gate oxide rated above core; the PDK has one thick-oxide family. | no |
| SUP.4 | Core-domain device flavor | 1.8 V thin-oxide devices (nfet_01v8 / pfet_01v8) for core-side logic and the core half of the level shifter | — | — | Core-side devices never see VDDIO. | no |
| SUP.5 | Ground topology | One ground net VSS shared by I/O and core (common p-substrate); one ground pad type | Separate VSSIO / VSSD pads joined only through the substrate | — | The substrate is shared on this process, so separate ground nets add pad types without isolating anything. Keeps the pad-type pair count at 4 types. | yes |
| SUP.6 | Supply sequencing | Either supply may rise first; with VDD absent and VDDIO present the pad is high-Z and draws <= 1 µA from VDDIO at 25 C | VDDIO may rise only after VDD | — | A pad ring in a real board sees either order. Value is a design target to be confirmed by simulation, not a measured figure. | yes |
<!-- rows:end SUP -->

## 2. GPIO function

<!-- rows:begin GF -->
| id | parameter | target | fallback | stretch | rationale | pdk_independent |
|---|---|---|---|---|---|---|
| GF.1 | Output enable | Core-side OE input; pad is high-Z when OE is inactive | Output-only and input-only pad variants | — | Bidirectional is the README target; the fallback keeps two single-direction cells. | yes |
| GF.2 | Input enable | Core-side IE input; with IE inactive the core-side input is held at a defined level | Receiver always enabled | — | A floating pad must not toggle the core when the receiver is not wanted. | yes |
| GF.3 | Pull-up / pull-down | One weak pull, selectable pull-up or pull-down, active only while OE is inactive; pull-up and pull-down mutually exclusive | No pulls (output + input only) | — | Pulls give a defined level for unconnected pads. Mutual exclusion avoids a rail-to-rail path through the pad. | yes |
| GF.4 | Drive strength | One fixed strength | Same | Selectable second strength (core-side control) | Selectable drive is a documented stretch in the README draft. | yes |
| GF.5 | Slew control | Fixed edge rate set by GE.3 / GE.4 | Same | Selectable slow mode (core-side control) | As GF.4. | yes |
| GF.6 | Input threshold | Single CMOS-compatible threshold, referenced to VDDIO | Same | Selectable second threshold | Selectable threshold exists in the foundry cell; kept out of the target to hold the first cell small. | yes |
| GF.7 | Input hysteresis | Schmitt input, >= 200 mV hysteresis at VDDIO = 3.30 V, tt / 25 C | Plain inverter input, no hysteresis | — | Pads see noise from bond wires and the board. Value is a design target. | no |
| GF.8 | Level shifting | Core 1.8 V to I/O 3.3 V on the output path and I/O 3.3 V to core 1.8 V on the input path, inside the pad cell | Same | — | The core interface is 1.8 V only (SUP.2). | yes |
<!-- rows:end GF -->

## 3. GPIO electrical targets

Corners are stated per row. Corner names are defined in section 7.

<!-- rows:begin GE -->
| id | parameter | target | fallback | stretch | rationale | pdk_independent |
|---|---|---|---|---|---|---|
| GE.1 | Output high level | VOH >= VDDIO - 0.4 V at IOH = -4 mA; corner ss, 125 C, VDDIO 2.97 V, VDD 1.62 V | IOH = -2 mA | IOH = -8 mA in the selectable strong mode | Slow-process / hot / low-supply is the worst case for drive. 4 mA is a common GPIO class. | no |
| GE.2 | Output low level | VOL <= 0.4 V at IOL = 4 mA; same corner as GE.1 | IOL = 2 mA | IOL = 8 mA in the strong mode | As GE.1. | no |
| GE.3 | Edge rate, maximum | tr and tf (20-80 % of VDDIO) <= 3 ns into 10 pF; corner ss, 125 C, VDDIO 2.97 V | <= 5 ns | — | Sets the usable toggle rate (GE.9). | no |
| GE.4 | Edge rate, minimum | tr and tf (20-80 %) >= 0.8 ns into 10 pF; corner ff, -40 C, VDDIO 3.63 V | — | Selectable slow mode with a larger minimum | Limits supply bounce and overshoot at the fast corner. Value is a design target. | no |
| GE.5 | Input thresholds | VIL <= 0.3 x VDDIO and VIH >= 0.7 x VDDIO over all corners | — | — | CMOS-compatible levels at every corner. | yes |
| GE.6 | Pad leakage (high-Z, pulls off) | \|I\| <= 100 nA at 0 <= VPAD <= VDDIO, 25 C; <= 1 µA at 125 C; corner ff VDDIO 3.63 V | <= 1 µA at 25 C | — | Leakage is statistical, so it is a Monte Carlo candidate. Pad diodes dominate. | no |
| GE.7 | Output-path delay (core OUT to PAD, 50 %-50 %) | <= 5 ns into 10 pF; corner ss, 125 C, VDDIO 2.97 V, VDD 1.62 V | <= 8 ns | — | Includes the level shifter. | no |
| GE.8 | Input-path delay (PAD to core IN, 50 %-50 %) | <= 3 ns; corner ss, 125 C, VDDIO 2.97 V, VDD 1.62 V | <= 5 ns | — | Includes the level shifter. | no |
| GE.9 | Maximum toggle rate | 50 MHz into 10 pF, output and input paths; corner ss, 125 C, low supplies | 25 MHz | — | Follows from GE.3 (20 ns period for 3 ns edges). | no |
| GE.10 | Pull resistance | 20 kΩ to 60 kΩ at VPAD = VDDIO / 2 (pull-up) or VPAD = VDDIO / 2 (pull-down), all corners | 10 kΩ to 100 kΩ | — | Weak enough for a driver to override, strong enough to hold a level. Resistance spread is a Monte Carlo candidate. | no |
<!-- rows:end GE -->

## 4. Cell set and geometry

<!-- rows:begin CELL -->
| id | parameter | target | fallback | stretch | rationale | pdk_independent |
|---|---|---|---|---|---|---|
| CELL.1 | Cell set | GPIO, VDDIO pad, VDD pad, VSS pad, corner, filler set | GPIO + one supply pair (VDDIO + VSS) + corner | Analog pass-through pad | From the README draft; the fallback is the close-first set in CLAUDE.md. | yes |
| CELL.2 | Pad pitch | 80 µm for every pad cell (uniform width) | 100 µm | 60 µm | A uniform pitch makes ring assembly a placement problem. Foundry GPIO is 80 µm and its power pads 75 µm; cited for comparison in decision 0001, not copied. | no |
| CELL.3 | Cell depth (die edge to core side) | <= 200 µm | <= 250 µm | <= 150 µm | Foundry depth is 197.965 µm (comparison only). Depth is driven by the driver, level shifter and clamp area. | no |
| CELL.4 | Bond-pad opening | Square opening >= 55 µm x 55 µm | Larger opening as the shuttle requires | — | OPEN: the final value comes from the chosen shuttle's pad rule; no shuttle is selected yet. Foundry bare pad outline is 65.4 x 75.4 µm (comparison only). | no |
| CELL.5 | Ring rails | VSS on met5, VDDIO on met4, VDD on met3; each >= 10 µm wide; same layer and y-extent in every cell | Single shared rail layer pair | — | Fixed layer and extent per rail is what makes abutment close the ring (CELL.8). Width is sized against the ESD peak current in decision 0004. | no |
| CELL.6 | Filler widths | 1, 5, 10 and 20 µm | 5 and 20 µm | — | Any ring length that is a multiple of 1 µm can be filled. The foundry library offers the same set; the match is recorded in decision 0001. | no |
| CELL.7 | Corner construction | Square corner cell, edge = cell depth; rails turn 90 degrees with 45-degree chamfered corners; guard rings continuous; no pad | Corner cell with mitred rails and no clamp | — | Chamfers respect the 45-degree angle rule in the deck. A corner carries no pad, so it carries no ESD path. | no |
| CELL.8 | Abutment seam | Rails, guard rings and well ties extend to the cell boundary on the same layers and the same y-extent so abutment forms a continuous conductor; no overlap or gap | — | — | The seam is where the tools are weakest (CLAUDE.md); making the rule explicit lets signoff check it. | yes |
| CELL.9 | Grid | Cell edges and pad centres on the 0.005 µm manufacturing grid; pad pitch is an integer number of µm | — | — | The deck checks 0.005 µm ongrid on every drawn layer. | no |
<!-- rows:end CELL -->

## 5. ESD network

<!-- rows:begin ESD -->
| id | parameter | target | fallback | stretch | rationale | pdk_independent |
|---|---|---|---|---|---|---|
| ESD.1 | HBM design target | 2 kV HBM, design target only; not a rating | 1 kV | — | README target. A silicon property: pre-silicon evidence does not establish it. | yes |
| ESD.2 | HBM stress model for simulation | 100 pF through 1.5 kΩ; 2 kV gives about 1.33 A peak (2000 V / 1500 Ω) | 1 kV: about 0.67 A | — | Standard HBM network. The peak figure ignores the device voltage drop, so it is slightly high. | yes |
| ESD.3 | GPIO pad protection | Primary: diode from pad to VDDIO and diode from VSS to pad. Secondary: series resistor into the driver / receiver plus a local clamp at the receiver gate. Supply clamp (ESD.4) closes the loop. | Diode pair + supply clamp, no secondary stage | — | Diode paths are forward conduction, the regime the PDK models cover best. See decision 0004. | no |
| ESD.4 | VDDIO-VSS supply clamp | RC-triggered large thick-oxide NMOS clamp, trigger time constant about 1 µs | Grounded-gate NMOS clamp | — | The RC clamp turns on in simulation. A grounded-gate clamp relies on snapback, which the models do not represent, so it is fallback and gets less pre-silicon evidence. | no |
| ESD.5 | VDD-VSS core supply clamp | RC-triggered thin-oxide NMOS clamp, trigger time constant about 1 µs | Grounded-gate NMOS clamp | — | As ESD.4. | no |
| ESD.6 | Cross-domain path VDDIO to VDD | No direct clamp; the path runs through VSS via the two supply clamps | Back-to-back diode pair between VDDIO and VDD | — | One fewer element on the discharge path; the cost is a longer path, which the path simulation (ESD.8) covers. | yes |
| ESD.7 | Stress limit during the HBM pulse | Peak voltage on any node <= 80 % of the lowest breakdown the PDK states for a connected device | — | — | The limit value comes from the PDK documentation and is recorded in decision 0004 when ratified. | yes |
| ESD.8 | Discharge-path simulation | Every path in the ESD section of io-ring.md simulated with the PDK models for the ESD.2 pulse; turn-on and current split reported | Paths G-VSS, G-VDDIO, VDDIO-VSS, VDD-VSS only | — | What pre-silicon evidence can show. Snapback, second breakdown and failure current are not shown. | yes |
| ESD.9 | Current sharing | Parallel clamp legs share the stress current within +/-25 % in simulation including rail resistance | +/-40 % | — | Uneven sharing is the usual early failure in a wide clamp. Value is a design target. | yes |
| ESD.10 | Wording | No cell, report or document describes any cell as ESD-rated, qualified or compliant; HBM figures are labelled design targets until measured | — | — | CLAUDE.md scope rule. | yes |
<!-- rows:end ESD -->

### 5.1 What pre-silicon evidence can and cannot show

ESD robustness is a silicon property. No cell here is ESD-rated, and none is
called qualified or compliant; the 2 kV figure is a design target until
measured.

Pre-silicon, this repository can show:

- the clamp network turns on in simulation at the stress voltage, using the
  PDK's ngspice models;
- the stress current takes the intended path and splits across parallel legs
  as ESD.9 requires;
- the node voltages stay below the stress limit in ESD.7 for the ESD.2 pulse;
- the layout is clean against the rules the deck checks, and the rules it does
  not check are listed as not checked.

It cannot show:

- the failure current or second-breakdown point of any device (the models do
  not reproduce snapback or thermal runaway);
- HBM, CDM or MM pass levels, or latch-up immunity under the JESD78 test;
- behaviour of the real bond-wire, package and board impedance (out of scope);
- that the PDK diode and clamp models are valid at the stress current: they are
  fitted for normal operation, so the forward-diode paths are the best-covered
  part and any path that relies on avalanche or snapback is the least.

### 5.2 Discharge paths

Pad types are G (GPIO), IO (VDDIO), DD (VDD), SS (VSS). One row per
unordered pair that can carry stress current, with the evidence kind per
path. "Simulated" means an ngspice transient with the PDK models at the ESD.2
pulse; "unverifiable" means pre-silicon evidence cannot establish it.

| Path | Stress pair | Route | Simulated evidence | Unverifiable pre-silicon |
|---|---|---|---|---|
| P1 | G to SS, pad positive | G pad, then clamp NMOS / diode string to SS | primary diode and supply-clamp turn-on; current split | failure current of the diode |
| P2 | G to SS, pad negative | VSS-to-pad diode, forward | forward conduction, drop at ESD.2 current | diode failure current |
| P3 | G to IO, pad positive | pad-to-VDDIO diode, forward | forward conduction | diode failure current |
| P4 | G to IO, pad negative | VSS-to-pad diode, then IO-SS clamp, then IO | clamp turn-on, current split | clamp failure current, snapback |
| P5 | IO to SS | VDDIO-VSS clamp (ESD.4) | RC trigger and turn-on; peak node voltage | clamp failure current |
| P6 | DD to SS | VDD-VSS clamp (ESD.5) | RC trigger and turn-on; peak node voltage | clamp failure current |
| P7 | IO to DD | via VSS through both clamps (ESD.6) | path voltage drop at ESD.2 current | combined path robustness |
| P8 | G to DD | pad diode to IO, IO-SS clamp, DD-SS clamp in reverse | path drop | same as P4 and P6 |
| P9 | G to G | pad A to IO or VSS, rail, then pad B | rail IR drop, both diodes | rail current density at the pulse |

## 6. Latch-up and guard rings

<!-- rows:begin LU -->
| id | parameter | target | fallback | stretch | rationale | pdk_independent |
|---|---|---|---|---|---|---|
| LU.1 | Guard rings, drivers | Closed p+ tap ring tied to VSS around every NMOS driver / clamp, closed n+ tap ring tied to VDDIO around every PMOS driver; each ring a single closed annulus | Ring around the NMOS devices only | Second (double) ring around output drivers | Guard rings are the main latch-up control at an I/O. The closed-annulus check exists in klt (ring-check). | yes |
| LU.2 | Tap distance, I/O region | Every diffusion within 10 µm (Euclidean) of a qualifying tap, per well island | 15 µm | — | INTERIM internal value, tighter than a core rule. No latch-up distance rule is in klt's sky130 deck (klt-rule-coverage.md); replace with the foundry figure once pinned. | no |
| LU.3 | I/O-to-core well spacing | I/O driver wells at least 20 µm from core wells, with the VSS guard ring between | 10 µm | — | INTERIM internal value; replace with the foundry figure once pinned. | no |
| LU.4 | Pad-connected diffusion | Every n+ diffusion connected to a pad lies inside a p-type guard ring tied to VSS and within LU.2 of a tap | — | — | Pad diffusion is the injection source for an overshoot or undershoot event. | yes |
| LU.5 | Latch-up test | JESD78 class I, +/-100 mA on each I/O at 25 C; a silicon test | — | Class II (125 C) | Design target. Not simulated and not verifiable pre-silicon. | yes |
<!-- rows:end LU -->

The values in LU.2 and LU.3 are interim internal figures; klt's sky130 deck has
no latch-up distance rule (see `klt-rule-coverage.md`).

## 7. PVT corners

<!-- rows:begin PVT -->
| id | parameter | target | fallback | stretch | rationale | pdk_independent |
|---|---|---|---|---|---|---|
| PVT.1 | Process corners | tt, ff, ss, sf, fs: the model-library sections of the same names in sky130.lib.spice (MOS skew, resistors and capacitors typical) | tt, ss, ff only | Add the RC-skew sections (ll, hh, hl, lh) and the _mm Monte Carlo sections | Section names confirmed against the installed library; see decision 0003. klt marks ff, ss, sf and fs 'complete: no' because they skew MOS only. | no |
| PVT.2 | Temperature | -40 C, 25 C, 125 C | 25 C and 125 C | — | The README target. | yes |
| PVT.3 | VDDIO supply points | 2.97 V, 3.30 V, 3.63 V | 3.30 V and one extreme | — | 3.3 V ±10%. | no |
| PVT.4 | VDD supply points | 1.62 V, 1.80 V, 1.98 V | 1.80 V and one extreme | — | 1.8 V ±10%. | no |
| PVT.5 | Corner set | 75 named corners: 5 process x 3 temperature x 5 supply codes (nn, hh, ll, hl, lh; first letter VDDIO, second VDD). Names are listed in io-ring.json under 'corners'. | 27 corners: tt, ss, ff x 3 temperatures x {nn, hh, ll} | — | Cross-supply codes (hl, lh) are the level-shifter stress points. A named, fixed set makes recorded results comparable. | yes |
<!-- rows:end PVT -->

Corner names are `<process>_<temperature>_<supply>`:

- process: `tt ff ss sf fs`;
- temperature: `m40C` (-40 C), `25C`, `125C`;
- supply: `nn` (VDDIO 3.30 V, VDD 1.80 V), `hh` (3.63 V, 1.98 V),
  `ll` (2.97 V, 1.62 V), `hl` (3.63 V, 1.62 V), `lh` (2.97 V, 1.98 V).

The full list of 75 is in `io-ring.json` under `corners`. Example:
`ss_125C_ll` is slow-slow, 125 C, both supplies at -10 %.

## 8. Signoff

<!-- rows:begin SIGN -->
| id | parameter | target | fallback | stretch | rationale | pdk_independent |
|---|---|---|---|---|---|---|
| SIGN.1 | DRC | Zero violations from the pinned sky130 deck (klt drc). Rule classes the deck does not check are reported 'not checked', never 'clean'. | Same | Foundry I/O rules added once klt covers them | Clean means clean against what the deck checks. See klt-rule-coverage.md. | yes |
| SIGN.2 | LVS | Zero mismatches (klt extract + klt lvs) against the schematic netlist for every device klt can extract. Devices outside the deck's classes (protection diodes) are listed as 'not extracted'. | Same | — | The deck has no diode class (issue filed upstream). | yes |
| SIGN.3 | Latch-up / guard ring | klt ring-check passes on each guard ring (single closed annulus); klt tap-distance passes at LU.2 per well island | Ring check only | — | The tap-distance command exists; the foundry latch-up distance is not in the deck, so the value is LU.2. | yes |
| SIGN.4 | Ring ERC | Each rail net is one connected component through every cell abutment; every well has at least one tie; no floating well | Rail continuity only | — | No klt command checks this directly; interim method uses klt components and tap-distance. Gap filed upstream. | yes |
| SIGN.5 | ESD rule check | Foundry ESD layout rules checked by a named procedure | Documented manual review | — | The sky130 deck carries no ESD rules; until klt does, this row reads 'not checked'. | yes |
| SIGN.6 | Evidence record | Every signoff result records the PDK build, the klt version and the deck content hash; results are append-only | — | — | So a result can be reproduced against the same deck. | yes |
<!-- rows:end SIGN -->

## 9. Open questions, answered

**Which I/O-specific rules does klt's sky130 deck check today?** Almost none;
see [`klt-rule-coverage.md`](klt-rule-coverage.md). Three tool gaps were filed
at `2AMLogic/klayout-tools`: #3802, #3803, #3804.

**Can ngspice with the PDK's models represent clamp behaviour well enough to
size the ESD network?** Partly. Turn-on and forward-conduction paths, yes;
snapback, second breakdown and failure currents, no. Section 5.1 states what
is claimed; decision 0004 chooses the topology so the sizing rests on the
parts the models cover.

**What does the port need from this repo as structured data?** `io-ring.json`
(rows with `pdk_independent`, `statistical`, and the corner list). The
PDK-independent rows are the ones to carry over; the others are re-derived.
