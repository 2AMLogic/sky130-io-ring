* clamp-probe: G6 single-corner probe, tt, 27 C
.lib $PDK_ROOT/sky130A/libs.tech/ngspice/sky130.lib.spice tt
.temp 27
.include ./sky130_ioring_clamp_io.spice
.include ./sky130_ioring_clamp_core.spice
Vr_io vr_io 0 pulse(0 5.0 0 1u 1 1 1)
Xrio vr_io 0 sky130_ioring_clamp_io
Ch_io ch_io 0 100p ic=2000
Rh_io ch_io vh_io 1500
Xhio vh_io 0 sky130_ioring_clamp_io
.ic v(ch_io)=2000 v(vh_io)=0
Bi05_io ia05_io 0 V = v(xhio.gate) > 0.5 ? 1 : 0
Bi10_io ia10_io 0 V = v(xhio.gate) > 1.0 ? 1 : 0
Vr_core vr_core 0 pulse(0 1.8 0 1u 1 1 1)
Xrcore vr_core 0 sky130_ioring_clamp_core
Ch_core ch_core 0 100p ic=2000
Rh_core ch_core vh_core 1500
Xhcore vh_core 0 sky130_ioring_clamp_core
.ic v(ch_core)=2000 v(vh_core)=0
Bi05_core ia05_core 0 V = v(xhcore.gate) > 0.5 ? 1 : 0
Bi10_core ia10_core 0 V = v(xhcore.gate) > 1.0 ? 1 : 0
.control
set noaskquit
save all @m.xrio.xmcl.msky130_fd_pr__nfet_g5v0d10v5[id] @m.xhio.xmcl.msky130_fd_pr__nfet_g5v0d10v5[id] @m.xrcore.xmcl.msky130_fd_pr__nfet_01v8[id] @m.xhcore.xmcl.msky130_fd_pr__nfet_01v8[id]
alter Vr_io pulse = [ 0 5.0 0 1u 1 1 1 ]
alter Vr_core pulse = [ 0 1.8 0 1u 1 1 1 ]
tran 1.275e-08 5.1e-05 0 5.1e-08
let tend = 5.1e-05
let nn = length(time)
let idpk = maximum(@m.xrio.xmcl.msky130_fd_pr__nfet_g5v0d10v5[id])
let vgpk = maximum(v(xrio.gate))
let ilk = -i(Vr_io)[nn-1]
let ipk = maximum(abs(i(Vr_io)))
echo "RESULT ramp_io_1u vnom=5.0 tr_s=1u id_xmcl_pk_A=$&idpk gate_pk_V=$&vgpk isup_pk_A=$&ipk ileak_end_A=$&ilk"
let pvds = maximum(abs(v(xrio.g1) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.t) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_1u_mp1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g1) - 0))
let pvgs = maximum(abs(v(xrio.t) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_1u_mn1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g2) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.g1) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_1u_mp2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g2) - 0))
let pvgs = maximum(abs(v(xrio.g1) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_1u_mn2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.gate) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.g2) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_1u_mp3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.gate) - 0))
let pvgs = maximum(abs(v(xrio.g2) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_1u_mn3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(vr_io) - 0))
let pvgs = maximum(abs(v(xrio.gate) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_1u_mcl vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let idpk = maximum(@m.xrcore.xmcl.msky130_fd_pr__nfet_01v8[id])
let vgpk = maximum(v(xrcore.gate))
let ilk = -i(Vr_core)[nn-1]
let ipk = maximum(abs(i(Vr_core)))
echo "RESULT ramp_core_1u vnom=1.8 tr_s=1u id_xmcl_pk_A=$&idpk gate_pk_V=$&vgpk isup_pk_A=$&ipk ileak_end_A=$&ilk"
let pvds = maximum(abs(v(xrcore.g1) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.t) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_1u_mp1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g1) - 0))
let pvgs = maximum(abs(v(xrcore.t) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_1u_mn1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g2) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.g1) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_1u_mp2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g2) - 0))
let pvgs = maximum(abs(v(xrcore.g1) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_1u_mn2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.gate) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.g2) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_1u_mp3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.gate) - 0))
let pvgs = maximum(abs(v(xrcore.g2) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_1u_mn3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(vr_core) - 0))
let pvgs = maximum(abs(v(xrcore.gate) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_1u_mcl vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
alter Vr_io pulse = [ 0 5.0 0 10u 1 1 1 ]
alter Vr_core pulse = [ 0 1.8 0 10u 1 1 1 ]
tran 1.5e-08 6e-05 0 6e-08
let tend = 6e-05
let nn = length(time)
let idpk = maximum(@m.xrio.xmcl.msky130_fd_pr__nfet_g5v0d10v5[id])
let vgpk = maximum(v(xrio.gate))
let ilk = -i(Vr_io)[nn-1]
let ipk = maximum(abs(i(Vr_io)))
echo "RESULT ramp_io_10u vnom=5.0 tr_s=10u id_xmcl_pk_A=$&idpk gate_pk_V=$&vgpk isup_pk_A=$&ipk ileak_end_A=$&ilk"
let pvds = maximum(abs(v(xrio.g1) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.t) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_10u_mp1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g1) - 0))
let pvgs = maximum(abs(v(xrio.t) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_10u_mn1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g2) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.g1) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_10u_mp2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g2) - 0))
let pvgs = maximum(abs(v(xrio.g1) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_10u_mn2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.gate) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.g2) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_10u_mp3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.gate) - 0))
let pvgs = maximum(abs(v(xrio.g2) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_10u_mn3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(vr_io) - 0))
let pvgs = maximum(abs(v(xrio.gate) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_10u_mcl vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let idpk = maximum(@m.xrcore.xmcl.msky130_fd_pr__nfet_01v8[id])
let vgpk = maximum(v(xrcore.gate))
let ilk = -i(Vr_core)[nn-1]
let ipk = maximum(abs(i(Vr_core)))
echo "RESULT ramp_core_10u vnom=1.8 tr_s=10u id_xmcl_pk_A=$&idpk gate_pk_V=$&vgpk isup_pk_A=$&ipk ileak_end_A=$&ilk"
let pvds = maximum(abs(v(xrcore.g1) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.t) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_10u_mp1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g1) - 0))
let pvgs = maximum(abs(v(xrcore.t) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_10u_mn1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g2) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.g1) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_10u_mp2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g2) - 0))
let pvgs = maximum(abs(v(xrcore.g1) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_10u_mn2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.gate) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.g2) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_10u_mp3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.gate) - 0))
let pvgs = maximum(abs(v(xrcore.g2) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_10u_mn3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(vr_core) - 0))
let pvgs = maximum(abs(v(xrcore.gate) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_10u_mcl vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
alter Vr_io pulse = [ 0 5.0 0 100u 1 1 1 ]
alter Vr_core pulse = [ 0 1.8 0 100u 1 1 1 ]
tran 3.75e-08 0.00015 0 1.5e-07
let tend = 0.00015
let nn = length(time)
let idpk = maximum(@m.xrio.xmcl.msky130_fd_pr__nfet_g5v0d10v5[id])
let vgpk = maximum(v(xrio.gate))
let ilk = -i(Vr_io)[nn-1]
let ipk = maximum(abs(i(Vr_io)))
echo "RESULT ramp_io_100u vnom=5.0 tr_s=100u id_xmcl_pk_A=$&idpk gate_pk_V=$&vgpk isup_pk_A=$&ipk ileak_end_A=$&ilk"
let pvds = maximum(abs(v(xrio.g1) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.t) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_100u_mp1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g1) - 0))
let pvgs = maximum(abs(v(xrio.t) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_100u_mn1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g2) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.g1) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_100u_mp2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g2) - 0))
let pvgs = maximum(abs(v(xrio.g1) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_100u_mn2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.gate) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.g2) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_100u_mp3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.gate) - 0))
let pvgs = maximum(abs(v(xrio.g2) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_100u_mn3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(vr_io) - 0))
let pvgs = maximum(abs(v(xrio.gate) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_100u_mcl vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let idpk = maximum(@m.xrcore.xmcl.msky130_fd_pr__nfet_01v8[id])
let vgpk = maximum(v(xrcore.gate))
let ilk = -i(Vr_core)[nn-1]
let ipk = maximum(abs(i(Vr_core)))
echo "RESULT ramp_core_100u vnom=1.8 tr_s=100u id_xmcl_pk_A=$&idpk gate_pk_V=$&vgpk isup_pk_A=$&ipk ileak_end_A=$&ilk"
let pvds = maximum(abs(v(xrcore.g1) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.t) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_100u_mp1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g1) - 0))
let pvgs = maximum(abs(v(xrcore.t) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_100u_mn1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g2) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.g1) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_100u_mp2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g2) - 0))
let pvgs = maximum(abs(v(xrcore.g1) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_100u_mn2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.gate) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.g2) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_100u_mp3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.gate) - 0))
let pvgs = maximum(abs(v(xrcore.g2) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_100u_mn3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(vr_core) - 0))
let pvgs = maximum(abs(v(xrcore.gate) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_100u_mcl vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
alter Vr_io pulse = [ 0 5.0 0 1m 1 1 1 ]
alter Vr_core pulse = [ 0 1.8 0 1m 1 1 1 ]
tran 2.625e-07 0.00105 0 1.05e-06
let tend = 0.00105
let nn = length(time)
let idpk = maximum(@m.xrio.xmcl.msky130_fd_pr__nfet_g5v0d10v5[id])
let vgpk = maximum(v(xrio.gate))
let ilk = -i(Vr_io)[nn-1]
let ipk = maximum(abs(i(Vr_io)))
echo "RESULT ramp_io_1m vnom=5.0 tr_s=1m id_xmcl_pk_A=$&idpk gate_pk_V=$&vgpk isup_pk_A=$&ipk ileak_end_A=$&ilk"
let pvds = maximum(abs(v(xrio.g1) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.t) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_1m_mp1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g1) - 0))
let pvgs = maximum(abs(v(xrio.t) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_1m_mn1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g2) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.g1) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_1m_mp2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g2) - 0))
let pvgs = maximum(abs(v(xrio.g1) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_1m_mn2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.gate) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.g2) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_1m_mp3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.gate) - 0))
let pvgs = maximum(abs(v(xrio.g2) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_1m_mn3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(vr_io) - 0))
let pvgs = maximum(abs(v(xrio.gate) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_1m_mcl vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let idpk = maximum(@m.xrcore.xmcl.msky130_fd_pr__nfet_01v8[id])
let vgpk = maximum(v(xrcore.gate))
let ilk = -i(Vr_core)[nn-1]
let ipk = maximum(abs(i(Vr_core)))
echo "RESULT ramp_core_1m vnom=1.8 tr_s=1m id_xmcl_pk_A=$&idpk gate_pk_V=$&vgpk isup_pk_A=$&ipk ileak_end_A=$&ilk"
let pvds = maximum(abs(v(xrcore.g1) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.t) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_1m_mp1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g1) - 0))
let pvgs = maximum(abs(v(xrcore.t) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_1m_mn1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g2) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.g1) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_1m_mp2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g2) - 0))
let pvgs = maximum(abs(v(xrcore.g1) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_1m_mn2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.gate) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.g2) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_1m_mp3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.gate) - 0))
let pvgs = maximum(abs(v(xrcore.g2) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_1m_mn3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(vr_core) - 0))
let pvgs = maximum(abs(v(xrcore.gate) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_1m_mcl vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
tran 0.2n 10u 0 0.2n uic
let vpk = maximum(v(vh_io))
let idpk = maximum(@m.xhio.xmcl.msky130_fd_pr__nfet_g5v0d10v5[id])
let ipk = maximum(abs(v(ch_io) - v(vh_io))) / 1500
let vgpk = maximum(v(xhio.gate))
meas tran gend_io find v(xhio.gate) at=9.9u
meas tran vpend_io find v(vh_io) at=9.9u
meas tran tab05_io integ v(ia05_io)
meas tran tab10_io integ v(ia10_io)
echo "RESULT hbm_io vhbm_V=2000 c_F=100p r_ohm=1500 vp_pk_V=$&vpk id_xmcl_pk_A=$&idpk ipulse_pk_A=$&ipk gate_pk_V=$&vgpk gate_at_9p9us_V=$&gend_io vp_at_9p9us_V=$&vpend_io gate_above_0p5V_s=$&tab05_io gate_above_1p0V_s=$&tab10_io decay_tau_s=1.5e-7"
let pvds = maximum(abs(v(xhio.g1) - v(vh_io)))
let pvgs = maximum(abs(v(xhio.t) - v(vh_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_hbm_io_mp1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xhio.g1) - 0))
let pvgs = maximum(abs(v(xhio.t) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_hbm_io_mn1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xhio.g2) - v(vh_io)))
let pvgs = maximum(abs(v(xhio.g1) - v(vh_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_hbm_io_mp2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xhio.g2) - 0))
let pvgs = maximum(abs(v(xhio.g1) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_hbm_io_mn2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xhio.gate) - v(vh_io)))
let pvgs = maximum(abs(v(xhio.g2) - v(vh_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_hbm_io_mp3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xhio.gate) - 0))
let pvgs = maximum(abs(v(xhio.g2) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_hbm_io_mn3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(vh_io) - 0))
let pvgs = maximum(abs(v(xhio.gate) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_hbm_io_mcl vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let vpk = maximum(v(vh_core))
let idpk = maximum(@m.xhcore.xmcl.msky130_fd_pr__nfet_01v8[id])
let ipk = maximum(abs(v(ch_core) - v(vh_core))) / 1500
let vgpk = maximum(v(xhcore.gate))
meas tran gend_core find v(xhcore.gate) at=9.9u
meas tran vpend_core find v(vh_core) at=9.9u
meas tran tab05_core integ v(ia05_core)
meas tran tab10_core integ v(ia10_core)
echo "RESULT hbm_core vhbm_V=2000 c_F=100p r_ohm=1500 vp_pk_V=$&vpk id_xmcl_pk_A=$&idpk ipulse_pk_A=$&ipk gate_pk_V=$&vgpk gate_at_9p9us_V=$&gend_core vp_at_9p9us_V=$&vpend_core gate_above_0p5V_s=$&tab05_core gate_above_1p0V_s=$&tab10_core decay_tau_s=1.5e-7"
let pvds = maximum(abs(v(xhcore.g1) - v(vh_core)))
let pvgs = maximum(abs(v(xhcore.t) - v(vh_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_hbm_core_mp1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xhcore.g1) - 0))
let pvgs = maximum(abs(v(xhcore.t) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_hbm_core_mn1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xhcore.g2) - v(vh_core)))
let pvgs = maximum(abs(v(xhcore.g1) - v(vh_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_hbm_core_mp2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xhcore.g2) - 0))
let pvgs = maximum(abs(v(xhcore.g1) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_hbm_core_mn2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xhcore.gate) - v(vh_core)))
let pvgs = maximum(abs(v(xhcore.g2) - v(vh_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_hbm_core_mp3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xhcore.gate) - 0))
let pvgs = maximum(abs(v(xhcore.g2) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_hbm_core_mn3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(vh_core) - 0))
let pvgs = maximum(abs(v(xhcore.gate) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_hbm_core_mcl vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
quit
.endc
.end
