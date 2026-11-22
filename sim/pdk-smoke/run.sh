#!/usr/bin/env bash
# PDK smoke: DC operating point + Id-Vgs sweep of one NMOS and one PMOS from the
# 1.8 V core and the thick-oxide g5v0d10v5 families, at tt / 27 C.
# Proves the models load and converge. Chooses no device, supply or cell:
# the bias, W and L below are arbitrary smoke values, not design values.
#
#   bash sim/pdk-smoke/run.sh [OUTDIR]     # default OUTDIR: sim/pdk-smoke/record
#
# Writes OUTDIR/{netlists/,logs/,record.json}; refuses to overwrite an existing
# OUTDIR (records are append-only). One ngspice run: loading the sky130 library
# costs about a minute on its own, so the four independent device circuits share
# a netlist rather than paying that four times.
set -euo pipefail
# shellcheck source=../lib/run_common.sh
source "$(dirname "$0")/../lib/run_common.sh"
run_common_setup "${1:-}"

# Shared smoke device table: identical numbers in sim/corner-skew-probe, so
# the tt currents there are directly comparable with the committed smoke record.
# shellcheck source=../lib/smoke_devices.sh
source "${repo}/sim/lib/smoke_devices.sh"
devices="${smoke_devices}"

emit() { # libpath
  echo "* pdk-smoke: DC op + Id-Vgs per device, tt, 27 C"
  echo ".lib $1 tt"
  echo ".temp 27"
  local name model type vsup w l
  while IFS='|' read -r name model type vsup w l; do
    [ -n "${name}" ] || continue
    if [ "${type}" = n ]; then
      echo "Vd_${name} d_${name} 0 ${vsup}"
      echo "Vg_${name} g_${name} 0 ${vsup}"
      echo "XM_${name} d_${name} g_${name} 0 0 ${model} w=${w} l=${l}"
    else # source/bulk on the rail; gate at 0 = full |Vgs|
      echo "Vs_${name} s_${name} 0 ${vsup}"
      echo "Vd_${name} d_${name} 0 0"
      echo "Vg_${name} g_${name} 0 0"
      echo "XM_${name} d_${name} g_${name} s_${name} s_${name} ${model} w=${w} l=${l}"
    fi
  done <<< "${devices}"
  echo ".control"
  echo "op"
  # operating-point currents, read before dc switches the current plot
  while IFS='|' read -r name model type vsup w l; do
    [ -n "${name}" ] || continue
    if [ "${type}" = n ]; then echo "let idq = -i(Vd_${name})"; else echo "let idq = i(Vd_${name})"; fi
    echo "echo \"RESULT ${name}_op vsup=${vsup} id_A=\$&idq\""
  done <<< "${devices}"
  while IFS='|' read -r name model type vsup w l; do
    [ -n "${name}" ] || continue
    if [ "${type}" = n ]; then
      echo "dc Vg_${name} 0 ${vsup} 0.05"
      echo "let id = -i(Vd_${name})"
      echo "let id0 = id[0]"
    else
      echo "dc Vg_${name} ${vsup} 0 -0.05"
      echo "let id = i(Vd_${name})"
      echo "let id0 = id[0]"
    fi
    # id0 is the first sweep point (|Vgs|=0 for n, gate at the rail for p: both off)
    echo "let idmax = maximum(id)"
    echo "let npts = length(id)"
    echo "echo \"RESULT ${name} vsup=${vsup} id_off_A=\$&id0 id_on_A=\$&idmax points=\$&npts\""
  done <<< "${devices}"
  echo "quit"
  echo ".endc"
  echo ".end"
}

emit "${SKY130_MODEL_LIB}" > "${work}/smoke.sp"
# Snapshot: no absolute paths.
emit '$PDK_ROOT/sky130A/libs.tech/ngspice/sky130.lib.spice' > "${out}/netlists/smoke.sp"

run_common_ngspice "${work}/smoke.sp" "${work}/smoke.log"
run_common_scrub < "${work}/smoke.log" > "${out}/logs/smoke.log"

meta="$(printf '{"kind":"pdk-smoke","pdk_revision":"%s","pdk_variant":"%s","corner":"tt","temp_c":27,"tools":%s,"note":"Models load/converge only; bias, W and L are smoke values, not design choices."}' \
  "${PDK_REVISION}" "${PDK}" "$(run_common_tools_json ngspice ciel xschem)")"
run_common_record "${meta}" --log "smoke=logs/smoke.log"
