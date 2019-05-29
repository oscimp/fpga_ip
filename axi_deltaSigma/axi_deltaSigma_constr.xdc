set ctrl_clk [get_clocks -of_objects [get_ports s_axi_aclk]]
set data_clk [get_clocks -of_objects [get_ports data_clk_i]]

set_property ASYNC_REG TRUE \
	[get_cells -hier cdc_sync_stage1_*_reg] \
	[get_cells -hier cdc_sync_stage2_*_reg]

set_false_path \
	-from [get_cells -hier cdc_sync_stage0_*_reg -filter {IS_SEQUENTIAL}] \
	-to [get_cells -hier cdc_sync_stage1_*_reg -filter {IS_SEQUENTIAL}]

# Reset
set_false_path \
	-to [get_pins -hier data_reset_vec_reg*/PRE]
