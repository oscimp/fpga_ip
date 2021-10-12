
VHDL_SOURCES= iir_lpf_real.vhd iir_lpf_real_tb.vhd
SIM_BUILD=sim_build
RTL_LIBRARY ?= work
CMD=/usr/bin/ghdl
TOPLEVEL=iir_lpf_real_tb
COCOTB_RESULTS_FILE=results.txt
PLUSARGS=--vcdgz=sim_build/waveform.vcdgz --wave=sim_build/waveform.ghw
SIM_ARGS=--assert-level=error

all: $(COCOTB_RESULTS_FILE)

$(SIM_BUILD):
	@mkdir -p $(SIM_BUILD)

analyse: $(VHDL_SOURCES) $(CUSTOM_COMPILE_DEPS) | $(SIM_BUILD)
	$(foreach SOURCES_VAR, $(filter VHDL_SOURCES_%, $(.VARIABLES)), \
	$(CMD) -i $(GHDL_ARGS) $(COMPILE_ARGS) --workdir=$(SIM_BUILD) --work=$(SOURCES_VAR:VHDL_SOURCES_%=%) $($(SOURCES_VAR)) && ) \
	$(CMD) -i $(GHDL_ARGS) $(COMPILE_ARGS) --workdir=$(SIM_BUILD) --work=$(RTL_LIBRARY) $(VHDL_SOURCES) && \
	$(CMD) -m $(GHDL_ARGS) $(COMPILE_ARGS) --workdir=$(SIM_BUILD) -P$(SIM_BUILD) --work=$(RTL_LIBRARY) $(TOPLEVEL)

$(COCOTB_RESULTS_FILE): analyse $(CUSTOM_SIM_DEPS)
	-@rm -f $(COCOTB_RESULTS_FILE)

	MODULE=$(MODULE) TESTCASE=$(TESTCASE) TOPLEVEL=$(TOPLEVEL) TOPLEVEL_LANG=$(TOPLEVEL_LANG) \
	$(SIM_CMD_PREFIX) $(CMD) -r $(GHDL_ARGS) --workdir=$(SIM_BUILD) -P$(SIM_BUILD) --work=$(RTL_LIBRARY) $(TOPLEVEL) --vpi=$(shell cocotb-config --lib-name-path vpi ghdl) $(SIM_ARGS) $(PLUSARGS)

	#$(call check_for_results_file)

clean::
	-@rm -rf $(SIM_BUILD) $(COCOTB_RESULTS_FILE)

