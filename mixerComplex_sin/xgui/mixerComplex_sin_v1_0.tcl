# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "DATA_IN_SIZE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DATA_OUT_SIZE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "ENABLE_SEL" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "NCO_SIZE" -parent ${Page_0}


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

proc update_PARAM_VALUE.ENABLE_SEL { PARAM_VALUE.ENABLE_SEL } {
	# Procedure called to update ENABLE_SEL when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ENABLE_SEL { PARAM_VALUE.ENABLE_SEL } {
	# Procedure called to validate ENABLE_SEL
	return true
}

proc update_PARAM_VALUE.NCO_SIZE { PARAM_VALUE.NCO_SIZE } {
	# Procedure called to update NCO_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NCO_SIZE { PARAM_VALUE.NCO_SIZE } {
	# Procedure called to validate NCO_SIZE
	return true
}


proc update_MODELPARAM_VALUE.NCO_SIZE { MODELPARAM_VALUE.NCO_SIZE PARAM_VALUE.NCO_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NCO_SIZE}] ${MODELPARAM_VALUE.NCO_SIZE}
}

proc update_MODELPARAM_VALUE.ENABLE_SEL { MODELPARAM_VALUE.ENABLE_SEL PARAM_VALUE.ENABLE_SEL } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ENABLE_SEL}] ${MODELPARAM_VALUE.ENABLE_SEL}
}

proc update_MODELPARAM_VALUE.DATA_IN_SIZE { MODELPARAM_VALUE.DATA_IN_SIZE PARAM_VALUE.DATA_IN_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_IN_SIZE}] ${MODELPARAM_VALUE.DATA_IN_SIZE}
}

proc update_MODELPARAM_VALUE.DATA_OUT_SIZE { MODELPARAM_VALUE.DATA_OUT_SIZE PARAM_VALUE.DATA_OUT_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_OUT_SIZE}] ${MODELPARAM_VALUE.DATA_OUT_SIZE}
}

