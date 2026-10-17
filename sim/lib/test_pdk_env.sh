#!/usr/bin/env bash
# Self-test of the sim/lib/pdk_env.sh revision refusal. Uses throwaway fake
# trees, so it needs no installed PDK. Run: bash sim/lib/test_pdk_env.sh
set -u
here="$(cd "$(dirname "$0")" && pwd)"
pin="$(sed -n 's/^ *"open_pdks_revision" *: *"\([^"]*\)".*/\1/p' "${here}/../pdk.json")"
tmp="$(mktemp -d)"; trap 'rm -rf "${tmp}"' EXIT
fail=0
check() { if [ "$2" = "$3" ]; then echo "ok   - $1"; else echo "FAIL - $1 (expected $2, got $3)"; fail=1; fi; }

mk() { # name sources-content
  mkdir -p "${tmp}/$1/sky130A/libs.tech/ngspice"
  : > "${tmp}/$1/sky130A/libs.tech/ngspice/sky130.lib.spice"
  [ -n "${2:-}" ] && printf '%s\n' "$2" > "${tmp}/$1/sky130A/SOURCES"
}
resolve() { (PDK_ROOT="${tmp}/$1" bash -c ". '${here}/pdk_env.sh'" 2>"${tmp}/err"); }

mk good "open_pdks ${pin}"
resolve good; check "pinned tree accepted" 0 $?

mk stale "open_pdks c6d73a35f524070e85faff4a6a9eef49553ebc2b"
resolve stale; check "stale revision refused (non-zero)" 1 $?
grep -q "revision mismatch" "${tmp}/err"; check "stale revision message names the mismatch" 0 $?

mk nosrc ""
resolve nosrc; check "missing SOURCES refused" 1 $?
grep -q "SOURCES missing" "${tmp}/err"; check "missing SOURCES message" 0 $?

mk junk "not a sources file"
resolve junk; check "unparseable SOURCES refused" 1 $?

resolve absent; check "absent tree refused" 1 $?

out="$(PDK_ROOT="${tmp}/good" bash -c ". '${here}/pdk_env.sh' && echo \"\$PDK_REVISION \$PDK\"")"
check "exports revision and variant" "${pin} sky130A" "${out}"

exit "${fail}"
