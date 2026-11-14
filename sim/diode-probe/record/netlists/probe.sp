* diode-probe: ESD.3 pad diode forward drop at the ESD.2 current
* single-corner probe, tt, 27 C. Diode areas are placeholders (gate G1).
.lib $PDK_ROOT/sky130A/libs.tech/ngspice/sky130.lib.spice tt
.temp 27
.include ./sky130_ioring_gpio_esd.spice
Vddio vddio 0 3.3
Vddio5 vddio5 0 5.0
* VSS is node 0 throughout.
Iin_sp 0 pad_sp 0
Xsp pad_sp rxg_sp vddio 0 sky130_ioring_gpio_esd
Iin_sn pad_sn 0 0
Xsn pad_sn rxg_sn vddio 0 sky130_ioring_gpio_esd
Vg_pa g_pa 0 PWL(0 0 50n 0 50.1n 2000)
Ch_pa g_pa h_pa 100p
Rh_pa h_pa pad_pa 1500
Xpa pad_pa rxg_pa vddio 0 sky130_ioring_gpio_esd
Vg_pb g_pb 0 PWL(0 0 500n 0 500.1n 2000)
Ch_pb g_pb h_pb 100p
Rh_pb h_pb pad_pb 1500
Xpb pad_pb rxg_pb vddio 0 sky130_ioring_gpio_esd
Vg_pc g_pc 0 PWL(0 0 50n 0 50.1n 2000)
Ch_pc g_pc h_pc 100p
Rh_pc h_pc pad_pc 1500
Xpc pad_pc rxg_pc vddio 0 sky130_ioring_gpio_esd
Rbl_pc pad_pc 0 1G
Vg_pd g_pd 0 PWL(0 0 50n 0 50.1n 2000)
Ch_pd g_pd h_pd 100p
Rh_pd h_pd pad_pd 1500
Xpd pad_pd rxg_pd vddio 0 sky130_ioring_gpio_esd
Vg_pe g_pe 0 PWL(0 0 50n 0 50.1n 2000)
Ch_pe g_pe h_pe 100p
Rh_pe h_pe pad_pe 1500
Xpe pad_pe rxg_pe vddio 0 sky130_ioring_gpio_esd
Vg_na g_na 0 PWL(0 0 50n 0 50.1n -2000)
Ch_na g_na h_na 100p
Rh_na h_na pad_na 1500
Xna pad_na rxg_na vddio 0 sky130_ioring_gpio_esd
Vg_nb g_nb 0 PWL(0 0 500n 0 500.1n -2000)
Ch_nb g_nb h_nb 100p
Rh_nb h_nb pad_nb 1500
Xnb pad_nb rxg_nb vddio 0 sky130_ioring_gpio_esd
Vg_nc g_nc 0 PWL(0 0 50n 0 50.1n -2000)
Ch_nc g_nc h_nc 100p
Rh_nc h_nc pad_nc 1500
Xnc pad_nc rxg_nc vddio 0 sky130_ioring_gpio_esd
Rbl_nc pad_nc 0 1G
Vg_nd g_nd 0 PWL(0 0 50n 0 50.1n -2000)
Ch_nd g_nd h_nd 100p
Rh_nd h_nd pad_nd 1500
Xnd pad_nd rxg_nd vddio 0 sky130_ioring_gpio_esd
Vg_ne g_ne 0 PWL(0 0 50n 0 50.1n -2000)
Ch_ne g_ne h_ne 100p
Rh_ne h_ne pad_ne 1500
Xne pad_ne rxg_ne vddio 0 sky130_ioring_gpio_esd
Vg_qp g_qp 0 PWL(0 0 50n 0 50.1n 2000)
Ch_qp g_qp h_qp 100p
Rh_qp h_qp pad_qp 1500
Xqp pad_qp rxg_qp vddio5 0 sky130_ioring_gpio_esd
Vg_qn g_qn 0 PWL(0 0 50n 0 50.1n -2000)
Ch_qn g_qn h_qn 100p
Rh_qn h_qn pad_qn 1500
Xqn pad_qn rxg_qn vddio5 0 sky130_ioring_gpio_esd
Vg_gr g_gr 0 PWL(0 0 50n 0 50.1n 2000)
Ch_gr g_gr h_gr 100p
Rh_gr h_gr m_gr 1500
Vm_gr m_gr 0 0
Vg_gc g_gc 0 PWL(0 0 50n 0 50.1n 2000)
Ch_gc g_gc h_gc 100p
Rh_gc h_gc c_gc 1500
Cl_gc c_gc 0 1u
Rbl_gc c_gc 0 1T
.ic v(pad_pd)=5 v(rxg_pd)=5
.ic v(pad_pe)=-0.05 v(rxg_pe)=-0.05
.ic v(pad_nd)=5 v(rxg_nd)=5
.ic v(pad_ne)=-0.05 v(rxg_ne)=-0.05
.control
set noaskquit
save all @d.xsp.xdp.d0[id] @d.xsp.xdn.d0[id] @d.xsp.xdlp.d0[id] @d.xsp.xdln.d0[id]
save @d.xsp.xdp.d0[cd] @d.xsp.xdn.d0[cd] @d.xsp.xdlp.d0[cd] @d.xsp.xdln.d0[cd]
save all @d.xsn.xdp.d0[id] @d.xsn.xdn.d0[id] @d.xsn.xdlp.d0[id] @d.xsn.xdln.d0[id]
save @d.xsn.xdp.d0[cd] @d.xsn.xdn.d0[cd] @d.xsn.xdlp.d0[cd] @d.xsn.xdln.d0[cd]
save @d.xpa.xdp.d0[id] @d.xpa.xdn.d0[id] @d.xpa.xdlp.d0[id] @d.xpa.xdln.d0[id]
save @d.xpb.xdp.d0[id] @d.xpb.xdn.d0[id] @d.xpb.xdlp.d0[id] @d.xpb.xdln.d0[id]
save @d.xpc.xdp.d0[id] @d.xpc.xdn.d0[id] @d.xpc.xdlp.d0[id] @d.xpc.xdln.d0[id]
save @d.xpd.xdp.d0[id] @d.xpd.xdn.d0[id] @d.xpd.xdlp.d0[id] @d.xpd.xdln.d0[id]
save @d.xpe.xdp.d0[id] @d.xpe.xdn.d0[id] @d.xpe.xdlp.d0[id] @d.xpe.xdln.d0[id]
save @d.xna.xdp.d0[id] @d.xna.xdn.d0[id] @d.xna.xdlp.d0[id] @d.xna.xdln.d0[id]
save @d.xnb.xdp.d0[id] @d.xnb.xdn.d0[id] @d.xnb.xdlp.d0[id] @d.xnb.xdln.d0[id]
save @d.xnc.xdp.d0[id] @d.xnc.xdn.d0[id] @d.xnc.xdlp.d0[id] @d.xnc.xdln.d0[id]
save @d.xnd.xdp.d0[id] @d.xnd.xdn.d0[id] @d.xnd.xdlp.d0[id] @d.xnd.xdln.d0[id]
save @d.xne.xdp.d0[id] @d.xne.xdn.d0[id] @d.xne.xdlp.d0[id] @d.xne.xdln.d0[id]
save @d.xqp.xdp.d0[id] @d.xqp.xdn.d0[id] @d.xqp.xdlp.d0[id] @d.xqp.xdln.d0[id]
save @d.xqn.xdp.d0[id] @d.xqn.xdn.d0[id] @d.xqn.xdlp.d0[id] @d.xqn.xdln.d0[id]
echo "RESULT model_limits_XDP model=sky130_fd_pr__diode_pd2nw_05v5 area_inst=2e14 perim_inst=6e7 js_A_per_m2=2.1483e-17 jsw_A_per_m=8.04e-16 isat_A=0.00429665 ik_density_A_per_m2=47600 ik_times_area_A=9.52e+18 n=1.3632 rs_ohm_per_area=600 bv_V=12.69 i_esd2_pk_A=1.33333 esd7_abs_v_limit_V=5.0 current_validity=no_current_validity_range_on_record"
echo "RESULT model_limits_XDN model=sky130_fd_pr__diode_pw2nd_05v5 area_inst=2e14 perim_inst=6e7 js_A_per_m2=2.75e-15 jsw_A_per_m=6e-16 isat_A=0.55 ik_density_A_per_m2=1300 ik_times_area_A=2.6e+17 n=1.2928 rs_ohm_per_area=981 bv_V=11.7 i_esd2_pk_A=1.33333 esd7_abs_v_limit_V=5.0 current_validity=no_current_validity_range_on_record"
echo "RESULT model_limits_XDLP model=sky130_fd_pr__diode_pd2nw_05v5 area_inst=1e13 perim_inst=1.4e7 js_A_per_m2=2.1483e-17 jsw_A_per_m=8.04e-16 isat_A=0.000214841 ik_density_A_per_m2=47600 ik_times_area_A=4.76e+17 n=1.3632 rs_ohm_per_area=600 bv_V=12.69 i_esd2_pk_A=1.33333 esd7_abs_v_limit_V=5.0 current_validity=no_current_validity_range_on_record"
echo "RESULT model_limits_XDLN model=sky130_fd_pr__diode_pw2nd_05v5 area_inst=1e13 perim_inst=1.4e7 js_A_per_m2=2.75e-15 jsw_A_per_m=6e-16 isat_A=0.0275 ik_density_A_per_m2=1300 ik_times_area_A=1.3e+16 n=1.2928 rs_ohm_per_area=981 bv_V=11.7 i_esd2_pk_A=1.33333 esd7_abs_v_limit_V=5.0 current_validity=no_current_validity_range_on_record"
tran 0.02n 2u 0 0.1n
let igr = abs(i(Vm_gr))
let igrpk = maximum(igr)
meas tran igr_tau find igr at=200.1n
let ratio = igr_tau / igrpk
let vgc = maximum(v(c_gc))
let qgc = vgc * 1e-6
echo "RESULT selftest_gun_short vhbm_V=2000 c_F=100p r_ohm=1500 i_expected_A=1.33333 ipulse_pk_A=$&igrpk i_at_1tau_A=$&igr_tau i_at_1tau_over_ipk=$&ratio one_over_e=0.367879 decay_tau_s=1.5e-7"
echo "RESULT selftest_gun_1uF c_load_F=1e-6 v_load_final_V=$&vgc q_delivered_C=$&qgc q_expected_C=2e-7"
alter Vddio = 3.3
alter Iin_sn = 0
alter Iin_sp = 0
op
let vp = v(pad_sp)
let vr = v(rxg_sp)
let ikcl = @d.xsp.xdp.d0[id] - @d.xsp.xdn.d0[id] + @d.xsp.xdlp.d0[id] - @d.xsp.xdln.d0[id]
let ikerr = ikcl - (0)
echo "RESULT dcop_sp_i0 i_forced_A=0 i_esd2_pk_A=1.33333 vddio_V=3.3 vpad_V=$&vp vrxg_V=$&vr i_kcl_A=$&ikcl i_kcl_err_A=$&ikerr"
let vf = v(pad_sp) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdp.d0[cd]
echo "RESULT dcop_sp_i0_XDP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(pad_sp)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdn.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdn.d0[cd]
echo "RESULT dcop_sp_i0_XDN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = v(rxg_sp) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdlp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdlp.d0[cd]
echo "RESULT dcop_sp_i0_XDLP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(rxg_sp)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdln.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdln.d0[cd]
echo "RESULT dcop_sp_i0_XDLN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vrsa = maximum(abs(v(rxg_sp) - v(pad_sp)))
echo "RESULT dcop_sp_i0_XRS vabs_V=$&vrsa validity=no_validity_range_on_record current_validity=no_current_validity_range_on_record"
alter Iin_sp = 1.33333e-3
op
let vp = v(pad_sp)
let vr = v(rxg_sp)
let ikcl = @d.xsp.xdp.d0[id] - @d.xsp.xdn.d0[id] + @d.xsp.xdlp.d0[id] - @d.xsp.xdln.d0[id]
let ikerr = ikcl - (1.33333e-3)
echo "RESULT dcop_sp_i1.33333e-3 i_forced_A=1.33333e-3 i_esd2_pk_A=1.33333 vddio_V=3.3 vpad_V=$&vp vrxg_V=$&vr i_kcl_A=$&ikcl i_kcl_err_A=$&ikerr"
let vf = v(pad_sp) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdp.d0[cd]
echo "RESULT dcop_sp_i1.33333e-3_XDP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(pad_sp)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdn.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdn.d0[cd]
echo "RESULT dcop_sp_i1.33333e-3_XDN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = v(rxg_sp) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdlp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdlp.d0[cd]
echo "RESULT dcop_sp_i1.33333e-3_XDLP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(rxg_sp)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdln.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdln.d0[cd]
echo "RESULT dcop_sp_i1.33333e-3_XDLN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vrsa = maximum(abs(v(rxg_sp) - v(pad_sp)))
echo "RESULT dcop_sp_i1.33333e-3_XRS vabs_V=$&vrsa validity=no_validity_range_on_record current_validity=no_current_validity_range_on_record"
alter Iin_sp = 1.33333e-2
op
let vp = v(pad_sp)
let vr = v(rxg_sp)
let ikcl = @d.xsp.xdp.d0[id] - @d.xsp.xdn.d0[id] + @d.xsp.xdlp.d0[id] - @d.xsp.xdln.d0[id]
let ikerr = ikcl - (1.33333e-2)
echo "RESULT dcop_sp_i1.33333e-2 i_forced_A=1.33333e-2 i_esd2_pk_A=1.33333 vddio_V=3.3 vpad_V=$&vp vrxg_V=$&vr i_kcl_A=$&ikcl i_kcl_err_A=$&ikerr"
let vf = v(pad_sp) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdp.d0[cd]
echo "RESULT dcop_sp_i1.33333e-2_XDP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(pad_sp)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdn.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdn.d0[cd]
echo "RESULT dcop_sp_i1.33333e-2_XDN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = v(rxg_sp) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdlp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdlp.d0[cd]
echo "RESULT dcop_sp_i1.33333e-2_XDLP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(rxg_sp)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdln.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdln.d0[cd]
echo "RESULT dcop_sp_i1.33333e-2_XDLN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vrsa = maximum(abs(v(rxg_sp) - v(pad_sp)))
echo "RESULT dcop_sp_i1.33333e-2_XRS vabs_V=$&vrsa validity=no_validity_range_on_record current_validity=no_current_validity_range_on_record"
alter Iin_sp = 1.33333e-1
op
let vp = v(pad_sp)
let vr = v(rxg_sp)
let ikcl = @d.xsp.xdp.d0[id] - @d.xsp.xdn.d0[id] + @d.xsp.xdlp.d0[id] - @d.xsp.xdln.d0[id]
let ikerr = ikcl - (1.33333e-1)
echo "RESULT dcop_sp_i1.33333e-1 i_forced_A=1.33333e-1 i_esd2_pk_A=1.33333 vddio_V=3.3 vpad_V=$&vp vrxg_V=$&vr i_kcl_A=$&ikcl i_kcl_err_A=$&ikerr"
let vf = v(pad_sp) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdp.d0[cd]
echo "RESULT dcop_sp_i1.33333e-1_XDP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(pad_sp)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdn.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdn.d0[cd]
echo "RESULT dcop_sp_i1.33333e-1_XDN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = v(rxg_sp) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdlp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdlp.d0[cd]
echo "RESULT dcop_sp_i1.33333e-1_XDLP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(rxg_sp)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdln.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdln.d0[cd]
echo "RESULT dcop_sp_i1.33333e-1_XDLN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vrsa = maximum(abs(v(rxg_sp) - v(pad_sp)))
echo "RESULT dcop_sp_i1.33333e-1_XRS vabs_V=$&vrsa validity=no_validity_range_on_record current_validity=no_current_validity_range_on_record"
alter Iin_sp = 0.3
op
let vp = v(pad_sp)
let vr = v(rxg_sp)
let ikcl = @d.xsp.xdp.d0[id] - @d.xsp.xdn.d0[id] + @d.xsp.xdlp.d0[id] - @d.xsp.xdln.d0[id]
let ikerr = ikcl - (0.3)
echo "RESULT dcop_sp_i0.3 i_forced_A=0.3 i_esd2_pk_A=1.33333 vddio_V=3.3 vpad_V=$&vp vrxg_V=$&vr i_kcl_A=$&ikcl i_kcl_err_A=$&ikerr"
let vf = v(pad_sp) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdp.d0[cd]
echo "RESULT dcop_sp_i0.3_XDP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(pad_sp)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdn.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdn.d0[cd]
echo "RESULT dcop_sp_i0.3_XDN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = v(rxg_sp) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdlp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdlp.d0[cd]
echo "RESULT dcop_sp_i0.3_XDLP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(rxg_sp)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdln.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdln.d0[cd]
echo "RESULT dcop_sp_i0.3_XDLN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vrsa = maximum(abs(v(rxg_sp) - v(pad_sp)))
echo "RESULT dcop_sp_i0.3_XRS vabs_V=$&vrsa validity=no_validity_range_on_record current_validity=no_current_validity_range_on_record"
alter Iin_sp = 0.38
op
let vp = v(pad_sp)
let vr = v(rxg_sp)
let ikcl = @d.xsp.xdp.d0[id] - @d.xsp.xdn.d0[id] + @d.xsp.xdlp.d0[id] - @d.xsp.xdln.d0[id]
let ikerr = ikcl - (0.38)
echo "RESULT dcop_sp_i0.38 i_forced_A=0.38 i_esd2_pk_A=1.33333 vddio_V=3.3 vpad_V=$&vp vrxg_V=$&vr i_kcl_A=$&ikcl i_kcl_err_A=$&ikerr"
let vf = v(pad_sp) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdp.d0[cd]
echo "RESULT dcop_sp_i0.38_XDP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(pad_sp)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdn.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdn.d0[cd]
echo "RESULT dcop_sp_i0.38_XDN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = v(rxg_sp) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdlp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdlp.d0[cd]
echo "RESULT dcop_sp_i0.38_XDLP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(rxg_sp)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdln.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdln.d0[cd]
echo "RESULT dcop_sp_i0.38_XDLN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vrsa = maximum(abs(v(rxg_sp) - v(pad_sp)))
echo "RESULT dcop_sp_i0.38_XRS vabs_V=$&vrsa validity=no_validity_range_on_record current_validity=no_current_validity_range_on_record"
alter Iin_sp = 0.39
op
let vp = v(pad_sp)
let vr = v(rxg_sp)
let ikcl = @d.xsp.xdp.d0[id] - @d.xsp.xdn.d0[id] + @d.xsp.xdlp.d0[id] - @d.xsp.xdln.d0[id]
let ikerr = ikcl - (0.39)
echo "RESULT dcop_sp_i0.39 i_forced_A=0.39 i_esd2_pk_A=1.33333 vddio_V=3.3 vpad_V=$&vp vrxg_V=$&vr i_kcl_A=$&ikcl i_kcl_err_A=$&ikerr"
let vf = v(pad_sp) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdp.d0[cd]
echo "RESULT dcop_sp_i0.39_XDP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(pad_sp)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdn.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdn.d0[cd]
echo "RESULT dcop_sp_i0.39_XDN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = v(rxg_sp) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdlp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdlp.d0[cd]
echo "RESULT dcop_sp_i0.39_XDLP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(rxg_sp)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdln.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdln.d0[cd]
echo "RESULT dcop_sp_i0.39_XDLN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vrsa = maximum(abs(v(rxg_sp) - v(pad_sp)))
echo "RESULT dcop_sp_i0.39_XRS vabs_V=$&vrsa validity=no_validity_range_on_record current_validity=no_current_validity_range_on_record"
alter Iin_sp = 0.395
op
let vp = v(pad_sp)
let vr = v(rxg_sp)
let ikcl = @d.xsp.xdp.d0[id] - @d.xsp.xdn.d0[id] + @d.xsp.xdlp.d0[id] - @d.xsp.xdln.d0[id]
let ikerr = ikcl - (0.395)
echo "RESULT dcop_sp_i0.395 i_forced_A=0.395 i_esd2_pk_A=1.33333 vddio_V=3.3 vpad_V=$&vp vrxg_V=$&vr i_kcl_A=$&ikcl i_kcl_err_A=$&ikerr"
let vf = v(pad_sp) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdp.d0[cd]
echo "RESULT dcop_sp_i0.395_XDP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(pad_sp)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdn.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdn.d0[cd]
echo "RESULT dcop_sp_i0.395_XDN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = v(rxg_sp) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdlp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdlp.d0[cd]
echo "RESULT dcop_sp_i0.395_XDLP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(rxg_sp)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdln.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdln.d0[cd]
echo "RESULT dcop_sp_i0.395_XDLN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vrsa = maximum(abs(v(rxg_sp) - v(pad_sp)))
echo "RESULT dcop_sp_i0.395_XRS vabs_V=$&vrsa validity=no_validity_range_on_record current_validity=no_current_validity_range_on_record"
alter Iin_sp = 0.4
op
let vp = v(pad_sp)
let vr = v(rxg_sp)
let ikcl = @d.xsp.xdp.d0[id] - @d.xsp.xdn.d0[id] + @d.xsp.xdlp.d0[id] - @d.xsp.xdln.d0[id]
let ikerr = ikcl - (0.4)
echo "RESULT dcop_sp_i0.4 i_forced_A=0.4 i_esd2_pk_A=1.33333 vddio_V=3.3 vpad_V=$&vp vrxg_V=$&vr i_kcl_A=$&ikcl i_kcl_err_A=$&ikerr"
let vf = v(pad_sp) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdp.d0[cd]
echo "RESULT dcop_sp_i0.4_XDP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(pad_sp)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdn.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdn.d0[cd]
echo "RESULT dcop_sp_i0.4_XDN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = v(rxg_sp) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdlp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdlp.d0[cd]
echo "RESULT dcop_sp_i0.4_XDLP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(rxg_sp)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdln.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdln.d0[cd]
echo "RESULT dcop_sp_i0.4_XDLN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vrsa = maximum(abs(v(rxg_sp) - v(pad_sp)))
echo "RESULT dcop_sp_i0.4_XRS vabs_V=$&vrsa validity=no_validity_range_on_record current_validity=no_current_validity_range_on_record"
alter Iin_sp = 0.42
op
let vp = v(pad_sp)
let vr = v(rxg_sp)
let ikcl = @d.xsp.xdp.d0[id] - @d.xsp.xdn.d0[id] + @d.xsp.xdlp.d0[id] - @d.xsp.xdln.d0[id]
let ikerr = ikcl - (0.42)
echo "RESULT dcop_sp_i0.42 i_forced_A=0.42 i_esd2_pk_A=1.33333 vddio_V=3.3 vpad_V=$&vp vrxg_V=$&vr i_kcl_A=$&ikcl i_kcl_err_A=$&ikerr"
let vf = v(pad_sp) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdp.d0[cd]
echo "RESULT dcop_sp_i0.42_XDP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(pad_sp)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdn.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdn.d0[cd]
echo "RESULT dcop_sp_i0.42_XDN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = v(rxg_sp) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdlp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdlp.d0[cd]
echo "RESULT dcop_sp_i0.42_XDLP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(rxg_sp)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdln.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdln.d0[cd]
echo "RESULT dcop_sp_i0.42_XDLN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vrsa = maximum(abs(v(rxg_sp) - v(pad_sp)))
echo "RESULT dcop_sp_i0.42_XRS vabs_V=$&vrsa validity=no_validity_range_on_record current_validity=no_current_validity_range_on_record"
alter Iin_sp = 0.5
op
let vp = v(pad_sp)
let vr = v(rxg_sp)
let ikcl = @d.xsp.xdp.d0[id] - @d.xsp.xdn.d0[id] + @d.xsp.xdlp.d0[id] - @d.xsp.xdln.d0[id]
let ikerr = ikcl - (0.5)
echo "RESULT dcop_sp_i0.5 i_forced_A=0.5 i_esd2_pk_A=1.33333 vddio_V=3.3 vpad_V=$&vp vrxg_V=$&vr i_kcl_A=$&ikcl i_kcl_err_A=$&ikerr"
let vf = v(pad_sp) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdp.d0[cd]
echo "RESULT dcop_sp_i0.5_XDP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(pad_sp)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdn.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdn.d0[cd]
echo "RESULT dcop_sp_i0.5_XDN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = v(rxg_sp) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdlp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdlp.d0[cd]
echo "RESULT dcop_sp_i0.5_XDLP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(rxg_sp)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdln.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdln.d0[cd]
echo "RESULT dcop_sp_i0.5_XDLN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vrsa = maximum(abs(v(rxg_sp) - v(pad_sp)))
echo "RESULT dcop_sp_i0.5_XRS vabs_V=$&vrsa validity=no_validity_range_on_record current_validity=no_current_validity_range_on_record"
alter Iin_sp = 6.66667e-1
op
let vp = v(pad_sp)
let vr = v(rxg_sp)
let ikcl = @d.xsp.xdp.d0[id] - @d.xsp.xdn.d0[id] + @d.xsp.xdlp.d0[id] - @d.xsp.xdln.d0[id]
let ikerr = ikcl - (6.66667e-1)
echo "RESULT dcop_sp_i6.66667e-1 i_forced_A=6.66667e-1 i_esd2_pk_A=1.33333 vddio_V=3.3 vpad_V=$&vp vrxg_V=$&vr i_kcl_A=$&ikcl i_kcl_err_A=$&ikerr"
let vf = v(pad_sp) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdp.d0[cd]
echo "RESULT dcop_sp_i6.66667e-1_XDP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(pad_sp)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdn.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdn.d0[cd]
echo "RESULT dcop_sp_i6.66667e-1_XDN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = v(rxg_sp) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdlp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdlp.d0[cd]
echo "RESULT dcop_sp_i6.66667e-1_XDLP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(rxg_sp)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdln.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdln.d0[cd]
echo "RESULT dcop_sp_i6.66667e-1_XDLN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vrsa = maximum(abs(v(rxg_sp) - v(pad_sp)))
echo "RESULT dcop_sp_i6.66667e-1_XRS vabs_V=$&vrsa validity=no_validity_range_on_record current_validity=no_current_validity_range_on_record"
alter Iin_sp = 1.0
op
let vp = v(pad_sp)
let vr = v(rxg_sp)
let ikcl = @d.xsp.xdp.d0[id] - @d.xsp.xdn.d0[id] + @d.xsp.xdlp.d0[id] - @d.xsp.xdln.d0[id]
let ikerr = ikcl - (1.0)
echo "RESULT dcop_sp_i1.0 i_forced_A=1.0 i_esd2_pk_A=1.33333 vddio_V=3.3 vpad_V=$&vp vrxg_V=$&vr i_kcl_A=$&ikcl i_kcl_err_A=$&ikerr"
let vf = v(pad_sp) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdp.d0[cd]
echo "RESULT dcop_sp_i1.0_XDP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(pad_sp)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdn.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdn.d0[cd]
echo "RESULT dcop_sp_i1.0_XDN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = v(rxg_sp) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdlp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdlp.d0[cd]
echo "RESULT dcop_sp_i1.0_XDLP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(rxg_sp)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdln.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdln.d0[cd]
echo "RESULT dcop_sp_i1.0_XDLN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vrsa = maximum(abs(v(rxg_sp) - v(pad_sp)))
echo "RESULT dcop_sp_i1.0_XRS vabs_V=$&vrsa validity=no_validity_range_on_record current_validity=no_current_validity_range_on_record"
alter Iin_sp = 1.33333
op
let vp = v(pad_sp)
let vr = v(rxg_sp)
let ikcl = @d.xsp.xdp.d0[id] - @d.xsp.xdn.d0[id] + @d.xsp.xdlp.d0[id] - @d.xsp.xdln.d0[id]
let ikerr = ikcl - (1.33333)
echo "RESULT dcop_sp_i1.33333 i_forced_A=1.33333 i_esd2_pk_A=1.33333 vddio_V=3.3 vpad_V=$&vp vrxg_V=$&vr i_kcl_A=$&ikcl i_kcl_err_A=$&ikerr"
let vf = v(pad_sp) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdp.d0[cd]
echo "RESULT dcop_sp_i1.33333_XDP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(pad_sp)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdn.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdn.d0[cd]
echo "RESULT dcop_sp_i1.33333_XDN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = v(rxg_sp) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdlp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdlp.d0[cd]
echo "RESULT dcop_sp_i1.33333_XDLP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(rxg_sp)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdln.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdln.d0[cd]
echo "RESULT dcop_sp_i1.33333_XDLN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vrsa = maximum(abs(v(rxg_sp) - v(pad_sp)))
echo "RESULT dcop_sp_i1.33333_XRS vabs_V=$&vrsa validity=no_validity_range_on_record current_validity=no_current_validity_range_on_record"
alter Iin_sp = 0
alter Iin_sp = 0
alter Iin_sn = 0
op
let vp = v(pad_sn)
let vr = v(rxg_sn)
let ikcl = @d.xsn.xdp.d0[id] - @d.xsn.xdn.d0[id] + @d.xsn.xdlp.d0[id] - @d.xsn.xdln.d0[id]
let ikerr = ikcl - (-0)
echo "RESULT dcop_sn_i0 i_forced_A=-0 i_esd2_pk_A=1.33333 vddio_V=3.3 vpad_V=$&vp vrxg_V=$&vr i_kcl_A=$&ikcl i_kcl_err_A=$&ikerr"
let vf = v(pad_sn) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdp.d0[cd]
echo "RESULT dcop_sn_i0_XDP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(pad_sn)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdn.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdn.d0[cd]
echo "RESULT dcop_sn_i0_XDN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = v(rxg_sn) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdlp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdlp.d0[cd]
echo "RESULT dcop_sn_i0_XDLP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(rxg_sn)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdln.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdln.d0[cd]
echo "RESULT dcop_sn_i0_XDLN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vrsa = maximum(abs(v(rxg_sn) - v(pad_sn)))
echo "RESULT dcop_sn_i0_XRS vabs_V=$&vrsa validity=no_validity_range_on_record current_validity=no_current_validity_range_on_record"
alter Iin_sn = 1.33333e-3
op
let vp = v(pad_sn)
let vr = v(rxg_sn)
let ikcl = @d.xsn.xdp.d0[id] - @d.xsn.xdn.d0[id] + @d.xsn.xdlp.d0[id] - @d.xsn.xdln.d0[id]
let ikerr = ikcl - (-1.33333e-3)
echo "RESULT dcop_sn_i1.33333e-3 i_forced_A=-1.33333e-3 i_esd2_pk_A=1.33333 vddio_V=3.3 vpad_V=$&vp vrxg_V=$&vr i_kcl_A=$&ikcl i_kcl_err_A=$&ikerr"
let vf = v(pad_sn) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdp.d0[cd]
echo "RESULT dcop_sn_i1.33333e-3_XDP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(pad_sn)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdn.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdn.d0[cd]
echo "RESULT dcop_sn_i1.33333e-3_XDN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = v(rxg_sn) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdlp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdlp.d0[cd]
echo "RESULT dcop_sn_i1.33333e-3_XDLP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(rxg_sn)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdln.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdln.d0[cd]
echo "RESULT dcop_sn_i1.33333e-3_XDLN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vrsa = maximum(abs(v(rxg_sn) - v(pad_sn)))
echo "RESULT dcop_sn_i1.33333e-3_XRS vabs_V=$&vrsa validity=no_validity_range_on_record current_validity=no_current_validity_range_on_record"
alter Iin_sn = 1.33333e-2
op
let vp = v(pad_sn)
let vr = v(rxg_sn)
let ikcl = @d.xsn.xdp.d0[id] - @d.xsn.xdn.d0[id] + @d.xsn.xdlp.d0[id] - @d.xsn.xdln.d0[id]
let ikerr = ikcl - (-1.33333e-2)
echo "RESULT dcop_sn_i1.33333e-2 i_forced_A=-1.33333e-2 i_esd2_pk_A=1.33333 vddio_V=3.3 vpad_V=$&vp vrxg_V=$&vr i_kcl_A=$&ikcl i_kcl_err_A=$&ikerr"
let vf = v(pad_sn) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdp.d0[cd]
echo "RESULT dcop_sn_i1.33333e-2_XDP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(pad_sn)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdn.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdn.d0[cd]
echo "RESULT dcop_sn_i1.33333e-2_XDN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = v(rxg_sn) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdlp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdlp.d0[cd]
echo "RESULT dcop_sn_i1.33333e-2_XDLP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(rxg_sn)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdln.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdln.d0[cd]
echo "RESULT dcop_sn_i1.33333e-2_XDLN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vrsa = maximum(abs(v(rxg_sn) - v(pad_sn)))
echo "RESULT dcop_sn_i1.33333e-2_XRS vabs_V=$&vrsa validity=no_validity_range_on_record current_validity=no_current_validity_range_on_record"
alter Iin_sn = 1.33333e-1
op
let vp = v(pad_sn)
let vr = v(rxg_sn)
let ikcl = @d.xsn.xdp.d0[id] - @d.xsn.xdn.d0[id] + @d.xsn.xdlp.d0[id] - @d.xsn.xdln.d0[id]
let ikerr = ikcl - (-1.33333e-1)
echo "RESULT dcop_sn_i1.33333e-1 i_forced_A=-1.33333e-1 i_esd2_pk_A=1.33333 vddio_V=3.3 vpad_V=$&vp vrxg_V=$&vr i_kcl_A=$&ikcl i_kcl_err_A=$&ikerr"
let vf = v(pad_sn) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdp.d0[cd]
echo "RESULT dcop_sn_i1.33333e-1_XDP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(pad_sn)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdn.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdn.d0[cd]
echo "RESULT dcop_sn_i1.33333e-1_XDN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = v(rxg_sn) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdlp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdlp.d0[cd]
echo "RESULT dcop_sn_i1.33333e-1_XDLP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(rxg_sn)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdln.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdln.d0[cd]
echo "RESULT dcop_sn_i1.33333e-1_XDLN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vrsa = maximum(abs(v(rxg_sn) - v(pad_sn)))
echo "RESULT dcop_sn_i1.33333e-1_XRS vabs_V=$&vrsa validity=no_validity_range_on_record current_validity=no_current_validity_range_on_record"
alter Iin_sn = 0.3
op
let vp = v(pad_sn)
let vr = v(rxg_sn)
let ikcl = @d.xsn.xdp.d0[id] - @d.xsn.xdn.d0[id] + @d.xsn.xdlp.d0[id] - @d.xsn.xdln.d0[id]
let ikerr = ikcl - (-0.3)
echo "RESULT dcop_sn_i0.3 i_forced_A=-0.3 i_esd2_pk_A=1.33333 vddio_V=3.3 vpad_V=$&vp vrxg_V=$&vr i_kcl_A=$&ikcl i_kcl_err_A=$&ikerr"
let vf = v(pad_sn) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdp.d0[cd]
echo "RESULT dcop_sn_i0.3_XDP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(pad_sn)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdn.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdn.d0[cd]
echo "RESULT dcop_sn_i0.3_XDN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = v(rxg_sn) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdlp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdlp.d0[cd]
echo "RESULT dcop_sn_i0.3_XDLP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(rxg_sn)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdln.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdln.d0[cd]
echo "RESULT dcop_sn_i0.3_XDLN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vrsa = maximum(abs(v(rxg_sn) - v(pad_sn)))
echo "RESULT dcop_sn_i0.3_XRS vabs_V=$&vrsa validity=no_validity_range_on_record current_validity=no_current_validity_range_on_record"
alter Iin_sn = 0.38
op
let vp = v(pad_sn)
let vr = v(rxg_sn)
let ikcl = @d.xsn.xdp.d0[id] - @d.xsn.xdn.d0[id] + @d.xsn.xdlp.d0[id] - @d.xsn.xdln.d0[id]
let ikerr = ikcl - (-0.38)
echo "RESULT dcop_sn_i0.38 i_forced_A=-0.38 i_esd2_pk_A=1.33333 vddio_V=3.3 vpad_V=$&vp vrxg_V=$&vr i_kcl_A=$&ikcl i_kcl_err_A=$&ikerr"
let vf = v(pad_sn) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdp.d0[cd]
echo "RESULT dcop_sn_i0.38_XDP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(pad_sn)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdn.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdn.d0[cd]
echo "RESULT dcop_sn_i0.38_XDN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = v(rxg_sn) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdlp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdlp.d0[cd]
echo "RESULT dcop_sn_i0.38_XDLP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(rxg_sn)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdln.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdln.d0[cd]
echo "RESULT dcop_sn_i0.38_XDLN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vrsa = maximum(abs(v(rxg_sn) - v(pad_sn)))
echo "RESULT dcop_sn_i0.38_XRS vabs_V=$&vrsa validity=no_validity_range_on_record current_validity=no_current_validity_range_on_record"
alter Iin_sn = 0.39
op
let vp = v(pad_sn)
let vr = v(rxg_sn)
let ikcl = @d.xsn.xdp.d0[id] - @d.xsn.xdn.d0[id] + @d.xsn.xdlp.d0[id] - @d.xsn.xdln.d0[id]
let ikerr = ikcl - (-0.39)
echo "RESULT dcop_sn_i0.39 i_forced_A=-0.39 i_esd2_pk_A=1.33333 vddio_V=3.3 vpad_V=$&vp vrxg_V=$&vr i_kcl_A=$&ikcl i_kcl_err_A=$&ikerr"
let vf = v(pad_sn) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdp.d0[cd]
echo "RESULT dcop_sn_i0.39_XDP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(pad_sn)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdn.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdn.d0[cd]
echo "RESULT dcop_sn_i0.39_XDN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = v(rxg_sn) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdlp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdlp.d0[cd]
echo "RESULT dcop_sn_i0.39_XDLP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(rxg_sn)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdln.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdln.d0[cd]
echo "RESULT dcop_sn_i0.39_XDLN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vrsa = maximum(abs(v(rxg_sn) - v(pad_sn)))
echo "RESULT dcop_sn_i0.39_XRS vabs_V=$&vrsa validity=no_validity_range_on_record current_validity=no_current_validity_range_on_record"
alter Iin_sn = 0.395
op
let vp = v(pad_sn)
let vr = v(rxg_sn)
let ikcl = @d.xsn.xdp.d0[id] - @d.xsn.xdn.d0[id] + @d.xsn.xdlp.d0[id] - @d.xsn.xdln.d0[id]
let ikerr = ikcl - (-0.395)
echo "RESULT dcop_sn_i0.395 i_forced_A=-0.395 i_esd2_pk_A=1.33333 vddio_V=3.3 vpad_V=$&vp vrxg_V=$&vr i_kcl_A=$&ikcl i_kcl_err_A=$&ikerr"
let vf = v(pad_sn) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdp.d0[cd]
echo "RESULT dcop_sn_i0.395_XDP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(pad_sn)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdn.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdn.d0[cd]
echo "RESULT dcop_sn_i0.395_XDN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = v(rxg_sn) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdlp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdlp.d0[cd]
echo "RESULT dcop_sn_i0.395_XDLP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(rxg_sn)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdln.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdln.d0[cd]
echo "RESULT dcop_sn_i0.395_XDLN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vrsa = maximum(abs(v(rxg_sn) - v(pad_sn)))
echo "RESULT dcop_sn_i0.395_XRS vabs_V=$&vrsa validity=no_validity_range_on_record current_validity=no_current_validity_range_on_record"
alter Iin_sn = 0.4
op
let vp = v(pad_sn)
let vr = v(rxg_sn)
let ikcl = @d.xsn.xdp.d0[id] - @d.xsn.xdn.d0[id] + @d.xsn.xdlp.d0[id] - @d.xsn.xdln.d0[id]
let ikerr = ikcl - (-0.4)
echo "RESULT dcop_sn_i0.4 i_forced_A=-0.4 i_esd2_pk_A=1.33333 vddio_V=3.3 vpad_V=$&vp vrxg_V=$&vr i_kcl_A=$&ikcl i_kcl_err_A=$&ikerr"
let vf = v(pad_sn) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdp.d0[cd]
echo "RESULT dcop_sn_i0.4_XDP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(pad_sn)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdn.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdn.d0[cd]
echo "RESULT dcop_sn_i0.4_XDN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = v(rxg_sn) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdlp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdlp.d0[cd]
echo "RESULT dcop_sn_i0.4_XDLP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(rxg_sn)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdln.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdln.d0[cd]
echo "RESULT dcop_sn_i0.4_XDLN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vrsa = maximum(abs(v(rxg_sn) - v(pad_sn)))
echo "RESULT dcop_sn_i0.4_XRS vabs_V=$&vrsa validity=no_validity_range_on_record current_validity=no_current_validity_range_on_record"
alter Iin_sn = 0.42
op
let vp = v(pad_sn)
let vr = v(rxg_sn)
let ikcl = @d.xsn.xdp.d0[id] - @d.xsn.xdn.d0[id] + @d.xsn.xdlp.d0[id] - @d.xsn.xdln.d0[id]
let ikerr = ikcl - (-0.42)
echo "RESULT dcop_sn_i0.42 i_forced_A=-0.42 i_esd2_pk_A=1.33333 vddio_V=3.3 vpad_V=$&vp vrxg_V=$&vr i_kcl_A=$&ikcl i_kcl_err_A=$&ikerr"
let vf = v(pad_sn) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdp.d0[cd]
echo "RESULT dcop_sn_i0.42_XDP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(pad_sn)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdn.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdn.d0[cd]
echo "RESULT dcop_sn_i0.42_XDN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = v(rxg_sn) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdlp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdlp.d0[cd]
echo "RESULT dcop_sn_i0.42_XDLP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(rxg_sn)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdln.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdln.d0[cd]
echo "RESULT dcop_sn_i0.42_XDLN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vrsa = maximum(abs(v(rxg_sn) - v(pad_sn)))
echo "RESULT dcop_sn_i0.42_XRS vabs_V=$&vrsa validity=no_validity_range_on_record current_validity=no_current_validity_range_on_record"
alter Iin_sn = 0.5
op
let vp = v(pad_sn)
let vr = v(rxg_sn)
let ikcl = @d.xsn.xdp.d0[id] - @d.xsn.xdn.d0[id] + @d.xsn.xdlp.d0[id] - @d.xsn.xdln.d0[id]
let ikerr = ikcl - (-0.5)
echo "RESULT dcop_sn_i0.5 i_forced_A=-0.5 i_esd2_pk_A=1.33333 vddio_V=3.3 vpad_V=$&vp vrxg_V=$&vr i_kcl_A=$&ikcl i_kcl_err_A=$&ikerr"
let vf = v(pad_sn) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdp.d0[cd]
echo "RESULT dcop_sn_i0.5_XDP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(pad_sn)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdn.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdn.d0[cd]
echo "RESULT dcop_sn_i0.5_XDN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = v(rxg_sn) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdlp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdlp.d0[cd]
echo "RESULT dcop_sn_i0.5_XDLP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(rxg_sn)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdln.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdln.d0[cd]
echo "RESULT dcop_sn_i0.5_XDLN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vrsa = maximum(abs(v(rxg_sn) - v(pad_sn)))
echo "RESULT dcop_sn_i0.5_XRS vabs_V=$&vrsa validity=no_validity_range_on_record current_validity=no_current_validity_range_on_record"
alter Iin_sn = 6.66667e-1
op
let vp = v(pad_sn)
let vr = v(rxg_sn)
let ikcl = @d.xsn.xdp.d0[id] - @d.xsn.xdn.d0[id] + @d.xsn.xdlp.d0[id] - @d.xsn.xdln.d0[id]
let ikerr = ikcl - (-6.66667e-1)
echo "RESULT dcop_sn_i6.66667e-1 i_forced_A=-6.66667e-1 i_esd2_pk_A=1.33333 vddio_V=3.3 vpad_V=$&vp vrxg_V=$&vr i_kcl_A=$&ikcl i_kcl_err_A=$&ikerr"
let vf = v(pad_sn) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdp.d0[cd]
echo "RESULT dcop_sn_i6.66667e-1_XDP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(pad_sn)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdn.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdn.d0[cd]
echo "RESULT dcop_sn_i6.66667e-1_XDN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = v(rxg_sn) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdlp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdlp.d0[cd]
echo "RESULT dcop_sn_i6.66667e-1_XDLP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(rxg_sn)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdln.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdln.d0[cd]
echo "RESULT dcop_sn_i6.66667e-1_XDLN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vrsa = maximum(abs(v(rxg_sn) - v(pad_sn)))
echo "RESULT dcop_sn_i6.66667e-1_XRS vabs_V=$&vrsa validity=no_validity_range_on_record current_validity=no_current_validity_range_on_record"
alter Iin_sn = 1.0
op
let vp = v(pad_sn)
let vr = v(rxg_sn)
let ikcl = @d.xsn.xdp.d0[id] - @d.xsn.xdn.d0[id] + @d.xsn.xdlp.d0[id] - @d.xsn.xdln.d0[id]
let ikerr = ikcl - (-1.0)
echo "RESULT dcop_sn_i1.0 i_forced_A=-1.0 i_esd2_pk_A=1.33333 vddio_V=3.3 vpad_V=$&vp vrxg_V=$&vr i_kcl_A=$&ikcl i_kcl_err_A=$&ikerr"
let vf = v(pad_sn) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdp.d0[cd]
echo "RESULT dcop_sn_i1.0_XDP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(pad_sn)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdn.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdn.d0[cd]
echo "RESULT dcop_sn_i1.0_XDN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = v(rxg_sn) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdlp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdlp.d0[cd]
echo "RESULT dcop_sn_i1.0_XDLP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(rxg_sn)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdln.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdln.d0[cd]
echo "RESULT dcop_sn_i1.0_XDLN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vrsa = maximum(abs(v(rxg_sn) - v(pad_sn)))
echo "RESULT dcop_sn_i1.0_XRS vabs_V=$&vrsa validity=no_validity_range_on_record current_validity=no_current_validity_range_on_record"
alter Iin_sn = 1.33333
op
let vp = v(pad_sn)
let vr = v(rxg_sn)
let ikcl = @d.xsn.xdp.d0[id] - @d.xsn.xdn.d0[id] + @d.xsn.xdlp.d0[id] - @d.xsn.xdln.d0[id]
let ikerr = ikcl - (-1.33333)
echo "RESULT dcop_sn_i1.33333 i_forced_A=-1.33333 i_esd2_pk_A=1.33333 vddio_V=3.3 vpad_V=$&vp vrxg_V=$&vr i_kcl_A=$&ikcl i_kcl_err_A=$&ikerr"
let vf = v(pad_sn) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdp.d0[cd]
echo "RESULT dcop_sn_i1.33333_XDP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(pad_sn)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdn.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdn.d0[cd]
echo "RESULT dcop_sn_i1.33333_XDN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = v(rxg_sn) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdlp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdlp.d0[cd]
echo "RESULT dcop_sn_i1.33333_XDLP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(rxg_sn)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdln.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdln.d0[cd]
echo "RESULT dcop_sn_i1.33333_XDLN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vrsa = maximum(abs(v(rxg_sn) - v(pad_sn)))
echo "RESULT dcop_sn_i1.33333_XRS vabs_V=$&vrsa validity=no_validity_range_on_record current_validity=no_current_validity_range_on_record"
alter Iin_sn = 0
alter Vddio = 2.97
alter Iin_sn = 0
alter Iin_sp = 1.33333
op
let vp = v(pad_sp)
let vr = v(rxg_sp)
let ikcl = @d.xsp.xdp.d0[id] - @d.xsp.xdn.d0[id] + @d.xsp.xdlp.d0[id] - @d.xsp.xdln.d0[id]
let ikerr = ikcl - (1.33333)
echo "RESULT supply_sp_vddio2.97 i_forced_A=1.33333 i_esd2_pk_A=1.33333 vddio_V=2.97 vpad_V=$&vp vrxg_V=$&vr i_kcl_A=$&ikcl i_kcl_err_A=$&ikerr"
let vf = v(pad_sp) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdp.d0[cd]
echo "RESULT supply_sp_vddio2.97_XDP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(pad_sp)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdn.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdn.d0[cd]
echo "RESULT supply_sp_vddio2.97_XDN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = v(rxg_sp) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdlp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdlp.d0[cd]
echo "RESULT supply_sp_vddio2.97_XDLP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(rxg_sp)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdln.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdln.d0[cd]
echo "RESULT supply_sp_vddio2.97_XDLN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vrsa = maximum(abs(v(rxg_sp) - v(pad_sp)))
echo "RESULT supply_sp_vddio2.97_XRS vabs_V=$&vrsa validity=no_validity_range_on_record current_validity=no_current_validity_range_on_record"
alter Iin_sp = 0
alter Iin_sp = 0
alter Iin_sn = 1.33333
op
let vp = v(pad_sn)
let vr = v(rxg_sn)
let ikcl = @d.xsn.xdp.d0[id] - @d.xsn.xdn.d0[id] + @d.xsn.xdlp.d0[id] - @d.xsn.xdln.d0[id]
let ikerr = ikcl - (-1.33333)
echo "RESULT supply_sn_vddio2.97 i_forced_A=-1.33333 i_esd2_pk_A=1.33333 vddio_V=2.97 vpad_V=$&vp vrxg_V=$&vr i_kcl_A=$&ikcl i_kcl_err_A=$&ikerr"
let vf = v(pad_sn) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdp.d0[cd]
echo "RESULT supply_sn_vddio2.97_XDP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(pad_sn)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdn.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdn.d0[cd]
echo "RESULT supply_sn_vddio2.97_XDN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = v(rxg_sn) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdlp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdlp.d0[cd]
echo "RESULT supply_sn_vddio2.97_XDLP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(rxg_sn)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdln.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdln.d0[cd]
echo "RESULT supply_sn_vddio2.97_XDLN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vrsa = maximum(abs(v(rxg_sn) - v(pad_sn)))
echo "RESULT supply_sn_vddio2.97_XRS vabs_V=$&vrsa validity=no_validity_range_on_record current_validity=no_current_validity_range_on_record"
alter Iin_sn = 0
alter Vddio = 3.63
alter Iin_sn = 0
alter Iin_sp = 1.33333
op
let vp = v(pad_sp)
let vr = v(rxg_sp)
let ikcl = @d.xsp.xdp.d0[id] - @d.xsp.xdn.d0[id] + @d.xsp.xdlp.d0[id] - @d.xsp.xdln.d0[id]
let ikerr = ikcl - (1.33333)
echo "RESULT supply_sp_vddio3.63 i_forced_A=1.33333 i_esd2_pk_A=1.33333 vddio_V=3.63 vpad_V=$&vp vrxg_V=$&vr i_kcl_A=$&ikcl i_kcl_err_A=$&ikerr"
let vf = v(pad_sp) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdp.d0[cd]
echo "RESULT supply_sp_vddio3.63_XDP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(pad_sp)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdn.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdn.d0[cd]
echo "RESULT supply_sp_vddio3.63_XDN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = v(rxg_sp) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdlp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdlp.d0[cd]
echo "RESULT supply_sp_vddio3.63_XDLP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(rxg_sp)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdln.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdln.d0[cd]
echo "RESULT supply_sp_vddio3.63_XDLN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vrsa = maximum(abs(v(rxg_sp) - v(pad_sp)))
echo "RESULT supply_sp_vddio3.63_XRS vabs_V=$&vrsa validity=no_validity_range_on_record current_validity=no_current_validity_range_on_record"
alter Iin_sp = 0
alter Iin_sp = 0
alter Iin_sn = 1.33333
op
let vp = v(pad_sn)
let vr = v(rxg_sn)
let ikcl = @d.xsn.xdp.d0[id] - @d.xsn.xdn.d0[id] + @d.xsn.xdlp.d0[id] - @d.xsn.xdln.d0[id]
let ikerr = ikcl - (-1.33333)
echo "RESULT supply_sn_vddio3.63 i_forced_A=-1.33333 i_esd2_pk_A=1.33333 vddio_V=3.63 vpad_V=$&vp vrxg_V=$&vr i_kcl_A=$&ikcl i_kcl_err_A=$&ikerr"
let vf = v(pad_sn) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdp.d0[cd]
echo "RESULT supply_sn_vddio3.63_XDP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(pad_sn)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdn.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdn.d0[cd]
echo "RESULT supply_sn_vddio3.63_XDN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = v(rxg_sn) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdlp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdlp.d0[cd]
echo "RESULT supply_sn_vddio3.63_XDLP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(rxg_sn)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdln.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdln.d0[cd]
echo "RESULT supply_sn_vddio3.63_XDLN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vrsa = maximum(abs(v(rxg_sn) - v(pad_sn)))
echo "RESULT supply_sn_vddio3.63_XRS vabs_V=$&vrsa validity=no_validity_range_on_record current_validity=no_current_validity_range_on_record"
alter Iin_sn = 0
alter Vddio = 5.0
alter Iin_sn = 0
alter Iin_sp = 1.33333
op
let vp = v(pad_sp)
let vr = v(rxg_sp)
let ikcl = @d.xsp.xdp.d0[id] - @d.xsp.xdn.d0[id] + @d.xsp.xdlp.d0[id] - @d.xsp.xdln.d0[id]
let ikerr = ikcl - (1.33333)
echo "RESULT supply_sp_vddio5.0 i_forced_A=1.33333 i_esd2_pk_A=1.33333 vddio_V=5.0 vpad_V=$&vp vrxg_V=$&vr i_kcl_A=$&ikcl i_kcl_err_A=$&ikerr"
let vf = v(pad_sp) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdp.d0[cd]
echo "RESULT supply_sp_vddio5.0_XDP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(pad_sp)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdn.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdn.d0[cd]
echo "RESULT supply_sp_vddio5.0_XDN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = v(rxg_sp) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdlp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdlp.d0[cd]
echo "RESULT supply_sp_vddio5.0_XDLP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(rxg_sp)
let vapk = maximum(abs(vf))
let idv = @d.xsp.xdln.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsp.xdln.d0[cd]
echo "RESULT supply_sp_vddio5.0_XDLN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vrsa = maximum(abs(v(rxg_sp) - v(pad_sp)))
echo "RESULT supply_sp_vddio5.0_XRS vabs_V=$&vrsa validity=no_validity_range_on_record current_validity=no_current_validity_range_on_record"
alter Iin_sp = 0
alter Iin_sp = 0
alter Iin_sn = 1.33333
op
let vp = v(pad_sn)
let vr = v(rxg_sn)
let ikcl = @d.xsn.xdp.d0[id] - @d.xsn.xdn.d0[id] + @d.xsn.xdlp.d0[id] - @d.xsn.xdln.d0[id]
let ikerr = ikcl - (-1.33333)
echo "RESULT supply_sn_vddio5.0 i_forced_A=-1.33333 i_esd2_pk_A=1.33333 vddio_V=5.0 vpad_V=$&vp vrxg_V=$&vr i_kcl_A=$&ikcl i_kcl_err_A=$&ikerr"
let vf = v(pad_sn) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdp.d0[cd]
echo "RESULT supply_sn_vddio5.0_XDP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(pad_sn)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdn.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdn.d0[cd]
echo "RESULT supply_sn_vddio5.0_XDN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = v(rxg_sn) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdlp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdlp.d0[cd]
echo "RESULT supply_sn_vddio5.0_XDLP vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(rxg_sn)
let vapk = maximum(abs(vf))
let idv = @d.xsn.xdln.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let cdv = @d.xsn.xdln.d0[cd]
echo "RESULT supply_sn_vddio5.0_XDLN vfwd_V=$&vf id_A=$&idv cd_F=$&cdv vabs_V=$&vapk validity=$lab current_validity=no_current_validity_range_on_record"
let vrsa = maximum(abs(v(rxg_sn) - v(pad_sn)))
echo "RESULT supply_sn_vddio5.0_XRS vabs_V=$&vrsa validity=no_validity_range_on_record current_validity=no_current_validity_range_on_record"
alter Iin_sn = 0
alter Vddio = 3.3
alter Iin_sp = 0
alter Iin_sn = 0
tran 0.02n 2u 0 0.1n
let ii = abs(v(h_pa) - v(pad_pa)) / 1500
let ipk = maximum(ii)
let mk_pa = (ii > 0.9999*ipk)
let tat = minimum(time*mk_pa + (1-mk_pa)*1e9)
let vpmin = minimum(v(pad_pa))
let vpmax = maximum(v(pad_pa))
let vpexc = vpmax - vpmin
let vcat = minimum((v(pad_pa) - v(vddio))*mk_pa + (1-mk_pa)*1e9)
if ( vcat > 0 )
  set fs = positive
  set fd = developed
