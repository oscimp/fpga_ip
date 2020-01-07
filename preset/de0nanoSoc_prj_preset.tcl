set_global_assignment -name STRATIX_DEVICE_IO_STANDARD "2.5 V"

set_global_assignment -name DEVICE_FILTER_PACKAGE UFBGA
set_global_assignment -name DEVICE_FILTER_PIN_COUNT 896
set_global_assignment -name DEVICE_FILTER_SPEED_GRADE 6

set_global_assignment -name NUM_PARALLEL_PROCESSORS 2

set_global_assignment -name USE_DLL_FREQUENCY_FOR_DQS_DELAY_CHAIN ON
set_global_assignment -name UNIPHY_SEQUENCER_DQS_CONFIG_ENABLE ON
set_global_assignment -name OPTIMIZE_MULTI_CORNER_TIMING ON
set_global_assignment -name ECO_REGENERATE_REPORT ON

set_instance_assignment -name GLOBAL_SIGNAL OFF -to hps|hps_io|border|hps_sdram_inst|p0|umemphy|ureset|phy_reset_mem_stable_n -tag __hps_sdram_p0
set_instance_assignment -name GLOBAL_SIGNAL OFF -to hps|hps_io|border|hps_sdram_inst|p0|umemphy|ureset|phy_reset_n -tag __hps_sdram_p0
set_instance_assignment -name GLOBAL_SIGNAL OFF -to hps|hps_io|border|hps_sdram_inst|p0|umemphy|uio_pads|dq_ddio[0].read_capture_clk_buffer -tag __hps_sdram_p0
set_instance_assignment -name GLOBAL_SIGNAL OFF -to hps|hps_io|border|hps_sdram_inst|p0|umemphy|uread_datapath|reset_n_fifo_write_side[0] -tag __hps_sdram_p0
set_instance_assignment -name GLOBAL_SIGNAL OFF -to hps|hps_io|border|hps_sdram_inst|p0|umemphy|uread_datapath|reset_n_fifo_wraddress[0] -tag __hps_sdram_p0
set_instance_assignment -name GLOBAL_SIGNAL OFF -to hps|hps_io|border|hps_sdram_inst|p0|umemphy|uio_pads|dq_ddio[1].read_capture_clk_buffer -tag __hps_sdram_p0
set_instance_assignment -name GLOBAL_SIGNAL OFF -to hps|hps_io|border|hps_sdram_inst|p0|umemphy|uread_datapath|reset_n_fifo_write_side[1] -tag __hps_sdram_p0
set_instance_assignment -name GLOBAL_SIGNAL OFF -to hps|hps_io|border|hps_sdram_inst|p0|umemphy|uread_datapath|reset_n_fifo_wraddress[1] -tag __hps_sdram_p0
set_instance_assignment -name GLOBAL_SIGNAL OFF -to hps|hps_io|border|hps_sdram_inst|p0|umemphy|uio_pads|dq_ddio[2].read_capture_clk_buffer -tag __hps_sdram_p0
set_instance_assignment -name GLOBAL_SIGNAL OFF -to hps|hps_io|border|hps_sdram_inst|p0|umemphy|uread_datapath|reset_n_fifo_write_side[2] -tag __hps_sdram_p0
set_instance_assignment -name GLOBAL_SIGNAL OFF -to hps|hps_io|border|hps_sdram_inst|p0|umemphy|uread_datapath|reset_n_fifo_wraddress[2] -tag __hps_sdram_p0
set_instance_assignment -name GLOBAL_SIGNAL OFF -to hps|hps_io|border|hps_sdram_inst|p0|umemphy|uio_pads|dq_ddio[3].read_capture_clk_buffer -tag __hps_sdram_p0
set_instance_assignment -name GLOBAL_SIGNAL OFF -to hps|hps_io|border|hps_sdram_inst|p0|umemphy|uread_datapath|reset_n_fifo_write_side[3] -tag __hps_sdram_p0
set_instance_assignment -name GLOBAL_SIGNAL OFF -to hps|hps_io|border|hps_sdram_inst|p0|umemphy|uread_datapath|reset_n_fifo_wraddress[3] -tag __hps_sdram_p0
set_instance_assignment -name ENABLE_BENEFICIAL_SKEW_OPTIMIZATION_FOR_NON_GLOBAL_CLOCKS ON -to hps|hps_io|border|hps_sdram_inst -tag __hps_sdram_p0
set_instance_assignment -name PLL_COMPENSATION_MODE DIRECT -to hps|hps_io|border|hps_sdram_inst|pll0|fbout -tag __hps_sdram_p0

