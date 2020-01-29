proc add_ip_and_conf {ip_name inst_name {conf_list {}} } {
  # UPGRADE_VERSIONS == "" => latest IP version
  set vlnv_ip [get_ipdefs -all \
  	-filter "VLNV =~ *:$ip_name:* && design_tool_contexts =~ *IPI* && UPGRADE_VERSIONS == \"\""]

  set ip_inst [ create_bd_cell -type ip -vlnv $vlnv_ip $inst_name ]
  set prop_list {}
  foreach {cnf_name cnf_value} [uplevel 1 [list subst $conf_list]] {
    lappend prop_list CONFIG.$cnf_name $cnf_value
  }
  if {[llength $prop_list] > 1} {
	  set_property -dict $prop_list $ip_inst
  }
  return $ip_inst
}

proc connect_intf {src_name src_if dest_name dest_if} {
  set src_is_intf 1
  set dest_is_intf 1
  # search if src is an interface or simple signal
  set src_inst_if [get_bd_intf_pins $src_name/$src_if -quiet]
  if {$src_inst_if == ""} {
	set src_is_intf 0
    set src_inst_if [get_bd_pins $src_name/$src_if -quiet]
  }
  # search if dest is an interface or simple signal
  set dest_inst_if [get_bd_intf_pins $dest_name/$dest_if -quiet]
  if {$dest_inst_if == ""} {
	set dest_is_intf 0
    set dest_inst_if [get_bd_pins $dest_name/$dest_if -quiet]
  }

  if {$src_is_intf != $dest_is_intf} {
	  puts "connect_intf errror: try to connect a mix interface and pins"
	  exit
	  return
  }

  if {$src_is_intf == 1} {
    connect_bd_intf_net $src_inst_if $dest_inst_if
  } else {
    connect_bd_net $src_inst_if $dest_inst_if
  }

}

proc connect_to_fpga_pins {inst_name inst_bus fpga_pins} {

	set inst_if [get_bd_pins $inst_name/$inst_bus -quiet]
	# if not a signal => need to add an interface
	if {$inst_if == ""} {
		set inst_if [get_bd_intf_pins $inst_name/$inst_bus -quiet]
		if {$inst_if == ""} {
			puts "error: $inst_name/$inst_bus not found"
			return
		}

		set vlnv [get_property VLNV $inst_if]
		set mode [get_property MODE $inst_if]
		puts $vlnv
		puts $mode

		# create corresponding interface
		set fpga_if [create_bd_intf_port -mode $mode -vlnv $vlnv $fpga_pins]
		# connect IP interface port to fpga interface
		connect_bd_intf_net $inst_if $fpga_if

	} else {
		puts "c'est un signal"
		puts [list_property $inst_if]
		puts [get_property TYPE $inst_if]
		puts [get_property NAME $inst_if]
		set high_bit [get_property LEFT $inst_if]
		set low_bit [get_property RIGHT $inst_if]
		set dir [get_property DIR $inst_if]
		puts $high_bit
		puts $low_bit
		puts $dir
		# create corresponding port
		if {$high_bit == ""} {
			set fpga_if [create_bd_port -dir $dir $fpga_pins]
		} else {
			set fpga_if [create_bd_port -dir $dir -from $high_bit -to $low_bit $fpga_pins]
		}
		# connect IP port to fpga port
		connect_bd_net $inst_if $fpga_if
	}
}

proc __create_ps7_axi {} {
	set ps7_axi [add_ip_and_conf axi_interconnect ps7_axi {
		NUM_MI 1}]
	connect_bd_intf_net \
		[get_bd_intf_pins ps7/M_AXI_GP0] [get_bd_intf_pins $ps7_axi/S00_AXI]

	connect_bd_net [get_bd_pins ps7_rst/interconnect_aresetn] [get_bd_pins $ps7_axi/ARESETN]
	connect_bd_net [get_bd_pins ps7/FCLK_CLK0] [get_bd_pins $ps7_axi/ACLK]

	connect_bd_net [get_bd_pins ps7_rst/peripheral_aresetn] [get_bd_pins $ps7_axi/S00_ARESETN]
	connect_bd_net [get_bd_pins ps7/FCLK_CLK0] [get_bd_pins $ps7_axi/S00_ACLK]
	return $ps7_axi
}