else
  set fs = not_forward_biased
  set fd = not_developed
end
echo "RESULT pulse_pa vhbm_V=2000 c_F=100p r_ohm=1500 decay_tau_s=1.5e-7 t_fire_s=50n rail=vddio vddio_V=3.3 state=natural_operating_point ic_pad_rxg_V=none pad_bleed_1Gohm=0 i_esd2_pk_A=1.33333 ipulse_pk_A=$&ipk t_ipk_s=$&tat vpad_min_V=$&vpmin vpad_max_V=$&vpmax vpad_excursion_V=$&vpexc conducting=XDP vfwd_cond_at_ipk_V=$&vcat fwd_sign=$fs pulse_forward_drop=$fd"
let vf = v(pad_pa) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xpa.xdp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let vfmax = maximum(vf)
let vrmax = maximum(-vf)
let idmin = minimum(idv)
let idmax = maximum(idv)
let vfat = minimum(vf*mk_pa + (1-mk_pa)*1e9)
let idat = minimum(idv*mk_pa + (1-mk_pa)*1e9)
echo "RESULT pulse_pa_XDP vfwd_at_ipk_V=$&vfat id_at_ipk_A=$&idat vfwd_max_V=$&vfmax vrev_max_V=$&vrmax vabs_max_V=$&vapk id_min_A=$&idmin id_max_A=$&idmax validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(pad_pa)
let vapk = maximum(abs(vf))
let idv = @d.xpa.xdn.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let vfmax = maximum(vf)
let vrmax = maximum(-vf)
let idmin = minimum(idv)
let idmax = maximum(idv)
let vfat = minimum(vf*mk_pa + (1-mk_pa)*1e9)
let idat = minimum(idv*mk_pa + (1-mk_pa)*1e9)
echo "RESULT pulse_pa_XDN vfwd_at_ipk_V=$&vfat id_at_ipk_A=$&idat vfwd_max_V=$&vfmax vrev_max_V=$&vrmax vabs_max_V=$&vapk id_min_A=$&idmin id_max_A=$&idmax validity=$lab current_validity=no_current_validity_range_on_record"
let vf = v(rxg_pa) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xpa.xdlp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let vfmax = maximum(vf)
let vrmax = maximum(-vf)
let idmin = minimum(idv)
let idmax = maximum(idv)
let vfat = minimum(vf*mk_pa + (1-mk_pa)*1e9)
let idat = minimum(idv*mk_pa + (1-mk_pa)*1e9)
echo "RESULT pulse_pa_XDLP vfwd_at_ipk_V=$&vfat id_at_ipk_A=$&idat vfwd_max_V=$&vfmax vrev_max_V=$&vrmax vabs_max_V=$&vapk id_min_A=$&idmin id_max_A=$&idmax validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(rxg_pa)
let vapk = maximum(abs(vf))
let idv = @d.xpa.xdln.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let vfmax = maximum(vf)
let vrmax = maximum(-vf)
let idmin = minimum(idv)
let idmax = maximum(idv)
let vfat = minimum(vf*mk_pa + (1-mk_pa)*1e9)
let idat = minimum(idv*mk_pa + (1-mk_pa)*1e9)
echo "RESULT pulse_pa_XDLN vfwd_at_ipk_V=$&vfat id_at_ipk_A=$&idat vfwd_max_V=$&vfmax vrev_max_V=$&vrmax vabs_max_V=$&vapk id_min_A=$&idmin id_max_A=$&idmax validity=$lab current_validity=no_current_validity_range_on_record"
let vrsa = maximum(abs(v(rxg_pa) - v(pad_pa)))
echo "RESULT pulse_pa_XRS vabs_V=$&vrsa validity=no_validity_range_on_record current_validity=no_current_validity_range_on_record"
let ii = abs(v(h_pb) - v(pad_pb)) / 1500
let ipk = maximum(ii)
let mk_pb = (ii > 0.9999*ipk)
let tat = minimum(time*mk_pb + (1-mk_pb)*1e9)
let vpmin = minimum(v(pad_pb))
let vpmax = maximum(v(pad_pb))
let vpexc = vpmax - vpmin
let vcat = minimum((v(pad_pb) - v(vddio))*mk_pb + (1-mk_pb)*1e9)
if ( vcat > 0 )
  set fs = positive
  set fd = developed
