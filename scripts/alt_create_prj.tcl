set prj_name [lindex $argv 0]
set top_name [lindex $argv 1]
set use_qsys [lindex $argv 2]
set family   [lindex $argv 3]
set part     [lindex $argv 4]
set start_index 5

cd ./tmp

package require ::quartus::project
package require ::quartus::flow

project_new -family $family -part $part -overwrite $prj_name

# configure platform params
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY ./
set_global_assignment -name PARTITION_NETLIST_TYPE SOURCE -section_id Top
set_global_assignment -name PARTITION_FITTER_PRESERVATION_LEVEL PLACEMENT_AND_ROUTING -section_id Top
set_global_assignment -name PARTITION_COLOR 16764057 -section_id Top

set_global_assignment -name TOP_LEVEL_ENTITY $top_name

# add files to project
for {set i $start_index} {$i < $argc} {incr i} {
	set hdl [lindex $argv $i]
	set ext [file extension $hdl]
	switch -nocase -- $ext {
		".vhd"  { set_global_assignment -name VHDL_FILE $hdl    }
		".v"    { set_global_assignment -name VERILOG_FILE $hdl }
		".tcl"  { source $hdl                                   }
		".sdc"  { set_global_assignment -name SDC_FILE $hdl     } 
		".qsys" { set_global_assignment -name QSYS_FILE $hdl    }
		".qip"  { set_global_assignment -name QIP_FILE $hdl     }
		default { puts "unknown file type : $hdl $ext"          }
	}
}

if {$use_qsys == y} {
	set QSYS_SCRIPT [glob -join $quartus(quartus_rootpath) sopc_builder bin qsys-script]
	set QSYS_GEN    [glob -join $quartus(quartus_rootpath) sopc_builder bin qsys-generate]

	exec -ignorestderr $QSYS_SCRIPT --script=qsys_loader.tcl
	exec -ignorestderr $QSYS_GEN ${prj_name}_qsys.qsys --synthesis=VHDL --family=$family --part=$part
}

export_assignments
project_close

