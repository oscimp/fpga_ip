# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  set C_S00_AXI_ADDR_WIDTH [ipgui::add_param $IPINST -name "C_S00_AXI_ADDR_WIDTH" -parent ${Page_0}]
  set_property tooltip {Width of the S_AXI addr bus.} ${C_S00_AXI_ADDR_WIDTH}
  set C_S00_AXI_DATA_WIDTH [ipgui::add_param $IPINST -name "C_S00_AXI_DATA_WIDTH" -parent ${Page_0}]
  set_property tooltip {Width of the S_AXI data bus.} ${C_S00_AXI_DATA_WIDTH}
  set DATA_IN_SIZE [ipgui::add_param $IPINST -name "DATA_IN_SIZE" -parent ${Page_0}]
  set_property tooltip {Size of the input data bus.} ${DATA_IN_SIZE}
  set DATA_OUT_SIZE [ipgui::add_param $IPINST -name "DATA_OUT_SIZE" -parent ${Page_0}]
  set_property tooltip {Size of the output data bus.} ${DATA_OUT_SIZE}
  set DSR [ipgui::add_param $IPINST -name "DSR" -parent ${Page_0}]
  set_property tooltip {Shift applied to D.} ${DSR}
  set D_SIZE [ipgui::add_param $IPINST -name "D_SIZE" -parent ${Page_0}]
  set_property tooltip {Size of D.} ${D_SIZE}
  set ISR [ipgui::add_param $IPINST -name "ISR" -parent ${Page_0}]
  set_property tooltip {Shift applied to I.} ${ISR}
  set I_SIZE [ipgui::add_param $IPINST -name "I_SIZE" -parent ${Page_0}]
  set_property tooltip {Size of I.} ${I_SIZE}
  set PSR [ipgui::add_param $IPINST -name "PSR" -parent ${Page_0}]
  set_property tooltip {Shift applied to P.} ${PSR}
  set P_SIZE [ipgui::add_param $IPINST -name "P_SIZE" -parent ${Page_0}]
  set_property tooltip {Size of P.} ${P_SIZE}


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

proc update_PARAM_VALUE.DATA_OUT_SIZE { PARAM_VALUE.DATA_OUT_SIZE } {
	# Procedure called to update DATA_OUT_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA_OUT_SIZE { PARAM_VALUE.DATA_OUT_SIZE } {
	# Procedure called to validate DATA_OUT_SIZE
	return true
}

proc update_PARAM_VALUE.DSR { PARAM_VALUE.DSR } {
	# Procedure called to update DSR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DSR { PARAM_VALUE.DSR } {
	# Procedure called to validate DSR
	return true
}

proc update_PARAM_VALUE.D_SIZE { PARAM_VALUE.D_SIZE } {
	# Procedure called to update D_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.D_SIZE { PARAM_VALUE.D_SIZE } {
	# Procedure called to validate D_SIZE
	return true
}

proc update_PARAM_VALUE.ISR { PARAM_VALUE.ISR } {
	# Procedure called to update ISR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ISR { PARAM_VALUE.ISR } {
	# Procedure called to validate ISR
	return true
}

proc update_PARAM_VALUE.I_SIZE { PARAM_VALUE.I_SIZE } {
	# Procedure called to update I_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.I_SIZE { PARAM_VALUE.I_SIZE } {
	# Procedure called to validate I_SIZE
	return true
}

proc update_PARAM_VALUE.PSR { PARAM_VALUE.PSR } {
	# Procedure called to update PSR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PSR { PARAM_VALUE.PSR } {
	# Procedure called to validate PSR
	return true
}

proc update_PARAM_VALUE.P_SIZE { PARAM_VALUE.P_SIZE } {
	# Procedure called to update P_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.P_SIZE { PARAM_VALUE.P_SIZE } {
	# Procedure called to validate P_SIZE
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

proc update_MODELPARAM_VALUE.P_SIZE { MODELPARAM_VALUE.P_SIZE PARAM_VALUE.P_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.P_SIZE}] ${MODELPARAM_VALUE.P_SIZE}
}

proc update_MODELPARAM_VALUE.PSR { MODELPARAM_VALUE.PSR PARAM_VALUE.PSR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PSR}] ${MODELPARAM_VALUE.PSR}
}

proc update_MODELPARAM_VALUE.I_SIZE { MODELPARAM_VALUE.I_SIZE PARAM_VALUE.I_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.I_SIZE}] ${MODELPARAM_VALUE.I_SIZE}
}

proc update_MODELPARAM_VALUE.ISR { MODELPARAM_VALUE.ISR PARAM_VALUE.ISR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ISR}] ${MODELPARAM_VALUE.ISR}
}

proc update_MODELPARAM_VALUE.D_SIZE { MODELPARAM_VALUE.D_SIZE PARAM_VALUE.D_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.D_SIZE}] ${MODELPARAM_VALUE.D_SIZE}
}

proc update_MODELPARAM_VALUE.DSR { MODELPARAM_VALUE.DSR PARAM_VALUE.DSR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DSR}] ${MODELPARAM_VALUE.DSR}
}

proc update_MODELPARAM_VALUE.DATA_IN_SIZE { MODELPARAM_VALUE.DATA_IN_SIZE PARAM_VALUE.DATA_IN_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_IN_SIZE}] ${MODELPARAM_VALUE.DATA_IN_SIZE}
}

proc update_MODELPARAM_VALUE.DATA_OUT_SIZE { MODELPARAM_VALUE.DATA_OUT_SIZE PARAM_VALUE.DATA_OUT_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_OUT_SIZE}] ${MODELPARAM_VALUE.DATA_OUT_SIZE}
}

