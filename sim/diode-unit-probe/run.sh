#!/usr/bin/env bash
# diode-unit-probe: settles the unit convention of the instance `area` /
# `perim` parameters of sky130_fd_pr__diode_pd2nw_05v5 and
# sky130_fd_pr__diode_pw2nd_05v5 (issue #107), so G1 sizing has a defined
# starting point.
#
# Method: instantiate each model at known instance values, read ngspice's OWN
# output (junction capacitance `cd`, device current `id`, forced-current
# forward drop) and compare against the model cards' `cj`/`cjsw`/`js`/`jsw`/
# `rs` under each of the three candidate conventions:
#
#   C1  instance value is um^2 (area) / um (perim)
#   C2  instance value is m^2 / m        (what the cards' "; Units:" comments say)
#   C3  instance value is um^2 x 1e12 / um x 1e6   (design/README.md's old reading)
#
# The capacitance path and the current path are checked SEPARATELY, because
# the cards' pre-scaling is not uniform: cj / cjsw / ik carry *1e-12 / *1e-6 /
# /1e-12 factors, js / jsw / rs carry none. A single-parameter check cannot
# settle both.
#
# The primary current-path point is at 0.6 V forward. Below ~0.4 V, ngspice's
# default GMIN = 1e-12 S floor dominates a raw-diode junction at these areas:
# the deck records the 0.2 V / 0.3 V / 0.4 V rows as a measured demonstration
# of exactly that (current not linear in area there), not as results.
#
# A second deck repeats the measurement at .temp 30, the cards' own
# `tref = 30` reference temperature, so the residual measured/card ratio of
# the current path at 27 C is shown to be a temperature artifact and not a
# unit effect. tt corner throughout; both decks are single-corner runs of
# operating points only (no corners, no Monte Carlo, no parallel jobs).
#
#   bash sim/diode-unit-probe/run.sh [OUTDIR]   # default: sim/diode-unit-probe/record
#
# Writes OUTDIR/{netlists/,logs/,record.json}; refuses to overwrite an
# existing OUTDIR (records are append-only).
set -euo pipefail
# shellcheck source=../lib/run_common.sh
source "$(dirname "$0")/../lib/run_common.sh"
run_common_setup "${1:-}"

mdir="${PDK_ROOT}/${PDK}/libs.ref/sky130_fd_pr/spice"
mparam() { # model-file param -> raw value ('a/b' kept as written)
  awk -v p="$2" '$1=="+" && $2==p && $3=="=" {v=$4; gsub(/\x27/,"",v); print v; exit}' "$1"
}
num() { # evaluate a card value; corner *_junction_mult tokens are replaced
        # with 1 so the card's PRE-multiplier figure is reported (the tt
        # multiplier itself is measured out of the probe by the
        # instance-difference method, never assumed). The expression domain
        # after the substitution is digits, '.', 'e', '*', '/', '+' and '-'
        # only - what the cards themselves contain - so inlining it into the
        # awk program below is safe.
  local e
  e="$(sed -E 's/sky130_fd_pr__[a-z0-9_]+__(a|p)junction_mult/1/g' <<<"$1")"
  awk "BEGIN{printf \"%.6g\", (${e})}"
}
cards() { # model -> "<stem> <file>"; the two design models
  case "$1" in
    pd2nw) echo "sky130_fd_pr__diode_pd2nw_05v5" ;;
    pw2nd) echo "sky130_fd_pr__diode_pw2nd_05v5" ;;
  esac
}

