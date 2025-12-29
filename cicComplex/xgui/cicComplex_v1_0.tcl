# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "data_signed" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DATA_IN_SIZE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DATA_OUT_SIZE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "ORDER" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DECIMATE_FACTOR" -parent ${Page_0}
}


proc update_PARAM_VALUE.ORDER { PARAM_VALUE.ORDER } {
	# Procedure called to update ORDER when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ORDER { PARAM_VALUE.ORDER } {
	# Procedure called to validate ORDER
	return true
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


proc update_PARAM_VALUE.DECIMATE_FACTOR { PARAM_VALUE.DECIMATE_FACTOR } {
	# Procedure called to update DECIMATE_FACTOR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DECIMATE_FACTOR { PARAM_VALUE.DECIMATE_FACTOR } {
	# Procedure called to validate DECIMATE_FACTOR
	return true
}


proc update_PARAM_VALUE.ID { PARAM_VALUE.ID } {
	# Procedure called to update ID when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ID { PARAM_VALUE.ID } {
	# Procedure called to validate ID
	return true
}


proc update_PARAM_VALUE.data_signed { PARAM_VALUE.data_signed } {
	# Procedure called to update data_signed when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.data_signed { PARAM_VALUE.data_signed } {
	# Procedure called to validate data_signed
	return true
}


proc update_MODELPARAM_VALUE.ID { MODELPARAM_VALUE.ID PARAM_VALUE.ID } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ID}] ${MODELPARAM_VALUE.ID}
}

proc update_MODELPARAM_VALUE.ORDER { MODELPARAM_VALUE.ORDER PARAM_VALUE.ORDER } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ORDER}] ${MODELPARAM_VALUE.ORDER}
}

proc update_MODELPARAM_VALUE.DECIMATE_FACTOR { MODELPARAM_VALUE.DECIMATE_FACTOR PARAM_VALUE.DECIMATE_FACTOR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DECIMATE_FACTOR}] ${MODELPARAM_VALUE.DECIMATE_FACTOR}
}

proc update_MODELPARAM_VALUE.DATA_IN_SIZE { MODELPARAM_VALUE.DATA_IN_SIZE PARAM_VALUE.DATA_IN_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_IN_SIZE}] ${MODELPARAM_VALUE.DATA_IN_SIZE}
}

proc update_MODELPARAM_VALUE.DATA_OUT_SIZE { MODELPARAM_VALUE.DATA_OUT_SIZE PARAM_VALUE.DATA_OUT_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_OUT_SIZE}] ${MODELPARAM_VALUE.DATA_OUT_SIZE}
}

proc update_MODELPARAM_VALUE.data_signed { MODELPARAM_VALUE.data_signed PARAM_VALUE.data_signed } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.data_signed}] ${MODELPARAM_VALUE.data_signed}
}

