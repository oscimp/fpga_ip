import random
import logging

import cocotb

from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge, FallingEdge

from math import *

clock_period = 100

@cocotb.coroutine
def reset_dut(reset_n, clk_i, duration):
    reset_n <= 1
    yield Timer(duration)
    yield RisingEdge(clk_i)
    reset_n <= 0
    reset_n._log.debug("Reset complete")

@cocotb.test()
def verif_lt(dut):
    # configuration
    duty = 1200
    period = 10000
    prescaler = 10
    clk_period = 10
    tick_len = prescaler * clk_period

    #reset_n = dut.rst_i
    dut.enable_i <= 0
    dut.duty_i <= 0
    dut.period_i <= 0
    dut.prescaler_i <= 0
    cocotb.fork(Clock(dut.clk_i, clk_period, 'ns').start())
    yield reset_dut(dut.rst_i, dut.clk_i, 500)
    dut._log.debug("After reset")

    yield RisingEdge(dut.clk_i)
    yield RisingEdge(dut.clk_i)

    dut.prescaler_i <= prescaler
    dut.period_i <= int(period/tick_len)
    dut.duty_i <= int(duty/tick_len)
    yield RisingEdge(dut.clk_i)
    dut.enable_i <= 1;

    # first value
    yield FallingEdge(dut.clk_i)
    assert(int(dut.pwm1_o.value.get_value()) == int(1))
    assert(int(dut.pwm2_o.value.get_value()) == int(0))

    for ii in range(0, 3):
        for i in range(0, int(duty/prescaler)):
            assert(int(dut.pwm1_o.value.get_value()) == int(1))
            assert(int(dut.pwm2_o.value.get_value()) == int(0))
            yield FallingEdge(dut.clk_i)
        assert(int(dut.pwm1_o.value.get_value()) == int(0))
        assert(int(dut.pwm2_o.value.get_value()) == int(1))
        for i in range(0, int((period-duty)/prescaler)):
            assert(int(dut.pwm1_o.value.get_value()) == int(0))
            assert(int(dut.pwm2_o.value.get_value()) == int(1))
            yield FallingEdge(dut.clk_i)
        assert(int(dut.pwm1_o.value.get_value()) == int(1))
        assert(int(dut.pwm2_o.value.get_value()) == int(0))
