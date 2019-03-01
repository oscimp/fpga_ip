WAVE=gtkwave
VCC=iverilog
VEXEC=vvp
SIMU_DIR=simu
PROJECT=top_cs4344
TESTBENCH_FILE=$(PROJECT)_tb.v
GHDL_FLAGS=
OBJS=../hdl/deltaSigma.v

all: $(PROJECT)

$(PROJECT): $(OBJS) $(TESTBENCH_FILE) 
	echo "$(PROJECT)" >> time.txt
	date >> time.txt
	mkdir -p $(SIMU_DIR)
	$(VCC) -o $(SIMU_DIR)/$@ $^
	$(VEXEC) $(SIMU_DIR)/$@ -lvcd
	echo "end $(PROJECT)" >> time.txt
	date >> time.txt

ghdl-view : $(SIMU_DIR)/$(PROJECT)_tb.vcd
	$(WAVE) $< -a $(PROJECT).gtkw

clean:
	-rm -rf $(SIMU_DIR)
	-rm time.txt
