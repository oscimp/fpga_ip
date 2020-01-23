import random
import logging

import cocotb

from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge, FallingEdge

from math import *

clock_period = 100

@cocotb.coroutine
def reset_dut(reset_n, duration):
    reset_n <= 1
    yield Timer(duration)
    reset_n <= 0
    reset_n._log.debug("Reset complete")

@cocotb.coroutine
def clock_gen(signal, period=10000):
    while True:
        signal <= 0
        yield Timer(period/2)
        signal <= 1
        yield Timer(period/2)

nb_sample = 2048 * 4

@cocotb.test()
def verif_lt(dut):
    reset_n = dut.rst_i
    dut.data_en_i <= 0
    dut.data1_i_i <= 0
    dut.data1_q_i <= 0
    dut.data2_i_i <= 0
    dut.data2_q_i <= 0
    dut.period_cnt_i <= 100
    dut.duty_cnt_i   <= 10

    cocotb.fork(clock_gen(dut.clk_i, period=clock_period))
    yield reset_dut(reset_n, 500)

    dut._log.debug("After reset")
    yield RisingEdge(dut.clk_i)
    yield RisingEdge(dut.clk_i)
    for i in range (0, nb_sample):
        dut.data1_i_i <= i
        dut.data1_q_i <= i+10
        dut.data2_i_i <= i+20
        dut.data2_q_i <= i+30
        dut.data_en_i <= 1
        yield RisingEdge(dut.clk_i)
        dut.data_en_i <= 0
        for ii in range (0, 3):
            yield RisingEdge(dut.clk_i)
