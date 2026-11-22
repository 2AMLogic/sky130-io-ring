"""Minimal SPICE reader for the committed schematic netlists (PDK-independent).

The layout generator draws every device from the same `design/netlists/*.spice`
files LVS later compares against, so device sizes are read, never retyped.
Only the subset xschem writes is understood: `.subckt` / `.ends`, `+`
continuations, `*` comments and `X` cards. An `X` card is a device when its
model name is in the caller's device-model set, otherwise a subcircuit call.
"""
import re
from collections import namedtuple

Device = namedtuple("Device", "name nets model params")
Call = namedtuple("Call", "name nets subckt")
Subckt = namedtuple("Subckt", "name pins devices calls")


def _logical_lines(text):
    out = []
    for raw in text.splitlines():
        line = raw.rstrip()
        if not line or line.lstrip().startswith("*"):
            continue
        if line.startswith("+") and out:
            out[-1] += " " + line[1:].strip()
        else:
            out.append(line.strip())
    return out


def _number(text):
    m = re.fullmatch(r"([-+0-9.eE]+)([a-zA-Z]*)", text)
    scale = {"": 1.0, "u": 1e-6, "n": 1e-9, "p": 1e-12, "m": 1e-3, "meg": 1e6, "k": 1e3}
    if not m or m.group(2).lower() not in scale:
        return text
    return float(m.group(1)) * scale[m.group(2).lower()]


def parse(path, device_models):
    """Return {subckt name: Subckt} for every `.subckt` in the file.

    A name defined more than once (xschem repeats a child's definition in each
    parent's file) keeps its last definition.
    """
    subckts = {}
    cur = None
    with open(path) as f:
        lines = _logical_lines(f.read())
    for line in lines:
        tok = line.split()
        head = tok[0].lower()
        if head == ".subckt":
            cur = Subckt(tok[1], [t for t in tok[2:] if "=" not in t], [], [])
        elif head == ".ends":
            subckts[cur.name] = cur
            cur = None
        elif cur is not None and head.startswith("x"):
            plain = [t for t in tok[1:] if "=" not in t]
            params = {k: _number(v) for k, v in (t.split("=", 1) for t in tok[1:] if "=" in t)}
            model, nets = plain[-1], plain[:-1]
            if model in device_models:
                cur.devices.append(Device(tok[0][1:], nets, model, params))
            else:
                cur.calls.append(Call(tok[0][1:], nets, model))
        elif cur is not None:
            raise ValueError(f"{path}: unsupported card {line!r}")
    return subckts
