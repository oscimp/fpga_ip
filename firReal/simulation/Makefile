PROJECT=top_enable
TESTBENCH_FILE=$(PROJECT)_tb.vhd
SIMTOP =$(PROJECT)_tb

GHDL=ghdl
GHDLFLAGS=--workdir=simu --work=work
GHDLRUNFLAGS=--assert-level=error
GHDL_SIMU_FLAGS = --ieee=synopsys --warn-no-vital-generic --warn-default-binding
FILES=../hdl/firReal_ram.vhd ../hdl/firReal_proc.vhd ../hdl/firReal_top.vhd
FILES+=ram_storage16.vhd  readFromFile.vhd
#FILES=../readFromFile.vhd ../ram_storage16.vhd \
#	../../hdl/firReal_dspmanu.vhd \
#	../../hdl/firReal_reg_delay.vhd \
#	../../hdl/firReal_cpt.vhd \
#	../../hdl/firReal_ram.vhd \
#	../../hdl/firReal_proc.vhd \
#	../../hdl/firReal_global.vhd \
#	../../hdl/firReal_ng_top.vhd
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
force:
