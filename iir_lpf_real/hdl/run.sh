PROJECT=iir_lpf_real

ghdl -c ${PROJECT}.vhd
ghdl -a ${PROJECT}.vhd
ghdl -e ${PROJECT}

ghdl -c ${PROJECT}_tb.vhd
ghdl -a ${PROJECT}_tb.vhd
ghdl -e ${PROJECT}_tb
ghdl -r ${PROJECT}_tb --assert-level=error --vcd=${PROJECT}_tb.vcd 
