PROJECT=top_nco_counter
TESTBENCH_FILE=$(PROJECT)_tb.vhd
SIMTOP =$(PROJECT)_tb

GHDL=ghdl
GHDL_VERSION=$(shell ghdl --version |grep "code generator"|cut -d' ' -f2)
ifeq ($(GHDL_VERSION),mcode)
	RUN_CMD=$(GHDL) -c $(GHDLFLAGS) -r $(SIMTOP) $(GHDLRUNFLAGS)
else ifeq ($(GHDL_VERSION),GCC)
	RUN_CMD=./$(SIMTOP) $(GHDLRUNFLAGS)
endif
GHDLFLAGS=--workdir=simu --work=work
GHDLRUNFLAGS=--assert-level=error
GHDL_SIMU_FLAGS = --ieee=synopsys --warn-no-vital-generic --warn-default-binding
FILES=../hdl/nco_counter_cos_rom.vhd \
	../hdl/nco_counter_cos_rom_a12_d16.vhd \
	../hdl/nco_counter_cos_rom_a16_d16.vhd \
	../hdl/nco_counter_logic.vhd
SIMDIR=simu

VIEW_CMD = gtkwave

all : run

# Run target
run:$(SIMDIR)/$(SIMTOP).ghw
$(SIMDIR)/$(SIMTOP).ghw: $(SIMDIR)/work-obj93.cf
	$(GHDL) -c $(GHDLFLAGS) -e $(SIMTOP)
	$(RUN_CMD) --vcdgz=$(SIMDIR)/$(SIMTOP).vcdgz --wave=$(SIMDIR)/$(SIMTOP).ghw

# Targets to analyze libraries
$(SIMDIR)/work-obj93.cf:$(FILES) $(TESTBENCH_FILE)
	mkdir -p $(SIMDIR)
	$(GHDL) -a $(GHDLFLAGS) $(GHDL_SIMU_FLAGS) $(FILES) $(TESTBENCH_FILE)

ghdl-view: $(SIMDIR)/$(SIMTOP).ghw
	$(VIEW_CMD) $(SIMDIR)/$(SIMTOP).ghw -a $(PROJECT).gtkw

clean:
	-$(GHDL) --clean --workdir=simu
	-rm -rf simu
	-rm -f *.txt
force:
