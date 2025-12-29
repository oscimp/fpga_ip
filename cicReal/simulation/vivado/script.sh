FILES="readComplexFromFile.vhd ../hdl/firReal_ram.vhd"
FILES=$FILES" ../hdl/firReal_ram_coeff.vhd"
FILES=$FILES" ../hdl/firReal_ram.vhd ../hdl/firReal_transfert.vhd"
FILES=$FILES" ../hdl/firReal_coeff_handler.vhd ../hdl/firReal_data_handler.vhd"
FILES=$FILES" ../hdl/firReal_comp_complex.vhd"
FILES=$FILES" ../hdl/firReal_comp_butterfly.vhd ../hdl/firReal_loop_radix.vhd"

FILES=$FILES" ../hdl/firReal_loop_stage.vhd ../hdl/firReal_top_logic.vhd"
FILES=$FILES" top_firReal_tb.vhd"

xvhdl $FILES
xelab top_firReal_tb -debug typical -s top_sim
xsim top_sim -gui
#-t xsim_script.tcl
