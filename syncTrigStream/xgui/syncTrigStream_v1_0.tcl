# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  set C_S00_AXI_ADDR_WIDTH [ipgui::add_param $IPINST -name "C_S00_AXI_ADDR_WIDTH" -parent ${Page_0}]
  set_property tooltip {Width of the S_AXI addr bus.} ${C_S00_AXI_ADDR_WIDTH}
  set C_S00_AXI_DATA_WIDTH [ipgui::add_param $IPINST -name "C_S00_AXI_DATA_WIDTH" -parent ${Page_0}]
  set_property tooltip {Width of the S_AXI data bus.} ${C_S00_AXI_DATA_WIDTH}
  set DATA_SIZE [ipgui::add_param $IPINST -name "DATA_SIZE" -parent ${Page_0}]
  set_property tooltip {Size of data bus.} ${DATA_SIZE}
  set DFLT_DUTY [ipgui::add_param $IPINST -name "DFLT_DUTY" -parent ${Page_0}]
  set_property tooltip {Default pulse duty in clk cycle} ${DFLT_DUTY}
  set DFLT_PERIOD [ipgui::add_param $IPINST -name "DFLT_PERIOD" -parent ${Page_0}]
  set_property tooltip {Default pulse period in clk cycle} ${DFLT_PERIOD}
  set GEN_SIZE [ipgui::add_param $IPINST -name "GEN_SIZE" -parent ${Page_0}]
  set_property tooltip {Size of accumulator used for pulse generation.} ${GEN_SIZE}
  set NB_SAMPLE [ipgui::add_param $IPINST -name "NB_SAMPLE" -parent ${Page_0}]
  set_property tooltip {number of sample propagates after pulse rise.} ${NB_SAMPLE}
  set USE_EXT_TRIG [ipgui::add_param $IPINST -name "USE_EXT_TRIG" -parent ${Page_0}]
  set_property tooltip {Use input trig instead of generate one.} ${USE_EXT_TRIG}


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

proc update_PARAM_VALUE.DATA_SIZE { PARAM_VALUE.DATA_SIZE } {
	# Procedure called to update DATA_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA_SIZE { PARAM_VALUE.DATA_SIZE } {
	# Procedure called to validate DATA_SIZE
	return true
}

proc update_PARAM_VALUE.DFLT_DUTY { PARAM_VALUE.DFLT_DUTY } {
	# Procedure called to update DFLT_DUTY when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DFLT_DUTY { PARAM_VALUE.DFLT_DUTY } {
	# Procedure called to validate DFLT_DUTY
	return true
}

proc update_PARAM_VALUE.DFLT_PERIOD { PARAM_VALUE.DFLT_PERIOD } {
	# Procedure called to update DFLT_PERIOD when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DFLT_PERIOD { PARAM_VALUE.DFLT_PERIOD } {
	# Procedure called to validate DFLT_PERIOD
	return true
}

proc update_PARAM_VALUE.GEN_SIZE { PARAM_VALUE.GEN_SIZE } {
	# Procedure called to update GEN_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.GEN_SIZE { PARAM_VALUE.GEN_SIZE } {
	# Procedure called to validate GEN_SIZE
	return true
}

proc update_PARAM_VALUE.NB_SAMPLE { PARAM_VALUE.NB_SAMPLE } {
	# Procedure called to update NB_SAMPLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NB_SAMPLE { PARAM_VALUE.NB_SAMPLE } {
	# Procedure called to validate NB_SAMPLE
	return true
}

proc update_PARAM_VALUE.USE_EXT_TRIG { PARAM_VALUE.USE_EXT_TRIG } {
	# Procedure called to update USE_EXT_TRIG when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.USE_EXT_TRIG { PARAM_VALUE.USE_EXT_TRIG } {
	# Procedure called to validate USE_EXT_TRIG
	return true
}


proc update_MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S00_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S00_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.USE_EXT_TRIG { MODELPARAM_VALUE.USE_EXT_TRIG PARAM_VALUE.USE_EXT_TRIG } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.USE_EXT_TRIG}] ${MODELPARAM_VALUE.USE_EXT_TRIG}
}

proc update_MODELPARAM_VALUE.DFLT_PERIOD { MODELPARAM_VALUE.DFLT_PERIOD PARAM_VALUE.DFLT_PERIOD } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DFLT_PERIOD}] ${MODELPARAM_VALUE.DFLT_PERIOD}
}

proc update_MODELPARAM_VALUE.DFLT_DUTY { MODELPARAM_VALUE.DFLT_DUTY PARAM_VALUE.DFLT_DUTY } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DFLT_DUTY}] ${MODELPARAM_VALUE.DFLT_DUTY}
}

proc update_MODELPARAM_VALUE.GEN_SIZE { MODELPARAM_VALUE.GEN_SIZE PARAM_VALUE.GEN_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.GEN_SIZE}] ${MODELPARAM_VALUE.GEN_SIZE}
}

proc update_MODELPARAM_VALUE.DATA_SIZE { MODELPARAM_VALUE.DATA_SIZE PARAM_VALUE.DATA_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_SIZE}] ${MODELPARAM_VALUE.DATA_SIZE}
}

proc update_MODELPARAM_VALUE.NB_SAMPLE { MODELPARAM_VALUE.NB_SAMPLE PARAM_VALUE.NB_SAMPLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NB_SAMPLE}] ${MODELPARAM_VALUE.NB_SAMPLE}
}

