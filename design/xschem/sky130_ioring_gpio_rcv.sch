v {xschem version=3.4.7 file_version=1.2
}
G {}
K {type=subcircuit
}
V {}
S {}
E {}
C {devices/ipin.sym} -700 -600 0 0 {name=p1 lab=RXG}
C {devices/ipin.sym} -700 -560 0 0 {name=p2 lab=IE}
C {devices/opin.sym} -700 -520 0 0 {name=p3 lab=Y}
C {devices/iopin.sym} -700 -480 0 0 {name=p4 lab=VDD}
C {devices/iopin.sym} -700 -440 0 0 {name=p5 lab=VDDIO}
C {devices/iopin.sym} -700 -400 0 0 {name=p6 lab=VSS}
T {sky130_ioring_gpio_rcv: Schmitt receiver (thick oxide, VDDIO), thick level-down inverter on VDD, thin gating by IE (GF.2, GF.6-GF.8).} -700 -760 0 0 0.3 0.3 {}
T {6T Schmitt: PMOS stack to VDDIO, NMOS stack to VSS, feedback MN3/MP3. Hysteresis target >= 200 mV (GF.7) is UNVERIFIED; feedback sizing is a placeholder.} -700 -742 0 0 0.3 0.3 {}
T {Level-down inverter uses g5v0d10v5 devices supplied from VDD, so the VDDIO-swing input never reaches a thin-oxide gate (SUP.4). With IE low, Y = 0.} -700 -724 0 0 0.3 0.3 {}
T {Sizing is a placeholder, OPEN pending simulation (T1 item 9). Spec proposed, not ratified. Not ESD-rated or qualified.} -700 -706 0 0 0.3 0.3 {}
C {sky130_fd_pr/pfet_g5v0d10v5.sym} -300 -400 0 0 {name=MP1 L=0.5 W=2 nf=1 mult=1 model=pfet_g5v0d10v5 spiceprefix=X}
C {devices/lab_pin.sym} -280 -430 0 0 {name=l7 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} -320 -400 0 0 {name=l8 sig_type=std_logic lab=RXG}
C {devices/lab_pin.sym} -280 -370 0 0 {name=l9 sig_type=std_logic lab=p1}
C {devices/lab_pin.sym} -280 -400 0 0 {name=l10 sig_type=std_logic lab=VDDIO}
C {sky130_fd_pr/pfet_g5v0d10v5.sym} -40 -400 0 0 {name=MP2 L=0.5 W=2 nf=1 mult=1 model=pfet_g5v0d10v5 spiceprefix=X}
C {devices/lab_pin.sym} -20 -430 0 0 {name=l11 sig_type=std_logic lab=p1}
C {devices/lab_pin.sym} -60 -400 0 0 {name=l12 sig_type=std_logic lab=RXG}
C {devices/lab_pin.sym} -20 -370 0 0 {name=l13 sig_type=std_logic lab=SCHN}
C {devices/lab_pin.sym} -20 -400 0 0 {name=l14 sig_type=std_logic lab=VDDIO}
C {sky130_fd_pr/nfet_g5v0d10v5.sym} 220 -400 0 0 {name=MN1 L=0.5 W=1 nf=1 mult=1 model=nfet_g5v0d10v5 spiceprefix=X}
C {devices/lab_pin.sym} 240 -430 0 0 {name=l15 sig_type=std_logic lab=SCHN}
C {devices/lab_pin.sym} 200 -400 0 0 {name=l16 sig_type=std_logic lab=RXG}
C {devices/lab_pin.sym} 240 -370 0 0 {name=l17 sig_type=std_logic lab=n1}
C {devices/lab_pin.sym} 240 -400 0 0 {name=l18 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/nfet_g5v0d10v5.sym} 480 -400 0 0 {name=MN2 L=0.5 W=1 nf=1 mult=1 model=nfet_g5v0d10v5 spiceprefix=X}
C {devices/lab_pin.sym} 500 -430 0 0 {name=l19 sig_type=std_logic lab=n1}
C {devices/lab_pin.sym} 460 -400 0 0 {name=l20 sig_type=std_logic lab=RXG}
C {devices/lab_pin.sym} 500 -370 0 0 {name=l21 sig_type=std_logic lab=VSS}
C {devices/lab_pin.sym} 500 -400 0 0 {name=l22 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/nfet_g5v0d10v5.sym} 740 -400 0 0 {name=MN3 L=0.5 W=0.5 nf=1 mult=1 model=nfet_g5v0d10v5 spiceprefix=X}
C {devices/lab_pin.sym} 760 -430 0 0 {name=l23 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} 720 -400 0 0 {name=l24 sig_type=std_logic lab=SCHN}
C {devices/lab_pin.sym} 760 -370 0 0 {name=l25 sig_type=std_logic lab=n1}
C {devices/lab_pin.sym} 760 -400 0 0 {name=l26 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/pfet_g5v0d10v5.sym} -300 -180 0 0 {name=MP3 L=0.5 W=0.5 nf=1 mult=1 model=pfet_g5v0d10v5 spiceprefix=X}
C {devices/lab_pin.sym} -280 -210 0 0 {name=l27 sig_type=std_logic lab=p1}
C {devices/lab_pin.sym} -320 -180 0 0 {name=l28 sig_type=std_logic lab=SCHN}
C {devices/lab_pin.sym} -280 -150 0 0 {name=l29 sig_type=std_logic lab=VSS}
C {devices/lab_pin.sym} -280 -180 0 0 {name=l30 sig_type=std_logic lab=VDDIO}
C {sky130_fd_pr/pfet_g5v0d10v5.sym} -40 -180 0 0 {name=MP4 L=0.5 W=1 nf=1 mult=1 model=pfet_g5v0d10v5 spiceprefix=X}
C {devices/lab_pin.sym} -20 -210 0 0 {name=l31 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} -60 -180 0 0 {name=l32 sig_type=std_logic lab=SCHN}
C {devices/lab_pin.sym} -20 -150 0 0 {name=l33 sig_type=std_logic lab=RXL}
C {devices/lab_pin.sym} -20 -180 0 0 {name=l34 sig_type=std_logic lab=VDD}
C {sky130_fd_pr/nfet_g5v0d10v5.sym} 220 -180 0 0 {name=MN4 L=0.5 W=0.5 nf=1 mult=1 model=nfet_g5v0d10v5 spiceprefix=X}
C {devices/lab_pin.sym} 240 -210 0 0 {name=l35 sig_type=std_logic lab=RXL}
C {devices/lab_pin.sym} 200 -180 0 0 {name=l36 sig_type=std_logic lab=SCHN}
C {devices/lab_pin.sym} 240 -150 0 0 {name=l37 sig_type=std_logic lab=VSS}
C {devices/lab_pin.sym} 240 -180 0 0 {name=l38 sig_type=std_logic lab=VSS}
C {sky130_ioring_nand2.sym} 480 -180 0 0 {name=X1}
C {devices/lab_pin.sym} 380 -210 0 0 {name=l39 sig_type=std_logic lab=RXL}
C {devices/lab_pin.sym} 380 -190 0 0 {name=l40 sig_type=std_logic lab=IE}
C {devices/lab_pin.sym} 580 -210 0 0 {name=l41 sig_type=std_logic lab=RXN}
C {devices/lab_pin.sym} 420 -240 0 0 {name=l42 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 420 -120 0 0 {name=l43 sig_type=std_logic lab=VSS}
C {sky130_ioring_inv.sym} 740 -180 0 0 {name=X2}
C {devices/lab_pin.sym} 640 -210 0 0 {name=l44 sig_type=std_logic lab=RXN}
C {devices/lab_pin.sym} 840 -210 0 0 {name=l45 sig_type=std_logic lab=Y}
C {devices/lab_pin.sym} 680 -240 0 0 {name=l46 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 680 -120 0 0 {name=l47 sig_type=std_logic lab=VSS}
