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
from cocotb_tools.runner import get_runner


np.seterr(divide='ignore', invalid='ignore');

DIFFERENTIAL_DELAY_TESTED = [1, 2, 4]

DATA_SIZE = 16
NORMALIZE_FREQUENCY = False
CLOCK_PERIOD = 8  # in ns
FS = 125e6  # Sampling frequency (in Hz)
STIMULI_SIZE = 256

# ============================================================================
def wave(amp, f, fs, clks): 
    clks = np.arange(0, clks)
    sample = np.rint(amp*np.sin(2.0*np.pi*f/fs*clks))
    print(amp)
    return sample


def comb(source, ddelay):
    """'Theoritical' comb.
    from https://www.gibbard.me/cic_filters/cic_filters_ipython.html
    """
    outData = [0]
    delay = [0] * ddelay
    for sample in source:
        outData.append(sample - delay[-1])
        delay = [sample] + delay
        delay.pop()
    return outData[:-1]


# ============================================================================
async def reset_dut(reset_n, clk, duration):
    reset_n.value = 0
    await FallingEdge(clk)
    reset_n.value = 1
    await Timer(duration)
    await RisingEdge(clk)
    reset_n.value = 0
    reset_n._log.debug("Reset complete")


# ============================================================================
@cocotb.test()
async def comb_filter_impulse_response_test(dut):
    """Analyze filter frequency response.
    """
    # Initialize
    dut.data_i_i.value = 0
    dut.data_q_i.value = 0

    if NORMALIZE_FREQUENCY is True:
        fs = 1
    else:
        fs = FS
    num_clks = STIMULI_SIZE  # Length of stimuli input
    nfft     = num_clks; 

    # stimuli input -> Impulse
    impulse_amplitude = 1
    input_signal = [impulse_amplitude]+[0]*(nfft-1)

    # bit accurate predictor values
    comb_theo_response = comb(input_signal, int(dut.DIFFERENTIAL_DELAY.value))

    # start simulator clock
    cocotb.start_soon(Clock(dut.clk, CLOCK_PERIOD, unit="ns").start())

    # Reset DUT
    await reset_dut(dut.reset, dut.clk, 20)
    print("!!! After reset !!! ")

    comb_complex_response_i = np.zeros(int(num_clks))
    comb_complex_response_q = np.zeros(int(num_clks))

    # Enable data input sampling
    dut.data_en_i.value = 1

    # run through each clock
    for samp in range(num_clks):
         # feed a new input in
        dut.data_i_i.value = int(input_signal[samp])
        dut.data_q_i.value = int(input_signal[samp])
        await RisingEdge(dut.clk)
        # get the output at rising edge
        comb_complex_response_i[samp] = dut.data_i_o.value.to_signed()
        comb_complex_response_q[samp] = dut.data_q_o.value.to_signed()
        # wait until reset is over, then start the assertion checking
        if(samp>=2):
            assert comb_complex_response_i[samp] == comb_theo_response[samp], "filter result is incorrect: %d != %d" % (comb_complex_response_i[samp], comb_theo_response[samp])
            assert comb_complex_response_q[samp] == comb_theo_response[samp], "filter result is incorrect: %d != %d" % (comb_complex_response_q[samp], comb_theo_response[samp])

    comb_theo_fft  = 20*np.log10(np.abs(np.fft.fft(comb_theo_response)))
    comb_complex_fft_i  = 20*np.log10(np.abs(np.fft.fft(comb_complex_response_i)))

    time_max_idx = num_clks
    plt.figure(1)
    plt.plot(comb_complex_response_i[:time_max_idx], marker='x')
    plt.plot(comb_theo_response[:time_max_idx], marker='.')
    plt.plot(input_signal[:time_max_idx])
    plt.legend(['DUT I', 'Theory', 'Impulse'])
    plt.title(f'Time domain: Impulse response Comb delay {int(dut.DIFFERENTIAL_DELAY.value)}')

    if NORMALIZE_FREQUENCY is True:
        xaxis = np.arange(0, 0.5, 1/nfft)
    else:
        xaxis = np.arange(0, fs/2, fs/nfft)

    plt.figure(2)
    plt.plot(xaxis, comb_complex_fft_i[0:int(nfft/2)], marker='x')
    plt.plot(xaxis, comb_theo_fft[0:int(nfft/2)], marker='.')
    plt.legend(['DUT I', 'Theory'])
    plt.title(f'Comb delay {int(dut.DIFFERENTIAL_DELAY.value)} frequency Domain Response')

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
def comb_tb_runner(differential_delay: int) -> None:
    print("Begin comb_tb_runner()")
    hdl_toplevel_lang = os.getenv("HDL_TOPLEVEL_LANG", "vhdl")
    sim = os.getenv("SIM", "ghdl")

    proj_path = pathlib.Path(__file__).resolve().parent
    vhdl_sources = [
        proj_path / "../../hdl/common.vhd",
        proj_path / "../../hdl/comb.vhd",
        ]

    runner = get_runner(sim)

    print("Build HDL")
    runner.build(
        sources=vhdl_sources,
        hdl_toplevel="comb",
        parameters={"DIFFERENTIAL_DELAY": differential_delay,
                    "DATA_SIZE": DATA_SIZE},
        always=True,
        build_args=['--ieee=synopsys', '-fexplicit',],
        build_dir=proj_path / "sim_build/",
    )

    print("Start test")
    runner.test(
        hdl_toplevel="comb", 
        test_module="comb_tb,",
        waves=True,
        test_args=['--ieee=synopsys', '-fexplicit', '-v'],
        plusargs=['--wave=comb_waves.ghw',],
        build_dir=proj_path / "sim_build/",
        test_dir=proj_path / "sim_build/",
        )


# ============================================================================
if __name__ == "__main__":
    for dd in DIFFERENTIAL_DELAY_TESTED:
        print('# ------------------------------------------------------ #')
        print('# -                                                    - #')
        print(f'# -           Differential Delay = {dd}                   - #')
        print('# -                                                    - #')
        print('# ------------------------------------------------------ #')
        comb_tb_runner(dd)
