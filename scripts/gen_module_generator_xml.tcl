set vivado_prj_root_path [lindex $argv 0]
set project_name [lindex $argv 1]

if {$argc == 2} {
	set bd_name $project_name
} else {
	set bd_name [lindex $argv 2]
}

open_project $vivado_prj_root_path/$project_name.xpr
open_bd_design $vivado_prj_root_path/$project_name.srcs/sources_1/bd/$bd_name/$bd_name.bd

set list_cells [get_bd_cells]
set max [llength $list_cells]

set list_axi_cells []
set list_ip {}

for {set i 0} {$i < $max} {incr i} {
	set cell [lindex $list_cells $i]
	set vlnv [get_property VLNV $cell]
	set name [get_property NAME $cell]
	if {[regexp {xilinx.com:ip:axi_interconnect:[0-9]*.[0-9]*} $vlnv] |
		[regexp {xilinx.com:ip:proc_sys_reset:[0-9]*.[0-9]*} $vlnv] |
		[regexp {xilinx.com:ip:processing_system7:[0-9]*.[0-9]*} $vlnv]} {
		continue
	}
	set list_net [get_bd_intf_pins -of [get_bd_cells $cell]]
	for {set ii 0} {$ii < [llength $list_net]} {incr ii} {
		set name_net [lindex $list_net $ii]
		set vlnv_net [get_property VLNV $name_net]
		set mode_net [get_property MODE $name_net]
		if {[regexp {xilinx.com:interface:aximm_rtl:[0-9]*.[0-9]*} $vlnv_net] &
			$mode_net == "Slave"} {
			set reg_name [get_bd_addr_segs -of_object $cell]
			set seg_name [get_bd_addr_segs -of_object $reg_name]
			set offset [get_property OFFSET $seg_name]
			lappend list_axi_cells [dict create name $name vlnv $vlnv offset $offset]
			lappend list_ip $vlnv
		}
	}
}

set uniqueList [lsort -unique $list_ip]
set max_ip [llength $uniqueList]
set max_inst [llength $list_axi_cells]
if {$max_inst == 0} {
	exit
}

set filename "../$project_name.xml"
set fd [open $filename "w"]

puts $fd "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
puts $fd "<project name=\"$project_name\" version=\"1.0\">"
puts $fd "\t<ips>"
for {set i 0} {$i < $max_ip} {incr i} {
	set ip_type [lindex $uniqueList $i]
	set ip_name [lindex [split $ip_type ":"] 2]
	puts $fd "\t\t<ip name =\"$ip_name\" >"
	set id 0
	for {set ii 0} {$ii < $max_inst} {incr ii} {
		set tmp [lindex $list_axi_cells $ii]
		set inst_type [dict get $tmp vlnv]
		if {$ip_type == $inst_type} {
			set inst_name [dict get $tmp name]
			set base_addr [dict get $tmp offset]
			puts $fd "\t\t\t<instance name=\"$inst_name\" id=\"$id\""
			puts $fd "\t\t\t\tbase_addr=\"$base_addr\" addr_size=\"0xffff\" />"
			incr id
		}
	}
	puts $fd "\t\t</ip>"
}
puts $fd "\t</ips>"
puts $fd "</project>"

close $fd