else
  set fs = not_forward_biased
  set fd = not_developed
end
echo "RESULT pulse_pb vhbm_V=2000 c_F=100p r_ohm=1500 decay_tau_s=1.5e-7 t_fire_s=500n rail=vddio vddio_V=3.3 state=natural_operating_point_fired_at_500ns ic_pad_rxg_V=none pad_bleed_1Gohm=0 i_esd2_pk_A=1.33333 ipulse_pk_A=$&ipk t_ipk_s=$&tat vpad_min_V=$&vpmin vpad_max_V=$&vpmax vpad_excursion_V=$&vpexc conducting=XDP vfwd_cond_at_ipk_V=$&vcat fwd_sign=$fs pulse_forward_drop=$fd"
let vf = v(pad_pb) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xpb.xdp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let vfmax = maximum(vf)
let vrmax = maximum(-vf)
let idmin = minimum(idv)
let idmax = maximum(idv)
let vfat = minimum(vf*mk_pb + (1-mk_pb)*1e9)
let idat = minimum(idv*mk_pb + (1-mk_pb)*1e9)
echo "RESULT pulse_pb_XDP vfwd_at_ipk_V=$&vfat id_at_ipk_A=$&idat vfwd_max_V=$&vfmax vrev_max_V=$&vrmax vabs_max_V=$&vapk id_min_A=$&idmin id_max_A=$&idmax validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(pad_pb)
let vapk = maximum(abs(vf))
let idv = @d.xpb.xdn.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let vfmax = maximum(vf)
let vrmax = maximum(-vf)
let idmin = minimum(idv)
let idmax = maximum(idv)
let vfat = minimum(vf*mk_pb + (1-mk_pb)*1e9)
let idat = minimum(idv*mk_pb + (1-mk_pb)*1e9)
echo "RESULT pulse_pb_XDN vfwd_at_ipk_V=$&vfat id_at_ipk_A=$&idat vfwd_max_V=$&vfmax vrev_max_V=$&vrmax vabs_max_V=$&vapk id_min_A=$&idmin id_max_A=$&idmax validity=$lab current_validity=no_current_validity_range_on_record"
let vf = v(rxg_pb) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xpb.xdlp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let vfmax = maximum(vf)
let vrmax = maximum(-vf)
let idmin = minimum(idv)
let idmax = maximum(idv)
let vfat = minimum(vf*mk_pb + (1-mk_pb)*1e9)
let idat = minimum(idv*mk_pb + (1-mk_pb)*1e9)
echo "RESULT pulse_pb_XDLP vfwd_at_ipk_V=$&vfat id_at_ipk_A=$&idat vfwd_max_V=$&vfmax vrev_max_V=$&vrmax vabs_max_V=$&vapk id_min_A=$&idmin id_max_A=$&idmax validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(rxg_pb)
let vapk = maximum(abs(vf))
let idv = @d.xpb.xdln.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let vfmax = maximum(vf)
let vrmax = maximum(-vf)
let idmin = minimum(idv)
let idmax = maximum(idv)
let vfat = minimum(vf*mk_pb + (1-mk_pb)*1e9)
let idat = minimum(idv*mk_pb + (1-mk_pb)*1e9)
echo "RESULT pulse_pb_XDLN vfwd_at_ipk_V=$&vfat id_at_ipk_A=$&idat vfwd_max_V=$&vfmax vrev_max_V=$&vrmax vabs_max_V=$&vapk id_min_A=$&idmin id_max_A=$&idmax validity=$lab current_validity=no_current_validity_range_on_record"
let vrsa = maximum(abs(v(rxg_pb) - v(pad_pb)))
echo "RESULT pulse_pb_XRS vabs_V=$&vrsa validity=no_validity_range_on_record current_validity=no_current_validity_range_on_record"
let ii = abs(v(h_pc) - v(pad_pc)) / 1500
let ipk = maximum(ii)
let mk_pc = (ii > 0.9999*ipk)
let tat = minimum(time*mk_pc + (1-mk_pc)*1e9)
let vpmin = minimum(v(pad_pc))
let vpmax = maximum(v(pad_pc))
let vpexc = vpmax - vpmin
let vcat = minimum((v(pad_pc) - v(vddio))*mk_pc + (1-mk_pc)*1e9)
if ( vcat > 0 )
  set fs = positive
  set fd = developed
