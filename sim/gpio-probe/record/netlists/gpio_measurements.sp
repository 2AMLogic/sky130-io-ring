* gpio_measurements.sp -- PDK-independent single-corner GPIO measurement deck.
* Names no PDK path, device, model or corner. The caller (sim/<bench>/run.sh)
* supplies, before including this file:
*   .param vddio_v=<V> vdd_v=<V>             nominal rails
*   .subckt gpio_dut A OE IE PU PD Y PAD VDDIO VDD VSS ... .ends
*                                            adapter onto the cell under test
*                                            (the only place a cell name appears)
*   the model library, .temp, and the final .end
* Definitions follow spec/io-ring.md (GF.1-3, GF.7-8, GE.1-8, GE.10). Every
* RESULT line carries the spec row id(s) in row= and, where the row has a
* proposed target, that target as text in proposed_target= (corner named in the
* text; this deck runs one corner). There is no pass/fail field: the rows are
* proposed and most name a worst-case corner this deck does not run.
*
* Conventions
*   A, OE, IE, PU, PD and Y use the core rail (vdd_v). PAD uses the I/O rail (vddio_v).
*   "pad_forced=no": PAD is free (1e12 ohm to its force source). Forced: an
*   ideal source behind 1 mohm; i_pad_into_dut_A is the current that source
*   supplies into the PAD pin (positive = into the cell). il_A > 0 sinks from
*   PAD (output loaded), il_A < 0 sources into PAD. Y is unloaded. Stimulus
*   edges (A, PAD) are 0.1 ns; the transfer ramp is 30 us per direction.
.csparam vddio_v={vddio_v}
.csparam vdd_v={vdd_v}
Vddio vddio 0 dc {vddio_v}
Vdd vdd 0 dc {vdd_v}

* static bench: DC controls, optional forced PAD, optional load current
.subckt gpio_tb_dc y pad vddio vdd params: va=0 voe=0 vie=0 vpu=0 vpd=0 vpf=0 rf=1m il=0
Va a 0 dc {va}
Voe oe 0 dc {voe}
Vie ie 0 dc {vie}
Vpu pu 0 dc {vpu}
Vpd pd 0 dc {vpd}
Vpf pf 0 dc {vpf}
Rf pf pad {rf}
Il pad 0 dc {il}
Xd a oe ie pu pd y pad vddio vdd 0 gpio_dut
.ends

* sweep bench: PAD is a port so the caller sweeps its source (GE.6)
.subckt gpio_tb_sw y pad vddio vdd params: va=0 voe=0 vie=0 vpu=0 vpd=0
Va a 0 dc {va}
Voe oe 0 dc {voe}
Vie ie 0 dc {vie}
Vpu pu 0 dc {vpu}
Vpd pd 0 dc {vpd}
Xd a oe ie pu pd y pad vddio vdd 0 gpio_dut
.ends

* output-path bench: A pulses 0 -> vdd_v -> 0, 10 pF on PAD (GE.3, GE.4, GE.7)
.subckt gpio_tb_out y pad vddio vdd
Va a 0 pulse(0 {vdd_v} 5n 0.1n 0.1n 20n 1)
Voe oe 0 dc {vdd_v}
Vie ie 0 dc {vdd_v}
Vpu pu 0 dc 0
Vpd pd 0 dc 0
Cl pad 0 10p
Xd a oe ie pu pd y pad vddio vdd 0 gpio_dut
.ends

* input-path bench: PAD pulses 0 -> vddio_v -> 0 from an ideal source (GE.8)
.subckt gpio_tb_in y pad vddio vdd
Va a 0 dc 0
Voe oe 0 dc 0
Vie ie 0 dc {vdd_v}
Vpu pu 0 dc 0
Vpd pd 0 dc 0
Vpf pf 0 pulse(0 {vddio_v} 5n 0.1n 0.1n 20n 1)
Rf pf pad 1m
Xd a oe ie pu pd y pad vddio vdd 0 gpio_dut
.ends

* transfer bench: PAD ramps 0 -> vddio_v -> 0, 30 us each way, IE on (GE.5, GF.7)
.subckt gpio_tb_xf y pad vddio vdd
Va a 0 dc 0
Voe oe 0 dc 0
Vie ie 0 dc {vdd_v}
Vpu pu 0 dc 0
Vpd pd 0 dc 0
Vpf pf 0 pwl(0 0 1u 0 31u {vddio_v} 32u {vddio_v} 62u 0 63u 0)
Rf pf pad 1m
Xd a oe ie pu pd y pad vddio vdd 0 gpio_dut
.ends

