# display a message colored in red, delete project and call exit
proc print_error_and_exit {error_message} {
  puts "\033\[1;31mError: ${error_message}\033\[0m"
  exit 1
}


proc add_ip_and_conf {ip_name inst_name {conf_list {}} } {
  # UPGRADE_VERSIONS == "" => latest IP version
  set vlnv_ip [get_ipdefs -all \
  	-filter "VLNV =~ *:$ip_name:* && design_tool_contexts =~ *IPI* && UPGRADE_VERSIONS == \"\""]

  if {$vlnv_ip == ""} {
	  print_error_and_exit "no IP with name ${ip_name}"
	  exit
  }

  set ip_inst [ create_bd_cell -type ip -vlnv $vlnv_ip $inst_name ]
  set prop_list {}
  set ip_cnf_list [list_property $ip_inst CONFIG.*]
  foreach {cnf_name cnf_value} [uplevel 1 [list subst $conf_list]] {
    set full_cnf_name CONFIG.$cnf_name
    if {[lsearch -exact $ip_cnf_list $full_cnf_name] == -1} {
	  print_error_and_exit "IP ${ip_name} has no parameter $cnf_name"
    }
    lappend prop_list $full_cnf_name $cnf_value
  }
  if {[llength $prop_list] > 1} {
	  set_property -dict $prop_list $ip_inst
  }
  return $ip_inst
}

