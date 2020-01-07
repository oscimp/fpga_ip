proc add_ip_and_conf {ip_name inst_name {conf_list {}} } {
	add_instance $inst_name $ip_name

	foreach {cnf_name cnf_value} [uplevel 1 [list subst $conf_list]] {
		set_instance_parameter_value $inst_name $cnf_name $cnf_value
	}
}

proc connect_intf {src_name src_if dest_name dest_if} {
	add_connection $src_name.$src_if $dest_name.$dest_if
}

# GGM: TODO: it's only working for simple signal
# must be expanded to interface
proc connect_to_fpga_pins {inst_name inst_bus fpga_pins} {
	add_interface $fpga_pins conduit end
	set_interface_property $fpga_pins EXPORT_OF $inst_name.$inst_bus
}

proc connect_proc {inst_name axi_bus axi_clock axi_rst base_addr} {
	add_connection hps.h2f_user0_clock $inst_name.$axi_clock
	add_connection hps.h2f_reset $inst_name.$axi_rst
	add_connection hps.h2f_lw_axi_master $inst_name.$axi_bus
	set_connection_parameter_value \
		hps.h2f_lw_axi_master/$inst_name.$axi_bus arbitrationPriority {1}
	set_connection_parameter_value \
		hps.h2f_lw_axi_master/$inst_name.$axi_bus baseAddress $base_addr
	set_connection_parameter_value \
		hps.h2f_lw_axi_master/$inst_name.$axi_bus defaultConnection {0}

}

proc connect_proc_clk {inst_name clk_if} {
	add_connection hps.h2f_user0_clock $inst_name.$clk_if
}

proc connect_proc_rst {inst_name rst_if {polarity "ACTIVE_HIGH"}} {
	add_connection hps.h2f_reset $inst_name.$rst_if
}
