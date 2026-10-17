# sky130 half of the harness: PDK resolver. Source it; do not execute.
#
#   source sim/lib/pdk_env.sh
#
# Exports PDK_ROOT, PDK, SKY130_MODEL_LIB, PDK_REVISION. Refuses (returns
# non-zero, message on stderr) a tree whose open_pdks revision (its SOURCES
# file) is not the pin in sim/pdk.json, so a stale ~/.volare tree is never
# used silently.
#
# Resolution: PDK_ROOT env if set, else default_pdk_root from sim/pdk.json
# (~/.ciel). ~/.volare is never consulted.

_pdk_env_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_pdk_env_json="${PDK_PIN_FILE:-${_pdk_env_dir}/../pdk.json}"

_pdk_env_get() { # key -> value from the flat sim/pdk.json
  sed -n "s/^ *\"$1\" *: *\"\([^\"]*\)\".*/\1/p" "${_pdk_env_json}" | head -n1
}

_pdk_env_resolve() {
  local pin variant root dir sources found lib
  [ -r "${_pdk_env_json}" ] || { echo "pdk_env: cannot read pin file ${_pdk_env_json}" >&2; return 1; }
  pin="$(_pdk_env_get open_pdks_revision)"
  variant="$(_pdk_env_get variant)"
  [ -n "${pin}" ] && [ -n "${variant}" ] || { echo "pdk_env: pin file lacks open_pdks_revision/variant" >&2; return 1; }

  root="${PDK_ROOT:-$(_pdk_env_get default_pdk_root)}"
  root="${root/#\~/$HOME}"
  dir="${root}/${variant}"
  [ -d "${dir}" ] || { echo "pdk_env: ${dir} not found; install the pin: $(_pdk_env_get install)" >&2; return 1; }

  sources="${dir}/SOURCES"
  [ -r "${sources}" ] || { echo "pdk_env: ${sources} missing; cannot verify the open_pdks revision, refusing" >&2; return 1; }
  found="$(sed -n 's/^open_pdks[[:space:]]\{1,\}\([0-9a-f]\{7,40\}\).*/\1/p' "${sources}" | head -n1)"
  if [ "${found}" != "${pin}" ]; then
    echo "pdk_env: open_pdks revision mismatch in ${dir}: found '${found:-unknown}', pinned ${pin}; refusing" >&2
    return 1
  fi

  lib="${dir}/libs.tech/ngspice/sky130.lib.spice"
  [ -r "${lib}" ] || { echo "pdk_env: model library ${lib} missing" >&2; return 1; }

  export PDK_ROOT="${root}" PDK="${variant}" PDK_REVISION="${pin}" SKY130_MODEL_LIB="${lib}"
}

_pdk_env_resolve
_pdk_env_rc=$?
unset -f _pdk_env_get _pdk_env_resolve
unset _pdk_env_dir _pdk_env_json
if [ "${_pdk_env_rc}" -ne 0 ]; then unset _pdk_env_rc; return 1 2>/dev/null || exit 1; fi
unset _pdk_env_rc
