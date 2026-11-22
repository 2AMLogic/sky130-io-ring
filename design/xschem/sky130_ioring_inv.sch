v {xschem version=3.4.7 file_version=1.2
}
G {}
K {type=subcircuit
}
V {}
S {}
E {}
C {devices/ipin.sym} -700 -600 0 0 {name=p1 lab=A}
C {devices/opin.sym} -700 -560 0 0 {name=p2 lab=Y}
C {devices/iopin.sym} -700 -520 0 0 {name=p3 lab=VDD}
C {devices/iopin.sym} -700 -480 0 0 {name=p4 lab=VSS}
T {sky130_ioring_inv: 1.8 V thin-oxide (nfet_01v8/pfet_01v8) gate, VDD domain (decision 0002, SUP.4).} -700 -760 0 0 0.3 0.3 {}
T {Sizing is a placeholder, OPEN pending simulation (T1 item 9). Spec proposed, not ratified. Not ESD-rated or qualified.} -700 -742 0 0 0.3 0.3 {}
C {sky130_fd_pr/pfet_01v8.sym} -300 -400 0 0 {name=MP L=0.15 W=1.0 nf=1 mult=1 model=pfet_01v8 spiceprefix=X}
C {devices/lab_pin.sym} -280 -430 0 0 {name=l5 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} -320 -400 0 0 {name=l6 sig_type=std_logic lab=A}
C {devices/lab_pin.sym} -280 -370 0 0 {name=l7 sig_type=std_logic lab=Y}
C {devices/lab_pin.sym} -280 -400 0 0 {name=l8 sig_type=std_logic lab=VDD}
C {sky130_fd_pr/nfet_01v8.sym} -40 -400 0 0 {name=MN L=0.15 W=0.65 nf=1 mult=1 model=nfet_01v8 spiceprefix=X}
C {devices/lab_pin.sym} -20 -430 0 0 {name=l9 sig_type=std_logic lab=Y}
C {devices/lab_pin.sym} -60 -400 0 0 {name=l10 sig_type=std_logic lab=A}
C {devices/lab_pin.sym} -20 -370 0 0 {name=l11 sig_type=std_logic lab=VSS}
C {devices/lab_pin.sym} -20 -400 0 0 {name=l12 sig_type=std_logic lab=VSS}