Xs_drv_hi y_drv_hi p_drv_hi vddio vdd gpio_tb_dc va={vdd_v} voe={vdd_v} vie={vdd_v} vpu=0 vpd=0 vpf=0 rf=1e12 il=0
Xs_drv_lo y_drv_lo p_drv_lo vddio vdd gpio_tb_dc va=0 voe={vdd_v} vie={vdd_v} vpu=0 vpd=0 vpf=0 rf=1e12 il=0
Xs_drv_hi_ie0 y_drv_hi_ie0 p_drv_hi_ie0 vddio vdd gpio_tb_dc va={vdd_v} voe={vdd_v} vie=0 vpu=0 vpd=0 vpf=0 rf=1e12 il=0
Xs_drv_lo_ie0 y_drv_lo_ie0 p_drv_lo_ie0 vddio vdd gpio_tb_dc va=0 voe={vdd_v} vie=0 vpu=0 vpd=0 vpf=0 rf=1e12 il=0
Xs_in_hi_ie1 y_in_hi_ie1 p_in_hi_ie1 vddio vdd gpio_tb_dc va=0 voe=0 vie={vdd_v} vpu=0 vpd=0 vpf={vddio_v} rf=1m il=0
Xs_in_lo_ie1 y_in_lo_ie1 p_in_lo_ie1 vddio vdd gpio_tb_dc va={vdd_v} voe=0 vie={vdd_v} vpu=0 vpd=0 vpf=0 rf=1m il=0
Xs_in_hi_ie0 y_in_hi_ie0 p_in_hi_ie0 vddio vdd gpio_tb_dc va=0 voe=0 vie=0 vpu=0 vpd=0 vpf={vddio_v} rf=1m il=0
Xs_in_lo_ie0 y_in_lo_ie0 p_in_lo_ie0 vddio vdd gpio_tb_dc va={vdd_v} voe=0 vie=0 vpu=0 vpd=0 vpf=0 rf=1m il=0
Xs_hz_hi y_hz_hi p_hz_hi vddio vdd gpio_tb_dc va=0 voe=0 vie={vdd_v} vpu=0 vpd=0 vpf={vddio_v} rf=1m il=0
Xs_hz_lo y_hz_lo p_hz_lo vddio vdd gpio_tb_dc va={vdd_v} voe=0 vie={vdd_v} vpu=0 vpd=0 vpf=0 rf=1m il=0
Xs_contention_hi y_contention_hi p_contention_hi vddio vdd gpio_tb_dc va=0 voe={vdd_v} vie={vdd_v} vpu=0 vpd=0 vpf={vddio_v} rf=1m il=0
Xs_contention_lo y_contention_lo p_contention_lo vddio vdd gpio_tb_dc va={vdd_v} voe={vdd_v} vie={vdd_v} vpu=0 vpd=0 vpf=0 rf=1m il=0
Xs_pu_free y_pu_free p_pu_free vddio vdd gpio_tb_dc va=0 voe=0 vie={vdd_v} vpu={vdd_v} vpd=0 vpf=0 rf=1e12 il=0
Xs_pd_free y_pd_free p_pd_free vddio vdd gpio_tb_dc va=0 voe=0 vie={vdd_v} vpu=0 vpd={vdd_v} vpf=0 rf=1e12 il=0
Xs_both_free y_both_free p_both_free vddio vdd gpio_tb_dc va=0 voe=0 vie={vdd_v} vpu={vdd_v} vpd={vdd_v} vpf=0 rf=1e12 il=0
Xs_off_free y_off_free p_off_free vddio vdd gpio_tb_dc va=0 voe=0 vie={vdd_v} vpu=0 vpd=0 vpf=0 rf=1e12 il=0
Xs_pu_mid y_pu_mid p_pu_mid vddio vdd gpio_tb_dc va=0 voe=0 vie={vdd_v} vpu={vdd_v} vpd=0 vpf={vddio_v/2} rf=1m il=0
Xs_pd_mid y_pd_mid p_pd_mid vddio vdd gpio_tb_dc va=0 voe=0 vie={vdd_v} vpu=0 vpd={vdd_v} vpf={vddio_v/2} rf=1m il=0
Xs_both_mid y_both_mid p_both_mid vddio vdd gpio_tb_dc va=0 voe=0 vie={vdd_v} vpu={vdd_v} vpd={vdd_v} vpf={vddio_v/2} rf=1m il=0
Xs_off_mid y_off_mid p_off_mid vddio vdd gpio_tb_dc va=0 voe=0 vie={vdd_v} vpu=0 vpd=0 vpf={vddio_v/2} rf=1m il=0
Xs_inh_pu y_inh_pu p_inh_pu vddio vdd gpio_tb_dc va=0 voe={vdd_v} vie={vdd_v} vpu={vdd_v} vpd=0 vpf=0 rf=1m il=0
Xs_inh_pu_ref y_inh_pu_ref p_inh_pu_ref vddio vdd gpio_tb_dc va=0 voe=0 vie={vdd_v} vpu={vdd_v} vpd=0 vpf=0 rf=1m il=0
Xs_inh_pd y_inh_pd p_inh_pd vddio vdd gpio_tb_dc va={vdd_v} voe={vdd_v} vie={vdd_v} vpu=0 vpd={vdd_v} vpf={vddio_v} rf=1m il=0
Xs_inh_pd_ref y_inh_pd_ref p_inh_pd_ref vddio vdd gpio_tb_dc va={vdd_v} voe=0 vie={vdd_v} vpu=0 vpd={vdd_v} vpf={vddio_v} rf=1m il=0
Xs_voh y_voh p_voh vddio vdd gpio_tb_dc va={vdd_v} voe={vdd_v} vie=0 vpu=0 vpd=0 vpf=0 rf=1e12 il=4m
Xs_vol y_vol p_vol vddio vdd gpio_tb_dc va=0 voe={vdd_v} vie=0 vpu=0 vpd=0 vpf=0 rf=1e12 il=-4m
Xlk ylk plk vddio vdd gpio_tb_sw voe=0 vie={vdd_v}
Vlk plk 0 dc 0
Xo y_o p_o vddio vdd gpio_tb_out
Xi y_i p_i vddio vdd gpio_tb_in
Xf y_f p_f vddio vdd gpio_tb_xf

