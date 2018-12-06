# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  set C_S00_AXI_ADDR_WIDTH [ipgui::add_param $IPINST -name "C_S00_AXI_ADDR_WIDTH" -parent ${Page_0}]
  set_property tooltip {Width of the S_AXI addr bus.} ${C_S00_AXI_ADDR_WIDTH}
  set C_S00_AXI_DATA_WIDTH [ipgui::add_param $IPINST -name "C_S00_AXI_DATA_WIDTH" -parent ${Page_0}]
  set_property tooltip {Width of the S_AXI data bus.} ${C_S00_AXI_DATA_WIDTH}
  set DATA_FORMAT [ipgui::add_param $IPINST -name "DATA_FORMAT" -parent ${Page_0}]
  set_property tooltip {Data Format (un)signed.} ${DATA_FORMAT}
  set DATA_SIZE [ipgui::add_param $IPINST -name "DATA_SIZE" -parent ${Page_0}]
  set_property tooltip {Size of input data bus.} ${DATA_SIZE}
  set NB_INPUT [ipgui::add_param $IPINST -name "NB_INPUT" -parent ${Page_0}]
  set_property tooltip {Number of input channels (max 12).} ${NB_INPUT}
  set NB_SAMPLE [ipgui::add_param $IPINST -name "NB_SAMPLE" -parent ${Page_0}]
  set_property tooltip {Number of samples per channel.} ${NB_SAMPLE}
  set USE_EOF [ipgui::add_param $IPINST -name "USE_EOF" -parent ${Page_0}]
  set_property tooltip {Use EOF.} ${USE_EOF}


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

proc update_PARAM_VALUE.DATA_FORMAT { PARAM_VALUE.DATA_FORMAT } {
	# Procedure called to update DATA_FORMAT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA_FORMAT { PARAM_VALUE.DATA_FORMAT } {
	# Procedure called to validate DATA_FORMAT
	return true
}

proc update_PARAM_VALUE.DATA_SIZE { PARAM_VALUE.DATA_SIZE } {
	# Procedure called to update DATA_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA_SIZE { PARAM_VALUE.DATA_SIZE } {
	# Procedure called to validate DATA_SIZE
	return true
}

proc update_PARAM_VALUE.NB_INPUT { PARAM_VALUE.NB_INPUT } {
	# Procedure called to update NB_INPUT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NB_INPUT { PARAM_VALUE.NB_INPUT } {
	# Procedure called to validate NB_INPUT
	return true
}

proc update_PARAM_VALUE.NB_SAMPLE { PARAM_VALUE.NB_SAMPLE } {
	# Procedure called to update NB_SAMPLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NB_SAMPLE { PARAM_VALUE.NB_SAMPLE } {
	# Procedure called to validate NB_SAMPLE
	return true
}

proc update_PARAM_VALUE.USE_EOF { PARAM_VALUE.USE_EOF } {
	# Procedure called to update USE_EOF when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.USE_EOF { PARAM_VALUE.USE_EOF } {
	# Procedure called to validate USE_EOF
	return true
}


proc update_MODELPARAM_VALUE.USE_EOF { MODELPARAM_VALUE.USE_EOF PARAM_VALUE.USE_EOF } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.USE_EOF}] ${MODELPARAM_VALUE.USE_EOF}
}

proc update_MODELPARAM_VALUE.NB_INPUT { MODELPARAM_VALUE.NB_INPUT PARAM_VALUE.NB_INPUT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NB_INPUT}] ${MODELPARAM_VALUE.NB_INPUT}
}

proc update_MODELPARAM_VALUE.DATA_FORMAT { MODELPARAM_VALUE.DATA_FORMAT PARAM_VALUE.DATA_FORMAT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_FORMAT}] ${MODELPARAM_VALUE.DATA_FORMAT}
}

proc update_MODELPARAM_VALUE.DATA_SIZE { MODELPARAM_VALUE.DATA_SIZE PARAM_VALUE.DATA_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_SIZE}] ${MODELPARAM_VALUE.DATA_SIZE}
}

proc update_MODELPARAM_VALUE.NB_SAMPLE { MODELPARAM_VALUE.NB_SAMPLE PARAM_VALUE.NB_SAMPLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NB_SAMPLE}] ${MODELPARAM_VALUE.NB_SAMPLE}
}

proc update_MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S00_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S00_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH}
}

