# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "DATA_OUT_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "ESTIMATION_METHOD" -parent ${Page_0}
  ipgui::add_param $IPINST -name "FILTER_COEFF_TWOS_POWER" -parent ${Page_0}

  ipgui::add_param $IPINST -name "PI_VALUE"

}

proc update_PARAM_VALUE.DATA_OUT_WIDTH { PARAM_VALUE.DATA_OUT_WIDTH } {
	# Procedure called to update DATA_OUT_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA_OUT_WIDTH { PARAM_VALUE.DATA_OUT_WIDTH } {
	# Procedure called to validate DATA_OUT_WIDTH
	return true
}

proc update_PARAM_VALUE.DATA_WIDTH { PARAM_VALUE.DATA_WIDTH } {
	# Procedure called to update DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA_WIDTH { PARAM_VALUE.DATA_WIDTH } {
	# Procedure called to validate DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.ESTIMATION_METHOD { PARAM_VALUE.ESTIMATION_METHOD } {
	# Procedure called to update ESTIMATION_METHOD when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ESTIMATION_METHOD { PARAM_VALUE.ESTIMATION_METHOD } {
	# Procedure called to validate ESTIMATION_METHOD
	return true
}

proc update_PARAM_VALUE.FILTER_COEFF_TWOS_POWER { PARAM_VALUE.FILTER_COEFF_TWOS_POWER } {
	# Procedure called to update FILTER_COEFF_TWOS_POWER when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FILTER_COEFF_TWOS_POWER { PARAM_VALUE.FILTER_COEFF_TWOS_POWER } {
	# Procedure called to validate FILTER_COEFF_TWOS_POWER
	return true
}

proc update_PARAM_VALUE.PI_VALUE { PARAM_VALUE.PI_VALUE } {
	# Procedure called to update PI_VALUE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PI_VALUE { PARAM_VALUE.PI_VALUE } {
	# Procedure called to validate PI_VALUE
	return true
}


proc update_MODELPARAM_VALUE.DATA_WIDTH { MODELPARAM_VALUE.DATA_WIDTH PARAM_VALUE.DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_WIDTH}] ${MODELPARAM_VALUE.DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.DATA_OUT_WIDTH { MODELPARAM_VALUE.DATA_OUT_WIDTH PARAM_VALUE.DATA_OUT_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_OUT_WIDTH}] ${MODELPARAM_VALUE.DATA_OUT_WIDTH}
}

proc update_MODELPARAM_VALUE.FILTER_COEFF_TWOS_POWER { MODELPARAM_VALUE.FILTER_COEFF_TWOS_POWER PARAM_VALUE.FILTER_COEFF_TWOS_POWER } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FILTER_COEFF_TWOS_POWER}] ${MODELPARAM_VALUE.FILTER_COEFF_TWOS_POWER}
}

proc update_MODELPARAM_VALUE.ESTIMATION_METHOD { MODELPARAM_VALUE.ESTIMATION_METHOD PARAM_VALUE.ESTIMATION_METHOD } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ESTIMATION_METHOD}] ${MODELPARAM_VALUE.ESTIMATION_METHOD}
}

proc update_MODELPARAM_VALUE.PI_VALUE { MODELPARAM_VALUE.PI_VALUE PARAM_VALUE.PI_VALUE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PI_VALUE}] ${MODELPARAM_VALUE.PI_VALUE}
}

