import random
import logging

import cocotb

from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge, FallingEdge

@cocotb.coroutine
def reset_dut(reset_n, clk, duration):
    reset_n.value = 1
    yield RisingEdge(clk)
    yield Timer(duration)
    yield RisingEdge(clk)
    reset_n.value = 0
    #reset_n._log.debug("Reset complete")

@cocotb.coroutine
def prepare_simu(dut, start, length):
    dut.data_en_i.value   = 0
    dut.data_sof_i.value  = 0
    dut.data_eof_i.value  = 0
    dut.data_i.value      = 0
    
    reset_n = dut.rst_i
    cocotb.start_soon(Clock(dut.clk_i, 10, 'ns').start())
    yield reset_dut(reset_n, dut.clk_i, 500)

    dut._log.debug("After reset")
    yield FallingEdge(dut.clk_i)
    yield FallingEdge(dut.clk_i)

@cocotb.coroutine
def post_simu(dut):
    dut.ref_en_i.value = 0

    yield FallingEdge(dut.clk_i)
    yield FallingEdge(dut.clk_i)

    for _ in range(3000):
        yield FallingEdge(dut.clk_i)

@cocotb.test()
def dec3_example(dut):
    yield prepare_simu(dut, 10, 10)

    yield FallingEdge(dut.clk_i)
    for i in range(2**10):
        dut.data_sof_i.value = int(i == 0)
        dut.data_eof_i.value = int(i == 50)
        dut.data_en_i.value  = 1
        dut.data_i.value     = 1+i
        yield FallingEdge(dut.clk_i)
        dut.data_en_i.value  = 0
        yield FallingEdge(dut.clk_i)
        #yield RisingEdge(dut.clk_i)
    post_simu(dut)
