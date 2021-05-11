# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  set DATA_IN_SIZE [ipgui::add_param $IPINST -name "DATA_IN_SIZE" -parent ${Page_0}]
  set_property tooltip {Size of input data bus.} ${DATA_IN_SIZE}
  set NB_ITER [ipgui::add_param $IPINST -name "NB_ITER" -parent ${Page_0}]
  set_property tooltip {Number of successive approximation.} ${NB_ITER}
  set DATA_OUT_SIZE [ipgui::add_param $IPINST -name "DATA_OUT_SIZE" -parent ${Page_0}]
  set_property tooltip {Size of output data bus.} ${DATA_OUT_SIZE}
  set PI_VALUE [ipgui::add_param $IPINST -name "PI_VALUE" -parent ${Page_0}]
  set_property tooltip {Pi x pow(2, NB_ITER-1).} ${PI_VALUE}


}

proc update_PARAM_VALUE.DATA_IN_SIZE { PARAM_VALUE.DATA_IN_SIZE } {
	# Procedure called to update DATA_IN_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA_IN_SIZE { PARAM_VALUE.DATA_IN_SIZE } {
	# Procedure called to validate DATA_IN_SIZE
	return true
}

proc update_PARAM_VALUE.NB_ITER { PARAM_VALUE.NB_ITER } {
	# Procedure called to update NB_ITER when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NB_ITER { PARAM_VALUE.NB_ITER } {
	# Procedure called to validate NB_ITER
	return true
}

proc update_PARAM_VALUE.DATA_OUT_SIZE { PARAM_VALUE.DATA_OUT_SIZE } {
	# Procedure called to update DATA_OUT_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA_OUT_SIZE { PARAM_VALUE.DATA_OUT_SIZE } {
	# Procedure called to validate DATA_OUT_SIZE
	return true
}

proc update_PARAM_VALUE.PI_VALUE { PARAM_VALUE.PI_VALUE } {
	# Procedure called to update PI_VALUE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PI_VALUE { PARAM_VALUE.PI_VALUE } {
	# Procedure called to validate PI_VALUE
	return true
}


proc update_MODELPARAM_VALUE.NB_ITER { MODELPARAM_VALUE.NB_ITER PARAM_VALUE.NB_ITER } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NB_ITER}] ${MODELPARAM_VALUE.NB_ITER}
}

proc update_MODELPARAM_VALUE.DATA_IN_SIZE { MODELPARAM_VALUE.DATA_IN_SIZE PARAM_VALUE.DATA_IN_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_IN_SIZE}] ${MODELPARAM_VALUE.DATA_IN_SIZE}
}

proc update_MODELPARAM_VALUE.DATA_OUT_SIZE { MODELPARAM_VALUE.DATA_OUT_SIZE PARAM_VALUE.DATA_OUT_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_OUT_SIZE}] ${MODELPARAM_VALUE.DATA_OUT_SIZE}
}

proc update_MODELPARAM_VALUE.PI_VALUE { MODELPARAM_VALUE.PI_VALUE PARAM_VALUE.PI_VALUE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PI_VALUE}] ${MODELPARAM_VALUE.PI_VALUE}
}

