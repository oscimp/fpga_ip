set prj_name [lindex $argv 0]
set use_qsys [lindex $argv 1]
set family   [lindex $argv 2]
set part     [lindex $argv 3]

cd ./tmp
package require ::quartus::project
package require ::quartus::flow

project_open $prj_name

if {[string equal -nocase $use_qsys "y"]} {
	set QSYS_GEN [glob -join $quartus(quartus_rootpath) sopc_builder bin qsys-generate]
	exec -ignorestderr $QSYS_GEN ${prj_name}_qsys.qsys --synthesis=VHDL --family=$family --part=$part
}

execute_flow -compile
project_close
