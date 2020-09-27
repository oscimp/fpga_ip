# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  set C_S00_AXI_ADDR_WIDTH [ipgui::add_param $IPINST -name "C_S00_AXI_ADDR_WIDTH" -parent ${Page_0}]
  set_property tooltip {Width of the S_AXI addr bus.} ${C_S00_AXI_ADDR_WIDTH}
  set C_S00_AXI_DATA_WIDTH [ipgui::add_param $IPINST -name "C_S00_AXI_DATA_WIDTH" -parent ${Page_0}]
  set_property tooltip {Width of the S_AXI data bus.} ${C_S00_AXI_DATA_WIDTH}
  set ADC_EN [ipgui::add_param $IPINST -name "ADC_EN" -parent ${Page_0}]
  set_property tooltip {Enable ADC.} ${ADC_EN}
  set DAC_EN [ipgui::add_param $IPINST -name "DAC_EN" -parent ${Page_0}]
  set_property tooltip {Enable DAC.} ${DAC_EN}

}

proc update_PARAM_VALUE.C_S00_AXI_ADDR_WIDTH { PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
        # Procedure called to update C_S00_AXI_ADDR_WIDTH when any of the dependent parameter$
}

proc validate_PARAM_VALUE.C_S00_AXI_ADDR_WIDTH { PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
        # Procedure called to validate C_S00_AXI_ADDR_WIDTH
        return true
}

proc update_PARAM_VALUE.C_S00_AXI_DATA_WIDTH { PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
        # Procedure called to update C_S00_AXI_DATA_WIDTH when any of the dependent parameter$
}

proc validate_PARAM_VALUE.C_S00_AXI_DATA_WIDTH { PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
        # Procedure called to validate C_S00_AXI_DATA_WIDTH
        return true
}

proc update_PARAM_VALUE.ADC_EN { PARAM_VALUE.ADC_EN } {
	# Procedure called to update ADC_EN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ADC_EN { PARAM_VALUE.ADC_EN } {
	# Procedure called to validate ADC_EN
	return true
}

proc update_PARAM_VALUE.DAC_EN { PARAM_VALUE.DAC_EN } {
	# Procedure called to update DAC_EN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DAC_EN { PARAM_VALUE.DAC_EN } {
	# Procedure called to validate DAC_EN
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

proc update_MODELPARAM_VALUE.ADC_EN { MODELPARAM_VALUE.ADC_EN PARAM_VALUE.ADC_EN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ADC_EN}] ${MODELPARAM_VALUE.ADC_EN}
}

proc update_MODELPARAM_VALUE.DAC_EN { MODELPARAM_VALUE.DAC_EN PARAM_VALUE.DAC_EN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DAC_EN}] ${MODELPARAM_VALUE.DAC_EN}
}
