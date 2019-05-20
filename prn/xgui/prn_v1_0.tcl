# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  set PERIOD_LEN [ipgui::add_param $IPINST -name "PERIOD_LEN" -parent ${Page_0}]
  set_property tooltip {Period Length of bit.} ${PERIOD_LEN}


}

proc update_PARAM_VALUE.PERIOD_LEN { PARAM_VALUE.PERIOD_LEN } {
	# Procedure called to update PERIOD_LEN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PERIOD_LEN { PARAM_VALUE.PERIOD_LEN } {
	# Procedure called to validate PERIOD_LEN
	return true
}


proc update_MODELPARAM_VALUE.PERIOD_LEN { MODELPARAM_VALUE.PERIOD_LEN PARAM_VALUE.PERIOD_LEN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PERIOD_LEN}] ${MODELPARAM_VALUE.PERIOD_LEN}
}

