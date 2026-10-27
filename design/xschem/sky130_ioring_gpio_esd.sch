v {xschem version=3.4.7 file_version=1.2
}
G {}
K {type=subcircuit
}
V {}
S {}
E {}
C {devices/iopin.sym} -700 -600 0 0 {name=p1 lab=PAD}
C {devices/opin.sym} -700 -560 0 0 {name=p2 lab=RXG}
C {devices/iopin.sym} -700 -520 0 0 {name=p3 lab=VDDIO}
C {devices/iopin.sym} -700 -480 0 0 {name=p4 lab=VSS}
T {sky130_ioring_gpio_esd: GPIO ESD network per decision 0004 / spec ESD.3.} -700 -760 0 0 0.3 0.3 {}
T {Primary: diode PAD to VDDIO (p+/nwell) and diode VSS to PAD (n+/pwell). Secondary: series resistor PAD to RXG, local diode clamp at RXG.} -700 -742 0 0 0.3 0.3 {}
T {Series R and diode areas are UNSIZED in the spec (ESD.3, gate G1): values here are placeholders. Foundry ~150 ohm series R is a comparison only.} -700 -724 0 0 0.3 0.3 {}
T {Simulated turn-on and current sharing are design evidence only; nothing here is ESD-rated or qualified. Diode |V| validity 5.0 V (ESD.7).} -700 -706 0 0 0.3 0.3 {}
C {sky130_fd_pr/diode.sym} -300 -400 0 0 {name=DP model=diode_pd2nw_05v5 area=2e14 perim=6e7 spiceprefix=X}
C {devices/lab_pin.sym} -300 -370 0 0 {name=l5 sig_type=std_logic lab=PAD}
C {devices/lab_pin.sym} -300 -430 0 0 {name=l6 sig_type=std_logic lab=VDDIO}
C {sky130_fd_pr/diode.sym} -40 -400 0 0 {name=DN model=diode_pw2nd_05v5 area=2e14 perim=6e7 spiceprefix=X}
C {devices/lab_pin.sym} -40 -370 0 0 {name=l7 sig_type=std_logic lab=VSS}
C {devices/lab_pin.sym} -40 -430 0 0 {name=l8 sig_type=std_logic lab=PAD}
C {sky130_fd_pr/res_high_po_1p41.sym} 220 -400 0 0 {name=RS model=res_high_po_1p41 W=1.41 L=1.0 mult=1 spiceprefix=X}
C {devices/lab_pin.sym} 220 -430 0 0 {name=l9 sig_type=std_logic lab=PAD}
C {devices/lab_pin.sym} 220 -370 0 0 {name=l10 sig_type=std_logic lab=RXG}
C {devices/lab_pin.sym} 200 -400 0 0 {name=l11 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/diode.sym} 480 -400 0 0 {name=DLP model=diode_pd2nw_05v5 area=1e13 perim=1.4e7 spiceprefix=X}
C {devices/lab_pin.sym} 480 -370 0 0 {name=l12 sig_type=std_logic lab=RXG}
C {devices/lab_pin.sym} 480 -430 0 0 {name=l13 sig_type=std_logic lab=VDDIO}
C {sky130_fd_pr/diode.sym} 740 -400 0 0 {name=DLN model=diode_pw2nd_05v5 area=1e13 perim=1.4e7 spiceprefix=X}
C {devices/lab_pin.sym} 740 -370 0 0 {name=l14 sig_type=std_logic lab=VSS}
C {devices/lab_pin.sym} 740 -430 0 0 {name=l15 sig_type=std_logic lab=RXG}
