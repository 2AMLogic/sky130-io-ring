* diode-unit-probe: instance area/perim unit convention, issue #107
* tt corner, 27 C. GMIN is left at its ngspice default (1e-12 S);
* the sub-0.4 V rows exist to demonstrate that floor, not as results.
.lib $PDK_ROOT/sky130A/libs.tech/ngspice/sky130.lib.spice tt
.temp 27
Dpd1 f1 0 sky130_fd_pr__diode_pd2nw_05v5 area=1 perim=1
Dpd2 f2 0 sky130_fd_pr__diode_pd2nw_05v5 area=10 perim=1
Dpd3 f3 0 sky130_fd_pr__diode_pd2nw_05v5 area=1 perim=10
Dpd4 f4 0 sky130_fd_pr__diode_pd2nw_05v5 area=1 pj=1
Dpd6 f6 0 sky130_fd_pr__diode_pd2nw_05v5 area=2500 perim=200
Dnw1 g1 0 sky130_fd_pr__diode_pw2nd_05v5 area=1 perim=1
Dnw2 g2 0 sky130_fd_pr__diode_pw2nd_05v5 area=10 perim=1
Dnw3 g3 0 sky130_fd_pr__diode_pw2nd_05v5 area=1 perim=10
Dnw4 g4 0 sky130_fd_pr__diode_pw2nd_05v5 area=1 pj=1
Dnw6 g6 0 sky130_fd_pr__diode_pw2nd_05v5 area=2500 perim=200
Vpd1 f1 0 0
Vpd2 f2 0 0
Vpd3 f3 0 0
Vpd4 f4 0 0
Vpd6 f6 0 0
Vnw1 g1 0 0
Vnw2 g2 0 0
Vnw3 g3 0 0
Vnw4 g4 0 0
Vnw6 g6 0 0
Dpd8 h8 0 sky130_fd_pr__diode_pd2nw_05v5 area=2500 perim=200
Dpd9 h9 0 sky130_fd_pr__diode_pd2nw_05v5 area=25000 perim=2000
Dpd10 h10 0 sky130_fd_pr__diode_pd2nw_05v5 area=2e14 perim=6e7
Dnw8 k8 0 sky130_fd_pr__diode_pw2nd_05v5 area=2500 perim=200
Dnw9 k9 0 sky130_fd_pr__diode_pw2nd_05v5 area=25000 perim=2000
Dnw10 k10 0 sky130_fd_pr__diode_pw2nd_05v5 area=2e14 perim=6e7
Ipd8 0 h8 dc 0
Ipd9 0 h9 dc 0
Ipd10 0 h10 dc 0
Inw8 0 k8 dc 0
Inw9 0 k9 dc 0
Inw10 0 k10 dc 0
.control
set noaskquit
save all
echo "RESULT cards_pd2nw model=sky130_fd_pr__diode_pd2nw_05v5 cj_card_F_per_m2=7.4079e-16 cj_prescaled=7.4079e-16 cjsw_card_F_per_m=9.88e-17 cjsw_prescaled=9.88e-17 js=2.1483e-17 jsw=8.04e-16 n=1.3632 rs=600 ik=47600 pb=0.6587 mj=0.34629 php=0.7418 mjsw=0.29781 tref=30 area_model_default=1e+12 units_comment=cj_farad_per_meter^2_cjsw_farad_per_meter_js_amper_per_meter^2_rs_ohm"
echo "RESULT cards_pw2nd model=sky130_fd_pr__diode_pw2nd_05v5 cj_card_F_per_m2=1.3459e-15 cj_prescaled=1.3459e-15 cjsw_card_F_per_m=3.6001e-17 cjsw_prescaled=3.6001e-17 js=2.75e-15 jsw=6e-16 n=1.2928 rs=981 ik=1300 pb=0.729 mj=0.44 php=0.2 mjsw=0.0009 tref=30 area_model_default=1e+12 units_comment=cj_farad_per_meter^2_cjsw_farad_per_meter_js_amper_per_meter^2_rs_ohm"
alter Vpd1 = -3.3
alter Vpd2 = -3.3
alter Vpd3 = -3.3
alter Vpd4 = -3.3
alter Vpd6 = -3.3
alter Vnw1 = -3.3
alter Vnw2 = -3.3
alter Vnw3 = -3.3
alter Vnw4 = -3.3
alter Vnw6 = -3.3
op
echo "RESULT cap_pd1_vr3p3 vbias_V=-3.3 cd_F=$&@dpd1[cd]"
echo "RESULT cap_pd2_vr3p3 vbias_V=-3.3 cd_F=$&@dpd2[cd]"
echo "RESULT cap_pd3_vr3p3 vbias_V=-3.3 cd_F=$&@dpd3[cd]"
echo "RESULT cap_pd4_vr3p3 vbias_V=-3.3 cd_F=$&@dpd4[cd]"
echo "RESULT cap_pd6_vr3p3 vbias_V=-3.3 cd_F=$&@dpd6[cd]"
echo "RESULT cap_nw1_vr3p3 vbias_V=-3.3 cd_F=$&@dnw1[cd]"
echo "RESULT cap_nw2_vr3p3 vbias_V=-3.3 cd_F=$&@dnw2[cd]"
echo "RESULT cap_nw3_vr3p3 vbias_V=-3.3 cd_F=$&@dnw3[cd]"
echo "RESULT cap_nw4_vr3p3 vbias_V=-3.3 cd_F=$&@dnw4[cd]"
echo "RESULT cap_nw6_vr3p3 vbias_V=-3.3 cd_F=$&@dnw6[cd]"
alter Vpd1 = 0
alter Vpd2 = 0
alter Vpd3 = 0
alter Vpd4 = 0
alter Vpd6 = 0
alter Vnw1 = 0
alter Vnw2 = 0
alter Vnw3 = 0
alter Vnw4 = 0
alter Vnw6 = 0
op
echo "RESULT cap_pd1_vr0 vbias_V=0 cd_F=$&@dpd1[cd]"
echo "RESULT cap_pd2_vr0 vbias_V=0 cd_F=$&@dpd2[cd]"
echo "RESULT cap_pd3_vr0 vbias_V=0 cd_F=$&@dpd3[cd]"
echo "RESULT cap_pd4_vr0 vbias_V=0 cd_F=$&@dpd4[cd]"
echo "RESULT cap_pd6_vr0 vbias_V=0 cd_F=$&@dpd6[cd]"
echo "RESULT cap_nw1_vr0 vbias_V=0 cd_F=$&@dnw1[cd]"
echo "RESULT cap_nw2_vr0 vbias_V=0 cd_F=$&@dnw2[cd]"
echo "RESULT cap_nw3_vr0 vbias_V=0 cd_F=$&@dnw3[cd]"
echo "RESULT cap_nw4_vr0 vbias_V=0 cd_F=$&@dnw4[cd]"
echo "RESULT cap_nw6_vr0 vbias_V=0 cd_F=$&@dnw6[cd]"
echo "RESULT cap_pd8_vr0 bias_source=0A_current_source cd_F=$&@dpd8[cd]"
echo "RESULT cap_pd9_vr0 bias_source=0A_current_source cd_F=$&@dpd9[cd]"
echo "RESULT cap_pd10_vr0 bias_source=0A_current_source cd_F=$&@dpd10[cd]"
echo "RESULT cap_nw8_vr0 bias_source=0A_current_source cd_F=$&@dnw8[cd]"
echo "RESULT cap_nw9_vr0 bias_source=0A_current_source cd_F=$&@dnw9[cd]"
echo "RESULT cap_nw10_vr0 bias_source=0A_current_source cd_F=$&@dnw10[cd]"
alter Vpd1 = 0.2
alter Vpd2 = 0.2
alter Vpd3 = 0.2
alter Vpd4 = 0.2
alter Vpd6 = 0.2
alter Vnw1 = 0.2
alter Vnw2 = 0.2
alter Vnw3 = 0.2
alter Vnw4 = 0.2
alter Vnw6 = 0.2
op
echo "RESULT fwd_pd1_v0p2 vbias_V=0.2 id_A=$&@dpd1[id]"
echo "RESULT fwd_pd2_v0p2 vbias_V=0.2 id_A=$&@dpd2[id]"
echo "RESULT fwd_pd3_v0p2 vbias_V=0.2 id_A=$&@dpd3[id]"
echo "RESULT fwd_pd4_v0p2 vbias_V=0.2 id_A=$&@dpd4[id]"
echo "RESULT fwd_pd6_v0p2 vbias_V=0.2 id_A=$&@dpd6[id]"
echo "RESULT fwd_nw1_v0p2 vbias_V=0.2 id_A=$&@dnw1[id]"
echo "RESULT fwd_nw2_v0p2 vbias_V=0.2 id_A=$&@dnw2[id]"
echo "RESULT fwd_nw3_v0p2 vbias_V=0.2 id_A=$&@dnw3[id]"
echo "RESULT fwd_nw4_v0p2 vbias_V=0.2 id_A=$&@dnw4[id]"
echo "RESULT fwd_nw6_v0p2 vbias_V=0.2 id_A=$&@dnw6[id]"
alter Vpd1 = 0.3
alter Vpd2 = 0.3
alter Vpd3 = 0.3
alter Vpd4 = 0.3
alter Vpd6 = 0.3
alter Vnw1 = 0.3
alter Vnw2 = 0.3
alter Vnw3 = 0.3
alter Vnw4 = 0.3
alter Vnw6 = 0.3
op
echo "RESULT fwd_pd1_v0p3 vbias_V=0.3 id_A=$&@dpd1[id]"
echo "RESULT fwd_pd2_v0p3 vbias_V=0.3 id_A=$&@dpd2[id]"
echo "RESULT fwd_pd3_v0p3 vbias_V=0.3 id_A=$&@dpd3[id]"
echo "RESULT fwd_pd4_v0p3 vbias_V=0.3 id_A=$&@dpd4[id]"
echo "RESULT fwd_pd6_v0p3 vbias_V=0.3 id_A=$&@dpd6[id]"
echo "RESULT fwd_nw1_v0p3 vbias_V=0.3 id_A=$&@dnw1[id]"
echo "RESULT fwd_nw2_v0p3 vbias_V=0.3 id_A=$&@dnw2[id]"
echo "RESULT fwd_nw3_v0p3 vbias_V=0.3 id_A=$&@dnw3[id]"
echo "RESULT fwd_nw4_v0p3 vbias_V=0.3 id_A=$&@dnw4[id]"
echo "RESULT fwd_nw6_v0p3 vbias_V=0.3 id_A=$&@dnw6[id]"
alter Vpd1 = 0.4
alter Vpd2 = 0.4
alter Vpd3 = 0.4
alter Vpd4 = 0.4
alter Vpd6 = 0.4
alter Vnw1 = 0.4
alter Vnw2 = 0.4
alter Vnw3 = 0.4
alter Vnw4 = 0.4
alter Vnw6 = 0.4
op
echo "RESULT fwd_pd1_v0p4 vbias_V=0.4 id_A=$&@dpd1[id]"
echo "RESULT fwd_pd2_v0p4 vbias_V=0.4 id_A=$&@dpd2[id]"
echo "RESULT fwd_pd3_v0p4 vbias_V=0.4 id_A=$&@dpd3[id]"
echo "RESULT fwd_pd4_v0p4 vbias_V=0.4 id_A=$&@dpd4[id]"
echo "RESULT fwd_pd6_v0p4 vbias_V=0.4 id_A=$&@dpd6[id]"
echo "RESULT fwd_nw1_v0p4 vbias_V=0.4 id_A=$&@dnw1[id]"
echo "RESULT fwd_nw2_v0p4 vbias_V=0.4 id_A=$&@dnw2[id]"
echo "RESULT fwd_nw3_v0p4 vbias_V=0.4 id_A=$&@dnw3[id]"
echo "RESULT fwd_nw4_v0p4 vbias_V=0.4 id_A=$&@dnw4[id]"
echo "RESULT fwd_nw6_v0p4 vbias_V=0.4 id_A=$&@dnw6[id]"
alter Vpd1 = 0.6
alter Vpd2 = 0.6
alter Vpd3 = 0.6
alter Vpd4 = 0.6
alter Vpd6 = 0.6
alter Vnw1 = 0.6
alter Vnw2 = 0.6
alter Vnw3 = 0.6
alter Vnw4 = 0.6
alter Vnw6 = 0.6
op
echo "RESULT fwd_pd1_v0p6 vbias_V=0.6 id_A=$&@dpd1[id]"
echo "RESULT fwd_pd2_v0p6 vbias_V=0.6 id_A=$&@dpd2[id]"
echo "RESULT fwd_pd3_v0p6 vbias_V=0.6 id_A=$&@dpd3[id]"
echo "RESULT fwd_pd4_v0p6 vbias_V=0.6 id_A=$&@dpd4[id]"
echo "RESULT fwd_pd6_v0p6 vbias_V=0.6 id_A=$&@dpd6[id]"
echo "RESULT fwd_nw1_v0p6 vbias_V=0.6 id_A=$&@dnw1[id]"
echo "RESULT fwd_nw2_v0p6 vbias_V=0.6 id_A=$&@dnw2[id]"
echo "RESULT fwd_nw3_v0p6 vbias_V=0.6 id_A=$&@dnw3[id]"
echo "RESULT fwd_nw4_v0p6 vbias_V=0.6 id_A=$&@dnw4[id]"
echo "RESULT fwd_nw6_v0p6 vbias_V=0.6 id_A=$&@dnw6[id]"
op
echo "RESULT perim_alias pd1_perim=$&@dpd1[perim] pd4_perim=$&@dpd4[perim] nw1_perim=$&@dnw1[perim] nw4_perim=$&@dnw4[perim]"
alter Vpd1 = 0
alter Vpd2 = 0
alter Vpd3 = 0
alter Vpd4 = 0
alter Vpd6 = 0
alter Vnw1 = 0
alter Vnw2 = 0
alter Vnw3 = 0
alter Vnw4 = 0
alter Vnw6 = 0
alter Ipd8 = 1.33333
alter Ipd9 = 1.33333
alter Ipd10 = 1.33333
alter Inw8 = 1.33333
alter Inw9 = 1.33333
alter Inw10 = 1.33333
op
echo "RESULT anchor_pd8_a2500 i_forced_A=1.33333 area=2500 perim=200 vdrop_V=$&v(h8)"
echo "RESULT anchor_pd9_a25000 i_forced_A=1.33333 area=25000 perim=2000 vdrop_V=$&v(h9)"
echo "RESULT anchor_pd10_a2e14 i_forced_A=1.33333 area=2e14 perim=6e7 vdrop_V=$&v(h10)"
echo "RESULT anchor_nw8_a2500 i_forced_A=1.33333 area=2500 perim=200 vdrop_V=$&v(k8)"
echo "RESULT anchor_nw9_a25000 i_forced_A=1.33333 area=25000 perim=2000 vdrop_V=$&v(k9)"
echo "RESULT anchor_nw10_a2e14 i_forced_A=1.33333 area=2e14 perim=6e7 vdrop_V=$&v(k10)"
quit
.endc
.end
