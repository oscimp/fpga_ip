# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  set DATA_IN_SIZE [ipgui::add_param $IPINST -name "DATA_IN_SIZE" -parent ${Page_0}]
  set_property tooltip {Size of input data bus.} ${DATA_IN_SIZE}
  set DATA_OUT_SIZE [ipgui::add_param $IPINST -name "DATA_OUT_SIZE" -parent ${Page_0}]
  set_property tooltip {Size of output data bus.} ${DATA_OUT_SIZE}
  set format [ipgui::add_param $IPINST -name "format" -parent ${Page_0}]
  set_property tooltip {Data Format (signed/unsigned.} ${format}


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

proc update_PARAM_VALUE.format { PARAM_VALUE.format } {
	# Procedure called to update format when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.format { PARAM_VALUE.format } {
	# Procedure called to validate format
	return true
}


proc update_MODELPARAM_VALUE.format { MODELPARAM_VALUE.format PARAM_VALUE.format } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.format}] ${MODELPARAM_VALUE.format}
}

proc update_MODELPARAM_VALUE.DATA_IN_SIZE { MODELPARAM_VALUE.DATA_IN_SIZE PARAM_VALUE.DATA_IN_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_IN_SIZE}] ${MODELPARAM_VALUE.DATA_IN_SIZE}
}

proc update_MODELPARAM_VALUE.DATA_OUT_SIZE { MODELPARAM_VALUE.DATA_OUT_SIZE PARAM_VALUE.DATA_OUT_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_OUT_SIZE}] ${MODELPARAM_VALUE.DATA_OUT_SIZE}
}

