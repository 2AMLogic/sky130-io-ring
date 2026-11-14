#!/usr/bin/env bash
# Gate G2 single-corner probe: does the sky130 skew set (ff ss sf fs) move the
# 5 V thick-oxide devices, or only the 1.8 V core devices?
#
# Two halves, both from the pinned PDK and neither a corner sweep:
#
#   A. Card survey (read-only, no simulation). Walks $SKY130_MODEL_LIB's own
#      include chain for each of tt ff ss sf fs and each of the four devices,
#      and reports the model card that corner selects, its reference-bin
#      vth0 / toxe / u0, the junction multipliers of the *.corner.spice
#      wrapper, and how far the card differs from the same device's tt card.
#   B. One ngspice run at tt / 27 C (single corner, local, as the host rules
#      allow) for the measured anchor: DC operating point of the same four
#      devices at the sim/pdk-smoke bias.
#
#   bash sim/corner-skew-probe/run.sh [OUTDIR]   # default: sim/corner-skew-probe/record
#
# Writes OUTDIR/{netlists/,logs/,record.json}; refuses to overwrite an existing
# OUTDIR (records are append-only). ONE ngspice process: no corner set, no
# temperature sweep, no Monte Carlo, no parallel jobs. A corner set belongs in a
# klt sim request on the batch fleet and is held by spec/review-2026-10.md
# section 7 item 3 until decision 0004 ratifies.
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

corners='tt ff ss sf fs'
# name|model|type|vsup|W|L   W, L in um (the library sets .option scale=1.0u).
# Identical to sim/pdk-smoke/run.sh so the tt currents here are directly
# comparable with the committed smoke record. Smoke values, not design values.
devices='
nfet_01v8|sky130_fd_pr__nfet_01v8|n|1.8|1.0|0.15
pfet_01v8|sky130_fd_pr__pfet_01v8|p|1.8|1.0|0.15
nfet_g5v0d10v5|sky130_fd_pr__nfet_g5v0d10v5|n|5.0|1.0|0.5
pfet_g5v0d10v5|sky130_fd_pr__pfet_g5v0d10v5|p|5.0|1.0|0.5
'

# ---------------------------------------------------------------- helpers
libdir="$(cd "$(dirname "${SKY130_MODEL_LIB}")" && pwd)"

abspath() { # existing file -> absolute, no .. components
  printf '%s/%s\n' "$(cd "$(dirname "$1")" && pwd)" "$(basename "$1")"
}
pdkrel() { # absolute path under PDK_ROOT -> $PDK_ROOT-rooted, for the record
  printf '%s\n' "${1/#${PDK_ROOT}/\$PDK_ROOT}"
}
lib_include() { # corner regexp -> first .include in that .lib section matching regexp
  sed -n "/^\.lib $1\$/,/^\.endl $1\$/p" "${SKY130_MODEL_LIB}" \
    | sed -n "s|^\.include *\"\($2\)\".*|\1|p" | head -n1
}
dev_include() { # file device corner -> the .include naming that device at that corner
  sed -n "s|^\.include *\"\([^\"]*sky130_fd_pr__$2__$3[.a-z0-9_]*\.spice\)\".*|\1|p" "$1" | head -n1
}
param_value() { # file paramname -> value of a `+ <name><suffix> = <v>` continuation line
  sed -n "s|^+ *[a-z0-9_]*__$2 *= *\([^ ]*\).*|\1|p" "$1" | head -n1
}

# Reference-bin vth0/toxe/u0, bin count, and the bin covering the probe W/L.
# Binning rule applied: lmin <= L < lmax and wmin <= W < wmax, on the scaled
# geometry. The reference bin is the first .model card in the file.
card_params='
function num(s) {
  sub(/^[ \t]*=?[ \t]*/, "", s); sub(/^\{/, "", s)
  if (match(s, /^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?/)) return substr(s, 1, RLENGTH)
  return "na"
}
/^\.model[ \t]/ { n++; bin = $2; sub(/^.*__model\./, "", bin); if (ref == "") ref = bin; next }
/^\+[ \t]+lmin[ \t]*=/ {
  if (L >= $4 + 0 && L < $7 + 0 && W >= $10 + 0 && W < $13 + 0 && sel == "") sel = bin
  next
}
/^\+[ \t]+(vth0|toxe|u0)[ \t]*=/ {
  k = ref SUBSEP $2
  if (bin == ref && !(k in v)) v[k] = num(substr($0, index($0, "=") + 1))
  next
}
END { printf "%s %s %s %s %d %s\n", ref, v[ref,"vth0"], v[ref,"toxe"], v[ref,"u0"], n,
        (sel == "" ? "none" : sel) }
'

# ------------------------------------------------- A. card survey (no simulation)
nsections="$(grep -c '^\.lib ' "${SKY130_MODEL_LIB}")"
: > "${work}/cards.log"
for c in ${corners}; do
  mos_inc="$(lib_include "${c}" 'corners/[^"/]*\.spice')"
  rc_inc="$(lib_include "${c}" 'r+c/[^"]*\.spice')"
  if [ -z "${mos_inc}" ] || [ -z "${rc_inc}" ]; then
    echo "run.sh: .lib ${c} has no MOS and/or no r+c include" >&2; exit 1
  fi
  mos_abs="$(abspath "${libdir}/${mos_inc}")"
  echo "RESULT libsec_${c} corner=${c} mos_include=$(pdkrel "${mos_abs}")" \
       "rc_include=$(basename "${rc_inc}") lib_sections=${nsections}" >> "${work}/cards.log"

  while IFS='|' read -r name model type vsup w l; do
    [ -n "${name}" ] || continue
    inc="$(dev_include "${mos_abs}" "${name}" "${c}")"
    [ -n "${inc}" ] || { echo "run.sh: ${mos_inc} does not include ${name} at ${c}" >&2; exit 1; }
    sel_abs="$(abspath "$(dirname "${mos_abs}")/${inc}")"
    case "${sel_abs}" in
      *.corner.spice) # wrapper: two junction multipliers, then the real card
        amult="$(param_value "${sel_abs}" ajunction_mult)"
        pmult="$(param_value "${sel_abs}" pjunction_mult)"
        card="$(abspath "$(dirname "${sel_abs}")/$(sed -n 's|^\.include *"\([^"]*\)".*|\1|p' "${sel_abs}" | head -n1)")"
        wrapper="$(pdkrel "${sel_abs}")"
        ;;
      *) wrapper=none; amult=absent; pmult=absent; card="${sel_abs}" ;;
    esac
    # distance from this device's own tt card (0 for tt itself)
    ttcard="$(printf '%s\n' "${card}" | sed "s|__${c}\.pm3\.spice\$|__tt.pm3.spice|")"
    if [ "${card}" = "${ttcard}" ]; then dl=0; else
      dl="$(diff "${ttcard}" "${card}" | grep -c '^[<>]' || true)"
    fi
    # .option scale=1.0u in the library, so the table's W, L are um; bin on metres.
    wm="$(awk -v x="${w}" 'BEGIN{printf "%.12g", x*1e-6}')"
    lm="$(awk -v x="${l}" 'BEGIN{printf "%.12g", x*1e-6}')"
    # six fields: ref_bin vth0 toxe u0 bins bin_for_probe_wl
    # shellcheck disable=SC2046  # deliberate: split the six fields into $1..$6
    set -- $(awk -v W="${wm}" -v L="${lm}" "${card_params}" "${card}")
    echo "RESULT card_${name}_${c} corner=${c} device=${name} w_um=${w} l_um=${l}" \
         "card=$(pdkrel "${card}") wrapper=${wrapper}" \
         "bins=$5 ref_bin=$1 vth0_ref_V=$2 toxe_ref_m=$3 u0_ref=$4 bin_for_probe_wl=$6" \
         "ajunction_mult=${amult} pjunction_mult=${pmult} diff_lines_vs_tt=${dl}" >> "${work}/cards.log"
  done <<< "${devices}"
