TOPLEVEL_LANG ?= vhdl
SIM = ghdl

PWD=$(shell pwd)
WPWD=$(shell pwd)
PLUSARGS=--vcdgz=$(WPWD)/build/waveform.vcdgz --wave=$(WPWD)/build/waveform.ghw

VHDL_SOURCES=$(WPWD)/../hdl/pwm_logic.vhd $(WPWD)/../hdl/pwm_cpt.vhd
VHDL_SOURCES+=$(WPWD)/top_pwmAxi.vhd

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file:
TOPLEVEL=top_pwmaxi
# MODULE is the name of the Python test file:
MODULE=top_pwmAxi_tb
include $(shell cocotb-config --makefiles)/Makefile.inc
include $(shell cocotb-config --makefiles)/Makefile.sim

view:
	gtkwave -a top_pwmAxi.gtkw build/waveform.ghw