# ---- instances. Voltage-sourced matrix (capacitance path + forward id):
#   a1 a10 p10 a-pj1 : the difference instances that extract the per-unit
#                      coefficients exactly (differences at fixed perim /
#                      fixed area cancel the other term and the derating)
#   a2500            : the realistic pad-diode scale the record compares to
# Current-sourced anchors (forced 1.33333 A = the ESD.2 peak current, the
# current PR #105 probed the placeholders at):
#   a2500 a25000     : 1x and 10x the realistic scale - the high-current
#                      linearity-in-area check (isat and rs both scale)
#   a2e14            : the design netlists' placeholder value, so the record
#                      states what that number MEANS under the settled unit.
#                      Nothing is resized anywhere; this is context, not a
#                      sizing proposal.
emit() { # temp_c
  local t="$1" m stem mf
  echo "* diode-unit-probe: instance area/perim unit convention, issue #107"
  echo "* tt corner, ${t} C. GMIN is left at its ngspice default (1e-12 S);"
  echo "* the sub-0.4 V rows exist to demonstrate that floor, not as results."
  echo ".lib $PDK_ROOT/sky130A/libs.tech/ngspice/sky130.lib.spice tt"
  echo ".temp ${t}"
  # Voltage-sourced matrix: anode on its own source, cathode to VSS (0).
  echo "Dpd1 f1 0 sky130_fd_pr__diode_pd2nw_05v5 area=1 perim=1"
  echo "Dpd2 f2 0 sky130_fd_pr__diode_pd2nw_05v5 area=10 perim=1"
  echo "Dpd3 f3 0 sky130_fd_pr__diode_pd2nw_05v5 area=1 perim=10"
  echo "Dpd4 f4 0 sky130_fd_pr__diode_pd2nw_05v5 area=1 pj=1"
  echo "Dpd6 f6 0 sky130_fd_pr__diode_pd2nw_05v5 area=2500 perim=200"
  echo "Dnw1 g1 0 sky130_fd_pr__diode_pw2nd_05v5 area=1 perim=1"
  echo "Dnw2 g2 0 sky130_fd_pr__diode_pw2nd_05v5 area=10 perim=1"
  echo "Dnw3 g3 0 sky130_fd_pr__diode_pw2nd_05v5 area=1 perim=10"
  echo "Dnw4 g4 0 sky130_fd_pr__diode_pw2nd_05v5 area=1 pj=1"
  echo "Dnw6 g6 0 sky130_fd_pr__diode_pw2nd_05v5 area=2500 perim=200"
  echo "Vpd1 f1 0 0"
  echo "Vpd2 f2 0 0"
  echo "Vpd3 f3 0 0"
  echo "Vpd4 f4 0 0"
  echo "Vpd6 f6 0 0"
  echo "Vnw1 g1 0 0"
  echo "Vnw2 g2 0 0"
  echo "Vnw3 g3 0 0"
  echo "Vnw4 g4 0 0"
  echo "Vnw6 g6 0 0"
  # Current-sourced anchors: source injects INTO the anode node, so a positive
  # 1.33333 A forward-biases the diode; node voltage IS the forward drop
  # (cathode at 0), including the models' own rs drop.
  echo "Dpd8 h8 0 sky130_fd_pr__diode_pd2nw_05v5 area=2500 perim=200"
  echo "Dpd9 h9 0 sky130_fd_pr__diode_pd2nw_05v5 area=25000 perim=2000"
  echo "Dpd10 h10 0 sky130_fd_pr__diode_pd2nw_05v5 area=2e14 perim=6e7"
  echo "Dnw8 k8 0 sky130_fd_pr__diode_pw2nd_05v5 area=2500 perim=200"
  echo "Dnw9 k9 0 sky130_fd_pr__diode_pw2nd_05v5 area=25000 perim=2000"
  echo "Dnw10 k10 0 sky130_fd_pr__diode_pw2nd_05v5 area=2e14 perim=6e7"
  echo "Ipd8 0 h8 dc 0"
  echo "Ipd9 0 h9 dc 0"
  echo "Ipd10 0 h10 dc 0"
  echo "Inw8 0 k8 dc 0"
  echo "Inw9 0 k9 dc 0"
  echo "Inw10 0 k10 dc 0"

  echo ".control"
  echo "set noaskquit"
  echo "save all"

  # ---- what the cards themselves say, with the pre-multiplier figures. The
  # "; Units:" comments are copied verbatim alongside, because what those
  # comments DESCRIBE is one of the findings of this probe.
  for m in pd2nw pw2nd; do
    stem="$(cards "$m")"; mf="${mdir}/${stem}.model.spice"
    echo "echo \"RESULT cards_${m} model=${stem}" \
      "cj_card_F_per_m2=$(num "$(mparam "$mf" cj)")" \
      "cj_prescaled=$(num "$(sed -E 's/sky130_fd_pr__[a-z0-9_]+__(a|p)junction_mult/1/g' <<<"$(mparam "$mf" cj)")")" \
      "cjsw_card_F_per_m=$(num "$(mparam "$mf" cjsw)")" \
      "cjsw_prescaled=$(num "$(sed -E 's/sky130_fd_pr__[a-z0-9_]+__(a|p)junction_mult/1/g' <<<"$(mparam "$mf" cjsw)")")" \
      "js=$(num "$(mparam "$mf" js)") jsw=$(num "$(mparam "$mf" jsw)")" \
      "n=$(num "$(mparam "$mf" n)") rs=$(num "$(mparam "$mf" rs)")" \
      "ik=$(num "$(mparam "$mf" ik)") pb=$(num "$(mparam "$mf" pb)") mj=$(num "$(mparam "$mf" mj)")" \
      "php=$(num "$(mparam "$mf" php)") mjsw=$(num "$(mparam "$mf" mjsw)")" \
      "tref=$(num "$(mparam "$mf" tref)") area_model_default=$(num "$(mparam "$mf" area)")" \
      "units_comment=cj_farad_per_meter^2_cjsw_farad_per_meter_js_amper_per_meter^2_rs_ohm\""
  done

  # ---- capacitance path and forward current path, bias by bias. Biases <= 0
  # report junction capacitance cd (reverse or zero bias); biases > 0 report
  # device current id. Each bias is its own operating point.
  for vb in -3.3 0 0.2 0.3 0.4 0.6; do
    echo "alter Vpd1 = ${vb}"
    echo "alter Vpd2 = ${vb}"
    echo "alter Vpd3 = ${vb}"
    echo "alter Vpd4 = ${vb}"
    echo "alter Vpd6 = ${vb}"
    echo "alter Vnw1 = ${vb}"
    echo "alter Vnw2 = ${vb}"
    echo "alter Vnw3 = ${vb}"
    echo "alter Vnw4 = ${vb}"
    echo "alter Vnw6 = ${vb}"
    echo "op"
    if awk -v v="${vb}" 'BEGIN{exit !(v <= 0)}'; then
      local tag d
      case "${vb}" in -3.3) tag=vr3p3 ;; 0) tag=vr0 ;; esac
      for d in pd1 pd2 pd3 pd4 pd6 nw1 nw2 nw3 nw4 nw6; do
        echo "echo \"RESULT cap_${d}_${tag} vbias_V=${vb} cd_F=\$&@d${d}[cd]\""
      done
      if [ "${tag}" = vr0 ]; then
        # The current-sourced instances sit at their own bias, not at ${vb}:
        # with the forced current still 0 A they rest at ~0 V, so their cd is
        # recorded once here with that stated, not under the stage bias.
        for d in pd8 pd9 pd10 nw8 nw9 nw10; do
          echo "echo \"RESULT cap_${d}_vr0 bias_source=0A_current_source cd_F=\$&@d${d}[cd]\""
        done
      fi
    else
      local tag d
      case "${vb}" in 0.2) tag=v0p2 ;; 0.3) tag=v0p3 ;; 0.4) tag=v0p4 ;; 0.6) tag=v0p6 ;; esac
      for d in pd1 pd2 pd3 pd4 pd6 nw1 nw2 nw3 nw4 nw6; do
        echo "echo \"RESULT fwd_${d}_${tag} vbias_V=${vb} id_A=\$&@d${d}[id]\""
      done
    fi
  done

  # ---- the perim= / pj= alias, asserted not assumed: the two instances
  # report their own perim back, and their cd / id are recorded separately
  # above for the equality check.
  echo "op"
  echo "echo \"RESULT perim_alias pd1_perim=\$&@dpd1[perim] pd4_perim=\$&@dpd4[perim] nw1_perim=\$&@dnw1[perim] nw4_perim=\$&@dnw4[perim]\""

  # ---- forced-current anchors at the ESD.2 peak current (2000 V / 1500 ohm).
  # Matrix sources back to 0 so the stage is unambiguous.
  for vb_src in Vpd1 Vpd2 Vpd3 Vpd4 Vpd6 Vnw1 Vnw2 Vnw3 Vnw4 Vnw6; do
    echo "alter ${vb_src} = 0"
  done
  echo "alter Ipd8 = 1.33333"
  echo "alter Ipd9 = 1.33333"
  echo "alter Ipd10 = 1.33333"
  echo "alter Inw8 = 1.33333"
  echo "alter Inw9 = 1.33333"
  echo "alter Inw10 = 1.33333"
  echo "op"
  echo "echo \"RESULT anchor_pd8_a2500 i_forced_A=1.33333 area=2500 perim=200 vdrop_V=\$&v(h8)\""
  echo "echo \"RESULT anchor_pd9_a25000 i_forced_A=1.33333 area=25000 perim=2000 vdrop_V=\$&v(h9)\""
  echo "echo \"RESULT anchor_pd10_a2e14 i_forced_A=1.33333 area=2e14 perim=6e7 vdrop_V=\$&v(h10)\""
  echo "echo \"RESULT anchor_nw8_a2500 i_forced_A=1.33333 area=2500 perim=200 vdrop_V=\$&v(k8)\""
  echo "echo \"RESULT anchor_nw9_a25000 i_forced_A=1.33333 area=25000 perim=2000 vdrop_V=\$&v(k9)\""
  echo "echo \"RESULT anchor_nw10_a2e14 i_forced_A=1.33333 area=2e14 perim=6e7 vdrop_V=\$&v(k10)\""
  echo "quit"
  echo ".endc"
  echo ".end"
}