proc connect_proc {inst_name axi_bus {base_addr ""}} {
	set axi_clock ""
	set axi_rst ""
	set listIF [get_bd_pins -of_objects [get_bd_cells $inst_name]]
	foreach {intf} $listIF {
		set intf_pins [get_bd_pins $intf]
		set intf_type [get_property TYPE $intf_pins]
		set intf_name [get_property NAME $intf_pins]
		if {$intf_type == "clk"} {
			set assoc_bus [get_property CONFIG.ASSOCIATED_BUSIF $intf_pins]
			if {$assoc_bus == $axi_bus} {
				set axi_clock $intf_name
				set axi_rst [get_property CONFIG.ASSOCIATED_RESET $intf_pins]
			}
		}
	}
	if {$axi_clock == ""} {
		puts "associated clock not found for interface : $inst_name/$axi_bus"
		exit
	}

	if {$base_addr == ""} {
		apply_bd_automation -rule xilinx.com:bd_rule:axi4 \
			-config {Master "/ps7/M_AXI_GP0" Clk "Auto" } \
			[get_bd_intf_pins $inst_name/$axi_bus]
	} else {
		set base_name [join [lrange [split $inst_name "/"] 0 end] "_"]
		set addr [expr {$base_addr + 0x43C00000}]

		set ps7_axi [get_bd_cells ps7_axi -quiet]
		if {$ps7_axi == ""} {
			set ps7_axi [__create_ps7_axi]
			set num_mi 0
		} else {
			set num_mi [get_property CONFIG.NUM_MI  $ps7_axi]
			set new_num_mi [expr {$num_mi + 1}]
			puts $num_mi
			puts $new_num_mi
			set_property -dict [list CONFIG.NUM_MI $new_num_mi] $ps7_axi
		}

		if {$num_mi < 10} {
			set mst_if "M0${num_mi}"
		} else {
			set mst_if "M${num_mi}"
		}
		
		set axi_mst "${mst_if}_AXI"

		connect_bd_net \
			[get_bd_pins ps7_rst/peripheral_aresetn] \
			[get_bd_pins ps7_axi/${mst_if}_ARESETN]
		connect_bd_net \
			[get_bd_pins ps7/FCLK_CLK0] \
			[get_bd_pins ps7_axi/${mst_if}_ACLK]

		save_bd_design

		connect_bd_net \
			[get_bd_pins ps7_rst/peripheral_reset] \
			[get_bd_pins $inst_name/${axi_rst}]
		save_bd_design
		connect_bd_net \
			[get_bd_pins ps7/FCLK_CLK0] \
			[get_bd_pins $inst_name/$axi_clock]

		connect_bd_intf_net [get_bd_intf_pins ps7_axi/$axi_mst] \
			[get_bd_intf_pins $inst_name/$axi_bus]

		create_bd_addr_seg -verbose -range 0x0001000 -offset $addr \
			[get_bd_addr_spaces ps7/Data] \
			[get_bd_addr_segs $inst_name/$axi_bus/reg0] \
			"SEG_${base_name}_${axi_bus}"

	}

}

proc connect_proc_clk {inst_name clk_if} {
	connect_intf ps7 FCLK_CLK0 $inst_name $clk_if
}

proc connect_proc_rst {inst_name rst_if {polarity "ACTIVE_HIGH"}} {
	if {$polarity == "ACTIVE_HIGH"} {
		connect_intf ps7_rst peripheral_reset $inst_name $rst_if
	} else {
		connect_intf ps7_rst peripheral_aresetn $inst_name $rst_if
	}
}

