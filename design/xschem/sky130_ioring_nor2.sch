v {xschem version=3.4.7 file_version=1.2
}
G {}
K {type=subcircuit
}
V {}
S {}
E {}
C {devices/ipin.sym} -700 -600 0 0 {name=p1 lab=A}
C {devices/ipin.sym} -700 -560 0 0 {name=p2 lab=B}
C {devices/opin.sym} -700 -520 0 0 {name=p3 lab=Y}
C {devices/iopin.sym} -700 -480 0 0 {name=p4 lab=VDD}
C {devices/iopin.sym} -700 -440 0 0 {name=p5 lab=VSS}
T {sky130_ioring_nor2: 1.8 V thin-oxide (nfet_01v8/pfet_01v8) gate, VDD domain (decision 0002, SUP.4).} -700 -760 0 0 0.3 0.3 {}
T {Sizing is a placeholder, OPEN pending simulation (T1 item 9). Spec proposed, not ratified. Not ESD-rated or qualified.} -700 -742 0 0 0.3 0.3 {}
C {sky130_fd_pr/pfet_01v8.sym} -300 -400 0 0 {name=MPA L=0.15 W=2.0 nf=1 mult=1 model=pfet_01v8 spiceprefix=X}
C {devices/lab_pin.sym} -280 -430 0 0 {name=l6 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} -320 -400 0 0 {name=l7 sig_type=std_logic lab=A}
C {devices/lab_pin.sym} -280 -370 0 0 {name=l8 sig_type=std_logic lab=p1}
C {devices/lab_pin.sym} -280 -400 0 0 {name=l9 sig_type=std_logic lab=VDD}
C {sky130_fd_pr/pfet_01v8.sym} -40 -400 0 0 {name=MPB L=0.15 W=2.0 nf=1 mult=1 model=pfet_01v8 spiceprefix=X}
C {devices/lab_pin.sym} -20 -430 0 0 {name=l10 sig_type=std_logic lab=p1}
C {devices/lab_pin.sym} -60 -400 0 0 {name=l11 sig_type=std_logic lab=B}
C {devices/lab_pin.sym} -20 -370 0 0 {name=l12 sig_type=std_logic lab=Y}
C {devices/lab_pin.sym} -20 -400 0 0 {name=l13 sig_type=std_logic lab=VDD}
C {sky130_fd_pr/nfet_01v8.sym} 220 -400 0 0 {name=MNA L=0.15 W=0.65 nf=1 mult=1 model=nfet_01v8 spiceprefix=X}
C {devices/lab_pin.sym} 240 -430 0 0 {name=l14 sig_type=std_logic lab=Y}
C {devices/lab_pin.sym} 200 -400 0 0 {name=l15 sig_type=std_logic lab=A}
C {devices/lab_pin.sym} 240 -370 0 0 {name=l16 sig_type=std_logic lab=VSS}
C {devices/lab_pin.sym} 240 -400 0 0 {name=l17 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/nfet_01v8.sym} 480 -400 0 0 {name=MNB L=0.15 W=0.65 nf=1 mult=1 model=nfet_01v8 spiceprefix=X}
C {devices/lab_pin.sym} 500 -430 0 0 {name=l18 sig_type=std_logic lab=Y}
C {devices/lab_pin.sym} 460 -400 0 0 {name=l19 sig_type=std_logic lab=B}
C {devices/lab_pin.sym} 500 -370 0 0 {name=l20 sig_type=std_logic lab=VSS}
C {devices/lab_pin.sym} 500 -400 0 0 {name=l21 sig_type=std_logic lab=VSS}
