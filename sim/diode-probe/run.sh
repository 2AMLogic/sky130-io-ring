#!/usr/bin/env bash
# diode-probe: G1 / ESD.3 single-corner probe of the GPIO pad diodes
# (design/netlists/sky130_ioring_gpio_esd.spice) at the ESD.2 current.
#
#   (a) the forward voltage of every diode in the cell over a forced-current
#       sweep that reaches the ESD.2 peak (1.33333 A = 2000 V / 1500 ohm), run
#       in both pad polarities at the SUP.1 nominal VDDIO;
#   (b) the same at the ESD.2 peak only, across the SUP.1 supply range
#       (2.97 / 3.30 / 3.63 V) plus a 5.0 V comparison point, because the ESD.7
#       verdict on the reverse-biased diode is set by the rail, not by the pad;
#   (c) the same quantity under one ESD.2 HBM pulse (100 pF, 2 kV, 1.5 kohm)
#       per polarity, each fired from several different starting states so the
#       recorded figure is shown invariant instead of taken on trust;
#   (d) two self-tests of the HBM source network alone, no design device in the
#       loop, so the gun's peak current, decay and delivered charge are
#       established before any pad number is read from it.
#
# tt / 27 C only. A probe, not item-5 evidence: it chooses nothing, changes no
# netlist or spec row, and says nothing about ESD rating (ESD.10). The diode
# areas in the netlist are explicit placeholders (gate G1, decision 0004), so
# every voltage here is the drop of a placeholder at a placeholder area.
#
#   bash sim/diode-probe/run.sh [OUTDIR]     # default OUTDIR: sim/diode-probe/record
#
# Writes OUTDIR/{netlists/,logs/,record.json}; refuses to overwrite an existing
# OUTDIR (records are append-only). ONE ngspice process runs every analysis one
# after another: the sky130 library is loaded once, and this is a single-corner
# run, not a grid (no corners, no Monte Carlo, no parallel jobs).
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
cell=sky130_ioring_gpio_esd
src="${nl}/${cell}.spice"
# The cell is included unchanged. The copy in the snapshot keeps the record
# self-contained; its line-1 absolute sch_path comment is scrubbed.
sed -e "s#/[^ ]*/design/xschem/#\$REPO/design/xschem/#" "${src}" > "${out}/netlists/${cell}.spice"

# ---- ESD.2 stress network (spec/io-ring.md row ESD.2) and the probe grid
hbm_v=2000; hbm_c=100p; hbm_r=1500; hbm_tau=1.5e-7
i_esd2=1.33333                       # 2000 V / 1500 ohm, the ESD.2 peak
# SUP.1 I/O supply: 3.3 V +/-10%. vddio_nom carries the main sweep and the
# pulse; vddio_set adds the range ends at the ESD.2 peak only. 5.0 is not a
# SUP.1 point: it is the comparison rail the 5 V device flavour (SUP.3) and the
# earlier clamp probe used, kept so the two records can be compared.
vddio_nom=3.3
vddio_set="2.97 3.63 5.0"
vddio_cmp=5.0                        # fixed second rail, for the pulse comparison
# The forced-current sweep: 0 A quiescent, three decades, then a cluster across
# the 0.38 to 0.42 A region (where the pad voltage turns over) up to the ESD.2
# peak. 6.66667e-1 is the ESD.2 fallback row (1 kV). Each current is solved as
# its OWN operating point, not as a continuation of the previous one: a `dc`
# continuation across the turnover returns non-physical intermediate points.
i_list="0 1.33333e-3 1.33333e-2 1.33333e-1 0.3 0.38 0.39 0.395 0.4 0.42 0.5 6.66667e-1 1.0 ${i_esd2}"
t_stop=2u                            # covers the 500 ns fire time plus ~10 tau

