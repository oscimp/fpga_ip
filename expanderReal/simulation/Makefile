TOPLEVEL_LANG ?= vhdl
SIM = ghdl

PWD=$(shell pwd)
WPWD=$(shell pwd)
PLUSARGS=--vcdgz=$(WPWD)/sim_build/waveform.vcdgz --wave=$(WPWD)/sim_build/waveform.ghw

VHDL_SOURCES=$(WPWD)/../hdl/expanderReal.vhd

VHDL_SOURCES+=$(WPWD)/top_expanderReal.vhd
# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file:
TOPLEVEL=top_expanderreal
# MODULE is the name of the Python test file:
MODULE=top_expanderReal_tb
include $(shell cocotb-config --makefiles)/Makefile.sim

ghdl_view:
	gtkwave -a top_expanderReal.gtkw build/waveform.ghw
