import random
import logging

import cocotb

from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge, FallingEdge

from math import *

@cocotb.coroutine
def reset_dut(reset_n, clk, duration):
    reset_n <= 1
    yield RisingEdge(clk);
    yield Timer(duration)
    yield RisingEdge(clk);
    reset_n <= 0
    reset_n._log.debug("Reset complete")

nb_sample = 2048 * 4

#@cocotb.test()
#def verif_lt(dut):
#    dut.select_input_i <= 1
#    dut.data1_i <= 0
#    dut.data2_i <= 0
#    dut.data_en_i <= 0
#    dut.data_sof_i <= 0
#    dut.data_eof_i <= 0
#    dut.start_acquisition_i <= 0
#    reset_n = dut.rst_i
#
#    cocotb.fork(Clock(dut.clk_i, 10, 'ns').start())
#    yield reset_dut(reset_n, dut.clk_i, 500)
#
#    dut._log.debug("After reset")
#
#    # try to start with enable
#    yield RisingEdge(dut.clk_i)
#    dut.data_en_i <= 1
#    dut.data_sof_i <= 1
#    yield RisingEdge(dut.clk_i)
#    dut.data_en_i <= 0
#    dut.data_sof_i <= 0
#    yield RisingEdge(dut.clk_i)
#    yield RisingEdge(dut.clk_i)
#    assert(int(dut.busy_o) == int(0))
#    
#    # now correct behavior
#    dut.start_acquisition_i <= 1
#    yield RisingEdge(dut.clk_i)
#    dut.start_acquisition_i <= 0
#    yield RisingEdge(dut.clk_i)
#    yield RisingEdge(dut.clk_i)
#    # IP must be ready to receive
#    # GGM: TODO: verify bhv when en is high but sof low
#    assert(int(dut.dut_inst.enable_s) == int(1))
#    yield RisingEdge(dut.clk_i)
#    dut.data1_i <= 10
#    dut.data2_i <= 100
#    dut.data_en_i <= 1
#    dut.data_sof_i <= 1
#    yield RisingEdge(dut.clk_i)
#    dut.data_en_i <= 0
#    dut.data_sof_i <= 0
#    yield RisingEdge(dut.clk_i)
#    yield RisingEdge(dut.clk_i)
#    yield RisingEdge(dut.clk_i)
#    assert(int(dut.dut_inst.enable_s) == int(0))
#    for i in range(0, 10):
#        dut.data1_i <= 10+i+1
#        dut.data2_i <= 100+i+1
#        dut.data_en_i <= 1
#        if i == 9:
#            dut.data_eof_i <= 1
#        yield RisingEdge(dut.clk_i)
#        dut.data_en_i <= 0
#        dut.data_sof_i <= 0
#        dut.data_eof_i <= 0
#        # a second cycle is mandatory to send
#        # data2
#        yield RisingEdge(dut.clk_i)
#        yield RisingEdge(dut.clk_i)
#    dut.data_en_i <= 1
#    dut.data1_i <= 1000
#    dut.data2_i <= 1010
#    yield RisingEdge(dut.clk_i)
#    dut.data_en_i <= 0
#    yield RisingEdge(dut.clk_i)
#    yield RisingEdge(dut.clk_i)
#    dut.data_en_i <= 1
#    dut.data_sof_i <= 1
#    yield RisingEdge(dut.clk_i)
#    yield RisingEdge(dut.clk_i)
#    for i in range(0, 10):
#        yield RisingEdge(dut.clk_i)

#@cocotb.test()
#def verif_manuel(dut):
#    dut.select_input_i <= 1
#    dut.data1_i <= 0
#    dut.data2_i <= 0
#    dut.data_en_i <= 0
#    dut.data_sof_i <= 0
#    dut.data_eof_i <= 0
#    dut.start_acquisition_i <= 0
#    reset_n = dut.rst_i
#
#    cocotb.fork(Clock(dut.clk_i, 10, 'ns').start())
#    yield reset_dut(reset_n, dut.clk_i, 500)
#
#    dut._log.debug("After reset")
#
#    # now correct behavior
#    dut.start_acquisition_i <= 1
#    yield RisingEdge(dut.clk_i)
#    dut.start_acquisition_i <= 0
#    yield RisingEdge(dut.clk_i)
#    yield RisingEdge(dut.clk_i)
#    dut.select_input_i <= 0
#    yield RisingEdge(dut.clk_i)
#    for i in range(0, 40):
#        yield RisingEdge(dut.clk_i)