else
  set fs = not_forward_biased
  set fd = not_developed
end
echo "RESULT pulse_pc vhbm_V=2000 c_F=100p r_ohm=1500 decay_tau_s=1.5e-7 t_fire_s=50n rail=vddio vddio_V=3.3 state=natural_operating_point_plus_1Gohm_pad_bleed ic_pad_rxg_V=none pad_bleed_1Gohm=1 i_esd2_pk_A=1.33333 ipulse_pk_A=$&ipk t_ipk_s=$&tat vpad_min_V=$&vpmin vpad_max_V=$&vpmax vpad_excursion_V=$&vpexc conducting=XDP vfwd_cond_at_ipk_V=$&vcat fwd_sign=$fs pulse_forward_drop=$fd"
let vf = v(pad_pc) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xpc.xdp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let vfmax = maximum(vf)
let vrmax = maximum(-vf)
let idmin = minimum(idv)
let idmax = maximum(idv)
let vfat = minimum(vf*mk_pc + (1-mk_pc)*1e9)
let idat = minimum(idv*mk_pc + (1-mk_pc)*1e9)
echo "RESULT pulse_pc_XDP vfwd_at_ipk_V=$&vfat id_at_ipk_A=$&idat vfwd_max_V=$&vfmax vrev_max_V=$&vrmax vabs_max_V=$&vapk id_min_A=$&idmin id_max_A=$&idmax validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(pad_pc)
let vapk = maximum(abs(vf))
let idv = @d.xpc.xdn.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let vfmax = maximum(vf)
let vrmax = maximum(-vf)
let idmin = minimum(idv)
let idmax = maximum(idv)
let vfat = minimum(vf*mk_pc + (1-mk_pc)*1e9)
let idat = minimum(idv*mk_pc + (1-mk_pc)*1e9)
echo "RESULT pulse_pc_XDN vfwd_at_ipk_V=$&vfat id_at_ipk_A=$&idat vfwd_max_V=$&vfmax vrev_max_V=$&vrmax vabs_max_V=$&vapk id_min_A=$&idmin id_max_A=$&idmax validity=$lab current_validity=no_current_validity_range_on_record"
let vf = v(rxg_pc) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xpc.xdlp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let vfmax = maximum(vf)
let vrmax = maximum(-vf)
let idmin = minimum(idv)
let idmax = maximum(idv)
let vfat = minimum(vf*mk_pc + (1-mk_pc)*1e9)
let idat = minimum(idv*mk_pc + (1-mk_pc)*1e9)
echo "RESULT pulse_pc_XDLP vfwd_at_ipk_V=$&vfat id_at_ipk_A=$&idat vfwd_max_V=$&vfmax vrev_max_V=$&vrmax vabs_max_V=$&vapk id_min_A=$&idmin id_max_A=$&idmax validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(rxg_pc)
let vapk = maximum(abs(vf))
let idv = @d.xpc.xdln.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let vfmax = maximum(vf)
let vrmax = maximum(-vf)
let idmin = minimum(idv)
let idmax = maximum(idv)
let vfat = minimum(vf*mk_pc + (1-mk_pc)*1e9)
let idat = minimum(idv*mk_pc + (1-mk_pc)*1e9)
echo "RESULT pulse_pc_XDLN vfwd_at_ipk_V=$&vfat id_at_ipk_A=$&idat vfwd_max_V=$&vfmax vrev_max_V=$&vrmax vabs_max_V=$&vapk id_min_A=$&idmin id_max_A=$&idmax validity=$lab current_validity=no_current_validity_range_on_record"
let vrsa = maximum(abs(v(rxg_pc) - v(pad_pc)))
echo "RESULT pulse_pc_XRS vabs_V=$&vrsa validity=no_validity_range_on_record current_validity=no_current_validity_range_on_record"
let ii = abs(v(h_pd) - v(pad_pd)) / 1500
let ipk = maximum(ii)
let mk_pd = (ii > 0.9999*ipk)
let tat = minimum(time*mk_pd + (1-mk_pd)*1e9)
let vpmin = minimum(v(pad_pd))
let vpmax = maximum(v(pad_pd))
let vpexc = vpmax - vpmin
let vcat = minimum((v(pad_pd) - v(vddio))*mk_pd + (1-mk_pd)*1e9)
if ( vcat > 0 )
  set fs = positive
  set fd = developed
