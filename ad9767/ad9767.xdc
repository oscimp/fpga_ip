### DAC
# data
set_property IOSTANDARD LVCMOS33 [get_ports {dac_dat_o_0[*]}]
set_property SLEW SLOW [get_ports {dac_dat_o_0[*]}]
set_property DRIVE 4 [get_ports {dac_dat_o_0[*]}]

set_property PACKAGE_PIN M19 [get_ports {dac_dat_o_0[0]}]
set_property PACKAGE_PIN M20 [get_ports {dac_dat_o_0[1]}]
set_property PACKAGE_PIN L19 [get_ports {dac_dat_o_0[2]}]
set_property PACKAGE_PIN L20 [get_ports {dac_dat_o_0[3]}]
set_property PACKAGE_PIN K19 [get_ports {dac_dat_o_0[4]}]
set_property PACKAGE_PIN J19 [get_ports {dac_dat_o_0[5]}]
set_property PACKAGE_PIN J20 [get_ports {dac_dat_o_0[6]}]
set_property PACKAGE_PIN H20 [get_ports {dac_dat_o_0[7]}]
set_property PACKAGE_PIN G19 [get_ports {dac_dat_o_0[8]}]
set_property PACKAGE_PIN G20 [get_ports {dac_dat_o_0[9]}]
set_property PACKAGE_PIN F19 [get_ports {dac_dat_o_0[10]}]
set_property PACKAGE_PIN F20 [get_ports {dac_dat_o_0[11]}]
set_property PACKAGE_PIN D20 [get_ports {dac_dat_o_0[12]}]
set_property PACKAGE_PIN D19 [get_ports {dac_dat_o_0[13]}]

# control
set_property IOSTANDARD LVCMOS33 [get_ports dac_*_o_0]
set_property SLEW FAST [get_ports dac_*_o_0]
set_property DRIVE 8 [get_ports dac_*_o_0]

set_property PACKAGE_PIN M17 [get_ports dac_wrt_o_0]
set_property PACKAGE_PIN N16 [get_ports dac_sel_o_0]
set_property PACKAGE_PIN M18 [get_ports dac_clk_o_0]
set_property PACKAGE_PIN N15 [get_ports dac_rst_o_0]
