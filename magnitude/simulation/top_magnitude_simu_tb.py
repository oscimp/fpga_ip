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
    vi = [-32768, -1000, 0, 1000, 32767, -32768, -1000, 0, 1000, 32767]
    vq = [-32768, -1000, 0, 1000, 32767, 32767, 1000, 0, -1000, -32768]

    dut.data_en_i <= 0

    reset_n = dut.rst_i

    cocotb.fork(Clock(dut.clk_i, 10, 'ns').start())
    yield reset_dut(reset_n, dut.clk_i, 500)

    dut._log.debug("After reset")
    yield FallingEdge(dut.clk_i)
    yield FallingEdge(dut.clk_i)

    for i in range(len(vi)):
        dut.data_en_i <= 1
        dut.data_i_i <= vi[i]
        dut.data_q_i <= vq[i]
        print(f"{i} {vi[i]} {vq[i]}")
        yield FallingEdge(dut.clk_i)
        dut.data_en_i <= 0
        yield FallingEdge(dut.clk_i)
        res = vq[i] * vq[i] + vi[i] * vi[i]
        print(f"{res} {int(dut.data_o.value.signed_integer)}")
        assert res == int(dut.data_o.value.signed_integer)
    dut.data_en_i <= 0
