# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  set BURST_SIZE [ipgui::add_param $IPINST -name "BURST_SIZE" -parent ${Page_0}]
  set_property tooltip {Max size of the burst.} ${BURST_SIZE}
  set C_S00_AXI_ADDR_WIDTH [ipgui::add_param $IPINST -name "C_S00_AXI_ADDR_WIDTH" -parent ${Page_0}]
  set_property tooltip {Width of the S_AXI addr bus.} ${C_S00_AXI_ADDR_WIDTH}
  set C_S00_AXI_DATA_WIDTH [ipgui::add_param $IPINST -name "C_S00_AXI_DATA_WIDTH" -parent ${Page_0}]
  set_property tooltip {Width of the S_AXI data bus.} ${C_S00_AXI_DATA_WIDTH}
  set DATA_SIZE [ipgui::add_param $IPINST -name "DATA_SIZE" -parent ${Page_0}]
  set_property tooltip {Size of data busses.} ${DATA_SIZE}
  set ID [ipgui::add_param $IPINST -name "ID" -parent ${Page_0}]
  set_property tooltip {Component id.} ${ID}
  set RXOFF [ipgui::add_param $IPINST -name "RXOFF" -parent ${Page_0}]
  set_property tooltip {number of cycle.} ${RXOFF}
  set TXON [ipgui::add_param $IPINST -name "TXON" -parent ${Page_0}]
  set_property tooltip {number of cycle.} ${TXON}


}

proc update_PARAM_VALUE.BURST_SIZE { PARAM_VALUE.BURST_SIZE } {
	# Procedure called to update BURST_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BURST_SIZE { PARAM_VALUE.BURST_SIZE } {
	# Procedure called to validate BURST_SIZE
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

proc update_PARAM_VALUE.ID { PARAM_VALUE.ID } {
	# Procedure called to update ID when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ID { PARAM_VALUE.ID } {
	# Procedure called to validate ID
	return true
}

proc update_PARAM_VALUE.RXOFF { PARAM_VALUE.RXOFF } {
	# Procedure called to update RXOFF when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RXOFF { PARAM_VALUE.RXOFF } {
	# Procedure called to validate RXOFF
	return true
}

proc update_PARAM_VALUE.TXON { PARAM_VALUE.TXON } {
	# Procedure called to update TXON when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TXON { PARAM_VALUE.TXON } {
	# Procedure called to validate TXON
	return true
}


proc update_MODELPARAM_VALUE.ID { MODELPARAM_VALUE.ID PARAM_VALUE.ID } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ID}] ${MODELPARAM_VALUE.ID}
}

proc update_MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S00_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S00_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.DATA_SIZE { MODELPARAM_VALUE.DATA_SIZE PARAM_VALUE.DATA_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_SIZE}] ${MODELPARAM_VALUE.DATA_SIZE}
}

proc update_MODELPARAM_VALUE.BURST_SIZE { MODELPARAM_VALUE.BURST_SIZE PARAM_VALUE.BURST_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BURST_SIZE}] ${MODELPARAM_VALUE.BURST_SIZE}
}

proc update_MODELPARAM_VALUE.RXOFF { MODELPARAM_VALUE.RXOFF PARAM_VALUE.RXOFF } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RXOFF}] ${MODELPARAM_VALUE.RXOFF}
}

proc update_MODELPARAM_VALUE.TXON { MODELPARAM_VALUE.TXON PARAM_VALUE.TXON } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.TXON}] ${MODELPARAM_VALUE.TXON}
}

