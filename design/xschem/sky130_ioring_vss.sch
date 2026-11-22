v {xschem version=3.4.7 file_version=1.2
}
G {}
K {type=subcircuit
}
V {}
S {}
E {}
C {devices/iopin.sym} -700 -600 0 0 {name=p1 lab=VDDIO}
C {devices/iopin.sym} -700 -560 0 0 {name=p2 lab=VDD}
C {devices/iopin.sym} -700 -520 0 0 {name=p3 lab=VSS}
T {sky130_ioring_vss: VSS ground pad. The bond pad IS the VSS rail (no separate PAD pin). Rail-only, no devices: one ground net (SUP.5, decision 0002).} -700 -760 0 0 0.3 0.3 {}
T {Empty subcircuit body on purpose; the pad-to-rail tie is a layout fact.} -700 -742 0 0 0.3 0.3 {}
