* clamp-trigger-probe: G6 follow-up single-corner probe, tt, 27 C
.lib $PDK_ROOT/sky130A/libs.tech/ngspice/sky130.lib.spice tt
.temp 27
.include ./sky130_ioring_clamp_io.spice
.include ./sky130_ioring_clamp_core.spice
Vr_io vr_io 0 pulse(0 5.0 0 1u 1 1 1)
Xrio vr_io 0 sky130_ioring_clamp_io
Vd_io vd_io 0 5.0
Xdio vd_io 0 sky130_ioring_clamp_io
Vr_core vr_core 0 pulse(0 1.8 0 1u 1 1 1)
Xrcore vr_core 0 sky130_ioring_clamp_core
Vd_core vd_core 0 1.8
Xdcore vd_core 0 sky130_ioring_clamp_core
.control
set noaskquit
save all @m.xrio.xmcl.msky130_fd_pr__nfet_g5v0d10v5[id] @m.xrcore.xmcl.msky130_fd_pr__nfet_01v8[id]
op
let ilkd = -i(Vd_io)
echo "RESULT dcop_io vp_V=5.0 ileak_dc_A=$&ilkd"
let ilkd = -i(Vd_core)
echo "RESULT dcop_core vp_V=1.8 ileak_dc_A=$&ilkd"
alter Vd_io = 0
alter Vd_core = 0
alter Vr_io pulse = [ 0 5.0 0 1u 1 1 1 ]
alter Vr_core pulse = [ 0 1.8 0 1u 1 1 1 ]
tran 1.275e-08 5.1e-05 0 5.1e-08
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
alter Vr_io pulse = [ 0 5.0 0 2u 1 1 1 ]
alter Vr_core pulse = [ 0 1.8 0 2u 1 1 1 ]
tran 1.3e-08 5.2e-05 0 5.2e-08
let nn = length(time)
let idpk = maximum(@m.xrio.xmcl.msky130_fd_pr__nfet_g5v0d10v5[id])
let vgpk = maximum(v(xrio.gate))
let ilk = -i(Vr_io)[nn-1]
let ipk = maximum(abs(i(Vr_io)))
echo "RESULT ramp_io_2u vnom=5.0 tr_s=2u id_xmcl_pk_A=$&idpk gate_pk_V=$&vgpk isup_pk_A=$&ipk ileak_end_A=$&ilk"
let pvds = maximum(abs(v(xrio.g1) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.t) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_2u_mp1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g1) - 0))
let pvgs = maximum(abs(v(xrio.t) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_2u_mn1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g2) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.g1) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_2u_mp2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g2) - 0))
let pvgs = maximum(abs(v(xrio.g1) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_2u_mn2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.gate) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.g2) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_2u_mp3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.gate) - 0))
let pvgs = maximum(abs(v(xrio.g2) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_2u_mn3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(vr_io) - 0))
let pvgs = maximum(abs(v(xrio.gate) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_2u_mcl vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let idpk = maximum(@m.xrcore.xmcl.msky130_fd_pr__nfet_01v8[id])
let vgpk = maximum(v(xrcore.gate))
let ilk = -i(Vr_core)[nn-1]
let ipk = maximum(abs(i(Vr_core)))
echo "RESULT ramp_core_2u vnom=1.8 tr_s=2u id_xmcl_pk_A=$&idpk gate_pk_V=$&vgpk isup_pk_A=$&ipk ileak_end_A=$&ilk"
let pvds = maximum(abs(v(xrcore.g1) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.t) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_2u_mp1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g1) - 0))
let pvgs = maximum(abs(v(xrcore.t) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_2u_mn1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g2) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.g1) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_2u_mp2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g2) - 0))
let pvgs = maximum(abs(v(xrcore.g1) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_2u_mn2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.gate) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.g2) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_2u_mp3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.gate) - 0))
let pvgs = maximum(abs(v(xrcore.g2) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_2u_mn3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(vr_core) - 0))
let pvgs = maximum(abs(v(xrcore.gate) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_2u_mcl vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
alter Vr_io pulse = [ 0 5.0 0 3u 1 1 1 ]
alter Vr_core pulse = [ 0 1.8 0 3u 1 1 1 ]
tran 1.325e-08 5.3e-05 0 5.3e-08
let nn = length(time)
let idpk = maximum(@m.xrio.xmcl.msky130_fd_pr__nfet_g5v0d10v5[id])
let vgpk = maximum(v(xrio.gate))
let ilk = -i(Vr_io)[nn-1]
let ipk = maximum(abs(i(Vr_io)))
echo "RESULT ramp_io_3u vnom=5.0 tr_s=3u id_xmcl_pk_A=$&idpk gate_pk_V=$&vgpk isup_pk_A=$&ipk ileak_end_A=$&ilk"
let pvds = maximum(abs(v(xrio.g1) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.t) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_3u_mp1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g1) - 0))
let pvgs = maximum(abs(v(xrio.t) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_3u_mn1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g2) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.g1) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_3u_mp2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g2) - 0))
let pvgs = maximum(abs(v(xrio.g1) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_3u_mn2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.gate) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.g2) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_3u_mp3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.gate) - 0))
let pvgs = maximum(abs(v(xrio.g2) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_3u_mn3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(vr_io) - 0))
let pvgs = maximum(abs(v(xrio.gate) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_3u_mcl vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let idpk = maximum(@m.xrcore.xmcl.msky130_fd_pr__nfet_01v8[id])
let vgpk = maximum(v(xrcore.gate))
let ilk = -i(Vr_core)[nn-1]
let ipk = maximum(abs(i(Vr_core)))
echo "RESULT ramp_core_3u vnom=1.8 tr_s=3u id_xmcl_pk_A=$&idpk gate_pk_V=$&vgpk isup_pk_A=$&ipk ileak_end_A=$&ilk"
let pvds = maximum(abs(v(xrcore.g1) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.t) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_3u_mp1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g1) - 0))
let pvgs = maximum(abs(v(xrcore.t) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_3u_mn1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g2) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.g1) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_3u_mp2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g2) - 0))
let pvgs = maximum(abs(v(xrcore.g1) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_3u_mn2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.gate) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.g2) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_3u_mp3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.gate) - 0))
let pvgs = maximum(abs(v(xrcore.g2) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_3u_mn3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(vr_core) - 0))
let pvgs = maximum(abs(v(xrcore.gate) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_3u_mcl vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
alter Vr_io pulse = [ 0 5.0 0 4u 1 1 1 ]
alter Vr_core pulse = [ 0 1.8 0 4u 1 1 1 ]
tran 1.35e-08 5.4e-05 0 5.4e-08
let nn = length(time)
let idpk = maximum(@m.xrio.xmcl.msky130_fd_pr__nfet_g5v0d10v5[id])
let vgpk = maximum(v(xrio.gate))
let ilk = -i(Vr_io)[nn-1]
let ipk = maximum(abs(i(Vr_io)))
echo "RESULT ramp_io_4u vnom=5.0 tr_s=4u id_xmcl_pk_A=$&idpk gate_pk_V=$&vgpk isup_pk_A=$&ipk ileak_end_A=$&ilk"
let pvds = maximum(abs(v(xrio.g1) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.t) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_4u_mp1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g1) - 0))
let pvgs = maximum(abs(v(xrio.t) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_4u_mn1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g2) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.g1) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_4u_mp2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g2) - 0))
let pvgs = maximum(abs(v(xrio.g1) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_4u_mn2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.gate) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.g2) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_4u_mp3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.gate) - 0))
let pvgs = maximum(abs(v(xrio.g2) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_4u_mn3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(vr_io) - 0))
let pvgs = maximum(abs(v(xrio.gate) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_4u_mcl vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let idpk = maximum(@m.xrcore.xmcl.msky130_fd_pr__nfet_01v8[id])
let vgpk = maximum(v(xrcore.gate))
let ilk = -i(Vr_core)[nn-1]
let ipk = maximum(abs(i(Vr_core)))
echo "RESULT ramp_core_4u vnom=1.8 tr_s=4u id_xmcl_pk_A=$&idpk gate_pk_V=$&vgpk isup_pk_A=$&ipk ileak_end_A=$&ilk"
let pvds = maximum(abs(v(xrcore.g1) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.t) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_4u_mp1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g1) - 0))
let pvgs = maximum(abs(v(xrcore.t) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_4u_mn1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g2) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.g1) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_4u_mp2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g2) - 0))
let pvgs = maximum(abs(v(xrcore.g1) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_4u_mn2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.gate) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.g2) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_4u_mp3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.gate) - 0))
let pvgs = maximum(abs(v(xrcore.g2) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_4u_mn3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(vr_core) - 0))
let pvgs = maximum(abs(v(xrcore.gate) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_4u_mcl vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
alter Vr_io pulse = [ 0 5.0 0 5u 1 1 1 ]
alter Vr_core pulse = [ 0 1.8 0 5u 1 1 1 ]
tran 1.375e-08 5.5e-05 0 5.5e-08
let nn = length(time)
let idpk = maximum(@m.xrio.xmcl.msky130_fd_pr__nfet_g5v0d10v5[id])
let vgpk = maximum(v(xrio.gate))
let ilk = -i(Vr_io)[nn-1]
let ipk = maximum(abs(i(Vr_io)))
echo "RESULT ramp_io_5u vnom=5.0 tr_s=5u id_xmcl_pk_A=$&idpk gate_pk_V=$&vgpk isup_pk_A=$&ipk ileak_end_A=$&ilk"
let pvds = maximum(abs(v(xrio.g1) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.t) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_5u_mp1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g1) - 0))
let pvgs = maximum(abs(v(xrio.t) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_5u_mn1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g2) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.g1) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_5u_mp2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g2) - 0))
let pvgs = maximum(abs(v(xrio.g1) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_5u_mn2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.gate) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.g2) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_5u_mp3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.gate) - 0))
let pvgs = maximum(abs(v(xrio.g2) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_5u_mn3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(vr_io) - 0))
let pvgs = maximum(abs(v(xrio.gate) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_5u_mcl vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let idpk = maximum(@m.xrcore.xmcl.msky130_fd_pr__nfet_01v8[id])
let vgpk = maximum(v(xrcore.gate))
let ilk = -i(Vr_core)[nn-1]
let ipk = maximum(abs(i(Vr_core)))
echo "RESULT ramp_core_5u vnom=1.8 tr_s=5u id_xmcl_pk_A=$&idpk gate_pk_V=$&vgpk isup_pk_A=$&ipk ileak_end_A=$&ilk"
let pvds = maximum(abs(v(xrcore.g1) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.t) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_5u_mp1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g1) - 0))
let pvgs = maximum(abs(v(xrcore.t) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_5u_mn1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g2) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.g1) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_5u_mp2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g2) - 0))
let pvgs = maximum(abs(v(xrcore.g1) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_5u_mn2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.gate) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.g2) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_5u_mp3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.gate) - 0))
let pvgs = maximum(abs(v(xrcore.g2) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_5u_mn3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(vr_core) - 0))
let pvgs = maximum(abs(v(xrcore.gate) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_5u_mcl vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
alter Vr_io pulse = [ 0 5.0 0 5.25u 1 1 1 ]
alter Vr_core pulse = [ 0 1.8 0 5.25u 1 1 1 ]
tran 1.381e-08 5.525e-05 0 5.525e-08
let nn = length(time)
let idpk = maximum(@m.xrio.xmcl.msky130_fd_pr__nfet_g5v0d10v5[id])
let vgpk = maximum(v(xrio.gate))
let ilk = -i(Vr_io)[nn-1]
let ipk = maximum(abs(i(Vr_io)))
echo "RESULT ramp_io_5.25u vnom=5.0 tr_s=5.25u id_xmcl_pk_A=$&idpk gate_pk_V=$&vgpk isup_pk_A=$&ipk ileak_end_A=$&ilk"
let pvds = maximum(abs(v(xrio.g1) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.t) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_5.25u_mp1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g1) - 0))
let pvgs = maximum(abs(v(xrio.t) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_5.25u_mn1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g2) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.g1) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_5.25u_mp2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g2) - 0))
let pvgs = maximum(abs(v(xrio.g1) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_5.25u_mn2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.gate) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.g2) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_5.25u_mp3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.gate) - 0))
let pvgs = maximum(abs(v(xrio.g2) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_5.25u_mn3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(vr_io) - 0))
let pvgs = maximum(abs(v(xrio.gate) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_5.25u_mcl vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let idpk = maximum(@m.xrcore.xmcl.msky130_fd_pr__nfet_01v8[id])
let vgpk = maximum(v(xrcore.gate))
let ilk = -i(Vr_core)[nn-1]
let ipk = maximum(abs(i(Vr_core)))
echo "RESULT ramp_core_5.25u vnom=1.8 tr_s=5.25u id_xmcl_pk_A=$&idpk gate_pk_V=$&vgpk isup_pk_A=$&ipk ileak_end_A=$&ilk"
let pvds = maximum(abs(v(xrcore.g1) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.t) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_5.25u_mp1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g1) - 0))
let pvgs = maximum(abs(v(xrcore.t) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_5.25u_mn1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g2) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.g1) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_5.25u_mp2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g2) - 0))
let pvgs = maximum(abs(v(xrcore.g1) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_5.25u_mn2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.gate) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.g2) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_5.25u_mp3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.gate) - 0))
let pvgs = maximum(abs(v(xrcore.g2) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_5.25u_mn3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(vr_core) - 0))
let pvgs = maximum(abs(v(xrcore.gate) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_5.25u_mcl vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
alter Vr_io pulse = [ 0 5.0 0 5.5u 1 1 1 ]
alter Vr_core pulse = [ 0 1.8 0 5.5u 1 1 1 ]
tran 1.388e-08 5.55e-05 0 5.55e-08
let nn = length(time)
let idpk = maximum(@m.xrio.xmcl.msky130_fd_pr__nfet_g5v0d10v5[id])
let vgpk = maximum(v(xrio.gate))
let ilk = -i(Vr_io)[nn-1]
let ipk = maximum(abs(i(Vr_io)))
echo "RESULT ramp_io_5.5u vnom=5.0 tr_s=5.5u id_xmcl_pk_A=$&idpk gate_pk_V=$&vgpk isup_pk_A=$&ipk ileak_end_A=$&ilk"
let pvds = maximum(abs(v(xrio.g1) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.t) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_5.5u_mp1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g1) - 0))
let pvgs = maximum(abs(v(xrio.t) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_5.5u_mn1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g2) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.g1) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_5.5u_mp2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g2) - 0))
let pvgs = maximum(abs(v(xrio.g1) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_5.5u_mn2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.gate) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.g2) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_5.5u_mp3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.gate) - 0))
let pvgs = maximum(abs(v(xrio.g2) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_5.5u_mn3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(vr_io) - 0))
let pvgs = maximum(abs(v(xrio.gate) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_5.5u_mcl vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let idpk = maximum(@m.xrcore.xmcl.msky130_fd_pr__nfet_01v8[id])
let vgpk = maximum(v(xrcore.gate))
let ilk = -i(Vr_core)[nn-1]
let ipk = maximum(abs(i(Vr_core)))
echo "RESULT ramp_core_5.5u vnom=1.8 tr_s=5.5u id_xmcl_pk_A=$&idpk gate_pk_V=$&vgpk isup_pk_A=$&ipk ileak_end_A=$&ilk"
let pvds = maximum(abs(v(xrcore.g1) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.t) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_5.5u_mp1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g1) - 0))
let pvgs = maximum(abs(v(xrcore.t) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_5.5u_mn1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g2) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.g1) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_5.5u_mp2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g2) - 0))
let pvgs = maximum(abs(v(xrcore.g1) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_5.5u_mn2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.gate) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.g2) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_5.5u_mp3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.gate) - 0))
let pvgs = maximum(abs(v(xrcore.g2) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_5.5u_mn3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(vr_core) - 0))
let pvgs = maximum(abs(v(xrcore.gate) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_5.5u_mcl vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
alter Vr_io pulse = [ 0 5.0 0 5.75u 1 1 1 ]
alter Vr_core pulse = [ 0 1.8 0 5.75u 1 1 1 ]
tran 1.394e-08 5.575e-05 0 5.575e-08
let nn = length(time)
let idpk = maximum(@m.xrio.xmcl.msky130_fd_pr__nfet_g5v0d10v5[id])
let vgpk = maximum(v(xrio.gate))
let ilk = -i(Vr_io)[nn-1]
let ipk = maximum(abs(i(Vr_io)))
echo "RESULT ramp_io_5.75u vnom=5.0 tr_s=5.75u id_xmcl_pk_A=$&idpk gate_pk_V=$&vgpk isup_pk_A=$&ipk ileak_end_A=$&ilk"
let pvds = maximum(abs(v(xrio.g1) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.t) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_5.75u_mp1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g1) - 0))
let pvgs = maximum(abs(v(xrio.t) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_5.75u_mn1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g2) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.g1) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_5.75u_mp2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g2) - 0))
let pvgs = maximum(abs(v(xrio.g1) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_5.75u_mn2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.gate) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.g2) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_5.75u_mp3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.gate) - 0))
let pvgs = maximum(abs(v(xrio.g2) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_5.75u_mn3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(vr_io) - 0))
let pvgs = maximum(abs(v(xrio.gate) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_5.75u_mcl vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let idpk = maximum(@m.xrcore.xmcl.msky130_fd_pr__nfet_01v8[id])
let vgpk = maximum(v(xrcore.gate))
let ilk = -i(Vr_core)[nn-1]
let ipk = maximum(abs(i(Vr_core)))
echo "RESULT ramp_core_5.75u vnom=1.8 tr_s=5.75u id_xmcl_pk_A=$&idpk gate_pk_V=$&vgpk isup_pk_A=$&ipk ileak_end_A=$&ilk"
let pvds = maximum(abs(v(xrcore.g1) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.t) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_5.75u_mp1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g1) - 0))
let pvgs = maximum(abs(v(xrcore.t) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_5.75u_mn1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g2) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.g1) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_5.75u_mp2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g2) - 0))
let pvgs = maximum(abs(v(xrcore.g1) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_5.75u_mn2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.gate) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.g2) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_5.75u_mp3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.gate) - 0))
let pvgs = maximum(abs(v(xrcore.g2) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_5.75u_mn3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(vr_core) - 0))
let pvgs = maximum(abs(v(xrcore.gate) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_5.75u_mcl vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
alter Vr_io pulse = [ 0 5.0 0 6u 1 1 1 ]
alter Vr_core pulse = [ 0 1.8 0 6u 1 1 1 ]
tran 1.4e-08 5.6e-05 0 5.6e-08
let nn = length(time)
let idpk = maximum(@m.xrio.xmcl.msky130_fd_pr__nfet_g5v0d10v5[id])
let vgpk = maximum(v(xrio.gate))
let ilk = -i(Vr_io)[nn-1]
let ipk = maximum(abs(i(Vr_io)))
echo "RESULT ramp_io_6u vnom=5.0 tr_s=6u id_xmcl_pk_A=$&idpk gate_pk_V=$&vgpk isup_pk_A=$&ipk ileak_end_A=$&ilk"
let pvds = maximum(abs(v(xrio.g1) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.t) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_6u_mp1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g1) - 0))
let pvgs = maximum(abs(v(xrio.t) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_6u_mn1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g2) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.g1) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_6u_mp2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g2) - 0))
let pvgs = maximum(abs(v(xrio.g1) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_6u_mn2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.gate) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.g2) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_6u_mp3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.gate) - 0))
let pvgs = maximum(abs(v(xrio.g2) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_6u_mn3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(vr_io) - 0))
let pvgs = maximum(abs(v(xrio.gate) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_6u_mcl vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let idpk = maximum(@m.xrcore.xmcl.msky130_fd_pr__nfet_01v8[id])
let vgpk = maximum(v(xrcore.gate))
let ilk = -i(Vr_core)[nn-1]
let ipk = maximum(abs(i(Vr_core)))
echo "RESULT ramp_core_6u vnom=1.8 tr_s=6u id_xmcl_pk_A=$&idpk gate_pk_V=$&vgpk isup_pk_A=$&ipk ileak_end_A=$&ilk"
let pvds = maximum(abs(v(xrcore.g1) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.t) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_6u_mp1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g1) - 0))
let pvgs = maximum(abs(v(xrcore.t) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_6u_mn1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g2) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.g1) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_6u_mp2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g2) - 0))
let pvgs = maximum(abs(v(xrcore.g1) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_6u_mn2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.gate) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.g2) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_6u_mp3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.gate) - 0))
let pvgs = maximum(abs(v(xrcore.g2) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_6u_mn3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(vr_core) - 0))
let pvgs = maximum(abs(v(xrcore.gate) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_6u_mcl vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
alter Vr_io pulse = [ 0 5.0 0 6.25u 1 1 1 ]
alter Vr_core pulse = [ 0 1.8 0 6.25u 1 1 1 ]
tran 1.406e-08 5.625e-05 0 5.625e-08
let nn = length(time)
let idpk = maximum(@m.xrio.xmcl.msky130_fd_pr__nfet_g5v0d10v5[id])
let vgpk = maximum(v(xrio.gate))
let ilk = -i(Vr_io)[nn-1]
let ipk = maximum(abs(i(Vr_io)))
echo "RESULT ramp_io_6.25u vnom=5.0 tr_s=6.25u id_xmcl_pk_A=$&idpk gate_pk_V=$&vgpk isup_pk_A=$&ipk ileak_end_A=$&ilk"
let pvds = maximum(abs(v(xrio.g1) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.t) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_6.25u_mp1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g1) - 0))
let pvgs = maximum(abs(v(xrio.t) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_6.25u_mn1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g2) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.g1) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_6.25u_mp2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g2) - 0))
let pvgs = maximum(abs(v(xrio.g1) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_6.25u_mn2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.gate) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.g2) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_6.25u_mp3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.gate) - 0))
let pvgs = maximum(abs(v(xrio.g2) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_6.25u_mn3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(vr_io) - 0))
let pvgs = maximum(abs(v(xrio.gate) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_6.25u_mcl vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let idpk = maximum(@m.xrcore.xmcl.msky130_fd_pr__nfet_01v8[id])
let vgpk = maximum(v(xrcore.gate))
let ilk = -i(Vr_core)[nn-1]
let ipk = maximum(abs(i(Vr_core)))
echo "RESULT ramp_core_6.25u vnom=1.8 tr_s=6.25u id_xmcl_pk_A=$&idpk gate_pk_V=$&vgpk isup_pk_A=$&ipk ileak_end_A=$&ilk"
let pvds = maximum(abs(v(xrcore.g1) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.t) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_6.25u_mp1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g1) - 0))
let pvgs = maximum(abs(v(xrcore.t) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_6.25u_mn1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g2) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.g1) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_6.25u_mp2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g2) - 0))
let pvgs = maximum(abs(v(xrcore.g1) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_6.25u_mn2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.gate) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.g2) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_6.25u_mp3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.gate) - 0))
let pvgs = maximum(abs(v(xrcore.g2) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_6.25u_mn3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(vr_core) - 0))
let pvgs = maximum(abs(v(xrcore.gate) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_6.25u_mcl vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
alter Vr_io pulse = [ 0 5.0 0 6.5u 1 1 1 ]
alter Vr_core pulse = [ 0 1.8 0 6.5u 1 1 1 ]
tran 1.412e-08 5.65e-05 0 5.65e-08
let nn = length(time)
let idpk = maximum(@m.xrio.xmcl.msky130_fd_pr__nfet_g5v0d10v5[id])
let vgpk = maximum(v(xrio.gate))
let ilk = -i(Vr_io)[nn-1]
let ipk = maximum(abs(i(Vr_io)))
echo "RESULT ramp_io_6.5u vnom=5.0 tr_s=6.5u id_xmcl_pk_A=$&idpk gate_pk_V=$&vgpk isup_pk_A=$&ipk ileak_end_A=$&ilk"
let pvds = maximum(abs(v(xrio.g1) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.t) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_6.5u_mp1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g1) - 0))
let pvgs = maximum(abs(v(xrio.t) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_6.5u_mn1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g2) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.g1) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_6.5u_mp2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g2) - 0))
let pvgs = maximum(abs(v(xrio.g1) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_6.5u_mn2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.gate) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.g2) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_6.5u_mp3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.gate) - 0))
let pvgs = maximum(abs(v(xrio.g2) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_6.5u_mn3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(vr_io) - 0))
let pvgs = maximum(abs(v(xrio.gate) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_6.5u_mcl vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let idpk = maximum(@m.xrcore.xmcl.msky130_fd_pr__nfet_01v8[id])
let vgpk = maximum(v(xrcore.gate))
let ilk = -i(Vr_core)[nn-1]
let ipk = maximum(abs(i(Vr_core)))
echo "RESULT ramp_core_6.5u vnom=1.8 tr_s=6.5u id_xmcl_pk_A=$&idpk gate_pk_V=$&vgpk isup_pk_A=$&ipk ileak_end_A=$&ilk"
let pvds = maximum(abs(v(xrcore.g1) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.t) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_6.5u_mp1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g1) - 0))
let pvgs = maximum(abs(v(xrcore.t) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_6.5u_mn1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g2) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.g1) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_6.5u_mp2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g2) - 0))
let pvgs = maximum(abs(v(xrcore.g1) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_6.5u_mn2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.gate) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.g2) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_6.5u_mp3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.gate) - 0))
let pvgs = maximum(abs(v(xrcore.g2) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_6.5u_mn3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(vr_core) - 0))
let pvgs = maximum(abs(v(xrcore.gate) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_6.5u_mcl vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
alter Vr_io pulse = [ 0 5.0 0 6.75u 1 1 1 ]
alter Vr_core pulse = [ 0 1.8 0 6.75u 1 1 1 ]
tran 1.419e-08 5.675e-05 0 5.675e-08
let nn = length(time)
let idpk = maximum(@m.xrio.xmcl.msky130_fd_pr__nfet_g5v0d10v5[id])
let vgpk = maximum(v(xrio.gate))
let ilk = -i(Vr_io)[nn-1]
let ipk = maximum(abs(i(Vr_io)))
echo "RESULT ramp_io_6.75u vnom=5.0 tr_s=6.75u id_xmcl_pk_A=$&idpk gate_pk_V=$&vgpk isup_pk_A=$&ipk ileak_end_A=$&ilk"
let pvds = maximum(abs(v(xrio.g1) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.t) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_6.75u_mp1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g1) - 0))
let pvgs = maximum(abs(v(xrio.t) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_6.75u_mn1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g2) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.g1) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_6.75u_mp2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g2) - 0))
let pvgs = maximum(abs(v(xrio.g1) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_6.75u_mn2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.gate) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.g2) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_6.75u_mp3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.gate) - 0))
let pvgs = maximum(abs(v(xrio.g2) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_6.75u_mn3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(vr_io) - 0))
let pvgs = maximum(abs(v(xrio.gate) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_6.75u_mcl vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let idpk = maximum(@m.xrcore.xmcl.msky130_fd_pr__nfet_01v8[id])
let vgpk = maximum(v(xrcore.gate))
let ilk = -i(Vr_core)[nn-1]
let ipk = maximum(abs(i(Vr_core)))
echo "RESULT ramp_core_6.75u vnom=1.8 tr_s=6.75u id_xmcl_pk_A=$&idpk gate_pk_V=$&vgpk isup_pk_A=$&ipk ileak_end_A=$&ilk"
let pvds = maximum(abs(v(xrcore.g1) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.t) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_6.75u_mp1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g1) - 0))
let pvgs = maximum(abs(v(xrcore.t) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_6.75u_mn1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g2) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.g1) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_6.75u_mp2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g2) - 0))
let pvgs = maximum(abs(v(xrcore.g1) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_6.75u_mn2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.gate) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.g2) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_6.75u_mp3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.gate) - 0))
let pvgs = maximum(abs(v(xrcore.g2) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_6.75u_mn3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(vr_core) - 0))
let pvgs = maximum(abs(v(xrcore.gate) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_6.75u_mcl vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
alter Vr_io pulse = [ 0 5.0 0 7u 1 1 1 ]
alter Vr_core pulse = [ 0 1.8 0 7u 1 1 1 ]
tran 1.425e-08 5.7e-05 0 5.7e-08
let nn = length(time)
let idpk = maximum(@m.xrio.xmcl.msky130_fd_pr__nfet_g5v0d10v5[id])
let vgpk = maximum(v(xrio.gate))
let ilk = -i(Vr_io)[nn-1]
let ipk = maximum(abs(i(Vr_io)))
echo "RESULT ramp_io_7u vnom=5.0 tr_s=7u id_xmcl_pk_A=$&idpk gate_pk_V=$&vgpk isup_pk_A=$&ipk ileak_end_A=$&ilk"
let pvds = maximum(abs(v(xrio.g1) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.t) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_7u_mp1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g1) - 0))
let pvgs = maximum(abs(v(xrio.t) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_7u_mn1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g2) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.g1) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_7u_mp2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g2) - 0))
let pvgs = maximum(abs(v(xrio.g1) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_7u_mn2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.gate) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.g2) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_7u_mp3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.gate) - 0))
let pvgs = maximum(abs(v(xrio.g2) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_7u_mn3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(vr_io) - 0))
let pvgs = maximum(abs(v(xrio.gate) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_7u_mcl vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let idpk = maximum(@m.xrcore.xmcl.msky130_fd_pr__nfet_01v8[id])
let vgpk = maximum(v(xrcore.gate))
let ilk = -i(Vr_core)[nn-1]
let ipk = maximum(abs(i(Vr_core)))
echo "RESULT ramp_core_7u vnom=1.8 tr_s=7u id_xmcl_pk_A=$&idpk gate_pk_V=$&vgpk isup_pk_A=$&ipk ileak_end_A=$&ilk"
let pvds = maximum(abs(v(xrcore.g1) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.t) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_7u_mp1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g1) - 0))
let pvgs = maximum(abs(v(xrcore.t) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_7u_mn1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g2) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.g1) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_7u_mp2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g2) - 0))
let pvgs = maximum(abs(v(xrcore.g1) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_7u_mn2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.gate) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.g2) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_7u_mp3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.gate) - 0))
let pvgs = maximum(abs(v(xrcore.g2) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_7u_mn3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(vr_core) - 0))
let pvgs = maximum(abs(v(xrcore.gate) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_7u_mcl vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
alter Vr_io pulse = [ 0 5.0 0 7.25u 1 1 1 ]
alter Vr_core pulse = [ 0 1.8 0 7.25u 1 1 1 ]
tran 1.431e-08 5.725e-05 0 5.725e-08
let nn = length(time)
let idpk = maximum(@m.xrio.xmcl.msky130_fd_pr__nfet_g5v0d10v5[id])
let vgpk = maximum(v(xrio.gate))
let ilk = -i(Vr_io)[nn-1]
let ipk = maximum(abs(i(Vr_io)))
echo "RESULT ramp_io_7.25u vnom=5.0 tr_s=7.25u id_xmcl_pk_A=$&idpk gate_pk_V=$&vgpk isup_pk_A=$&ipk ileak_end_A=$&ilk"
let pvds = maximum(abs(v(xrio.g1) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.t) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_7.25u_mp1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g1) - 0))
let pvgs = maximum(abs(v(xrio.t) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_7.25u_mn1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g2) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.g1) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_7.25u_mp2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g2) - 0))
let pvgs = maximum(abs(v(xrio.g1) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_7.25u_mn2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.gate) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.g2) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_7.25u_mp3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.gate) - 0))
let pvgs = maximum(abs(v(xrio.g2) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_7.25u_mn3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(vr_io) - 0))
let pvgs = maximum(abs(v(xrio.gate) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_7.25u_mcl vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let idpk = maximum(@m.xrcore.xmcl.msky130_fd_pr__nfet_01v8[id])
let vgpk = maximum(v(xrcore.gate))
let ilk = -i(Vr_core)[nn-1]
let ipk = maximum(abs(i(Vr_core)))
echo "RESULT ramp_core_7.25u vnom=1.8 tr_s=7.25u id_xmcl_pk_A=$&idpk gate_pk_V=$&vgpk isup_pk_A=$&ipk ileak_end_A=$&ilk"
let pvds = maximum(abs(v(xrcore.g1) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.t) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_7.25u_mp1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g1) - 0))
let pvgs = maximum(abs(v(xrcore.t) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_7.25u_mn1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g2) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.g1) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_7.25u_mp2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g2) - 0))
let pvgs = maximum(abs(v(xrcore.g1) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_7.25u_mn2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.gate) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.g2) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_7.25u_mp3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.gate) - 0))
let pvgs = maximum(abs(v(xrcore.g2) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_7.25u_mn3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(vr_core) - 0))
let pvgs = maximum(abs(v(xrcore.gate) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_7.25u_mcl vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
alter Vr_io pulse = [ 0 5.0 0 7.5u 1 1 1 ]
alter Vr_core pulse = [ 0 1.8 0 7.5u 1 1 1 ]
tran 1.437e-08 5.75e-05 0 5.75e-08
let nn = length(time)
let idpk = maximum(@m.xrio.xmcl.msky130_fd_pr__nfet_g5v0d10v5[id])
let vgpk = maximum(v(xrio.gate))
let ilk = -i(Vr_io)[nn-1]
let ipk = maximum(abs(i(Vr_io)))
echo "RESULT ramp_io_7.5u vnom=5.0 tr_s=7.5u id_xmcl_pk_A=$&idpk gate_pk_V=$&vgpk isup_pk_A=$&ipk ileak_end_A=$&ilk"
let pvds = maximum(abs(v(xrio.g1) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.t) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_7.5u_mp1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g1) - 0))
let pvgs = maximum(abs(v(xrio.t) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_7.5u_mn1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g2) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.g1) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_7.5u_mp2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g2) - 0))
let pvgs = maximum(abs(v(xrio.g1) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_7.5u_mn2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.gate) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.g2) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_7.5u_mp3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.gate) - 0))
let pvgs = maximum(abs(v(xrio.g2) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_7.5u_mn3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(vr_io) - 0))
let pvgs = maximum(abs(v(xrio.gate) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_7.5u_mcl vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let idpk = maximum(@m.xrcore.xmcl.msky130_fd_pr__nfet_01v8[id])
let vgpk = maximum(v(xrcore.gate))
let ilk = -i(Vr_core)[nn-1]
let ipk = maximum(abs(i(Vr_core)))
echo "RESULT ramp_core_7.5u vnom=1.8 tr_s=7.5u id_xmcl_pk_A=$&idpk gate_pk_V=$&vgpk isup_pk_A=$&ipk ileak_end_A=$&ilk"
let pvds = maximum(abs(v(xrcore.g1) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.t) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_7.5u_mp1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g1) - 0))
let pvgs = maximum(abs(v(xrcore.t) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_7.5u_mn1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g2) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.g1) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_7.5u_mp2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g2) - 0))
let pvgs = maximum(abs(v(xrcore.g1) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_7.5u_mn2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.gate) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.g2) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_7.5u_mp3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.gate) - 0))
let pvgs = maximum(abs(v(xrcore.g2) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_7.5u_mn3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(vr_core) - 0))
let pvgs = maximum(abs(v(xrcore.gate) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_7.5u_mcl vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
alter Vr_io pulse = [ 0 5.0 0 7.75u 1 1 1 ]
alter Vr_core pulse = [ 0 1.8 0 7.75u 1 1 1 ]
tran 1.444e-08 5.775e-05 0 5.775e-08
let nn = length(time)
let idpk = maximum(@m.xrio.xmcl.msky130_fd_pr__nfet_g5v0d10v5[id])
let vgpk = maximum(v(xrio.gate))
let ilk = -i(Vr_io)[nn-1]
let ipk = maximum(abs(i(Vr_io)))
echo "RESULT ramp_io_7.75u vnom=5.0 tr_s=7.75u id_xmcl_pk_A=$&idpk gate_pk_V=$&vgpk isup_pk_A=$&ipk ileak_end_A=$&ilk"
let pvds = maximum(abs(v(xrio.g1) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.t) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_7.75u_mp1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g1) - 0))
let pvgs = maximum(abs(v(xrio.t) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_7.75u_mn1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g2) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.g1) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_7.75u_mp2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g2) - 0))
let pvgs = maximum(abs(v(xrio.g1) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_7.75u_mn2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.gate) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.g2) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_7.75u_mp3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.gate) - 0))
let pvgs = maximum(abs(v(xrio.g2) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_7.75u_mn3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(vr_io) - 0))
let pvgs = maximum(abs(v(xrio.gate) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_7.75u_mcl vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let idpk = maximum(@m.xrcore.xmcl.msky130_fd_pr__nfet_01v8[id])
let vgpk = maximum(v(xrcore.gate))
let ilk = -i(Vr_core)[nn-1]
let ipk = maximum(abs(i(Vr_core)))
echo "RESULT ramp_core_7.75u vnom=1.8 tr_s=7.75u id_xmcl_pk_A=$&idpk gate_pk_V=$&vgpk isup_pk_A=$&ipk ileak_end_A=$&ilk"
let pvds = maximum(abs(v(xrcore.g1) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.t) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_7.75u_mp1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g1) - 0))
let pvgs = maximum(abs(v(xrcore.t) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_7.75u_mn1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g2) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.g1) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_7.75u_mp2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g2) - 0))
let pvgs = maximum(abs(v(xrcore.g1) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_7.75u_mn2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.gate) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.g2) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_7.75u_mp3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.gate) - 0))
let pvgs = maximum(abs(v(xrcore.g2) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_7.75u_mn3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(vr_core) - 0))
let pvgs = maximum(abs(v(xrcore.gate) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_7.75u_mcl vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
alter Vr_io pulse = [ 0 5.0 0 8u 1 1 1 ]
alter Vr_core pulse = [ 0 1.8 0 8u 1 1 1 ]
tran 1.45e-08 5.8e-05 0 5.8e-08
let nn = length(time)
let idpk = maximum(@m.xrio.xmcl.msky130_fd_pr__nfet_g5v0d10v5[id])
let vgpk = maximum(v(xrio.gate))
let ilk = -i(Vr_io)[nn-1]
let ipk = maximum(abs(i(Vr_io)))
echo "RESULT ramp_io_8u vnom=5.0 tr_s=8u id_xmcl_pk_A=$&idpk gate_pk_V=$&vgpk isup_pk_A=$&ipk ileak_end_A=$&ilk"
let pvds = maximum(abs(v(xrio.g1) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.t) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_8u_mp1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g1) - 0))
let pvgs = maximum(abs(v(xrio.t) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_8u_mn1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g2) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.g1) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_8u_mp2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g2) - 0))
let pvgs = maximum(abs(v(xrio.g1) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_8u_mn2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.gate) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.g2) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_8u_mp3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.gate) - 0))
let pvgs = maximum(abs(v(xrio.g2) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_8u_mn3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(vr_io) - 0))
let pvgs = maximum(abs(v(xrio.gate) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_8u_mcl vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let idpk = maximum(@m.xrcore.xmcl.msky130_fd_pr__nfet_01v8[id])
let vgpk = maximum(v(xrcore.gate))
let ilk = -i(Vr_core)[nn-1]
let ipk = maximum(abs(i(Vr_core)))
echo "RESULT ramp_core_8u vnom=1.8 tr_s=8u id_xmcl_pk_A=$&idpk gate_pk_V=$&vgpk isup_pk_A=$&ipk ileak_end_A=$&ilk"
let pvds = maximum(abs(v(xrcore.g1) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.t) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_8u_mp1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g1) - 0))
let pvgs = maximum(abs(v(xrcore.t) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_8u_mn1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g2) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.g1) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_8u_mp2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g2) - 0))
let pvgs = maximum(abs(v(xrcore.g1) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_8u_mn2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.gate) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.g2) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_8u_mp3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.gate) - 0))
let pvgs = maximum(abs(v(xrcore.g2) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_8u_mn3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(vr_core) - 0))
let pvgs = maximum(abs(v(xrcore.gate) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_8u_mcl vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
alter Vr_io pulse = [ 0 5.0 0 9u 1 1 1 ]
alter Vr_core pulse = [ 0 1.8 0 9u 1 1 1 ]
tran 1.475e-08 5.9e-05 0 5.9e-08
let nn = length(time)
let idpk = maximum(@m.xrio.xmcl.msky130_fd_pr__nfet_g5v0d10v5[id])
let vgpk = maximum(v(xrio.gate))
let ilk = -i(Vr_io)[nn-1]
let ipk = maximum(abs(i(Vr_io)))
echo "RESULT ramp_io_9u vnom=5.0 tr_s=9u id_xmcl_pk_A=$&idpk gate_pk_V=$&vgpk isup_pk_A=$&ipk ileak_end_A=$&ilk"
let pvds = maximum(abs(v(xrio.g1) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.t) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_9u_mp1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g1) - 0))
let pvgs = maximum(abs(v(xrio.t) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_9u_mn1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g2) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.g1) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_9u_mp2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.g2) - 0))
let pvgs = maximum(abs(v(xrio.g1) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_9u_mn2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.gate) - v(vr_io)))
let pvgs = maximum(abs(v(xrio.g2) - v(vr_io)))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_9u_mp3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrio.gate) - 0))
let pvgs = maximum(abs(v(xrio.g2) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_9u_mn3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(vr_io) - 0))
let pvgs = maximum(abs(v(xrio.gate) - 0))
if ( pvds > 11.0 | pvgs > 5.5 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
echo "RESULT esd7_ramp_io_9u_mcl vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let idpk = maximum(@m.xrcore.xmcl.msky130_fd_pr__nfet_01v8[id])
let vgpk = maximum(v(xrcore.gate))
let ilk = -i(Vr_core)[nn-1]
let ipk = maximum(abs(i(Vr_core)))
echo "RESULT ramp_core_9u vnom=1.8 tr_s=9u id_xmcl_pk_A=$&idpk gate_pk_V=$&vgpk isup_pk_A=$&ipk ileak_end_A=$&ilk"
let pvds = maximum(abs(v(xrcore.g1) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.t) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_9u_mp1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g1) - 0))
let pvgs = maximum(abs(v(xrcore.t) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_9u_mn1 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g2) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.g1) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_9u_mp2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.g2) - 0))
let pvgs = maximum(abs(v(xrcore.g1) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_9u_mn2 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.gate) - v(vr_core)))
let pvgs = maximum(abs(v(xrcore.g2) - v(vr_core)))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_9u_mp3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(xrcore.gate) - 0))
let pvgs = maximum(abs(v(xrcore.g2) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_9u_mn3 vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
let pvds = maximum(abs(v(vr_core) - 0))
let pvgs = maximum(abs(v(xrcore.gate) - 0))
set lab = no_validity_range_on_record
echo "RESULT esd7_ramp_core_9u_mcl vds_pk_V=$&pvds vgs_pk_V=$&pvgs validity=$lab"
alter Vr_io pulse = [ 0 5.0 0 10u 1 1 1 ]
alter Vr_core pulse = [ 0 1.8 0 10u 1 1 1 ]
tran 1.5e-08 6e-05 0 6e-08
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
alter Vr_io pulse = [ 0 5.0 0 1u 1 1 1 ]
alter Vr_core pulse = [ 0 1.8 0 1u 1 1 1 ]
tran 50n 1.01m 0 50n
let nn = length(time)
let ilke = -i(Vr_io)[nn-1]
echo "RESULT settle_tmax50n_io_end tstep_s=50n tmax_s=50n tol=default t_s=1.01m ileak_A=$&ilke"
meas tran i_io find i(Vr_io) at=2u
meas tran vp_io find v(vr_io) at=2u
meas tran t1_io find v(xrio.t1) at=2u
meas tran tt_io find v(xrio.t) at=2u
meas tran g1_io find v(xrio.g1) at=2u
meas tran g2_io find v(xrio.g2) at=2u
meas tran ga_io find v(xrio.gate) at=2u
let ilkt = -i_io
echo "RESULT settle_tmax50n_io_t2u tstep_s=50n tmax_s=50n tol=default t_s=2u ileak_A=$&ilkt vp_V=$&vp_io t1_V=$&t1_io t_V=$&tt_io g1_V=$&g1_io g2_V=$&g2_io gate_V=$&ga_io"
meas tran i_io find i(Vr_io) at=5u
meas tran vp_io find v(vr_io) at=5u
meas tran t1_io find v(xrio.t1) at=5u
meas tran tt_io find v(xrio.t) at=5u
meas tran g1_io find v(xrio.g1) at=5u
meas tran g2_io find v(xrio.g2) at=5u
meas tran ga_io find v(xrio.gate) at=5u
let ilkt = -i_io
echo "RESULT settle_tmax50n_io_t5u tstep_s=50n tmax_s=50n tol=default t_s=5u ileak_A=$&ilkt vp_V=$&vp_io t1_V=$&t1_io t_V=$&tt_io g1_V=$&g1_io g2_V=$&g2_io gate_V=$&ga_io"
meas tran i_io find i(Vr_io) at=10u
meas tran vp_io find v(vr_io) at=10u
meas tran t1_io find v(xrio.t1) at=10u
meas tran tt_io find v(xrio.t) at=10u
meas tran g1_io find v(xrio.g1) at=10u
meas tran g2_io find v(xrio.g2) at=10u
meas tran ga_io find v(xrio.gate) at=10u
let ilkt = -i_io
echo "RESULT settle_tmax50n_io_t10u tstep_s=50n tmax_s=50n tol=default t_s=10u ileak_A=$&ilkt vp_V=$&vp_io t1_V=$&t1_io t_V=$&tt_io g1_V=$&g1_io g2_V=$&g2_io gate_V=$&ga_io"
meas tran i_io find i(Vr_io) at=20u
meas tran vp_io find v(vr_io) at=20u
meas tran t1_io find v(xrio.t1) at=20u
meas tran tt_io find v(xrio.t) at=20u
meas tran g1_io find v(xrio.g1) at=20u
meas tran g2_io find v(xrio.g2) at=20u
meas tran ga_io find v(xrio.gate) at=20u
let ilkt = -i_io
echo "RESULT settle_tmax50n_io_t20u tstep_s=50n tmax_s=50n tol=default t_s=20u ileak_A=$&ilkt vp_V=$&vp_io t1_V=$&t1_io t_V=$&tt_io g1_V=$&g1_io g2_V=$&g2_io gate_V=$&ga_io"
meas tran i_io find i(Vr_io) at=51u
meas tran vp_io find v(vr_io) at=51u
meas tran t1_io find v(xrio.t1) at=51u
meas tran tt_io find v(xrio.t) at=51u
meas tran g1_io find v(xrio.g1) at=51u
meas tran g2_io find v(xrio.g2) at=51u
meas tran ga_io find v(xrio.gate) at=51u
let ilkt = -i_io
echo "RESULT settle_tmax50n_io_t51u tstep_s=50n tmax_s=50n tol=default t_s=51u ileak_A=$&ilkt vp_V=$&vp_io t1_V=$&t1_io t_V=$&tt_io g1_V=$&g1_io g2_V=$&g2_io gate_V=$&ga_io"
meas tran i_io find i(Vr_io) at=60u
meas tran vp_io find v(vr_io) at=60u
meas tran t1_io find v(xrio.t1) at=60u
meas tran tt_io find v(xrio.t) at=60u
meas tran g1_io find v(xrio.g1) at=60u
meas tran g2_io find v(xrio.g2) at=60u
meas tran ga_io find v(xrio.gate) at=60u
let ilkt = -i_io
echo "RESULT settle_tmax50n_io_t60u tstep_s=50n tmax_s=50n tol=default t_s=60u ileak_A=$&ilkt vp_V=$&vp_io t1_V=$&t1_io t_V=$&tt_io g1_V=$&g1_io g2_V=$&g2_io gate_V=$&ga_io"
meas tran i_io find i(Vr_io) at=100u
meas tran vp_io find v(vr_io) at=100u
meas tran t1_io find v(xrio.t1) at=100u
meas tran tt_io find v(xrio.t) at=100u
meas tran g1_io find v(xrio.g1) at=100u
meas tran g2_io find v(xrio.g2) at=100u
meas tran ga_io find v(xrio.gate) at=100u
let ilkt = -i_io
echo "RESULT settle_tmax50n_io_t100u tstep_s=50n tmax_s=50n tol=default t_s=100u ileak_A=$&ilkt vp_V=$&vp_io t1_V=$&t1_io t_V=$&tt_io g1_V=$&g1_io g2_V=$&g2_io gate_V=$&ga_io"
meas tran i_io find i(Vr_io) at=200u
meas tran vp_io find v(vr_io) at=200u
meas tran t1_io find v(xrio.t1) at=200u
meas tran tt_io find v(xrio.t) at=200u
meas tran g1_io find v(xrio.g1) at=200u
meas tran g2_io find v(xrio.g2) at=200u
meas tran ga_io find v(xrio.gate) at=200u
let ilkt = -i_io
echo "RESULT settle_tmax50n_io_t200u tstep_s=50n tmax_s=50n tol=default t_s=200u ileak_A=$&ilkt vp_V=$&vp_io t1_V=$&t1_io t_V=$&tt_io g1_V=$&g1_io g2_V=$&g2_io gate_V=$&ga_io"
meas tran i_io find i(Vr_io) at=300u
meas tran vp_io find v(vr_io) at=300u
meas tran t1_io find v(xrio.t1) at=300u
meas tran tt_io find v(xrio.t) at=300u
meas tran g1_io find v(xrio.g1) at=300u
meas tran g2_io find v(xrio.g2) at=300u
meas tran ga_io find v(xrio.gate) at=300u
let ilkt = -i_io
echo "RESULT settle_tmax50n_io_t300u tstep_s=50n tmax_s=50n tol=default t_s=300u ileak_A=$&ilkt vp_V=$&vp_io t1_V=$&t1_io t_V=$&tt_io g1_V=$&g1_io g2_V=$&g2_io gate_V=$&ga_io"
meas tran i_io find i(Vr_io) at=500u
meas tran vp_io find v(vr_io) at=500u
meas tran t1_io find v(xrio.t1) at=500u
meas tran tt_io find v(xrio.t) at=500u
meas tran g1_io find v(xrio.g1) at=500u
meas tran g2_io find v(xrio.g2) at=500u
meas tran ga_io find v(xrio.gate) at=500u
let ilkt = -i_io
echo "RESULT settle_tmax50n_io_t500u tstep_s=50n tmax_s=50n tol=default t_s=500u ileak_A=$&ilkt vp_V=$&vp_io t1_V=$&t1_io t_V=$&tt_io g1_V=$&g1_io g2_V=$&g2_io gate_V=$&ga_io"
meas tran i_io find i(Vr_io) at=700u
meas tran vp_io find v(vr_io) at=700u
meas tran t1_io find v(xrio.t1) at=700u
meas tran tt_io find v(xrio.t) at=700u
meas tran g1_io find v(xrio.g1) at=700u
meas tran g2_io find v(xrio.g2) at=700u
meas tran ga_io find v(xrio.gate) at=700u
let ilkt = -i_io
echo "RESULT settle_tmax50n_io_t700u tstep_s=50n tmax_s=50n tol=default t_s=700u ileak_A=$&ilkt vp_V=$&vp_io t1_V=$&t1_io t_V=$&tt_io g1_V=$&g1_io g2_V=$&g2_io gate_V=$&ga_io"
meas tran i_io find i(Vr_io) at=1000u
meas tran vp_io find v(vr_io) at=1000u
meas tran t1_io find v(xrio.t1) at=1000u
meas tran tt_io find v(xrio.t) at=1000u
meas tran g1_io find v(xrio.g1) at=1000u
meas tran g2_io find v(xrio.g2) at=1000u
meas tran ga_io find v(xrio.gate) at=1000u
let ilkt = -i_io
echo "RESULT settle_tmax50n_io_t1000u tstep_s=50n tmax_s=50n tol=default t_s=1000u ileak_A=$&ilkt vp_V=$&vp_io t1_V=$&t1_io t_V=$&tt_io g1_V=$&g1_io g2_V=$&g2_io gate_V=$&ga_io"
let nn = length(time)
let ilke = -i(Vr_core)[nn-1]
echo "RESULT settle_tmax50n_core_end tstep_s=50n tmax_s=50n tol=default t_s=1.01m ileak_A=$&ilke"
meas tran i_core find i(Vr_core) at=2u
meas tran vp_core find v(vr_core) at=2u
meas tran t1_core find v(xrcore.t1) at=2u
meas tran tt_core find v(xrcore.t) at=2u
meas tran g1_core find v(xrcore.g1) at=2u
meas tran g2_core find v(xrcore.g2) at=2u
meas tran ga_core find v(xrcore.gate) at=2u
let ilkt = -i_core
echo "RESULT settle_tmax50n_core_t2u tstep_s=50n tmax_s=50n tol=default t_s=2u ileak_A=$&ilkt vp_V=$&vp_core t1_V=$&t1_core t_V=$&tt_core g1_V=$&g1_core g2_V=$&g2_core gate_V=$&ga_core"
meas tran i_core find i(Vr_core) at=5u
meas tran vp_core find v(vr_core) at=5u
meas tran t1_core find v(xrcore.t1) at=5u
meas tran tt_core find v(xrcore.t) at=5u
meas tran g1_core find v(xrcore.g1) at=5u
meas tran g2_core find v(xrcore.g2) at=5u
meas tran ga_core find v(xrcore.gate) at=5u
let ilkt = -i_core
echo "RESULT settle_tmax50n_core_t5u tstep_s=50n tmax_s=50n tol=default t_s=5u ileak_A=$&ilkt vp_V=$&vp_core t1_V=$&t1_core t_V=$&tt_core g1_V=$&g1_core g2_V=$&g2_core gate_V=$&ga_core"
meas tran i_core find i(Vr_core) at=10u
meas tran vp_core find v(vr_core) at=10u
meas tran t1_core find v(xrcore.t1) at=10u
meas tran tt_core find v(xrcore.t) at=10u
meas tran g1_core find v(xrcore.g1) at=10u
meas tran g2_core find v(xrcore.g2) at=10u
meas tran ga_core find v(xrcore.gate) at=10u
let ilkt = -i_core
echo "RESULT settle_tmax50n_core_t10u tstep_s=50n tmax_s=50n tol=default t_s=10u ileak_A=$&ilkt vp_V=$&vp_core t1_V=$&t1_core t_V=$&tt_core g1_V=$&g1_core g2_V=$&g2_core gate_V=$&ga_core"
meas tran i_core find i(Vr_core) at=20u
meas tran vp_core find v(vr_core) at=20u
meas tran t1_core find v(xrcore.t1) at=20u
meas tran tt_core find v(xrcore.t) at=20u
meas tran g1_core find v(xrcore.g1) at=20u
meas tran g2_core find v(xrcore.g2) at=20u
meas tran ga_core find v(xrcore.gate) at=20u
let ilkt = -i_core
echo "RESULT settle_tmax50n_core_t20u tstep_s=50n tmax_s=50n tol=default t_s=20u ileak_A=$&ilkt vp_V=$&vp_core t1_V=$&t1_core t_V=$&tt_core g1_V=$&g1_core g2_V=$&g2_core gate_V=$&ga_core"
meas tran i_core find i(Vr_core) at=51u
meas tran vp_core find v(vr_core) at=51u
meas tran t1_core find v(xrcore.t1) at=51u
meas tran tt_core find v(xrcore.t) at=51u
meas tran g1_core find v(xrcore.g1) at=51u
meas tran g2_core find v(xrcore.g2) at=51u
meas tran ga_core find v(xrcore.gate) at=51u
let ilkt = -i_core
echo "RESULT settle_tmax50n_core_t51u tstep_s=50n tmax_s=50n tol=default t_s=51u ileak_A=$&ilkt vp_V=$&vp_core t1_V=$&t1_core t_V=$&tt_core g1_V=$&g1_core g2_V=$&g2_core gate_V=$&ga_core"
meas tran i_core find i(Vr_core) at=60u
meas tran vp_core find v(vr_core) at=60u
meas tran t1_core find v(xrcore.t1) at=60u
meas tran tt_core find v(xrcore.t) at=60u
meas tran g1_core find v(xrcore.g1) at=60u
meas tran g2_core find v(xrcore.g2) at=60u
meas tran ga_core find v(xrcore.gate) at=60u
let ilkt = -i_core
echo "RESULT settle_tmax50n_core_t60u tstep_s=50n tmax_s=50n tol=default t_s=60u ileak_A=$&ilkt vp_V=$&vp_core t1_V=$&t1_core t_V=$&tt_core g1_V=$&g1_core g2_V=$&g2_core gate_V=$&ga_core"
meas tran i_core find i(Vr_core) at=100u
meas tran vp_core find v(vr_core) at=100u
meas tran t1_core find v(xrcore.t1) at=100u
meas tran tt_core find v(xrcore.t) at=100u
meas tran g1_core find v(xrcore.g1) at=100u
meas tran g2_core find v(xrcore.g2) at=100u
meas tran ga_core find v(xrcore.gate) at=100u
let ilkt = -i_core
echo "RESULT settle_tmax50n_core_t100u tstep_s=50n tmax_s=50n tol=default t_s=100u ileak_A=$&ilkt vp_V=$&vp_core t1_V=$&t1_core t_V=$&tt_core g1_V=$&g1_core g2_V=$&g2_core gate_V=$&ga_core"
meas tran i_core find i(Vr_core) at=200u
meas tran vp_core find v(vr_core) at=200u
meas tran t1_core find v(xrcore.t1) at=200u
meas tran tt_core find v(xrcore.t) at=200u
meas tran g1_core find v(xrcore.g1) at=200u
meas tran g2_core find v(xrcore.g2) at=200u
meas tran ga_core find v(xrcore.gate) at=200u
let ilkt = -i_core
echo "RESULT settle_tmax50n_core_t200u tstep_s=50n tmax_s=50n tol=default t_s=200u ileak_A=$&ilkt vp_V=$&vp_core t1_V=$&t1_core t_V=$&tt_core g1_V=$&g1_core g2_V=$&g2_core gate_V=$&ga_core"
meas tran i_core find i(Vr_core) at=300u
meas tran vp_core find v(vr_core) at=300u
meas tran t1_core find v(xrcore.t1) at=300u
meas tran tt_core find v(xrcore.t) at=300u
meas tran g1_core find v(xrcore.g1) at=300u
meas tran g2_core find v(xrcore.g2) at=300u
meas tran ga_core find v(xrcore.gate) at=300u
let ilkt = -i_core
echo "RESULT settle_tmax50n_core_t300u tstep_s=50n tmax_s=50n tol=default t_s=300u ileak_A=$&ilkt vp_V=$&vp_core t1_V=$&t1_core t_V=$&tt_core g1_V=$&g1_core g2_V=$&g2_core gate_V=$&ga_core"
meas tran i_core find i(Vr_core) at=500u
meas tran vp_core find v(vr_core) at=500u
meas tran t1_core find v(xrcore.t1) at=500u
meas tran tt_core find v(xrcore.t) at=500u
meas tran g1_core find v(xrcore.g1) at=500u
meas tran g2_core find v(xrcore.g2) at=500u
meas tran ga_core find v(xrcore.gate) at=500u
let ilkt = -i_core
echo "RESULT settle_tmax50n_core_t500u tstep_s=50n tmax_s=50n tol=default t_s=500u ileak_A=$&ilkt vp_V=$&vp_core t1_V=$&t1_core t_V=$&tt_core g1_V=$&g1_core g2_V=$&g2_core gate_V=$&ga_core"
meas tran i_core find i(Vr_core) at=700u
meas tran vp_core find v(vr_core) at=700u
meas tran t1_core find v(xrcore.t1) at=700u
meas tran tt_core find v(xrcore.t) at=700u
meas tran g1_core find v(xrcore.g1) at=700u
meas tran g2_core find v(xrcore.g2) at=700u
meas tran ga_core find v(xrcore.gate) at=700u
let ilkt = -i_core
echo "RESULT settle_tmax50n_core_t700u tstep_s=50n tmax_s=50n tol=default t_s=700u ileak_A=$&ilkt vp_V=$&vp_core t1_V=$&t1_core t_V=$&tt_core g1_V=$&g1_core g2_V=$&g2_core gate_V=$&ga_core"
meas tran i_core find i(Vr_core) at=1000u
meas tran vp_core find v(vr_core) at=1000u
meas tran t1_core find v(xrcore.t1) at=1000u
meas tran tt_core find v(xrcore.t) at=1000u
meas tran g1_core find v(xrcore.g1) at=1000u
meas tran g2_core find v(xrcore.g2) at=1000u
meas tran ga_core find v(xrcore.gate) at=1000u
let ilkt = -i_core
echo "RESULT settle_tmax50n_core_t1000u tstep_s=50n tmax_s=50n tol=default t_s=1000u ileak_A=$&ilkt vp_V=$&vp_core t1_V=$&t1_core t_V=$&tt_core g1_V=$&g1_core g2_V=$&g2_core gate_V=$&ga_core"
alter Vr_io pulse = [ 0 5.0 0 1u 1 1 1 ]
alter Vr_core pulse = [ 0 1.8 0 1u 1 1 1 ]
tran 250n 1.01m 0 510n
let nn = length(time)
let ilke = -i(Vr_io)[nn-1]
echo "RESULT settle_tmax510n_io_end tstep_s=250n tmax_s=510n tol=default t_s=1.01m ileak_A=$&ilke"
meas tran i_io find i(Vr_io) at=2u
meas tran vp_io find v(vr_io) at=2u
meas tran t1_io find v(xrio.t1) at=2u
meas tran tt_io find v(xrio.t) at=2u
meas tran g1_io find v(xrio.g1) at=2u
meas tran g2_io find v(xrio.g2) at=2u
meas tran ga_io find v(xrio.gate) at=2u
let ilkt = -i_io
echo "RESULT settle_tmax510n_io_t2u tstep_s=250n tmax_s=510n tol=default t_s=2u ileak_A=$&ilkt vp_V=$&vp_io t1_V=$&t1_io t_V=$&tt_io g1_V=$&g1_io g2_V=$&g2_io gate_V=$&ga_io"
meas tran i_io find i(Vr_io) at=5u
meas tran vp_io find v(vr_io) at=5u
meas tran t1_io find v(xrio.t1) at=5u
meas tran tt_io find v(xrio.t) at=5u
meas tran g1_io find v(xrio.g1) at=5u
meas tran g2_io find v(xrio.g2) at=5u
meas tran ga_io find v(xrio.gate) at=5u
let ilkt = -i_io
echo "RESULT settle_tmax510n_io_t5u tstep_s=250n tmax_s=510n tol=default t_s=5u ileak_A=$&ilkt vp_V=$&vp_io t1_V=$&t1_io t_V=$&tt_io g1_V=$&g1_io g2_V=$&g2_io gate_V=$&ga_io"
meas tran i_io find i(Vr_io) at=10u
meas tran vp_io find v(vr_io) at=10u
meas tran t1_io find v(xrio.t1) at=10u
meas tran tt_io find v(xrio.t) at=10u
meas tran g1_io find v(xrio.g1) at=10u
meas tran g2_io find v(xrio.g2) at=10u
meas tran ga_io find v(xrio.gate) at=10u
let ilkt = -i_io
echo "RESULT settle_tmax510n_io_t10u tstep_s=250n tmax_s=510n tol=default t_s=10u ileak_A=$&ilkt vp_V=$&vp_io t1_V=$&t1_io t_V=$&tt_io g1_V=$&g1_io g2_V=$&g2_io gate_V=$&ga_io"
meas tran i_io find i(Vr_io) at=20u
meas tran vp_io find v(vr_io) at=20u
meas tran t1_io find v(xrio.t1) at=20u
meas tran tt_io find v(xrio.t) at=20u
meas tran g1_io find v(xrio.g1) at=20u
meas tran g2_io find v(xrio.g2) at=20u
meas tran ga_io find v(xrio.gate) at=20u
let ilkt = -i_io
echo "RESULT settle_tmax510n_io_t20u tstep_s=250n tmax_s=510n tol=default t_s=20u ileak_A=$&ilkt vp_V=$&vp_io t1_V=$&t1_io t_V=$&tt_io g1_V=$&g1_io g2_V=$&g2_io gate_V=$&ga_io"
meas tran i_io find i(Vr_io) at=51u
meas tran vp_io find v(vr_io) at=51u
meas tran t1_io find v(xrio.t1) at=51u
meas tran tt_io find v(xrio.t) at=51u
meas tran g1_io find v(xrio.g1) at=51u
meas tran g2_io find v(xrio.g2) at=51u
meas tran ga_io find v(xrio.gate) at=51u
let ilkt = -i_io
echo "RESULT settle_tmax510n_io_t51u tstep_s=250n tmax_s=510n tol=default t_s=51u ileak_A=$&ilkt vp_V=$&vp_io t1_V=$&t1_io t_V=$&tt_io g1_V=$&g1_io g2_V=$&g2_io gate_V=$&ga_io"
meas tran i_io find i(Vr_io) at=60u
meas tran vp_io find v(vr_io) at=60u
meas tran t1_io find v(xrio.t1) at=60u
meas tran tt_io find v(xrio.t) at=60u
meas tran g1_io find v(xrio.g1) at=60u
meas tran g2_io find v(xrio.g2) at=60u
meas tran ga_io find v(xrio.gate) at=60u
let ilkt = -i_io
echo "RESULT settle_tmax510n_io_t60u tstep_s=250n tmax_s=510n tol=default t_s=60u ileak_A=$&ilkt vp_V=$&vp_io t1_V=$&t1_io t_V=$&tt_io g1_V=$&g1_io g2_V=$&g2_io gate_V=$&ga_io"
meas tran i_io find i(Vr_io) at=100u
meas tran vp_io find v(vr_io) at=100u
meas tran t1_io find v(xrio.t1) at=100u
meas tran tt_io find v(xrio.t) at=100u
meas tran g1_io find v(xrio.g1) at=100u
meas tran g2_io find v(xrio.g2) at=100u
meas tran ga_io find v(xrio.gate) at=100u
let ilkt = -i_io
echo "RESULT settle_tmax510n_io_t100u tstep_s=250n tmax_s=510n tol=default t_s=100u ileak_A=$&ilkt vp_V=$&vp_io t1_V=$&t1_io t_V=$&tt_io g1_V=$&g1_io g2_V=$&g2_io gate_V=$&ga_io"
meas tran i_io find i(Vr_io) at=200u
meas tran vp_io find v(vr_io) at=200u
meas tran t1_io find v(xrio.t1) at=200u
meas tran tt_io find v(xrio.t) at=200u
meas tran g1_io find v(xrio.g1) at=200u
meas tran g2_io find v(xrio.g2) at=200u
meas tran ga_io find v(xrio.gate) at=200u
let ilkt = -i_io
echo "RESULT settle_tmax510n_io_t200u tstep_s=250n tmax_s=510n tol=default t_s=200u ileak_A=$&ilkt vp_V=$&vp_io t1_V=$&t1_io t_V=$&tt_io g1_V=$&g1_io g2_V=$&g2_io gate_V=$&ga_io"
meas tran i_io find i(Vr_io) at=300u
meas tran vp_io find v(vr_io) at=300u
meas tran t1_io find v(xrio.t1) at=300u
meas tran tt_io find v(xrio.t) at=300u
meas tran g1_io find v(xrio.g1) at=300u
meas tran g2_io find v(xrio.g2) at=300u
meas tran ga_io find v(xrio.gate) at=300u
let ilkt = -i_io
echo "RESULT settle_tmax510n_io_t300u tstep_s=250n tmax_s=510n tol=default t_s=300u ileak_A=$&ilkt vp_V=$&vp_io t1_V=$&t1_io t_V=$&tt_io g1_V=$&g1_io g2_V=$&g2_io gate_V=$&ga_io"
meas tran i_io find i(Vr_io) at=500u
meas tran vp_io find v(vr_io) at=500u
meas tran t1_io find v(xrio.t1) at=500u
meas tran tt_io find v(xrio.t) at=500u
meas tran g1_io find v(xrio.g1) at=500u
meas tran g2_io find v(xrio.g2) at=500u
meas tran ga_io find v(xrio.gate) at=500u
let ilkt = -i_io
echo "RESULT settle_tmax510n_io_t500u tstep_s=250n tmax_s=510n tol=default t_s=500u ileak_A=$&ilkt vp_V=$&vp_io t1_V=$&t1_io t_V=$&tt_io g1_V=$&g1_io g2_V=$&g2_io gate_V=$&ga_io"
meas tran i_io find i(Vr_io) at=700u
meas tran vp_io find v(vr_io) at=700u
meas tran t1_io find v(xrio.t1) at=700u
meas tran tt_io find v(xrio.t) at=700u
meas tran g1_io find v(xrio.g1) at=700u
meas tran g2_io find v(xrio.g2) at=700u
meas tran ga_io find v(xrio.gate) at=700u
let ilkt = -i_io
echo "RESULT settle_tmax510n_io_t700u tstep_s=250n tmax_s=510n tol=default t_s=700u ileak_A=$&ilkt vp_V=$&vp_io t1_V=$&t1_io t_V=$&tt_io g1_V=$&g1_io g2_V=$&g2_io gate_V=$&ga_io"
meas tran i_io find i(Vr_io) at=1000u
meas tran vp_io find v(vr_io) at=1000u
meas tran t1_io find v(xrio.t1) at=1000u
meas tran tt_io find v(xrio.t) at=1000u
meas tran g1_io find v(xrio.g1) at=1000u
meas tran g2_io find v(xrio.g2) at=1000u
meas tran ga_io find v(xrio.gate) at=1000u
let ilkt = -i_io
echo "RESULT settle_tmax510n_io_t1000u tstep_s=250n tmax_s=510n tol=default t_s=1000u ileak_A=$&ilkt vp_V=$&vp_io t1_V=$&t1_io t_V=$&tt_io g1_V=$&g1_io g2_V=$&g2_io gate_V=$&ga_io"
let nn = length(time)
let ilke = -i(Vr_core)[nn-1]
echo "RESULT settle_tmax510n_core_end tstep_s=250n tmax_s=510n tol=default t_s=1.01m ileak_A=$&ilke"
meas tran i_core find i(Vr_core) at=2u
meas tran vp_core find v(vr_core) at=2u
meas tran t1_core find v(xrcore.t1) at=2u
meas tran tt_core find v(xrcore.t) at=2u
meas tran g1_core find v(xrcore.g1) at=2u
meas tran g2_core find v(xrcore.g2) at=2u
meas tran ga_core find v(xrcore.gate) at=2u
let ilkt = -i_core
echo "RESULT settle_tmax510n_core_t2u tstep_s=250n tmax_s=510n tol=default t_s=2u ileak_A=$&ilkt vp_V=$&vp_core t1_V=$&t1_core t_V=$&tt_core g1_V=$&g1_core g2_V=$&g2_core gate_V=$&ga_core"
meas tran i_core find i(Vr_core) at=5u
meas tran vp_core find v(vr_core) at=5u
meas tran t1_core find v(xrcore.t1) at=5u
meas tran tt_core find v(xrcore.t) at=5u
meas tran g1_core find v(xrcore.g1) at=5u
meas tran g2_core find v(xrcore.g2) at=5u
meas tran ga_core find v(xrcore.gate) at=5u
let ilkt = -i_core
echo "RESULT settle_tmax510n_core_t5u tstep_s=250n tmax_s=510n tol=default t_s=5u ileak_A=$&ilkt vp_V=$&vp_core t1_V=$&t1_core t_V=$&tt_core g1_V=$&g1_core g2_V=$&g2_core gate_V=$&ga_core"
meas tran i_core find i(Vr_core) at=10u
meas tran vp_core find v(vr_core) at=10u
meas tran t1_core find v(xrcore.t1) at=10u
meas tran tt_core find v(xrcore.t) at=10u
meas tran g1_core find v(xrcore.g1) at=10u
meas tran g2_core find v(xrcore.g2) at=10u
meas tran ga_core find v(xrcore.gate) at=10u
let ilkt = -i_core
echo "RESULT settle_tmax510n_core_t10u tstep_s=250n tmax_s=510n tol=default t_s=10u ileak_A=$&ilkt vp_V=$&vp_core t1_V=$&t1_core t_V=$&tt_core g1_V=$&g1_core g2_V=$&g2_core gate_V=$&ga_core"
meas tran i_core find i(Vr_core) at=20u
meas tran vp_core find v(vr_core) at=20u
meas tran t1_core find v(xrcore.t1) at=20u
meas tran tt_core find v(xrcore.t) at=20u
meas tran g1_core find v(xrcore.g1) at=20u
meas tran g2_core find v(xrcore.g2) at=20u
meas tran ga_core find v(xrcore.gate) at=20u
let ilkt = -i_core
echo "RESULT settle_tmax510n_core_t20u tstep_s=250n tmax_s=510n tol=default t_s=20u ileak_A=$&ilkt vp_V=$&vp_core t1_V=$&t1_core t_V=$&tt_core g1_V=$&g1_core g2_V=$&g2_core gate_V=$&ga_core"
meas tran i_core find i(Vr_core) at=51u
meas tran vp_core find v(vr_core) at=51u
meas tran t1_core find v(xrcore.t1) at=51u
meas tran tt_core find v(xrcore.t) at=51u
meas tran g1_core find v(xrcore.g1) at=51u
meas tran g2_core find v(xrcore.g2) at=51u
meas tran ga_core find v(xrcore.gate) at=51u
let ilkt = -i_core
echo "RESULT settle_tmax510n_core_t51u tstep_s=250n tmax_s=510n tol=default t_s=51u ileak_A=$&ilkt vp_V=$&vp_core t1_V=$&t1_core t_V=$&tt_core g1_V=$&g1_core g2_V=$&g2_core gate_V=$&ga_core"
meas tran i_core find i(Vr_core) at=60u
meas tran vp_core find v(vr_core) at=60u
meas tran t1_core find v(xrcore.t1) at=60u
meas tran tt_core find v(xrcore.t) at=60u
meas tran g1_core find v(xrcore.g1) at=60u
meas tran g2_core find v(xrcore.g2) at=60u
meas tran ga_core find v(xrcore.gate) at=60u
let ilkt = -i_core
echo "RESULT settle_tmax510n_core_t60u tstep_s=250n tmax_s=510n tol=default t_s=60u ileak_A=$&ilkt vp_V=$&vp_core t1_V=$&t1_core t_V=$&tt_core g1_V=$&g1_core g2_V=$&g2_core gate_V=$&ga_core"
meas tran i_core find i(Vr_core) at=100u
meas tran vp_core find v(vr_core) at=100u
meas tran t1_core find v(xrcore.t1) at=100u
meas tran tt_core find v(xrcore.t) at=100u
meas tran g1_core find v(xrcore.g1) at=100u
meas tran g2_core find v(xrcore.g2) at=100u
meas tran ga_core find v(xrcore.gate) at=100u
let ilkt = -i_core
echo "RESULT settle_tmax510n_core_t100u tstep_s=250n tmax_s=510n tol=default t_s=100u ileak_A=$&ilkt vp_V=$&vp_core t1_V=$&t1_core t_V=$&tt_core g1_V=$&g1_core g2_V=$&g2_core gate_V=$&ga_core"
meas tran i_core find i(Vr_core) at=200u
meas tran vp_core find v(vr_core) at=200u
meas tran t1_core find v(xrcore.t1) at=200u
meas tran tt_core find v(xrcore.t) at=200u
meas tran g1_core find v(xrcore.g1) at=200u
meas tran g2_core find v(xrcore.g2) at=200u
meas tran ga_core find v(xrcore.gate) at=200u
let ilkt = -i_core
echo "RESULT settle_tmax510n_core_t200u tstep_s=250n tmax_s=510n tol=default t_s=200u ileak_A=$&ilkt vp_V=$&vp_core t1_V=$&t1_core t_V=$&tt_core g1_V=$&g1_core g2_V=$&g2_core gate_V=$&ga_core"
meas tran i_core find i(Vr_core) at=300u
meas tran vp_core find v(vr_core) at=300u
meas tran t1_core find v(xrcore.t1) at=300u
meas tran tt_core find v(xrcore.t) at=300u
meas tran g1_core find v(xrcore.g1) at=300u
meas tran g2_core find v(xrcore.g2) at=300u
meas tran ga_core find v(xrcore.gate) at=300u
let ilkt = -i_core
echo "RESULT settle_tmax510n_core_t300u tstep_s=250n tmax_s=510n tol=default t_s=300u ileak_A=$&ilkt vp_V=$&vp_core t1_V=$&t1_core t_V=$&tt_core g1_V=$&g1_core g2_V=$&g2_core gate_V=$&ga_core"
meas tran i_core find i(Vr_core) at=500u
meas tran vp_core find v(vr_core) at=500u
meas tran t1_core find v(xrcore.t1) at=500u
meas tran tt_core find v(xrcore.t) at=500u
meas tran g1_core find v(xrcore.g1) at=500u
meas tran g2_core find v(xrcore.g2) at=500u
meas tran ga_core find v(xrcore.gate) at=500u
let ilkt = -i_core
echo "RESULT settle_tmax510n_core_t500u tstep_s=250n tmax_s=510n tol=default t_s=500u ileak_A=$&ilkt vp_V=$&vp_core t1_V=$&t1_core t_V=$&tt_core g1_V=$&g1_core g2_V=$&g2_core gate_V=$&ga_core"
meas tran i_core find i(Vr_core) at=700u
meas tran vp_core find v(vr_core) at=700u
meas tran t1_core find v(xrcore.t1) at=700u
meas tran tt_core find v(xrcore.t) at=700u
meas tran g1_core find v(xrcore.g1) at=700u
meas tran g2_core find v(xrcore.g2) at=700u
meas tran ga_core find v(xrcore.gate) at=700u
let ilkt = -i_core
echo "RESULT settle_tmax510n_core_t700u tstep_s=250n tmax_s=510n tol=default t_s=700u ileak_A=$&ilkt vp_V=$&vp_core t1_V=$&t1_core t_V=$&tt_core g1_V=$&g1_core g2_V=$&g2_core gate_V=$&ga_core"
meas tran i_core find i(Vr_core) at=1000u
meas tran vp_core find v(vr_core) at=1000u
meas tran t1_core find v(xrcore.t1) at=1000u
meas tran tt_core find v(xrcore.t) at=1000u
meas tran g1_core find v(xrcore.g1) at=1000u
meas tran g2_core find v(xrcore.g2) at=1000u
meas tran ga_core find v(xrcore.gate) at=1000u
let ilkt = -i_core
echo "RESULT settle_tmax510n_core_t1000u tstep_s=250n tmax_s=510n tol=default t_s=1000u ileak_A=$&ilkt vp_V=$&vp_core t1_V=$&t1_core t_V=$&tt_core g1_V=$&g1_core g2_V=$&g2_core gate_V=$&ga_core"
alter Vr_io pulse = [ 0 5.0 0 1u 1 1 1 ]
alter Vr_core pulse = [ 0 1.8 0 1u 1 1 1 ]
tran 252.5n 1.01m 0 1.01u
let nn = length(time)
let ilke = -i(Vr_io)[nn-1]
echo "RESULT settle_tmax1.01u_io_end tstep_s=252.5n tmax_s=1.01u tol=default t_s=1.01m ileak_A=$&ilke"
meas tran i_io find i(Vr_io) at=2u
meas tran vp_io find v(vr_io) at=2u
meas tran t1_io find v(xrio.t1) at=2u
meas tran tt_io find v(xrio.t) at=2u
meas tran g1_io find v(xrio.g1) at=2u
meas tran g2_io find v(xrio.g2) at=2u
meas tran ga_io find v(xrio.gate) at=2u
let ilkt = -i_io
echo "RESULT settle_tmax1.01u_io_t2u tstep_s=252.5n tmax_s=1.01u tol=default t_s=2u ileak_A=$&ilkt vp_V=$&vp_io t1_V=$&t1_io t_V=$&tt_io g1_V=$&g1_io g2_V=$&g2_io gate_V=$&ga_io"
meas tran i_io find i(Vr_io) at=5u
meas tran vp_io find v(vr_io) at=5u
meas tran t1_io find v(xrio.t1) at=5u
meas tran tt_io find v(xrio.t) at=5u
meas tran g1_io find v(xrio.g1) at=5u
meas tran g2_io find v(xrio.g2) at=5u
meas tran ga_io find v(xrio.gate) at=5u
let ilkt = -i_io
echo "RESULT settle_tmax1.01u_io_t5u tstep_s=252.5n tmax_s=1.01u tol=default t_s=5u ileak_A=$&ilkt vp_V=$&vp_io t1_V=$&t1_io t_V=$&tt_io g1_V=$&g1_io g2_V=$&g2_io gate_V=$&ga_io"
meas tran i_io find i(Vr_io) at=10u
meas tran vp_io find v(vr_io) at=10u
meas tran t1_io find v(xrio.t1) at=10u
meas tran tt_io find v(xrio.t) at=10u
meas tran g1_io find v(xrio.g1) at=10u
meas tran g2_io find v(xrio.g2) at=10u
meas tran ga_io find v(xrio.gate) at=10u
let ilkt = -i_io
echo "RESULT settle_tmax1.01u_io_t10u tstep_s=252.5n tmax_s=1.01u tol=default t_s=10u ileak_A=$&ilkt vp_V=$&vp_io t1_V=$&t1_io t_V=$&tt_io g1_V=$&g1_io g2_V=$&g2_io gate_V=$&ga_io"
meas tran i_io find i(Vr_io) at=20u
meas tran vp_io find v(vr_io) at=20u
meas tran t1_io find v(xrio.t1) at=20u
meas tran tt_io find v(xrio.t) at=20u
meas tran g1_io find v(xrio.g1) at=20u
meas tran g2_io find v(xrio.g2) at=20u
meas tran ga_io find v(xrio.gate) at=20u
let ilkt = -i_io
echo "RESULT settle_tmax1.01u_io_t20u tstep_s=252.5n tmax_s=1.01u tol=default t_s=20u ileak_A=$&ilkt vp_V=$&vp_io t1_V=$&t1_io t_V=$&tt_io g1_V=$&g1_io g2_V=$&g2_io gate_V=$&ga_io"
meas tran i_io find i(Vr_io) at=51u
meas tran vp_io find v(vr_io) at=51u
meas tran t1_io find v(xrio.t1) at=51u
meas tran tt_io find v(xrio.t) at=51u
meas tran g1_io find v(xrio.g1) at=51u
meas tran g2_io find v(xrio.g2) at=51u
meas tran ga_io find v(xrio.gate) at=51u
let ilkt = -i_io
echo "RESULT settle_tmax1.01u_io_t51u tstep_s=252.5n tmax_s=1.01u tol=default t_s=51u ileak_A=$&ilkt vp_V=$&vp_io t1_V=$&t1_io t_V=$&tt_io g1_V=$&g1_io g2_V=$&g2_io gate_V=$&ga_io"
meas tran i_io find i(Vr_io) at=60u
meas tran vp_io find v(vr_io) at=60u
meas tran t1_io find v(xrio.t1) at=60u
meas tran tt_io find v(xrio.t) at=60u
meas tran g1_io find v(xrio.g1) at=60u
meas tran g2_io find v(xrio.g2) at=60u
meas tran ga_io find v(xrio.gate) at=60u
let ilkt = -i_io
echo "RESULT settle_tmax1.01u_io_t60u tstep_s=252.5n tmax_s=1.01u tol=default t_s=60u ileak_A=$&ilkt vp_V=$&vp_io t1_V=$&t1_io t_V=$&tt_io g1_V=$&g1_io g2_V=$&g2_io gate_V=$&ga_io"
meas tran i_io find i(Vr_io) at=100u
meas tran vp_io find v(vr_io) at=100u
meas tran t1_io find v(xrio.t1) at=100u
meas tran tt_io find v(xrio.t) at=100u
meas tran g1_io find v(xrio.g1) at=100u
meas tran g2_io find v(xrio.g2) at=100u
meas tran ga_io find v(xrio.gate) at=100u
let ilkt = -i_io
echo "RESULT settle_tmax1.01u_io_t100u tstep_s=252.5n tmax_s=1.01u tol=default t_s=100u ileak_A=$&ilkt vp_V=$&vp_io t1_V=$&t1_io t_V=$&tt_io g1_V=$&g1_io g2_V=$&g2_io gate_V=$&ga_io"
meas tran i_io find i(Vr_io) at=200u
meas tran vp_io find v(vr_io) at=200u
meas tran t1_io find v(xrio.t1) at=200u
meas tran tt_io find v(xrio.t) at=200u
meas tran g1_io find v(xrio.g1) at=200u
meas tran g2_io find v(xrio.g2) at=200u
meas tran ga_io find v(xrio.gate) at=200u
let ilkt = -i_io
echo "RESULT settle_tmax1.01u_io_t200u tstep_s=252.5n tmax_s=1.01u tol=default t_s=200u ileak_A=$&ilkt vp_V=$&vp_io t1_V=$&t1_io t_V=$&tt_io g1_V=$&g1_io g2_V=$&g2_io gate_V=$&ga_io"
meas tran i_io find i(Vr_io) at=300u
meas tran vp_io find v(vr_io) at=300u
meas tran t1_io find v(xrio.t1) at=300u
meas tran tt_io find v(xrio.t) at=300u
meas tran g1_io find v(xrio.g1) at=300u
meas tran g2_io find v(xrio.g2) at=300u
meas tran ga_io find v(xrio.gate) at=300u
let ilkt = -i_io
echo "RESULT settle_tmax1.01u_io_t300u tstep_s=252.5n tmax_s=1.01u tol=default t_s=300u ileak_A=$&ilkt vp_V=$&vp_io t1_V=$&t1_io t_V=$&tt_io g1_V=$&g1_io g2_V=$&g2_io gate_V=$&ga_io"
meas tran i_io find i(Vr_io) at=500u
meas tran vp_io find v(vr_io) at=500u
meas tran t1_io find v(xrio.t1) at=500u
meas tran tt_io find v(xrio.t) at=500u
meas tran g1_io find v(xrio.g1) at=500u
meas tran g2_io find v(xrio.g2) at=500u
meas tran ga_io find v(xrio.gate) at=500u
let ilkt = -i_io
echo "RESULT settle_tmax1.01u_io_t500u tstep_s=252.5n tmax_s=1.01u tol=default t_s=500u ileak_A=$&ilkt vp_V=$&vp_io t1_V=$&t1_io t_V=$&tt_io g1_V=$&g1_io g2_V=$&g2_io gate_V=$&ga_io"
meas tran i_io find i(Vr_io) at=700u
meas tran vp_io find v(vr_io) at=700u
meas tran t1_io find v(xrio.t1) at=700u
meas tran tt_io find v(xrio.t) at=700u
meas tran g1_io find v(xrio.g1) at=700u
meas tran g2_io find v(xrio.g2) at=700u
meas tran ga_io find v(xrio.gate) at=700u
let ilkt = -i_io
echo "RESULT settle_tmax1.01u_io_t700u tstep_s=252.5n tmax_s=1.01u tol=default t_s=700u ileak_A=$&ilkt vp_V=$&vp_io t1_V=$&t1_io t_V=$&tt_io g1_V=$&g1_io g2_V=$&g2_io gate_V=$&ga_io"
meas tran i_io find i(Vr_io) at=1000u
meas tran vp_io find v(vr_io) at=1000u
meas tran t1_io find v(xrio.t1) at=1000u
meas tran tt_io find v(xrio.t) at=1000u
meas tran g1_io find v(xrio.g1) at=1000u
meas tran g2_io find v(xrio.g2) at=1000u
meas tran ga_io find v(xrio.gate) at=1000u
let ilkt = -i_io
echo "RESULT settle_tmax1.01u_io_t1000u tstep_s=252.5n tmax_s=1.01u tol=default t_s=1000u ileak_A=$&ilkt vp_V=$&vp_io t1_V=$&t1_io t_V=$&tt_io g1_V=$&g1_io g2_V=$&g2_io gate_V=$&ga_io"
let nn = length(time)
let ilke = -i(Vr_core)[nn-1]
echo "RESULT settle_tmax1.01u_core_end tstep_s=252.5n tmax_s=1.01u tol=default t_s=1.01m ileak_A=$&ilke"
meas tran i_core find i(Vr_core) at=2u
meas tran vp_core find v(vr_core) at=2u
meas tran t1_core find v(xrcore.t1) at=2u
meas tran tt_core find v(xrcore.t) at=2u
meas tran g1_core find v(xrcore.g1) at=2u
meas tran g2_core find v(xrcore.g2) at=2u
meas tran ga_core find v(xrcore.gate) at=2u
let ilkt = -i_core
echo "RESULT settle_tmax1.01u_core_t2u tstep_s=252.5n tmax_s=1.01u tol=default t_s=2u ileak_A=$&ilkt vp_V=$&vp_core t1_V=$&t1_core t_V=$&tt_core g1_V=$&g1_core g2_V=$&g2_core gate_V=$&ga_core"
meas tran i_core find i(Vr_core) at=5u
meas tran vp_core find v(vr_core) at=5u
meas tran t1_core find v(xrcore.t1) at=5u
meas tran tt_core find v(xrcore.t) at=5u
meas tran g1_core find v(xrcore.g1) at=5u
meas tran g2_core find v(xrcore.g2) at=5u
meas tran ga_core find v(xrcore.gate) at=5u
let ilkt = -i_core
echo "RESULT settle_tmax1.01u_core_t5u tstep_s=252.5n tmax_s=1.01u tol=default t_s=5u ileak_A=$&ilkt vp_V=$&vp_core t1_V=$&t1_core t_V=$&tt_core g1_V=$&g1_core g2_V=$&g2_core gate_V=$&ga_core"
meas tran i_core find i(Vr_core) at=10u
meas tran vp_core find v(vr_core) at=10u
meas tran t1_core find v(xrcore.t1) at=10u
meas tran tt_core find v(xrcore.t) at=10u
meas tran g1_core find v(xrcore.g1) at=10u
meas tran g2_core find v(xrcore.g2) at=10u
meas tran ga_core find v(xrcore.gate) at=10u
let ilkt = -i_core
echo "RESULT settle_tmax1.01u_core_t10u tstep_s=252.5n tmax_s=1.01u tol=default t_s=10u ileak_A=$&ilkt vp_V=$&vp_core t1_V=$&t1_core t_V=$&tt_core g1_V=$&g1_core g2_V=$&g2_core gate_V=$&ga_core"
meas tran i_core find i(Vr_core) at=20u
meas tran vp_core find v(vr_core) at=20u
meas tran t1_core find v(xrcore.t1) at=20u
meas tran tt_core find v(xrcore.t) at=20u
meas tran g1_core find v(xrcore.g1) at=20u
meas tran g2_core find v(xrcore.g2) at=20u
meas tran ga_core find v(xrcore.gate) at=20u
let ilkt = -i_core
echo "RESULT settle_tmax1.01u_core_t20u tstep_s=252.5n tmax_s=1.01u tol=default t_s=20u ileak_A=$&ilkt vp_V=$&vp_core t1_V=$&t1_core t_V=$&tt_core g1_V=$&g1_core g2_V=$&g2_core gate_V=$&ga_core"
meas tran i_core find i(Vr_core) at=51u
meas tran vp_core find v(vr_core) at=51u
meas tran t1_core find v(xrcore.t1) at=51u
meas tran tt_core find v(xrcore.t) at=51u
meas tran g1_core find v(xrcore.g1) at=51u
meas tran g2_core find v(xrcore.g2) at=51u
meas tran ga_core find v(xrcore.gate) at=51u
let ilkt = -i_core
echo "RESULT settle_tmax1.01u_core_t51u tstep_s=252.5n tmax_s=1.01u tol=default t_s=51u ileak_A=$&ilkt vp_V=$&vp_core t1_V=$&t1_core t_V=$&tt_core g1_V=$&g1_core g2_V=$&g2_core gate_V=$&ga_core"
meas tran i_core find i(Vr_core) at=60u
meas tran vp_core find v(vr_core) at=60u
meas tran t1_core find v(xrcore.t1) at=60u
meas tran tt_core find v(xrcore.t) at=60u
meas tran g1_core find v(xrcore.g1) at=60u
meas tran g2_core find v(xrcore.g2) at=60u
meas tran ga_core find v(xrcore.gate) at=60u
let ilkt = -i_core
echo "RESULT settle_tmax1.01u_core_t60u tstep_s=252.5n tmax_s=1.01u tol=default t_s=60u ileak_A=$&ilkt vp_V=$&vp_core t1_V=$&t1_core t_V=$&tt_core g1_V=$&g1_core g2_V=$&g2_core gate_V=$&ga_core"
meas tran i_core find i(Vr_core) at=100u
meas tran vp_core find v(vr_core) at=100u
meas tran t1_core find v(xrcore.t1) at=100u
meas tran tt_core find v(xrcore.t) at=100u
meas tran g1_core find v(xrcore.g1) at=100u
meas tran g2_core find v(xrcore.g2) at=100u
meas tran ga_core find v(xrcore.gate) at=100u
let ilkt = -i_core
echo "RESULT settle_tmax1.01u_core_t100u tstep_s=252.5n tmax_s=1.01u tol=default t_s=100u ileak_A=$&ilkt vp_V=$&vp_core t1_V=$&t1_core t_V=$&tt_core g1_V=$&g1_core g2_V=$&g2_core gate_V=$&ga_core"
meas tran i_core find i(Vr_core) at=200u
meas tran vp_core find v(vr_core) at=200u
meas tran t1_core find v(xrcore.t1) at=200u
meas tran tt_core find v(xrcore.t) at=200u
meas tran g1_core find v(xrcore.g1) at=200u
meas tran g2_core find v(xrcore.g2) at=200u
meas tran ga_core find v(xrcore.gate) at=200u
let ilkt = -i_core
echo "RESULT settle_tmax1.01u_core_t200u tstep_s=252.5n tmax_s=1.01u tol=default t_s=200u ileak_A=$&ilkt vp_V=$&vp_core t1_V=$&t1_core t_V=$&tt_core g1_V=$&g1_core g2_V=$&g2_core gate_V=$&ga_core"
meas tran i_core find i(Vr_core) at=300u
meas tran vp_core find v(vr_core) at=300u
meas tran t1_core find v(xrcore.t1) at=300u
meas tran tt_core find v(xrcore.t) at=300u
meas tran g1_core find v(xrcore.g1) at=300u
meas tran g2_core find v(xrcore.g2) at=300u
meas tran ga_core find v(xrcore.gate) at=300u
let ilkt = -i_core
echo "RESULT settle_tmax1.01u_core_t300u tstep_s=252.5n tmax_s=1.01u tol=default t_s=300u ileak_A=$&ilkt vp_V=$&vp_core t1_V=$&t1_core t_V=$&tt_core g1_V=$&g1_core g2_V=$&g2_core gate_V=$&ga_core"
meas tran i_core find i(Vr_core) at=500u
meas tran vp_core find v(vr_core) at=500u
meas tran t1_core find v(xrcore.t1) at=500u
meas tran tt_core find v(xrcore.t) at=500u
meas tran g1_core find v(xrcore.g1) at=500u
meas tran g2_core find v(xrcore.g2) at=500u
meas tran ga_core find v(xrcore.gate) at=500u
let ilkt = -i_core
echo "RESULT settle_tmax1.01u_core_t500u tstep_s=252.5n tmax_s=1.01u tol=default t_s=500u ileak_A=$&ilkt vp_V=$&vp_core t1_V=$&t1_core t_V=$&tt_core g1_V=$&g1_core g2_V=$&g2_core gate_V=$&ga_core"
meas tran i_core find i(Vr_core) at=700u
meas tran vp_core find v(vr_core) at=700u
meas tran t1_core find v(xrcore.t1) at=700u
meas tran tt_core find v(xrcore.t) at=700u
meas tran g1_core find v(xrcore.g1) at=700u
meas tran g2_core find v(xrcore.g2) at=700u
meas tran ga_core find v(xrcore.gate) at=700u
let ilkt = -i_core
echo "RESULT settle_tmax1.01u_core_t700u tstep_s=252.5n tmax_s=1.01u tol=default t_s=700u ileak_A=$&ilkt vp_V=$&vp_core t1_V=$&t1_core t_V=$&tt_core g1_V=$&g1_core g2_V=$&g2_core gate_V=$&ga_core"
meas tran i_core find i(Vr_core) at=1000u
meas tran vp_core find v(vr_core) at=1000u
meas tran t1_core find v(xrcore.t1) at=1000u
meas tran tt_core find v(xrcore.t) at=1000u
meas tran g1_core find v(xrcore.g1) at=1000u
meas tran g2_core find v(xrcore.g2) at=1000u
meas tran ga_core find v(xrcore.gate) at=1000u
let ilkt = -i_core
echo "RESULT settle_tmax1.01u_core_t1000u tstep_s=252.5n tmax_s=1.01u tol=default t_s=1000u ileak_A=$&ilkt vp_V=$&vp_core t1_V=$&t1_core t_V=$&tt_core g1_V=$&g1_core g2_V=$&g2_core gate_V=$&ga_core"
option reltol=1e-6 abstol=1e-15 vntol=1e-9
alter Vr_io pulse = [ 0 5.0 0 1u 1 1 1 ]
alter Vr_core pulse = [ 0 1.8 0 1u 1 1 1 ]
tran 50n 1.01m 0 50n
let nn = length(time)
let ilke = -i(Vr_io)[nn-1]
echo "RESULT settle_tight_io_end tstep_s=50n tmax_s=50n tol=tight t_s=1.01m ileak_A=$&ilke"
meas tran i_io find i(Vr_io) at=2u
meas tran vp_io find v(vr_io) at=2u
meas tran t1_io find v(xrio.t1) at=2u
meas tran tt_io find v(xrio.t) at=2u
meas tran g1_io find v(xrio.g1) at=2u
meas tran g2_io find v(xrio.g2) at=2u
meas tran ga_io find v(xrio.gate) at=2u
let ilkt = -i_io
echo "RESULT settle_tight_io_t2u tstep_s=50n tmax_s=50n tol=tight t_s=2u ileak_A=$&ilkt vp_V=$&vp_io t1_V=$&t1_io t_V=$&tt_io g1_V=$&g1_io g2_V=$&g2_io gate_V=$&ga_io"
meas tran i_io find i(Vr_io) at=5u
meas tran vp_io find v(vr_io) at=5u
meas tran t1_io find v(xrio.t1) at=5u
meas tran tt_io find v(xrio.t) at=5u
meas tran g1_io find v(xrio.g1) at=5u
meas tran g2_io find v(xrio.g2) at=5u
meas tran ga_io find v(xrio.gate) at=5u
let ilkt = -i_io
echo "RESULT settle_tight_io_t5u tstep_s=50n tmax_s=50n tol=tight t_s=5u ileak_A=$&ilkt vp_V=$&vp_io t1_V=$&t1_io t_V=$&tt_io g1_V=$&g1_io g2_V=$&g2_io gate_V=$&ga_io"
meas tran i_io find i(Vr_io) at=10u
meas tran vp_io find v(vr_io) at=10u
meas tran t1_io find v(xrio.t1) at=10u
meas tran tt_io find v(xrio.t) at=10u
meas tran g1_io find v(xrio.g1) at=10u
meas tran g2_io find v(xrio.g2) at=10u
meas tran ga_io find v(xrio.gate) at=10u
let ilkt = -i_io
echo "RESULT settle_tight_io_t10u tstep_s=50n tmax_s=50n tol=tight t_s=10u ileak_A=$&ilkt vp_V=$&vp_io t1_V=$&t1_io t_V=$&tt_io g1_V=$&g1_io g2_V=$&g2_io gate_V=$&ga_io"
meas tran i_io find i(Vr_io) at=20u
meas tran vp_io find v(vr_io) at=20u
meas tran t1_io find v(xrio.t1) at=20u
meas tran tt_io find v(xrio.t) at=20u
meas tran g1_io find v(xrio.g1) at=20u
meas tran g2_io find v(xrio.g2) at=20u
meas tran ga_io find v(xrio.gate) at=20u
let ilkt = -i_io
echo "RESULT settle_tight_io_t20u tstep_s=50n tmax_s=50n tol=tight t_s=20u ileak_A=$&ilkt vp_V=$&vp_io t1_V=$&t1_io t_V=$&tt_io g1_V=$&g1_io g2_V=$&g2_io gate_V=$&ga_io"
meas tran i_io find i(Vr_io) at=51u
meas tran vp_io find v(vr_io) at=51u
meas tran t1_io find v(xrio.t1) at=51u
meas tran tt_io find v(xrio.t) at=51u
meas tran g1_io find v(xrio.g1) at=51u
meas tran g2_io find v(xrio.g2) at=51u
meas tran ga_io find v(xrio.gate) at=51u
let ilkt = -i_io
echo "RESULT settle_tight_io_t51u tstep_s=50n tmax_s=50n tol=tight t_s=51u ileak_A=$&ilkt vp_V=$&vp_io t1_V=$&t1_io t_V=$&tt_io g1_V=$&g1_io g2_V=$&g2_io gate_V=$&ga_io"
meas tran i_io find i(Vr_io) at=60u
meas tran vp_io find v(vr_io) at=60u
meas tran t1_io find v(xrio.t1) at=60u
meas tran tt_io find v(xrio.t) at=60u
meas tran g1_io find v(xrio.g1) at=60u
meas tran g2_io find v(xrio.g2) at=60u
meas tran ga_io find v(xrio.gate) at=60u
let ilkt = -i_io
echo "RESULT settle_tight_io_t60u tstep_s=50n tmax_s=50n tol=tight t_s=60u ileak_A=$&ilkt vp_V=$&vp_io t1_V=$&t1_io t_V=$&tt_io g1_V=$&g1_io g2_V=$&g2_io gate_V=$&ga_io"
meas tran i_io find i(Vr_io) at=100u
meas tran vp_io find v(vr_io) at=100u
meas tran t1_io find v(xrio.t1) at=100u
meas tran tt_io find v(xrio.t) at=100u
meas tran g1_io find v(xrio.g1) at=100u
meas tran g2_io find v(xrio.g2) at=100u
meas tran ga_io find v(xrio.gate) at=100u
let ilkt = -i_io
echo "RESULT settle_tight_io_t100u tstep_s=50n tmax_s=50n tol=tight t_s=100u ileak_A=$&ilkt vp_V=$&vp_io t1_V=$&t1_io t_V=$&tt_io g1_V=$&g1_io g2_V=$&g2_io gate_V=$&ga_io"
meas tran i_io find i(Vr_io) at=200u
meas tran vp_io find v(vr_io) at=200u
meas tran t1_io find v(xrio.t1) at=200u
meas tran tt_io find v(xrio.t) at=200u
meas tran g1_io find v(xrio.g1) at=200u
meas tran g2_io find v(xrio.g2) at=200u
meas tran ga_io find v(xrio.gate) at=200u
let ilkt = -i_io
echo "RESULT settle_tight_io_t200u tstep_s=50n tmax_s=50n tol=tight t_s=200u ileak_A=$&ilkt vp_V=$&vp_io t1_V=$&t1_io t_V=$&tt_io g1_V=$&g1_io g2_V=$&g2_io gate_V=$&ga_io"
meas tran i_io find i(Vr_io) at=300u
meas tran vp_io find v(vr_io) at=300u
meas tran t1_io find v(xrio.t1) at=300u
meas tran tt_io find v(xrio.t) at=300u
meas tran g1_io find v(xrio.g1) at=300u
meas tran g2_io find v(xrio.g2) at=300u
meas tran ga_io find v(xrio.gate) at=300u
let ilkt = -i_io
echo "RESULT settle_tight_io_t300u tstep_s=50n tmax_s=50n tol=tight t_s=300u ileak_A=$&ilkt vp_V=$&vp_io t1_V=$&t1_io t_V=$&tt_io g1_V=$&g1_io g2_V=$&g2_io gate_V=$&ga_io"
meas tran i_io find i(Vr_io) at=500u
meas tran vp_io find v(vr_io) at=500u
meas tran t1_io find v(xrio.t1) at=500u
meas tran tt_io find v(xrio.t) at=500u
meas tran g1_io find v(xrio.g1) at=500u
meas tran g2_io find v(xrio.g2) at=500u
meas tran ga_io find v(xrio.gate) at=500u
let ilkt = -i_io
echo "RESULT settle_tight_io_t500u tstep_s=50n tmax_s=50n tol=tight t_s=500u ileak_A=$&ilkt vp_V=$&vp_io t1_V=$&t1_io t_V=$&tt_io g1_V=$&g1_io g2_V=$&g2_io gate_V=$&ga_io"
meas tran i_io find i(Vr_io) at=700u
meas tran vp_io find v(vr_io) at=700u
meas tran t1_io find v(xrio.t1) at=700u
meas tran tt_io find v(xrio.t) at=700u
meas tran g1_io find v(xrio.g1) at=700u
meas tran g2_io find v(xrio.g2) at=700u
meas tran ga_io find v(xrio.gate) at=700u
let ilkt = -i_io
echo "RESULT settle_tight_io_t700u tstep_s=50n tmax_s=50n tol=tight t_s=700u ileak_A=$&ilkt vp_V=$&vp_io t1_V=$&t1_io t_V=$&tt_io g1_V=$&g1_io g2_V=$&g2_io gate_V=$&ga_io"
meas tran i_io find i(Vr_io) at=1000u
meas tran vp_io find v(vr_io) at=1000u
meas tran t1_io find v(xrio.t1) at=1000u
meas tran tt_io find v(xrio.t) at=1000u
meas tran g1_io find v(xrio.g1) at=1000u
meas tran g2_io find v(xrio.g2) at=1000u
meas tran ga_io find v(xrio.gate) at=1000u
let ilkt = -i_io
echo "RESULT settle_tight_io_t1000u tstep_s=50n tmax_s=50n tol=tight t_s=1000u ileak_A=$&ilkt vp_V=$&vp_io t1_V=$&t1_io t_V=$&tt_io g1_V=$&g1_io g2_V=$&g2_io gate_V=$&ga_io"
let nn = length(time)
let ilke = -i(Vr_core)[nn-1]
echo "RESULT settle_tight_core_end tstep_s=50n tmax_s=50n tol=tight t_s=1.01m ileak_A=$&ilke"
meas tran i_core find i(Vr_core) at=2u
meas tran vp_core find v(vr_core) at=2u
meas tran t1_core find v(xrcore.t1) at=2u
meas tran tt_core find v(xrcore.t) at=2u
meas tran g1_core find v(xrcore.g1) at=2u
meas tran g2_core find v(xrcore.g2) at=2u
meas tran ga_core find v(xrcore.gate) at=2u
let ilkt = -i_core
echo "RESULT settle_tight_core_t2u tstep_s=50n tmax_s=50n tol=tight t_s=2u ileak_A=$&ilkt vp_V=$&vp_core t1_V=$&t1_core t_V=$&tt_core g1_V=$&g1_core g2_V=$&g2_core gate_V=$&ga_core"
meas tran i_core find i(Vr_core) at=5u
meas tran vp_core find v(vr_core) at=5u
meas tran t1_core find v(xrcore.t1) at=5u
meas tran tt_core find v(xrcore.t) at=5u
meas tran g1_core find v(xrcore.g1) at=5u
meas tran g2_core find v(xrcore.g2) at=5u
meas tran ga_core find v(xrcore.gate) at=5u
let ilkt = -i_core
echo "RESULT settle_tight_core_t5u tstep_s=50n tmax_s=50n tol=tight t_s=5u ileak_A=$&ilkt vp_V=$&vp_core t1_V=$&t1_core t_V=$&tt_core g1_V=$&g1_core g2_V=$&g2_core gate_V=$&ga_core"
meas tran i_core find i(Vr_core) at=10u
meas tran vp_core find v(vr_core) at=10u
meas tran t1_core find v(xrcore.t1) at=10u
meas tran tt_core find v(xrcore.t) at=10u
meas tran g1_core find v(xrcore.g1) at=10u
meas tran g2_core find v(xrcore.g2) at=10u
meas tran ga_core find v(xrcore.gate) at=10u
let ilkt = -i_core
echo "RESULT settle_tight_core_t10u tstep_s=50n tmax_s=50n tol=tight t_s=10u ileak_A=$&ilkt vp_V=$&vp_core t1_V=$&t1_core t_V=$&tt_core g1_V=$&g1_core g2_V=$&g2_core gate_V=$&ga_core"
meas tran i_core find i(Vr_core) at=20u
meas tran vp_core find v(vr_core) at=20u
meas tran t1_core find v(xrcore.t1) at=20u
meas tran tt_core find v(xrcore.t) at=20u
meas tran g1_core find v(xrcore.g1) at=20u
meas tran g2_core find v(xrcore.g2) at=20u
meas tran ga_core find v(xrcore.gate) at=20u
let ilkt = -i_core
echo "RESULT settle_tight_core_t20u tstep_s=50n tmax_s=50n tol=tight t_s=20u ileak_A=$&ilkt vp_V=$&vp_core t1_V=$&t1_core t_V=$&tt_core g1_V=$&g1_core g2_V=$&g2_core gate_V=$&ga_core"
meas tran i_core find i(Vr_core) at=51u
meas tran vp_core find v(vr_core) at=51u
meas tran t1_core find v(xrcore.t1) at=51u
meas tran tt_core find v(xrcore.t) at=51u
meas tran g1_core find v(xrcore.g1) at=51u
meas tran g2_core find v(xrcore.g2) at=51u
meas tran ga_core find v(xrcore.gate) at=51u
let ilkt = -i_core
echo "RESULT settle_tight_core_t51u tstep_s=50n tmax_s=50n tol=tight t_s=51u ileak_A=$&ilkt vp_V=$&vp_core t1_V=$&t1_core t_V=$&tt_core g1_V=$&g1_core g2_V=$&g2_core gate_V=$&ga_core"
meas tran i_core find i(Vr_core) at=60u
meas tran vp_core find v(vr_core) at=60u
meas tran t1_core find v(xrcore.t1) at=60u
meas tran tt_core find v(xrcore.t) at=60u
meas tran g1_core find v(xrcore.g1) at=60u
meas tran g2_core find v(xrcore.g2) at=60u
meas tran ga_core find v(xrcore.gate) at=60u
let ilkt = -i_core
echo "RESULT settle_tight_core_t60u tstep_s=50n tmax_s=50n tol=tight t_s=60u ileak_A=$&ilkt vp_V=$&vp_core t1_V=$&t1_core t_V=$&tt_core g1_V=$&g1_core g2_V=$&g2_core gate_V=$&ga_core"
meas tran i_core find i(Vr_core) at=100u
meas tran vp_core find v(vr_core) at=100u
meas tran t1_core find v(xrcore.t1) at=100u
meas tran tt_core find v(xrcore.t) at=100u
meas tran g1_core find v(xrcore.g1) at=100u
meas tran g2_core find v(xrcore.g2) at=100u
meas tran ga_core find v(xrcore.gate) at=100u
let ilkt = -i_core
echo "RESULT settle_tight_core_t100u tstep_s=50n tmax_s=50n tol=tight t_s=100u ileak_A=$&ilkt vp_V=$&vp_core t1_V=$&t1_core t_V=$&tt_core g1_V=$&g1_core g2_V=$&g2_core gate_V=$&ga_core"
meas tran i_core find i(Vr_core) at=200u
meas tran vp_core find v(vr_core) at=200u
meas tran t1_core find v(xrcore.t1) at=200u
meas tran tt_core find v(xrcore.t) at=200u
meas tran g1_core find v(xrcore.g1) at=200u
meas tran g2_core find v(xrcore.g2) at=200u
meas tran ga_core find v(xrcore.gate) at=200u
let ilkt = -i_core
echo "RESULT settle_tight_core_t200u tstep_s=50n tmax_s=50n tol=tight t_s=200u ileak_A=$&ilkt vp_V=$&vp_core t1_V=$&t1_core t_V=$&tt_core g1_V=$&g1_core g2_V=$&g2_core gate_V=$&ga_core"
meas tran i_core find i(Vr_core) at=300u
meas tran vp_core find v(vr_core) at=300u
meas tran t1_core find v(xrcore.t1) at=300u
meas tran tt_core find v(xrcore.t) at=300u
meas tran g1_core find v(xrcore.g1) at=300u
meas tran g2_core find v(xrcore.g2) at=300u
meas tran ga_core find v(xrcore.gate) at=300u
let ilkt = -i_core
echo "RESULT settle_tight_core_t300u tstep_s=50n tmax_s=50n tol=tight t_s=300u ileak_A=$&ilkt vp_V=$&vp_core t1_V=$&t1_core t_V=$&tt_core g1_V=$&g1_core g2_V=$&g2_core gate_V=$&ga_core"
meas tran i_core find i(Vr_core) at=500u
meas tran vp_core find v(vr_core) at=500u
meas tran t1_core find v(xrcore.t1) at=500u
meas tran tt_core find v(xrcore.t) at=500u
meas tran g1_core find v(xrcore.g1) at=500u
meas tran g2_core find v(xrcore.g2) at=500u
meas tran ga_core find v(xrcore.gate) at=500u
let ilkt = -i_core
echo "RESULT settle_tight_core_t500u tstep_s=50n tmax_s=50n tol=tight t_s=500u ileak_A=$&ilkt vp_V=$&vp_core t1_V=$&t1_core t_V=$&tt_core g1_V=$&g1_core g2_V=$&g2_core gate_V=$&ga_core"
meas tran i_core find i(Vr_core) at=700u
meas tran vp_core find v(vr_core) at=700u
meas tran t1_core find v(xrcore.t1) at=700u
meas tran tt_core find v(xrcore.t) at=700u
meas tran g1_core find v(xrcore.g1) at=700u
meas tran g2_core find v(xrcore.g2) at=700u
meas tran ga_core find v(xrcore.gate) at=700u
let ilkt = -i_core
echo "RESULT settle_tight_core_t700u tstep_s=50n tmax_s=50n tol=tight t_s=700u ileak_A=$&ilkt vp_V=$&vp_core t1_V=$&t1_core t_V=$&tt_core g1_V=$&g1_core g2_V=$&g2_core gate_V=$&ga_core"
meas tran i_core find i(Vr_core) at=1000u
meas tran vp_core find v(vr_core) at=1000u
meas tran t1_core find v(xrcore.t1) at=1000u
meas tran tt_core find v(xrcore.t) at=1000u
meas tran g1_core find v(xrcore.g1) at=1000u
meas tran g2_core find v(xrcore.g2) at=1000u
meas tran ga_core find v(xrcore.gate) at=1000u
let ilkt = -i_core
echo "RESULT settle_tight_core_t1000u tstep_s=50n tmax_s=50n tol=tight t_s=1000u ileak_A=$&ilkt vp_V=$&vp_core t1_V=$&t1_core t_V=$&tt_core g1_V=$&g1_core g2_V=$&g2_core gate_V=$&ga_core"
quit
.endc
.end
