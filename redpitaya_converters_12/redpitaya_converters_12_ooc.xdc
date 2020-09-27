############################################################################
# Clock constraints                                                        #
############################################################################
#NET "adc_clk" TNM_NET = "adc_clk";
#TIMESPEC TS_adc_clk = PERIOD "adc_clk" 250 MHz;

create_clock -period 100.000 -name pll_ref_i -waveform {0.000 50.000} [get_ports pll_ref_i]
create_clock -period 4.000 -name adc_clk [get_ports adc_clk_p_i]

set_clock_groups -asynchronous -group dac_clk_out -group adc_clk2d_out -group adc_clk
set_clock_groups -asynchronous -group adc_clk2d_out -group pll_ref_i




set_property ASYNC_REG TRUE \
        [get_cells -hier flipflops*_reg[0]] \
        [get_cells -hier flipflops*_reg[1]]
set_false_path \
        -from [get_cells -hier sync_stage0_*_reg -filter {IS_SEQUENTIAL}] \
        -to [get_cells -hier flipflops*_reg[0] -filter {IS_SEQUENTIAL}]

set_property ASYNC_REG TRUE \
        [get_cells -hier flipflops_vect*_reg[0][*]] \
        [get_cells -hier flipflops_vect*_reg[1][*]]
set_false_path \
        -from [get_cells -hier sync_vect_stage0_*_reg[*] -filter {IS_SEQUENTIAL}] \
        -to [get_cells -hier flipflops_vect*_reg[0][*] -filter {IS_SEQUENTIAL}]

