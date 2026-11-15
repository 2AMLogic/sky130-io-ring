#!/usr/bin/env python3
"""Assert hand-written prose citations against the evidence JSON they cite.

Prose that quotes a signoff report drifts silently (three recurrences: #122,
#130, #136). A paragraph that cites an evidence file is wrapped in

    <!-- cite:begin source=signoff/evidence/drc/ring.json -->
    ...prose...
    <!-- cite:end -->

(the marker contract follows spec/check_spec.py's rows:begin/end convention;
the begin marker names its source, so the checker never guesses). Inside a
region the checker extracts and asserts — it never regenerates narrative:

  - every sha256: token — full (sha256:<64 hex>), ASCII head...tail
    (sha256:ba0f9788...942e6), or Unicode head-only (ba0f9788…) — must match
    a hash present anywhere in the named source;
  - every count written as `field` is N or `field` (N[,)] must equal the
    source's value (len() for lists, the scalar for ints; an optional
    `coverage.` prefix on the field name is stripped).

A deliberate stale reference — a historical deck hash pinned as the record of
an earlier survey — is excused by an inline <!-- cite:historical --> on its
line. The escape suppresses only hashes *absent* from the source; a hash that
the source does contain fails anyway, so the escape cannot rot into a blanket
suppression. Outside a region nothing is scanned: the historical pins in the
append-only record are out of scope by construction. Marker recognition
ignores occurrences inside inline-code spans, so prose that documents the
marker syntax does not itself open or close a region.

Counts the grammar does not capture are not asserted: a field followed by a
quoted contents list (`field` is `66/13`, ...) and free narrative numbers
("had skipped 57 rules") stay review-only. This is deliberate — those are
citations of contents or of predecessor reports, not of this source's counts.

Missing/unreadable source, nested or unterminated regions, cite:end without
begin, and count fields absent from the source are hard errors.

Usage:
    python3 -I scripts/ci/check_prose_citations.py .    # exit 1 on any
                                                        # disagreement
"""
import json
import re
import sys
from pathlib import Path

BEGIN = re.compile(r"<!--\s*cite:begin\s+source=(\S+)\s*-->")
END = re.compile(r"<!--\s*cite:end\s*-->")
HISTORICAL = "<!-- cite:historical -->"
HASH_RE = re.compile(
    r"sha256:(?P<full>[0-9a-f]{64})"
    r"|sha256:(?P<ahead>[0-9a-f]{4,})\.\.\.(?P<atail>[0-9a-f]{4,})"
    r"|(?:sha256:)?(?P<uhead>[0-9a-f]{4,})…")
COUNT_IS = re.compile(r"`([A-Za-z_][A-Za-z0-9_.]*)` is (\d+)\b")
COUNT_PAREN = re.compile(r"`([A-Za-z_][A-Za-z0-9_.]*)` \((\d+)[,)]")
HEX64 = re.compile(r"[0-9a-f]{64}")
SKIP_PARTS = {"node_modules", "target", "__pycache__"}


def in_code_span(line, pos):
    return line.count("`", 0, pos) % 2 == 1


def find_marker(regex, line):
    """First marker match outside inline-code spans — prose that *mentions*
    the marker syntax inside backticks documents it, it does not open or
    close a region. Hash and count citations inside code spans stay asserted
    (that is where prose puts them); only marker recognition skips spans."""
    for m in regex.finditer(line):
        if not in_code_span(line, m.start()):
            return m
    return None


def has_historical(line):
    pos = line.find(HISTORICAL)
    while pos != -1:
        if not in_code_span(line, pos):
            return True
        pos = line.find(HISTORICAL, pos + 1)
    return False


def collect_hashes(node, out):
    if isinstance(node, str):
        out.update(HEX64.findall(node))
    elif isinstance(node, dict):
        for v in node.values():
            collect_hashes(v, out)
    elif isinstance(node, list):
        for v in node:
            collect_hashes(v, out)


