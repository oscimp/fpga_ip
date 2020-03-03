#!/usr/bin/env python3

dupplType="real"
content = """---------------------------------------------------------------------------
-- (c) Copyright: OscillatorIMP Digital
-- Author : Gwenhael Goavec-Merou<gwenhael.goavec-merou@trabucayre.com>
-- Creation date : 2014/10/14
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
"""
if dupplType == "complex":
    content += "entity dupplComplex is"
else:
    content += "entity dupplReal is"
content += """
	generic (
		NB_OUTPUT  : natural := 32;
		DATA_SIZE : natural := 8
	);
	port (
		-- DATA in
		data_en_i : in std_logic;
		data_clk_i : in std_logic;
		data_rst_i : in std_logic;
		data_eof_i : in std_logic;
		data_sof_i : in std_logic;"""

if dupplType == "complex":
    content += """
		data_i_i : in std_logic_vector(DATA_SIZE-1 downto 0);
		data_q_i : in std_logic_vector(DATA_SIZE-1 downto 0);
"""
else:
    content += """
		data_i: in std_logic_vector(DATA_SIZE-1 downto 0);
"""

content += "\t\t--next\n"
for i in range(32):
    content += "\t\tdata"+str(i+1) + "_en_o : out std_logic;\n"
    content += "\t\tdata"+str(i+1) + "_clk_o : out std_logic;\n"
    content += "\t\tdata"+str(i+1) + "_rst_o : out std_logic;\n"
    content += "\t\tdata"+str(i+1) + "_eof_o : out std_logic;\n"
    content += "\t\tdata"+str(i+1) + "_sof_o : out std_logic;\n"
    if (dupplType == "complex"):
        content += "\t\tdata"+str(i+1) + "_i_o : out std_logic_vector(DATA_SIZE-1 downto 0);\n"
        content += "\t\tdata"+str(i+1) + "_q_o : out std_logic_vector(DATA_SIZE-1 downto 0)"
    else:
        content += "\t\tdata"+str(i+1) + "_o : out std_logic_vector(DATA_SIZE-1 downto 0)"
    if (i < 31):
        content += ";\n"
    else:
        content += "\n"
content += ");\n"
if dupplType == "complex":
    content += "end dupplComplex;\n"
else:
    content += "end dupplReal;\n"
content += "architecture Behavioral of duppl"
if dupplType == "complex":
    content += "Complex is\n"
else:
    content += "Real is\n"
content += "begin\n"
if dupplType == "complex":
    content+= "\tdata1_i_o <= data_i_i;\n"
    content+= "\tdata1_q_o <= data_q_i;"
else:
    content+= "\tdata1_o <= data_i;"
content += """
	data1_en_o <= data_en_i;
	data1_clk_o <= data_clk_i;
	data1_rst_o <= data_rst_i;
	data1_eof_o <= data_eof_i;
	data1_sof_o <= data_sof_i;

"""
for i in range(1, 32):
    content += "\tout" + str(i+1)+ " : if NB_OUTPUT > " + str(i) + " generate\n"
    if dupplType == "complex":
        content+= "\t\tdata" + str(i+1) + "_i_o <= data_i_i;\n"
        content+= "\t\tdata" + str(i+1) + "_q_o <= data_q_i;\n"
    else:
        content+= "\t\tdata" + str(i+1) + "_o <= data_i;\n"
    content+= "\t\tdata" + str(i+1) + "_en_o <= data_en_i;\n"
    content+= "\t\tdata" + str(i+1) + "_clk_o <= data_clk_i;\n"
    content+= "\t\tdata" + str(i+1) + "_rst_o <= data_rst_i;\n"
    content+= "\t\tdata" + str(i+1) + "_eof_o <= data_eof_i;\n"
    content+= "\t\tdata" + str(i+1) + "_sof_o <= data_sof_i;\n"
    content+= "\tend generate out" + str(i+1)+";\n"
    content+= "\n"

content += "end Behavioral;\n"

if dupplType == "complex":
    filename = "dupplComplex"
else:
    filename = "dupplReal"
fd = open("hdl/" + filename + ".vhd", "w")
fd.write(content)
fd.close()

content = """variable fpga_ip    $::env(OSC_IMP_IP)

source $fpga_ip/scripts/core_ip.tcl

"""
content += "set ip_name {" + filename + "}\n"
content += """set version 1.0

adi_ip_create $ip_name
adi_ip_file $ip_name [list \\
"""
if dupplType == "complex":
    content += '\t"hdl/dupplComplex.vhd"]\n'
else:
    content += '\t"hdl/dupplReal.vhd"]\n'
content += """
package_and_set_default_properties $version $ip_name cogen \\
                                    ggm {Gwenhael Goavec-Merou} \\
                                    http://www.trabucayre.com

core_parameter NB_OUTPUT {NB Output} {Number of output channels (max 32).}
core_parameter DATA_SIZE {Data Size} {Size of input data bus.}

"""
content += "add_" + dupplType + "_bus data_in slave \\\n"
content += "\t{\n"
if dupplType == "complex":
    content += '\t\t{"data_i_i"  "DATA_I"} \\\n'
    content += '\t\t{"data_q_i"  "DATA_Q"} \\\n'
else:
    content += '\t\t{"data_i"  "DATA"} \\\n'
content += '\t\t{"data_en_i"  "DATA_EN"} \\\n'
content += '\t\t{"data_eof_i" "DATA_EOF"} \\\n'
content += '\t\t{"data_sof_i" "DATA_SOF"} \\\n'
content += '\t\t{"data_clk_i" "DATA_CLK"} \\\n'
content += '\t\t{"data_rst_i" "DATA_RST"} \\\n'
content += '\t}\n\n'

for i in range(32):
    content += "add_"+dupplType+"_bus data"+str(i+1)+"_out master \\\n"
    content += "\t{\n"
    if dupplType == "complex":
        content += '\t\t{"data' + str(i+1) + '_i_o"  "DATA_I"} \\\n'
        content += '\t\t{"data' + str(i+1) + '_q_o"  "DATA_Q"} \\\n'
    else:
        content += '\t\t{"data' + str(i+1) + '_o"  "DATA"} \\\n'
    content += '\t\t{"data' + str(i+1) + '_en_o"  "DATA_EN"} \\\n'
    content += '\t\t{"data' + str(i+1) + '_eof_o" "DATA_EOF"} \\\n'
    content += '\t\t{"data' + str(i+1) + '_sof_o" "DATA_SOF"} \\\n'
    content += '\t\t{"data' + str(i+1) + '_clk_o" "DATA_CLK"} \\\n'
    content += '\t\t{"data' + str(i+1) + '_rst_o" "DATA_RST"} \\\n'
    content += '\t}\n'
    if i > 0:
        content += "set_property enablement_dependency \\\n"
        content += "\t{spirit:decode(id('MODELPARAM_VALUE.NB_OUTPUT')) > " + str(i) + "} \\\n"
        content += "\t[ipx::get_bus_interfaces data"+str(i+1)+"_out -of_objects [ipx::current_core]]\n"
    content += "\n"
content += """set_property previous_version_for_upgrade ggm:cogen:dupplComplex_1_to_2:1.0 [ipx::current_core]

rename core_parameter {}

package_save

close_project
"""
fd = open("core_config.tcl", "w")
fd.write(content)
fd.close()
print(content)
