TOPLEVEL_LANG ?= vhdl
SIM ?= ghdl

PWD=$(shell pwd)
WPWD=$(shell pwd)

VHDL_SOURCES = $(WPWD)/../hdl/add_constReal_logic.vhd

VHDL_SOURCES += $(WPWD)/top_dut.vhd

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file:
TOPLEVEL=top_dut
# MODULE is the name of the Python test file:
MODULE=top_add_constReal_tb

PLUSARGS=--vcdgz=$(WPWD)/sim_build/waveform.vcdgz --wave=$(WPWD)/sim_build/waveform.ghw

include $(shell cocotb-config --makefiles)/Makefile.sim

view:
	gtkwave -a top_add_constReal.gtkw $(VCD)