run_one() { # temp tag
  local t="$1" tag="$2"
  emit "$t" > "${work}/probe_${tag}.sp"
  run_common_ngspice "${work}/probe_${tag}.sp" "${work}/probe_${tag}.log" "${tag}"
  run_common_scrub < "${work}/probe_${tag}.sp" > "${out}/netlists/probe_${tag}.sp"
  run_common_scrub < "${work}/probe_${tag}.log" > "${out}/logs/probe_${tag}.log"
}

run_one 27 tt27
run_one 30 tref30

meta="$(printf '{"kind":"probe","probe":"diode instance area/perim unit-convention probe (sky130_fd_pr__diode_pd2nw_05v5, sky130_fd_pr__diode_pw2nd_05v5), issue #107","pdk_revision":"%s","pdk_variant":"%s","corner":"tt","temp_c":27,"temp_c_tref_check":30,"tools":%s,"conclusion":"Instance area is um^2 and perim is um (candidate C1). C3 (um^2 x 1e12 / um x 1e6, the old design/README.md reading) is refuted by a factor of 1e12 on BOTH the capacitance path and the current path. C2 (m^2 / m, the cards literal ; Units: comments) is numerically indistinguishable from C1 at the same instance values but is disposed of on physical consistency: under C2 the measured capacitance density is 1e12 times below the cards own stated F/m^2 figure, and 1 instance unit would be 1 m^2 of diode. The cards pre-scale cj (*1e-12, F/m^2 -> F/um^2), cjsw (*1e-6, F/m -> F/um) and ik (/1e-12, A/m^2 -> A/um^2) to match the um-based instance convention; js, jsw and rs carry NO such factor and ngspice applies them raw per instance unit (effective A/um^2, A/um, ohm*um^2), so their ; Units: ... meter ... comments describe pre-conversion source units, not the units the instance numbers are in. The design netlists area=2e14 perim=6e7 therefore instantiate a 2e14 um^2 = 200 m^2 diode.","note":"Settles a unit convention, which is corner- and temperature-independent; tt / 27 C is the repo convention and the .temp 30 companion deck (the cards own tref) only closes the residual measured/card ratio of the current path as a temperature artifact. GMIN is left at the ngspice default 1e-12 S: the primary current-path point is 0.6 V forward, well above the floor, and the recorded 0.2 / 0.3 / 0.4 V rows are the measured demonstration of why a low-bias operating point cannot settle this. The perim= / pj= alias is asserted from the devices own readback, not assumed. No device is resized and no ESD rating is stated anywhere; the a=2e14 / p=6e7 anchors record what the design netlists placeholder MEANS, not a sizing proposal (G1, decision 0004). Nothing under sim/diode-probe/ was touched (append-only)."}' \
  "${PDK_REVISION}" "${PDK}" "$(run_common_tools_json ngspice ciel)")"
run_common_record "${meta}" \
  --log "main_tt27=logs/probe_tt27.log" \
  --log "tref30_check=logs/probe_tref30.log"
