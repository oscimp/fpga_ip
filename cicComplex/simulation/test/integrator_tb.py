import os
import random
import math
import logging
import pathlib
import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import lfilter
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge, FallingEdge
from cocotb.types import LogicArray
from cocotb.runner import get_runner, Simulator

np.seterr(divide='ignore', invalid='ignore');

#DIFFERENTIAL_DELAY = 2  # Number of samples per stage (usually 1) 
DATA_SIZE = 16
NORMALIZE_FREQUENCY = False
CLOCK_PERIOD = 8  # in ns
FS = 125e6  # Sampling frequency (in Hz)
STIMULI_SIZE = 256


# ============================================================================
def integrator(source):
    """'Theoritical' integrator.
    from https://www.gibbard.me/cic_filters/cic_filters_ipython.html
    """
    delay = 0
    outData = [0]
    for sample in source:
        y = delay + sample    
        outData.append(y)
        delay = y
    return outData[:-1]


# ============================================================================
async def reset_dut(reset_n, clk, duration):
    reset_n.value = 1
    await FallingEdge(clk)
    reset_n.value = 0
    await Timer(duration)
    await RisingEdge(clk)
    reset_n.value = 1
    reset_n._log.debug("Reset complete")


# ============================================================================
@cocotb.test()
async def integrator_filter_impulse_response_test(dut):
    """Analyze filter frequency response.
    """
    # Initialize
    dut.data_i_i.value = 0
    dut.data_q_i.value = 0
    if NORMALIZE_FREQUENCY is True:
        fs = 1
    else:
        fs = FS
    num_clks = 128  # Length of stimuli input
    nfft     = num_clks; 

    # Check generic parameter values consistency between DUT and simulator
    assert int(dut.DATA_SIZE) == DATA_SIZE, ("Generic value mismatch: DATA_SIZE")

    # stimuli input -> Impulse
    impulse_amplitude = 1
    input_signal = [impulse_amplitude]+[0]*(nfft-1)

    # bit accurate predictor values
    integrator_theo_response = integrator(input_signal)

    # start simulator clock
    cocotb.start_soon(Clock(dut.clk, CLOCK_PERIOD, units="ns").start())

    # Reset DUT
    await reset_dut(dut.reset, dut.clk, 20)
    print("!!! After reset !!! ")

    integrator_complex_response_i = np.zeros(int(num_clks))
    integrator_complex_response_q = np.zeros(int(num_clks))

    # run through each clock
    for samp in range(num_clks):
         # feed a new input in
        dut.data_i_i.value = int(input_signal[samp])
        dut.data_q_i.value = int(input_signal[samp])

        await RisingEdge(dut.clk)

        # get the output at rising edge
        integrator_complex_response_i[samp] = dut.data_i_o.value.signed_integer
        integrator_complex_response_q[samp] = dut.data_i_o.value.signed_integer
        
        # wait until reset is over, then start the assertion checking
        if(samp>=2):
            assert integrator_complex_response_i[samp]  == integrator_theo_response[samp], "filter result is incorrect: %d != %d" % (integrator_complex_response_i[samp], integrator_theo_response[samp])
            assert integrator_complex_response_q[samp]  == integrator_theo_response[samp], "filter result is incorrect: %d != %d" % (integrator_complex_response_q[samp], integrator_theo_response[samp])

    integrator_theo_fft  = 20*np.log10(np.abs(np.fft.fft(integrator_theo_response)))
    integrator_complex_fft_i  = 20*np.log10(np.abs(np.fft.fft(integrator_complex_response_i)))

    time_max_idx = num_clks
    plt.figure(1)
    plt.subplot(1,2,1)
    plt.plot(integrator_complex_response_i[:time_max_idx], marker='x')
    plt.plot(integrator_theo_response[:time_max_idx], marker='.')
    plt.plot(input_signal[:time_max_idx])
    plt.legend(['DUT I', 'Theory', 'Impulse'])
    plt.title('Time domain: Impulse response')
    plt.subplot(1,2,2)
    plt.stem(integrator_complex_response_i-integrator_theo_response)
    plt.title('error : DUT - Golden Reference')

    if NORMALIZE_FREQUENCY is True:
        xaxis = np.arange(0, 0.5, 1/nfft)
    else:
        xaxis = np.arange(0, fs/2, fs/nfft)

    plt.figure(2)
    plt.plot(xaxis, integrator_complex_fft_i[0:int(nfft/2)], marker='x')
    plt.plot(xaxis, integrator_theo_fft[0:int(nfft/2)], marker='.')
    plt.legend(['DUT I', 'Theory'])
    plt.title('Filter frequency Domain Response')

    plt.grid()
    if NORMALIZE_FREQUENCY is True:
        plt.xlabel('Normalized Frequency')
        plt.xlim([0, .5])
    else:
        plt.xlabel('Absolute Frequency')
        plt.xlim([0, fs/2])
    plt.ylabel('dB')
    
    plt.show()


# ============================================================================
def integrator_tb_runner():
    print("Begin integrator_tb_runner()")
    hdl_toplevel_lang = os.getenv("HDL_TOPLEVEL_LANG", "vhdl")
    sim = os.getenv("SIM", "ghdl")

    proj_path = pathlib.Path(__file__).resolve().parent
    vhdl_sources = [
        proj_path / "../../hdl/common.vhd",
        proj_path / "../../hdl/integrator.vhd",
        ]

    runner = get_runner(sim)

    print("Build HDL")
    runner.build(
        vhdl_sources=vhdl_sources,
        hdl_toplevel="integrator",
        parameters={"DATA_SIZE": DATA_SIZE},
        always=True,
        build_args=['--ieee=synopsys', '-fexplicit',],
        build_dir=proj_path / "sim_build/",
    )

    print("Start test")
    runner.test(
        hdl_toplevel="integrator", 
        test_module="integrator_tb,",
        waves=True,
        test_args=['--ieee=synopsys', '-fexplicit', '-v'],
        plusargs=['--wave=integrator_waves.ghw',],
        build_dir=proj_path / "sim_build/",
        test_dir=proj_path / "sim_build/",
        )


# ============================================================================
if __name__ == "__main__":
    integrator_tb_runner()