.control
set noaskquit
* ----------------------------------------------------- static (op), GF / GE.1-2
op
let vp_drv_hi = v(p_drv_hi)
let vy_drv_hi = v(y_drv_hi)
echo "RESULT st_drv_hi row=GF.1,GF.8 pad_forced=no il_A=0 pad_V=$&vp_drv_hi y_V=$&vy_drv_hi"
let vp_drv_lo = v(p_drv_lo)
let vy_drv_lo = v(y_drv_lo)
echo "RESULT st_drv_lo row=GF.1,GF.8 pad_forced=no il_A=0 pad_V=$&vp_drv_lo y_V=$&vy_drv_lo"
let vp_drv_hi_ie0 = v(p_drv_hi_ie0)
let vy_drv_hi_ie0 = v(y_drv_hi_ie0)
echo "RESULT st_drv_hi_ie0 row=GF.2 pad_forced=no il_A=0 pad_V=$&vp_drv_hi_ie0 y_V=$&vy_drv_hi_ie0"
let vp_drv_lo_ie0 = v(p_drv_lo_ie0)
let vy_drv_lo_ie0 = v(y_drv_lo_ie0)
echo "RESULT st_drv_lo_ie0 row=GF.2 pad_forced=no il_A=0 pad_V=$&vp_drv_lo_ie0 y_V=$&vy_drv_lo_ie0"
let vp_in_hi_ie1 = v(p_in_hi_ie1)
let vy_in_hi_ie1 = v(y_in_hi_ie1)
let ip_in_hi_ie1 = 0 - v.xs_in_hi_ie1.vpf#branch
echo "RESULT st_in_hi_ie1 row=GF.2,GF.8 pad_forced=yes il_A=0 pad_V=$&vp_in_hi_ie1 y_V=$&vy_in_hi_ie1 i_pad_into_dut_A=$&ip_in_hi_ie1"
let vp_in_lo_ie1 = v(p_in_lo_ie1)
let vy_in_lo_ie1 = v(y_in_lo_ie1)
let ip_in_lo_ie1 = 0 - v.xs_in_lo_ie1.vpf#branch
echo "RESULT st_in_lo_ie1 row=GF.2,GF.8 pad_forced=yes il_A=0 pad_V=$&vp_in_lo_ie1 y_V=$&vy_in_lo_ie1 i_pad_into_dut_A=$&ip_in_lo_ie1"
let vp_in_hi_ie0 = v(p_in_hi_ie0)
let vy_in_hi_ie0 = v(y_in_hi_ie0)
let ip_in_hi_ie0 = 0 - v.xs_in_hi_ie0.vpf#branch
echo "RESULT st_in_hi_ie0 row=GF.2 pad_forced=yes il_A=0 pad_V=$&vp_in_hi_ie0 y_V=$&vy_in_hi_ie0 i_pad_into_dut_A=$&ip_in_hi_ie0"
let vp_in_lo_ie0 = v(p_in_lo_ie0)
let vy_in_lo_ie0 = v(y_in_lo_ie0)
let ip_in_lo_ie0 = 0 - v.xs_in_lo_ie0.vpf#branch
echo "RESULT st_in_lo_ie0 row=GF.2 pad_forced=yes il_A=0 pad_V=$&vp_in_lo_ie0 y_V=$&vy_in_lo_ie0 i_pad_into_dut_A=$&ip_in_lo_ie0"
let vp_hz_hi = v(p_hz_hi)
let vy_hz_hi = v(y_hz_hi)
let ip_hz_hi = 0 - v.xs_hz_hi.vpf#branch
echo "RESULT st_hz_hi row=GF.1 pad_forced=yes il_A=0 pad_V=$&vp_hz_hi y_V=$&vy_hz_hi i_pad_into_dut_A=$&ip_hz_hi"
let vp_hz_lo = v(p_hz_lo)
let vy_hz_lo = v(y_hz_lo)
let ip_hz_lo = 0 - v.xs_hz_lo.vpf#branch
echo "RESULT st_hz_lo row=GF.1 pad_forced=yes il_A=0 pad_V=$&vp_hz_lo y_V=$&vy_hz_lo i_pad_into_dut_A=$&ip_hz_lo"
let vp_contention_hi = v(p_contention_hi)
let vy_contention_hi = v(y_contention_hi)
let ip_contention_hi = 0 - v.xs_contention_hi.vpf#branch
echo "RESULT st_contention_hi row=GF.1 pad_forced=yes il_A=0 pad_V=$&vp_contention_hi y_V=$&vy_contention_hi i_pad_into_dut_A=$&ip_contention_hi"
let vp_contention_lo = v(p_contention_lo)
let vy_contention_lo = v(y_contention_lo)
let ip_contention_lo = 0 - v.xs_contention_lo.vpf#branch
echo "RESULT st_contention_lo row=GF.1 pad_forced=yes il_A=0 pad_V=$&vp_contention_lo y_V=$&vy_contention_lo i_pad_into_dut_A=$&ip_contention_lo"
let vp_pu_free = v(p_pu_free)
let vy_pu_free = v(y_pu_free)
echo "RESULT st_pu_free row=GF.3 pad_forced=no il_A=0 pad_V=$&vp_pu_free y_V=$&vy_pu_free"
let vp_pd_free = v(p_pd_free)
let vy_pd_free = v(y_pd_free)
echo "RESULT st_pd_free row=GF.3 pad_forced=no il_A=0 pad_V=$&vp_pd_free y_V=$&vy_pd_free"
let vp_both_free = v(p_both_free)
let vy_both_free = v(y_both_free)
echo "RESULT st_both_free row=GF.3 pad_forced=no il_A=0 pad_V=$&vp_both_free y_V=$&vy_both_free"
let vp_off_free = v(p_off_free)
let vy_off_free = v(y_off_free)
echo "RESULT st_off_free row=GF.3 pad_forced=no il_A=0 pad_V=$&vp_off_free y_V=$&vy_off_free"
let vp_pu_mid = v(p_pu_mid)
let vy_pu_mid = v(y_pu_mid)
let ip_pu_mid = 0 - v.xs_pu_mid.vpf#branch
echo "RESULT st_pu_mid row=GF.3,GE.10 pad_forced=yes il_A=0 pad_V=$&vp_pu_mid y_V=$&vy_pu_mid i_pad_into_dut_A=$&ip_pu_mid"
let vp_pd_mid = v(p_pd_mid)
let vy_pd_mid = v(y_pd_mid)
let ip_pd_mid = 0 - v.xs_pd_mid.vpf#branch
echo "RESULT st_pd_mid row=GF.3,GE.10 pad_forced=yes il_A=0 pad_V=$&vp_pd_mid y_V=$&vy_pd_mid i_pad_into_dut_A=$&ip_pd_mid"
let vp_both_mid = v(p_both_mid)
let vy_both_mid = v(y_both_mid)
let ip_both_mid = 0 - v.xs_both_mid.vpf#branch
echo "RESULT st_both_mid row=GF.3 pad_forced=yes il_A=0 pad_V=$&vp_both_mid y_V=$&vy_both_mid i_pad_into_dut_A=$&ip_both_mid"
let vp_off_mid = v(p_off_mid)
let vy_off_mid = v(y_off_mid)
let ip_off_mid = 0 - v.xs_off_mid.vpf#branch
echo "RESULT st_off_mid row=GF.3,GE.10 pad_forced=yes il_A=0 pad_V=$&vp_off_mid y_V=$&vy_off_mid i_pad_into_dut_A=$&ip_off_mid"
let vp_inh_pu = v(p_inh_pu)
let vy_inh_pu = v(y_inh_pu)
let ip_inh_pu = 0 - v.xs_inh_pu.vpf#branch
echo "RESULT st_inh_pu row=GF.3 pad_forced=yes il_A=0 pad_V=$&vp_inh_pu y_V=$&vy_inh_pu i_pad_into_dut_A=$&ip_inh_pu"
let vp_inh_pu_ref = v(p_inh_pu_ref)
let vy_inh_pu_ref = v(y_inh_pu_ref)
let ip_inh_pu_ref = 0 - v.xs_inh_pu_ref.vpf#branch
echo "RESULT st_inh_pu_ref row=GF.3 pad_forced=yes il_A=0 pad_V=$&vp_inh_pu_ref y_V=$&vy_inh_pu_ref i_pad_into_dut_A=$&ip_inh_pu_ref"
let vp_inh_pd = v(p_inh_pd)
let vy_inh_pd = v(y_inh_pd)
let ip_inh_pd = 0 - v.xs_inh_pd.vpf#branch
echo "RESULT st_inh_pd row=GF.3 pad_forced=yes il_A=0 pad_V=$&vp_inh_pd y_V=$&vy_inh_pd i_pad_into_dut_A=$&ip_inh_pd"
let vp_inh_pd_ref = v(p_inh_pd_ref)
let vy_inh_pd_ref = v(y_inh_pd_ref)
let ip_inh_pd_ref = 0 - v.xs_inh_pd_ref.vpf#branch
echo "RESULT st_inh_pd_ref row=GF.3 pad_forced=yes il_A=0 pad_V=$&vp_inh_pd_ref y_V=$&vy_inh_pd_ref i_pad_into_dut_A=$&ip_inh_pd_ref"
let vp_voh = v(p_voh)
let vy_voh = v(y_voh)
echo "RESULT st_voh row=GE.1 pad_forced=no il_A=0.004 pad_V=$&vp_voh y_V=$&vy_voh proposed_target=ge_VDDIO_minus_0p4V_at_IOH_minus4mA_corner_ss_125C_VDDIO_2p97V_VDD_1p62V"
let vp_vol = v(p_vol)
let vy_vol = v(y_vol)
echo "RESULT st_vol row=GE.2 pad_forced=no il_A=-0.004 pad_V=$&vp_vol y_V=$&vy_vol proposed_target=le_0p4V_at_IOL_4mA_corner_ss_125C_VDDIO_2p97V_VDD_1p62V"
* pull resistance (GE.10): pulls-on current net of the pulls-off current at the same bias
let vmid = vddio_v / 2
let r_pu = (vddio_v - vmid) / (ip_off_mid - ip_pu_mid)
let r_pd = vmid / (ip_pd_mid - ip_off_mid)
echo "RESULT pull_resistance row=GE.10 bias_V=$&vmid r_pullup_ohm=$&r_pu r_pulldown_ohm=$&r_pd proposed_target=20k_to_60k_ohm_at_VPAD_VDDIO_half_all_corners"
* ----------------------------------------------------- pad leakage sweep (GE.6)
* OE=0, PU=PD=0, IE on; PAD forced 0..vddio_v in 33 dc steps; settled (dc) current.
let lstep = vddio_v / 33
dc vlk 0 $&vddio_v $&lstep
let ipl = 0 - i(vlk)
let npts = length(ipl)
let kk = 0
let best = 0
let bk = 0
while kk < npts
  if abs(ipl[kk]) > best
    let best = abs(ipl[kk])
    let bk = kk
  end
  let kk = kk + 1
