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

@cocotb.test()
def addConst_lt_Signed(dut):
    reset_n = dut.i_rst
    dut.i_add_val_signed.value   = 0
    dut.i_data_signed.value      = 0
    dut.i_data_en_signed.value   = 0
    dut.i_add_val_unsigned.value = 0
    dut.i_data_unsigned.value    = 0
    dut.i_data_en_unsigned.value = 0

    cocotb.start_soon(Clock(dut.i_clk, 10, 'ns').start())
    yield reset_dut(reset_n, dut.i_clk, 500)

    dut._log.debug("After reset")
    yield FallingEdge(dut.i_clk)
    yield FallingEdge(dut.i_clk)

    min_val = -(2**7)
    max_val = (2**7)-1
    for i in range(min_val, max_val+1):
        dut.i_add_val_signed.value = i
        for ii in range(min_val, max_val+1):
            dut.i_data_signed.value = ii
            dut.i_data_en_signed.value = 1
            yield FallingEdge(dut.i_clk)
            dut.i_data_en_signed.value = 0
            yield FallingEdge(dut.i_clk)
            th = i + ii
            dut_val = dut.o_data_signed.value.signed_integer
            assert th == dut_val, f"gte {i} + {ii} == {th} != {dut_val}"
            if th > (2**6) -1:
                th = (2**6) -1
            elif th < -(2**6):
                th = -(2**6)
            dut_val = dut.o_data_lt_signed.value.signed_integer
            assert th == dut_val, f"lt  {i} + {ii} == {th} != {dut_val}"

@cocotb.test()
def addConst_Unsigned(dut):
    reset_n = dut.i_rst
    dut.i_add_val_signed.value   = 0
    dut.i_data_signed.value      = 0
    dut.i_data_en_signed.value   = 0
    dut.i_add_val_unsigned.value = 0
    dut.i_data_unsigned.value    = 0
    dut.i_data_en_unsigned.value = 0

    cocotb.start_soon(Clock(dut.i_clk, 10, 'ns').start())
    yield reset_dut(reset_n, dut.i_clk, 500)

    dut._log.debug("After reset")
    yield FallingEdge(dut.i_clk)
    yield FallingEdge(dut.i_clk)

    min_val = 0
    max_val = (2**8)-1
    for i in range(min_val, max_val+1):
        dut.i_add_val_unsigned.value = i
        for ii in range(min_val, max_val+1):
            dut.i_data_unsigned.value = ii
            dut.i_data_en_unsigned.value = 1
            yield FallingEdge(dut.i_clk)
            dut.i_data_en_unsigned.value = 0
            yield FallingEdge(dut.i_clk)
            th = i + ii
            dut_val = dut.o_data_unsigned.value.integer
            assert th == dut_val, f"gte {i} + {ii} == {th} != {dut_val}"
            if th > (2**7) -1:
                th = (2**7) -1
            dut_val = dut.o_data_lt_unsigned.value.integer
            assert th == dut_val, f"lt {i} + {ii} == {th} != {dut_val}"
