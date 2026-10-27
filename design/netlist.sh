#!/usr/bin/env bash
# Netlist one cell: design/xschem/<cell>.sch -> design/netlists/<cell>.spice.
#   bash design/netlist.sh <cell>            regenerate
#   bash design/netlist.sh --check <cell>    exit 0 if the committed netlist matches, 3 if it drifted
# Goes through `klt netlist` (headless, bounded); never call xschem directly.
# Runs one xschem process, locally. Needs klt >= 0.8, xschem and the pinned PDK
# (sim/pdk.json); CI has none of them, so the attestation marks these
# commands local_only.
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "${here}/.." && pwd)"
check=()
if [ "${1:-}" = "--check" ]; then check=(--check); shift; fi
cell="${1:?usage: netlist.sh [--check] <cell>}"
# shellcheck source=../sim/lib/pdk_env.sh
source "${root}/sim/lib/pdk_env.sh"
cd "${root}"
exec klt netlist "design/xschem/${cell}.sch" -o "design/netlists/${cell}.spice" \
  --rcfile design/xschemrc --pdk "${PDK}" --pdk-root "${PDK_ROOT}" "${check[@]}" --format json >/dev/null
