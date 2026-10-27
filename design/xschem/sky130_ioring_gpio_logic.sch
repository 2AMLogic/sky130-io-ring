v {xschem version=3.4.7 file_version=1.2
}
G {}
K {type=subcircuit
}
V {}
S {}
E {}
C {devices/ipin.sym} -700 -600 0 0 {name=p1 lab=A}
C {devices/ipin.sym} -700 -560 0 0 {name=p2 lab=OE}
C {devices/ipin.sym} -700 -520 0 0 {name=p3 lab=PU}
C {devices/ipin.sym} -700 -480 0 0 {name=p4 lab=PD}
C {devices/opin.sym} -700 -440 0 0 {name=p5 lab=PG_C}
C {devices/opin.sym} -700 -400 0 0 {name=p6 lab=NG_C}
C {devices/opin.sym} -700 -360 0 0 {name=p7 lab=PUN_C}
C {devices/opin.sym} -700 -320 0 0 {name=p8 lab=PD_C}
C {devices/iopin.sym} -700 -280 0 0 {name=p9 lab=VDD}
C {devices/iopin.sym} -700 -240 0 0 {name=p10 lab=VSS}
T {sky130_ioring_gpio_logic: core-side (VDD domain, thin oxide) control for driver and pulls.} -700 -760 0 0 0.3 0.3 {}
T {PG_C = nand(A,OE) (low turns the PMOS driver on); NG_C = nor(A,~OE) (high turns the NMOS driver on); both off while OE low (GF.1).} -700 -742 0 0 0.3 0.3 {}
T {PUN_C = nand3(PU,~PD,~OE) low = pull-up on; PD_C = ~nand3(PD,~PU,~OE) high = pull-down on. Pulls act only while OE is inactive and are mutually exclusive (GF.3).} -700 -724 0 0 0.3 0.3 {}
T {Sizing is a placeholder, OPEN pending simulation (T1 item 9). Spec proposed, not ratified. Not ESD-rated or qualified.} -700 -706 0 0 0.3 0.3 {}
C {sky130_ioring_inv.sym} -300 -400 0 0 {name=X1}
C {devices/lab_pin.sym} -400 -430 0 0 {name=l11 sig_type=std_logic lab=OE}
C {devices/lab_pin.sym} -200 -430 0 0 {name=l12 sig_type=std_logic lab=OEB}
C {devices/lab_pin.sym} -360 -460 0 0 {name=l13 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} -360 -340 0 0 {name=l14 sig_type=std_logic lab=VSS}
C {sky130_ioring_inv.sym} -40 -400 0 0 {name=X2}
C {devices/lab_pin.sym} -140 -430 0 0 {name=l15 sig_type=std_logic lab=PU}
C {devices/lab_pin.sym} 60 -430 0 0 {name=l16 sig_type=std_logic lab=PUB}
C {devices/lab_pin.sym} -100 -460 0 0 {name=l17 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} -100 -340 0 0 {name=l18 sig_type=std_logic lab=VSS}
C {sky130_ioring_inv.sym} 220 -400 0 0 {name=X3}
C {devices/lab_pin.sym} 120 -430 0 0 {name=l19 sig_type=std_logic lab=PD}
C {devices/lab_pin.sym} 320 -430 0 0 {name=l20 sig_type=std_logic lab=PDB}
C {devices/lab_pin.sym} 160 -460 0 0 {name=l21 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 160 -340 0 0 {name=l22 sig_type=std_logic lab=VSS}
C {sky130_ioring_nand2.sym} 480 -400 0 0 {name=X4}
C {devices/lab_pin.sym} 380 -430 0 0 {name=l23 sig_type=std_logic lab=A}
C {devices/lab_pin.sym} 380 -410 0 0 {name=l24 sig_type=std_logic lab=OE}
C {devices/lab_pin.sym} 580 -430 0 0 {name=l25 sig_type=std_logic lab=PG_C}
C {devices/lab_pin.sym} 420 -460 0 0 {name=l26 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 420 -340 0 0 {name=l27 sig_type=std_logic lab=VSS}
C {sky130_ioring_nor2.sym} 740 -400 0 0 {name=X5}
C {devices/lab_pin.sym} 640 -430 0 0 {name=l28 sig_type=std_logic lab=A}
C {devices/lab_pin.sym} 640 -410 0 0 {name=l29 sig_type=std_logic lab=OEB}
C {devices/lab_pin.sym} 840 -430 0 0 {name=l30 sig_type=std_logic lab=NG_C}
C {devices/lab_pin.sym} 680 -460 0 0 {name=l31 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 680 -340 0 0 {name=l32 sig_type=std_logic lab=VSS}
C {sky130_ioring_nand3.sym} -300 -180 0 0 {name=X6}
C {devices/lab_pin.sym} -400 -230 0 0 {name=l33 sig_type=std_logic lab=PU}
C {devices/lab_pin.sym} -400 -210 0 0 {name=l34 sig_type=std_logic lab=PDB}
C {devices/lab_pin.sym} -400 -190 0 0 {name=l35 sig_type=std_logic lab=OEB}
C {devices/lab_pin.sym} -200 -230 0 0 {name=l36 sig_type=std_logic lab=PUN_C}
C {devices/lab_pin.sym} -360 -260 0 0 {name=l37 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} -360 -100 0 0 {name=l38 sig_type=std_logic lab=VSS}
C {sky130_ioring_nand3.sym} -40 -180 0 0 {name=X7}
C {devices/lab_pin.sym} -140 -230 0 0 {name=l39 sig_type=std_logic lab=PD}
C {devices/lab_pin.sym} -140 -210 0 0 {name=l40 sig_type=std_logic lab=PUB}
C {devices/lab_pin.sym} -140 -190 0 0 {name=l41 sig_type=std_logic lab=OEB}
C {devices/lab_pin.sym} 60 -230 0 0 {name=l42 sig_type=std_logic lab=PDN}
C {devices/lab_pin.sym} -100 -260 0 0 {name=l43 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} -100 -100 0 0 {name=l44 sig_type=std_logic lab=VSS}
C {sky130_ioring_inv.sym} 220 -180 0 0 {name=X8}
C {devices/lab_pin.sym} 120 -210 0 0 {name=l45 sig_type=std_logic lab=PDN}
C {devices/lab_pin.sym} 320 -210 0 0 {name=l46 sig_type=std_logic lab=PD_C}
C {devices/lab_pin.sym} 160 -240 0 0 {name=l47 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 160 -120 0 0 {name=l48 sig_type=std_logic lab=VSS}
