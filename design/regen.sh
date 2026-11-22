#!/usr/bin/env bash
# Regenerate (or, with --check, verify) every derived netlist under design/netlists/.
#   bash design/regen.sh            rewrite design/netlists/*.spice from design/xschem/*.sch
#   bash design/regen.sh --check    write nothing; exit 3 if any netlist drifted from its schematic
# Serial, one `klt netlist` per schematic (see netlist.sh).
set -uo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mode=()
[ "${1:-}" = "--check" ] && mode=(--check)
mkdir -p "${here}/netlists"
rc=0
for sch in "${here}"/xschem/*.sch; do
  cell="$(basename "${sch}" .sch)"
  if bash "${here}/netlist.sh" "${mode[@]}" "${cell}"; then
    echo "ok    ${cell}"
  else
    echo "FAIL  ${cell} (exit $?)"; rc=3
  fi
done
exit "${rc}"
