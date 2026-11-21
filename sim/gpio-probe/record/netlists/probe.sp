* gpio-probe: single-corner probe, tt, 27 C, nominal rails
.lib $PDK_ROOT/sky130A/libs.tech/ngspice/sky130.lib.spice tt
.temp 27
.param vddio_v=3.30 vdd_v=1.80
.include ./sky130_ioring_gpio.spice
.subckt gpio_dut A OE IE PU PD Y PAD VDDIO VDD VSS
X1 A OE IE PU PD Y PAD VDDIO VDD VSS sky130_ioring_gpio
.ends
.include $REPO/sim/lib/gpio_measurements.sp
.end
