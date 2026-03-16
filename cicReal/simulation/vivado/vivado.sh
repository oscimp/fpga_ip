#xvhdl $FILES
xelab top_enable_tb -prj firReal.prj -debug typical -s top_sim
#xsim top_sim -gui
#-t xsim_script.tcl
xsim -g -wdb top_sim.wdb top_sim

## juste pour compiler dans une fenetre tcl
#xsim {top_sim} -wdb {top_sim.wdb} -autoloadwcfg
