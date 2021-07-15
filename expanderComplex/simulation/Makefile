TOPLEVEL_LANG ?= vhdl
SIM = ghdl

PWD=$(shell pwd)
WPWD=$(shell pwd)
PLUSARGS=--vcdgz=$(WPWD)/sim_build/waveform.vcdgz --wave=$(WPWD)/sim_build/waveform.ghw

VHDL_SOURCES=$(WPWD)/../hdl/expanderComplex.vhd

VHDL_SOURCES+=$(WPWD)/top_expanderComplex.vhd
# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file:
TOPLEVEL=top_shiftercomplex
# MODULE is the name of the Python test file:
MODULE=top_expanderComplex_tb
include $(shell cocotb-config --makefiles)/Makefile.sim

ghdl_view:
	gtkwave -a top_expanderComplex.gtkw build/waveform.ghw
