### DAC reset
set_property IOSTANDARD LVCMOS33 [get_ports phys_interface_0_dac_rst]
set_property PACKAGE_PIN F16 [get_ports phys_interface_0_dac_rst]

### DAC data
set_property IOSTANDARD LVCMOS33 [get_ports {phys_interface_0_dac_dat_?[*]}]
set_property SLEW FAST [get_ports {phys_interface_0_dac_dat_?[*]}]
set_property DRIVE 8 [get_ports {phys_interface_0_dac_dat_?[*]}]
set_property IOB TRUE [get_ports {phys_interface_0_dac_dat_?}]

set_property PACKAGE_PIN L19 [get_ports {phys_interface_0_dac_dat_a[0]}]
set_property PACKAGE_PIN L20 [get_ports {phys_interface_0_dac_dat_a[1]}]
set_property PACKAGE_PIN K19 [get_ports {phys_interface_0_dac_dat_a[2]}]
set_property PACKAGE_PIN J19 [get_ports {phys_interface_0_dac_dat_a[3]}]
set_property PACKAGE_PIN J20 [get_ports {phys_interface_0_dac_dat_a[4]}]
set_property PACKAGE_PIN J18 [get_ports {phys_interface_0_dac_dat_a[5]}]
set_property PACKAGE_PIN H20 [get_ports {phys_interface_0_dac_dat_a[6]}]
set_property PACKAGE_PIN G19 [get_ports {phys_interface_0_dac_dat_a[7]}]
set_property PACKAGE_PIN G20 [get_ports {phys_interface_0_dac_dat_a[8]}]
set_property PACKAGE_PIN F17 [get_ports {phys_interface_0_dac_dat_a[9]}]
set_property PACKAGE_PIN F20 [get_ports {phys_interface_0_dac_dat_a[10]}]
set_property PACKAGE_PIN F19 [get_ports {phys_interface_0_dac_dat_a[11]}]
set_property PACKAGE_PIN D20 [get_ports {phys_interface_0_dac_dat_a[12]}]
set_property PACKAGE_PIN D19 [get_ports {phys_interface_0_dac_dat_a[13]}]

set_property PACKAGE_PIN G18 [get_ports {phys_interface_0_dac_dat_b[0]}]
set_property PACKAGE_PIN G17 [get_ports {phys_interface_0_dac_dat_b[1]}]
set_property PACKAGE_PIN H17 [get_ports {phys_interface_0_dac_dat_b[2]}]
set_property PACKAGE_PIN H18 [get_ports {phys_interface_0_dac_dat_b[3]}]
set_property PACKAGE_PIN J16 [get_ports {phys_interface_0_dac_dat_b[4]}]
set_property PACKAGE_PIN K16 [get_ports {phys_interface_0_dac_dat_b[5]}]
set_property PACKAGE_PIN K17 [get_ports {phys_interface_0_dac_dat_b[6]}]
set_property PACKAGE_PIN L15 [get_ports {phys_interface_0_dac_dat_b[7]}]
set_property PACKAGE_PIN M20 [get_ports {phys_interface_0_dac_dat_b[8]}]
set_property PACKAGE_PIN M19 [get_ports {phys_interface_0_dac_dat_b[9]}]
set_property PACKAGE_PIN M17 [get_ports {phys_interface_0_dac_dat_b[10]}]
set_property PACKAGE_PIN M18 [get_ports {phys_interface_0_dac_dat_b[11]}]
set_property PACKAGE_PIN L17 [get_ports {phys_interface_0_dac_dat_b[12]}]
set_property PACKAGE_PIN K18 [get_ports {phys_interface_0_dac_dat_b[13]}]


### Clock
set_property IOSTANDARD DIFF_SSTL18_II [get_ports phys_interface_0_clk_*]
set_property PACKAGE_PIN U18 [get_ports phys_interface_0_clk_p]
set_property PACKAGE_PIN U19 [get_ports phys_interface_0_clk_n]


### DAC SPI control
set_property IOSTANDARD LVCMOS33 [get_ports phys_interface_0_dac_spi_*]
set_property SLEW SLOW [get_ports phys_interface_0_dac_spi_*]
set_property DRIVE 8 [get_ports phys_interface_0_dac_spi_*]
set_property PACKAGE_PIN G14 [get_ports phys_interface_0_dac_spi_csb]
set_property PACKAGE_PIN H16 [get_ports phys_interface_0_dac_spi_sdio]
set_property PACKAGE_PIN G15 [get_ports phys_interface_0_dac_spi_clk]

### PLL
set_property IOSTANDARD LVCMOS33 [get_ports phys_interface_0_pll_*]
set_property PACKAGE_PIN U7 [get_ports phys_interface_0_pll_ref]
set_property PACKAGE_PIN V6 [get_ports phys_interface_0_pll_hi]
set_property PACKAGE_PIN V5 [get_ports phys_interface_0_pll_lo]
