TOPLEVEL_LANG ?= vhdl
SIM = ghdl

PWD=$(shell pwd)
WPWD=$(shell pwd)
PLUSARGS=--vcdgz=$(WPWD)/build/waveform.vcdgz --wave=$(WPWD)/build/waveform.ghw

VHDL_SOURCES=$(WPWD)/../hdl/mixer_sin.vhd $(WPWD)/../hdl/mixer_redim.vhd

VHDL_SOURCES+=$(WPWD)/top_mixer_sin.vhd
# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file:
TOPLEVEL=top_shiftercomplex
# MODULE is the name of the Python test file:
MODULE=top_mixer_sin_tb
include $(shell cocotb-config --makefiles)/Makefile.inc
include $(shell cocotb-config --makefiles)/Makefile.sim

ghdl_view:
	gtkwave -a top_mixer_sin.gtkw build/waveform.ghw
