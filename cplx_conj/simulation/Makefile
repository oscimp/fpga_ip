TOPLEVEL_LANG ?= verilog

PWD=$(shell pwd)
WPWD=$(shell pwd)

VERILOG_SOURCES = $(WPWD)/../hdl/cplx_conj.v

VERILOG_SOURCES+=$(WPWD)/top_dut.v
# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file:
TOPLEVEL=top_dut
# MODULE is the name of the Python test file:
MODULE=top_cplx_conj_simu_tb
include $(shell cocotb-config --makefiles)/Makefile.inc
include $(shell cocotb-config --makefiles)/Makefile.sim

view:
	gtkwave -a top_cplx_conj_simu.gtkw cplx_conj_simu_tb.vcd
