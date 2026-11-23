#!/usr/bin/env bash
# G6 follow-up single-corner probe of the two RC supply clamps (ESD.4
# VDDIO-VSS, ESD.5 VDD-VSS): (a) a supply rise-time sweep from 1 us to 10 us
# (integer steps plus 0.25 us refinement across the transitions) resolving
# where the false trigger stops, (b) a settling study of the 1 us ramp that
# resolves the negative post-ramp supply current the first probe left open.
# tt / 27 C only. A probe, not item-5 evidence: it chooses nothing, changes no
# netlist or spec row, proposes no supply rise-time requirement, and says
# nothing about ESD rating.
#
#   bash sim/clamp-trigger-probe/run.sh [OUTDIR]  # default OUTDIR: sim/clamp-trigger-probe/record
#
# Writes OUTDIR/{netlists/,logs/,record.json}; refuses to overwrite an existing
# OUTDIR (records are append-only). ONE ngspice process runs every analysis
# one after another: loading the sky130 library is paid once, and this is a
# single-corner run, not a grid (no corners, no Monte Carlo, no parallel jobs).
set -euo pipefail
# shellcheck source=../lib/run_common.sh
source "$(dirname "$0")/../lib/run_common.sh"
# shellcheck source=../lib/clamp_common.sh
source "$(dirname "$0")/../lib/clamp_common.sh"
run_common_setup "${1:-}"

nl="${repo}/design/netlists"
clamp_snapshot "${nl}"

# rise times: the first probe's 1 us and 10 us endpoints (same hold and the
# same tran-step scheme, so the rows compare directly), integer steps across
# the whole bracket, and 0.25 us refinement across the 5-8 us transitions.
rises='1u 2u 3u 4u 5u 5.25u 5.5u 5.75u 6u 6.25u 6.5u 6.75u 7u 7.25u 7.5u 7.75u 8u 9u 10u'
samples='2u 5u 10u 20u 51u 60u 100u 200u 300u 500u 700u 1000u'

emit() { # libpath includepath-prefix
  echo "* clamp-trigger-probe: G6 follow-up single-corner probe, tt, 27 C"
  echo ".lib $1 tt"
  echo ".temp 27"
  echo ".include $2/sky130_ioring_clamp_io.spice"
  echo ".include $2/sky130_ioring_clamp_core.spice"
  local tag sub vnom nm mult
  while IFS='|' read -r tag sub vnom nm mult; do
    [ -n "${tag}" ] || continue
    # power-up ramp circuit
    echo "Vr_${tag} vr_${tag} 0 pulse(0 ${vnom} 0 1u 1 1 1)"
    echo "Xr${tag} vr_${tag} 0 ${sub}"
    # separate DC-biased instance for the operating-point leakage only
    echo "Vd_${tag} vd_${tag} 0 ${vnom}"
    echo "Xd${tag} vd_${tag} 0 ${sub}"
  done <<< "${clamps}"
  echo ".control"
  echo "set noaskquit"
  local sv="save all"
  while IFS='|' read -r tag sub vnom nm mult; do
    [ -n "${tag}" ] || continue
    sv+=" @m.xr${tag}.xmcl.m${nm}[id]"
  done <<< "${clamps}"
  echo "${sv}"

  # ---- operating point: the DC leakage each clamp settles to at nominal VP
  echo "op"
  while IFS='|' read -r tag sub vnom nm mult; do
    [ -n "${tag}" ] || continue
    echo "let ilkd = -i(Vd_${tag})"
    echo "echo \"RESULT dcop_${tag} vp_V=${vnom} ileak_dc_A=\$&ilkd\""
  done <<< "${clamps}"
  echo "alter Vd_io = 0"
  echo "alter Vd_core = 0"

  # ---- rise-time sweep: 19 rise times x 2 clamps, sequential in this process.
  # Same hold and tran-step scheme as the first probe, so the 1 us and 10 us
  # rows compare with its ramp rows directly.
  local tr
  for tr in ${rises}; do
    emit_ramp_step "${tr}" 0
  done

  # ---- 1 us settling: the same circuit and the same 1.01 ms window three
  # times at default solver tolerances, differing only in the tran step and
  # maximum timestep; then once more with tightened tolerances. The sampled
  # node voltages show the circuit state, the sampled supply current shows
  # what the solver reports on it.
  local cfg tstep tmax
  for cfg in "tmax50n|50n|50n" "tmax510n|250n|510n" "tmax1.01u|252.5n|1.01u"; do
    IFS='|' read -r cfg tstep tmax <<< "${cfg}"
    echo "alter Vr_io pulse = [ 0 5.0 0 1u 1 1 1 ]"
    echo "alter Vr_core pulse = [ 0 1.8 0 1u 1 1 1 ]"
    echo "tran ${tstep} 1.01m 0 ${tmax}"
    emit_settle "${cfg}" "${tstep}" "${tmax}" default
  done
  echo "option reltol=1e-6 abstol=1e-15 vntol=1e-9"
  echo "alter Vr_io pulse = [ 0 5.0 0 1u 1 1 1 ]"
  echo "alter Vr_core pulse = [ 0 1.8 0 1u 1 1 1 ]"
  echo "tran 50n 1.01m 0 50n"
  emit_settle tight 50n 50n tight

  echo "quit"
  echo ".endc"
  echo ".end"
}