else
  set fs = not_forward_biased
  set fd = not_developed
end
echo "RESULT pulse_pd vhbm_V=2000 c_F=100p r_ohm=1500 decay_tau_s=1.5e-7 t_fire_s=50n rail=vddio vddio_V=3.3 state=forced_ic_diagnostic_not_a_result ic_pad_rxg_V=5 pad_bleed_1Gohm=0 i_esd2_pk_A=1.33333 ipulse_pk_A=$&ipk t_ipk_s=$&tat vpad_min_V=$&vpmin vpad_max_V=$&vpmax vpad_excursion_V=$&vpexc conducting=XDP vfwd_cond_at_ipk_V=$&vcat fwd_sign=$fs pulse_forward_drop=$fd"
let vf = v(pad_pd) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xpd.xdp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let vfmax = maximum(vf)
let vrmax = maximum(-vf)
let idmin = minimum(idv)
let idmax = maximum(idv)
let vfat = minimum(vf*mk_pd + (1-mk_pd)*1e9)
let idat = minimum(idv*mk_pd + (1-mk_pd)*1e9)
echo "RESULT pulse_pd_XDP vfwd_at_ipk_V=$&vfat id_at_ipk_A=$&idat vfwd_max_V=$&vfmax vrev_max_V=$&vrmax vabs_max_V=$&vapk id_min_A=$&idmin id_max_A=$&idmax validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(pad_pd)
let vapk = maximum(abs(vf))
let idv = @d.xpd.xdn.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let vfmax = maximum(vf)
let vrmax = maximum(-vf)
let idmin = minimum(idv)
let idmax = maximum(idv)
let vfat = minimum(vf*mk_pd + (1-mk_pd)*1e9)
let idat = minimum(idv*mk_pd + (1-mk_pd)*1e9)
echo "RESULT pulse_pd_XDN vfwd_at_ipk_V=$&vfat id_at_ipk_A=$&idat vfwd_max_V=$&vfmax vrev_max_V=$&vrmax vabs_max_V=$&vapk id_min_A=$&idmin id_max_A=$&idmax validity=$lab current_validity=no_current_validity_range_on_record"
let vf = v(rxg_pd) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xpd.xdlp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let vfmax = maximum(vf)
let vrmax = maximum(-vf)
let idmin = minimum(idv)
let idmax = maximum(idv)
let vfat = minimum(vf*mk_pd + (1-mk_pd)*1e9)
let idat = minimum(idv*mk_pd + (1-mk_pd)*1e9)
echo "RESULT pulse_pd_XDLP vfwd_at_ipk_V=$&vfat id_at_ipk_A=$&idat vfwd_max_V=$&vfmax vrev_max_V=$&vrmax vabs_max_V=$&vapk id_min_A=$&idmin id_max_A=$&idmax validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(rxg_pd)
let vapk = maximum(abs(vf))
let idv = @d.xpd.xdln.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let vfmax = maximum(vf)
let vrmax = maximum(-vf)
let idmin = minimum(idv)
let idmax = maximum(idv)
let vfat = minimum(vf*mk_pd + (1-mk_pd)*1e9)
let idat = minimum(idv*mk_pd + (1-mk_pd)*1e9)
echo "RESULT pulse_pd_XDLN vfwd_at_ipk_V=$&vfat id_at_ipk_A=$&idat vfwd_max_V=$&vfmax vrev_max_V=$&vrmax vabs_max_V=$&vapk id_min_A=$&idmin id_max_A=$&idmax validity=$lab current_validity=no_current_validity_range_on_record"
let vrsa = maximum(abs(v(rxg_pd) - v(pad_pd)))
echo "RESULT pulse_pd_XRS vabs_V=$&vrsa validity=no_validity_range_on_record current_validity=no_current_validity_range_on_record"
let ii = abs(v(h_pe) - v(pad_pe)) / 1500
let ipk = maximum(ii)
let mk_pe = (ii > 0.9999*ipk)
let tat = minimum(time*mk_pe + (1-mk_pe)*1e9)
let vpmin = minimum(v(pad_pe))
let vpmax = maximum(v(pad_pe))
let vpexc = vpmax - vpmin
let vcat = minimum((v(pad_pe) - v(vddio))*mk_pe + (1-mk_pe)*1e9)
if ( vcat > 0 )
  set fs = positive
  set fd = developed