# DDR
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_a[0] -tag __hps_sdram_p0;
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to memory_mem_a[0] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_a[0] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_a[1] -tag __hps_sdram_p0;
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to memory_mem_a[1] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_a[1] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_a[2] -tag __hps_sdram_p0;
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to memory_mem_a[2] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_a[2] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_a[3] -tag __hps_sdram_p0;
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to memory_mem_a[3] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_a[3] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_a[4] -tag __hps_sdram_p0;
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to memory_mem_a[4] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_a[4] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_a[5] -tag __hps_sdram_p0;
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to memory_mem_a[5] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_a[5] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_a[6] -tag __hps_sdram_p0;
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to memory_mem_a[6] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_a[6] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_a[7] -tag __hps_sdram_p0;
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to memory_mem_a[7] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_a[7] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_a[8] -tag __hps_sdram_p0;
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to memory_mem_a[8] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_a[8] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_a[9] -tag __hps_sdram_p0;
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to memory_mem_a[9] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_a[9] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_a[10] -tag __hps_sdram_p0;
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to memory_mem_a[10] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_a[10] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_a[11] -tag __hps_sdram_p0;
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to memory_mem_a[11] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_a[11] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_a[12] -tag __hps_sdram_p0;
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to memory_mem_a[12] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_a[12] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_a[13] -tag __hps_sdram_p0;
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to memory_mem_a[13] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_a[13] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_a[14] -tag __hps_sdram_p0;
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to memory_mem_a[14] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_a[14] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_ba[0] -tag __hps_sdram_p0;
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to memory_mem_ba[0] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_ba[0] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_ba[1] -tag __hps_sdram_p0;
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to memory_mem_ba[1] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_ba[1] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_ba[2] -tag __hps_sdram_p0;
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to memory_mem_ba[2] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_ba[2] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.5-V SSTL CLASS I" -to memory_mem_ck -tag __hps_sdram_p0;
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITHOUT CALIBRATION" -to memory_mem_ck -tag __hps_sdram_p0;
set_instance_assignment -name D5_DELAY 2 -to memory_mem_ck -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_ck -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.5-V SSTL CLASS I" -to memory_mem_ck_n -tag __hps_sdram_p0;
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITHOUT CALIBRATION" -to memory_mem_ck_n -tag __hps_sdram_p0;
set_instance_assignment -name D5_DELAY 2 -to memory_mem_ck_n -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_ck_n -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_cke -tag __hps_sdram_p0;
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to memory_mem_cke -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_cke -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_cs_n -tag __hps_sdram_p0;
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to memory_mem_cs_n -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_cs_n -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_ras_n -tag __hps_sdram_p0;
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to memory_mem_ras_n -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_ras_n -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_cas_n -tag __hps_sdram_p0;
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to memory_mem_cas_n -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_cas_n -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_we_n -tag __hps_sdram_p0;
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to memory_mem_we_n -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_we_n -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_reset_n -tag __hps_sdram_p0;
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to memory_mem_reset_n -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_reset_n -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[0] -tag __hps_sdram_p0;
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[0] -tag __hps_sdram_p0;
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[0] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[0] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[0] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[1] -tag __hps_sdram_p0;
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[1] -tag __hps_sdram_p0;
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[1] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[1] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[2] -tag __hps_sdram_p0;
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[2] -tag __hps_sdram_p0;
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[2] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[2] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[3] -tag __hps_sdram_p0;
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[3] -tag __hps_sdram_p0;
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[3] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[3] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[4] -tag __hps_sdram_p0;
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[4] -tag __hps_sdram_p0;
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[4] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[4] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[5] -tag __hps_sdram_p0;
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[5] -tag __hps_sdram_p0;
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[5] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[5] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[6] -tag __hps_sdram_p0;
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[6] -tag __hps_sdram_p0;
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[6] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[6] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[7] -tag __hps_sdram_p0;
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[7] -tag __hps_sdram_p0;
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[7] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[7] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[8] -tag __hps_sdram_p0;
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[8] -tag __hps_sdram_p0;
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[8] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[8] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[9] -tag __hps_sdram_p0;
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[9] -tag __hps_sdram_p0;
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[9] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[9] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[10] -tag __hps_sdram_p0;
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[10] -tag __hps_sdram_p0;
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[10] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[10] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[11] -tag __hps_sdram_p0;
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[11] -tag __hps_sdram_p0;
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[11] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[11] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[12] -tag __hps_sdram_p0;
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[12] -tag __hps_sdram_p0;
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[12] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[12] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[13] -tag __hps_sdram_p0;
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[13] -tag __hps_sdram_p0;
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[13] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[13] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[14] -tag __hps_sdram_p0;
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[14] -tag __hps_sdram_p0;
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[14] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[14] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[15] -tag __hps_sdram_p0;
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[15] -tag __hps_sdram_p0;
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[15] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[15] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[16] -tag __hps_sdram_p0;
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[16] -tag __hps_sdram_p0;
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[16] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[16] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[17] -tag __hps_sdram_p0;
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[17] -tag __hps_sdram_p0;
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[17] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[17] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[18] -tag __hps_sdram_p0;
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[18] -tag __hps_sdram_p0;
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[18] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[18] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[19] -tag __hps_sdram_p0;
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[19] -tag __hps_sdram_p0;
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[19] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[19] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[20] -tag __hps_sdram_p0;
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[20] -tag __hps_sdram_p0;
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[20] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[20] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[21] -tag __hps_sdram_p0;
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[21] -tag __hps_sdram_p0;
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[21] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[21] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[22] -tag __hps_sdram_p0;
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[22] -tag __hps_sdram_p0;
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[22] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[22] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[23] -tag __hps_sdram_p0;
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[23] -tag __hps_sdram_p0;
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[23] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[23] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[24] -tag __hps_sdram_p0;
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[24] -tag __hps_sdram_p0;
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[24] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[24] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[25] -tag __hps_sdram_p0;
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[25] -tag __hps_sdram_p0;
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[25] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[25] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[26] -tag __hps_sdram_p0;
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[26] -tag __hps_sdram_p0;
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[26] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[26] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[27] -tag __hps_sdram_p0;
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[27] -tag __hps_sdram_p0;
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[27] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[27] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[28] -tag __hps_sdram_p0;
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[28] -tag __hps_sdram_p0;
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[28] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[28] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[29] -tag __hps_sdram_p0;
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[29] -tag __hps_sdram_p0;
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[29] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[29] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[30] -tag __hps_sdram_p0;
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[30] -tag __hps_sdram_p0;
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[30] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[30] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dq[31] -tag __hps_sdram_p0;
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dq[31] -tag __hps_sdram_p0;
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dq[31] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dq[31] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.5-V SSTL CLASS I" -to memory_mem_dqs[0] -tag __hps_sdram_p0;
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dqs[0] -tag __hps_sdram_p0;
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dqs[0] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dqs[0] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.5-V SSTL CLASS I" -to memory_mem_dqs[1] -tag __hps_sdram_p0;
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dqs[1] -tag __hps_sdram_p0;
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dqs[1] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dqs[1] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.5-V SSTL CLASS I" -to memory_mem_dqs[2] -tag __hps_sdram_p0;
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dqs[2] -tag __hps_sdram_p0;
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dqs[2] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dqs[2] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.5-V SSTL CLASS I" -to memory_mem_dqs[3] -tag __hps_sdram_p0;
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dqs[3] -tag __hps_sdram_p0;
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dqs[3] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dqs[3] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.5-V SSTL CLASS I" -to memory_mem_dqs_n[0] -tag __hps_sdram_p0;
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dqs_n[0] -tag __hps_sdram_p0;
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dqs_n[0] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dqs_n[0] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.5-V SSTL CLASS I" -to memory_mem_dqs_n[1] -tag __hps_sdram_p0;
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dqs_n[1] -tag __hps_sdram_p0;
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dqs_n[1] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dqs_n[1] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.5-V SSTL CLASS I" -to memory_mem_dqs_n[2] -tag __hps_sdram_p0;
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dqs_n[2] -tag __hps_sdram_p0;
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dqs_n[2] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dqs_n[2] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.5-V SSTL CLASS I" -to memory_mem_dqs_n[3] -tag __hps_sdram_p0;
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to memory_mem_dqs_n[3] -tag __hps_sdram_p0;
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dqs_n[3] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dqs_n[3] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_odt -tag __hps_sdram_p0;
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to memory_mem_odt -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_odt -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dm[0] -tag __hps_sdram_p0;
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dm[0] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dm[0] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dm[1] -tag __hps_sdram_p0;
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dm[1] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dm[1] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dm[2] -tag __hps_sdram_p0;
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dm[2] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dm[2] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_mem_dm[3] -tag __hps_sdram_p0;
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to memory_mem_dm[3] -tag __hps_sdram_p0;
set_instance_assignment -name PACKAGE_SKEW_COMPENSATION OFF -to memory_mem_dm[3] -tag __hps_sdram_p0;
set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to memory_oct_rzqin -tag __hps_sdram_p0;

