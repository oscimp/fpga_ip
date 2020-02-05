# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  set BIT_LEN [ipgui::add_param $IPINST -name "BIT_LEN" -parent ${Page_0}]
  set_property tooltip {PRN vector len.} ${BIT_LEN}
  set PERIOD_LEN [ipgui::add_param $IPINST -name "PERIOD_LEN" -parent ${Page_0}]
  set_property tooltip {Period Length of bit.} ${PERIOD_LEN}
  set PRN_NUM [ipgui::add_param $IPINST -name "PRN_NUM" -parent ${Page_0}]
  set_property tooltip {PRN num.} ${PRN_NUM}


}

proc update_PARAM_VALUE.BIT_LEN { PARAM_VALUE.BIT_LEN } {
	# Procedure called to update BIT_LEN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BIT_LEN { PARAM_VALUE.BIT_LEN } {
	# Procedure called to validate BIT_LEN
	return true
}

proc update_PARAM_VALUE.PERIOD_LEN { PARAM_VALUE.PERIOD_LEN } {
	# Procedure called to update PERIOD_LEN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PERIOD_LEN { PARAM_VALUE.PERIOD_LEN } {
	# Procedure called to validate PERIOD_LEN
	return true
}

proc update_PARAM_VALUE.PRN_NUM { PARAM_VALUE.PRN_NUM } {
	# Procedure called to update PRN_NUM when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PRN_NUM { PARAM_VALUE.PRN_NUM } {
	# Procedure called to validate PRN_NUM
	return true
}


proc update_MODELPARAM_VALUE.BIT_LEN { MODELPARAM_VALUE.BIT_LEN PARAM_VALUE.BIT_LEN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BIT_LEN}] ${MODELPARAM_VALUE.BIT_LEN}
}

proc update_MODELPARAM_VALUE.PRN_NUM { MODELPARAM_VALUE.PRN_NUM PARAM_VALUE.PRN_NUM } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PRN_NUM}] ${MODELPARAM_VALUE.PRN_NUM}
}

proc update_MODELPARAM_VALUE.PERIOD_LEN { MODELPARAM_VALUE.PERIOD_LEN PARAM_VALUE.PERIOD_LEN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PERIOD_LEN}] ${MODELPARAM_VALUE.PERIOD_LEN}
}

