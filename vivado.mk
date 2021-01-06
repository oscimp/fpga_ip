VIVADO := vivado -nolog -nojournal -mode batch -source
HSI := hsi -nolog -nojournal -mode batch

CLEAN_FILES = *.log *.jou .Xil *.zip *.str

PRJ_FILE  = tmp/$(PRJ).xpr
ifeq ($(USE_BD), y)
OUT_FILE    = tmp/$(PRJ).runs/impl_1/$(PRJ)_wrapper
else
OUT_FILE    = tmp/$(PRJ).runs/impl_1/$(PRJ)
endif
BIT_FILE    = $(OUT_FILE).bit
BIN_FILE    = $(OUT_FILE).bit.bin
TARGET_BIN  = $(OUT_FILE).$(OUT_BIN)
BIF_FILE    = tmp/$(PRJ).bif

.PHONY: all clean
all: $(TARGET_BIN)

$(PRJ_FILE): $(TCL_SRC) | tmp
	$(VIVADO) $(OSCIMP_DIGITAL_IP)/scripts/xil_create_prj.tcl \
		-tclargs $(PRJ) $(PRJ) $(BOARD_NAME) $(PART) $(PRJ_PRESET) \
		$(BD_PRESET) $(IP_PATH) $(USE_BD) $(SRC) $(TCL_SRC) $(REAL_CONSTR)
xpr:$(PRJ_FILE)
project:xpr

$(BIT_FILE): $(PRJ_FILE) $(SRC) | tmp
	$(VIVADO) $(OSCIMP_DIGITAL_IP)/scripts/xil_gen.tcl -tclargs $(PRJ)
bit:$(BIT_FILE)

$(BIF_FILE):
	@rm -f $@ $(BIN_FILE)
	@echo "all:" >> $@
	@echo "{" >> $@
	@echo "	$(BIT_FILE)" >> $@
	@echo "}" >> $@

%.bin: $(BIT_FILE) $(BIF_FILE) | tmp
	bootgen -w -image $(BIF_FILE) -arch zynq -process_bitstream bin
	@mv $(BIN_FILE) .

force_bin: $(BIF_FILE)
	bootgen -w -image $(BIF_FILE) -arch zynq -process_bitstream bin
	@mv $(BIN_FILE) .

xml:$(PRJ_FILE)
	$(VIVADO) $(OSCIMP_DIGITAL_IP)/scripts/gen_module_generator_xml.tcl -tclargs tmp $(PRJ)
