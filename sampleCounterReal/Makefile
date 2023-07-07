M_DEPS += $(wildcard hdl/*.vhd)
M_DEPS += $(wildcard hdl/*.v)


M_VIVADO := vivado -mode batch -source

M_FLIST := *.cache
M_FLIST += *.data
M_FLIST += *.xpr
M_FLIST += *.log
M_FLIST += *.jou
M_FLIST += *.ip_user_files
M_FLIST += *.srcs
M_FLIST += *.hw
M_FLIST += *.sim *.runs
M_FLIST += *.zip
M_FLIST += .Xil
M_FLIST += tmp

M_FLIST2 += component.xml
M_FLIST2 += xgui

.PHONY: all clean clean-all
all: component.xml

clean:clean-all

clean-all:
	rm -rf $(M_FLIST) $(M_FLIST2)

clean-trash:
	rm -rf $(M_FLIST)

component.xml: $(M_DEPS) $(OSCIMP_DIGITAL_IP)/scripts/core_ip.tcl ./core_config.tcl
	-rm -rf $(M_FLIST)
	$(M_VIVADO) core_config.tcl

