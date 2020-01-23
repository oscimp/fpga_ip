# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  set DATA_IN_SIZE [ipgui::add_param $IPINST -name "DATA_IN_SIZE" -parent ${Page_0}]
  set_property tooltip {Size of the input data stream.} ${DATA_IN_SIZE}
  set DATA_OUT_SIZE [ipgui::add_param $IPINST -name "DATA_OUT_SIZE" -parent ${Page_0}]
  set_property tooltip {Size of the output data stream.} ${DATA_OUT_SIZE}
  set NB_ACCUM [ipgui::add_param $IPINST -name "NB_ACCUM" -parent ${Page_0}]
  set_property tooltip {Number Of Accumulation.} ${NB_ACCUM}
  set SHIFT [ipgui::add_param $IPINST -name "SHIFT" -parent ${Page_0}]
  set_property tooltip {Shift applied to the result just before produce.} ${SHIFT}
  set SIGNED_FORMAT [ipgui::add_param $IPINST -name "SIGNED_FORMAT" -parent ${Page_0}]
  set_property tooltip {signedOrunsigned.} ${SIGNED_FORMAT}


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

proc update_PARAM_VALUE.NB_ACCUM { PARAM_VALUE.NB_ACCUM } {
	# Procedure called to update NB_ACCUM when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NB_ACCUM { PARAM_VALUE.NB_ACCUM } {
	# Procedure called to validate NB_ACCUM
	return true
}

proc update_PARAM_VALUE.SHIFT { PARAM_VALUE.SHIFT } {
	# Procedure called to update SHIFT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SHIFT { PARAM_VALUE.SHIFT } {
	# Procedure called to validate SHIFT
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

proc update_MODELPARAM_VALUE.NB_ACCUM { MODELPARAM_VALUE.NB_ACCUM PARAM_VALUE.NB_ACCUM } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NB_ACCUM}] ${MODELPARAM_VALUE.NB_ACCUM}
}

proc update_MODELPARAM_VALUE.SHIFT { MODELPARAM_VALUE.SHIFT PARAM_VALUE.SHIFT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SHIFT}] ${MODELPARAM_VALUE.SHIFT}
}

proc update_MODELPARAM_VALUE.DATA_OUT_SIZE { MODELPARAM_VALUE.DATA_OUT_SIZE PARAM_VALUE.DATA_OUT_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_OUT_SIZE}] ${MODELPARAM_VALUE.DATA_OUT_SIZE}
}

proc update_MODELPARAM_VALUE.DATA_IN_SIZE { MODELPARAM_VALUE.DATA_IN_SIZE PARAM_VALUE.DATA_IN_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_IN_SIZE}] ${MODELPARAM_VALUE.DATA_IN_SIZE}
}

