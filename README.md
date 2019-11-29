# fpga_ip

In order to allow for pipelined processing of datastreams with no latency introduced by FIFOs or glue between blocks, dedicated
custom interfaces have been introduced: real and complex numbers and associated control signals. These interfaces are of varying,
user defined, bit width. A complex number is two real numbers processed in parallel.

![Data structure](https://github.com/oscimp/oscimpDigital/blob/master/doc/conferences/gnuradioDays2019/img/displayIf.png)

OscillatorIMP ecosystem FPGA IP sources

|     Block name      |    Function                           | Input(s)  | Output(s)          | Parameter(s)   | Driver | Library function(s) (liboscimp) |
|---------------------|---------------------------------------|-----------|--------------------|----------------|--------|---------------------------------|
|ad9767               |Redpitaya DAC                          |dataA_in,dataB_in| none               |none            |none    |                                 |
|convertRealToComplex |Real -> complex values                 |dataI_in,dataQ_in|data_out      |DATA_SIZE(8)                |none    |         |
|convertComplexToReal |Complex -> real values                 |data_in   | dataI_out,dataQ_out |DATA_SIZE(8)    |none    | none                            |
|dataComplex_to_ram   |PL to PS transfer (complex values)     |dataN_in   |none                |DATA_SIZE(32), NB_INPUT(12), NB_SAMPLE(1024)            |data_to_ram| |
|dataReal_to_ram      |PL to PS transfer (real values)        |dataN_in   |none                |DATA_SIZE(32), NB_INPUT(12), NB_SAMPLE(1024)            |data_to_ram| |
|dupplReal_1_to_2     |Splits a real value stream             |data_in    |data1_out,data2_out |DATA_SIZE(8)                                          |none       | |
|dupplComplex_1_to_2  |Splits a complex value stream          |data_in    |data1_out,data2_out |DATA_SIZE(8)                                          |none       | |
|firReal              |                                       |data_in    |data_out            |DATA_SIZE(16), NB_COEFF(128), DECIMATE_FACTOR(32), DATA_OUT_SIZE(32), COEFF_SIZE(16)|fir| |
|ltc2145              |Redpitaya ADC                          |none       |dataA_out,dataB_out |none            |none    | |
|redpitaya_adc_dac_clk|Repitaya clock distribution (ADC & DAC)|none       |none                |none            |none    | |
|[shifterReal](https://github.com/oscimp/oscimpDigital/blob/master/doc/IP/shifter.md)          |Bit shift (real values)                |data_in    |data_out            |DATA_IN_SIZE(32), DATA_OUT_SIZE(16)   |none    | |
|[shifterComplex](https://github.com/oscimp/oscimpDigital/blob/master/doc/IP/shifter.md)       |Bit shift (complex values)             |data_in    |data_out            |DATA_IN_SIZE(32), DATA_OUT_SIZE(16)   |none    | |
|expanderComplex      |Add Most Significant Bits (complex)    |data_in    |data_out            |DATA_IN_SIZE(16), DATA_OUT_SIZE(16) | none | |
|expanderReal         |Add Most Significant Bits (real value) |data_in    |data_out            |DATA_IN_SIZE(16), DATA_OUT_SIZE(16) | none | |
|nco_counter          |NCO (sine & square = complex values)   |none       |sine_out, square_out |COUNTER_SIZE(28), DATA_SIZE(16) |nco_counter|nco_counter_send_conf|
|[mixer_sin](https://github.com/oscimp/oscimpDigital/blob/master/doc/IP/mixer.md) |mixer                                  |data_in,nco_in|data_out         |DATA_SIZE(16), NCO_SIZE(16)|none||
|prn20b               | 20-bit pseudo random number sequence (LFSR)|none | data_out | none | none | none | |
|switchComplex        |Complex stream multiplexer             |data1_in,data2_in   | data_out  |DATA_SIZE(16),DEFAULT_INPUT(0) |switch   | switch_conf       |
|switchReal           |Real stream multiplexer                |data1_in,data2_in   | data_out  |DATA_SIZE(16),DEFAULT_INPUT(0) |switch   | switch_conf       |
|mean_vector_axi      |Average complex input stream (ADDR_SIZE=burst length) |data_in             | data_out  |DATA_SIZE(14),MAX_NB_ACCUM(1024),ADDR_SIZE(10)|   |          |

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
