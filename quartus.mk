# constants
PRJ_FILE    = tmp/$(PRJ).qpf
BINARY_FILE = tmp/$(PRJ).sof
RBF_FILE    = tmp/$(PRJ).rbf
SVF_FILE    = tmp/$(PRJ).svf
JIC_FILE    = tmp/$(PRJ).jic
RDP_FILE    = tmp/$(PRJ)_auto.rpd
TARGET_BIN  = tmp/$(PRJ).$(OUT_BIN)

TCK_FREQ="12.0MHz"

CLEAN_FILES = .qsys_edit

# convert all files in absolute
SDC_SRC     = $(realpath $(SDC))

# files
SRC        += $(SDC_SRC)
# add quartus board preset
SRC        += $(PRJ_PRESET)

# QSYS
ifeq ($(USE_QSYS),y)
QSYS_PREPARE  = tmp/qsys_loader.tcl
TOP          ?= $(PRJ)_qsys
SRC          += $(PWD)/tmp/$(TOP)/synthesis/$(TOP).qip
else
TOP          ?= $(PRJ)
endif

# script used to build project base
BASE_SCRIPT = $(OSCIMP_DIGITAL_IP)/scripts/alt_create_prj.tcl

all: $(TARGET_BIN)

test:
	@echo $(TCL_LIST)
	@echo $(TOP)
	@echo $(USE_QSYS)
	@echo $(SRC_QSYS)

# to avoid adding every time ip repository to quartus/qsys
# configuration files we create an local ipx with all available
# IP.
tmp/user_components.ipx: |tmp
	ip-make-ipx --source_directory=$(IP_PATH) --output=$@ --thorough-descent

$(BINARY_FILE): tmp/.prj_create $(SRC)
	quartus_sh -t $(OSCIMP_DIGITAL_IP)/scripts/alt_gen.tcl $(PRJ) $(USE_QSYS) $(FAMILY) $(PART)

tmp/.prj_create: $(PRJ_QSYS) $(PRJ_FILE)
	touch tmp/.prj_create
project:tmp/.prj_create

$(PRJ_FILE): $(QSYS_PREPARE) Makefile $(OSCIMP_DIGITAL_IP)/quartus.mk | tmp
	quartus_sh -t $(BASE_SCRIPT) $(PRJ) $(TOP) $(USE_QSYS) $(FAMILY) $(PART) $(REAL_CONSTR) $(SRC)
qpf:$(PRJ_FILE)

# qsys has a bit limited TCL support
# so we generates a top tcl as WA
tmp/qsys_loader.tcl: $(TCL_SRC) tmp/user_components.ipx | tmp
	@rm -f $@
	@echo "package require qsys" > $@
	@echo "# module properties ('module' here means 'system' or 'top level module')" >> $@
	@echo "set_module_property NAME {$(TOP)}" >> $@
	@echo "set_module_property GENERATION_ID {0x00000000}" >> $@
	@echo "source $(OSCIMP_DIGITAL_IP)/scripts/alt_prj.tcl" >> $@
	@echo "source $(BD_PRESET)" >> $@
	$(foreach TCL,$(TCL_SRC),@echo "source $(TCL)" >> $@;)
	@echo "save_system ${TOP}.qsys" >> $@

# convert sof to other format
$(RBF_FILE):$(BINARY_FILE)
	quartus_cpf  --option=bitstream_compression=on -c $(BINARY_FILE) $(RBF_FILE)
force_rbf:
	quartus_cpf  --option=bitstream_compression=on -c $(BINARY_FILE) $(RBF_FILE)
$(RDP_FILE):$(BINARY_FILE)
	quartus_cpf -o auto_create_rpd=on -c -d $(FLASH_MODEL) -s $(PART) $(BINARY_FILE) $(JIC_FILE)
force_rpd:
	quartus_cpf -o auto_create_rpd=on -c -d $(FLASH_MODEL) -s $(PART) $(BINARY_FILE) $(JIC_FILE)
$(SVF_FILE):$(BINARY_FILE)
	quartus_cpf -c -q $(TCK_FREQ) -g 3.3 -n p $(BINARY_FILE) $(SVF_FILE)

rbf: $(RBF_FILE)
rpd: $(RDP_FILE)
svf: $(SVF_FILE)

xml: |tmp
	qsys-script --script=$(OSCIMP_DIGITAL_IP)/scripts/gen_module_generator_xml_quartus.tcl \
		-system-file=tmp/$(TOP).qsys
# flash or install bitstream
flash_rpd: rpd
	cycloader -b $(BOARD_NAME) $(RDP_FILE)
flash_svf: svf
	cycloader -b $(BOARD_NAME) $(SVF_FILE)
