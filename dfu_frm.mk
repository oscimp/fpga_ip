IP?=192.168.2.1 # must be changed in settings.sh

OUTPUT_DIR=$(BR_DIR)/output
export HOST_DIR=$(OUTPUT_DIR)/host
IMG_DIR=$(OUTPUT_DIR)/images
dirname = $(patsubst %/,%,$(dir $1))
DESIGN_DIR=$(notdir $(call dirname,$(CURDIR)))
dirname = $(shell pwd)

ifeq ($(BOARD_NAME), plutosdr)
BIT_FILE=$(dirname)/*.runs/impl_1/*.bit
else
BIT_FILE=$(dirname)/tmp/*.runs/impl_1/*.bit
endif

test:
	echo $(BOARD_NAME)

POST_SCRIPT=$(shell grep '^BR2_ROOTFS_POST_IMAGE_SCRIPT' $(BR_DIR)/.config 2>/dev/null | cut -d \" -f 2)
IS_ABS_PATH=$(shell echo '${POST_SCRIPT}' | grep -o "\$\{.*\}")

# if post_image refer to a variable -> br2_external
ifneq ($(IS_ABS_PATH),)
	# include mk build by buildroot with all br2_external variables
	include $(OUTPUT_DIR)/.br*-external.mk
endif
ifeq ($(BOARD_NAME),plutosdr)
POST_SCRIPT=$(BR2_EXTERNAL_PLUTOSDR_PATH)/board/pluto/post_image.sh
endif

.PHONY: image dfu_frm flash_dfu_frm
image:
	mkdir -p image

dfu_frm: |image
	cp $(IMG_DIR)/*.dtb $(IMG_DIR)/rootfs* $(IMG_DIR)/zImage $(BIT_FILE) ./image/
	$(POST_SCRIPT) ./image

flash_dfu_frm:
	ssh root@$(IP) "device_reboot sf"; sleep 10;
	sudo dfu-util -R -D image/*.dfu -a firmware.dfu