else
  set fs = not_forward_biased
  set fd = not_developed
end
echo "RESULT pulse_pe vhbm_V=2000 c_F=100p r_ohm=1500 decay_tau_s=1.5e-7 t_fire_s=50n rail=vddio vddio_V=3.3 state=forced_ic_diagnostic_not_a_result ic_pad_rxg_V=-0.05 pad_bleed_1Gohm=0 i_esd2_pk_A=1.33333 ipulse_pk_A=$&ipk t_ipk_s=$&tat vpad_min_V=$&vpmin vpad_max_V=$&vpmax vpad_excursion_V=$&vpexc conducting=XDP vfwd_cond_at_ipk_V=$&vcat fwd_sign=$fs pulse_forward_drop=$fd"
let vf = v(pad_pe) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xpe.xdp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let vfmax = maximum(vf)
let vrmax = maximum(-vf)
let idmin = minimum(idv)
let idmax = maximum(idv)
let vfat = minimum(vf*mk_pe + (1-mk_pe)*1e9)
let idat = minimum(idv*mk_pe + (1-mk_pe)*1e9)
echo "RESULT pulse_pe_XDP vfwd_at_ipk_V=$&vfat id_at_ipk_A=$&idat vfwd_max_V=$&vfmax vrev_max_V=$&vrmax vabs_max_V=$&vapk id_min_A=$&idmin id_max_A=$&idmax validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(pad_pe)
let vapk = maximum(abs(vf))
let idv = @d.xpe.xdn.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let vfmax = maximum(vf)
let vrmax = maximum(-vf)
let idmin = minimum(idv)
let idmax = maximum(idv)
let vfat = minimum(vf*mk_pe + (1-mk_pe)*1e9)
let idat = minimum(idv*mk_pe + (1-mk_pe)*1e9)
echo "RESULT pulse_pe_XDN vfwd_at_ipk_V=$&vfat id_at_ipk_A=$&idat vfwd_max_V=$&vfmax vrev_max_V=$&vrmax vabs_max_V=$&vapk id_min_A=$&idmin id_max_A=$&idmax validity=$lab current_validity=no_current_validity_range_on_record"
let vf = v(rxg_pe) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xpe.xdlp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let vfmax = maximum(vf)
let vrmax = maximum(-vf)
let idmin = minimum(idv)
let idmax = maximum(idv)
let vfat = minimum(vf*mk_pe + (1-mk_pe)*1e9)
let idat = minimum(idv*mk_pe + (1-mk_pe)*1e9)
echo "RESULT pulse_pe_XDLP vfwd_at_ipk_V=$&vfat id_at_ipk_A=$&idat vfwd_max_V=$&vfmax vrev_max_V=$&vrmax vabs_max_V=$&vapk id_min_A=$&idmin id_max_A=$&idmax validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(rxg_pe)
let vapk = maximum(abs(vf))
let idv = @d.xpe.xdln.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let vfmax = maximum(vf)
let vrmax = maximum(-vf)
let idmin = minimum(idv)
let idmax = maximum(idv)
let vfat = minimum(vf*mk_pe + (1-mk_pe)*1e9)
let idat = minimum(idv*mk_pe + (1-mk_pe)*1e9)
echo "RESULT pulse_pe_XDLN vfwd_at_ipk_V=$&vfat id_at_ipk_A=$&idat vfwd_max_V=$&vfmax vrev_max_V=$&vrmax vabs_max_V=$&vapk id_min_A=$&idmin id_max_A=$&idmax validity=$lab current_validity=no_current_validity_range_on_record"
let vrsa = maximum(abs(v(rxg_pe) - v(pad_pe)))
echo "RESULT pulse_pe_XRS vabs_V=$&vrsa validity=no_validity_range_on_record current_validity=no_current_validity_range_on_record"
let ii = abs(v(h_na) - v(pad_na)) / 1500
let ipk = maximum(ii)
let mk_na = (ii > 0.9999*ipk)
let tat = minimum(time*mk_na + (1-mk_na)*1e9)
let vpmin = minimum(v(pad_na))
let vpmax = maximum(v(pad_na))
let vpexc = vpmax - vpmin
let vcat = minimum((-v(pad_na))*mk_na + (1-mk_na)*1e9)
if ( vcat > 0 )
  set fs = positive
  set fd = developed
else
  set fs = not_forward_biased
  set fd = not_developed
end
echo "RESULT pulse_na vhbm_V=-2000 c_F=100p r_ohm=1500 decay_tau_s=1.5e-7 t_fire_s=50n rail=vddio vddio_V=3.3 state=natural_operating_point ic_pad_rxg_V=none pad_bleed_1Gohm=0 i_esd2_pk_A=1.33333 ipulse_pk_A=$&ipk t_ipk_s=$&tat vpad_min_V=$&vpmin vpad_max_V=$&vpmax vpad_excursion_V=$&vpexc conducting=XDN vfwd_cond_at_ipk_V=$&vcat fwd_sign=$fs pulse_forward_drop=$fd"
let vf = v(pad_na) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xna.xdp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let vfmax = maximum(vf)
let vrmax = maximum(-vf)
let idmin = minimum(idv)
let idmax = maximum(idv)
let vfat = minimum(vf*mk_na + (1-mk_na)*1e9)
let idat = minimum(idv*mk_na + (1-mk_na)*1e9)
echo "RESULT pulse_na_XDP vfwd_at_ipk_V=$&vfat id_at_ipk_A=$&idat vfwd_max_V=$&vfmax vrev_max_V=$&vrmax vabs_max_V=$&vapk id_min_A=$&idmin id_max_A=$&idmax validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(pad_na)
let vapk = maximum(abs(vf))
let idv = @d.xna.xdn.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let vfmax = maximum(vf)
let vrmax = maximum(-vf)
let idmin = minimum(idv)
let idmax = maximum(idv)
let vfat = minimum(vf*mk_na + (1-mk_na)*1e9)
let idat = minimum(idv*mk_na + (1-mk_na)*1e9)
echo "RESULT pulse_na_XDN vfwd_at_ipk_V=$&vfat id_at_ipk_A=$&idat vfwd_max_V=$&vfmax vrev_max_V=$&vrmax vabs_max_V=$&vapk id_min_A=$&idmin id_max_A=$&idmax validity=$lab current_validity=no_current_validity_range_on_record"
let vf = v(rxg_na) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xna.xdlp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let vfmax = maximum(vf)
let vrmax = maximum(-vf)
let idmin = minimum(idv)
let idmax = maximum(idv)
let vfat = minimum(vf*mk_na + (1-mk_na)*1e9)
let idat = minimum(idv*mk_na + (1-mk_na)*1e9)
echo "RESULT pulse_na_XDLP vfwd_at_ipk_V=$&vfat id_at_ipk_A=$&idat vfwd_max_V=$&vfmax vrev_max_V=$&vrmax vabs_max_V=$&vapk id_min_A=$&idmin id_max_A=$&idmax validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(rxg_na)
let vapk = maximum(abs(vf))
let idv = @d.xna.xdln.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let vfmax = maximum(vf)
let vrmax = maximum(-vf)
let idmin = minimum(idv)
let idmax = maximum(idv)
let vfat = minimum(vf*mk_na + (1-mk_na)*1e9)
let idat = minimum(idv*mk_na + (1-mk_na)*1e9)
echo "RESULT pulse_na_XDLN vfwd_at_ipk_V=$&vfat id_at_ipk_A=$&idat vfwd_max_V=$&vfmax vrev_max_V=$&vrmax vabs_max_V=$&vapk id_min_A=$&idmin id_max_A=$&idmax validity=$lab current_validity=no_current_validity_range_on_record"
let vrsa = maximum(abs(v(rxg_na) - v(pad_na)))
echo "RESULT pulse_na_XRS vabs_V=$&vrsa validity=no_validity_range_on_record current_validity=no_current_validity_range_on_record"
let ii = abs(v(h_nb) - v(pad_nb)) / 1500
let ipk = maximum(ii)
let mk_nb = (ii > 0.9999*ipk)
let tat = minimum(time*mk_nb + (1-mk_nb)*1e9)
let vpmin = minimum(v(pad_nb))
let vpmax = maximum(v(pad_nb))
let vpexc = vpmax - vpmin
let vcat = minimum((-v(pad_nb))*mk_nb + (1-mk_nb)*1e9)
if ( vcat > 0 )
  set fs = positive
  set fd = developed
