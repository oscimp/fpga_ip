# fpga_ip
OscillatorIMP ecosystem FPGA IP sources

|     Block name      |    Function                           | Input(s)  | Output(s)          | Parameter(s)   | Driver | Library function(s) (liboscimp) |
|---------------------|---------------------------------------|-----------|--------------------|----------------|--------|---------------------------------|
|ad9767               |Redpitaya DAC                          |dataA,dataB| none               |none            |none    |                                 |
|convertRealToComplex |Real -> complex values                 |data1_in,data2_in|data_out      |DATA_SIZE(8)                |none    |         |
|dataComplex_to_ram   |PL to PS transfer (complex values)     |dataN_in   |none                |DATA_SIZE(32), NB_INPUT(12), NB_SAMPLE(1024)            |data_to_ram| |
|dataReal_to_ram      |PL to PS transfer (real values)        |dataN_in   |none                |DATA_SIZE(32), NB_INPUT(12), NB_SAMPLE(1024)            |data_to_ram| |
|dupplReal_1_to_2     |Splits a real value stream             |data_in    |data1_out,data2_out |DATA_SIZE(8)                                          |none       | |
|firReal              |                                       |data_in    |data_out            |DATA_SIZE(16), NB_COEFF(128), DECIMATE_FACTOR(32), DATA_OUT_SIZE(32), COEFF_SIZE(16)|fir| |
|ltc2145              |Redpitaya ADC                          |none       |data_a,data_b       |none            |none    | |
|redpitaya_adc_dac_clk|Repitaya clock distribution (ADC & DAC)|none       |none                |none            |none    | |
|shifterReal          |Bit shift (real values)                |data_in    |data_out            |DATA_IN_SIZE(32), DATA_OUT_SIZE(16)   |none    | |
|expanderComplex      |Add Most Significant Bits (complex)    |data_in    |data_out            |DATA_IN_SIZE(16), DATA_OUT_SIZE(16) | none | |
|expanderReal         |Add Most Significant Bits (real value) |data_in    |data_out            |DATA_IN_SIZE(16), DATA_OUT_SIZE(16) | none | |
|nco_counter          |NCO (DDS=sine, OUT=square)             |none       |data_dds, data_out  |COUNTER_SIZE(28), DATA_SIZE(16) |nco_counter|nco_counter_send_conf|
|mixer_sin            |mixer                                  |data_in,nco_in|data_out         |DATA_SIZE(16), NCO_SIZE(16)|none||
|prn20b               | 20-bit pseudo random number sequence (LFSR)|none | data_out | none | none | none | |
