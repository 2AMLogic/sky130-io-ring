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
here="$(cd "$(dirname "$0")" && pwd)"
repo="$(cd "${here}/../.." && pwd)"
out="${1:-${here}/record}"
[ ! -e "${out}" ] || { echo "run.sh: ${out} exists; records are append-only" >&2; exit 1; }

# shellcheck source=../lib/pdk_env.sh
source "${repo}/sim/lib/pdk_env.sh"
command -v ngspice >/dev/null || { echo "run.sh: ngspice not on PATH" >&2; exit 1; }

mkdir -p "${out}/netlists" "${out}/logs"
work="$(mktemp -d)"; trap 'rm -rf "${work}"' EXIT

nl="${repo}/design/netlists"
# The clamp subcircuits are included unchanged. Copies in the snapshot keep the
# record self-contained; the io netlist's absolute sch_path comment is scrubbed.
for c in io core; do
  sed -e "s#/[^ ]*/design/xschem/#\$REPO/design/xschem/#" "${nl}/sky130_ioring_clamp_${c}.spice" \
    > "${out}/netlists/sky130_ioring_clamp_${c}.spice"
done

# tag|subckt|vnom|nmos_model|mult_xmcl (mult is informational: ngspice's [id] of the
# subcircuit device is already the total, checked against the supply current)
#   tag io:   VDDIO clamp, thick-oxide family (ESD.7 limits apply)
#   tag core: VDD clamp, thin-oxide family (no ESD.7 limit on record)
clamps='
io|sky130_ioring_clamp_io|5.0|sky130_fd_pr__nfet_g5v0d10v5|400
core|sky130_ioring_clamp_core|1.8|sky130_fd_pr__nfet_01v8|800
'
rises='1u 10u 100u 1m'
hold_s=5e-5; hold=50u # time at nominal after the ramp (50 tau of the ~1 us trigger) before reading leakage
hbm_v=2000; hbm_c=100p; hbm_r=1500

# (device : drain gate source) of every clamp transistor, ESD.7 pairs per device
# name|d|g|s|polarity
devs='
mp1|g1|t|vp|p
mn1|g1|t|0|n
mp2|g2|g1|vp|p
mn2|g2|g1|0|n
mp3|gate|g2|vp|p
mn3|gate|g2|0|n
mcl|vp|gate|0|n
'

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
  local tr stop
  for tr in ${rises}; do
    stop="$(awk -v tr="${tr}" -v h="${hold}" 'function s(x){u=substr(x,length(x)); v=substr(x,1,length(x)-1)+0;
      return v*(u=="u"?1e-6:u=="m"?1e-3:u=="n"?1e-9:1)} BEGIN{printf "%.6g", s(tr)+s(h)}')"
    echo "alter Vr_io pulse = [ 0 5.0 0 ${tr} 1 1 1 ]"
    echo "alter Vr_core pulse = [ 0 1.8 0 ${tr} 1 1 1 ]"
    echo "tran $(awk -v t="${stop}" 'BEGIN{printf "%.4g", t/4000}') ${stop} 0 $(awk -v t="${stop}" 'BEGIN{printf "%.4g", t/1000}')"
    echo "let tend = ${stop}"
    echo "let nn = length(time)"
    while IFS='|' read -r tag sub vnom nm mult; do
      [ -n "${tag}" ] || continue
      echo "let idpk = maximum(@m.xr${tag}.xmcl.m${nm}[id])"
      echo "let vgpk = maximum(v(xr${tag}.gate))"
      echo "let ilk = -i(Vr_${tag})[nn-1]"
      echo "let ipk = maximum(abs(i(Vr_${tag})))"
      echo "echo \"RESULT ramp_${tag}_${tr} vnom=${vnom} tr_s=${tr} id_xmcl_pk_A=\$&idpk gate_pk_V=\$&vgpk isup_pk_A=\$&ipk ileak_end_A=\$&ilk\""
      emit_validity "xr${tag}" "ramp_${tag}_${tr}" "${tag}"
    done <<< "${clamps}"
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
    emit_validity "xh${tag}" "hbm_${tag}" "${tag}"
  done <<< "${clamps}"
  echo "quit"
  echo ".endc"
  echo ".end"
}

# Peak |VDS| and |VGS| of every clamp transistor and the ESD.7 comparison.
emit_validity() { # instance resultname tag
  local inst="$1" rname="$2" tag="$3" name d g s pol vds vgs
  local node
  node() { case "$1" in 0) echo 0;; vp) echo "v(${inst/x/x}_vp)";; *) echo "v(${inst}.$1)";; esac; }
  local vpn
  case "${inst}" in xr*) vpn="vr_${tag}";; xh*) vpn="vh_${tag}";; esac
  node() { case "$1" in 0) echo "0";; vp) echo "v(${vpn})";; *) echo "v(${inst}.$1)";; esac; }
  while IFS='|' read -r name d g s pol; do
    [ -n "${name}" ] || continue
    echo "let pvds = maximum(abs($(node "${d}") - $(node "${s}")))"
    echo "let pvgs = maximum(abs($(node "${g}") - $(node "${s}")))"
    if [ "${tag}" = io ]; then
      echo "if ( pvds > 11.0 | pvgs > 5.5 )"
      echo "  set lab = outside_model_validity"
      echo "else"
      echo "  set lab = within_esd7_model_range"
      echo "end"
    else
      echo "set lab = no_validity_range_on_record"
    fi
    echo "echo \"RESULT esd7_${rname}_${name} vds_pk_V=\$&pvds vgs_pk_V=\$&pvgs validity=\$lab\""
  done <<< "${devs}"
}

emit "${SKY130_MODEL_LIB}" "${nl}" > "${work}/probe.sp"
# Snapshot: no absolute paths.
emit '$PDK_ROOT/sky130A/libs.tech/ngspice/sky130.lib.spice' '.' > "${out}/netlists/probe.sp"

rc=0
(cd "${work}" && ngspice -b -o "${work}/probe.log" "${work}/probe.sp" </dev/null >/dev/null 2>&1) || rc=$?
[ "${rc}" -eq 0 ] || echo "run.sh: ngspice exited ${rc}" >&2
sed -e "s#${PDK_ROOT}#\$PDK_ROOT#g" -e "s#${work}#\$WORK#g" -e "s#${repo}#\$REPO#g" "${work}/probe.log" > "${out}/logs/probe.log"

ngspice_ver="$(ngspice --version | sed -n 's/.*ngspice-\([0-9.]*\).*/\1/p' | head -n1)"
ciel_ver="$(ciel --version 2>/dev/null | sed -n 's/^Ciel v\([0-9.]*\).*/\1/p' | head -n1)" || true
xschem_ver="$(xschem --version 2>&1 | sed -n 's/^XSCHEM V\([0-9.]*\).*/\1/p' | head -n1)" || true
meta="$(printf '{"kind":"probe","probe":"G6 single-corner RC clamp trigger probe (ESD.4, ESD.5)","pdk_revision":"%s","pdk_variant":"%s","corner":"tt","temp_c":27,"tools":{"ngspice":"%s","ciel":"%s","xschem":"%s"},"note":"Single-corner G6 probe, not item-5 evidence; says nothing about ESD rating. No validity range on record for the thin-oxide family."}' \
  "${PDK_REVISION}" "${PDK}" "${ngspice_ver}" "${ciel_ver:-unavailable}" "${xschem_ver:-unavailable}")"

cd "${out}"
python3 -I "${repo}/sim/lib/simrec.py" write record.json --meta "${meta}" --log "probe=logs/probe.log"
