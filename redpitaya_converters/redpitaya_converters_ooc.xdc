############################################################################
# Clock constraints                                                        #
############################################################################
#NET "adc_clk" TNM_NET = "adc_clk";
#TIMESPEC TS_adc_clk = PERIOD "adc_clk" 125 MHz;

create_clock -period 8.000 -name adc_clk [get_ports adc_clk_p_i]

set_false_path -from [get_clocks adc_clk]     -to [get_clocks dac_clk_out]
set_false_path -from [get_clocks dac_clk_out] -to [get_clocks dac_2clk_out]
set_false_path -from [get_clocks dac_clk_out] -to [get_clocks dac_2ph_out]
