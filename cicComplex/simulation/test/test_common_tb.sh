#!/bin/bash

ghdl -i -v --std=08 --work=top --ieee=synopsys -fexplicit /home/benny/projets/projets_fe/region_2023/dev/oscimpDigital/fpga_ip/cicComplex/hdl/common.vhd /home/benny/projets/projets_fe/region_2023/dev/oscimpDigital/fpga_ip/cicComplex/simulation/test/common_tb.vhd
ghdl -m -v --std=08 --work=top --ieee=synopsys -fexplicit common_tb
ghdl -r -v --std=08 --work=top --ieee=synopsys -fexplicit common_tb