done
cp "${work}/cards.log" "${out}/logs/cards.log"

# ------------------------------------------- B. one ngspice run, tt / 27 C
emit() { # libpath
  echo "* corner-skew-probe: G2 measured anchor, DC operating point, tt, 27 C"
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
  while IFS='|' read -r name model type vsup w l; do
    [ -n "${name}" ] || continue
    local dev="@m.xm_${name}.m${model}"
    if [ "${type}" = n ]; then echo "let idq = -i(Vd_${name})"; else echo "let idq = i(Vd_${name})"; fi
    # |vth| and |vdsat| of the bin ngspice itself selected for this geometry
    echo "let vt = abs(${dev}[vth])"
    echo "let vds = abs(${dev}[vdsat])"
    echo "let gmq = abs(${dev}[gm])"
    echo "let idm = abs(${dev}[id])"
    echo "echo \"RESULT op_${name} corner=tt temp_c=27 vsup=${vsup} w_um=${w} l_um=${l}" \
         "id_A=\$&idq id_model_A=\$&idm vth_op_V=\$&vt vdsat_op_V=\$&vds gm_S=\$&gmq\""
  done <<< "${devices}"
  echo "quit"
  echo ".endc"
  echo ".end"
}

emit "${SKY130_MODEL_LIB}" > "${work}/probe.sp"
# Snapshot: no absolute paths.
emit '$PDK_ROOT/sky130A/libs.tech/ngspice/sky130.lib.spice' > "${out}/netlists/probe.sp"

rc=0
(cd "${work}" && ngspice -b -o "${work}/probe.log" "${work}/probe.sp" </dev/null >/dev/null 2>&1) || rc=$?
[ "${rc}" -eq 0 ] || echo "run.sh: ngspice exited ${rc}" >&2
sed -e "s#${PDK_ROOT}#\$PDK_ROOT#g" -e "s#${work}#\$WORK#g" "${work}/probe.log" > "${out}/logs/probe.log"

ngspice_ver="$(ngspice --version | sed -n 's/.*ngspice-\([0-9.]*\).*/\1/p' | head -n1)"
ciel_ver="$(ciel --version 2>/dev/null | sed -n 's/^Ciel v\([0-9.]*\).*/\1/p' | head -n1)" || true
xschem_ver="$(xschem --version 2>&1 | sed -n 's/^XSCHEM V\([0-9.]*\).*/\1/p' | head -n1)" || true
meta="$(printf '{"kind":"probe","probe":"G2 corner-skew probe: 5 V device skew in ff/ss/sf/fs (card survey + one tt operating point)","pdk_revision":"%s","pdk_variant":"%s","corner":"tt","corners_surveyed":["tt","ff","ss","sf","fs"],"temp_c":27,"tools":{"ngspice":"%s","ciel":"%s","xschem":"%s"},"note":"Single-corner G2 probe, not item-5 evidence. The cards run is a read-only survey of the pinned model library, not a simulation; converged there means it produced RESULT lines with no error text. Only the probe run is simulated, at tt/27 C. No corner set, no temperature sweep, no Monte Carlo. W, L and bias are carried over from sim/pdk-smoke and are not design values."}' \
  "${PDK_REVISION}" "${PDK}" "${ngspice_ver}" "${ciel_ver:-unavailable}" "${xschem_ver:-unavailable}")"

cd "${out}"
python3 -I "${repo}/sim/lib/simrec.py" write record.json --meta "${meta}" \
  --log "cards=logs/cards.log" --log "probe=logs/probe.log"
