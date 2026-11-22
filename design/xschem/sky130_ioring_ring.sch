v {xschem version=3.4.7 file_version=1.2
}
G {}
K {type=subcircuit
}
V {}
S {}
E {}
C {devices/ipin.sym} -700 -600 0 0 {name=p1 lab=A0}
C {devices/ipin.sym} -700 -560 0 0 {name=p2 lab=OE0}
C {devices/ipin.sym} -700 -520 0 0 {name=p3 lab=IE0}
C {devices/ipin.sym} -700 -480 0 0 {name=p4 lab=PU0}
C {devices/ipin.sym} -700 -440 0 0 {name=p5 lab=PD0}
C {devices/ipin.sym} -700 -400 0 0 {name=p6 lab=A1}
C {devices/ipin.sym} -700 -360 0 0 {name=p7 lab=OE1}
C {devices/ipin.sym} -700 -320 0 0 {name=p8 lab=IE1}
C {devices/ipin.sym} -700 -280 0 0 {name=p9 lab=PU1}
C {devices/ipin.sym} -700 -240 0 0 {name=p10 lab=PD1}
C {devices/ipin.sym} -700 -200 0 0 {name=p11 lab=A2}
C {devices/ipin.sym} -700 -160 0 0 {name=p12 lab=OE2}
C {devices/ipin.sym} -700 -120 0 0 {name=p13 lab=IE2}
C {devices/ipin.sym} -700 -80 0 0 {name=p14 lab=PU2}
C {devices/ipin.sym} -700 -40 0 0 {name=p15 lab=PD2}
C {devices/ipin.sym} -700 0 0 0 {name=p16 lab=A3}
C {devices/ipin.sym} -700 40 0 0 {name=p17 lab=OE3}
C {devices/ipin.sym} -700 80 0 0 {name=p18 lab=IE3}
C {devices/ipin.sym} -700 120 0 0 {name=p19 lab=PU3}
C {devices/ipin.sym} -700 160 0 0 {name=p20 lab=PD3}
C {devices/ipin.sym} -700 200 0 0 {name=p21 lab=A4}
C {devices/ipin.sym} -700 240 0 0 {name=p22 lab=OE4}
C {devices/ipin.sym} -700 280 0 0 {name=p23 lab=IE4}
C {devices/ipin.sym} -700 320 0 0 {name=p24 lab=PU4}
C {devices/ipin.sym} -700 360 0 0 {name=p25 lab=PD4}
C {devices/ipin.sym} -700 400 0 0 {name=p26 lab=A5}
C {devices/ipin.sym} -700 440 0 0 {name=p27 lab=OE5}
C {devices/ipin.sym} -700 480 0 0 {name=p28 lab=IE5}
C {devices/ipin.sym} -700 520 0 0 {name=p29 lab=PU5}
C {devices/ipin.sym} -700 560 0 0 {name=p30 lab=PD5}
C {devices/ipin.sym} -700 600 0 0 {name=p31 lab=A6}
C {devices/ipin.sym} -700 640 0 0 {name=p32 lab=OE6}
C {devices/ipin.sym} -700 680 0 0 {name=p33 lab=IE6}
C {devices/ipin.sym} -700 720 0 0 {name=p34 lab=PU6}
C {devices/ipin.sym} -700 760 0 0 {name=p35 lab=PD6}
C {devices/ipin.sym} -700 800 0 0 {name=p36 lab=A7}
C {devices/ipin.sym} -700 840 0 0 {name=p37 lab=OE7}
C {devices/ipin.sym} -700 880 0 0 {name=p38 lab=IE7}
C {devices/ipin.sym} -700 920 0 0 {name=p39 lab=PU7}
C {devices/ipin.sym} -700 960 0 0 {name=p40 lab=PD7}
C {devices/opin.sym} -700 1000 0 0 {name=p41 lab=Y0}
C {devices/opin.sym} -700 1040 0 0 {name=p42 lab=Y1}
C {devices/opin.sym} -700 1080 0 0 {name=p43 lab=Y2}
C {devices/opin.sym} -700 1120 0 0 {name=p44 lab=Y3}
C {devices/opin.sym} -700 1160 0 0 {name=p45 lab=Y4}
C {devices/opin.sym} -700 1200 0 0 {name=p46 lab=Y5}
C {devices/opin.sym} -700 1240 0 0 {name=p47 lab=Y6}
C {devices/opin.sym} -700 1280 0 0 {name=p48 lab=Y7}
C {devices/iopin.sym} -700 1320 0 0 {name=p49 lab=PAD0}
C {devices/iopin.sym} -700 1360 0 0 {name=p50 lab=PAD1}
C {devices/iopin.sym} -700 1400 0 0 {name=p51 lab=PAD2}
C {devices/iopin.sym} -700 1440 0 0 {name=p52 lab=PAD3}
C {devices/iopin.sym} -700 1480 0 0 {name=p53 lab=PAD4}
C {devices/iopin.sym} -700 1520 0 0 {name=p54 lab=PAD5}
C {devices/iopin.sym} -700 1560 0 0 {name=p55 lab=PAD6}
C {devices/iopin.sym} -700 1600 0 0 {name=p56 lab=PAD7}
C {devices/iopin.sym} -700 1640 0 0 {name=p57 lab=VDDIO}
C {devices/iopin.sym} -700 1680 0 0 {name=p58 lab=VDD}
C {devices/iopin.sym} -700 1720 0 0 {name=p59 lab=VSS}
T {sky130_ioring_ring: closed ring around an EMPTY core: 4 corners and 4 identical sides.} -700 -760 0 0 0.3 0.3 {}
T {Side (south-edge order, as layout/gen_ring.py SIDE_PADS and filler run): gpio vddio vss vdd gpio fill_20 fill_10 fill_5 fill_1 fill_1.} -700 -742 0 0 0.3 0.3 {}
T {Core-side pins A/OE/IE/PU/PD/Y are ring ports (the core is out of scope). Rails VDDIO/VDD/VSS are shared by name across every cell (seam LVS keys on them).} -700 -724 0 0 0.3 0.3 {}
T {Sizing is a placeholder, OPEN pending simulation (T1 item 9). Spec proposed, not ratified. Not ESD-rated or qualified.} -700 -706 0 0 0.3 0.3 {}
C {sky130_ioring_corner.sym} -300 -400 0 0 {name=XC0}
C {devices/lab_pin.sym} -360 -460 0 0 {name=l60 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} -320 -460 0 0 {name=l61 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} -360 -340 0 0 {name=l62 sig_type=std_logic lab=VSS}
C {sky130_ioring_gpio.sym} 0 -400 0 0 {name=XS0_0_gpio}
C {devices/lab_pin.sym} -100 -490 0 0 {name=l63 sig_type=std_logic lab=A0}
C {devices/lab_pin.sym} -100 -470 0 0 {name=l64 sig_type=std_logic lab=OE0}
C {devices/lab_pin.sym} -100 -450 0 0 {name=l65 sig_type=std_logic lab=IE0}
C {devices/lab_pin.sym} -100 -430 0 0 {name=l66 sig_type=std_logic lab=PU0}
C {devices/lab_pin.sym} -100 -410 0 0 {name=l67 sig_type=std_logic lab=PD0}
C {devices/lab_pin.sym} 100 -490 0 0 {name=l68 sig_type=std_logic lab=Y0}
C {devices/lab_pin.sym} 100 -470 0 0 {name=l69 sig_type=std_logic lab=PAD0}
C {devices/lab_pin.sym} -60 -520 0 0 {name=l70 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} -20 -520 0 0 {name=l71 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} -60 -280 0 0 {name=l72 sig_type=std_logic lab=VSS}
C {sky130_ioring_vddio.sym} 300 -400 0 0 {name=XS0_1_vddio}
C {devices/lab_pin.sym} 240 -460 0 0 {name=l73 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} 280 -460 0 0 {name=l74 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 240 -340 0 0 {name=l75 sig_type=std_logic lab=VSS}
C {sky130_ioring_vss.sym} 600 -400 0 0 {name=XS0_2_vss}
C {devices/lab_pin.sym} 540 -460 0 0 {name=l76 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} 580 -460 0 0 {name=l77 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 540 -340 0 0 {name=l78 sig_type=std_logic lab=VSS}
C {sky130_ioring_vdd.sym} 900 -400 0 0 {name=XS0_3_vdd}
C {devices/lab_pin.sym} 840 -460 0 0 {name=l79 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} 880 -460 0 0 {name=l80 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 840 -340 0 0 {name=l81 sig_type=std_logic lab=VSS}
C {sky130_ioring_gpio.sym} -300 -100 0 0 {name=XS0_4_gpio}
C {devices/lab_pin.sym} -400 -190 0 0 {name=l82 sig_type=std_logic lab=A1}
C {devices/lab_pin.sym} -400 -170 0 0 {name=l83 sig_type=std_logic lab=OE1}
C {devices/lab_pin.sym} -400 -150 0 0 {name=l84 sig_type=std_logic lab=IE1}
C {devices/lab_pin.sym} -400 -130 0 0 {name=l85 sig_type=std_logic lab=PU1}
C {devices/lab_pin.sym} -400 -110 0 0 {name=l86 sig_type=std_logic lab=PD1}
C {devices/lab_pin.sym} -200 -190 0 0 {name=l87 sig_type=std_logic lab=Y1}
C {devices/lab_pin.sym} -200 -170 0 0 {name=l88 sig_type=std_logic lab=PAD1}
C {devices/lab_pin.sym} -360 -220 0 0 {name=l89 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} -320 -220 0 0 {name=l90 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} -360 20 0 0 {name=l91 sig_type=std_logic lab=VSS}
C {sky130_ioring_fill_20.sym} 0 -100 0 0 {name=XS0_5_fill_20}
C {devices/lab_pin.sym} -60 -160 0 0 {name=l92 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} -20 -160 0 0 {name=l93 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} -60 -40 0 0 {name=l94 sig_type=std_logic lab=VSS}
C {sky130_ioring_fill_10.sym} 300 -100 0 0 {name=XS0_6_fill_10}
C {devices/lab_pin.sym} 240 -160 0 0 {name=l95 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} 280 -160 0 0 {name=l96 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 240 -40 0 0 {name=l97 sig_type=std_logic lab=VSS}
C {sky130_ioring_fill_5.sym} 600 -100 0 0 {name=XS0_7_fill_5}
C {devices/lab_pin.sym} 540 -160 0 0 {name=l98 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} 580 -160 0 0 {name=l99 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 540 -40 0 0 {name=l100 sig_type=std_logic lab=VSS}
C {sky130_ioring_fill_1.sym} 900 -100 0 0 {name=XS0_8_fill_1}
C {devices/lab_pin.sym} 840 -160 0 0 {name=l101 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} 880 -160 0 0 {name=l102 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 840 -40 0 0 {name=l103 sig_type=std_logic lab=VSS}
C {sky130_ioring_fill_1.sym} -300 200 0 0 {name=XS0_9_fill_1}
C {devices/lab_pin.sym} -360 140 0 0 {name=l104 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} -320 140 0 0 {name=l105 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} -360 260 0 0 {name=l106 sig_type=std_logic lab=VSS}
C {sky130_ioring_corner.sym} 0 200 0 0 {name=XC1}
C {devices/lab_pin.sym} -60 140 0 0 {name=l107 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} -20 140 0 0 {name=l108 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} -60 260 0 0 {name=l109 sig_type=std_logic lab=VSS}
C {sky130_ioring_gpio.sym} 300 200 0 0 {name=XS1_0_gpio}
C {devices/lab_pin.sym} 200 110 0 0 {name=l110 sig_type=std_logic lab=A2}
C {devices/lab_pin.sym} 200 130 0 0 {name=l111 sig_type=std_logic lab=OE2}
C {devices/lab_pin.sym} 200 150 0 0 {name=l112 sig_type=std_logic lab=IE2}
C {devices/lab_pin.sym} 200 170 0 0 {name=l113 sig_type=std_logic lab=PU2}
C {devices/lab_pin.sym} 200 190 0 0 {name=l114 sig_type=std_logic lab=PD2}
C {devices/lab_pin.sym} 400 110 0 0 {name=l115 sig_type=std_logic lab=Y2}
C {devices/lab_pin.sym} 400 130 0 0 {name=l116 sig_type=std_logic lab=PAD2}
C {devices/lab_pin.sym} 240 80 0 0 {name=l117 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} 280 80 0 0 {name=l118 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 240 320 0 0 {name=l119 sig_type=std_logic lab=VSS}
C {sky130_ioring_vddio.sym} 600 200 0 0 {name=XS1_1_vddio}
C {devices/lab_pin.sym} 540 140 0 0 {name=l120 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} 580 140 0 0 {name=l121 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 540 260 0 0 {name=l122 sig_type=std_logic lab=VSS}
C {sky130_ioring_vss.sym} 900 200 0 0 {name=XS1_2_vss}
C {devices/lab_pin.sym} 840 140 0 0 {name=l123 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} 880 140 0 0 {name=l124 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 840 260 0 0 {name=l125 sig_type=std_logic lab=VSS}
C {sky130_ioring_vdd.sym} -300 500 0 0 {name=XS1_3_vdd}
C {devices/lab_pin.sym} -360 440 0 0 {name=l126 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} -320 440 0 0 {name=l127 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} -360 560 0 0 {name=l128 sig_type=std_logic lab=VSS}
C {sky130_ioring_gpio.sym} 0 500 0 0 {name=XS1_4_gpio}
C {devices/lab_pin.sym} -100 410 0 0 {name=l129 sig_type=std_logic lab=A3}
C {devices/lab_pin.sym} -100 430 0 0 {name=l130 sig_type=std_logic lab=OE3}
C {devices/lab_pin.sym} -100 450 0 0 {name=l131 sig_type=std_logic lab=IE3}
C {devices/lab_pin.sym} -100 470 0 0 {name=l132 sig_type=std_logic lab=PU3}
C {devices/lab_pin.sym} -100 490 0 0 {name=l133 sig_type=std_logic lab=PD3}
C {devices/lab_pin.sym} 100 410 0 0 {name=l134 sig_type=std_logic lab=Y3}
C {devices/lab_pin.sym} 100 430 0 0 {name=l135 sig_type=std_logic lab=PAD3}
C {devices/lab_pin.sym} -60 380 0 0 {name=l136 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} -20 380 0 0 {name=l137 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} -60 620 0 0 {name=l138 sig_type=std_logic lab=VSS}
C {sky130_ioring_fill_20.sym} 300 500 0 0 {name=XS1_5_fill_20}
C {devices/lab_pin.sym} 240 440 0 0 {name=l139 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} 280 440 0 0 {name=l140 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 240 560 0 0 {name=l141 sig_type=std_logic lab=VSS}
C {sky130_ioring_fill_10.sym} 600 500 0 0 {name=XS1_6_fill_10}
C {devices/lab_pin.sym} 540 440 0 0 {name=l142 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} 580 440 0 0 {name=l143 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 540 560 0 0 {name=l144 sig_type=std_logic lab=VSS}
C {sky130_ioring_fill_5.sym} 900 500 0 0 {name=XS1_7_fill_5}
C {devices/lab_pin.sym} 840 440 0 0 {name=l145 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} 880 440 0 0 {name=l146 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 840 560 0 0 {name=l147 sig_type=std_logic lab=VSS}
C {sky130_ioring_fill_1.sym} -300 800 0 0 {name=XS1_8_fill_1}
C {devices/lab_pin.sym} -360 740 0 0 {name=l148 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} -320 740 0 0 {name=l149 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} -360 860 0 0 {name=l150 sig_type=std_logic lab=VSS}
C {sky130_ioring_fill_1.sym} 0 800 0 0 {name=XS1_9_fill_1}
C {devices/lab_pin.sym} -60 740 0 0 {name=l151 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} -20 740 0 0 {name=l152 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} -60 860 0 0 {name=l153 sig_type=std_logic lab=VSS}
C {sky130_ioring_corner.sym} 300 800 0 0 {name=XC2}
C {devices/lab_pin.sym} 240 740 0 0 {name=l154 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} 280 740 0 0 {name=l155 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 240 860 0 0 {name=l156 sig_type=std_logic lab=VSS}
C {sky130_ioring_gpio.sym} 600 800 0 0 {name=XS2_0_gpio}
C {devices/lab_pin.sym} 500 710 0 0 {name=l157 sig_type=std_logic lab=A4}
C {devices/lab_pin.sym} 500 730 0 0 {name=l158 sig_type=std_logic lab=OE4}
C {devices/lab_pin.sym} 500 750 0 0 {name=l159 sig_type=std_logic lab=IE4}
C {devices/lab_pin.sym} 500 770 0 0 {name=l160 sig_type=std_logic lab=PU4}
C {devices/lab_pin.sym} 500 790 0 0 {name=l161 sig_type=std_logic lab=PD4}
C {devices/lab_pin.sym} 700 710 0 0 {name=l162 sig_type=std_logic lab=Y4}
C {devices/lab_pin.sym} 700 730 0 0 {name=l163 sig_type=std_logic lab=PAD4}
C {devices/lab_pin.sym} 540 680 0 0 {name=l164 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} 580 680 0 0 {name=l165 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 540 920 0 0 {name=l166 sig_type=std_logic lab=VSS}
C {sky130_ioring_vddio.sym} 900 800 0 0 {name=XS2_1_vddio}
C {devices/lab_pin.sym} 840 740 0 0 {name=l167 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} 880 740 0 0 {name=l168 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 840 860 0 0 {name=l169 sig_type=std_logic lab=VSS}
C {sky130_ioring_vss.sym} -300 1100 0 0 {name=XS2_2_vss}
C {devices/lab_pin.sym} -360 1040 0 0 {name=l170 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} -320 1040 0 0 {name=l171 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} -360 1160 0 0 {name=l172 sig_type=std_logic lab=VSS}
C {sky130_ioring_vdd.sym} 0 1100 0 0 {name=XS2_3_vdd}
C {devices/lab_pin.sym} -60 1040 0 0 {name=l173 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} -20 1040 0 0 {name=l174 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} -60 1160 0 0 {name=l175 sig_type=std_logic lab=VSS}
C {sky130_ioring_gpio.sym} 300 1100 0 0 {name=XS2_4_gpio}
C {devices/lab_pin.sym} 200 1010 0 0 {name=l176 sig_type=std_logic lab=A5}
C {devices/lab_pin.sym} 200 1030 0 0 {name=l177 sig_type=std_logic lab=OE5}
C {devices/lab_pin.sym} 200 1050 0 0 {name=l178 sig_type=std_logic lab=IE5}
C {devices/lab_pin.sym} 200 1070 0 0 {name=l179 sig_type=std_logic lab=PU5}
C {devices/lab_pin.sym} 200 1090 0 0 {name=l180 sig_type=std_logic lab=PD5}
C {devices/lab_pin.sym} 400 1010 0 0 {name=l181 sig_type=std_logic lab=Y5}
C {devices/lab_pin.sym} 400 1030 0 0 {name=l182 sig_type=std_logic lab=PAD5}
C {devices/lab_pin.sym} 240 980 0 0 {name=l183 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} 280 980 0 0 {name=l184 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 240 1220 0 0 {name=l185 sig_type=std_logic lab=VSS}
C {sky130_ioring_fill_20.sym} 600 1100 0 0 {name=XS2_5_fill_20}
C {devices/lab_pin.sym} 540 1040 0 0 {name=l186 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} 580 1040 0 0 {name=l187 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 540 1160 0 0 {name=l188 sig_type=std_logic lab=VSS}
C {sky130_ioring_fill_10.sym} 900 1100 0 0 {name=XS2_6_fill_10}
C {devices/lab_pin.sym} 840 1040 0 0 {name=l189 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} 880 1040 0 0 {name=l190 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 840 1160 0 0 {name=l191 sig_type=std_logic lab=VSS}
C {sky130_ioring_fill_5.sym} -300 1400 0 0 {name=XS2_7_fill_5}
C {devices/lab_pin.sym} -360 1340 0 0 {name=l192 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} -320 1340 0 0 {name=l193 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} -360 1460 0 0 {name=l194 sig_type=std_logic lab=VSS}
C {sky130_ioring_fill_1.sym} 0 1400 0 0 {name=XS2_8_fill_1}
C {devices/lab_pin.sym} -60 1340 0 0 {name=l195 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} -20 1340 0 0 {name=l196 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} -60 1460 0 0 {name=l197 sig_type=std_logic lab=VSS}
C {sky130_ioring_fill_1.sym} 300 1400 0 0 {name=XS2_9_fill_1}
C {devices/lab_pin.sym} 240 1340 0 0 {name=l198 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} 280 1340 0 0 {name=l199 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 240 1460 0 0 {name=l200 sig_type=std_logic lab=VSS}
C {sky130_ioring_corner.sym} 600 1400 0 0 {name=XC3}
C {devices/lab_pin.sym} 540 1340 0 0 {name=l201 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} 580 1340 0 0 {name=l202 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 540 1460 0 0 {name=l203 sig_type=std_logic lab=VSS}
C {sky130_ioring_gpio.sym} 900 1400 0 0 {name=XS3_0_gpio}
C {devices/lab_pin.sym} 800 1310 0 0 {name=l204 sig_type=std_logic lab=A6}
C {devices/lab_pin.sym} 800 1330 0 0 {name=l205 sig_type=std_logic lab=OE6}
C {devices/lab_pin.sym} 800 1350 0 0 {name=l206 sig_type=std_logic lab=IE6}
C {devices/lab_pin.sym} 800 1370 0 0 {name=l207 sig_type=std_logic lab=PU6}
C {devices/lab_pin.sym} 800 1390 0 0 {name=l208 sig_type=std_logic lab=PD6}
C {devices/lab_pin.sym} 1000 1310 0 0 {name=l209 sig_type=std_logic lab=Y6}
C {devices/lab_pin.sym} 1000 1330 0 0 {name=l210 sig_type=std_logic lab=PAD6}
C {devices/lab_pin.sym} 840 1280 0 0 {name=l211 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} 880 1280 0 0 {name=l212 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 840 1520 0 0 {name=l213 sig_type=std_logic lab=VSS}
C {sky130_ioring_vddio.sym} -300 1700 0 0 {name=XS3_1_vddio}
C {devices/lab_pin.sym} -360 1640 0 0 {name=l214 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} -320 1640 0 0 {name=l215 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} -360 1760 0 0 {name=l216 sig_type=std_logic lab=VSS}
C {sky130_ioring_vss.sym} 0 1700 0 0 {name=XS3_2_vss}
C {devices/lab_pin.sym} -60 1640 0 0 {name=l217 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} -20 1640 0 0 {name=l218 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} -60 1760 0 0 {name=l219 sig_type=std_logic lab=VSS}
C {sky130_ioring_vdd.sym} 300 1700 0 0 {name=XS3_3_vdd}
C {devices/lab_pin.sym} 240 1640 0 0 {name=l220 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} 280 1640 0 0 {name=l221 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 240 1760 0 0 {name=l222 sig_type=std_logic lab=VSS}
C {sky130_ioring_gpio.sym} 600 1700 0 0 {name=XS3_4_gpio}
C {devices/lab_pin.sym} 500 1610 0 0 {name=l223 sig_type=std_logic lab=A7}
C {devices/lab_pin.sym} 500 1630 0 0 {name=l224 sig_type=std_logic lab=OE7}
C {devices/lab_pin.sym} 500 1650 0 0 {name=l225 sig_type=std_logic lab=IE7}
C {devices/lab_pin.sym} 500 1670 0 0 {name=l226 sig_type=std_logic lab=PU7}
C {devices/lab_pin.sym} 500 1690 0 0 {name=l227 sig_type=std_logic lab=PD7}
C {devices/lab_pin.sym} 700 1610 0 0 {name=l228 sig_type=std_logic lab=Y7}
C {devices/lab_pin.sym} 700 1630 0 0 {name=l229 sig_type=std_logic lab=PAD7}
C {devices/lab_pin.sym} 540 1580 0 0 {name=l230 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} 580 1580 0 0 {name=l231 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 540 1820 0 0 {name=l232 sig_type=std_logic lab=VSS}
C {sky130_ioring_fill_20.sym} 900 1700 0 0 {name=XS3_5_fill_20}
C {devices/lab_pin.sym} 840 1640 0 0 {name=l233 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} 880 1640 0 0 {name=l234 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 840 1760 0 0 {name=l235 sig_type=std_logic lab=VSS}
C {sky130_ioring_fill_10.sym} -300 2000 0 0 {name=XS3_6_fill_10}
C {devices/lab_pin.sym} -360 1940 0 0 {name=l236 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} -320 1940 0 0 {name=l237 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} -360 2060 0 0 {name=l238 sig_type=std_logic lab=VSS}
C {sky130_ioring_fill_5.sym} 0 2000 0 0 {name=XS3_7_fill_5}
C {devices/lab_pin.sym} -60 1940 0 0 {name=l239 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} -20 1940 0 0 {name=l240 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} -60 2060 0 0 {name=l241 sig_type=std_logic lab=VSS}
C {sky130_ioring_fill_1.sym} 300 2000 0 0 {name=XS3_8_fill_1}
C {devices/lab_pin.sym} 240 1940 0 0 {name=l242 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} 280 1940 0 0 {name=l243 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 240 2060 0 0 {name=l244 sig_type=std_logic lab=VSS}
C {sky130_ioring_fill_1.sym} 600 2000 0 0 {name=XS3_9_fill_1}
C {devices/lab_pin.sym} 540 1940 0 0 {name=l245 sig_type=std_logic lab=VDDIO}
C {devices/lab_pin.sym} 580 1940 0 0 {name=l246 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 540 2060 0 0 {name=l247 sig_type=std_logic lab=VSS}
