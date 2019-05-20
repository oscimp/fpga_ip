onerror {resume}
isim set radix hex
#wave add /sim_tb_top/
wave add /top_xcorr_gps_slow_complex_tb
run 60 us
#quit
