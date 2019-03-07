# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  set COUNTER_SIZE [ipgui::add_param $IPINST -name "COUNTER_SIZE" -parent ${Page_0}]
  set_property tooltip {Size of the phase accum counter.} ${COUNTER_SIZE}
  set C_S00_AXI_ADDR_WIDTH [ipgui::add_param $IPINST -name "C_S00_AXI_ADDR_WIDTH" -parent ${Page_0}]
  set_property tooltip {Width of the S_AXI addr bus.} ${C_S00_AXI_ADDR_WIDTH}
  set C_S00_AXI_DATA_WIDTH [ipgui::add_param $IPINST -name "C_S00_AXI_DATA_WIDTH" -parent ${Page_0}]
  set_property tooltip {Width of the S_AXI data bus.} ${C_S00_AXI_DATA_WIDTH}
  set DATA_SIZE [ipgui::add_param $IPINST -name "DATA_SIZE" -parent ${Page_0}]
  set_property tooltip {Size of input data bus.} ${DATA_SIZE}
  set DEFAULT_RST_ACCUM_VAL [ipgui::add_param $IPINST -name "DEFAULT_RST_ACCUM_VAL" -parent ${Page_0}]
  set_property tooltip {Default reset accum val.} ${DEFAULT_RST_ACCUM_VAL}
  set LUT_SIZE [ipgui::add_param $IPINST -name "LUT_SIZE" -parent ${Page_0}]
  set_property tooltip {Length of the coefficient LUT.} ${LUT_SIZE}
  set RESET_ACCUM [ipgui::add_param $IPINST -name "RESET_ACCUM" -parent ${Page_0}]
  set_property tooltip {Reset accum at each overflow.} ${RESET_ACCUM}
  set id [ipgui::add_param $IPINST -name "id" -parent ${Page_0}]
  set_property tooltip {Id.} ${id}


}

proc update_PARAM_VALUE.COUNTER_SIZE { PARAM_VALUE.COUNTER_SIZE } {
	# Procedure called to update COUNTER_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.COUNTER_SIZE { PARAM_VALUE.COUNTER_SIZE } {
	# Procedure called to validate COUNTER_SIZE
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

proc update_PARAM_VALUE.DEFAULT_RST_ACCUM_VAL { PARAM_VALUE.DEFAULT_RST_ACCUM_VAL } {
	# Procedure called to update DEFAULT_RST_ACCUM_VAL when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DEFAULT_RST_ACCUM_VAL { PARAM_VALUE.DEFAULT_RST_ACCUM_VAL } {
	# Procedure called to validate DEFAULT_RST_ACCUM_VAL
	return true
}

proc update_PARAM_VALUE.LUT_SIZE { PARAM_VALUE.LUT_SIZE } {
	# Procedure called to update LUT_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.LUT_SIZE { PARAM_VALUE.LUT_SIZE } {
	# Procedure called to validate LUT_SIZE
	return true
}

proc update_PARAM_VALUE.RESET_ACCUM { PARAM_VALUE.RESET_ACCUM } {
	# Procedure called to update RESET_ACCUM when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RESET_ACCUM { PARAM_VALUE.RESET_ACCUM } {
	# Procedure called to validate RESET_ACCUM
	return true
}

proc update_PARAM_VALUE.id { PARAM_VALUE.id } {
	# Procedure called to update id when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.id { PARAM_VALUE.id } {
	# Procedure called to validate id
	return true
}


proc update_MODELPARAM_VALUE.id { MODELPARAM_VALUE.id PARAM_VALUE.id } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.id}] ${MODELPARAM_VALUE.id}
}

proc update_MODELPARAM_VALUE.RESET_ACCUM { MODELPARAM_VALUE.RESET_ACCUM PARAM_VALUE.RESET_ACCUM } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RESET_ACCUM}] ${MODELPARAM_VALUE.RESET_ACCUM}
}

proc update_MODELPARAM_VALUE.DEFAULT_RST_ACCUM_VAL { MODELPARAM_VALUE.DEFAULT_RST_ACCUM_VAL PARAM_VALUE.DEFAULT_RST_ACCUM_VAL } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DEFAULT_RST_ACCUM_VAL}] ${MODELPARAM_VALUE.DEFAULT_RST_ACCUM_VAL}
}

proc update_MODELPARAM_VALUE.DATA_SIZE { MODELPARAM_VALUE.DATA_SIZE PARAM_VALUE.DATA_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_SIZE}] ${MODELPARAM_VALUE.DATA_SIZE}
}

proc update_MODELPARAM_VALUE.LUT_SIZE { MODELPARAM_VALUE.LUT_SIZE PARAM_VALUE.LUT_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.LUT_SIZE}] ${MODELPARAM_VALUE.LUT_SIZE}
}

proc update_MODELPARAM_VALUE.COUNTER_SIZE { MODELPARAM_VALUE.COUNTER_SIZE PARAM_VALUE.COUNTER_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.COUNTER_SIZE}] ${MODELPARAM_VALUE.COUNTER_SIZE}
}

proc update_MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S00_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S00_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH}
}