else
  set fs = not_forward_biased
  set fd = not_developed
end
echo "RESULT pulse_nb vhbm_V=-2000 c_F=100p r_ohm=1500 decay_tau_s=1.5e-7 t_fire_s=500n rail=vddio vddio_V=3.3 state=natural_operating_point_fired_at_500ns ic_pad_rxg_V=none pad_bleed_1Gohm=0 i_esd2_pk_A=1.33333 ipulse_pk_A=$&ipk t_ipk_s=$&tat vpad_min_V=$&vpmin vpad_max_V=$&vpmax vpad_excursion_V=$&vpexc conducting=XDN vfwd_cond_at_ipk_V=$&vcat fwd_sign=$fs pulse_forward_drop=$fd"
let vf = v(pad_nb) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xnb.xdp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let vfmax = maximum(vf)
let vrmax = maximum(-vf)
let idmin = minimum(idv)
let idmax = maximum(idv)
let vfat = minimum(vf*mk_nb + (1-mk_nb)*1e9)
let idat = minimum(idv*mk_nb + (1-mk_nb)*1e9)
echo "RESULT pulse_nb_XDP vfwd_at_ipk_V=$&vfat id_at_ipk_A=$&idat vfwd_max_V=$&vfmax vrev_max_V=$&vrmax vabs_max_V=$&vapk id_min_A=$&idmin id_max_A=$&idmax validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(pad_nb)
let vapk = maximum(abs(vf))
let idv = @d.xnb.xdn.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let vfmax = maximum(vf)
let vrmax = maximum(-vf)
let idmin = minimum(idv)
let idmax = maximum(idv)
let vfat = minimum(vf*mk_nb + (1-mk_nb)*1e9)
let idat = minimum(idv*mk_nb + (1-mk_nb)*1e9)
echo "RESULT pulse_nb_XDN vfwd_at_ipk_V=$&vfat id_at_ipk_A=$&idat vfwd_max_V=$&vfmax vrev_max_V=$&vrmax vabs_max_V=$&vapk id_min_A=$&idmin id_max_A=$&idmax validity=$lab current_validity=no_current_validity_range_on_record"
let vf = v(rxg_nb) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xnb.xdlp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let vfmax = maximum(vf)
let vrmax = maximum(-vf)
let idmin = minimum(idv)
let idmax = maximum(idv)
let vfat = minimum(vf*mk_nb + (1-mk_nb)*1e9)
let idat = minimum(idv*mk_nb + (1-mk_nb)*1e9)
echo "RESULT pulse_nb_XDLP vfwd_at_ipk_V=$&vfat id_at_ipk_A=$&idat vfwd_max_V=$&vfmax vrev_max_V=$&vrmax vabs_max_V=$&vapk id_min_A=$&idmin id_max_A=$&idmax validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(rxg_nb)
let vapk = maximum(abs(vf))
let idv = @d.xnb.xdln.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let vfmax = maximum(vf)
let vrmax = maximum(-vf)
let idmin = minimum(idv)
let idmax = maximum(idv)
let vfat = minimum(vf*mk_nb + (1-mk_nb)*1e9)
let idat = minimum(idv*mk_nb + (1-mk_nb)*1e9)
echo "RESULT pulse_nb_XDLN vfwd_at_ipk_V=$&vfat id_at_ipk_A=$&idat vfwd_max_V=$&vfmax vrev_max_V=$&vrmax vabs_max_V=$&vapk id_min_A=$&idmin id_max_A=$&idmax validity=$lab current_validity=no_current_validity_range_on_record"
let vrsa = maximum(abs(v(rxg_nb) - v(pad_nb)))
echo "RESULT pulse_nb_XRS vabs_V=$&vrsa validity=no_validity_range_on_record current_validity=no_current_validity_range_on_record"
let ii = abs(v(h_nc) - v(pad_nc)) / 1500
let ipk = maximum(ii)
let mk_nc = (ii > 0.9999*ipk)
let tat = minimum(time*mk_nc + (1-mk_nc)*1e9)
let vpmin = minimum(v(pad_nc))
let vpmax = maximum(v(pad_nc))
let vpexc = vpmax - vpmin
let vcat = minimum((-v(pad_nc))*mk_nc + (1-mk_nc)*1e9)
if ( vcat > 0 )
  set fs = positive
  set fd = developed
else
  set fs = not_forward_biased
  set fd = not_developed
end
echo "RESULT pulse_nc vhbm_V=-2000 c_F=100p r_ohm=1500 decay_tau_s=1.5e-7 t_fire_s=50n rail=vddio vddio_V=3.3 state=natural_operating_point_plus_1Gohm_pad_bleed ic_pad_rxg_V=none pad_bleed_1Gohm=1 i_esd2_pk_A=1.33333 ipulse_pk_A=$&ipk t_ipk_s=$&tat vpad_min_V=$&vpmin vpad_max_V=$&vpmax vpad_excursion_V=$&vpexc conducting=XDN vfwd_cond_at_ipk_V=$&vcat fwd_sign=$fs pulse_forward_drop=$fd"
let vf = v(pad_nc) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xnc.xdp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let vfmax = maximum(vf)
let vrmax = maximum(-vf)
let idmin = minimum(idv)
let idmax = maximum(idv)
let vfat = minimum(vf*mk_nc + (1-mk_nc)*1e9)
let idat = minimum(idv*mk_nc + (1-mk_nc)*1e9)
echo "RESULT pulse_nc_XDP vfwd_at_ipk_V=$&vfat id_at_ipk_A=$&idat vfwd_max_V=$&vfmax vrev_max_V=$&vrmax vabs_max_V=$&vapk id_min_A=$&idmin id_max_A=$&idmax validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(pad_nc)
let vapk = maximum(abs(vf))
let idv = @d.xnc.xdn.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let vfmax = maximum(vf)
let vrmax = maximum(-vf)
let idmin = minimum(idv)
let idmax = maximum(idv)
let vfat = minimum(vf*mk_nc + (1-mk_nc)*1e9)
let idat = minimum(idv*mk_nc + (1-mk_nc)*1e9)
echo "RESULT pulse_nc_XDN vfwd_at_ipk_V=$&vfat id_at_ipk_A=$&idat vfwd_max_V=$&vfmax vrev_max_V=$&vrmax vabs_max_V=$&vapk id_min_A=$&idmin id_max_A=$&idmax validity=$lab current_validity=no_current_validity_range_on_record"
let vf = v(rxg_nc) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xnc.xdlp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let vfmax = maximum(vf)
let vrmax = maximum(-vf)
let idmin = minimum(idv)
let idmax = maximum(idv)
let vfat = minimum(vf*mk_nc + (1-mk_nc)*1e9)
let idat = minimum(idv*mk_nc + (1-mk_nc)*1e9)
echo "RESULT pulse_nc_XDLP vfwd_at_ipk_V=$&vfat id_at_ipk_A=$&idat vfwd_max_V=$&vfmax vrev_max_V=$&vrmax vabs_max_V=$&vapk id_min_A=$&idmin id_max_A=$&idmax validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(rxg_nc)
let vapk = maximum(abs(vf))
let idv = @d.xnc.xdln.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let vfmax = maximum(vf)
let vrmax = maximum(-vf)
let idmin = minimum(idv)
let idmax = maximum(idv)
let vfat = minimum(vf*mk_nc + (1-mk_nc)*1e9)
let idat = minimum(idv*mk_nc + (1-mk_nc)*1e9)
echo "RESULT pulse_nc_XDLN vfwd_at_ipk_V=$&vfat id_at_ipk_A=$&idat vfwd_max_V=$&vfmax vrev_max_V=$&vrmax vabs_max_V=$&vapk id_min_A=$&idmin id_max_A=$&idmax validity=$lab current_validity=no_current_validity_range_on_record"
let vrsa = maximum(abs(v(rxg_nc) - v(pad_nc)))
echo "RESULT pulse_nc_XRS vabs_V=$&vrsa validity=no_validity_range_on_record current_validity=no_current_validity_range_on_record"
let ii = abs(v(h_nd) - v(pad_nd)) / 1500
let ipk = maximum(ii)
let mk_nd = (ii > 0.9999*ipk)
let tat = minimum(time*mk_nd + (1-mk_nd)*1e9)
let vpmin = minimum(v(pad_nd))
let vpmax = maximum(v(pad_nd))
let vpexc = vpmax - vpmin
let vcat = minimum((-v(pad_nd))*mk_nd + (1-mk_nd)*1e9)
if ( vcat > 0 )
  set fs = positive
  set fd = developed
else
  set fs = not_forward_biased
  set fd = not_developed
end
echo "RESULT pulse_nd vhbm_V=-2000 c_F=100p r_ohm=1500 decay_tau_s=1.5e-7 t_fire_s=50n rail=vddio vddio_V=3.3 state=forced_ic_diagnostic_not_a_result ic_pad_rxg_V=5 pad_bleed_1Gohm=0 i_esd2_pk_A=1.33333 ipulse_pk_A=$&ipk t_ipk_s=$&tat vpad_min_V=$&vpmin vpad_max_V=$&vpmax vpad_excursion_V=$&vpexc conducting=XDN vfwd_cond_at_ipk_V=$&vcat fwd_sign=$fs pulse_forward_drop=$fd"
let vf = v(pad_nd) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xnd.xdp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let vfmax = maximum(vf)
let vrmax = maximum(-vf)
let idmin = minimum(idv)
let idmax = maximum(idv)
let vfat = minimum(vf*mk_nd + (1-mk_nd)*1e9)
let idat = minimum(idv*mk_nd + (1-mk_nd)*1e9)
echo "RESULT pulse_nd_XDP vfwd_at_ipk_V=$&vfat id_at_ipk_A=$&idat vfwd_max_V=$&vfmax vrev_max_V=$&vrmax vabs_max_V=$&vapk id_min_A=$&idmin id_max_A=$&idmax validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(pad_nd)
let vapk = maximum(abs(vf))
let idv = @d.xnd.xdn.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let vfmax = maximum(vf)
let vrmax = maximum(-vf)
let idmin = minimum(idv)
let idmax = maximum(idv)
let vfat = minimum(vf*mk_nd + (1-mk_nd)*1e9)
let idat = minimum(idv*mk_nd + (1-mk_nd)*1e9)
echo "RESULT pulse_nd_XDN vfwd_at_ipk_V=$&vfat id_at_ipk_A=$&idat vfwd_max_V=$&vfmax vrev_max_V=$&vrmax vabs_max_V=$&vapk id_min_A=$&idmin id_max_A=$&idmax validity=$lab current_validity=no_current_validity_range_on_record"
let vf = v(rxg_nd) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xnd.xdlp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let vfmax = maximum(vf)
let vrmax = maximum(-vf)
let idmin = minimum(idv)
let idmax = maximum(idv)
let vfat = minimum(vf*mk_nd + (1-mk_nd)*1e9)
let idat = minimum(idv*mk_nd + (1-mk_nd)*1e9)
echo "RESULT pulse_nd_XDLP vfwd_at_ipk_V=$&vfat id_at_ipk_A=$&idat vfwd_max_V=$&vfmax vrev_max_V=$&vrmax vabs_max_V=$&vapk id_min_A=$&idmin id_max_A=$&idmax validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(rxg_nd)
let vapk = maximum(abs(vf))
let idv = @d.xnd.xdln.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let vfmax = maximum(vf)
let vrmax = maximum(-vf)
let idmin = minimum(idv)
let idmax = maximum(idv)
let vfat = minimum(vf*mk_nd + (1-mk_nd)*1e9)
let idat = minimum(idv*mk_nd + (1-mk_nd)*1e9)
echo "RESULT pulse_nd_XDLN vfwd_at_ipk_V=$&vfat id_at_ipk_A=$&idat vfwd_max_V=$&vfmax vrev_max_V=$&vrmax vabs_max_V=$&vapk id_min_A=$&idmin id_max_A=$&idmax validity=$lab current_validity=no_current_validity_range_on_record"
let vrsa = maximum(abs(v(rxg_nd) - v(pad_nd)))
echo "RESULT pulse_nd_XRS vabs_V=$&vrsa validity=no_validity_range_on_record current_validity=no_current_validity_range_on_record"
let ii = abs(v(h_ne) - v(pad_ne)) / 1500
let ipk = maximum(ii)
let mk_ne = (ii > 0.9999*ipk)
let tat = minimum(time*mk_ne + (1-mk_ne)*1e9)
let vpmin = minimum(v(pad_ne))
let vpmax = maximum(v(pad_ne))
let vpexc = vpmax - vpmin
let vcat = minimum((-v(pad_ne))*mk_ne + (1-mk_ne)*1e9)
if ( vcat > 0 )
  set fs = positive
  set fd = developed
