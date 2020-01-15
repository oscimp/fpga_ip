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

@cocotb.test()
def verif_pulse(dut):
    dut.data1_i <= 0
    #dut.data2_i <= 0
    dut.data_en_i <= 0
    #dut.data_sof_i <= 0
    #dut.data_eof_i <= 0
    dut.start_acquisition_i <= 0

    reset_n = dut.rst_i

    cocotb.fork(Clock(dut.clk_i, 10, 'ns').start())
    yield reset_dut(reset_n, dut.clk_i, 500)

    dut._log.debug("After reset")

    # now correct behavior
    yield RisingEdge(dut.clk_i);

    # start dataToRam
    dut.start_acquisition_i <= 1
    yield RisingEdge(dut.clk_i);
    dut.start_acquisition_i <= 0
    yield RisingEdge(dut.clk_i);
    yield RisingEdge(dut.clk_i)
    yield RisingEdge(dut.clk_i)
    yield RisingEdge(dut.clk_i)
    for i in range(0, 15):
        dut.data_en_i <= 1
        dut.data1_i <= i
        yield RisingEdge(dut.clk_i)
        if (i == 0):
            assert(int(dut.m_axis_tvalid) == 0)
        elif (i < 11):
            assert(int(dut.m_axis_tvalid) == 1)
            assert(int(dut.m_axis_tdata) == i-1)
            if (i == 10):
                assert(int(dut.m_axis_tlast) == 1)
        else:
            assert(int(dut.m_axis_tvalid) == 0)
    dut.data_en_i <= 0
    dut.start_acquisition_i <= 1
    yield RisingEdge(dut.clk_i);
    dut.start_acquisition_i <= 0
    yield RisingEdge(dut.clk_i);
    yield RisingEdge(dut.clk_i)
    yield RisingEdge(dut.clk_i)
    yield RisingEdge(dut.clk_i)

    # slow data rate 
    for i in range(0, 15):
        dut.data_en_i <= 1
        dut.data1_i <= i
        yield RisingEdge(dut.clk_i)
        dut.data_en_i <= 0
        yield RisingEdge(dut.clk_i)
        if (i < 10):
            assert(int(dut.m_axis_tvalid) == 1)
            assert(int(dut.m_axis_tdata) == i)
            if (i == 10):
                assert(int(dut.m_axis_tlast) == 1)
        else:
            assert(int(dut.m_axis_tvalid) == 0)
