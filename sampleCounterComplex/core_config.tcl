variable fpga_ip    $::env(OSCIMP_DIGITAL_IP)

source $fpga_ip/scripts/core_ip.tcl

set ip_name {sampleCounterComplex}
set version 1.0

adi_ip_create $ip_name
adi_ip_file $ip_name [list \
	"./hdl/sampleCounterComplex.vhd"]

package_and_set_default_properties $version $ip_name cogen \
									ggm {Gwenhael Goavec-Merou} \
									http://www.trabucayre.com

core_parameter DATA_SIZE {Data Size} {input and output data size.}
core_parameter SAMPLE_COUNTER_SIZE {Counter Size} {internal counter and output counter stream size} 

add_complex_bus "data_in" "slave" \
	{
		{"data_i_i"   "DATA_I"} \
		{"data_q_i"   "DATA_Q"} \
		{"data_en_i"  "DATA_EN"} \
		{"data_eof_i" "DATA_EOF"} \
		{"data_sof_i" "DATA_SOF"} \
		{"data_clk_i" "DATA_CLK"} \
		{"data_rst_i" "DATA_RST"} \
	}

add_complex_bus "data_out" "master" \
	{
		{"data_i_o"   "DATA_I"} \
		{"data_q_o"   "DATA_Q"} \
		{"data_en_o"  "DATA_EN"} \
		{"data_eof_o" "DATA_EOF"} \
		{"data_sof_o" "DATA_SOF"} \
		{"data_clk_o" "DATA_CLK"} \
		{"data_rst_o" "DATA_RST"} \
	}

add_real_bus "counter_out" "master" \
	{
		{"counter_o"     "DATA"} \
		{"counter_en_o"  "DATA_EN"} \
		{"counter_eof_o" "DATA_EOF"} \
		{"counter_sof_o" "DATA_SOF"} \
		{"counter_clk_o" "DATA_CLK"} \
		{"counter_rst_o" "DATA_RST"} \
	}

rename core_parameter {}

package_save

close_project
