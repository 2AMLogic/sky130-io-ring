* corner-skew-probe: G2 measured anchor, DC operating point, tt, 27 C
.lib $PDK_ROOT/sky130A/libs.tech/ngspice/sky130.lib.spice tt
.temp 27
Vd_nfet_01v8 d_nfet_01v8 0 1.8
Vg_nfet_01v8 g_nfet_01v8 0 1.8
XM_nfet_01v8 d_nfet_01v8 g_nfet_01v8 0 0 sky130_fd_pr__nfet_01v8 w=1.0 l=0.15
Vs_pfet_01v8 s_pfet_01v8 0 1.8
Vd_pfet_01v8 d_pfet_01v8 0 0
Vg_pfet_01v8 g_pfet_01v8 0 0
XM_pfet_01v8 d_pfet_01v8 g_pfet_01v8 s_pfet_01v8 s_pfet_01v8 sky130_fd_pr__pfet_01v8 w=1.0 l=0.15
Vd_nfet_g5v0d10v5 d_nfet_g5v0d10v5 0 5.0
Vg_nfet_g5v0d10v5 g_nfet_g5v0d10v5 0 5.0
XM_nfet_g5v0d10v5 d_nfet_g5v0d10v5 g_nfet_g5v0d10v5 0 0 sky130_fd_pr__nfet_g5v0d10v5 w=1.0 l=0.5
Vs_pfet_g5v0d10v5 s_pfet_g5v0d10v5 0 5.0
Vd_pfet_g5v0d10v5 d_pfet_g5v0d10v5 0 0
Vg_pfet_g5v0d10v5 g_pfet_g5v0d10v5 0 0
XM_pfet_g5v0d10v5 d_pfet_g5v0d10v5 g_pfet_g5v0d10v5 s_pfet_g5v0d10v5 s_pfet_g5v0d10v5 sky130_fd_pr__pfet_g5v0d10v5 w=1.0 l=0.5
.control
op
let idq = -i(Vd_nfet_01v8)
let vt = abs(@m.xm_nfet_01v8.msky130_fd_pr__nfet_01v8[vth])
let vds = abs(@m.xm_nfet_01v8.msky130_fd_pr__nfet_01v8[vdsat])
let gmq = abs(@m.xm_nfet_01v8.msky130_fd_pr__nfet_01v8[gm])
let idm = abs(@m.xm_nfet_01v8.msky130_fd_pr__nfet_01v8[id])
echo "RESULT op_nfet_01v8 corner=tt temp_c=27 vsup=1.8 w_um=1.0 l_um=0.15 id_A=$&idq id_model_A=$&idm vth_op_V=$&vt vdsat_op_V=$&vds gm_S=$&gmq"
let idq = i(Vd_pfet_01v8)
let vt = abs(@m.xm_pfet_01v8.msky130_fd_pr__pfet_01v8[vth])
let vds = abs(@m.xm_pfet_01v8.msky130_fd_pr__pfet_01v8[vdsat])
let gmq = abs(@m.xm_pfet_01v8.msky130_fd_pr__pfet_01v8[gm])
let idm = abs(@m.xm_pfet_01v8.msky130_fd_pr__pfet_01v8[id])
echo "RESULT op_pfet_01v8 corner=tt temp_c=27 vsup=1.8 w_um=1.0 l_um=0.15 id_A=$&idq id_model_A=$&idm vth_op_V=$&vt vdsat_op_V=$&vds gm_S=$&gmq"
let idq = -i(Vd_nfet_g5v0d10v5)
let vt = abs(@m.xm_nfet_g5v0d10v5.msky130_fd_pr__nfet_g5v0d10v5[vth])
let vds = abs(@m.xm_nfet_g5v0d10v5.msky130_fd_pr__nfet_g5v0d10v5[vdsat])
let gmq = abs(@m.xm_nfet_g5v0d10v5.msky130_fd_pr__nfet_g5v0d10v5[gm])
let idm = abs(@m.xm_nfet_g5v0d10v5.msky130_fd_pr__nfet_g5v0d10v5[id])
echo "RESULT op_nfet_g5v0d10v5 corner=tt temp_c=27 vsup=5.0 w_um=1.0 l_um=0.5 id_A=$&idq id_model_A=$&idm vth_op_V=$&vt vdsat_op_V=$&vds gm_S=$&gmq"
let idq = i(Vd_pfet_g5v0d10v5)
let vt = abs(@m.xm_pfet_g5v0d10v5.msky130_fd_pr__pfet_g5v0d10v5[vth])
let vds = abs(@m.xm_pfet_g5v0d10v5.msky130_fd_pr__pfet_g5v0d10v5[vdsat])
let gmq = abs(@m.xm_pfet_g5v0d10v5.msky130_fd_pr__pfet_g5v0d10v5[gm])
let idm = abs(@m.xm_pfet_g5v0d10v5.msky130_fd_pr__pfet_g5v0d10v5[id])
echo "RESULT op_pfet_g5v0d10v5 corner=tt temp_c=27 vsup=5.0 w_um=1.0 l_um=0.5 id_A=$&idq id_model_A=$&idm vth_op_V=$&vt vdsat_op_V=$&vds gm_S=$&gmq"
quit
.endc
.end
