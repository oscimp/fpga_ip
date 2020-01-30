TOPLEVEL_LANG ?= vhdl
SIM = ghdl

PWD=$(shell pwd)
WPWD=$(shell pwd)
PLUSARGS=--vcdgz=$(WPWD)/build/waveform.vcdgz --wave=$(WPWD)/build/waveform.ghw

VHDL_SOURCES=$(WPWD)/../hdl/multiplierReal.vhd $(WPWD)/../hdl/multiplierReal_redim.vhd

VHDL_SOURCES+=$(WPWD)/top_multiplierReal.vhd
# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file:
TOPLEVEL=top_multiplierreal
# MODULE is the name of the Python test file:
MODULE=top_multiplierReal_tb
include $(shell cocotb-config --makefiles)/Makefile.inc
include $(shell cocotb-config --makefiles)/Makefile.sim

view:
	gtkwave -a top_multiplierReal.gtkw build/waveform.ghw
