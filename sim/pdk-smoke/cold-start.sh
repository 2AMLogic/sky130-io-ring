#!/usr/bin/env bash
# Cold start for T1 item 9: run the PDK smoke from a fresh checkout.
# run.sh refuses an existing OUTDIR (records are append-only), so this runs it
# into a throwaway directory and removes it; nothing is written under sim/.
# Needs the pinned PDK and ngspice (sim/pdk.json), so the inventory declares it
# local_only: CI re-checks file hashes but does not re-run it.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
tmp="$(mktemp -d)"; trap 'rm -rf "${tmp}"' EXIT
bash "${here}/run.sh" "${tmp}/record" >/dev/null
[ -s "${tmp}/record/record.json" ] || { echo "cold-start.sh: no record.json produced" >&2; exit 1; }
