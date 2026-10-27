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
C {devices/ipin.sym} -700 -520 0 0 {name=p3 lab=IE}
C {devices/ipin.sym} -700 -480 0 0 {name=p4 lab=PU}
C {devices/ipin.sym} -700 -440 0 0 {name=p5 lab=PD}
C {devices/opin.sym} -700 -400 0 0 {name=p6 lab=Y}
C {devices/iopin.sym} -700 -360 0 0 {name=p7 lab=PAD}
C {devices/iopin.sym} -700 -320 0 0 {name=p8 lab=VDDIO}
C {devices/iopin.sym} -700 -280 0 0 {name=p9 lab=VDD}
C {devices/iopin.sym} -700 -240 0 0 {name=p10 lab=VSS}
T {sky130_ioring_gpio: bidirectional GPIO pad cell, 1.8 V core side, 3.3 V pad side (GF.1-GF.8).} -700 -760 0 0 0.3 0.3 {}
T {Pins: A core data to pad; OE output enable; IE input enable; PU/PD pull select; Y pad data to core; PAD bond pad; rails VDDIO VDD VSS.} -700 -742 0 0 0.3 0.3 {}
T {Built against the PROPOSED spec (decisions 0001-0004 not ratified). Drawn here; sky130_fd_io is a comparison only, nothing copied (decision 0001).} -700 -724 0 0 0.3 0.3 {}
T {ESD network is the 0004 topology, sized by placeholder. No cell here is ESD-rated or qualified; HBM 2 kV is a design target.} -700 -706 0 0 0.3 0.3 {}
T {Sizing is a placeholder, OPEN pending simulation (T1 item 9). Spec proposed, not ratified. Not ESD-rated or qualified.} -700 -688 0 0 0.3 0.3 {}
C {sky130_ioring_gpio_logic.sym} -300 -400 0 0 {name=X1}
C {devices/lab_pin.sym} -400 -470 0 0 {name=l11 sig_type=std_logic lab=A}
C {devices/lab_pin.sym} -400 -450 0 0 {name=l12 sig_type=std_logic lab=OE}
C {devices/lab_pin.sym} -400 -430 0 0 {name=l13 sig_type=std_logic lab=PU}
C {devices/lab_pin.sym} -400 -410 0 0 {name=l14 sig_type=std_logic lab=PD}
C {devices/lab_pin.sym} -200 -470 0 0 {name=l15 sig_type=std_logic lab=PG_C}
C {devices/lab_pin.sym} -200 -450 0 0 {name=l16 sig_type=std_logic lab=NG_C}
C {devices/lab_pin.sym} -200 -430 0 0 {name=l17 sig_type=std_logic lab=PUN_C}
C {devices/lab_pin.sym} -200 -410 0 0 {name=l18 sig_type=std_logic lab=PD_C}
C {devices/lab_pin.sym} -360 -500 0 0 {name=l19 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} -360 -300 0 0 {name=l20 sig_type=std_logic lab=VSS}
C {sky130_ioring_gpio_ls.sym} 60 -400 0 0 {name=XL1}
C {devices/lab_pin.sym} -40 -430 0 0 {name=l21 sig_type=std_logic lab=PG_C}
C {devices/lab_pin.sym} 160 -430 0 0 {name=l22 sig_type=std_logic lab=PG}
C {devices/lab_pin.sym} 40 -460 0 0 {name=l23 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} 0 -460 0 0 {name=l24 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 0 -340 0 0 {name=l25 sig_type=std_logic lab=VSS}
C {sky130_ioring_gpio_ls.sym} 420 -400 0 0 {name=XL2}
C {devices/lab_pin.sym} 320 -430 0 0 {name=l26 sig_type=std_logic lab=NG_C}
C {devices/lab_pin.sym} 520 -430 0 0 {name=l27 sig_type=std_logic lab=NG}
C {devices/lab_pin.sym} 400 -460 0 0 {name=l28 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} 360 -460 0 0 {name=l29 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 360 -340 0 0 {name=l30 sig_type=std_logic lab=VSS}
C {sky130_ioring_gpio_ls.sym} 780 -400 0 0 {name=XL3}
C {devices/lab_pin.sym} 680 -430 0 0 {name=l31 sig_type=std_logic lab=PUN_C}
C {devices/lab_pin.sym} 880 -430 0 0 {name=l32 sig_type=std_logic lab=PUN}
C {devices/lab_pin.sym} 760 -460 0 0 {name=l33 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} 720 -460 0 0 {name=l34 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 720 -340 0 0 {name=l35 sig_type=std_logic lab=VSS}
C {sky130_ioring_gpio_ls.sym} 1140 -400 0 0 {name=XL4}
C {devices/lab_pin.sym} 1040 -430 0 0 {name=l36 sig_type=std_logic lab=PD_C}
C {devices/lab_pin.sym} 1240 -430 0 0 {name=l37 sig_type=std_logic lab=PDP}
C {devices/lab_pin.sym} 1120 -460 0 0 {name=l38 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} 1080 -460 0 0 {name=l39 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 1080 -340 0 0 {name=l40 sig_type=std_logic lab=VSS}
C {sky130_ioring_gpio_drv.sym} -300 -80 0 0 {name=X2}
C {devices/lab_pin.sym} -400 -110 0 0 {name=l41 sig_type=std_logic lab=PG}
C {devices/lab_pin.sym} -400 -90 0 0 {name=l42 sig_type=std_logic lab=NG}
C {devices/lab_pin.sym} -200 -110 0 0 {name=l43 sig_type=std_logic lab=PAD}
C {devices/lab_pin.sym} -360 -140 0 0 {name=l44 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} -360 -20 0 0 {name=l45 sig_type=std_logic lab=VSS}
C {sky130_ioring_gpio_pulls.sym} 60 -80 0 0 {name=X3}
C {devices/lab_pin.sym} -40 -110 0 0 {name=l46 sig_type=std_logic lab=PUN}
C {devices/lab_pin.sym} -40 -90 0 0 {name=l47 sig_type=std_logic lab=PDP}
C {devices/lab_pin.sym} 160 -110 0 0 {name=l48 sig_type=std_logic lab=PAD}
C {devices/lab_pin.sym} 0 -140 0 0 {name=l49 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} 0 -20 0 0 {name=l50 sig_type=std_logic lab=VSS}
C {sky130_ioring_gpio_esd.sym} 420 -80 0 0 {name=X4}
C {devices/lab_pin.sym} 520 -90 0 0 {name=l51 sig_type=std_logic lab=PAD}
C {devices/lab_pin.sym} 520 -110 0 0 {name=l52 sig_type=std_logic lab=RXG}
C {devices/lab_pin.sym} 360 -140 0 0 {name=l53 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} 360 -20 0 0 {name=l54 sig_type=std_logic lab=VSS}
C {sky130_ioring_gpio_rcv.sym} 780 -80 0 0 {name=X5}
C {devices/lab_pin.sym} 680 -110 0 0 {name=l55 sig_type=std_logic lab=RXG}
C {devices/lab_pin.sym} 680 -90 0 0 {name=l56 sig_type=std_logic lab=IE}
C {devices/lab_pin.sym} 880 -110 0 0 {name=l57 sig_type=std_logic lab=Y}
C {devices/lab_pin.sym} 760 -140 0 0 {name=l58 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} 720 -140 0 0 {name=l59 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 720 -20 0 0 {name=l60 sig_type=std_logic lab=VSS}
