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
def addConstSigned(dut):
    reset_n = dut.i_rst
    dut.i_add_val_signed.value   = 0
    dut.i_data_signed.value      = 0
    dut.i_data_en_signed.value   = 0
    dut.i_add_val_unsigned.value = 0
    dut.i_data_unsigned.value    = 0
    dut.i_data_en_unsigned.value = 0

    cocotb.fork(Clock(dut.i_clk, 10, 'ns').start())
    yield reset_dut(reset_n, dut.i_clk, 500)

    dut._log.debug("After reset")
    yield FallingEdge(dut.i_clk)
    yield FallingEdge(dut.i_clk)

    min_val = -(2**7)
    max_val = (2**7)-1
    for i in range(min_val, max_val):
        dut.i_add_val_signed.value = i
        for ii in range(min_val, max_val):
            dut.i_data_signed.value = ii
            dut.i_data_en_signed.value = 1
            yield FallingEdge(dut.i_clk)
            dut.i_data_en_signed.value = 0
            yield FallingEdge(dut.i_clk)
            assert i+ii == dut.o_data_signed.value.signed_integer

#@cocotb.test()
#def addConstUnSigned(dut):
#    reset_n = dut.i_rst
#    dut.i_add_val_signed.value   = 0
#    dut.i_data_signed.value      = 0
#    dut.i_data_en_signed.value   = 0
#    dut.i_add_val_unsigned.value = 0
#    dut.i_data_unsigned.value    = 0
#    dut.i_data_en_unsigned.value = 0
#
#    cocotb.fork(Clock(dut.i_clk, 10, 'ns').start())
#    yield reset_dut(reset_n, dut.i_clk, 500)
#
#    dut._log.debug("After reset")
#    yield FallingEdge(dut.i_clk)
#    yield FallingEdge(dut.i_clk)
#
#    for i in range(2**8):
#        dut.i_add_val_unsigned.value = i
#        for ii in range(2**8):
#            dut.i_data_unsigned.value = ii
#            dut.i_data_en_unsigned.value = 1
#            yield FallingEdge(dut.i_clk)
#            dut.i_data_en_unsigned.value = 0
#            yield FallingEdge(dut.i_clk)
#            assert i+ii == dut.o_data_unsigned.value.integer
#
