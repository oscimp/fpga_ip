# source common function
variable oscimp_digital_ip    $::env(OSCIMP_DIGITAL_IP)
source $oscimp_digital_ip/scripts/xil_prj.tcl

set project_name [lindex $argv 0]
set top_name     [lindex $argv 1]
set board_name   [lindex $argv 2]
set part_name    [lindex $argv 3]
set prj_preset   [lindex $argv 4]
set bd_preset    [lindex $argv 5]
set ip_repo_path [lindex $argv 6]
set use_bd       [lindex $argv 7]
set start_index 8

set build_path tmp
set bd_path $build_path/$project_name.srcs/sources_1/bd/$project_name
#set repo_path $fpga_ip

puts $project_name
puts $top_name
puts $board_name
puts $part_name
puts $prj_preset
puts $bd_preset
puts $ip_repo_path
puts $use_bd

# prepare IP path
set list_ip_repo_path [split $ip_repo_path ,]
puts $list_ip_repo_path
for {set i 0} {$i < [llength $list_ip_repo_path]} {incr i} {
	puts [lindex $list_ip_repo_path $i]
}

file delete -force $build_path

# Project creation
create_project $project_name $build_path -part $part_name
if {$prj_preset != ""} {
	set_property BOARD_PART $prj_preset [current_project]
}

# Set Path for the custom IP cores
#set_property IP_REPO_PATHS [list ${repo_path} ${osc_fpga_ip} ${oscimp_digital_ip}] [current_project]
set_property IP_REPO_PATHS ${list_ip_repo_path} [current_project]
update_ip_catalog

set hdl_list []
set constr_list []
set tcl_list []

puts "hello"

# add files to project
for {set i $start_index} {$i < $argc} {incr i} {
	set hdl [lindex $argv $i]
	set ext [file extension $hdl]
	switch -nocase -- $ext {
		".vhd"  { add_files -norecurse $hdl    }
		".v"    { add_files -norecurse $hdl    }
		".tcl"  { 
			puts "tcl : $hdl"
			lappend tcl_list $hdl     }
		".xdc"  { 
			puts "xdc : $hdl"
			add_files -norecurse -fileset constrs_1 $hdl  }
		default { puts "unknown file type : $hdl $ext"          }
	}
}

if {$use_bd == y} {
	# block design creation
	create_bd_design $project_name

	# Create instance: processing_system7_0, and set properties
	startgroup
	set ps7 [ create_bd_cell -type ip \
		-vlnv xilinx.com:ip:processing_system7:5.5 ps7 ]

	## GGM: TODO
	# if prj_preset is none we can consider board not present in vivado
	# so we suppose bd_preset is an xml file
	if {$prj_preset == ""} {
		set_property -dict [list CONFIG.PCW_IMPORT_BOARD_PRESET $bd_preset] $ps7
	} else {
		# when prj_preset is not none we use preset
		set_property -dict [list CONFIG.preset $bd_preset ] $ps7
	}
	endgroup

	# create reset inst
	set ps7_rst [create_bd_cell -type ip \
	    -vlnv xilinx.com:ip:proc_sys_reset:5.0 ps7_rst]
	## clock (explicit since no AXI bus is used)
	connect_bd_net -net ps7_FCLK_CLK0 \
		[get_bd_pins $ps7/M_AXI_GP0_ACLK] \
		[get_bd_pins $ps7_rst/slowest_sync_clk] \
		[get_bd_pins $ps7/FCLK_CLK0]
	## reset CPU -> processing_rst
	connect_bd_net -net ps7_FCLK_RESET0_N \
		[get_bd_pins $ps7/FCLK_RESET0_N] \
		[get_bd_pins $ps7_rst/ext_reset_in]
	


	#==========================
	# autoconnect and AXI     =
	#==========================

	apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 \
		-config {make_external "FIXED_IO, DDR" Master "Disable" Slave "Disable" } \
		$ps7
	
}

for {set i 0} {$i < [llength $tcl_list]} {incr i} {
	puts [lindex $tcl_list $i]
	source [lindex $tcl_list $i]
}

if {$use_bd == y} {
	generate_target all [get_files  $bd_path/$project_name.bd]
	make_wrapper -files [get_files $bd_path/$project_name.bd] -top

	set project_name_wrapper $project_name
	append project_name_wrapper _wrapper
	add_files -norecurse $bd_path/hdl/$project_name_wrapper.v
	#lappend hdl_list $bd_path/hdl/$project_name_wrapper.v
}

# Load any additional Verilog files in the project folder
set files [glob -nocomplain projects/$project_name/*.v projects/$project_name/*.sv]
if {[llength $files] > 0} {
	add_files -norecurse $files
}

#add_files -norecurse -fileset constrs_1 ../../leds.xdc
#add_files -norecurse $hdl_list
#add_files -norecurse -fileset constrs_1 $constr_list

set_property VERILOG_DEFINE {TOOL_VIVADO} [current_fileset]