# ---- model and instance parameters, read from the pinned PDK and from the
# design netlist so the figures in the record are derived here, never hardcoded.
mdir="${PDK_ROOT}/${PDK}/libs.ref/sky130_fd_pr/spice"
mparam() { # model-file param -> raw value ('a/b' kept as written)
  awk -v p="$2" '$1=="+" && $2==p && $3=="=" {v=$4; gsub(/\x27/,"",v); print v; exit}' "$1"
}
num() { # evaluate a model value, which may be the 'a/b' form the cards use
  awk -v e="$1" 'BEGIN{n=split(e,a,"/"); printf "%.6g", (n==2 ? a[1]/a[2] : a[1]+0)}'
}
iparam() { # instance param from the design netlist: iparam XDP area
  awk -v inst="$1" -v p="$2" '$1==inst{for(i=1;i<=NF;i++) if($i ~ "^"p"="){sub("^"p"=","",$i); print $i; exit}}' "${src}"
}
imodel() { awk -v inst="$1" '$1==inst{print $4; exit}' "${src}"; }

# ---- one cell instance per condition. The cell's pins are PAD RXG VDDIO VSS;
# RXG is left unloaded, exactly as the cell stands on its own, so XRS carries
# only what XDLP / XDLN draw. Nothing else loads the pad.
#
# Forced-current instances, both on the swept rail `vddio`:
#   sp  pad-positive: current forced INTO  PAD  -> XDP (PAD->VDDIO) conducts
#   sn  pad-negative: current drawn OUT of PAD  -> XDN (VSS->PAD)  conducts
dcins='sp sn'

# HBM instances: tag|rail node|amplitude|fire|fire+0.1ns|.ic for pad and rxg|1G
# pad bleed|starting-state token.
# a, b and c are the same deck fired from three different starting states (fire
# time, and a quiescent point moved by a 1 Gohm bleed): that is the invariance
# check. d and e force the pad state instead and are diagnostics of what forcing
# it does, not results. qp and qn repeat the a case on the 5.0 V comparison rail.
pulses='
pa|vddio|2000|50n|50.1n|none|0|natural_operating_point
pb|vddio|2000|500n|500.1n|none|0|natural_operating_point_fired_at_500ns
pc|vddio|2000|50n|50.1n|none|1|natural_operating_point_plus_1Gohm_pad_bleed
pd|vddio|2000|50n|50.1n|5|0|forced_ic_diagnostic_not_a_result
pe|vddio|2000|50n|50.1n|-0.05|0|forced_ic_diagnostic_not_a_result
na|vddio|-2000|50n|50.1n|none|0|natural_operating_point
nb|vddio|-2000|500n|500.1n|none|0|natural_operating_point_fired_at_500ns
nc|vddio|-2000|50n|50.1n|none|1|natural_operating_point_plus_1Gohm_pad_bleed
nd|vddio|-2000|50n|50.1n|5|0|forced_ic_diagnostic_not_a_result
ne|vddio|-2000|50n|50.1n|-0.05|0|forced_ic_diagnostic_not_a_result
qp|vddio5|2000|50n|50.1n|none|0|natural_operating_point
qn|vddio5|-2000|50n|50.1n|none|0|natural_operating_point
'

# Every diode of the cell, as a validity-verdict row: name|forward-voltage
# expression (ANODE minus CATHODE)|subcircuit instance.
#   XDP  PAD VDDIO : anode PAD -> conducts for PAD above VDDIO
#   XDN  VSS PAD   : anode VSS -> conducts for PAD below VSS
#   XDLP RXG VDDIO : anode RXG -> the local pair at the receiver gate
#   XDLN VSS RXG   : anode VSS
# (the PDK wrapper is `.subckt sky130_fd_pr__diode_<t> N P` expanding to
# `D0 N P <model>`, so pin N is the anode)
diodes() { # padnode rxgnode railnode
  printf 'XDP|v(%s) - v(%s)|xdp\nXDN|-v(%s)|xdn\nXDLP|v(%s) - v(%s)|xdlp\nXDLN|-v(%s)|xdln\n' \
    "$1" "$3" "$1" "$2" "$3" "$2"
}

