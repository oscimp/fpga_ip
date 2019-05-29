# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "format" -parent ${Page_0}
  ipgui::add_param $IPINST -name "nb_accum" -parent ${Page_0}
  ipgui::add_param $IPINST -name "shift" -parent ${Page_0}
  ipgui::add_param $IPINST -name "OUTPUT_DATA_SIZE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "INPUT_DATA_SIZE" -parent ${Page_0}


}

proc update_PARAM_VALUE.INPUT_DATA_SIZE { PARAM_VALUE.INPUT_DATA_SIZE } {
	# Procedure called to update INPUT_DATA_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.INPUT_DATA_SIZE { PARAM_VALUE.INPUT_DATA_SIZE } {
	# Procedure called to validate INPUT_DATA_SIZE
	return true
}

proc update_PARAM_VALUE.OUTPUT_DATA_SIZE { PARAM_VALUE.OUTPUT_DATA_SIZE } {
	# Procedure called to update OUTPUT_DATA_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.OUTPUT_DATA_SIZE { PARAM_VALUE.OUTPUT_DATA_SIZE } {
	# Procedure called to validate OUTPUT_DATA_SIZE
	return true
}

proc update_PARAM_VALUE.format { PARAM_VALUE.format } {
	# Procedure called to update format when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.format { PARAM_VALUE.format } {
	# Procedure called to validate format
	return true
}

proc update_PARAM_VALUE.nb_accum { PARAM_VALUE.nb_accum } {
	# Procedure called to update nb_accum when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.nb_accum { PARAM_VALUE.nb_accum } {
	# Procedure called to validate nb_accum
	return true
}

proc update_PARAM_VALUE.shift { PARAM_VALUE.shift } {
	# Procedure called to update shift when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.shift { PARAM_VALUE.shift } {
	# Procedure called to validate shift
	return true
}


proc update_MODELPARAM_VALUE.format { MODELPARAM_VALUE.format PARAM_VALUE.format } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.format}] ${MODELPARAM_VALUE.format}
}

proc update_MODELPARAM_VALUE.nb_accum { MODELPARAM_VALUE.nb_accum PARAM_VALUE.nb_accum } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.nb_accum}] ${MODELPARAM_VALUE.nb_accum}
}

proc update_MODELPARAM_VALUE.shift { MODELPARAM_VALUE.shift PARAM_VALUE.shift } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.shift}] ${MODELPARAM_VALUE.shift}
}

proc update_MODELPARAM_VALUE.OUTPUT_DATA_SIZE { MODELPARAM_VALUE.OUTPUT_DATA_SIZE PARAM_VALUE.OUTPUT_DATA_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.OUTPUT_DATA_SIZE}] ${MODELPARAM_VALUE.OUTPUT_DATA_SIZE}
}

proc update_MODELPARAM_VALUE.INPUT_DATA_SIZE { MODELPARAM_VALUE.INPUT_DATA_SIZE PARAM_VALUE.INPUT_DATA_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.INPUT_DATA_SIZE}] ${MODELPARAM_VALUE.INPUT_DATA_SIZE}
}

