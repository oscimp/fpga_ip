VIVADO := vivado -mode batch -source
IP_CORE_VERSION := 1.0

configs = ip

all: $(configs)

$(configs):
	mkdir -p $@
	./gen_hdl.py $@/ddmtd
	cd $@ && IP_CORE_VERSION=$(IP_CORE_VERSION) $(VIVADO) ../package_ip.tcl

clean:
	rm -rf $(configs)

.PHONY: all clean $(configs)
