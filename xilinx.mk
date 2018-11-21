DEPS += $(BASE_TCL)

VIVADO := vivado -nolog -nojournal -mode batch -source
HSI := hsi -nolog -nojournal -mode batch

TARGET_PRJ=tmp/$(NAME).xpr
BIT_FILE=tmp/$(NAME).runs/impl_1/$(NAME)_wrapper.bit
BIN_FILE=$(NAME)_wrapper.bit.bin
BIF_FILE=$(NAME).bif

INSTALL_DIR=$(OSCIMP_DIGITAL_NFS)/$(BOARD_NAME)/$(NAME)/bitstreams

.PHONY: all clean clean-all clean-trash
all: $(BIN_FILE)

$(BIT_FILE): $(DEPS) 
	-rm -rf tmp
	$(VIVADO) $(BASE_TCL)

%.bin: $(BIT_FILE)
	@rm -f $(BIF_FILE) $(BIN_FILE)
	@echo "all:" >> $(BIF_FILE)
	@echo "{" >> $(BIF_FILE)
	@echo "	$(BIT_FILE)" >> $(BIF_FILE)
	@echo "}" >> $(BIF_FILE)

	bootgen -w -image $(NAME).bif -arch zynq -process_bitstream bin
	mv $(BIT_FILE).bin .
	@rm -f $(BIF_FILE)

force_bin:
	@rm -f $(BIF_FILE) $(BIN_FILE)
	@echo "all:" >> $(BIF_FILE)
	@echo "{" >> $(BIF_FILE)
	@echo "	$(BIT_FILE)" >> $(BIF_FILE)
	@echo "}" >> $(BIF_FILE)

	bootgen -w -image $(NAME).bif -arch zynq -process_bitstream bin
	mv $(BIT_FILE).bin .
	@rm -f $(BIF_FILE)

install:$(BIN_FILE)
	if [ ! -d $(INSTALL_DIR) ]; then mkdir -p $(INSTALL_DIR); fi
	cp $(BIN_FILE) $(INSTALL_DIR)

force_install:
	if [ ! -d $(INSTALL_DIR) ]; then mkdir -p $(INSTALL_DIR); fi
	cp $(BIN_FILE) $(INSTALL_DIR)

clean: clean-all
clean-all: clean-trash
	-rm -rf $(BIN_FILE) $(NAME)
	-rm -f $(BIF_FILE)

clean-trash:
	rm -rf tmp
	rm -rf *.log *.jou .Xil *.zip *.str
