#!/usr/bin/env bash
# First GPIO bench: single-corner (tt, 27 C, nominal rails) probe of the drawn
# GPIO cell. A probe, not item-5 evidence: no corner, no temperature sweep, no
# Monte Carlo, no post-layout, says nothing about ESD rating. Measurement
# definitions are in sim/lib/gpio_measurements.sp (PDK-independent); this file
# binds the cell, the pinned model library and the rails.
#
#   bash sim/gpio-probe/run.sh [OUTDIR]     # default OUTDIR: sim/gpio-probe/record
#
# Writes OUTDIR/{netlists/,logs/,record.json}; refuses an existing OUTDIR
# (records are append-only). ONE ngspice process runs every analysis.
set -euo pipefail
# shellcheck source=../lib/run_common.sh
source "$(dirname "$0")/../lib/run_common.sh"
run_common_setup "${1:-}"
export OMP_NUM_THREADS=2 # shared host: keep ngspice off the other sweeps' cores

nl="${repo}/design/netlists"
deck="${repo}/sim/lib/gpio_measurements.sp"
vddio_v=3.30 # I/O rail, nominal
vdd_v=1.80   # core rail, nominal

# The GPIO netlist is included unchanged (its absolute sch_path comment is
# scrubbed in the snapshot only).
sed -e "s#/[^ ]*/design/xschem/#\$REPO/design/xschem/#" "${nl}/sky130_ioring_gpio.spice" \
  > "${out}/netlists/sky130_ioring_gpio.spice"

emit() { # libpath netlist-dir deckpath
  echo "* gpio-probe: single-corner probe, tt, 27 C, nominal rails"
  echo ".lib $1 tt"
  echo ".temp 27"
  echo ".param vddio_v=${vddio_v} vdd_v=${vdd_v}"
  echo ".include $2/sky130_ioring_gpio.spice"
  echo ".subckt gpio_dut A OE IE PU PD Y PAD VDDIO VDD VSS"
  echo "X1 A OE IE PU PD Y PAD VDDIO VDD VSS sky130_ioring_gpio"
  echo ".ends"
  echo ".include $3"
  echo ".end"
}

emit "${SKY130_MODEL_LIB}" "${nl}" "${deck}" > "${work}/probe.sp"
emit '$PDK_ROOT/sky130A/libs.tech/ngspice/sky130.lib.spice' '.' '$REPO/sim/lib/gpio_measurements.sp' > "${out}/netlists/probe.sp"
cp "${deck}" "${out}/netlists/gpio_measurements.sp"

run_common_ngspice "${work}/probe.sp" "${work}/probe.log"
run_common_scrub < "${work}/probe.log" > "${out}/logs/probe.log"

# every RESULT line the deck can print must be present and finite
expect="$(sed -n 's/^echo "RESULT \([^ ]*\) .*/\1/p' "${deck}" | paste -sd, -)"

meta="$(printf '{"kind":"probe","probe":"first GPIO single-corner probe (GF.1-3, GF.7-8, GE.1-8, GE.10 definitions)","pdk_revision":"%s","pdk_variant":"%s","corner":"tt","temp_c":27,"vddio_v":%s,"vdd_v":%s,"tools":%s,"note":"Single-corner probe, not item-5 evidence. Values sit next to each row'"'"'s proposed target as text; there is no pass/fail field. No corner, no temperature, no post-layout, no ESD claim."}' \
  "${PDK_REVISION}" "${PDK}" "${vddio_v}" "${vdd_v}" "$(run_common_tools_json ngspice ciel xschem)")"
run_common_record "${meta}" --log "probe=logs/probe.log" --expect "probe=${expect}"
