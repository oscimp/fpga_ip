# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "C_S00_AXI_ADDR_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S00_AXI_DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DATA_IN_SIZE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DATA_OUT_SIZE" -parent ${Page_0}


}

proc update_PARAM_VALUE.C_S00_AXI_ADDR_WIDTH { PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to update C_S00_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S00_AXI_ADDR_WIDTH { PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to validate C_S00_AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S00_AXI_DATA_WIDTH { PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to update C_S00_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S00_AXI_DATA_WIDTH { PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to validate C_S00_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.DATA_IN_SIZE { PARAM_VALUE.DATA_IN_SIZE } {
	# Procedure called to update DATA_IN_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA_IN_SIZE { PARAM_VALUE.DATA_IN_SIZE } {
	# Procedure called to validate DATA_IN_SIZE
	return true
}

proc update_PARAM_VALUE.DATA_OUT_SIZE { PARAM_VALUE.DATA_OUT_SIZE } {
	# Procedure called to update DATA_OUT_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA_OUT_SIZE { PARAM_VALUE.DATA_OUT_SIZE } {
	# Procedure called to validate DATA_OUT_SIZE
	return true
}

proc update_PARAM_VALUE.add_val_i { PARAM_VALUE.add_val_i } {
	# Procedure called to update add_val_i when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.add_val_i { PARAM_VALUE.add_val_i } {
	# Procedure called to validate add_val_i
	return true
}

proc update_PARAM_VALUE.add_val_q { PARAM_VALUE.add_val_q } {
	# Procedure called to update add_val_q when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.add_val_q { PARAM_VALUE.add_val_q } {
	# Procedure called to validate add_val_q
	return true
}

proc update_PARAM_VALUE.format { PARAM_VALUE.format } {
	# Procedure called to update format when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.format { PARAM_VALUE.format } {
	# Procedure called to validate format
	return true
}

proc update_PARAM_VALUE.id { PARAM_VALUE.id } {
	# Procedure called to update id when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.id { PARAM_VALUE.id } {
	# Procedure called to validate id
	return true
}


proc update_MODELPARAM_VALUE.id { MODELPARAM_VALUE.id PARAM_VALUE.id } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.id}] ${MODELPARAM_VALUE.id}
}

proc update_MODELPARAM_VALUE.format { MODELPARAM_VALUE.format PARAM_VALUE.format } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.format}] ${MODELPARAM_VALUE.format}
}

proc update_MODELPARAM_VALUE.DATA_OUT_SIZE { MODELPARAM_VALUE.DATA_OUT_SIZE PARAM_VALUE.DATA_OUT_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_OUT_SIZE}] ${MODELPARAM_VALUE.DATA_OUT_SIZE}
}

proc update_MODELPARAM_VALUE.DATA_IN_SIZE { MODELPARAM_VALUE.DATA_IN_SIZE PARAM_VALUE.DATA_IN_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_IN_SIZE}] ${MODELPARAM_VALUE.DATA_IN_SIZE}
}

proc update_MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S00_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S00_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.add_val_i { MODELPARAM_VALUE.add_val_i PARAM_VALUE.add_val_i } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.add_val_i}] ${MODELPARAM_VALUE.add_val_i}
}

proc update_MODELPARAM_VALUE.add_val_q { MODELPARAM_VALUE.add_val_q PARAM_VALUE.add_val_q } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.add_val_q}] ${MODELPARAM_VALUE.add_val_q}
}

