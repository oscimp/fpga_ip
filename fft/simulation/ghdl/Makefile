PROJECT=top_fft
TESTBENCH_FILE=../$(PROJECT)_tb.vhd
SIMTOP =$(PROJECT)_tb

GHDL=ghdl
GHDLFLAGS=--workdir=simu --work=work
GHDLRUNFLAGS=--assert-level=error
GHDL_SIMU_FLAGS = --ieee=synopsys --warn-no-vital-generic --warn-default-binding
FILES=../../hdl/fft_ram.vhd ../../hdl/fft_ram_coeff.vhd \
../../hdl/fft_coeff_handler.vhd ../../hdl/fft_comp_complex.vhd \
../../hdl/fft_data_handler.vhd ../../hdl/fft_comp_butterfly.vhd \
../readComplexFromFile.vhd ../readFromFile.vhd ../ram_storage16.vhd \
../../hdl/fft_transfert.vhd\
../../hdl/fft_loop_radix.vhd ../../hdl/fft_loop_stage.vhd ../../hdl/fft_top_logic.vhd

SIMDIR=simu

VIEW_CMD = gtkwave

all : run

# Run target
run:$(SIMDIR)/$(SIMTOP).ghw
$(SIMDIR)/$(SIMTOP).ghw: $(SIMDIR)/work-obj93.cf
	$(GHDL) -c $(GHDLFLAGS) -v -e $(SIMTOP)
	$(GHDL) -c $(GHDLFLAGS) -v -r $(SIMTOP) $(GHDLRUNFLAGS) \
		--vcdgz=$(SIMDIR)/$(SIMTOP).vcdgz --wave=$(SIMDIR)/$(SIMTOP).ghw

# Targets to analyze libraries
$(SIMDIR)/work-obj93.cf:$(FILES) $(TESTBENCH_FILE)
	mkdir -p $(SIMDIR)
	$(GHDL) -a $(GHDLFLAGS) $(GHDL_SIMU_FLAGS) $(FILES) $(TESTBENCH_FILE)

ghdl-view: $(SIMDIR)/$(SIMTOP).ghw
	$(VIEW_CMD) $(SIMDIR)/$(SIMTOP).ghw -a $(PROJECT).gtkw

clean:
	$(GHDL) --clean --workdir=simu
	-rm -rf simu
force:
