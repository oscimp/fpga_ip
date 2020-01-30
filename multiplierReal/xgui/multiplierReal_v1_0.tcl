# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  set DATA1_IN_SIZE [ipgui::add_param $IPINST -name "DATA1_IN_SIZE" -parent ${Page_0}]
  set_property tooltip {Size of the input data1 stream.} ${DATA1_IN_SIZE}
  set DATA2_IN_SIZE [ipgui::add_param $IPINST -name "DATA2_IN_SIZE" -parent ${Page_0}]
  set_property tooltip {Size of the input data2 stream.} ${DATA2_IN_SIZE}
  set DATA_OUT_SIZE [ipgui::add_param $IPINST -name "DATA_OUT_SIZE" -parent ${Page_0}]
  set_property tooltip {Size of the output data stream.} ${DATA_OUT_SIZE}
  set SIGNED_FORMAT [ipgui::add_param $IPINST -name "SIGNED_FORMAT" -parent ${Page_0}]
  set_property tooltip {signedOrunsigned.} ${SIGNED_FORMAT}


}

proc update_PARAM_VALUE.DATA1_IN_SIZE { PARAM_VALUE.DATA1_IN_SIZE } {
	# Procedure called to update DATA1_IN_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA1_IN_SIZE { PARAM_VALUE.DATA1_IN_SIZE } {
	# Procedure called to validate DATA1_IN_SIZE
	return true
}

proc update_PARAM_VALUE.DATA2_IN_SIZE { PARAM_VALUE.DATA2_IN_SIZE } {
	# Procedure called to update DATA2_IN_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA2_IN_SIZE { PARAM_VALUE.DATA2_IN_SIZE } {
	# Procedure called to validate DATA2_IN_SIZE
	return true
}

proc update_PARAM_VALUE.DATA_OUT_SIZE { PARAM_VALUE.DATA_OUT_SIZE } {
	# Procedure called to update DATA_OUT_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA_OUT_SIZE { PARAM_VALUE.DATA_OUT_SIZE } {
	# Procedure called to validate DATA_OUT_SIZE
	return true
}

proc update_PARAM_VALUE.SIGNED_FORMAT { PARAM_VALUE.SIGNED_FORMAT } {
	# Procedure called to update SIGNED_FORMAT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SIGNED_FORMAT { PARAM_VALUE.SIGNED_FORMAT } {
	# Procedure called to validate SIGNED_FORMAT
	return true
}


proc update_MODELPARAM_VALUE.SIGNED_FORMAT { MODELPARAM_VALUE.SIGNED_FORMAT PARAM_VALUE.SIGNED_FORMAT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SIGNED_FORMAT}] ${MODELPARAM_VALUE.SIGNED_FORMAT}
}

proc update_MODELPARAM_VALUE.DATA1_IN_SIZE { MODELPARAM_VALUE.DATA1_IN_SIZE PARAM_VALUE.DATA1_IN_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA1_IN_SIZE}] ${MODELPARAM_VALUE.DATA1_IN_SIZE}
}

proc update_MODELPARAM_VALUE.DATA2_IN_SIZE { MODELPARAM_VALUE.DATA2_IN_SIZE PARAM_VALUE.DATA2_IN_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA2_IN_SIZE}] ${MODELPARAM_VALUE.DATA2_IN_SIZE}
}

proc update_MODELPARAM_VALUE.DATA_OUT_SIZE { MODELPARAM_VALUE.DATA_OUT_SIZE PARAM_VALUE.DATA_OUT_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_OUT_SIZE}] ${MODELPARAM_VALUE.DATA_OUT_SIZE}
}