end
let vbk = v(plk)[bk]
let ibk = ipl[bk]
let i_at_0 = ipl[0]
let i_at_vddio = ipl[npts - 1]
echo "RESULT leakage_sweep row=GE.6 points=$&npts imax_abs_A=$&best imax_signed_A=$&ibk imax_at_pad_V=$&vbk i_at_pad_0V_A=$&i_at_0 i_at_pad_VDDIO_A=$&i_at_vddio proposed_target=le_100nA_0_to_VDDIO_25C_corner_ff_VDDIO_3p63V"
* ----------------------------------------------------- edges and delays (GE.3, GE.4, GE.7, GE.8)
tran 20p 60n 0 20p
let v20 = 0.2 * vddio_v
let v80 = 0.8 * vddio_v
let hio = 0.5 * vddio_v
let hcore = 0.5 * vdd_v
meas tran tr_s trig v(p_o) val=$&v20 rise=1 targ v(p_o) val=$&v80 rise=1
meas tran tf_s trig v(p_o) val=$&v80 fall=1 targ v(p_o) val=$&v20 fall=1
let slew_r = 0.6 * vddio_v / (tr_s * 1e9)
let slew_f = 0.6 * vddio_v / (tf_s * 1e9)
echo "RESULT edge_rate_10pF row=GE.3,GE.4 tr_20_80_s=$&tr_s tf_80_20_s=$&tf_s slew_rise_V_per_ns=$&slew_r slew_fall_V_per_ns=$&slew_f stimulus_edge_s=1e-10 proposed_target=GE.3_le_3ns_corner_ss_125C_VDDIO_2p97V_and_GE.4_ge_0p8ns_corner_ff_m40C_VDDIO_3p63V"
meas tran dout_r trig v(xo.a) val=$&hcore rise=1 targ v(p_o) val=$&hio rise=1
meas tran dout_f trig v(xo.a) val=$&hcore fall=1 targ v(p_o) val=$&hio fall=1
echo "RESULT delay_output_path_10pF row=GE.7 a_rise_to_pad_rise_s=$&dout_r a_fall_to_pad_fall_s=$&dout_f a_threshold_V=$&hcore pad_threshold_V=$&hio proposed_target=le_5ns_into_10pF_corner_ss_125C_VDDIO_2p97V_VDD_1p62V"
meas tran din_r trig v(p_i) val=$&hio rise=1 targ v(y_i) val=$&hcore rise=1
meas tran din_f trig v(p_i) val=$&hio fall=1 targ v(y_i) val=$&hcore fall=1
echo "RESULT delay_input_path row=GE.8 pad_rise_to_y_rise_s=$&din_r pad_fall_to_y_fall_s=$&din_f pad_threshold_V=$&hio y_threshold_V=$&hcore proposed_target=le_3ns_corner_ss_125C_VDDIO_2p97V_VDD_1p62V"
* ----------------------------------------------------- input thresholds and hysteresis (GE.5, GF.7)
* VIH_obs: PAD when Y rises through vdd_v/2 on the rising ramp; VIL_obs: PAD when
* Y falls through vdd_v/2 on the falling ramp. y_at_* is Y with PAD at 0.3 / 0.7 x vddio_v.
tran 20n 63u 0 20n
let v30 = 0.3 * vddio_v
let v70 = 0.7 * vddio_v
let hcore = 0.5 * vdd_v
meas tran vih_obs find v(p_f) when v(y_f)=$&hcore rise=1
meas tran vil_obs find v(p_f) when v(y_f)=$&hcore fall=1
let hyst = vih_obs - vil_obs
meas tran y30r find v(y_f) when v(p_f)=$&v30 rise=1
meas tran y70r find v(y_f) when v(p_f)=$&v70 rise=1
meas tran y30f find v(y_f) when v(p_f)=$&v30 fall=1
meas tran y70f find v(y_f) when v(p_f)=$&v70 fall=1
echo "RESULT input_thresholds row=GE.5 vih_obs_V=$&vih_obs vil_obs_V=$&vil_obs pad_at_0p3_vddio_V=$&v30 pad_at_0p7_vddio_V=$&v70 y_at_0p3_rising_V=$&y30r y_at_0p7_rising_V=$&y70r y_at_0p3_falling_V=$&y30f y_at_0p7_falling_V=$&y70f proposed_target=VIL_le_0p3_VDDIO_and_VIH_ge_0p7_VDDIO_all_corners"
echo "RESULT input_hysteresis row=GF.7 hyst_V=$&hyst temp_c=27 proposed_target=ge_200mV_VDDIO_3p30V_tt_25C"
quit
.endc
