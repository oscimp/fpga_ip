PROJECT=top_clock_prescaler
SIMTOP =$(PROJECT)_tb
TESTBENCH_FILE=$(SIMTOP).vhd

#GHDL=/home/gwe/apps/ghdl/bin/ghdl
GHDL=ghdl
GHDLFLAGS=--workdir=simu --work=work
GHDLRUNFLAGS=--assert-level=error
GHDL_SIMU_FLAGS = -fexplicit --ieee=synopsys --warn-no-vital-generic --warn-default-binding

FILES=../hdl/clock_prescaler.vhd

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
	-rm -f result.txt
force:
