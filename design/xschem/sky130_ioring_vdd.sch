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
T {sky130_ioring_vdd: VDD supply pad. The bond pad IS the VDD rail (no separate PAD pin). Carries the VDD-VSS RC clamp (ESD.5, decision 0004).} -700 -760 0 0 0.3 0.3 {}
T {Sizing is a placeholder, OPEN pending simulation (T1 item 9). Spec proposed, not ratified. Not ESD-rated or qualified.} -700 -742 0 0 0.3 0.3 {}
C {sky130_ioring_clamp_core.sym} -300 -400 0 0 {name=X1}
C {devices/lab_pin.sym} -360 -460 0 0 {name=l4 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} -360 -340 0 0 {name=l5 sig_type=std_logic lab=VSS}
