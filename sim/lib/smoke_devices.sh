#!/usr/bin/env bash
# sky130 half of the harness: the shared smoke device table. Source it; do not
# execute. name|model|type|vsup|W|L for the four smoke devices, model names as
# shipped in the pinned sky130 library; W, L in um (the library sets
# .option scale=1.0u). Identical in sim/pdk-smoke and sim/corner-skew-probe so
# their tt currents are directly comparable. Smoke values, not design values.

# shellcheck disable=SC2034  # assigned for the sourcers
smoke_devices='
nfet_01v8|sky130_fd_pr__nfet_01v8|n|1.8|1.0|0.15
pfet_01v8|sky130_fd_pr__pfet_01v8|p|1.8|1.0|0.15
nfet_g5v0d10v5|sky130_fd_pr__nfet_g5v0d10v5|n|5.0|1.0|0.5
pfet_g5v0d10v5|sky130_fd_pr__pfet_g5v0d10v5|p|5.0|1.0|0.5
'
