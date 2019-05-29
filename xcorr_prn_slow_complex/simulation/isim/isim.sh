#!/bin/csh -f
echo Simulation Tool: ISIM
fuse work.top_xcorr_prn_slow_complex_tb -prj xcorr_prn_slow_complex.prj -L unisim -L secureip -timeprecision_vhdl fs -o xcorr_prn_slow_complex
./xcorr_prn_slow_complex -gui -tclbatch isim.tcl -wdb xcorr_prn_slow_complex.wdb
#./xcorr_prn_slow_complex -gui -tclbatch isim.tcl -wdb xcorr_prn_slow_complex.wdb
echo done

