# project properties
set_project_property DEVICE_FAMILY {Cyclone V}
set_project_property DEVICE {5CSEMA4U23C6}
# instances and instance parameters
add_instance hps altera_hps
set_instance_parameter_value hps hps_device_family {Cyclone V}
set_instance_parameter_value hps device_name {5CSEMA4U23C6}
set_instance_parameter_value hps AUTO_DEVICE_SPEEDGRADE {6}
set_instance_parameter_value hps MPU_EVENTS_Enable {0}
set_instance_parameter_value hps STM_Enable {0}
set_instance_parameter_value hps F2SCLK_DBGRST_Enable {0}
set_instance_parameter_value hps F2SCLK_WARMRST_Enable {0}
set_instance_parameter_value hps F2SCLK_COLDRST_Enable {0}
set_instance_parameter_value hps F2SDRAM_Name_DERIVED {}
set_instance_parameter_value hps F2SDRAM_Type {}
set_instance_parameter_value hps F2SDRAM_Width {}
set_instance_parameter_value hps F2SDRAM_Width_Last_Size {0}
set_instance_parameter_value hps F2SDRAM_CMD_PORT_USED {0x0}
set_instance_parameter_value hps F2SDRAM_WR_PORT_USED {0x0}
set_instance_parameter_value hps F2SDRAM_RD_PORT_USED {0x0}
set_instance_parameter_value hps F2SDRAM_RST_PORT_USED {0x0}
set_instance_parameter_value hps F2SINTERRUPT_Enable {1}
set_instance_parameter_value hps EMAC1_PinMuxing {HPS I/O Set 0}
set_instance_parameter_value hps EMAC1_Mode {RGMII}
set_instance_parameter_value hps SDIO_PinMuxing {HPS I/O Set 0}
set_instance_parameter_value hps SDIO_Mode {4-bit Data}
set_instance_parameter_value hps USB1_PinMuxing {HPS I/O Set 0}
set_instance_parameter_value hps USB1_Mode {SDR}
set_instance_parameter_value hps SPIM1_PinMuxing {HPS I/O Set 0}
set_instance_parameter_value hps SPIM1_Mode {Single Slave Select}
set_instance_parameter_value hps UART0_PinMuxing {HPS I/O Set 0}
set_instance_parameter_value hps UART0_Mode {No Flow Control}
set_instance_parameter_value hps I2C0_PinMuxing {HPS I/O Set 0}
set_instance_parameter_value hps I2C0_Mode {I2C}
set_instance_parameter_value hps I2C1_PinMuxing {HPS I/O Set 0}
set_instance_parameter_value hps I2C1_Mode {I2C}
set_instance_parameter_value hps MEM_CLK_FREQ {400.0}
set_instance_parameter_value hps REF_CLK_FREQ {25.0}
set_instance_parameter_value hps MEM_VENDOR {Other}
set_instance_parameter_value hps MEM_CLK_FREQ_MAX {800.0}
set_instance_parameter_value hps MEM_DQ_WIDTH {32}
set_instance_parameter_value hps MEM_ROW_ADDR_WIDTH {15}
set_instance_parameter_value hps MEM_COL_ADDR_WIDTH {10}
set_instance_parameter_value hps MEM_RTT_NOM {RZQ/6}
set_instance_parameter_value hps MEM_WTCL {7}
set_instance_parameter_value hps MEM_TINIT_US {500}
set_instance_parameter_value hps MEM_TMRD_CK {4}
set_instance_parameter_value hps MEM_TRAS_NS {35.0}
set_instance_parameter_value hps MEM_TRCD_NS {13.75}
set_instance_parameter_value hps MEM_TREFI_US {7.8}
set_instance_parameter_value hps MEM_TRFC_NS {300.0}
set_instance_parameter_value hps MEM_TWTR {4}
set_instance_parameter_value hps MEM_TRP_NS {13.75}
set_instance_parameter_value hps S2FCLK_USER0CLK_Enable {1}
set_instance_parameter_value hps S2FCLK_USER1CLK_Enable {0}
set_instance_parameter_value hps S2FCLK_USER1CLK_FREQ {100.0}
set_instance_parameter_value hps S2FCLK_USER2CLK {5}
set_instance_parameter_value hps S2FCLK_USER2CLK_Enable {0}
set_instance_parameter_value hps S2FCLK_USER2CLK_FREQ {100.0}

# HPS IO
add_interface hps_io conduit end
set_interface_property hps_io EXPORT_OF hps.hps_io
# HPS memory
add_interface memory conduit end
set_interface_property memory EXPORT_OF hps.memory

# Mandatory to distribute clk to HPS and to slave IPs
#add_instance clk_0 clock_source
#set_instance_parameter_value clk_0 clockFrequency {50000000.0}
#set_instance_parameter_value clk_0 clockFrequencyKnown {1}
#set_instance_parameter_value clk_0 inputClockFrequency {0.0}
#set_instance_parameter_value clk_0 resetSynchronousEdges {NONE}

# HPS reset -> clk
#add_connection hps.h2f_reset clk_0.clk_in_reset

# clk -> everything
#add_connection clk_0.clk hps_0.f2h_axi_clock
#add_connection clk_0.clk hps_0.h2f_axi_clock
#add_connection clk_0.clk hps_0.h2f_lw_axi_clock

add_connection hps.h2f_user0_clock hps.f2h_axi_clock
add_connection hps.h2f_user0_clock hps.h2f_axi_clock
add_connection hps.h2f_user0_clock hps.h2f_lw_axi_clock
