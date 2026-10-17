# klt rule coverage for the I/O rule classes (sky130)

Answers the first open question of issue #2: which I/O-specific rules does
klt's sky130 deck check today? A rule class listed "not checked" is a
friction item filed upstream, not a rule to ignore; signoff reports it as
"not checked", never "clean" (SIGN.1).

**Inspected**: klt `0.7.1.dev1765+gb61f753d0369`; sky130 curated deck content
hash `sha256:f3e6a304b5d7e02301b14643fab17e3a455e145b4ba684dc66b645c2016e5865`;
PDK sky130A, open_pdks `f6eeac7d`. Single local, read-only runs; no layout was
checked. The curated deck is `klt drc --deck sky130` (default engine); the
other engine, `klt drc --engine klayout`, runs the PDK's own KLayout deck
(`libs.tech/klayout/drc/sky130A_mr.drc`).

## How the numbers were obtained

```
klt deck rules --deck sky130 --format json     # 150 rules, 75 after dropping ongrid / angle rules
klt deck devices --deck sky130                 # device classes recognised for extraction / LVS
klt deck info                                  # same class list, release status
klt pdk corners --pdk sky130A                  # model-library corner names
klt ring-check --help ; klt tap-distance --help; klt erc --help
# native deck rule ids: the output(...) names in sky130A_mr.drc (178 unique ids)
```

## Coverage by rule class

| Class | Curated deck (`--engine curated`) | Native deck (`--engine klayout`) | Other klt command | Verdict | Upstream |
|---|---|---|---|---|---|
| Thick-oxide / high-voltage layers (hvi, hvntm, vhvi, uhvi) | Only `nwell.enclosed.hvi.1` (the HV n-well must sit inside the hvi marker); `hvi`, `hvntm`, `vhvi`, `uhvi` and `pad` carry only grid and angle rules | `hvi.1`, `hvi.2a`, `hvntm.1`, `hvntm.2`, `hvtp.*`, `hvtr.*`, `dnwell.1`, `dnwell.2`, `nwell.9`, `pad.2` | none | **Partly checked.** Width / spacing of the thick-oxide marker layers only via the native engine, which needs a standalone `klayout` binary | [klayout-tools#3802](https://github.com/2AMLogic/klayout-tools/issues/3802) |
| Latch-up distance (tap spacing) | No rule | No rule (no id contains latch / tap distance) | `klt tap-distance` computes a distance for a caller-supplied value | **Not checked by any deck.** The command exists; the foundry value is not in the deck. LU.2 / LU.3 use interim internal values | #3802 |
| Guard ring | No rule | No rule | `klt ring-check` asserts a layer set forms a single closed annulus (geometry only; no net or construction check) | **Checkable for closure only.** Construction (p+ ring on VSS, n+ ring on VDDIO) is not verified | #3802 |
| ESD (implant / marker / device rules) | No rule | No rule (no id contains esd) | none | **Not checked.** SIGN.5 reads "not checked" | #3802 |
| Protection diodes in LVS | No diode class: classes are nfet, pfet, pnp, two MiM caps and eight resistor kinds | n/a | `klt extract` / `klt lvs` use the curated classes | **Not extracted.** A protection network would be missing from the extracted netlist | [klayout-tools#3803](https://github.com/2AMLogic/klayout-tools/issues/3803) |
| Ring continuity (rail through every abutment, no floating well) | n/a | n/a | `klt erc` is an antenna / connectivity-ratio check; `klt components` reports connected components but takes no expected nets and returns no pass / fail | **Not checked directly.** SIGN.4's interim method composes `klt components` and `klt tap-distance` | [klayout-tools#3804](https://github.com/2AMLogic/klayout-tools/issues/3804) |

The same two gaps exist for the `gf180mcu` deck and are already tracked
upstream (#3792, #3793); the sky130 reports are separate issues because the
decks and rule ids differ.

## What this means for the spec

- DRC "clean" (SIGN.1) means clean against the rules in the pinned deck. For
  the I/O classes above it says nothing about latch-up distance or ESD.
- The two latch-up distances in LU.2 / LU.3 are interim and flagged as such in
  the spec; they are replaced when the foundry figure is pinned.
- Corner names: `klt pdk corners --pdk sky130A` shows `tt ff ss sf fs` present,
  with `ff ss sf fs` marked "complete: no" (MOS-only skew); see decision 0003.

## Not checked in this survey

- Whether the curated deck's width / spacing rules for the thick-oxide
  devices' diffusion and poly match the 5 V device rules (the deck has one
  `diff.width.1` row; whether the 5 V device uses a different value was not
  examined).
- The native deck was read, not run: no layout exists yet.
