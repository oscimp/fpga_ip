# fpga_ip

In order to allow for pipelined processing of datastreams with no latency introduced by FIFOs or glue between blocks, dedicated
custom interfaces have been introduced: real and complex numbers and associated control signals. These interfaces are of varying,
user defined, bit width. A complex number is two real numbers processed in parallel.

![Data structure](https://github.com/oscimp/oscimpDigital/blob/master/doc/conferences/gnuradioDays2019/img/displayIf.png)

OscillatorIMP ecosystem FPGA IP sources: see ![the dedicated tool](https://github.com/oscimp/fpga_ip/tree/master/tools) for generating such information.

|     Block name      |    Function                           | Input(s)  | Output(s)          | Parameter(s)   | Driver | Library function(s) (liboscimp) |
|---------------------|---------------------------------------|-----------|--------------------|----------------|--------|---------------------------------|
|ad9767               |Redpitaya DAC (obsolete: see redpitaya_converters) |dataA_in,dataB_in| none |none        |none    |                                 |
|add_constComplex     | Add a constant to complex value stream| data_in    | data_out             | DATA_IN_SIZE(16), DATA_OUT_SIZE(18) | add_const   |   add_const_set_offset, add_const_get_offset, add_constMulti_set_offset     |                  
|add_constReal        | Add a constant to real value stream   | data_in   | data_out             | DATA_IN_SIZE(16), DATA_OUT_SIZE(18) | add_const   |   add_const_set_offset, add_const_get_offset, add_constMulti_set_offset     |                  
|[adder_substracter_complex](https://github.com/oscimp/oscimpDigital/blob/master/doc/IP/adder_subtractor.md)| Sum or difference of complex values| data1_i, data2_i  | data_o   | DATA_SIZE(16)   | none   |          none    |none           |                  
|[adder_substracter_real](https://github.com/oscimp/oscimpDigital/blob/master/doc/IP/adder_subtractor.md)| Sum or difference of real values     |  data1_i, data2_i  | data_o   | DATA_SIZE(16)   | none   |          none                   |                  
|axiStreamToComplex   | Xilinx AXI Stream to complex stream   | s00_axis, s00_axis_reset, s00_axis_aclk | data_out | DATA_SIZE | none | none    |                  
|axiStreamToReal      |Xilinx AXI Stream to real stream       | s00_axis, s00_axis_reset, s00_axis_aclk | data_out | DATA_SIZE | none | none    |                  
|axi_deltaSigma       |Slow DAC output (Sigma-Delta)          |  TODO     | TODO               | TODO           | TODO   |          TODO                   |                  
|[axi_to_dac](https://github.com/oscimp/oscimpDigital/blob/master/doc/IP/axi_to_dac.md)           |AXI value to DAC                       |  none     | dataA_out, dataB_out     | DATA_SIZE(14)   | axi_to_dac   | axi_to_dac_full_conf                   |                  
|cacode               |GPS Gold Code generator (outputs 31 codes in parallel -- select using slv_to_sl (std logic vector to std logic) | clk, reset, tick_i | gold_code_o | PERIOD_LEN  | none  |  none       |                  
|convertComplexToReal |Complex -> real values                 |data_in   | dataI_out,dataQ_out |DATA_SIZE(8)    |none    | none                            |
|convertRealToComplex |Real -> complex values                 |dataI_in,dataQ_in|data_out      |DATA_SIZE(8)    |none    |                                 |
|[dataComplex_to_ram](https://github.com/oscimp/oscimpDigital/blob/master/doc/IP/data_to_ram.md)   |PL to PS transfer (complex values)     |dataN_in   |none                |DATA_SIZE(32), NB_INPUT(12), NB_SAMPLE(1024) |data_to_ram| |
|[dataReal_to_ram](https://github.com/oscimp/oscimpDigital/blob/master/doc/IP/data_to_ram.md)      |PL to PS transfer (real values)        |dataN_in   |none                |DATA_SIZE(32), NB_INPUT(12), NB_SAMPLE(1024) |data_to_ram| |
|dupplReal_1_to_2     |Splits a real value stream             |data_in    |data1_out,data2_out |DATA_SIZE(8)    |none    |                                 |
|dupplComplex_1_to_2  |Splits a complex value stream          |data_in    |data1_out,data2_out |DATA_SIZE(8)    |none    |                                 |
|expanderComplex      |Add Most Significant Bits (complex)    |data_in    |data_out            |DATA_IN_SIZE(16), DATA_OUT_SIZE(16) | none |               |
|expanderReal         |Add Most Significant Bits (real value) |data_in    |data_out            |DATA_IN_SIZE(16), DATA_OUT_SIZE(16) | none |               |
|firReal              | Finite Impulse Response (FIR) filter with real coefficients provided from the processor, applied to real input stream |data_in    |data_out            |DATA_IN_SIZE(16), NB_COEFF(128), DECIMATE_FACTOR(32), DATA_OUT_SIZE(32), COEFF_SIZE(16)|fir| |
|ltc2145              |Redpitaya ADC (obsolete: see redpitaya_converters) |none |dataA_out,dataB_out |none      |none    |                                 |
|meanComplex          |outputs the mean value of the complex valued input stream |  data_in | data_out               | DATA_IN_SIZE(16), DATA_OUT_SIZE(18), NB_ACCUM(8), SHIFT(3), SIGNED_FORMAT(true)          | none   |          none                   |                  
|meanReal             |outputs the mean value of the real valued input stream    |  data_in | data_out               | DATA_IN_SIZE(16), DATA_OUT_SIZE(18), NB_ACCUM(8), SHIFT(3), SIGNED_FORMAT(true)           | none   |          none              |                  
|mean_vector_axi      |Average complex input stream (ADDR_SIZE=burst length) |data_in| data_out|DATA_SIZE(14),MAX_NB_ACCUM(1024),ADDR_SIZE(10)|   |        |
|[mixer_sin](https://github.com/oscimp/oscimpDigital/blob/master/doc/IP/mixer.md) |mixer                        |data_in,nco_in|data_out |DATA_IN_SIZE(16), DATA_OUT_SIZE(16), NCO_SIZE(16)|none||
|nco_counter          |NCO (sine & square = complex values)   |none       |sine_out, square_out |COUNTER_SIZE(28), DATA_SIZE(16) |nco_counter|nco_counter_send_conf|
|prn20b               | 20-bit pseudo random number sequence (LFSR)|none  | ref_clk_i, ref_rst_i, prn_full_out, bit_o           | DFLT_PRESC(15), PRESC_SIZE(16)           | none   | none |                          |
|redpitaya_adc_dac_clk|Repitaya clock distribution (ADC & DAC)| none       |none                |none            |none                                    | |
|redpitaya_converters | Redpitaya ADC/DAC converters | dataA_in, dataB_in | dataA_out, dataB_out| ADC_EN(true), DAC_EN(true), ADC_SIZE(14)          | none            | none             |
|[shifterReal](https://github.com/oscimp/oscimpDigital/blob/master/doc/IP/shifter.md)     |Bit shift (real values)   |data_in |data_out |DATA_IN_SIZE(32), DATA_OUT_SIZE(16)   |none    | |
|[shifterComplex](https://github.com/oscimp/oscimpDigital/blob/master/doc/IP/shifter.md)  |Bit shift (complex values)|data_in |data_out |DATA_IN_SIZE(32), DATA_OUT_SIZE(16)   |none    | |
|[switchComplex](https://github.com/oscimp/oscimpDigital/blob/master/doc/IP/switch.md)    |Complex stream multiplexer             |data1_in,data2_in   | data_out  |DATA_SIZE(16),DEFAULT_INPUT(0) |switch   | switch_conf     |
|[switchReal](https://github.com/oscimp/oscimpDigital/blob/master/doc/IP/switch.md)       |Real stream multiplexer                |data1_in,data2_in   | data_out  |DATA_SIZE(16),DEFAULT_INPUT(0) |switch   | switch_conf     |

For the pulse RADAR application:

|     Block name      |    Function                           | Input(s)  | Output(s)          | Parameter(s)   | Driver | Library function(s) (liboscimp) |
|---------------------|---------------------------------------|-----------|--------------------|----------------|--------|---------------------------------|
|check_valid_burst      |
|extract_data_from_burst|
|gen_radar_prog         |

For the pulse PlutoSDR demonstration and audio output/sigma-delta DAC with DC component output in general:

|     Block name      |    Function                           | Input(s)  | Output(s)          | Parameter(s)   | Driver | Library function(s) (liboscimp) |
|---------------------|---------------------------------------|-----------|--------------------|----------------|--------|---------------------------------|
|axi_deltaSigma         |
