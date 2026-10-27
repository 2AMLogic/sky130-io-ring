v {xschem version=3.4.7 file_version=1.2
}
G {}
K {type=subcircuit
}
V {}
S {}
E {}
C {devices/ipin.sym} -700 -600 0 0 {name=p1 lab=PG}
C {devices/ipin.sym} -700 -560 0 0 {name=p2 lab=NG}
C {devices/iopin.sym} -700 -520 0 0 {name=p3 lab=PAD}
C {devices/iopin.sym} -700 -480 0 0 {name=p4 lab=VDDIO}
C {devices/iopin.sym} -700 -440 0 0 {name=p5 lab=VSS}
T {sky130_ioring_gpio_drv: thick-oxide push-pull output driver (pfet/nfet_g5v0d10v5, decision 0002), gates at VDDIO swing.} -700 -760 0 0 0.3 0.3 {}
T {Drain directly on PAD; no series resistor in the driver path (ASSUMPTION, ESD.3 leaves series R unsized: a resistor here fights GE.1 VOH/VOL).} -700 -742 0 0 0.3 0.3 {}
T {P bulk to VDDIO, N bulk to VSS; closed guard rings are a layout matter (LU.1).} -700 -724 0 0 0.3 0.3 {}
T {Sizing is a placeholder, OPEN pending simulation (T1 item 9). Spec proposed, not ratified. Not ESD-rated or qualified.} -700 -706 0 0 0.3 0.3 {}
C {sky130_fd_pr/pfet_g5v0d10v5.sym} -300 -400 0 0 {name=MP L=0.5 W=5 nf=1 mult=20 model=pfet_g5v0d10v5 spiceprefix=X}
C {devices/lab_pin.sym} -280 -430 0 0 {name=l6 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} -320 -400 0 0 {name=l7 sig_type=std_logic lab=PG}
C {devices/lab_pin.sym} -280 -370 0 0 {name=l8 sig_type=std_logic lab=PAD}
C {devices/lab_pin.sym} -280 -400 0 0 {name=l9 sig_type=std_logic lab=VDDIO}
C {sky130_fd_pr/nfet_g5v0d10v5.sym} -40 -400 0 0 {name=MN L=0.5 W=5 nf=1 mult=10 model=nfet_g5v0d10v5 spiceprefix=X}
C {devices/lab_pin.sym} -20 -430 0 0 {name=l10 sig_type=std_logic lab=PAD}
C {devices/lab_pin.sym} -60 -400 0 0 {name=l11 sig_type=std_logic lab=NG}
C {devices/lab_pin.sym} -20 -370 0 0 {name=l12 sig_type=std_logic lab=VSS}
C {devices/lab_pin.sym} -20 -400 0 0 {name=l13 sig_type=std_logic lab=VSS}
