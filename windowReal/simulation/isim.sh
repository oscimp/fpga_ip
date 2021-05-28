#!/bin/csh -f
echo Simulation Tool: ISIM
fuse work.top_windowReal_tb -prj windowReal.prj -L unisim -L secureip -timeprecision_vhdl fs -o windowReal
./windowReal -gui -tclbatch isim.tcl -wdb windowReal.wdb
echo done