# placement
set_location_assignment PIN_A22 -to hps_io_hps_io_uart0_inst_RX;
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hps_io_hps_io_uart0_inst_RX;
set_location_assignment PIN_B21 -to hps_io_hps_io_uart0_inst_TX;
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hps_io_hps_io_uart0_inst_TX;

set_location_assignment PIN_J15 -to hps_io_hps_io_emac1_inst_TX_CLK;
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hps_io_hps_io_emac1_inst_TX_CLK;
set_location_assignment PIN_A16 -to hps_io_hps_io_emac1_inst_TXD0;
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hps_io_hps_io_emac1_inst_TXD0;
set_location_assignment PIN_J14 -to hps_io_hps_io_emac1_inst_TXD1;
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hps_io_hps_io_emac1_inst_TXD1;
set_location_assignment PIN_A15 -to hps_io_hps_io_emac1_inst_TXD2;
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hps_io_hps_io_emac1_inst_TXD2;
set_location_assignment PIN_D17 -to hps_io_hps_io_emac1_inst_TXD3;
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hps_io_hps_io_emac1_inst_TXD3;
set_location_assignment PIN_E16 -to hps_io_hps_io_emac1_inst_MDIO;
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hps_io_hps_io_emac1_inst_MDIO;
set_location_assignment PIN_A13 -to hps_io_hps_io_emac1_inst_MDC;
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hps_io_hps_io_emac1_inst_MDC;
#set_location_assignment PIN_ -to hps_io_hps_io_emac1_inst_RX_CTL;
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hps_io_hps_io_emac1_inst_RX_CTL;
#set_location_assignment PIN_ -to hps_io_hps_io_emac1_inst_TX_CTL;
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hps_io_hps_io_emac1_inst_TX_CTL;
set_location_assignment PIN_J12 -to hps_io_hps_io_emac1_inst_RX_CLK;
set_location_assignment PIN_A14 -to hps_io_hps_io_emac1_inst_RXD0;
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hps_io_hps_io_emac1_inst_RXD0;
set_location_assignment PIN_A11 -to hps_io_hps_io_emac1_inst_RXD1;
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hps_io_hps_io_emac1_inst_RXD1;
set_location_assignment PIN_C15 -to hps_io_hps_io_emac1_inst_RXD2;
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hps_io_hps_io_emac1_inst_RXD2;
set_location_assignment PIN_A9  -to hps_io_hps_io_emac1_inst_RXD3;
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hps_io_hps_io_emac1_inst_RXD3;

set_location_assignment PIN_B8  -to hps_io_hps_io_sdio_inst_CLK;
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hps_io_hps_io_sdio_inst_CLK;
set_location_assignment PIN_D14 -to hps_io_hps_io_sdio_inst_CMD;
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hps_io_hps_io_sdio_inst_CMD;
set_location_assignment PIN_C13 -to hps_io_hps_io_sdio_inst_D0;
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hps_io_hps_io_sdio_inst_D0;
set_location_assignment PIN_B6  -to hps_io_hps_io_sdio_inst_D1;
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hps_io_hps_io_sdio_inst_D1;
set_location_assignment PIN_B11 -to hps_io_hps_io_sdio_inst_D2;
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hps_io_hps_io_sdio_inst_D2;
set_location_assignment PIN_B9  -to hps_io_hps_io_sdio_inst_D3;
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hps_io_hps_io_sdio_inst_D3;

set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hps_io_hps_io_usb1_inst_D0;
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hps_io_hps_io_usb1_inst_D1;
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hps_io_hps_io_usb1_inst_D2;
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hps_io_hps_io_usb1_inst_D3;
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hps_io_hps_io_usb1_inst_D4;
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hps_io_hps_io_usb1_inst_D5;
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hps_io_hps_io_usb1_inst_D6;
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hps_io_hps_io_usb1_inst_D7;
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hps_io_hps_io_usb1_inst_CLK;
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hps_io_hps_io_usb1_inst_STP;
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hps_io_hps_io_usb1_inst_DIR;
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hps_io_hps_io_usb1_inst_NXT;
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hps_io_hps_io_spim1_inst_CLK;
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hps_io_hps_io_spim1_inst_MOSI;
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hps_io_hps_io_spim1_inst_MISO;
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hps_io_hps_io_spim1_inst_SS0;
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hps_io_hps_io_i2c0_inst_SDA;
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hps_io_hps_io_i2c0_inst_SCL;
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hps_io_hps_io_i2c1_inst_SDA;
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hps_io_hps_io_i2c1_inst_SCL;