#@cocotb.test()
#def verif_gen(dut):
#    dut.select_input_i <= 0
#    dut.data1_i <= 0
#    dut.data2_i <= 0
#    dut.data_en_i <= 0
#    dut.data_sof_i <= 0
#    dut.data_eof_i <= 0
#    dut.start_acquisition_i <= 0
#    dut.prescaler_i <= 0
#    dut.update_presc_i <= 0
#    dut.start_i <= 0
#    dut.trig_i <= 0
#    dut.dflt_val_i <= 0
#
#    reset_n = dut.rst_i
#
#    cocotb.fork(Clock(dut.clk_i, 10, 'ns').start())
#    yield reset_dut(reset_n, dut.clk_i, 500)
#
#    dut._log.debug("After reset")
#
#    # now correct behavior
#    yield RisingEdge(dut.clk_i)
#    dut.update_presc_i <= 1
#    dut.prescaler_i <= 2
#    yield RisingEdge(dut.clk_i);
#    dut.update_presc_i <= 0
#    yield RisingEdge(dut.clk_i);
#    dut.select_input_i <= 2
#    yield RisingEdge(dut.clk_i);
#
#    dut.start_acquisition_i <= 1
#    yield RisingEdge(dut.clk_i);
#    dut.start_acquisition_i <= 0
#    yield RisingEdge(dut.clk_i);
#
#    dut.start_i <= 1
#    yield RisingEdge(dut.clk_i);
#    yield RisingEdge(dut.clk_i);
#    dut.trig_i <= 1
#    yield RisingEdge(dut.clk_i);
#    dut.trig_i <= 0
#
#    yield RisingEdge(dut.clk_i)
#    #yield RisingEdge(dut.m_axis_tlast)
#    yield RisingEdge(dut.clk_i)
#    for i in range(0, 40):
#        yield RisingEdge(dut.clk_i)
#
#
#    yield RisingEdge(dut.clk_i)
#    dut.dflt_val_i <= 100    
#    dut.start_acquisition_i <= 1
#    yield RisingEdge(dut.clk_i);
#    dut.start_acquisition_i <= 0
#    yield RisingEdge(dut.clk_i)
#    dut.trig_i <= 1
#    yield RisingEdge(dut.clk_i);
#    dut.trig_i <= 0
#    yield RisingEdge(dut.clk_i)
#    #yield RisingEdge(dut.m_axis_tlast)
#    yield RisingEdge(dut.clk_i)
#    for i in range(0, 40):
#        yield RisingEdge(dut.clk_i)

@cocotb.test()
def verif_pulse(dut):
    dut.select_input_i <= 0
    dut.data1_i <= 0
    dut.data2_i <= 0
    dut.data_en_i <= 0
    dut.data_sof_i <= 0
    dut.data_eof_i <= 0
    dut.start_acquisition_i <= 0
    dut.prescaler_i <= 0
    dut.update_presc_i <= 0
    dut.start_i <= 0
    dut.trig_i <= 0
    dut.dflt_val_i <= 0
    dut.period_cnt_i <= 50
    dut.duty_cnt_i <= 10
    dut.enable_i <= 0

    reset_n = dut.rst_i

    cocotb.fork(Clock(dut.clk_i, 10, 'ns').start())
    yield reset_dut(reset_n, dut.clk_i, 500)

    dut._log.debug("After reset")

    # now correct behavior
    yield RisingEdge(dut.clk_i)
    dut.update_presc_i <= 1
    dut.prescaler_i <= 2
    yield RisingEdge(dut.clk_i);
    dut.update_presc_i <= 0
    yield RisingEdge(dut.clk_i);
    dut.select_input_i <= 2
    yield RisingEdge(dut.clk_i);

    # start dataToRam
    dut.start_acquisition_i <= 1
    yield RisingEdge(dut.clk_i);
    dut.start_acquisition_i <= 0
    yield RisingEdge(dut.clk_i);
    # start pseudoGen
    dut.start_i <= 1
    yield RisingEdge(dut.clk_i);
    yield RisingEdge(dut.clk_i);
    # start pulseDelay
    dut.enable_i <= 1
    for i in range(0, 10):
        yield RisingEdge(dut.clk_i);
    dut.enable_i <= 0

    yield RisingEdge(dut.clk_i)
    #yield RisingEdge(dut.m_axis_tlast)
    yield RisingEdge(dut.clk_i)
    for i in range(0, 40):
        yield RisingEdge(dut.clk_i)

    yield RisingEdge(dut.clk_i)
    # reconfigure pseudoGen and start dataToRam
    dut.dflt_val_i <= 100    
    dut.start_acquisition_i <= 1
    yield RisingEdge(dut.clk_i);
    dut.start_acquisition_i <= 0
    # restart pulseDelay
    yield RisingEdge(dut.clk_i)
    dut.enable_i <= 1
    for i in range(0, 10):
        yield RisingEdge(dut.clk_i);
    dut.enable_i <= 0
    yield RisingEdge(dut.clk_i)
    #yield RisingEdge(dut.m_axis_tlast)
    yield RisingEdge(dut.clk_i)
    for i in range(0, 40):
        yield RisingEdge(dut.clk_i)
