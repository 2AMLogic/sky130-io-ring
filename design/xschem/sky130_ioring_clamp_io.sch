v {xschem version=3.4.7 file_version=1.2
}
G {}
K {type=subcircuit
}
V {}
S {}
E {}
C {devices/iopin.sym} -700 -600 0 0 {name=p1 lab=VP}
C {devices/iopin.sym} -700 -560 0 0 {name=p2 lab=VSS}
T {sky130_ioring_clamp_io: RC-triggered VDDIO-VSS supply clamp, large thick-oxide NMOS (nfet_g5v0d10v5), ESD.4.} -700 -760 0 0 0.3 0.3 {}
T {RC trigger: R from VP to T (2 x xhigh-poly), C from T to VSS; ~1 us (ESD.4/5). T stays low in a fast ESD rise, so the odd inverter chain drives GATE high and turns the NMOS on.} -700 -742 0 0 0.3 0.3 {}
T {On a slow power-up T follows VP, GATE stays low, clamp off. ~1 us is an UNJUSTIFIED starting value (gate G6); clamp device choice OPEN (gate G5). No snapback is modelled.} -700 -724 0 0 0.3 0.3 {}
T {Sizing is a placeholder, OPEN pending simulation (T1 item 9). Spec proposed, not ratified. Not ESD-rated or qualified.} -700 -706 0 0 0.3 0.3 {}
C {sky130_fd_pr/res_xhigh_po_0p69.sym} -300 -400 0 0 {name=R1 model=res_xhigh_po_0p69 W=0.69 L=43 mult=1 spiceprefix=X}
C {devices/lab_pin.sym} -300 -430 0 0 {name=l3 sig_type=std_logic lab=VP}
C {devices/lab_pin.sym} -300 -370 0 0 {name=l4 sig_type=std_logic lab=T1}
C {devices/lab_pin.sym} -320 -400 0 0 {name=l5 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/res_xhigh_po_0p69.sym} -40 -400 0 0 {name=R2 model=res_xhigh_po_0p69 W=0.69 L=43 mult=1 spiceprefix=X}
C {devices/lab_pin.sym} -40 -430 0 0 {name=l6 sig_type=std_logic lab=T1}
C {devices/lab_pin.sym} -40 -370 0 0 {name=l7 sig_type=std_logic lab=T}
C {devices/lab_pin.sym} -60 -400 0 0 {name=l8 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/cap_mim_m3_1.sym} 220 -400 0 0 {name=C1 model=cap_mim_m3_1 W=30 L=33 MF=2 spiceprefix=X}
C {devices/lab_pin.sym} 220 -430 0 0 {name=l9 sig_type=std_logic lab=T}
C {devices/lab_pin.sym} 220 -370 0 0 {name=l10 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/pfet_g5v0d10v5.sym} 480 -400 0 0 {name=MP1 L=0.5 W=2 nf=1 mult=1 model=pfet_g5v0d10v5 spiceprefix=X}
C {devices/lab_pin.sym} 500 -430 0 0 {name=l11 sig_type=std_logic lab=VP}
C {devices/lab_pin.sym} 460 -400 0 0 {name=l12 sig_type=std_logic lab=T}
C {devices/lab_pin.sym} 500 -370 0 0 {name=l13 sig_type=std_logic lab=G1}
C {devices/lab_pin.sym} 500 -400 0 0 {name=l14 sig_type=std_logic lab=VP}
C {sky130_fd_pr/nfet_g5v0d10v5.sym} 740 -400 0 0 {name=MN1 L=0.5 W=1 nf=1 mult=1 model=nfet_g5v0d10v5 spiceprefix=X}
C {devices/lab_pin.sym} 760 -430 0 0 {name=l15 sig_type=std_logic lab=G1}
C {devices/lab_pin.sym} 720 -400 0 0 {name=l16 sig_type=std_logic lab=T}
C {devices/lab_pin.sym} 760 -370 0 0 {name=l17 sig_type=std_logic lab=VSS}
C {devices/lab_pin.sym} 760 -400 0 0 {name=l18 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/pfet_g5v0d10v5.sym} -300 -200 0 0 {name=MP2 L=0.5 W=5 nf=1 mult=4 model=pfet_g5v0d10v5 spiceprefix=X}
C {devices/lab_pin.sym} -280 -230 0 0 {name=l19 sig_type=std_logic lab=VP}
C {devices/lab_pin.sym} -320 -200 0 0 {name=l20 sig_type=std_logic lab=G1}
C {devices/lab_pin.sym} -280 -170 0 0 {name=l21 sig_type=std_logic lab=G2}
C {devices/lab_pin.sym} -280 -200 0 0 {name=l22 sig_type=std_logic lab=VP}
C {sky130_fd_pr/nfet_g5v0d10v5.sym} -40 -200 0 0 {name=MN2 L=0.5 W=2 nf=1 mult=4 model=nfet_g5v0d10v5 spiceprefix=X}
C {devices/lab_pin.sym} -20 -230 0 0 {name=l23 sig_type=std_logic lab=G2}
C {devices/lab_pin.sym} -60 -200 0 0 {name=l24 sig_type=std_logic lab=G1}
C {devices/lab_pin.sym} -20 -170 0 0 {name=l25 sig_type=std_logic lab=VSS}
C {devices/lab_pin.sym} -20 -200 0 0 {name=l26 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/pfet_g5v0d10v5.sym} 220 -200 0 0 {name=MP3 L=0.5 W=5 nf=1 mult=20 model=pfet_g5v0d10v5 spiceprefix=X}
C {devices/lab_pin.sym} 240 -230 0 0 {name=l27 sig_type=std_logic lab=VP}
C {devices/lab_pin.sym} 200 -200 0 0 {name=l28 sig_type=std_logic lab=G2}
C {devices/lab_pin.sym} 240 -170 0 0 {name=l29 sig_type=std_logic lab=GATE}
C {devices/lab_pin.sym} 240 -200 0 0 {name=l30 sig_type=std_logic lab=VP}
C {sky130_fd_pr/nfet_g5v0d10v5.sym} 480 -200 0 0 {name=MN3 L=0.5 W=5 nf=1 mult=10 model=nfet_g5v0d10v5 spiceprefix=X}
C {devices/lab_pin.sym} 500 -230 0 0 {name=l31 sig_type=std_logic lab=GATE}
C {devices/lab_pin.sym} 460 -200 0 0 {name=l32 sig_type=std_logic lab=G2}
C {devices/lab_pin.sym} 500 -170 0 0 {name=l33 sig_type=std_logic lab=VSS}
C {devices/lab_pin.sym} 500 -200 0 0 {name=l34 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/nfet_g5v0d10v5.sym} 740 -200 0 0 {name=MCL L=0.5 W=5 nf=1 mult=400 model=nfet_g5v0d10v5 spiceprefix=X}
C {devices/lab_pin.sym} 760 -230 0 0 {name=l35 sig_type=std_logic lab=VP}
C {devices/lab_pin.sym} 720 -200 0 0 {name=l36 sig_type=std_logic lab=GATE}
C {devices/lab_pin.sym} 760 -170 0 0 {name=l37 sig_type=std_logic lab=VSS}
C {devices/lab_pin.sym} 760 -200 0 0 {name=l38 sig_type=std_logic lab=VSS}
