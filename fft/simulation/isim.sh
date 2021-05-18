#!/bin/csh -f
echo Simulation Tool: ISIM
fuse work.top_fft_tb -prj fft.prj -L unisim -L secureip -timeprecision_vhdl fs -o fft
./fft -gui -tclbatch isim.tcl -wdb fft.wdb
echo done

