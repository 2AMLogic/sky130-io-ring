#!/usr/bin/env bash
# PDK-independent harness half: the run.sh preamble and record tail shared by
# every sim/<probe>/run.sh. Source it; do not execute. Names no PDK path,
# device or corner -- the caller supplies OUTDIR, the netlist emitter, the
# log/netlist file names and the record meta text -- so a port stamps this
# file unchanged (sim/README.md, "Layout").
#
#   # from a sim/<probe>/run.sh:
#   source "$(dirname "$0")/../lib/run_common.sh"
#
# run_common_setup [OUTDIR]      refuse an existing OUTDIR (records are
#                                append-only), source pdk_env.sh, check
#                                ngspice, mkdir, mktemp workdir + trap.
#                                Sets repo, out, work.
# run_common_scrub               stdin -> stdout; absolute paths become the
#                                $PDK_ROOT / $WORK / $REPO tokens.
# run_common_ngspice SP LOG [TAG]  one ngspice -b run in $work; warns on a
#                                non-zero exit, never aborts the probe.
# run_common_tools_json [TOOL...]  the JSON for the record's "tools" object.
#                                A tool is probed only if named (default: all
#                                three); the value is its version, "absent"
#                                (probed, not installed) or "not-probed"
#                                (not named) -- never one token for both
#                                (sim/pdk.json:tools.* stays the install
#                                pin). Present but unparsable: "unknown".
#                                Version capture never aborts a probe: a
#                                missing ciel/xschem is a recorded fact, not
#                                a failure.
# run_common_record META [--log NAME=PATH]...  write ${out}/record.json.

run_common_setup() { # [OUTDIR]; sets repo, out, work
  local here
  here="$(cd "$(dirname "$0")" && pwd)"
  repo="$(cd "${here}/../.." && pwd)"
  out="${1:-${here}/record}"
  [ ! -e "${out}" ] || { echo "run.sh: ${out} exists; records are append-only" >&2; exit 1; }

  # shellcheck source=pdk_env.sh
  source "${repo}/sim/lib/pdk_env.sh"
  command -v ngspice >/dev/null || { echo "run.sh: ngspice not on PATH" >&2; exit 1; }

  mkdir -p "${out}/netlists" "${out}/logs"
  work="$(mktemp -d)"
  trap 'rm -rf "${work}"' EXIT
}

run_common_scrub() { # stdin -> stdout
  sed -e "s#${PDK_ROOT}#\$PDK_ROOT#g" -e "s#${work}#\$WORK#g" -e "s#${repo}#\$REPO#g"
}

run_common_ngspice() { # SP LOG [TAG]
  local sp="$1" log="$2" tag="${3:-}" rc=0
  (cd "${work}" && ngspice -b -o "${log}" "${sp}" </dev/null >/dev/null 2>&1) || rc=$?
  if [ "${rc}" -ne 0 ]; then
    if [ -n "${tag}" ]; then
      echo "run.sh: ngspice (${tag}) exited ${rc}" >&2
    else
      echo "run.sh: ngspice exited ${rc}" >&2
    fi
  fi
}

run_common_tool_version() { # TOOL -> version string, or absent/unknown
  local raw=""
  command -v "$1" >/dev/null 2>&1 || { printf 'absent\n'; return 0; }
  case "$1" in
    ngspice) raw="$(ngspice --version | sed -n 's/.*ngspice-\([0-9.]*\).*/\1/p' | head -n1)" || true ;;
    ciel) raw="$(ciel --version 2>/dev/null | sed -n 's/^Ciel v\([0-9.]*\).*/\1/p' | head -n1)" || true ;;
    xschem) raw="$(xschem --version 2>&1 | sed -n 's/^XSCHEM V\([0-9.]*\).*/\1/p' | head -n1)" || true ;;
    *) printf 'not-probed\n'; return 0 ;;
  esac
  if [ -n "${raw}" ]; then printf '%s\n' "${raw}"; else printf 'unknown\n'; fi
}

run_common_tools_json() { # [TOOL...] (default: ngspice ciel xschem)
  local want=" ${*:-ngspice ciel xschem} " t v out="" sep=""
  for t in ngspice ciel xschem; do
    if [[ "${want}" == *" ${t} "* ]]; then
      v="$(run_common_tool_version "${t}")"
    else
      v="not-probed"
    fi
    out+="${sep}\"${t}\": \"${v}\""
    sep=", "
  done
  printf '{%s}\n' "${out}"
}

run_common_record() { # META [--log NAME=PATH]...
  local meta="$1"
  shift
  (cd "${out}" && python3 -I "${repo}/sim/lib/simrec.py" write record.json --meta "${meta}" "$@")
}
