# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "DATA_SIZE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "SIGN_CORRECTION" -parent ${Page_0}


}

proc update_PARAM_VALUE.DATA_SIZE { PARAM_VALUE.DATA_SIZE } {
	# Procedure called to update DATA_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA_SIZE { PARAM_VALUE.DATA_SIZE } {
	# Procedure called to validate DATA_SIZE
	return true
}

proc update_PARAM_VALUE.SIGN_CORRECTION { PARAM_VALUE.SIGN_CORRECTION } {
	# Procedure called to update SIGN_CORRECTION when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SIGN_CORRECTION { PARAM_VALUE.SIGN_CORRECTION } {
	# Procedure called to validate SIGN_CORRECTION
	return true
}


proc update_MODELPARAM_VALUE.DATA_SIZE { MODELPARAM_VALUE.DATA_SIZE PARAM_VALUE.DATA_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_SIZE}] ${MODELPARAM_VALUE.DATA_SIZE}
}

proc update_MODELPARAM_VALUE.SIGN_CORRECTION { MODELPARAM_VALUE.SIGN_CORRECTION PARAM_VALUE.SIGN_CORRECTION } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SIGN_CORRECTION}] ${MODELPARAM_VALUE.SIGN_CORRECTION}
}

