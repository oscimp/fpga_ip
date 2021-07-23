import random
import logging

import cocotb

from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge, FallingEdge

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
    val = [i for i in range(-2**15, 2**15, 10)]

    val_max = 127
    val_min = -128

    dut.data_en_i <= 0

    reset_n = dut.rst_i

    cocotb.fork(Clock(dut.clk_i, 10, 'ns').start())
    yield reset_dut(reset_n, dut.clk_i, 500)

    dut._log.debug("After reset")
    yield FallingEdge(dut.clk_i)
    yield FallingEdge(dut.clk_i)

    for i in val:
        dut.data_en_i <= 1
        dut.data_i <= i
        yield FallingEdge(dut.clk_i)
        dut.data_en_i <= 0
        yield FallingEdge(dut.clk_i)
        if i < val_min:
            res = val_min
        elif i > val_max:
            res = val_max
        else:
            res = i
        print(f"{i} {res} {int(dut.data_o.value.signed_integer)}")
        assert res == int(dut.data_o.value.signed_integer)
    dut.data_en_i <= 0
