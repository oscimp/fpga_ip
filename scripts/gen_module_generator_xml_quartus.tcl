package require qsys

set qsys_name [get_module_property NAME]
# name is always XXXX_qsys with XXXX the project name
# so we split and rebuild name without _qsys
set project_name [join [lrange [split $qsys_name "_"] 0 end-1] "_"]

set lstConn [get_connections hps.h2f_lw_axi_master]
set listInst {}
set listIP {}

foreach connec $lstConn {
	# connection has pattern master.interface/slave.interface
	# so to have slave instance name we must split using '/' and '.'
	set instName [lindex [split [lindex [split $connec "/"] 1] "."] 0]
	set baseAddr [get_connection_parameter_value $connec baseAddress]
	set ipName [get_instance_property $instName CLASS_NAME]

	lappend listInst $instName $ipName $baseAddr
	# inefficient way but since Qsys TCL didn't support lsort -unique
	# no best way ...
	if {[lsearch $listIP $ipName] < 0} {
		lappend listIP $ipName
	}
}

# add _quartus to avoid conflict with vivado xml
set filename "../${project_name}_quartus.xml"
set fd [open $filename "w"]

puts $fd "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
puts $fd "<project name=\"$project_name\" tool=\"quartus\" version=\"1.0\">"
puts $fd "\t<ips>"
foreach ipName $listIP {
	puts $fd "\t\t<ip name =\"$ipName\" >"
	set id 0
	foreach {instName instIPName baseAddr} $listInst {
		if {$ipName == $instIPName} {
			puts $fd "\t\t\t<instance name=\"$instName\" id=\"$id\""
			puts $fd "\t\t\t\tbase_addr=\"$baseAddr\" addr_size=\"0xffff\" />"
			incr id
		}
	}
	puts $fd "\t\t</ip>"
}
puts $fd "\t</ips>"
puts $fd "</project>"
close $fd
