#!/bin/csh -f
echo Simulation Tool: ISIM
fuse work.top_xcorr_gps_slow_complex_tb -prj xcorr_gps_slow_complex.prj -L unisim -L secureip -timeprecision_vhdl fs -o xcorr_gps_slow_complex
./xcorr_gps_slow_complex -gui -tclbatch isim.tcl -wdb xcorr_gps_slow_complex.wdb
#./xcorr_gps_slow_complex -gui -tclbatch isim.tcl -wdb xcorr_gps_slow_complex.wdb
echo done

