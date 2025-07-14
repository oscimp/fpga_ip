# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  set COUNTER_SIZE [ipgui::add_param $IPINST -name "COUNTER_SIZE" -parent ${Page_0}]
  set_property tooltip {up to 2^counter_size} ${COUNTER_SIZE}
  ipgui::add_param $IPINST -name "DATA_SIZE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "USE_EOF" -parent ${Page_0}


}

proc update_PARAM_VALUE.COUNTER_SIZE { PARAM_VALUE.COUNTER_SIZE } {
	# Procedure called to update COUNTER_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.COUNTER_SIZE { PARAM_VALUE.COUNTER_SIZE } {
	# Procedure called to validate COUNTER_SIZE
	return true
}

proc update_PARAM_VALUE.DATA_SIZE { PARAM_VALUE.DATA_SIZE } {
	# Procedure called to update DATA_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA_SIZE { PARAM_VALUE.DATA_SIZE } {
	# Procedure called to validate DATA_SIZE
	return true
}

proc update_PARAM_VALUE.USE_EOF { PARAM_VALUE.USE_EOF } {
	# Procedure called to update USE_EOF when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.USE_EOF { PARAM_VALUE.USE_EOF } {
	# Procedure called to validate USE_EOF
	return true
}


proc update_MODELPARAM_VALUE.DATA_SIZE { MODELPARAM_VALUE.DATA_SIZE PARAM_VALUE.DATA_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_SIZE}] ${MODELPARAM_VALUE.DATA_SIZE}
}

proc update_MODELPARAM_VALUE.COUNTER_SIZE { MODELPARAM_VALUE.COUNTER_SIZE PARAM_VALUE.COUNTER_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.COUNTER_SIZE}] ${MODELPARAM_VALUE.COUNTER_SIZE}
}

proc update_MODELPARAM_VALUE.USE_EOF { MODELPARAM_VALUE.USE_EOF PARAM_VALUE.USE_EOF } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.USE_EOF}] ${MODELPARAM_VALUE.USE_EOF}
}

