v {xschem version=3.4.7 file_version=1.2
}
G {}
K {type=subcircuit
}
V {}
S {}
E {}
C {devices/ipin.sym} -700 -600 0 0 {name=p1 lab=IN}
C {devices/opin.sym} -700 -560 0 0 {name=p2 lab=OUT}
C {devices/iopin.sym} -700 -520 0 0 {name=p3 lab=VDD}
C {devices/iopin.sym} -700 -480 0 0 {name=p4 lab=VDDIO}
C {devices/iopin.sym} -700 -440 0 0 {name=p5 lab=VSS}
T {sky130_ioring_gpio_ls: cross-coupled level shifter, VDD (1.8 V) to VDDIO (3.3 V), non-inverting (GF.8).} -700 -760 0 0 0.3 0.3 {}
T {Thick-oxide pair (nfet/pfet_g5v0d10v5) in the VDDIO half, gates of the NMOS driven at VDD swing; thin inverter makes INB.} -700 -742 0 0 0.3 0.3 {}
T {Sizing is a placeholder, OPEN pending simulation (T1 item 9). Spec proposed, not ratified. Not ESD-rated or qualified.} -700 -724 0 0 0.3 0.3 {}
C {sky130_ioring_inv.sym} -300 -400 0 0 {name=X1}
C {devices/lab_pin.sym} -400 -430 0 0 {name=l6 sig_type=std_logic lab=IN}
C {devices/lab_pin.sym} -200 -430 0 0 {name=l7 sig_type=std_logic lab=INB}
C {devices/lab_pin.sym} -360 -460 0 0 {name=l8 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} -360 -340 0 0 {name=l9 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/nfet_g5v0d10v5.sym} -40 -400 0 0 {name=MNA L=0.5 W=2 nf=1 mult=2 model=nfet_g5v0d10v5 spiceprefix=X}
C {devices/lab_pin.sym} -20 -430 0 0 {name=l10 sig_type=std_logic lab=OUTB}
C {devices/lab_pin.sym} -60 -400 0 0 {name=l11 sig_type=std_logic lab=IN}
C {devices/lab_pin.sym} -20 -370 0 0 {name=l12 sig_type=std_logic lab=VSS}
C {devices/lab_pin.sym} -20 -400 0 0 {name=l13 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/nfet_g5v0d10v5.sym} 220 -400 0 0 {name=MNB L=0.5 W=2 nf=1 mult=2 model=nfet_g5v0d10v5 spiceprefix=X}
C {devices/lab_pin.sym} 240 -430 0 0 {name=l14 sig_type=std_logic lab=OUT}
C {devices/lab_pin.sym} 200 -400 0 0 {name=l15 sig_type=std_logic lab=INB}
C {devices/lab_pin.sym} 240 -370 0 0 {name=l16 sig_type=std_logic lab=VSS}
C {devices/lab_pin.sym} 240 -400 0 0 {name=l17 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/pfet_g5v0d10v5.sym} 480 -400 0 0 {name=MPA L=0.5 W=0.5 nf=1 mult=1 model=pfet_g5v0d10v5 spiceprefix=X}
C {devices/lab_pin.sym} 500 -430 0 0 {name=l18 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} 460 -400 0 0 {name=l19 sig_type=std_logic lab=OUT}
C {devices/lab_pin.sym} 500 -370 0 0 {name=l20 sig_type=std_logic lab=OUTB}
C {devices/lab_pin.sym} 500 -400 0 0 {name=l21 sig_type=std_logic lab=VDDIO}
C {sky130_fd_pr/pfet_g5v0d10v5.sym} 740 -400 0 0 {name=MPB L=0.5 W=0.5 nf=1 mult=1 model=pfet_g5v0d10v5 spiceprefix=X}
C {devices/lab_pin.sym} 760 -430 0 0 {name=l22 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} 720 -400 0 0 {name=l23 sig_type=std_logic lab=OUTB}
C {devices/lab_pin.sym} 760 -370 0 0 {name=l24 sig_type=std_logic lab=OUT}
C {devices/lab_pin.sym} 760 -400 0 0 {name=l25 sig_type=std_logic lab=VDDIO}
