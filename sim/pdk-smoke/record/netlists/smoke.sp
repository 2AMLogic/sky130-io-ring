* pdk-smoke: DC op + Id-Vgs per device, tt, 27 C
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
echo "RESULT nfet_01v8_op vsup=1.8 id_A=$&idq"
let idq = i(Vd_pfet_01v8)
echo "RESULT pfet_01v8_op vsup=1.8 id_A=$&idq"
let idq = -i(Vd_nfet_g5v0d10v5)
echo "RESULT nfet_g5v0d10v5_op vsup=5.0 id_A=$&idq"
let idq = i(Vd_pfet_g5v0d10v5)
echo "RESULT pfet_g5v0d10v5_op vsup=5.0 id_A=$&idq"
dc Vg_nfet_01v8 0 1.8 0.05
let id = -i(Vd_nfet_01v8)
let id0 = id[0]
let idmax = maximum(id)
let npts = length(id)
echo "RESULT nfet_01v8 vsup=1.8 id_off_A=$&id0 id_on_A=$&idmax points=$&npts"
dc Vg_pfet_01v8 1.8 0 -0.05
let id = i(Vd_pfet_01v8)
let id0 = id[0]
let idmax = maximum(id)
let npts = length(id)
echo "RESULT pfet_01v8 vsup=1.8 id_off_A=$&id0 id_on_A=$&idmax points=$&npts"
dc Vg_nfet_g5v0d10v5 0 5.0 0.05
let id = -i(Vd_nfet_g5v0d10v5)
let id0 = id[0]
let idmax = maximum(id)
let npts = length(id)
echo "RESULT nfet_g5v0d10v5 vsup=5.0 id_off_A=$&id0 id_on_A=$&idmax points=$&npts"
dc Vg_pfet_g5v0d10v5 5.0 0 -0.05
let id = i(Vd_pfet_g5v0d10v5)
let id0 = id[0]
let idmax = maximum(id)
let npts = length(id)
echo "RESULT pfet_g5v0d10v5 vsup=5.0 id_off_A=$&id0 id_on_A=$&idmax points=$&npts"
quit
.endc
.end
