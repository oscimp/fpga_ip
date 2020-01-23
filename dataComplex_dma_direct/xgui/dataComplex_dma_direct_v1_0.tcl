# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "C_M00_AXIS_TDATA_WIDTH" -parent ${Page_0}
  set C_S00_AXI_ADDR_WIDTH [ipgui::add_param $IPINST -name "C_S00_AXI_ADDR_WIDTH" -parent ${Page_0}]
  set_property tooltip {Width of the S_AXI addr bus.} ${C_S00_AXI_ADDR_WIDTH}
  set C_S00_AXI_DATA_WIDTH [ipgui::add_param $IPINST -name "C_S00_AXI_DATA_WIDTH" -parent ${Page_0}]
  set_property tooltip {Width of the S_AXI data bus.} ${C_S00_AXI_DATA_WIDTH}
  ipgui::add_param $IPINST -name "DATA_SIZE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "NB_SAMPLE" -parent ${Page_0}
  set SIGNED_FORMAT [ipgui::add_param $IPINST -name "SIGNED_FORMAT" -parent ${Page_0}]
  set_property tooltip {signedOrunsigned} ${SIGNED_FORMAT}
  set STOP_ON_EOF [ipgui::add_param $IPINST -name "STOP_ON_EOF" -parent ${Page_0}]
  set_property tooltip {stop xfer when EOF is high.} ${STOP_ON_EOF}
  set USE_SOF [ipgui::add_param $IPINST -name "USE_SOF" -parent ${Page_0}]
  set_property tooltip {start acquisition when SOF is high.} ${USE_SOF}


}

proc update_PARAM_VALUE.C_M00_AXIS_TDATA_WIDTH { PARAM_VALUE.C_M00_AXIS_TDATA_WIDTH } {
	# Procedure called to update C_M00_AXIS_TDATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M00_AXIS_TDATA_WIDTH { PARAM_VALUE.C_M00_AXIS_TDATA_WIDTH } {
	# Procedure called to validate C_M00_AXIS_TDATA_WIDTH
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

proc update_PARAM_VALUE.DATA_SIZE { PARAM_VALUE.DATA_SIZE } {
	# Procedure called to update DATA_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA_SIZE { PARAM_VALUE.DATA_SIZE } {
	# Procedure called to validate DATA_SIZE
	return true
}

proc update_PARAM_VALUE.NB_SAMPLE { PARAM_VALUE.NB_SAMPLE } {
	# Procedure called to update NB_SAMPLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NB_SAMPLE { PARAM_VALUE.NB_SAMPLE } {
	# Procedure called to validate NB_SAMPLE
	return true
}

proc update_PARAM_VALUE.SIGNED_FORMAT { PARAM_VALUE.SIGNED_FORMAT } {
	# Procedure called to update SIGNED_FORMAT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SIGNED_FORMAT { PARAM_VALUE.SIGNED_FORMAT } {
	# Procedure called to validate SIGNED_FORMAT
	return true
}

proc update_PARAM_VALUE.STOP_ON_EOF { PARAM_VALUE.STOP_ON_EOF } {
	# Procedure called to update STOP_ON_EOF when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.STOP_ON_EOF { PARAM_VALUE.STOP_ON_EOF } {
	# Procedure called to validate STOP_ON_EOF
	return true
}

proc update_PARAM_VALUE.USE_SOF { PARAM_VALUE.USE_SOF } {
	# Procedure called to update USE_SOF when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.USE_SOF { PARAM_VALUE.USE_SOF } {
	# Procedure called to validate USE_SOF
	return true
}


proc update_MODELPARAM_VALUE.NB_SAMPLE { MODELPARAM_VALUE.NB_SAMPLE PARAM_VALUE.NB_SAMPLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NB_SAMPLE}] ${MODELPARAM_VALUE.NB_SAMPLE}
}

proc update_MODELPARAM_VALUE.SIGNED_FORMAT { MODELPARAM_VALUE.SIGNED_FORMAT PARAM_VALUE.SIGNED_FORMAT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SIGNED_FORMAT}] ${MODELPARAM_VALUE.SIGNED_FORMAT}
}

proc update_MODELPARAM_VALUE.DATA_SIZE { MODELPARAM_VALUE.DATA_SIZE PARAM_VALUE.DATA_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_SIZE}] ${MODELPARAM_VALUE.DATA_SIZE}
}

proc update_MODELPARAM_VALUE.USE_SOF { MODELPARAM_VALUE.USE_SOF PARAM_VALUE.USE_SOF } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.USE_SOF}] ${MODELPARAM_VALUE.USE_SOF}
}

proc update_MODELPARAM_VALUE.STOP_ON_EOF { MODELPARAM_VALUE.STOP_ON_EOF PARAM_VALUE.STOP_ON_EOF } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.STOP_ON_EOF}] ${MODELPARAM_VALUE.STOP_ON_EOF}
}

proc update_MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S00_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S00_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M00_AXIS_TDATA_WIDTH { MODELPARAM_VALUE.C_M00_AXIS_TDATA_WIDTH PARAM_VALUE.C_M00_AXIS_TDATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M00_AXIS_TDATA_WIDTH}] ${MODELPARAM_VALUE.C_M00_AXIS_TDATA_WIDTH}
}

