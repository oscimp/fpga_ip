# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  set C_S00_AXI_ADDR_WIDTH [ipgui::add_param $IPINST -name "C_S00_AXI_ADDR_WIDTH" -parent ${Page_0}]
  set_property tooltip {Width of the S_AXI addr bus.} ${C_S00_AXI_ADDR_WIDTH}
  set C_S00_AXI_DATA_WIDTH [ipgui::add_param $IPINST -name "C_S00_AXI_DATA_WIDTH" -parent ${Page_0}]
  set_property tooltip {Width of the S_AXI data bus.} ${C_S00_AXI_DATA_WIDTH}
  set DEFAULT_BIT_OFFSET [ipgui::add_param $IPINST -name "DEFAULT_BIT_OFFSET" -parent ${Page_0}]
  set_property tooltip {default Bit to Output.} ${DEFAULT_BIT_OFFSET}
  set SLV_SIZE [ipgui::add_param $IPINST -name "SLV_SIZE" -parent ${Page_0}]
  set_property tooltip {StdLogicVector Size.} ${SLV_SIZE}


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

proc update_PARAM_VALUE.DEFAULT_BIT_OFFSET { PARAM_VALUE.DEFAULT_BIT_OFFSET } {
	# Procedure called to update DEFAULT_BIT_OFFSET when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DEFAULT_BIT_OFFSET { PARAM_VALUE.DEFAULT_BIT_OFFSET } {
	# Procedure called to validate DEFAULT_BIT_OFFSET
	return true
}

proc update_PARAM_VALUE.SLV_SIZE { PARAM_VALUE.SLV_SIZE } {
	# Procedure called to update SLV_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SLV_SIZE { PARAM_VALUE.SLV_SIZE } {
	# Procedure called to validate SLV_SIZE
	return true
}


proc update_MODELPARAM_VALUE.SLV_SIZE { MODELPARAM_VALUE.SLV_SIZE PARAM_VALUE.SLV_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SLV_SIZE}] ${MODELPARAM_VALUE.SLV_SIZE}
}

proc update_MODELPARAM_VALUE.DEFAULT_BIT_OFFSET { MODELPARAM_VALUE.DEFAULT_BIT_OFFSET PARAM_VALUE.DEFAULT_BIT_OFFSET } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DEFAULT_BIT_OFFSET}] ${MODELPARAM_VALUE.DEFAULT_BIT_OFFSET}
}

proc update_MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S00_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S00_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH}
}

