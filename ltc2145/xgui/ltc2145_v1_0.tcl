# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "Component_Name" -parent ${Page_0}
  ipgui::add_param $IPINST -name "CLOCK_DUTY_CYCLE_STABILIZER_EN" -parent ${Page_0}


}

proc update_PARAM_VALUE.CLOCK_DUTY_CYCLE_STABILIZER_EN { PARAM_VALUE.CLOCK_DUTY_CYCLE_STABILIZER_EN } {
	# Procedure called to update CLOCK_DUTY_CYCLE_STABILIZER_EN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CLOCK_DUTY_CYCLE_STABILIZER_EN { PARAM_VALUE.CLOCK_DUTY_CYCLE_STABILIZER_EN } {
	# Procedure called to validate CLOCK_DUTY_CYCLE_STABILIZER_EN
	return true
}


proc update_MODELPARAM_VALUE.CLOCK_DUTY_CYCLE_STABILIZER_EN { MODELPARAM_VALUE.CLOCK_DUTY_CYCLE_STABILIZER_EN PARAM_VALUE.CLOCK_DUTY_CYCLE_STABILIZER_EN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CLOCK_DUTY_CYCLE_STABILIZER_EN}] ${MODELPARAM_VALUE.CLOCK_DUTY_CYCLE_STABILIZER_EN}
}

