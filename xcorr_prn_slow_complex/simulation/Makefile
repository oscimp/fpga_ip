PROJECT=top_xcorr_prn_slow_complex
SIMTOP =$(PROJECT)_tb
TESTBENCH_FILE=$(SIMTOP).vhd

GHDL=ghdl
GHDLFLAGS=--workdir=simu --work=work
GHDLRUNFLAGS=--assert-level=error
GHDL_SIMU_FLAGS = --ieee=synopsys --warn-no-vital-generic --warn-default-binding

FILES=../hdl/xcorr_prn_slow_complex_ram.vhd \
	../hdl/xcorr_prn_slow_complex_correl.vhd \
	../hdl/xcorr_prn_slow_complex_mux.vhd \
	../hdl/xcorr_prn_slow_complex.vhd
FILES+=../../cacode/hdl/cacode_g1_gen.vhd  ../../cacode/hdl/cacode_g2_gen.vhd  ../../cacode/hdl/cacode.vhd

SIMDIR=simu

VIEW_CMD = gtkwave

all : run

# Run target
run:$(SIMDIR)/$(SIMTOP).ghw
$(SIMDIR)/$(SIMTOP).ghw: $(SIMDIR)/work-obj93.cf
	$(GHDL) -c $(GHDLFLAGS) -e $(SIMTOP)
	$(GHDL) -c $(GHDLFLAGS) -r $(SIMTOP) $(GHDLRUNFLAGS) \
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
	-rm -rf result.txt
force:
