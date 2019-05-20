# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  set IN_SIZE [ipgui::add_param $IPINST -name "IN_SIZE" -parent ${Page_0}]
  set_property tooltip {Input Size.} ${IN_SIZE}
  set LENGTH [ipgui::add_param $IPINST -name "LENGTH" -parent ${Page_0}]
  set_property tooltip {Xcorr Length.} ${LENGTH}
  ipgui::add_param $IPINST -name "NB_BLK" -parent ${Page_0}
  set OUT_SIZE [ipgui::add_param $IPINST -name "OUT_SIZE" -parent ${Page_0}]
  set_property tooltip {Output Size.} ${OUT_SIZE}


}

proc update_PARAM_VALUE.IN_SIZE { PARAM_VALUE.IN_SIZE } {
	# Procedure called to update IN_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.IN_SIZE { PARAM_VALUE.IN_SIZE } {
	# Procedure called to validate IN_SIZE
	return true
}

proc update_PARAM_VALUE.LENGTH { PARAM_VALUE.LENGTH } {
	# Procedure called to update LENGTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.LENGTH { PARAM_VALUE.LENGTH } {
	# Procedure called to validate LENGTH
	return true
}

proc update_PARAM_VALUE.NB_BLK { PARAM_VALUE.NB_BLK } {
	# Procedure called to update NB_BLK when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NB_BLK { PARAM_VALUE.NB_BLK } {
	# Procedure called to validate NB_BLK
	return true
}

proc update_PARAM_VALUE.OUT_SIZE { PARAM_VALUE.OUT_SIZE } {
	# Procedure called to update OUT_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.OUT_SIZE { PARAM_VALUE.OUT_SIZE } {
	# Procedure called to validate OUT_SIZE
	return true
}


proc update_MODELPARAM_VALUE.NB_BLK { MODELPARAM_VALUE.NB_BLK PARAM_VALUE.NB_BLK } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NB_BLK}] ${MODELPARAM_VALUE.NB_BLK}
}

proc update_MODELPARAM_VALUE.LENGTH { MODELPARAM_VALUE.LENGTH PARAM_VALUE.LENGTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.LENGTH}] ${MODELPARAM_VALUE.LENGTH}
}

proc update_MODELPARAM_VALUE.IN_SIZE { MODELPARAM_VALUE.IN_SIZE PARAM_VALUE.IN_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.IN_SIZE}] ${MODELPARAM_VALUE.IN_SIZE}
}

proc update_MODELPARAM_VALUE.OUT_SIZE { MODELPARAM_VALUE.OUT_SIZE PARAM_VALUE.OUT_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.OUT_SIZE}] ${MODELPARAM_VALUE.OUT_SIZE}
}

