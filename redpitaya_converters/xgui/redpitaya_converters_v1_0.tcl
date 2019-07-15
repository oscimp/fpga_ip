# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  set ADC_EN [ipgui::add_param $IPINST -name "ADC_EN" -parent ${Page_0}]
  set_property tooltip {Enable ADC.} ${ADC_EN}
  set ADC_SIZE [ipgui::add_param $IPINST -name "ADC_SIZE" -parent ${Page_0} -widget comboBox]
  set_property tooltip {ADC bus size.} ${ADC_SIZE}
  set CLOCK_DUTY_CYCLE_STABILIZER_EN [ipgui::add_param $IPINST -name "CLOCK_DUTY_CYCLE_STABILIZER_EN" -parent ${Page_0}]
  set_property tooltip {Enable ADC clock duty cycle stabilizer.} ${CLOCK_DUTY_CYCLE_STABILIZER_EN}
  set DAC_EN [ipgui::add_param $IPINST -name "DAC_EN" -parent ${Page_0}]
  set_property tooltip {Enable DAC.} ${DAC_EN}


}

proc update_PARAM_VALUE.ADC_EN { PARAM_VALUE.ADC_EN } {
	# Procedure called to update ADC_EN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ADC_EN { PARAM_VALUE.ADC_EN } {
	# Procedure called to validate ADC_EN
	return true
}

proc update_PARAM_VALUE.ADC_SIZE { PARAM_VALUE.ADC_SIZE } {
	# Procedure called to update ADC_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ADC_SIZE { PARAM_VALUE.ADC_SIZE } {
	# Procedure called to validate ADC_SIZE
	return true
}

proc update_PARAM_VALUE.CLOCK_DUTY_CYCLE_STABILIZER_EN { PARAM_VALUE.CLOCK_DUTY_CYCLE_STABILIZER_EN } {
	# Procedure called to update CLOCK_DUTY_CYCLE_STABILIZER_EN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CLOCK_DUTY_CYCLE_STABILIZER_EN { PARAM_VALUE.CLOCK_DUTY_CYCLE_STABILIZER_EN } {
	# Procedure called to validate CLOCK_DUTY_CYCLE_STABILIZER_EN
	return true
}

proc update_PARAM_VALUE.DAC_EN { PARAM_VALUE.DAC_EN } {
	# Procedure called to update DAC_EN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DAC_EN { PARAM_VALUE.DAC_EN } {
	# Procedure called to validate DAC_EN
	return true
}


proc update_MODELPARAM_VALUE.ADC_SIZE { MODELPARAM_VALUE.ADC_SIZE PARAM_VALUE.ADC_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ADC_SIZE}] ${MODELPARAM_VALUE.ADC_SIZE}
}

proc update_MODELPARAM_VALUE.ADC_EN { MODELPARAM_VALUE.ADC_EN PARAM_VALUE.ADC_EN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ADC_EN}] ${MODELPARAM_VALUE.ADC_EN}
}

proc update_MODELPARAM_VALUE.CLOCK_DUTY_CYCLE_STABILIZER_EN { MODELPARAM_VALUE.CLOCK_DUTY_CYCLE_STABILIZER_EN PARAM_VALUE.CLOCK_DUTY_CYCLE_STABILIZER_EN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CLOCK_DUTY_CYCLE_STABILIZER_EN}] ${MODELPARAM_VALUE.CLOCK_DUTY_CYCLE_STABILIZER_EN}
}

proc update_MODELPARAM_VALUE.DAC_EN { MODELPARAM_VALUE.DAC_EN PARAM_VALUE.DAC_EN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DAC_EN}] ${MODELPARAM_VALUE.DAC_EN}
}

