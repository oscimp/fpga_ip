# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "USE_FIRST_BUFF" -parent ${Page_0}
  ipgui::add_param $IPINST -name "USE_SEC_BUFF" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DATA_IN_SIZE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DATA_SIZE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "SHIFT_VAL" -parent ${Page_0}
  ipgui::add_param $IPINST -name "LOG_2_N_FFT" -parent ${Page_0}
  ipgui::add_param $IPINST -name "USE_EOF" -parent ${Page_0}

  ipgui::add_param $IPINST -name "C_S00_AXI_DATA_WIDTH"
  ipgui::add_param $IPINST -name "C_S00_AXI_ADDR_WIDTH"

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

proc update_PARAM_VALUE.DATA_IN_SIZE { PARAM_VALUE.DATA_IN_SIZE } {
	# Procedure called to update DATA_IN_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA_IN_SIZE { PARAM_VALUE.DATA_IN_SIZE } {
	# Procedure called to validate DATA_IN_SIZE
	return true
}

proc update_PARAM_VALUE.DATA_SIZE { PARAM_VALUE.DATA_SIZE } {
	# Procedure called to update DATA_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA_SIZE { PARAM_VALUE.DATA_SIZE } {
	# Procedure called to validate DATA_SIZE
	return true
}

proc update_PARAM_VALUE.LOG_2_N_FFT { PARAM_VALUE.LOG_2_N_FFT } {
	# Procedure called to update LOG_2_N_FFT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.LOG_2_N_FFT { PARAM_VALUE.LOG_2_N_FFT } {
	# Procedure called to validate LOG_2_N_FFT
	return true
}

proc update_PARAM_VALUE.SHIFT_VAL { PARAM_VALUE.SHIFT_VAL } {
	# Procedure called to update SHIFT_VAL when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SHIFT_VAL { PARAM_VALUE.SHIFT_VAL } {
	# Procedure called to validate SHIFT_VAL
	return true
}

proc update_PARAM_VALUE.USE_EOF { PARAM_VALUE.USE_EOF } {
	# Procedure called to update USE_EOF when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.USE_EOF { PARAM_VALUE.USE_EOF } {
	# Procedure called to validate USE_EOF
	return true
}

proc update_PARAM_VALUE.USE_FIRST_BUFF { PARAM_VALUE.USE_FIRST_BUFF } {
	# Procedure called to update USE_FIRST_BUFF when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.USE_FIRST_BUFF { PARAM_VALUE.USE_FIRST_BUFF } {
	# Procedure called to validate USE_FIRST_BUFF
	return true
}

proc update_PARAM_VALUE.USE_SEC_BUFF { PARAM_VALUE.USE_SEC_BUFF } {
	# Procedure called to update USE_SEC_BUFF when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.USE_SEC_BUFF { PARAM_VALUE.USE_SEC_BUFF } {
	# Procedure called to validate USE_SEC_BUFF
	return true
}


proc update_MODELPARAM_VALUE.LOG_2_N_FFT { MODELPARAM_VALUE.LOG_2_N_FFT PARAM_VALUE.LOG_2_N_FFT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.LOG_2_N_FFT}] ${MODELPARAM_VALUE.LOG_2_N_FFT}
}

proc update_MODELPARAM_VALUE.SHIFT_VAL { MODELPARAM_VALUE.SHIFT_VAL PARAM_VALUE.SHIFT_VAL } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SHIFT_VAL}] ${MODELPARAM_VALUE.SHIFT_VAL}
}

proc update_MODELPARAM_VALUE.DATA_SIZE { MODELPARAM_VALUE.DATA_SIZE PARAM_VALUE.DATA_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_SIZE}] ${MODELPARAM_VALUE.DATA_SIZE}
}

proc update_MODELPARAM_VALUE.DATA_IN_SIZE { MODELPARAM_VALUE.DATA_IN_SIZE PARAM_VALUE.DATA_IN_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_IN_SIZE}] ${MODELPARAM_VALUE.DATA_IN_SIZE}
}

proc update_MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S00_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S00_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.USE_FIRST_BUFF { MODELPARAM_VALUE.USE_FIRST_BUFF PARAM_VALUE.USE_FIRST_BUFF } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.USE_FIRST_BUFF}] ${MODELPARAM_VALUE.USE_FIRST_BUFF}
}

proc update_MODELPARAM_VALUE.USE_SEC_BUFF { MODELPARAM_VALUE.USE_SEC_BUFF PARAM_VALUE.USE_SEC_BUFF } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.USE_SEC_BUFF}] ${MODELPARAM_VALUE.USE_SEC_BUFF}
}

proc update_MODELPARAM_VALUE.USE_EOF { MODELPARAM_VALUE.USE_EOF PARAM_VALUE.USE_EOF } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.USE_EOF}] ${MODELPARAM_VALUE.USE_EOF}
}

