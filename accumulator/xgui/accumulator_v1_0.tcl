# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "NB_ACCUM" -parent ${Page_0}


}

proc update_PARAM_VALUE.NB_ACCUM { PARAM_VALUE.NB_ACCUM } {
	# Procedure called to update NB_ACCUM when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NB_ACCUM { PARAM_VALUE.NB_ACCUM } {
	# Procedure called to validate NB_ACCUM
	return true
}


proc update_MODELPARAM_VALUE.NB_ACCUM { MODELPARAM_VALUE.NB_ACCUM PARAM_VALUE.NB_ACCUM } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NB_ACCUM}] ${MODELPARAM_VALUE.NB_ACCUM}
}

