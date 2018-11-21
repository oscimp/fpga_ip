#create_clock -period 8.000 -name ltc2145_clk [get_ports adc_clk_i]

#set_input_delay -clock ltc2145_clk 3.400 [get_ports adc_data_a_i[*]]
#set_input_delay -clock ltc2145_clk 3.400 [get_ports adc_data_b_i[*]]

