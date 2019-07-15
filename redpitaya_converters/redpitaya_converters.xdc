### DAC
# data
set_property IOSTANDARD LVCMOS33 [get_ports {phys_interface_0_dac_dat[*]}]
set_property SLEW SLOW [get_ports {phys_interface_0_dac_dat[*]}]
set_property DRIVE 4 [get_ports {phys_interface_0_dac_dat[*]}]

set_property PACKAGE_PIN M19 [get_ports {phys_interface_0_dac_dat[0]}]
set_property PACKAGE_PIN M20 [get_ports {phys_interface_0_dac_dat[1]}]
set_property PACKAGE_PIN L19 [get_ports {phys_interface_0_dac_dat[2]}]
set_property PACKAGE_PIN L20 [get_ports {phys_interface_0_dac_dat[3]}]
set_property PACKAGE_PIN K19 [get_ports {phys_interface_0_dac_dat[4]}]
set_property PACKAGE_PIN J19 [get_ports {phys_interface_0_dac_dat[5]}]
set_property PACKAGE_PIN J20 [get_ports {phys_interface_0_dac_dat[6]}]
set_property PACKAGE_PIN H20 [get_ports {phys_interface_0_dac_dat[7]}]
set_property PACKAGE_PIN G19 [get_ports {phys_interface_0_dac_dat[8]}]
set_property PACKAGE_PIN G20 [get_ports {phys_interface_0_dac_dat[9]}]
set_property PACKAGE_PIN F19 [get_ports {phys_interface_0_dac_dat[10]}]
set_property PACKAGE_PIN F20 [get_ports {phys_interface_0_dac_dat[11]}]
set_property PACKAGE_PIN D20 [get_ports {phys_interface_0_dac_dat[12]}]
set_property PACKAGE_PIN D19 [get_ports {phys_interface_0_dac_dat[13]}]

# control
set_property IOSTANDARD LVCMOS33 [get_ports phys_interface_0_dac_*]
set_property SLEW FAST [get_ports phys_interface_0_dac_*]
set_property DRIVE 8 [get_ports phys_interface_0_dac_*]

set_property PACKAGE_PIN M17 [get_ports phys_interface_0_dac_wrt]
set_property PACKAGE_PIN N16 [get_ports phys_interface_0_dac_sel]
set_property PACKAGE_PIN M18 [get_ports phys_interface_0_dac_clk]
set_property PACKAGE_PIN N15 [get_ports phys_interface_0_dac_rst]

### PLL
set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports phys_interface_0_clk_p]
set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports phys_interface_0_clk_n]
set_property PACKAGE_PIN U18 [get_ports phys_interface_0_clk_p]
set_property PACKAGE_PIN U19 [get_ports phys_interface_0_clk_n]