proc connect_intf {src_name src_if dest_name dest_if} {
  set src_is_intf 1
  set dest_is_intf 1

  # check if src and dest instance exists
  set src_inst [get_bd_cells $src_name -quiet]
  if {$src_inst == ""} {
	  print_error_and_exit "no instance with name ${src_name}"
  }
  set dest_inst [get_bd_cells $dest_name -quiet]
  if {$dest_inst == ""} {
	  print_error_and_exit "no instance with name ${dest_name}"
  }

  # search if src is an interface or simple signal
  set src_inst_if [get_bd_intf_pins $src_name/$src_if -quiet]
  if {$src_inst_if == ""} {
	set src_is_intf 0
    set src_inst_if [get_bd_pins $src_name/$src_if -quiet]
	if {$src_inst_if == ""} {
      print_error_and_exit "instance $src_name has no signal or interface called $src_if"
	}
    set src_intf_mode [get_property DIR $src_inst_if]
  } else {
    set src_intf_mode [get_property MODE $src_inst_if]
  }
  # search if dest is an interface or simple signal
  set dest_inst_if [get_bd_intf_pins $dest_name/$dest_if -quiet]
  if {$dest_inst_if == ""} {
	set dest_is_intf 0
    set dest_inst_if [get_bd_pins $dest_name/$dest_if -quiet]
	if {$dest_inst_if == ""} {
      print_error_and_exit "instance $dest_name has no signal or interface called $dest_if"
	}
    set dest_intf_mode [get_property DIR $dest_inst_if]
  } else {
    set dest_intf_mode [get_property MODE $dest_inst_if]
  }

  if {$src_is_intf != $dest_is_intf} {
    print_error_and_exit "Can't connect $src_name/$src_if to $dest_name/$dest_if: not same type"
  }

  if {$src_intf_mode == $dest_intf_mode} {
    print_error_and_exit "Can't connect $src_name/$src_if to $dest_name/$dest_if: same direction"
  }

  if {$src_is_intf == 1} {
    set src_intf_vlnv [get_property VLNV $src_inst_if]
    set dest_intf_vlnv [get_property VLNV $dest_inst_if]
	puts "$src_intf_vlnv != $dest_intf_vlnv"
	if {$src_intf_vlnv != $dest_intf_vlnv} {
      print_error_and_exit "Can't connect $src_name/$src_if to $dest_name/$src_if: not same type"
    }

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

		# create corresponding interface
		set fpga_if [create_bd_intf_port -mode $mode -vlnv $vlnv $fpga_pins]
		# connect IP interface port to fpga interface
		connect_bd_intf_net $inst_if $fpga_if

	} else {
		set high_bit [get_property LEFT $inst_if]
		set low_bit [get_property RIGHT $inst_if]
		set dir [get_property DIR $inst_if]
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

proc __create_ps7_axi {{ps7_axi_name "ps7_axi"}} {
	set ps7_axi [add_ip_and_conf axi_interconnect $ps7_axi_name {
		NUM_MI 1}]

	if {$ps7_axi_name == "ps7_axi"} {
		set M_AXI_GP "M_AXI_GP0"
	} else {
		set M_AXI_GP "M_AXI_GP1"
		set_property CONFIG.PCW_USE_M_AXI_GP1 {1} [get_bd_cells ps7]
		connect_bd_net -net ps7_FCLK_CLK0 [get_bd_pins ps7/M_AXI_GP1_ACLK]
	}

	connect_bd_intf_net \
		[get_bd_intf_pins ps7/$M_AXI_GP] [get_bd_intf_pins $ps7_axi/S00_AXI]

	connect_bd_net [get_bd_pins ps7_rst/interconnect_aresetn] [get_bd_pins $ps7_axi/ARESETN]
	connect_bd_net [get_bd_pins ps7/FCLK_CLK0] [get_bd_pins $ps7_axi/ACLK]

	connect_bd_net [get_bd_pins ps7_rst/peripheral_aresetn] [get_bd_pins $ps7_axi/S00_ARESETN]
	connect_bd_net [get_bd_pins ps7/FCLK_CLK0] [get_bd_pins $ps7_axi/S00_ACLK]
	return $ps7_axi
}

proc connect_proc {inst_name axi_bus {base_addr ""}} {
	set max_num_slaves 64
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

		if {[get_property CONFIG.PCW_USE_M_AXI_GP1 [get_bd_cells ps7]] == 1} {
			apply_bd_automation -rule xilinx.com:bd_rule:axi4 \
				-config {Master "/ps7/M_AXI_GP1" Clk "Auto" } \
				[get_bd_intf_pins $inst_name/$axi_bus]
		}
	} else {
		set base_name [join [lrange [split $inst_name "/"] 0 end] "_"]
		set addr [expr {$base_addr + 0x43C00000}]

		set ps7_axi [get_bd_cells ps7_axi -quiet]
		if {$ps7_axi == ""} {
			set ps7_axi [__create_ps7_axi]
			set num_mi 0
		} else {
			set num_mi [get_property CONFIG.NUM_MI $ps7_axi]
			if {$num_mi < $max_num_slaves} {
				set new_num_mi [expr {$num_mi + 1}]
				set_property -dict [list CONFIG.NUM_MI $new_num_mi] $ps7_axi
			}
		}

		# If max num of slaves (64) of ps7_axi interconnect is reached, use ps7_1_axi
		if {$num_mi == $max_num_slaves} {
			set addr [expr {$base_addr + 0x83C00000}]
			set ps7_axi [get_bd_cells ps7_1_axi -quiet]
			if {$ps7_axi == ""} {
				set ps7_axi [__create_ps7_axi ps7_1_axi]
				set num_mi 0
			} else {
				set num_mi [get_property CONFIG.NUM_MI  $ps7_axi]
				set new_num_mi [expr {$num_mi + 1}]
				set_property -dict [list CONFIG.NUM_MI $new_num_mi] $ps7_axi
			}
		}

		if {$num_mi < 10} {
			set mst_if "M0${num_mi}"
		} else {
			set mst_if "M${num_mi}"
		}

		set axi_mst "${mst_if}_AXI"

		connect_bd_net \
			[get_bd_pins ps7_rst/peripheral_aresetn] \
			[get_bd_pins $ps7_axi/${mst_if}_ARESETN]
		connect_bd_net \
			[get_bd_pins ps7/FCLK_CLK0] \
			[get_bd_pins $ps7_axi/${mst_if}_ACLK]

        if {$axi_rst != ""} {
          connect_bd_net \
            [get_bd_pins ps7_rst/peripheral_reset] \
            [get_bd_pins $inst_name/${axi_rst}]
        }

        if {$axi_clock != ""} {
          connect_proc_clk $inst_name $axi_clock
        }

		connect_bd_intf_net [get_bd_intf_pins $ps7_axi/$axi_mst] \
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

