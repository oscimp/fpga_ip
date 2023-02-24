import random
import logging

import cocotb

from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge, FallingEdge

clock_period = 10

@cocotb.coroutine
def reset_dut(reset_n, clk, duration):
    reset_n.value = 1
    yield RisingEdge(clk)
    yield Timer(duration)
    yield RisingEdge(clk)
    reset_n.value = 0
    reset_n._log.debug("Reset complete")


@cocotb.test()
def parallel_example(dut):
    #vi = [-32768, -1000, 0, 1000, 32767, -32768, -1000, 0, 1000, 32767]
    #vq = [-32768, -1000, 0, 1000, 32767, 32767, 1000, 0, -1000, -32768]
    min_v = int(-2**(10-1))
    max_v = int((2**(10-1))-1)

    dut.data_en_i.value = 0

    reset_n = dut.rst_i

    cocotb.fork(Clock(dut.clk_i, 10, 'ns').start())
    yield reset_dut(reset_n, dut.clk_i, 500)

    dut._log.debug("After reset")
    yield FallingEdge(dut.clk_i)
    yield FallingEdge(dut.clk_i)

    for i in range(min_v, max_v):
        for q in range(min_v, max_v):
            if q < 0:
                sign = -1
            else:
                sign = 1
            dut.data_en_i.value = 1
            dut.data_i_i.value = i
            dut.data_q_i.value = q
            #print(f"{i} {vi[i]} {vq[i]}")
            yield FallingEdge(dut.clk_i)
            dut.data_en_i.value = 0
            yield FallingEdge(dut.clk_i)
            res = i * i + q * q
            uns_out = int(dut.data_uns_o.value.signed_integer)
            sign_out = int(dut.data_sign_o.value.signed_integer)
            print(f"{q:4} {i:4} {res:6} <=> {uns_out:6} {res*sign:7} <=> {sign_out:7}")
            assert res == uns_out, f"wrong unsigned res {uns_out} -> {res}"
            assert sign * res == sign_out, f"wrong signed res {sign_out} -> {sign * res}"
    dut.data_en_i.value = 0
