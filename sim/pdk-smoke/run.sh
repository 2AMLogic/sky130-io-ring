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
here="$(cd "$(dirname "$0")" && pwd)"
repo="$(cd "${here}/../.." && pwd)"
out="${1:-${here}/record}"
[ ! -e "${out}" ] || { echo "run.sh: ${out} exists; records are append-only" >&2; exit 1; }

# shellcheck source=../lib/pdk_env.sh
source "${repo}/sim/lib/pdk_env.sh"
command -v ngspice >/dev/null || { echo "run.sh: ngspice not on PATH" >&2; exit 1; }

mkdir -p "${out}/netlists" "${out}/logs"
work="$(mktemp -d)"; trap 'rm -rf "${work}"' EXIT

# name|model|type|vsup|W|L   (model names as shipped in the pinned library)
devices='
nfet_01v8|sky130_fd_pr__nfet_01v8|n|1.8|1.0|0.15
pfet_01v8|sky130_fd_pr__pfet_01v8|p|1.8|1.0|0.15
nfet_g5v0d10v5|sky130_fd_pr__nfet_g5v0d10v5|n|5.0|1.0|0.5
pfet_g5v0d10v5|sky130_fd_pr__pfet_g5v0d10v5|p|5.0|1.0|0.5
'

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

rc=0
(cd "${work}" && ngspice -b -o "${work}/smoke.log" "${work}/smoke.sp" </dev/null >/dev/null 2>&1) || rc=$?
[ "${rc}" -eq 0 ] || echo "run.sh: ngspice exited ${rc}" >&2
sed -e "s#${PDK_ROOT}#\$PDK_ROOT#g" -e "s#${work}#\$WORK#g" "${work}/smoke.log" > "${out}/logs/smoke.log"

ngspice_ver="$(ngspice --version | sed -n 's/.*ngspice-\([0-9.]*\).*/\1/p' | head -n1)"
ciel_ver="$(ciel --version 2>/dev/null | sed -n 's/^Ciel v\([0-9.]*\).*/\1/p' | head -n1)"
xschem_ver="$(xschem --version 2>&1 | sed -n 's/^XSCHEM V\([0-9.]*\).*/\1/p' | head -n1)"
meta="$(printf '{"kind":"pdk-smoke","pdk_revision":"%s","pdk_variant":"%s","corner":"tt","temp_c":27,"tools":{"ngspice":"%s","ciel":"%s","xschem":"%s"},"note":"Models load/converge only; bias, W and L are smoke values, not design choices."}' \
  "${PDK_REVISION}" "${PDK}" "${ngspice_ver}" "${ciel_ver:-unavailable}" "${xschem_ver:-unavailable}")"

cd "${out}"
python3 -I "${repo}/sim/lib/simrec.py" write record.json --meta "${meta}" --log "smoke=logs/smoke.log"