# Sampled evidence of one settling run: signed supply current (positive when
# the rail delivers) plus the clamp node voltages, at a fixed sample list.
emit_settle() { # cfg tstep tmax tol
  local cfg="$1" tstep="$2" tmax="$3" tol="$4" tag t
  for tag in io core; do
    echo "let nn = length(time)"
    echo "let ilke = -i(Vr_${tag})[nn-1]"
    echo "echo \"RESULT settle_${cfg}_${tag}_end tstep_s=${tstep} tmax_s=${tmax} tol=${tol} t_s=1.01m ileak_A=\$&ilke\""
    for t in ${samples}; do
      echo "meas tran i_${tag} find i(Vr_${tag}) at=${t}"
      echo "meas tran vp_${tag} find v(vr_${tag}) at=${t}"
      echo "meas tran t1_${tag} find v(xr${tag}.t1) at=${t}"
      echo "meas tran tt_${tag} find v(xr${tag}.t) at=${t}"
      echo "meas tran g1_${tag} find v(xr${tag}.g1) at=${t}"
      echo "meas tran g2_${tag} find v(xr${tag}.g2) at=${t}"
      echo "meas tran ga_${tag} find v(xr${tag}.gate) at=${t}"
      echo "let ilkt = -i_${tag}"
      echo "echo \"RESULT settle_${cfg}_${tag}_t${t} tstep_s=${tstep} tmax_s=${tmax} tol=${tol} t_s=${t} ileak_A=\$&ilkt vp_V=\$&vp_${tag} t1_V=\$&t1_${tag} t_V=\$&tt_${tag} g1_V=\$&g1_${tag} g2_V=\$&g2_${tag} gate_V=\$&ga_${tag}\""
    done
  done
}

emit "${SKY130_MODEL_LIB}" "${nl}" > "${work}/probe.sp"
# Snapshot: no absolute paths.
emit '$PDK_ROOT/sky130A/libs.tech/ngspice/sky130.lib.spice' '.' > "${out}/netlists/probe.sp"

run_common_ngspice "${work}/probe.sp" "${work}/probe.log"
run_common_scrub < "${work}/probe.log" > "${out}/logs/probe.log"

meta="$(printf '{"kind":"probe","probe":"G6 follow-up probe: clamp false-trigger rise-time transition and settled leakage (ESD.4, ESD.5)","pdk_revision":"%s","pdk_variant":"%s","corner":"tt","temp_c":27,"tools":%s,"note":"Single-corner G6 follow-up probe, not item-5 evidence; says nothing about ESD rating. The GATE thresholds 0.5 V and 1.0 V and the clamp-current threshold 1 mA are round probe values, not extracted device thresholds. The settled leakage is read at tightened solver tolerances (reltol=1e-6, abstol=1e-15, vntol=1e-9); the default-tolerance settling runs are kept alongside it because they show the timestep artifact behind the first probe negative post-ramp readings. No validity range on record for the thin-oxide family."}' \
  "${PDK_REVISION}" "${PDK}" "$(run_common_tools_json ngspice ciel xschem)")"
run_common_record "${meta}" --log "probe=logs/probe.log"
