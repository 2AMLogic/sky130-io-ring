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
    `coverage.` prefix on the field name is stripped);
  - a hash pinned to its role, written `dotted.path` is `sha256:...`, must
    equal the value at that JSON path in the source. A bare token only
    asserts set-membership anywhere in the source, so a current hash quoted
    in the wrong role (the input-stream hash cited where the deck hash
    belongs) would pass; the pinned form closes that. Pinning is opt-in per
    citation; abbreviated hash forms match the pinned value the same way.
  - a near-miss pin is an error too (#146): a backticked path name that
    resolves to a hash in the source, on a line that also carries a hash
    token, but which is not written in the pinned form — a phrasing edit
    ("is now", "=", backticks dropped around the hash) silently de-pins the
    role and the citation degrades to set-membership. The error names the
    canonical form so the fix is mechanical. A path name on a line with no
    hash is prose about the path, not a citation, and stays silent;
    cite:historical does not excuse a near-miss (the escape excuses hashes
    absent from the source, and a near-miss path resolves in it by
    definition).
  - a split pin is an error too (#148): the pinned form is single-line by
    convention, so a backticked path name that resolves to a hash and ends
    its line carrying no hash — only a pin connector (`is`, `is now`, `=`,
    `:`) or whitespace after the name — is checked against the next
    non-blank line of the same region; a hash token there means the hash
    reflowed off the pin line and the citation silently degraded to
    set-membership (even when the reflowed hash is the correct value — a
    split pin asserts membership either way). The error names the canonical
    single-line form so the fix is mechanical. Sentence punctuation after
    the name — a resolving name ending a sentence above an unrelated hash
    — is prose and stays quiet; the lookahead is region-bounded and never
    crosses cite:end, cite:begin, a fence, or end of file. A path name
    written without backticks is not scanned at all: the canonical grammar
    has always required them, so a bare name is prose by definition (#148
    row 3, out of scope).

Set-membership also cannot see an *omitted* citation (the other half of
#130), so a begin marker may declare the coverage fields the region must
count-cite:

    <!-- cite:begin source=... requires=rules_checked,rules_skipped -->

`requires=` names coverage fields; closing the region without an asserted
count citation for each is a hard error. It is opt-in per region — a field
mentioned only as a quoted contents list (`field` is `66/13`, ...) is not a
count citation and must not be required — and a region without requires=
behaves exactly as before. A requires= name absent from the source's
coverage object is itself an error, so the declaration cannot rot into a
no-op.

A deliberate stale reference — a historical deck hash pinned as the record of
an earlier survey — is excused by an inline <!-- cite:historical --> on its
line. The escape suppresses only hashes *absent* from the source; a hash that
the source does contain fails anyway, so the escape cannot rot into a blanket
suppression. Outside a region nothing is scanned: the historical pins in the
append-only record are out of scope by construction. Marker recognition
ignores occurrences inside inline-code spans, so prose that documents the
marker syntax does not itself open or close a region; fenced code blocks
(three or more backticks or tildes) are inert outright — example syntax
inside a fence opens no region, and hashes or counts inside a fence are
illustrative, never asserted.

Counts the grammar does not capture are not asserted: a field followed by a
quoted contents list (`field` is `66/13`, ...) and free narrative numbers
("had skipped 57 rules") stay review-only. This is deliberate — those are
citations of contents or of predecessor reports, not of this source's counts.

Missing/unreadable source, nested or unterminated regions, cite:end without
begin, count fields absent from the source, a requires= field the region
never count-cites, a role path absent from the source, a role-pinned hash
that disagrees with the path's value, a near-miss pin (a backticked
path name that resolves to a hash on a hash-carrying line but is not
written in the pinned form), and a split pin (a resolving name ending its
line hash-free with a hash token on the region's immediately-next line —
a blank line ends the lookahead, and a candidate line that itself begins
a list item or table cell never arms one; #151) are hard errors.

Usage:
    python3 -I scripts/ci/check_prose_citations.py .    # exit 1 on any
                                                        # disagreement
"""
import json
import re
import sys
from pathlib import Path

BEGIN = re.compile(r"<!--\s*cite:begin\s+(.*?)\s*-->")
END = re.compile(r"<!--\s*cite:end\s*-->")
HISTORICAL = "<!-- cite:historical -->"
HASH_RE = re.compile(
    r"sha256:(?P<full>[0-9a-f]{64})"
    r"|sha256:(?P<ahead>[0-9a-f]{4,})\.\.\.(?P<atail>[0-9a-f]{4,})"
    r"|(?:sha256:)?(?P<uhead>[0-9a-f]{4,})…")
PATH_HASH = re.compile(r"`([A-Za-z_][A-Za-z0-9_.]*)` is `(sha256:[^`]+)`")
COUNT_IS = re.compile(r"`([A-Za-z_][A-Za-z0-9_.]*)` is (\d+)\b")
COUNT_PAREN = re.compile(r"`([A-Za-z_][A-Za-z0-9_.]*)` \((\d+)[,)]")
SPLIT_TAIL = re.compile(r"^(?:\s*(?:is now|is|=|:))?\s*$")
LIST_OR_TABLE_CELL = re.compile(r"^\s*(?:[-*+]|\d+[.)]|\|)\s")
FIELD_NAME = re.compile(r"[A-Za-z_][A-Za-z0-9_.]*")
BACKTICKED = re.compile(r"`([^`]+)`")
HEX64 = re.compile(r"[0-9a-f]{64}")
FENCE = re.compile(r"^ {0,3}(`{3,}|~{3,})")
SKIP_PARTS = {"node_modules", "target", "__pycache__"}


def in_code_span(line, pos):
    return line.count("`", 0, pos) % 2 == 1


def fence_state(line, state):
    """Track fenced code blocks, CommonMark-style: a fence of three or more
    backticks or tildes (with up to three leading spaces, optional info
    string) opens one; a bare fence of the same character at least as long
    closes it. Returns the new (char, length) state, or None outside."""
    m = FENCE.match(line)
    if state is None:
        return (m.group(1)[0], len(m.group(1))) if m else None
    ch, length = state
    if (m and m.group(1)[0] == ch and len(m.group(1)) >= length
            and line.strip() == m.group(1)):
        return None
    return state


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
    """Return (hashes, coverage, data) or a list of error strings."""
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
    return hashes, cov, data


def parse_begin(attrs, where):
    """Parse cite:begin attributes: `source=<path>` plus the optional
    `requires=<field>,<field>`. Unknown, malformed or repeated attributes
    are hard errors (fail closed)."""
    seen = {}
    for tok in attrs.split():
        key, sep, value = tok.partition("=")
        if (not sep or not value or key not in ("source", "requires")
                or key in seen):
            return None, (f"{where}: malformed cite:begin attribute `{tok}` "
                          f"(expected source=<path> [requires=a,b,...])")
        seen[key] = value
    if "source" not in seen:
        return None, f"{where}: cite:begin without source="
    requires = []
    for name in seen.get("requires", "").split(","):
        if name and not FIELD_NAME.fullmatch(name):
            return None, (f"{where}: requires= name `{name}` is not a "
                          f"coverage field name")
        if name:
            requires.append(name)
    return {"source": seen["source"], "requires": requires}, None


def hash_matches(m, hashes):
    if m.group("full") is not None:
        return m.group("full") in hashes
    if m.group("ahead") is not None:
        head, tail = m.group("ahead"), m.group("atail")
        return any(h.startswith(head) and h.endswith(tail) for h in hashes)
    head = m.group("uhead")
    return any(h.startswith(head) for h in hashes)


def count_name(field):
    return (field.split("coverage.", 1)[1]
            if field.startswith("coverage.") else field)


def assert_count(region, where, field, cited, errors):
    source, cov = region["source"], region["cov"]
    name = count_name(field)
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


MISSING = object()


def resolve_path(data, path):
    """Follow a dotted JSON path from the loaded source; return the node,
    or MISSING when a step is absent or passes through a non-object. A
    sentinel rather than None keeps "absent" distinguishable from a JSON
    null value."""
    node = data
    for part in path.split("."):
        if not isinstance(node, dict) or part not in node:
            return MISSING
        node = node[part]
    return node


def assert_path_hash(region, where, path, token, errors):
    """A role-pinned hash: the value at that dotted JSON path in the source
    must equal the cited hash (abbreviated forms matched against it). The
    point of the pin is that membership is not enough — the input-stream and
    deck hashes both live in the same report, and a current hash quoted in
    the wrong role must fail."""
    source, data = region["source"], region["data"]
    if data is None:          # source failed to load; already reported
        return
    node = resolve_path(data, path)
    if node is MISSING:
        errors.append(f"{where}: `{path}` names a path absent from "
                      f"{source}")
        return
    if not isinstance(node, str):
        errors.append(f"{where}: `{path}` is not a hash value in {source}")
        return
    m = HASH_RE.fullmatch(token)
    if not m or not hash_matches(m, set(HEX64.findall(node))):
        errors.append(f"{where}: `{path}` is cited as {token} but {source} "
                      f"{path} is {node}")


def resolves_to_hash(region, path):
    """Near-miss condition 2: does this dotted path resolve to a string
    carrying a hash in the region's source?"""
    data = region["data"]
    if data is None:
        return False
    node = resolve_path(data, path)
    return isinstance(node, str) and bool(HEX64.search(node))


def check_near_miss_pin(region, where, line, pinned, errors):
    """A de-pinned citation made loud (#146): a backticked name that
    (1) matches FIELD_NAME, (2) resolves to a hash value in the region's
    source, and (3) shares its line with a hash-shaped token, but is not
    itself part of a recognised PATH_HASH pin (4), is a phrasing edit away
    from a role pin — "is now", "=", or backticks dropped around the hash —
    and the citation has silently degraded to set-membership. The error
    names the canonical form so the fix is mechanical from the CI log. A
    field name on a hash-free line is prose about the path, not a citation,
    and stays quiet here — a hash-free name ending its line with a pin
    connector is #148's split-pin candidate instead, completed across
    lines by check_split_pin; cite:historical does not excuse a near-miss
    (the escape excuses hashes absent from the source, and a near-miss path
    resolves in it by definition)."""
    if region["data"] is None or not HASH_RE.search(line):
        return
    for m in BACKTICKED.finditer(line):
        name = m.group(1)
        if not FIELD_NAME.fullmatch(name):
            continue
        if any(s <= m.start() and m.end() <= e for s, e in pinned):
            continue
        if resolves_to_hash(region, name):
            errors.append(
                f"{where}: `{name}` resolves to a hash in "
                f"{region['source']} but this line does not write it as a "
                f"role pin, so the citation asserts set-membership only — "
                f"write `{name}` is `sha256:...` to pin it")


def split_pin_candidate(region, line):
    """#148's split-pin candidate rule: on a hash-free line, a backticked
    name that matches FIELD_NAME, resolves to a hash value in the region's
    source, and ends the line — apart from a pin connector (`is`, `is now`,
    `=`, `:`) or whitespace — is a pin whose hash may have reflowed onto
    the next line. #151 narrows the rule's reach, both measured free: the
    lookahead the candidate arms is one immediately-next line (a reflow
    never inserts a paragraph break, so check_file ends the lookahead at a
    blank line), and a line that begins a list item or table cell (the
    LIST_OR_TABLE_CELL lead: `-`, `*`, `+`, a digit dot/paren marker, or
    `|`, each followed by whitespace) never arms one — a list or table
    reads as structured prose, not a reflowed pin. The trailing whitespace
    in that regex is load-bearing: `0.9.1` version prose is not an
    ordered-list marker. The earlier narrowing stays: sentence punctuation
    after the name (a resolving name ending a sentence above an unrelated
    hash) disqualifies the candidate and keeps that prose shape quiet. A
    path name written without backticks is never scanned — the canonical
    grammar has always required them, so a bare name is prose by
    definition (#148 row 3, out of scope)."""
    if HASH_RE.search(line):
        return None
    if LIST_OR_TABLE_CELL.match(line):
        return None
    for m in BACKTICKED.finditer(line):
        name = m.group(1)
        if not FIELD_NAME.fullmatch(name):
            continue
        if not resolves_to_hash(region, name):
            continue
        if SPLIT_TAIL.match(line[m.end():]):
            return name
    return None


def check_split_pin(region, pending, where, line, errors):
    """#148's one-line lookahead, narrowed in #151 to the immediately-next
    line: a hash token on this line completes the previous line's
    split-pin candidate — check_file clears `pending` on every in-region
    line, blank ones included, so a paragraph break ends the lookahead,
    and a candidate under a list item or table cell never arms it (see
    split_pin_candidate). The pin is de-pinned whether the
    reflowed hash is right or wrong — a split pin asserts set-membership
    only — so the value is never consulted and the error names the
    canonical single-line form. cite:historical on the hash line does not
    excuse the split (consistent with #146: the escape excuses hashes
    absent from the source, and a split-pin path resolves in it by
    definition)."""
    if pending is None or not HASH_RE.search(line):
        return
    name, name_where = pending
    errors.append(
        f"{name_where}: `{name}` resolves to a hash in "
        f"{region['source']} but its role pin is split across lines, so "
        f"the citation asserts set-membership only — write `{name}` is "
        f"`sha256:...` on one line to pin it")


def check_requires(region, where, errors):
    """The omitted-citation half of #130: a region that declares requires=
    must carry an asserted count citation for each named coverage field.
    Omission used to be invisible — the checker asserted citations that were
    present and nothing tracked absence."""
    if not region["requires"] or region["cov"] is None:
        return
    for name in region["requires"]:
        if name not in region["cov"]:
            errors.append(f"{where}: requires= names `{name}`, absent from "
                          f"{region['source']} coverage")
        elif name not in region["asserted"]:
            errors.append(f"{where}: region opened at line {region['line']} "
                          f"(source={region['source']}) requires a count "
                          f"citation for `{name}` but asserts none")


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
    pinned = [p.span() for p in PATH_HASH.finditer(line)]
    for m in PATH_HASH.finditer(line):
        assert_path_hash(region, where, m.group(1), m.group(2), errors)
    check_near_miss_pin(region, where, line, pinned, errors)
    for m in COUNT_IS.finditer(line):
        region["asserted"].add(count_name(m.group(1)))
        assert_count(region, where, m.group(1), int(m.group(2)), errors)
    for m in COUNT_PAREN.finditer(line):
        region["asserted"].add(count_name(m.group(1)))
        assert_count(region, where, m.group(1), int(m.group(2)), errors)


def check_file(root, rel, text, errors):
    if "cite:begin" not in text and "cite:end" not in text:
        return
    region = None
    fence = None
    pending = None          # (name, where) from #148's split-pin lookahead
    for n, line in enumerate(text.splitlines(), 1):
        new_fence = fence_state(line, fence)
        if new_fence is not fence:
            fence = new_fence
            pending = None  # fenced syntax never completes a pin
            continue          # the fence delimiter line itself is inert
        if fence is not None:
            continue          # fenced code is example syntax, never asserted
        where = f"{rel}:{n}"
        b = find_marker(BEGIN, line)
        e = find_marker(END, line)
        if b or e:
            pending = None    # a marker line bounds the region: the
                              # lookahead never crosses one (#148)
        if b and e:
            errors.append(f"{where}: cite:begin and cite:end on one line")
            continue
        if b:
            attrs, perr = parse_begin(b.group(1), where)
            if perr is not None:
                errors.append(perr)
                continue
            if region is not None:
                errors.append(f"{where}: nested cite:begin (region "
                              f"source={region['source']} opened at line "
                              f"{region['line']})")
                continue
            source = attrs["source"]
            loaded = load_source(root, source)
            region = {"source": source, "line": n, "hashes": None,
                      "cov": None, "data": None,
                      "requires": attrs["requires"], "asserted": set()}
            if isinstance(loaded, list):
                errors.extend(f"{where}: {msg}" for msg in loaded)
            else:
                region["hashes"], region["cov"], region["data"] = loaded
            continue
        if e:
            if region is None:
                errors.append(f"{where}: cite:end without cite:begin")
            else:
                check_requires(region, where, errors)
            region = None
            continue
        if region is not None and region["hashes"] is not None:
            check_split_pin(region, pending, where, line, errors)
            pending = None    # the lookahead is the immediately-next line
                              # only (#151): a blank line ends it
            if line.strip():
                name = split_pin_candidate(region, line)
                if name is not None:
                    pending = (name, where)
            check_line(region, where, line, errors)
    if region is not None:
        errors.append(f"{rel}:{region['line']}: unterminated cite region "
                      f"(source={region['source']}) — no cite:end before "
                      f"end of file")
        check_requires(region, f"{rel}:{region['line']}", errors)


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
