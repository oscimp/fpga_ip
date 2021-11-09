# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "DATA_SIZE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "INT_REAL_PART_OUT_VALUE" -parent ${Page_0}


}

proc update_PARAM_VALUE.DATA_SIZE { PARAM_VALUE.DATA_SIZE } {
	# Procedure called to update DATA_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA_SIZE { PARAM_VALUE.DATA_SIZE } {
	# Procedure called to validate DATA_SIZE
	return true
}

proc update_PARAM_VALUE.INT_REAL_PART_OUT_VALUE { PARAM_VALUE.INT_REAL_PART_OUT_VALUE } {
	# Procedure called to update INT_REAL_PART_OUT_VALUE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.INT_REAL_PART_OUT_VALUE { PARAM_VALUE.INT_REAL_PART_OUT_VALUE } {
	# Procedure called to validate INT_REAL_PART_OUT_VALUE
	return true
}


proc update_MODELPARAM_VALUE.DATA_SIZE { MODELPARAM_VALUE.DATA_SIZE PARAM_VALUE.DATA_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_SIZE}] ${MODELPARAM_VALUE.DATA_SIZE}
}

proc update_MODELPARAM_VALUE.INT_REAL_PART_OUT_VALUE { MODELPARAM_VALUE.INT_REAL_PART_OUT_VALUE PARAM_VALUE.INT_REAL_PART_OUT_VALUE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.INT_REAL_PART_OUT_VALUE}] ${MODELPARAM_VALUE.INT_REAL_PART_OUT_VALUE}
}

