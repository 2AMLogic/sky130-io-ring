#!/usr/bin/env bash
# G6 single-corner probe of the two RC supply clamps (ESD.4 VDDIO-VSS, ESD.5
# VDD-VSS): (a) power-up ramps at four rise times, (b) one ESD.2 HBM pulse.
# tt / 27 C only. A probe, not item-5 evidence: it chooses nothing, changes no
# netlist or spec row, and says nothing about ESD rating.
#
#   bash sim/clamp-probe/run.sh [OUTDIR]     # default OUTDIR: sim/clamp-probe/record
#
# Writes OUTDIR/{netlists/,logs/,record.json}; refuses to overwrite an existing
# OUTDIR (records are append-only). ONE ngspice process runs every transient
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

rises='1u 10u 100u 1m'
hbm_v=2000; hbm_c=100p; hbm_r=1500

emit() { # libpath includepath-prefix
  echo "* clamp-probe: G6 single-corner probe, tt, 27 C"
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
    # HBM circuit: C charged to hbm_v discharges through R into VP (VSS = 0)
    echo "Ch_${tag} ch_${tag} 0 ${hbm_c} ic=${hbm_v}"
    echo "Rh_${tag} ch_${tag} vh_${tag} ${hbm_r}"
    echo "Xh${tag} vh_${tag} 0 ${sub}"
    echo ".ic v(ch_${tag})=${hbm_v} v(vh_${tag})=0"
    # 0/1 indicator that GATE is above a probe threshold (0.5 V, 1.0 V), integrated for time-above
    echo "Bi05_${tag} ia05_${tag} 0 V = v(xh${tag}.gate) > 0.5 ? 1 : 0"
    echo "Bi10_${tag} ia10_${tag} 0 V = v(xh${tag}.gate) > 1.0 ? 1 : 0"
  done <<< "${clamps}"
  echo ".control"
  echo "set noaskquit"
  # ESD.7: label for one device pair; nfet/pfet_g5v0d10v5 VDS <= 11.0 V, VGS <= 5.5 V.
  # Printed as label=<token>; the core family has no limit on record.
  local sv="save all"
  while IFS='|' read -r tag sub vnom nm mult; do
    [ -n "${tag}" ] || continue
    sv+=" @m.xr${tag}.xmcl.m${nm}[id] @m.xh${tag}.xmcl.m${nm}[id]"
  done <<< "${clamps}"
  echo "${sv}"

  # ---- power-up ramps: 4 rise times x 2 clamps, sequential in this process
  local tr
  for tr in ${rises}; do
    emit_ramp_step "${tr}" 1
  done

  # ---- ESD.2 HBM pulse: 2 kV, 100 pF, 1.5 kohm, one 10 us transient (uic: C starts charged; long enough to see GATE fall)
  echo "tran 0.2n 10u 0 0.2n uic"
  while IFS='|' read -r tag sub vnom nm mult; do
    [ -n "${tag}" ] || continue
    echo "let vpk = maximum(v(vh_${tag}))"
    echo "let idpk = maximum(@m.xh${tag}.xmcl.m${nm}[id])"
    echo "let ipk = maximum(abs(v(ch_${tag}) - v(vh_${tag}))) / ${hbm_r}"
    echo "let vgpk = maximum(v(xh${tag}.gate))"
    # time GATE stays above a threshold, from the integral of a 0/1 indicator
    echo "meas tran gend_${tag} find v(xh${tag}.gate) at=9.9u"
    echo "meas tran vpend_${tag} find v(vh_${tag}) at=9.9u"
    echo "meas tran tab05_${tag} integ v(ia05_${tag})"
    echo "meas tran tab10_${tag} integ v(ia10_${tag})"
    echo "echo \"RESULT hbm_${tag} vhbm_V=${hbm_v} c_F=${hbm_c} r_ohm=${hbm_r} vp_pk_V=\$&vpk id_xmcl_pk_A=\$&idpk ipulse_pk_A=\$&ipk gate_pk_V=\$&vgpk gate_at_9p9us_V=\$&gend_${tag} vp_at_9p9us_V=\$&vpend_${tag} gate_above_0p5V_s=\$&tab05_${tag} gate_above_1p0V_s=\$&tab10_${tag} decay_tau_s=1.5e-7\""
    emit_validity "xh${tag}" "hbm_${tag}" "${tag}" "vh_${tag}"
  done <<< "${clamps}"
  echo "quit"
  echo ".endc"
  echo ".end"
}

emit "${SKY130_MODEL_LIB}" "${nl}" > "${work}/probe.sp"
# Snapshot: no absolute paths.
emit '$PDK_ROOT/sky130A/libs.tech/ngspice/sky130.lib.spice' '.' > "${out}/netlists/probe.sp"

run_common_ngspice "${work}/probe.sp" "${work}/probe.log"
run_common_scrub < "${work}/probe.log" > "${out}/logs/probe.log"

meta="$(printf '{"kind":"probe","probe":"G6 single-corner RC clamp trigger probe (ESD.4, ESD.5)","pdk_revision":"%s","pdk_variant":"%s","corner":"tt","temp_c":27,"tools":%s,"note":"Single-corner G6 probe, not item-5 evidence; says nothing about ESD rating. No validity range on record for the thin-oxide family."}' \
  "${PDK_REVISION}" "${PDK}" "$(run_common_tools_json ngspice ciel xschem)")"
run_common_record "${meta}" --log "probe=logs/probe.log"
