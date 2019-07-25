# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  set C_S00_AXI_ADDR_WIDTH [ipgui::add_param $IPINST -name "C_S00_AXI_ADDR_WIDTH" -parent ${Page_0}]
  set_property tooltip {Width of the S_AXI addr bus.} ${C_S00_AXI_ADDR_WIDTH}
  set C_S00_AXI_DATA_WIDTH [ipgui::add_param $IPINST -name "C_S00_AXI_DATA_WIDTH" -parent ${Page_0}]
  set_property tooltip {Width of the S_AXI data bus.} ${C_S00_AXI_DATA_WIDTH}
  set DATAA_DEFAULT_OUT [ipgui::add_param $IPINST -name "DATAA_DEFAULT_OUT" -parent ${Page_0}]
  set_property tooltip {Default DataA value.} ${DATAA_DEFAULT_OUT}
  set DATAA_EN_ALWAYS_HIGH [ipgui::add_param $IPINST -name "DATAA_EN_ALWAYS_HIGH" -parent ${Page_0}]
  set_property tooltip {DataA Enable State Always High.} ${DATAA_EN_ALWAYS_HIGH}
  set DATAB_DEFAULT_OUT [ipgui::add_param $IPINST -name "DATAB_DEFAULT_OUT" -parent ${Page_0}]
  set_property tooltip {Default DataB value.} ${DATAB_DEFAULT_OUT}
  set DATAB_EN_ALWAYS_HIGH [ipgui::add_param $IPINST -name "DATAB_EN_ALWAYS_HIGH" -parent ${Page_0}]
  set_property tooltip {DataB Enable State Always High.} ${DATAB_EN_ALWAYS_HIGH}
  set DATA_SIZE [ipgui::add_param $IPINST -name "DATA_SIZE" -parent ${Page_0}]
  set_property tooltip {Size of data bus.} ${DATA_SIZE}
  set SYNCHRONIZE_CHAN [ipgui::add_param $IPINST -name "SYNCHRONIZE_CHAN" -parent ${Page_0}]
  set_property tooltip {Synchronize channels.} ${SYNCHRONIZE_CHAN}
  set id [ipgui::add_param $IPINST -name "id" -parent ${Page_0}]
  set_property tooltip {Unique Id.} ${id}


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

proc update_PARAM_VALUE.DATAA_DEFAULT_OUT { PARAM_VALUE.DATAA_DEFAULT_OUT } {
	# Procedure called to update DATAA_DEFAULT_OUT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATAA_DEFAULT_OUT { PARAM_VALUE.DATAA_DEFAULT_OUT } {
	# Procedure called to validate DATAA_DEFAULT_OUT
	return true
}

proc update_PARAM_VALUE.DATAA_EN_ALWAYS_HIGH { PARAM_VALUE.DATAA_EN_ALWAYS_HIGH } {
	# Procedure called to update DATAA_EN_ALWAYS_HIGH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATAA_EN_ALWAYS_HIGH { PARAM_VALUE.DATAA_EN_ALWAYS_HIGH } {
	# Procedure called to validate DATAA_EN_ALWAYS_HIGH
	return true
}

proc update_PARAM_VALUE.DATAB_DEFAULT_OUT { PARAM_VALUE.DATAB_DEFAULT_OUT } {
	# Procedure called to update DATAB_DEFAULT_OUT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATAB_DEFAULT_OUT { PARAM_VALUE.DATAB_DEFAULT_OUT } {
	# Procedure called to validate DATAB_DEFAULT_OUT
	return true
}

proc update_PARAM_VALUE.DATAB_EN_ALWAYS_HIGH { PARAM_VALUE.DATAB_EN_ALWAYS_HIGH } {
	# Procedure called to update DATAB_EN_ALWAYS_HIGH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATAB_EN_ALWAYS_HIGH { PARAM_VALUE.DATAB_EN_ALWAYS_HIGH } {
	# Procedure called to validate DATAB_EN_ALWAYS_HIGH
	return true
}

proc update_PARAM_VALUE.DATA_SIZE { PARAM_VALUE.DATA_SIZE } {
	# Procedure called to update DATA_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA_SIZE { PARAM_VALUE.DATA_SIZE } {
	# Procedure called to validate DATA_SIZE
	return true
}

proc update_PARAM_VALUE.SYNCHRONIZE_CHAN { PARAM_VALUE.SYNCHRONIZE_CHAN } {
	# Procedure called to update SYNCHRONIZE_CHAN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SYNCHRONIZE_CHAN { PARAM_VALUE.SYNCHRONIZE_CHAN } {
	# Procedure called to validate SYNCHRONIZE_CHAN
	return true
}

proc update_PARAM_VALUE.id { PARAM_VALUE.id } {
	# Procedure called to update id when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.id { PARAM_VALUE.id } {
	# Procedure called to validate id
	return true
}


proc update_MODELPARAM_VALUE.DATA_SIZE { MODELPARAM_VALUE.DATA_SIZE PARAM_VALUE.DATA_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_SIZE}] ${MODELPARAM_VALUE.DATA_SIZE}
}

proc update_MODELPARAM_VALUE.DATAA_DEFAULT_OUT { MODELPARAM_VALUE.DATAA_DEFAULT_OUT PARAM_VALUE.DATAA_DEFAULT_OUT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATAA_DEFAULT_OUT}] ${MODELPARAM_VALUE.DATAA_DEFAULT_OUT}
}

proc update_MODELPARAM_VALUE.DATAA_EN_ALWAYS_HIGH { MODELPARAM_VALUE.DATAA_EN_ALWAYS_HIGH PARAM_VALUE.DATAA_EN_ALWAYS_HIGH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATAA_EN_ALWAYS_HIGH}] ${MODELPARAM_VALUE.DATAA_EN_ALWAYS_HIGH}
}

proc update_MODELPARAM_VALUE.DATAB_DEFAULT_OUT { MODELPARAM_VALUE.DATAB_DEFAULT_OUT PARAM_VALUE.DATAB_DEFAULT_OUT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATAB_DEFAULT_OUT}] ${MODELPARAM_VALUE.DATAB_DEFAULT_OUT}
}

proc update_MODELPARAM_VALUE.DATAB_EN_ALWAYS_HIGH { MODELPARAM_VALUE.DATAB_EN_ALWAYS_HIGH PARAM_VALUE.DATAB_EN_ALWAYS_HIGH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATAB_EN_ALWAYS_HIGH}] ${MODELPARAM_VALUE.DATAB_EN_ALWAYS_HIGH}
}

proc update_MODELPARAM_VALUE.SYNCHRONIZE_CHAN { MODELPARAM_VALUE.SYNCHRONIZE_CHAN PARAM_VALUE.SYNCHRONIZE_CHAN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SYNCHRONIZE_CHAN}] ${MODELPARAM_VALUE.SYNCHRONIZE_CHAN}
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