def load_source(root, source):
    """Return (hashes, coverage) or a list of error strings."""
    path = root / source
    if not path.is_file():
        return [f"cite:begin source={source}: no such file"]
    try:
        data = json.loads(path.read_text())
    except (OSError, ValueError) as e:
        return [f"cite:begin source={source}: unreadable evidence JSON ({e})"]
    if not isinstance(data, dict):
        return [f"cite:begin source={source}: top level is not a JSON object"]
    hashes = set()
    collect_hashes(data, hashes)
    cov = data.get("coverage")
    if not isinstance(cov, dict):
        return [f"cite:begin source={source}: no coverage object"]
    return hashes, cov


def hash_matches(m, hashes):
    if m.group("full") is not None:
        return m.group("full") in hashes
    if m.group("ahead") is not None:
        head, tail = m.group("ahead"), m.group("atail")
        return any(h.startswith(head) and h.endswith(tail) for h in hashes)
    head = m.group("uhead")
    return any(h.startswith(head) for h in hashes)


def assert_count(region, where, field, cited, errors):
    source, cov = region["source"], region["cov"]
    name = field.split("coverage.", 1)[1] if field.startswith("coverage.") else field
    if name not in cov:
        errors.append(f"{where}: `{field}` names a field absent from "
                      f"{source} coverage")
        return
    v = cov[name]
    if isinstance(v, list):
        expected = len(v)
    elif isinstance(v, int) and not isinstance(v, bool):
        expected = v
    else:
        errors.append(f"{where}: `{field}` is not a countable value in {source}")
        return
    if cited != expected:
        errors.append(f"{where}: `{field}` is cited as {cited} but {source} "
                      f"coverage.{name} is {expected}")


def check_line(region, where, line, errors):
    historical = has_historical(line)
    for m in HASH_RE.finditer(line):
        token = m.group(0)
        hit = hash_matches(m, region["hashes"])
        if hit and historical:
            errors.append(f"{where}: cite:historical escape but {token} "
                          f"matches the source ({region['source']}) — the "
                          f"escape would suppress a current citation")
        elif not hit and not historical:
            errors.append(f"{where}: {token} does not match any hash in "
                          f"{region['source']}")
    for m in COUNT_IS.finditer(line):
        assert_count(region, where, m.group(1), int(m.group(2)), errors)
    for m in COUNT_PAREN.finditer(line):
        assert_count(region, where, m.group(1), int(m.group(2)), errors)


def check_file(root, rel, text, errors):
    if "cite:begin" not in text and "cite:end" not in text:
        return
    region = None
    for n, line in enumerate(text.splitlines(), 1):
        where = f"{rel}:{n}"
        b = find_marker(BEGIN, line)
        e = find_marker(END, line)
        if b and e:
            errors.append(f"{where}: cite:begin and cite:end on one line")
            continue
        if b:
            if region is not None:
                errors.append(f"{where}: nested cite:begin (region "
                              f"source={region['source']} opened at line "
                              f"{region['line']})")
                continue
            source = b.group(1)
            loaded = load_source(root, source)
            region = {"source": source, "line": n, "hashes": None, "cov": None}
            if isinstance(loaded, list):
                errors.extend(f"{where}: {msg}" for msg in loaded)
            else:
                region["hashes"], region["cov"] = loaded
            continue
        if e:
            if region is None:
                errors.append(f"{where}: cite:end without cite:begin")
            region = None
            continue
        if region is not None and region["hashes"] is not None:
            check_line(region, where, line, errors)
    if region is not None:
        errors.append(f"{rel}:{region['line']}: unterminated cite region "
                      f"(source={region['source']}) — no cite:end before "
                      f"end of file")


def check_root(root):
    root = Path(root)
    errors = []
    for path in sorted(root.rglob("*.md")):
        rel = path.relative_to(root)
        if any(p.startswith(".") or p in SKIP_PARTS for p in rel.parts[:-1]):
            continue
        check_file(root, rel.as_posix(), path.read_text(), errors)
    return errors


def main(argv):
    errors = check_root(argv[1] if len(argv) > 1 else ".")
    for e in errors:
        print("FAIL:", e)
    if not errors:
        print("OK: prose citations agree with the evidence they cite")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