# Per-diode voltages, the diode's own signed current, and the ESD.7 verdict.
#   mode op:    one operating point, so every quantity is a single value, and
#               the model's junction capacitance cd is read out as well.
#   mode pulse: extremes over the transient, plus the signed value at the
#               instant the pulse current peaks, read through the 0/1 mask
#               vector named in $7.
emit_diodes() { # mode resultprefix instance padnode rxgnode railnode [maskvector]
  local mode="$1" rname="$2" inst="$3" pad="$4" rxg="$5" rail="$6" mk="${7:-}" dname expr dev
  while IFS='|' read -r dname expr dev; do
    [ -n "${dname}" ] || continue
    echo "let vf = ${expr}"
    echo "let vapk = maximum(abs(vf))"
    echo "let idv = @d.${inst}.${dev}.d0[id]"
    # ESD.7: junction diodes are stated valid for |V| 0 to 5.0 V (the row names
    # 5.0 V in reverse); beyond it the result is not a pass.
    echo "if ( vapk > 5.0 )"
    echo "  set lab = outside_model_validity"
    echo "else"
    echo "  set lab = within_esd7_model_range"
    echo "end"
    if [ "${mode}" = op ]; then
      echo "let cdv = @d.${inst}.${dev}.d0[cd]"
      echo "echo \"RESULT ${rname}_${dname} vfwd_V=\$&vf id_A=\$&idv cd_F=\$&cdv vabs_V=\$&vapk validity=\$lab current_validity=no_current_validity_range_on_record\""
    else
      echo "let vfmax = maximum(vf)"
      echo "let vrmax = maximum(-vf)"
      echo "let idmin = minimum(idv)"
      echo "let idmax = maximum(idv)"
      # signed value at the peak-current sample: 0/1 mask, +1e9 elsewhere, so
      # the minimum picks the masked sample even when it is negative.
      echo "let vfat = minimum(vf*${mk} + (1-${mk})*1e9)"
      echo "let idat = minimum(idv*${mk} + (1-${mk})*1e9)"
      echo "echo \"RESULT ${rname}_${dname} vfwd_at_ipk_V=\$&vfat id_at_ipk_A=\$&idat vfwd_max_V=\$&vfmax vrev_max_V=\$&vrmax vabs_max_V=\$&vapk id_min_A=\$&idmin id_max_A=\$&idmax validity=\$lab current_validity=no_current_validity_range_on_record\""
    fi
  done <<< "$(diodes "${pad}" "${rxg}" "${rail}")"
  # The ESD.3 series resistor. No model validity range for res_high_po_1p41 is
  # on record, so its voltage is reported unjudged.
  echo "let vrsa = maximum(abs(v(${rxg}) - v(${pad})))"
  echo "echo \"RESULT ${rname}_XRS vabs_V=\$&vrsa validity=no_validity_range_on_record current_validity=no_current_validity_range_on_record\""
}

# One forced-current operating point: summary line plus every diode.
emit_op() { # resultprefix instancetag signprefix current vddio
  local rname="$1" t="$2" sgn="$3" i="$4" vd="$5"
  echo "alter Iin_${t} = ${i}"
  echo "op"
  echo "let vp = v(pad_${t})"
  echo "let vr = v(rxg_${t})"
  # pad-node current balance rebuilt from the four diode currents; the error
  # against the forced current is the solution's own consistency check.
  echo "let ikcl = @d.x${t}.xdp.d0[id] - @d.x${t}.xdn.d0[id] + @d.x${t}.xdlp.d0[id] - @d.x${t}.xdln.d0[id]"
  echo "let ikerr = ikcl - (${sgn}${i})"
  echo "echo \"RESULT ${rname} i_forced_A=${sgn}${i} i_esd2_pk_A=${i_esd2} vddio_V=${vd} vpad_V=\$&vp vrxg_V=\$&vr i_kcl_A=\$&ikcl i_kcl_err_A=\$&ikerr\""
  emit_diodes op "${rname}" "x${t}" "pad_${t}" "rxg_${t}" vddio
}

