# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  set COEFF_SIZE [ipgui::add_param $IPINST -name "COEFF_SIZE" -parent ${Page_0}]
  set_property tooltip {Coefficient size.} ${COEFF_SIZE}
  set C_S00_AXI_ADDR_WIDTH [ipgui::add_param $IPINST -name "C_S00_AXI_ADDR_WIDTH" -parent ${Page_0}]
  set_property tooltip {Width of the S_AXI addr bus.} ${C_S00_AXI_ADDR_WIDTH}
  set C_S00_AXI_DATA_WIDTH [ipgui::add_param $IPINST -name "C_S00_AXI_DATA_WIDTH" -parent ${Page_0}]
  set_property tooltip {Width of the S_AXI data bus.} ${C_S00_AXI_DATA_WIDTH}
  set DATA_IN_SIZE [ipgui::add_param $IPINST -name "DATA_IN_SIZE" -parent ${Page_0}]
  set_property tooltip {Size of input data bus.} ${DATA_IN_SIZE}
  set DATA_OUT_SIZE [ipgui::add_param $IPINST -name "DATA_OUT_SIZE" -parent ${Page_0}]
  set_property tooltip {Size of output data bus.} ${DATA_OUT_SIZE}
  set DECIMATE_FACTOR [ipgui::add_param $IPINST -name "DECIMATE_FACTOR" -parent ${Page_0}]
  set_property tooltip {Decimate Factor.} ${DECIMATE_FACTOR}
  set ID [ipgui::add_param $IPINST -name "ID" -parent ${Page_0}]
  set_property tooltip {Unique Id.} ${ID}
  set NB_COEFF [ipgui::add_param $IPINST -name "NB_COEFF" -parent ${Page_0}]
  set_property tooltip {number of coefficient.} ${NB_COEFF}
  set coeff_format [ipgui::add_param $IPINST -name "coeff_format" -parent ${Page_0}]
  set_property tooltip {Coefficient (un)signed.} ${coeff_format}


}

proc update_PARAM_VALUE.COEFF_SIZE { PARAM_VALUE.COEFF_SIZE } {
	# Procedure called to update COEFF_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.COEFF_SIZE { PARAM_VALUE.COEFF_SIZE } {
	# Procedure called to validate COEFF_SIZE
	return true
}

proc update_PARAM_VALUE.C_S00_AXI_ADDR_WIDTH { PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to update C_S00_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S00_AXI_ADDR_WIDTH { PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to validate C_S00_AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S00_AXI_DATA_WIDTH { PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to update C_S00_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S00_AXI_DATA_WIDTH { PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to validate C_S00_AXI_DATA_WIDTH
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

proc update_PARAM_VALUE.NB_COEFF { PARAM_VALUE.NB_COEFF } {
	# Procedure called to update NB_COEFF when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NB_COEFF { PARAM_VALUE.NB_COEFF } {
	# Procedure called to validate NB_COEFF
	return true
}

proc update_PARAM_VALUE.coeff_format { PARAM_VALUE.coeff_format } {
	# Procedure called to update coeff_format when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.coeff_format { PARAM_VALUE.coeff_format } {
	# Procedure called to validate coeff_format
	return true
}


proc update_MODELPARAM_VALUE.ID { MODELPARAM_VALUE.ID PARAM_VALUE.ID } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ID}] ${MODELPARAM_VALUE.ID}
}

proc update_MODELPARAM_VALUE.coeff_format { MODELPARAM_VALUE.coeff_format PARAM_VALUE.coeff_format } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.coeff_format}] ${MODELPARAM_VALUE.coeff_format}
}

proc update_MODELPARAM_VALUE.NB_COEFF { MODELPARAM_VALUE.NB_COEFF PARAM_VALUE.NB_COEFF } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NB_COEFF}] ${MODELPARAM_VALUE.NB_COEFF}
}

proc update_MODELPARAM_VALUE.COEFF_SIZE { MODELPARAM_VALUE.COEFF_SIZE PARAM_VALUE.COEFF_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.COEFF_SIZE}] ${MODELPARAM_VALUE.COEFF_SIZE}
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

proc update_MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S00_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S00_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH}
}

