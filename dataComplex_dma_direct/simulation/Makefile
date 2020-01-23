TOPLEVEL_LANG ?= vhdl
SIM = ghdl

PWD=$(shell pwd)
WPWD=$(shell pwd)
PLUSARGS=--vcdgz=$(WPWD)/build/waveform.vcdgz --wave=$(WPWD)/build/waveform.ghw

VHDL_SOURCES=$(WPWD)/../hdl/axi_dataComplex_dma_direct.vhd \
	$(WPWD)/../../pseudo_gen_trig/hdl/pseudo_gen_trig_logic.vhd \
	$(WPWD)/../../pulseGenDelayed/hdl/pulseGenDelayed_logic.vhd \
	$(WPWD)/../../genPulseTwoWayCplx/hdl/genPulseTwoWayCplx_logic.vhd

VHDL_SOURCES+=$(WPWD)/top_dataDma.vhd
# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file:
TOPLEVEL=top_dut
# MODULE is the name of the Python test file:
MODULE=top_dataDma_tb
include $(shell cocotb-config --makefiles)/Makefile.inc
include $(shell cocotb-config --makefiles)/Makefile.sim

view:
	gtkwave -a top_dataDma.gtkw build/waveform.ghw