emit() { # libpath includepath-prefix
  local t rail a fire peak ic bleed st dname expr dev i vd other inst mf js jsw ik ar pe cond cname sgn
  echo "* diode-probe: ESD.3 pad diode forward drop at the ESD.2 current"
  echo "* single-corner probe, tt, 27 C. Diode areas are placeholders (gate G1)."
  echo ".lib $1 tt"
  echo ".temp 27"
  echo ".include $2/${cell}.spice"
  echo "Vddio vddio 0 ${vddio_nom}"
  echo "Vddio5 vddio5 0 ${vddio_cmp}"
  echo "* VSS is node 0 throughout."
  for t in ${dcins}; do
    case "${t}" in
      sp) echo "Iin_${t} 0 pad_${t} 0" ;;   # injects into PAD: pad rises toward VDDIO
      sn) echo "Iin_${t} pad_${t} 0 0" ;;   # draws out of PAD: pad falls below VSS
    esac
    echo "X${t} pad_${t} rxg_${t} vddio 0 ${cell}"
  done
  # The gun is a voltage step behind the 100 pF capacitor rather than a
  # pre-charged capacitor. C*V is the same 200 nC and the decay is the same
  # R*C = 150 ns, but this deck has a real DC operating point, so the transient
  # needs no uic and no guessed initial state (README, "Why not uic").
  while IFS='|' read -r t rail a fire peak ic bleed st; do
    [ -n "${t}" ] || continue
    echo "Vg_${t} g_${t} 0 PWL(0 0 ${fire} 0 ${peak} ${a})"
    echo "Ch_${t} g_${t} h_${t} ${hbm_c}"
    echo "Rh_${t} h_${t} pad_${t} ${hbm_r}"
    echo "X${t} pad_${t} rxg_${t} ${rail} 0 ${cell}"
    [ "${bleed}" = 0 ] || echo "Rbl_${t} pad_${t} 0 1G"
  done <<< "${pulses}"
  # Self-tests of the gun alone: into a short (Vm_gr is the ammeter) and into a
  # 1 uF load, whose final voltage is the delivered charge. Rbl_gc gives the
  # capacitive branch a DC path, without which its operating point is singular.
  echo "Vg_gr g_gr 0 PWL(0 0 50n 0 50.1n ${hbm_v})"
  echo "Ch_gr g_gr h_gr ${hbm_c}"
  echo "Rh_gr h_gr m_gr ${hbm_r}"
  echo "Vm_gr m_gr 0 0"
  echo "Vg_gc g_gc 0 PWL(0 0 50n 0 50.1n ${hbm_v})"
  echo "Ch_gc g_gc h_gc ${hbm_c}"
  echo "Rh_gc h_gc c_gc ${hbm_r}"
  echo "Cl_gc c_gc 0 1u"
  echo "Rbl_gc c_gc 0 1T"
  # Transient initial conditions of the two diagnostic replicas per polarity.
  while IFS='|' read -r t rail a fire peak ic bleed st; do
    [ -n "${t}" ] || continue
    [ "${ic}" = none ] || echo ".ic v(pad_${t})=${ic} v(rxg_${t})=${ic}"
  done <<< "${pulses}"

  echo ".control"
  echo "set noaskquit"
  # One save per instance: a single save line carrying every device vector is
  # long enough to be mangled, and then returns wrong extremes silently.
  for t in ${dcins}; do
    echo "save all @d.x${t}.xdp.d0[id] @d.x${t}.xdn.d0[id] @d.x${t}.xdlp.d0[id] @d.x${t}.xdln.d0[id]"
    echo "save @d.x${t}.xdp.d0[cd] @d.x${t}.xdn.d0[cd] @d.x${t}.xdlp.d0[cd] @d.x${t}.xdln.d0[cd]"
  done
  while IFS='|' read -r t rail a fire peak ic bleed st; do
    [ -n "${t}" ] || continue
    echo "save @d.x${t}.xdp.d0[id] @d.x${t}.xdn.d0[id] @d.x${t}.xdlp.d0[id] @d.x${t}.xdln.d0[id]"
  done <<< "${pulses}"

  # ---- what the models themselves say, at the areas the netlist instantiates.
  # isat_A = js*area + jsw*perim is the ngspice level-3 area scaling, and is why
  # the forward drop lands where it does. ik_times_area_A is the models' own
  # forward knee, printed against the probe current rather than asserted.
  for inst in XDP XDN XDLP XDLN; do
    mf="${mdir}/$(imodel "${inst}").model.spice"
    ar="$(iparam "${inst}" area)"; pe="$(iparam "${inst}" perim)"
    js="$(num "$(mparam "${mf}" js)")"; jsw="$(num "$(mparam "${mf}" jsw)")"
    ik="$(num "$(mparam "${mf}" ik)")"
    echo "echo \"RESULT model_limits_${inst} model=$(imodel "${inst}") area_inst=${ar} perim_inst=${pe}" \
         "js_A_per_m2=${js} jsw_A_per_m=${jsw} isat_A=$(awk -v j="${js}" -v w="${jsw}" -v a="${ar}" -v p="${pe}" 'BEGIN{printf "%.6g", j*a + w*p}')" \
         "ik_density_A_per_m2=${ik} ik_times_area_A=$(awk -v k="${ik}" -v a="${ar}" 'BEGIN{printf "%.6g", k*a}')" \
         "n=$(num "$(mparam "${mf}" n)") rs_ohm_per_area=$(num "$(mparam "${mf}" rs)") bv_V=$(num "$(mparam "${mf}" bv)")" \
         "i_esd2_pk_A=${i_esd2} esd7_abs_v_limit_V=5.0 current_validity=no_current_validity_range_on_record\""
  done

  # ---- (d) gun self-tests, run first: establish the stress network before any
  # pad number is read from it.
  echo "tran 0.02n ${t_stop} 0 0.1n"
  echo "let igr = abs(i(Vm_gr))"
  echo "let igrpk = maximum(igr)"
  echo "meas tran igr_tau find igr at=200.1n"
  echo "let ratio = igr_tau / igrpk"
  echo "let vgc = maximum(v(c_gc))"
  echo "let qgc = vgc * 1e-6"
  echo "echo \"RESULT selftest_gun_short vhbm_V=${hbm_v} c_F=${hbm_c} r_ohm=${hbm_r} i_expected_A=${i_esd2} ipulse_pk_A=\$&igrpk i_at_1tau_A=\$&igr_tau i_at_1tau_over_ipk=\$&ratio one_over_e=0.367879 decay_tau_s=${hbm_tau}\""
  echo "echo \"RESULT selftest_gun_1uF c_load_F=1e-6 v_load_final_V=\$&vgc q_delivered_C=\$&qgc q_expected_C=2e-7\""

  # ---- (a) the forced-current sweep at the SUP.1 nominal supply, as
  # independent operating points. A different quantity from the pulse figures
  # below, and reported separately.
  echo "alter Vddio = ${vddio_nom}"
  for t in ${dcins}; do
    for other in ${dcins}; do [ "${other}" = "${t}" ] || echo "alter Iin_${other} = 0"; done
    # sign of the current the source pushes INTO the pad: positive for sp,
    # negative for sn, which draws it out.
    case "${t}" in sp) sgn='' ;; sn) sgn='-' ;; esac
    for i in ${i_list}; do
      emit_op "dcop_${t}_i${i}" "${t}" "${sgn}" "${i}" "${vddio_nom}"
    done
    echo "alter Iin_${t} = 0"
  done

  # ---- (b) supply sensitivity at the ESD.2 peak only. The ESD.7 verdict on the
  # reverse-biased diode is set by the rail, so the SUP.1 range ends and the
  # 5.0 V comparison rail are reported here.
  for vd in ${vddio_set}; do
    echo "alter Vddio = ${vd}"
    for t in ${dcins}; do
      for other in ${dcins}; do [ "${other}" = "${t}" ] || echo "alter Iin_${other} = 0"; done
      case "${t}" in sp) sgn='' ;; sn) sgn='-' ;; esac
      emit_op "supply_${t}_vddio${vd}" "${t}" "${sgn}" "${i_esd2}" "${vd}"
      echo "alter Iin_${t} = 0"
    done
  done

  # ---- (c) ESD.2 HBM pulse at the SUP.1 nominal supply (qp / qn sit on the
  # fixed 5.0 V rail). Every replica lives in one netlist, so one transient
  # covers both polarities and all starting states; the replicas share only the
  # two ideal supply sources and node 0.
  echo "alter Vddio = ${vddio_nom}"
  for t in ${dcins}; do echo "alter Iin_${t} = 0"; done
  echo "tran 0.02n ${t_stop} 0 0.1n"
  while IFS='|' read -r t rail a fire peak ic bleed st; do
    [ -n "${t}" ] || continue
    # pulse current through the 1.5 kohm series resistor, and the instant of its peak
    echo "let ii = abs(v(h_${t}) - v(pad_${t})) / ${hbm_r}"
    echo "let ipk = maximum(ii)"
    echo "let mk_${t} = (ii > 0.9999*ipk)"
    echo "let tat = minimum(time*mk_${t} + (1-mk_${t})*1e9)"
    echo "let vpmin = minimum(v(pad_${t}))"
    echo "let vpmax = maximum(v(pad_${t}))"
    echo "let vpexc = vpmax - vpmin"
    case "${a}" in -*) cond="-v(pad_${t})"; cname=XDN ;; *) cond="v(pad_${t}) - v(${rail})"; cname=XDP ;; esac
    echo "let vcat = minimum((${cond})*mk_${t} + (1-mk_${t})*1e9)"
    # the diode that carries this polarity must sit at a POSITIVE forward
    # voltage when the current peaks, or no forward drop developed at all.
    echo "if ( vcat > 0 )"
    echo "  set fs = positive"
    echo "  set fd = developed"
    echo "else"
    echo "  set fs = not_forward_biased"
    echo "  set fd = not_developed"
    echo "end"
    echo "echo \"RESULT pulse_${t} vhbm_V=${a} c_F=${hbm_c} r_ohm=${hbm_r} decay_tau_s=${hbm_tau} t_fire_s=${fire} rail=${rail} vddio_V=$([ "${rail}" = vddio ] && echo "${vddio_nom}" || echo "${vddio_cmp}") state=${st} ic_pad_rxg_V=${ic} pad_bleed_1Gohm=${bleed} i_esd2_pk_A=${i_esd2} ipulse_pk_A=\$&ipk t_ipk_s=\$&tat vpad_min_V=\$&vpmin vpad_max_V=\$&vpmax vpad_excursion_V=\$&vpexc conducting=${cname} vfwd_cond_at_ipk_V=\$&vcat fwd_sign=\$fs pulse_forward_drop=\$fd\""
    emit_diodes pulse "pulse_${t}" "x${t}" "pad_${t}" "rxg_${t}" "${rail}" "mk_${t}"
  done <<< "${pulses}"
  echo "quit"
  echo ".endc"
  echo ".end"
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
meta="$(printf '{"kind":"probe","probe":"G1/ESD.3 single-corner pad-diode forward-drop probe at the ESD.2 current","pdk_revision":"%s","pdk_variant":"%s","corner":"tt","temp_c":27,"vddio_nominal_V":%s,"tools":{"ngspice":"%s","ciel":"%s","xschem":"%s"},"note":"Single-corner probe, not item-5 evidence; no corner or temperature set, no failure current, no ESD rating. The diode areas in design/netlists/sky130_ioring_gpio_esd.spice are explicit placeholders (gate G1, decision 0004), so every voltage here is the drop of a placeholder at a placeholder area. The diode models carry a stated |V| 0 to 5.0 V validity range and NO current validity range at all: current_validity=no_current_validity_range_on_record sits on every diode line, and a within_esd7_model_range voltage verdict is not a pass on ESD.3."}' \
  "${PDK_REVISION}" "${PDK}" "${vddio_nom}" "${ngspice_ver}" "${ciel_ver:-unavailable}" "${xschem_ver:-unavailable}")"

cd "${out}"
python3 -I "${repo}/sim/lib/simrec.py" write record.json --meta "${meta}" --log "probe=logs/probe.log"
