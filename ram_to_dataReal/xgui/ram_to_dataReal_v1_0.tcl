# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "Component_Name" -parent ${Page_0}
  ipgui::add_param $IPINST -name "COEFF_ADDR_SIZE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "COEFF_SIZE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DECIM_FACTOR_POW" -parent ${Page_0}
  set EXT_TRIG [ipgui::add_param $IPINST -name "EXT_TRIG" -parent ${Page_0}]
  set_property tooltip {Use trigger_i instead of ref_clk_i to sample the data stream} ${EXT_TRIG}
  ipgui::add_param $IPINST -name "ENABLE_EACH_CLK" -parent ${Page_0}
  ipgui::add_param $IPINST -name "id" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S00_AXI_DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S00_AXI_ADDR_WIDTH" -parent ${Page_0}


}

proc update_PARAM_VALUE.COEFF_ADDR_SIZE { PARAM_VALUE.COEFF_ADDR_SIZE } {
	# Procedure called to update COEFF_ADDR_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.COEFF_ADDR_SIZE { PARAM_VALUE.COEFF_ADDR_SIZE } {
	# Procedure called to validate COEFF_ADDR_SIZE
	return true
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

proc update_PARAM_VALUE.DECIM_FACTOR_POW { PARAM_VALUE.DECIM_FACTOR_POW } {
	# Procedure called to update DECIM_FACTOR_POW when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DECIM_FACTOR_POW { PARAM_VALUE.DECIM_FACTOR_POW } {
	# Procedure called to validate DECIM_FACTOR_POW
	return true
}

proc update_PARAM_VALUE.ENABLE_EACH_CLK { PARAM_VALUE.ENABLE_EACH_CLK } {
	# Procedure called to update ENABLE_EACH_CLK when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ENABLE_EACH_CLK { PARAM_VALUE.ENABLE_EACH_CLK } {
	# Procedure called to validate ENABLE_EACH_CLK
	return true
}

proc update_PARAM_VALUE.EXT_TRIG { PARAM_VALUE.EXT_TRIG } {
	# Procedure called to update EXT_TRIG when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.EXT_TRIG { PARAM_VALUE.EXT_TRIG } {
	# Procedure called to validate EXT_TRIG
	return true
}

proc update_PARAM_VALUE.id { PARAM_VALUE.id } {
	# Procedure called to update id when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.id { PARAM_VALUE.id } {
	# Procedure called to validate id
	return true
}


proc update_MODELPARAM_VALUE.COEFF_ADDR_SIZE { MODELPARAM_VALUE.COEFF_ADDR_SIZE PARAM_VALUE.COEFF_ADDR_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.COEFF_ADDR_SIZE}] ${MODELPARAM_VALUE.COEFF_ADDR_SIZE}
}

proc update_MODELPARAM_VALUE.COEFF_SIZE { MODELPARAM_VALUE.COEFF_SIZE PARAM_VALUE.COEFF_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.COEFF_SIZE}] ${MODELPARAM_VALUE.COEFF_SIZE}
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

proc update_MODELPARAM_VALUE.DECIM_FACTOR_POW { MODELPARAM_VALUE.DECIM_FACTOR_POW PARAM_VALUE.DECIM_FACTOR_POW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DECIM_FACTOR_POW}] ${MODELPARAM_VALUE.DECIM_FACTOR_POW}
}

proc update_MODELPARAM_VALUE.EXT_TRIG { MODELPARAM_VALUE.EXT_TRIG PARAM_VALUE.EXT_TRIG } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.EXT_TRIG}] ${MODELPARAM_VALUE.EXT_TRIG}
}

proc update_MODELPARAM_VALUE.ENABLE_EACH_CLK { MODELPARAM_VALUE.ENABLE_EACH_CLK PARAM_VALUE.ENABLE_EACH_CLK } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ENABLE_EACH_CLK}] ${MODELPARAM_VALUE.ENABLE_EACH_CLK}
}

