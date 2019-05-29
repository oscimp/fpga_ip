# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  set DATA_SIZE [ipgui::add_param $IPINST -name "DATA_SIZE" -parent ${Page_0}]
  set_property tooltip {Data Size.} ${DATA_SIZE}
  set format [ipgui::add_param $IPINST -name "format" -parent ${Page_0}]
  set_property tooltip {Data format.} ${format}
  set opp [ipgui::add_param $IPINST -name "opp" -parent ${Page_0}]
  set_property tooltip {operation add/sub.} ${opp}


}

proc update_PARAM_VALUE.DATA_SIZE { PARAM_VALUE.DATA_SIZE } {
	# Procedure called to update DATA_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA_SIZE { PARAM_VALUE.DATA_SIZE } {
	# Procedure called to validate DATA_SIZE
	return true
}

proc update_PARAM_VALUE.format { PARAM_VALUE.format } {
	# Procedure called to update format when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.format { PARAM_VALUE.format } {
	# Procedure called to validate format
	return true
}

proc update_PARAM_VALUE.opp { PARAM_VALUE.opp } {
	# Procedure called to update opp when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.opp { PARAM_VALUE.opp } {
	# Procedure called to validate opp
	return true
}


proc update_MODELPARAM_VALUE.format { MODELPARAM_VALUE.format PARAM_VALUE.format } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.format}] ${MODELPARAM_VALUE.format}
}

proc update_MODELPARAM_VALUE.opp { MODELPARAM_VALUE.opp PARAM_VALUE.opp } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.opp}] ${MODELPARAM_VALUE.opp}
}

proc update_MODELPARAM_VALUE.DATA_SIZE { MODELPARAM_VALUE.DATA_SIZE PARAM_VALUE.DATA_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_SIZE}] ${MODELPARAM_VALUE.DATA_SIZE}
}

