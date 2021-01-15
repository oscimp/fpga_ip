import random
import logging

import cocotb

from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge, FallingEdge

clock_period = 10

@cocotb.coroutine
def reset_dut(reset_n, clk, duration):
    reset_n <= 1
    yield RisingEdge(clk)
    yield Timer(duration)
    yield RisingEdge(clk)
    reset_n <= 0
    reset_n._log.debug("Reset complete")


@cocotb.test()
def parallel_example(dut):
    dut.data_en_i <= 0

    reset_n = dut.rst_i

    cocotb.fork(Clock(dut.clk_i, 10, 'ns').start())
    yield reset_dut(reset_n, dut.clk_i, 500)

    dut._log.debug("After reset")
    yield FallingEdge(dut.clk_i)
    yield FallingEdge(dut.clk_i)

    for i in range(200):
        dut.data_en_i <= 1
        dut.data_i_i <= i - 100
        dut.data_q_i <= i - 100
        yield FallingEdge(dut.clk_i)
        assert i - 100 == int(dut.data_i_o.value.signed_integer)
        assert -(i - 100) == int(dut.data_q_o.value.signed_integer)
    dut.data_en_i <= 0
