include $(OSCIMP_DIGITAL_IP)/boards.def

# convert all files in absolute
V_SRC        = $(realpath $(V_LIST))
V_SRC       += $(realpath $(V_LIST_$(BOARD_NAME)))
VHDL_SRC     = $(realpath $(VHDL_LIST))
VHDL_SRC    += $(realpath $(VHDL_LIST_$(BOARD_NAME)))
REAL_CONSTR  = $(realpath $(CONSTR))
REAL_CONSTR	+= $(realpath $(CONSTR_$(BOARD_NAME)))
TCL_SRC      = $(realpath $(TCL_LIST))
TCL_SRC     += $(realpath $(TCL_LIST_$(BOARD_NAME)))

# files
SRC          = $(V_SRC) $(VHDL_SRC)

# to generate ipx file with all IPs available
# in all repositories we need to provides a list with ','
# to ip-make-ipx
IP_REPO     += $(OSCIMP_DIGITAL_IP)
IP_TMP       = $(shell realpath --relative-to=. $(IP_REPO))
IP_PATH      = $(shell echo $(IP_TMP) | tr ' ' ',')

INSTALL_DIR  = $(OSCIMP_DIGITAL_NFS)/$(BOARD_NAME)/$(PRJ)/bitstreams/

-include $(OSCIMP_DIGITAL_IP)/$(TOOLS).mk

tmp:
	mkdir -p $@

force_install:
install:$(BIN_FILE)
	if [ ! -d $(INSTALL_DIR) ]; then mkdir -p $(INSTALL_DIR); fi
	cp $(TARGET_BIN) $(INSTALL_DIR)

force_install:
	if [ ! -d $(INSTALL_DIR) ]; then mkdir -p $(INSTALL_DIR); fi
	cp $(TARGET_BIN) $(INSTALL_DIR)

clean:
	@rm -rf tmp
	@rm -rf $(CLEAN_FILES)