else
  set fs = not_forward_biased
  set fd = not_developed
end
echo "RESULT pulse_ne vhbm_V=-2000 c_F=100p r_ohm=1500 decay_tau_s=1.5e-7 t_fire_s=50n rail=vddio vddio_V=3.3 state=forced_ic_diagnostic_not_a_result ic_pad_rxg_V=-0.05 pad_bleed_1Gohm=0 i_esd2_pk_A=1.33333 ipulse_pk_A=$&ipk t_ipk_s=$&tat vpad_min_V=$&vpmin vpad_max_V=$&vpmax vpad_excursion_V=$&vpexc conducting=XDN vfwd_cond_at_ipk_V=$&vcat fwd_sign=$fs pulse_forward_drop=$fd"
let vf = v(pad_ne) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xne.xdp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let vfmax = maximum(vf)
let vrmax = maximum(-vf)
let idmin = minimum(idv)
let idmax = maximum(idv)
let vfat = minimum(vf*mk_ne + (1-mk_ne)*1e9)
let idat = minimum(idv*mk_ne + (1-mk_ne)*1e9)
echo "RESULT pulse_ne_XDP vfwd_at_ipk_V=$&vfat id_at_ipk_A=$&idat vfwd_max_V=$&vfmax vrev_max_V=$&vrmax vabs_max_V=$&vapk id_min_A=$&idmin id_max_A=$&idmax validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(pad_ne)
let vapk = maximum(abs(vf))
let idv = @d.xne.xdn.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let vfmax = maximum(vf)
let vrmax = maximum(-vf)
let idmin = minimum(idv)
let idmax = maximum(idv)
let vfat = minimum(vf*mk_ne + (1-mk_ne)*1e9)
let idat = minimum(idv*mk_ne + (1-mk_ne)*1e9)
echo "RESULT pulse_ne_XDN vfwd_at_ipk_V=$&vfat id_at_ipk_A=$&idat vfwd_max_V=$&vfmax vrev_max_V=$&vrmax vabs_max_V=$&vapk id_min_A=$&idmin id_max_A=$&idmax validity=$lab current_validity=no_current_validity_range_on_record"
let vf = v(rxg_ne) - v(vddio)
let vapk = maximum(abs(vf))
let idv = @d.xne.xdlp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let vfmax = maximum(vf)
let vrmax = maximum(-vf)
let idmin = minimum(idv)
let idmax = maximum(idv)
let vfat = minimum(vf*mk_ne + (1-mk_ne)*1e9)
let idat = minimum(idv*mk_ne + (1-mk_ne)*1e9)
echo "RESULT pulse_ne_XDLP vfwd_at_ipk_V=$&vfat id_at_ipk_A=$&idat vfwd_max_V=$&vfmax vrev_max_V=$&vrmax vabs_max_V=$&vapk id_min_A=$&idmin id_max_A=$&idmax validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(rxg_ne)
let vapk = maximum(abs(vf))
let idv = @d.xne.xdln.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let vfmax = maximum(vf)
let vrmax = maximum(-vf)
let idmin = minimum(idv)
let idmax = maximum(idv)
let vfat = minimum(vf*mk_ne + (1-mk_ne)*1e9)
let idat = minimum(idv*mk_ne + (1-mk_ne)*1e9)
echo "RESULT pulse_ne_XDLN vfwd_at_ipk_V=$&vfat id_at_ipk_A=$&idat vfwd_max_V=$&vfmax vrev_max_V=$&vrmax vabs_max_V=$&vapk id_min_A=$&idmin id_max_A=$&idmax validity=$lab current_validity=no_current_validity_range_on_record"
let vrsa = maximum(abs(v(rxg_ne) - v(pad_ne)))
echo "RESULT pulse_ne_XRS vabs_V=$&vrsa validity=no_validity_range_on_record current_validity=no_current_validity_range_on_record"
let ii = abs(v(h_qp) - v(pad_qp)) / 1500
let ipk = maximum(ii)
let mk_qp = (ii > 0.9999*ipk)
let tat = minimum(time*mk_qp + (1-mk_qp)*1e9)
let vpmin = minimum(v(pad_qp))
let vpmax = maximum(v(pad_qp))
let vpexc = vpmax - vpmin
let vcat = minimum((v(pad_qp) - v(vddio5))*mk_qp + (1-mk_qp)*1e9)
if ( vcat > 0 )
  set fs = positive
  set fd = developed
else
  set fs = not_forward_biased
  set fd = not_developed
end
echo "RESULT pulse_qp vhbm_V=2000 c_F=100p r_ohm=1500 decay_tau_s=1.5e-7 t_fire_s=50n rail=vddio5 vddio_V=5.0 state=natural_operating_point ic_pad_rxg_V=none pad_bleed_1Gohm=0 i_esd2_pk_A=1.33333 ipulse_pk_A=$&ipk t_ipk_s=$&tat vpad_min_V=$&vpmin vpad_max_V=$&vpmax vpad_excursion_V=$&vpexc conducting=XDP vfwd_cond_at_ipk_V=$&vcat fwd_sign=$fs pulse_forward_drop=$fd"
let vf = v(pad_qp) - v(vddio5)
let vapk = maximum(abs(vf))
let idv = @d.xqp.xdp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let vfmax = maximum(vf)
let vrmax = maximum(-vf)
let idmin = minimum(idv)
let idmax = maximum(idv)
let vfat = minimum(vf*mk_qp + (1-mk_qp)*1e9)
let idat = minimum(idv*mk_qp + (1-mk_qp)*1e9)
echo "RESULT pulse_qp_XDP vfwd_at_ipk_V=$&vfat id_at_ipk_A=$&idat vfwd_max_V=$&vfmax vrev_max_V=$&vrmax vabs_max_V=$&vapk id_min_A=$&idmin id_max_A=$&idmax validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(pad_qp)
let vapk = maximum(abs(vf))
let idv = @d.xqp.xdn.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let vfmax = maximum(vf)
let vrmax = maximum(-vf)
let idmin = minimum(idv)
let idmax = maximum(idv)
let vfat = minimum(vf*mk_qp + (1-mk_qp)*1e9)
let idat = minimum(idv*mk_qp + (1-mk_qp)*1e9)
echo "RESULT pulse_qp_XDN vfwd_at_ipk_V=$&vfat id_at_ipk_A=$&idat vfwd_max_V=$&vfmax vrev_max_V=$&vrmax vabs_max_V=$&vapk id_min_A=$&idmin id_max_A=$&idmax validity=$lab current_validity=no_current_validity_range_on_record"
let vf = v(rxg_qp) - v(vddio5)
let vapk = maximum(abs(vf))
let idv = @d.xqp.xdlp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let vfmax = maximum(vf)
let vrmax = maximum(-vf)
let idmin = minimum(idv)
let idmax = maximum(idv)
let vfat = minimum(vf*mk_qp + (1-mk_qp)*1e9)
let idat = minimum(idv*mk_qp + (1-mk_qp)*1e9)
echo "RESULT pulse_qp_XDLP vfwd_at_ipk_V=$&vfat id_at_ipk_A=$&idat vfwd_max_V=$&vfmax vrev_max_V=$&vrmax vabs_max_V=$&vapk id_min_A=$&idmin id_max_A=$&idmax validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(rxg_qp)
let vapk = maximum(abs(vf))
let idv = @d.xqp.xdln.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let vfmax = maximum(vf)
let vrmax = maximum(-vf)
let idmin = minimum(idv)
let idmax = maximum(idv)
let vfat = minimum(vf*mk_qp + (1-mk_qp)*1e9)
let idat = minimum(idv*mk_qp + (1-mk_qp)*1e9)
echo "RESULT pulse_qp_XDLN vfwd_at_ipk_V=$&vfat id_at_ipk_A=$&idat vfwd_max_V=$&vfmax vrev_max_V=$&vrmax vabs_max_V=$&vapk id_min_A=$&idmin id_max_A=$&idmax validity=$lab current_validity=no_current_validity_range_on_record"
let vrsa = maximum(abs(v(rxg_qp) - v(pad_qp)))
echo "RESULT pulse_qp_XRS vabs_V=$&vrsa validity=no_validity_range_on_record current_validity=no_current_validity_range_on_record"
let ii = abs(v(h_qn) - v(pad_qn)) / 1500
let ipk = maximum(ii)
let mk_qn = (ii > 0.9999*ipk)
let tat = minimum(time*mk_qn + (1-mk_qn)*1e9)
let vpmin = minimum(v(pad_qn))
let vpmax = maximum(v(pad_qn))
let vpexc = vpmax - vpmin
let vcat = minimum((-v(pad_qn))*mk_qn + (1-mk_qn)*1e9)
if ( vcat > 0 )
  set fs = positive
  set fd = developed
else
  set fs = not_forward_biased
  set fd = not_developed
end
echo "RESULT pulse_qn vhbm_V=-2000 c_F=100p r_ohm=1500 decay_tau_s=1.5e-7 t_fire_s=50n rail=vddio5 vddio_V=5.0 state=natural_operating_point ic_pad_rxg_V=none pad_bleed_1Gohm=0 i_esd2_pk_A=1.33333 ipulse_pk_A=$&ipk t_ipk_s=$&tat vpad_min_V=$&vpmin vpad_max_V=$&vpmax vpad_excursion_V=$&vpexc conducting=XDN vfwd_cond_at_ipk_V=$&vcat fwd_sign=$fs pulse_forward_drop=$fd"
let vf = v(pad_qn) - v(vddio5)
let vapk = maximum(abs(vf))
let idv = @d.xqn.xdp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let vfmax = maximum(vf)
let vrmax = maximum(-vf)
let idmin = minimum(idv)
let idmax = maximum(idv)
let vfat = minimum(vf*mk_qn + (1-mk_qn)*1e9)
let idat = minimum(idv*mk_qn + (1-mk_qn)*1e9)
echo "RESULT pulse_qn_XDP vfwd_at_ipk_V=$&vfat id_at_ipk_A=$&idat vfwd_max_V=$&vfmax vrev_max_V=$&vrmax vabs_max_V=$&vapk id_min_A=$&idmin id_max_A=$&idmax validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(pad_qn)
let vapk = maximum(abs(vf))
let idv = @d.xqn.xdn.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let vfmax = maximum(vf)
let vrmax = maximum(-vf)
let idmin = minimum(idv)
let idmax = maximum(idv)
let vfat = minimum(vf*mk_qn + (1-mk_qn)*1e9)
let idat = minimum(idv*mk_qn + (1-mk_qn)*1e9)
echo "RESULT pulse_qn_XDN vfwd_at_ipk_V=$&vfat id_at_ipk_A=$&idat vfwd_max_V=$&vfmax vrev_max_V=$&vrmax vabs_max_V=$&vapk id_min_A=$&idmin id_max_A=$&idmax validity=$lab current_validity=no_current_validity_range_on_record"
let vf = v(rxg_qn) - v(vddio5)
let vapk = maximum(abs(vf))
let idv = @d.xqn.xdlp.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let vfmax = maximum(vf)
let vrmax = maximum(-vf)
let idmin = minimum(idv)
let idmax = maximum(idv)
let vfat = minimum(vf*mk_qn + (1-mk_qn)*1e9)
let idat = minimum(idv*mk_qn + (1-mk_qn)*1e9)
echo "RESULT pulse_qn_XDLP vfwd_at_ipk_V=$&vfat id_at_ipk_A=$&idat vfwd_max_V=$&vfmax vrev_max_V=$&vrmax vabs_max_V=$&vapk id_min_A=$&idmin id_max_A=$&idmax validity=$lab current_validity=no_current_validity_range_on_record"
let vf = -v(rxg_qn)
let vapk = maximum(abs(vf))
let idv = @d.xqn.xdln.d0[id]
if ( vapk > 5.0 )
  set lab = outside_model_validity
else
  set lab = within_esd7_model_range
end
let vfmax = maximum(vf)
let vrmax = maximum(-vf)
let idmin = minimum(idv)
let idmax = maximum(idv)
let vfat = minimum(vf*mk_qn + (1-mk_qn)*1e9)
let idat = minimum(idv*mk_qn + (1-mk_qn)*1e9)
echo "RESULT pulse_qn_XDLN vfwd_at_ipk_V=$&vfat id_at_ipk_A=$&idat vfwd_max_V=$&vfmax vrev_max_V=$&vrmax vabs_max_V=$&vapk id_min_A=$&idmin id_max_A=$&idmax validity=$lab current_validity=no_current_validity_range_on_record"
let vrsa = maximum(abs(v(rxg_qn) - v(pad_qn)))
echo "RESULT pulse_qn_XRS vabs_V=$&vrsa validity=no_validity_range_on_record current_validity=no_current_validity_range_on_record"
quit
.endc
.end
