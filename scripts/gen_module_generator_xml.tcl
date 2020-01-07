set project_name [lindex $argv 0]

open_project tmp/$project_name.xpr
open_bd_design tmp/$project_name.srcs/sources_1/bd/$project_name/$project_name.bd

set list_addr [get_bd_addr_spaces]
set list_seg [lsearch -all -inline [get_bd_addr_segs] "*SEG*"]

set max [llength $list_addr]
set my_list []
set list_ip {}

for {set i 0} {$i < $max} {incr i} {
	set obj [lindex $list_addr $i]
	set base_name [join [lrange [split $obj "/"] 1 end-1] "/"]
	if {([get_property VLNV -object [get_bd_cells "/$base_name"]] ne "xilinx.com:ip:processing_system7:5.5")} {
		set itf_type [get_property VLNV -object [get_bd_intf_pins $obj]]
		set itf_mode [get_property MODE -object [get_bd_intf_pins $obj]]
		if {$itf_type == "xilinx.com:interface:aximm_rtl:1.0"} {
			if {$itf_mode == "Slave"} {
				lappend my_list "$base_name"
				lappend list_ip [get_property VLNV -object [get_bd_cells "/$base_name"]]
			}
		}
	}
}

set uniqueList [lsort -unique $list_ip]
set max_ip [llength $uniqueList]
set max_inst [llength $my_list]
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
		set base_name [lindex $my_list $ii]
		set inst_type [get_property VLNV -object [get_bd_cells $base_name]]
		if {$ip_type == $inst_type} {
			set inst_name [lindex [split $base_name "/"] end]
			set seg_name [lsearch -inline $list_seg "*${inst_name}*"]
			set base_addr [get_property OFFSET [get_bd_addr_segs $seg_name ]]
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
