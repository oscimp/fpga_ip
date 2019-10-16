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

@cocotb.coroutine
def send_data(dut, data_i_o, data_q_o, data_en_o, 
                data_i, data_q, nco_data_i, nco_data_q, res_i, res_q, nb_cycle):
    dut.nco_i_i <= nco_data_i
    dut.nco_q_i <= nco_data_q
    dut.nco_en_i <= 1
    dut.data_i_i <= int(data_i)
    dut.data_q_i <= int(data_q)
    dut.data_en_i <= 1
    yield RisingEdge(dut.clk_i)
    dut.data_en_i <= 0
    dut.nco_en_i <= 0
    for i in range (0, nb_cycle):
        assert(int(data_en_o.value) == int(0))
        yield RisingEdge(dut.clk_i)
    assert(int(data_en_o.value) == int(1))
    assert(int(data_i_o.value.get_value_signed()) == int(res_i))
    assert(int(data_q_o.value.get_value_signed()) == int(res_q))
    yield RisingEdge(dut.clk_i)

@cocotb.test()
def verif_lt(dut):
    shift = 16 # gain de 15 pour avoir des donnees signed sur 16bits
    nco_val_i = int(pow(2,7)-1)
    nco_val_q = int(pow(2,7)-1)+10
    reset_n = dut.rst_i
    dut.data_en_i <= 0
    dut.data_i_i <= 0
    dut.data_q_i <= 0
    dut.nco_en_i <= 0
    dut.nco_i_i <= 0
    dut.nco_q_i <= 0
    cocotb.fork(clock_gen(dut.clk_i, period=clock_period))
    yield reset_dut(reset_n, 500)
    dut._log.debug("After reset")
    yield RisingEdge(dut.clk_i)
    yield RisingEdge(dut.clk_i)
    for i in range (0, nb_sample):
        data_i = i-(nb_sample/2)
        data_q = i-(nb_sample/2)+50
        res_i = int((data_i*nco_val_i-data_q*nco_val_q)/pow(2,shift))
        res_q = int((data_i*nco_val_q+data_q*nco_val_i)/pow(2,shift))
        yield send_data(dut, dut.data_lt_i_o, dut.data_lt_q_o, dut.data_lt_en_o,
            data_i, data_q, nco_val_i, nco_val_q, res_i, res_q, 3)

@cocotb.test()
def verif_eq(dut):
    nco_val_i = int(pow(2,7)-1)
    nco_val_q = int(pow(2,7)-1)+10
    reset_n = dut.rst_i
    dut.data_en_i <= 0
    dut.data_i_i <= 0
    dut.data_q_i <= 0
    dut.nco_en_i <= 0
    dut.nco_i_i <= 0
    dut.nco_q_i <= 0
    cocotb.fork(clock_gen(dut.clk_i, period=clock_period))
    yield reset_dut(reset_n, 500)
    dut._log.debug("After reset")
    yield RisingEdge(dut.clk_i)
    yield RisingEdge(dut.clk_i)
    for i in range (0, nb_sample):
        data_i = i-(nb_sample/2)
        data_q = i-(nb_sample/2)+50
        res_i = int((data_i*nco_val_i-data_q*nco_val_q))
        res_q = int((data_i*nco_val_q+data_q*nco_val_i))
        yield send_data(dut, dut.data_eq_i_o, dut.data_eq_q_o, dut.data_eq_en_o,
            data_i, data_q, nco_val_i, nco_val_q, res_i, res_q, 2)

@cocotb.test()
def verif_gt(dut):
    nco_val_i = int(pow(2,7)-1)
    nco_val_q = int(pow(2,7)-1)+10
    reset_n = dut.rst_i
    dut.data_en_i <= 0
    dut.data_i_i <= 0
    dut.data_q_i <= 0
    dut.nco_en_i <= 0
    dut.nco_i_i <= 0
    dut.nco_q_i <= 0
    cocotb.fork(clock_gen(dut.clk_i, period=clock_period))
    yield reset_dut(reset_n, 500)
    dut._log.debug("After reset")
    yield RisingEdge(dut.clk_i)
    yield RisingEdge(dut.clk_i)
    for i in range (0, nb_sample):
        data_i = i-(nb_sample/2)
        data_q = i-(nb_sample/2)+50
        res_i = int((data_i*nco_val_i-data_q*nco_val_q))
        res_q = int((data_i*nco_val_q+data_q*nco_val_i))
        yield send_data(dut, dut.data_gt_i_o, dut.data_gt_q_o, dut.data_gt_en_o,
            data_i, data_q, nco_val_i, nco_val_q, res_i, res_q, 2)
