#!/usr/bin/env bash
# sky130 half of the harness: the clamp scaffolding shared by sim/clamp-probe
# and sim/clamp-trigger-probe. Source it; do not execute. It holds what the
# two probes used to carry as verbatim copies of each other -- the clamp and
# device tables (sky130 subckt and model names), the netlist-snapshot copy,
# the ramp-step emitter and the ESD.7 validity emitter -- so the ESD.7
# 11.0 V / 5.5 V limits live in exactly one place (sim/README.md, "Layout").
# The callers keep what makes them different probes: their rise-time lists,
# the HBM pulse, the settling study and the record meta.
#
#   # from a sim/clamp-*/run.sh, after sourcing lib/run_common.sh:
#   source "$(dirname "$0")/../lib/clamp_common.sh"
#
# Uses ${out} (record dir, set by run_common_setup) and defines:
#   clamps, devs, hold        the shared tables and the post-ramp hold
#   clamp_snapshot NL         copy the clamp subcircuits into ${out}/netlists
#   emit_ramp_step TR TEND    one rise time, both clamps: alter + tran lines,
#                             then the per-clamp ramp RESULT lines and the
#                             ESD.7 validity rows. TEND=1 additionally emits
#                             the (unread) `let tend` line the committed
#                             clamp-probe record carries; TEND=0 matches the
#                             clamp-trigger-probe record.
#   emit_validity INST RNAME TAG VPN
#                             peak |VDS|/|VGS| of every clamp transistor and
#                             the ESD.7 comparison; VPN names the supply node
#                             (vr_/vh_/vd_<tag>) the vp terminal reads.

# tag|subckt|vnom|nmos_model|mult_xmcl (mult is informational: ngspice's [id] of the
# subcircuit device is already the total, checked against the supply current)
#   tag io:   VDDIO clamp, thick-oxide family (ESD.7 limits apply)
#   tag core: VDD clamp, thin-oxide family (no ESD.7 limit on record)
clamps='
io|sky130_ioring_clamp_io|5.0|sky130_fd_pr__nfet_g5v0d10v5|400
core|sky130_ioring_clamp_core|1.8|sky130_fd_pr__nfet_01v8|800
'
hold=50u # time at nominal after the ramp (50 tau of the ~1 us trigger) before reading leakage

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

clamp_snapshot() { # nl-dir (design/netlists); writes into ${out}, set by run_common_setup
  # The clamp subcircuits are included unchanged. Copies in the snapshot keep the
  # record self-contained; the io netlist's absolute sch_path comment is scrubbed.
  local nl="$1" c
  for c in io core; do
    sed -e "s#/[^ ]*/design/xschem/#\$REPO/design/xschem/#" "${nl}/sky130_ioring_clamp_${c}.spice" \
      > "${out}/netlists/sky130_ioring_clamp_${c}.spice"
  done
}

emit_ramp_step() { # tr tend(0|1): one rise time, both clamps, ramp RESULT + ESD.7 rows
  local tr="$1" tend="$2" stop tag sub vnom nm mult
  stop="$(awk -v tr="${tr}" -v h="${hold}" 'function s(x){u=substr(x,length(x)); v=substr(x,1,length(x)-1)+0;
    return v*(u=="u"?1e-6:u=="m"?1e-3:u=="n"?1e-9:1)} BEGIN{printf "%.6g", s(tr)+s(h)}')"
  echo "alter Vr_io pulse = [ 0 5.0 0 ${tr} 1 1 1 ]"
  echo "alter Vr_core pulse = [ 0 1.8 0 ${tr} 1 1 1 ]"
  echo "tran $(awk -v t="${stop}" 'BEGIN{printf "%.4g", t/4000}') ${stop} 0 $(awk -v t="${stop}" 'BEGIN{printf "%.4g", t/1000}')"
  if [ "${tend}" -eq 1 ]; then echo "let tend = ${stop}"; fi
  echo "let nn = length(time)"
  while IFS='|' read -r tag sub vnom nm mult; do
    [ -n "${tag}" ] || continue
    echo "let idpk = maximum(@m.xr${tag}.xmcl.m${nm}[id])"
    echo "let vgpk = maximum(v(xr${tag}.gate))"
    echo "let ilk = -i(Vr_${tag})[nn-1]"
    echo "let ipk = maximum(abs(i(Vr_${tag})))"
    echo "echo \"RESULT ramp_${tag}_${tr} vnom=${vnom} tr_s=${tr} id_xmcl_pk_A=\$&idpk gate_pk_V=\$&vgpk isup_pk_A=\$&ipk ileak_end_A=\$&ilk\""
    emit_validity "xr${tag}" "ramp_${tag}_${tr}" "${tag}" "vr_${tag}"
  done <<< "${clamps}"
}

# Peak |VDS| and |VGS| of every clamp transistor and the ESD.7 comparison.
emit_validity() { # inst resultname tag supply-node
  local inst="$1" rname="$2" tag="$3" vpn="$4" name d g s pol
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
