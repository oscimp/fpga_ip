# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "id" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DATA_SIZE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "ADDR_SIZE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "ACCUM_SIZE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DFLT_START_OFFSET" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DFLT_STOP_OFFSET" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DFLT_LIMIT" -parent ${Page_0}

  ipgui::add_param $IPINST -name "C_S00_AXI_DATA_WIDTH"
  ipgui::add_param $IPINST -name "C_S00_AXI_ADDR_WIDTH"

}

proc update_PARAM_VALUE.ACCUM_SIZE { PARAM_VALUE.ACCUM_SIZE } {
	# Procedure called to update ACCUM_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ACCUM_SIZE { PARAM_VALUE.ACCUM_SIZE } {
	# Procedure called to validate ACCUM_SIZE
	return true
}

proc update_PARAM_VALUE.ADDR_SIZE { PARAM_VALUE.ADDR_SIZE } {
	# Procedure called to update ADDR_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ADDR_SIZE { PARAM_VALUE.ADDR_SIZE } {
	# Procedure called to validate ADDR_SIZE
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

proc update_PARAM_VALUE.DFLT_LIMIT { PARAM_VALUE.DFLT_LIMIT } {
	# Procedure called to update DFLT_LIMIT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DFLT_LIMIT { PARAM_VALUE.DFLT_LIMIT } {
	# Procedure called to validate DFLT_LIMIT
	return true
}

proc update_PARAM_VALUE.DFLT_START_OFFSET { PARAM_VALUE.DFLT_START_OFFSET } {
	# Procedure called to update DFLT_START_OFFSET when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DFLT_START_OFFSET { PARAM_VALUE.DFLT_START_OFFSET } {
	# Procedure called to validate DFLT_START_OFFSET
	return true
}

proc update_PARAM_VALUE.DFLT_STOP_OFFSET { PARAM_VALUE.DFLT_STOP_OFFSET } {
	# Procedure called to update DFLT_STOP_OFFSET when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DFLT_STOP_OFFSET { PARAM_VALUE.DFLT_STOP_OFFSET } {
	# Procedure called to validate DFLT_STOP_OFFSET
	return true
}

proc update_PARAM_VALUE.id { PARAM_VALUE.id } {
	# Procedure called to update id when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.id { PARAM_VALUE.id } {
	# Procedure called to validate id
	return true
}

proc update_PARAM_VALUE.DATA_SIZE { PARAM_VALUE.DATA_SIZE } {
	# Procedure called to update DATA_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA_SIZE { PARAM_VALUE.DATA_SIZE } {
	# Procedure called to validate DATA_SIZE
	return true
}


proc update_MODELPARAM_VALUE.DATA_SIZE { MODELPARAM_VALUE.DATA_SIZE PARAM_VALUE.DATA_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_SIZE}] ${MODELPARAM_VALUE.DATA_SIZE}
}

proc update_MODELPARAM_VALUE.id { MODELPARAM_VALUE.id PARAM_VALUE.id } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.id}] ${MODELPARAM_VALUE.id}
}

proc update_MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S00_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S00_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.ACCUM_SIZE { MODELPARAM_VALUE.ACCUM_SIZE PARAM_VALUE.ACCUM_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ACCUM_SIZE}] ${MODELPARAM_VALUE.ACCUM_SIZE}
}

proc update_MODELPARAM_VALUE.ADDR_SIZE { MODELPARAM_VALUE.ADDR_SIZE PARAM_VALUE.ADDR_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ADDR_SIZE}] ${MODELPARAM_VALUE.ADDR_SIZE}
}

proc update_MODELPARAM_VALUE.DFLT_START_OFFSET { MODELPARAM_VALUE.DFLT_START_OFFSET PARAM_VALUE.DFLT_START_OFFSET } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DFLT_START_OFFSET}] ${MODELPARAM_VALUE.DFLT_START_OFFSET}
}

proc update_MODELPARAM_VALUE.DFLT_STOP_OFFSET { MODELPARAM_VALUE.DFLT_STOP_OFFSET PARAM_VALUE.DFLT_STOP_OFFSET } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DFLT_STOP_OFFSET}] ${MODELPARAM_VALUE.DFLT_STOP_OFFSET}
}

proc update_MODELPARAM_VALUE.DFLT_LIMIT { MODELPARAM_VALUE.DFLT_LIMIT PARAM_VALUE.DFLT_LIMIT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DFLT_LIMIT}] ${MODELPARAM_VALUE.DFLT_LIMIT}
}

