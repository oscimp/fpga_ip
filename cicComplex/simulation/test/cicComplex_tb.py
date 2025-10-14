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

NORMALIZE_FREQUENCY = False

BIT_PRUNING = True
Bin = 25  # Input sample precision
DECIMATE_FACTOR = 32  # decimate or interpolation ratio
ORDER = 4  # Number of stages in filter
DIFFERENTIAL_DELAY = 4  # Number of samples per stage (usually 1 or 2)
Bout = 25 # ORDER * int(round(math.log2(DECIMATE_FACTOR*DIFFERENTIAL_DELAY))) + Bin # Output sample precision

FS = 125e6  # Sampling frequency (in Hz)
CLOCK_PERIOD = 8  # in ns
F_MOD = FS / 128  # About 1 MHz

STIMULI_SIZE = 4096  # Length of stimuli input


# ============================================================================
def wave(amp, f, fs, clks):
    clks = np.arange(0, clks)
    sample = np.rint(amp*np.sin(2.0*np.pi*f/fs*clks))
    return sample

def comb(source, ddelay, outDataIni=[0]):
    """'Theoritical' comb.
    from https://www.gibbard.me/cic_filters/cic_filters_ipython.html
    """
    outData = outDataIni
    delay = [0] * ddelay
    for sample in source:
        outData.append(sample - delay[-1])
        delay = [sample] + delay
        delay.pop()
    return outData

def comb_n(source, ddelay, order):
    """Cascade 'order' Comb
    """
    if order == 1:
        return comb(source, ddelay, [0])
    elif order == ORDER:
        return comb_n(comb(source, ddelay, [0]), ddelay, order-1)
    return comb_n(comb(source, ddelay, [0]), ddelay, order-1)

def integrator(source, outDataIni=[0]):
    """'Theoritical' integrator.
    from https://www.gibbard.me/cic_filters/cic_filters_ipython.html
    """
    delay = 0
    outData = outDataIni
    for sample in source:
        y = delay + sample
        outData.append(y)
        delay = y
    return outData

def integrator_n(source, order):
    """Cascade 'order' Integrator
    """
    if order == 1:
        return integrator(source, [0])
    elif order == ORDER:
        return integrator_n(integrator(source, [0]), order-1)
    return integrator_n(integrator(source, [0]), order-1)

def cic_decimator(source, decimate_factor, order, ibits, obits, delayed_delay=1):
    # Integration stage
    int_result = integrator_n(source, order)
    # Decimation
    dec_result = np.array(int_result[ : : decimate_factor])
    # Comb stage
    comb_result = comb_n(dec_result, delayed_delay, order)
    # Calculate the total number of bits used internally, and the output
    # shift and mask required.
    #numbits = order * int(round(math.log(decimate_factor)*delayed_delay / math.log(2))) + ibits
    #shift_gain = 0  #int(math.log((decimate_factor * delayed_delay)**order)/math.log(2))
    #comb_result = np.int64(comb_result) >> shift_gain
    #outmask  = (1 << obits) - 1
    #comb_result &= outmask

    return int_result, dec_result, comb_result


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
#@cocotb.test()
async def cic_wave_test(dut):
    """Test that wave propagates to output with respect to frequency"""
    print("Begin cic_wave_test()")

    Freq_in = F_MOD

    # Set initial input value to prevent it from floating
    dut.data_i_i.value = 0

    clock = Clock(dut.clk, CLOCK_PERIOD, units="ns")
    # Start the clock. Start it low to avoid issues on the first RisingEdge
    cocotb.start_soon(clock.start(start_high=False))

    # Reset DUT
    await reset_dut(dut.reset, dut.clk, 20)
    print("!!! After reset !!! ")

    # Synchronize with the clock. This will regisiter the initial input value
    await RisingEdge(dut.clk)

    #expected_val = 0  # Matches initial input value
    for freq in [Freq_in/2, 3*Freq_in/4, Freq_in, 4*Freq_in/3, 2*Freq_in, 3*Freq_in ]:
        amp = 2**(Bin-4)
        f = freq
        fs = FS
        nb_pts = 5000
        stimuli = wave(amp, f, fs, nb_pts) + freq/1024
        for i in range(nb_pts):
            dut.data_i_i.value = int(stimuli[i])
            await RisingEdge(dut.clk)
            #assert dut.data_o.value == expected_val, f"output was incorrect on the {i}th cycle"
            #expected_val = val  # Save random value for next RisingEdge

    # Check the final input on the next clock
    await RisingEdge(dut.clk)
    #assert dut.q.value == expected_val, "output q was incorrect on the last cycle"


# ============================================================================
#@cocotb.test()
async def cic_filter_impulse_response_test(dut):
    """Analyze filter frequency response.
    """
    print("Begin cic_filter_impulse_response_test()")

    if NORMALIZE_FREQUENCY is True:
        fs = 1
    else:
        fs = FS
    num_clks = STIMULI_SIZE
    nfft     = num_clks

    # Initialize
    dut.data_i_i.value = 0
    dut.data_q_i.value = 0

    # stimuli input -> Impulse
    impulse_amplitude = 1
    input_signal = [impulse_amplitude]+[0]*(nfft-1)

    # predictor values
    cic_int_theo_response, cic_dec_theo_response, cic_theo_response = cic_decimator(
        input_signal,
        int(dut.DECIMATE_FACTOR),
        int(dut.ORDER),
        int(dut.DATA_IN_SIZE),
        int(dut.DATA_OUT_SIZE),
        int(dut.DIFFERENTIAL_DELAY))
    # Repeat data sample to handle input vs output data number mismatch
    # due to decimation.
    cic_theo_response = np.repeat(cic_theo_response[1:], dut.DECIMATE_FACTOR)
    cic_dec_theo_response = np.repeat(cic_dec_theo_response, dut.DECIMATE_FACTOR)

    # start simulator clock
    cocotb.start_soon(Clock(dut.clk, CLOCK_PERIOD, units="ns").start())

    # Reset DUT
    await reset_dut(dut.reset, dut.clk, 20)
    print("!!! After reset !!! ")

    cic_int_complex_response_i = []
    for _ in range(ORDER):
        cic_int_complex_response_i.append(np.zeros(int(num_clks)))
    cic_dec_complex_response_i = np.zeros(int(num_clks))
    cic_complex_response_i = np.zeros(int(num_clks))
    cic_complex_response_q = np.zeros(int(num_clks))

    # Alway enable input data
    dut.data_en_i.value = 0

    # run through each clock
    for samp in range(num_clks):

        dut.data_i_i.value = int(input_signal[samp])
        dut.data_q_i.value = int(input_signal[samp])

        await RisingEdge(dut.clk)
        # feed a new input in

        # get the output at rising edge
        dir(dut.gen_integrator_n)
        dir(dut.gen_integrator_n._id('integrator_n(1)', extended=False))
        dir(dut.gen_integrator_n._id('integrator_n(1)', extended=False)._id('gen_int_1', extended=False))
        dir(dut.gen_integrator_n._id('integrator_n(1)', extended=False)._id('gen_int_1', extended=False)._id('int_n1', extended=False))
        cic_int_complex_response_i[1][samp] = dut.gen_integrator_n._id('integrator_n(1)', extended=False)._id('gen_int_1', extended=False)._id('int_n1', extended=False).data_i_o.value
        for i in range(1,ORDER-2):
            dir(dut.gen_integrator_n)
            dir(dut.gen_integrator_n._id(f'integrator_n({i+1})', extended=False))
            dir(dut.gen_integrator_n._id(f'integrator_n({i+1})', extended=False)._id('gen_int_i', extended=False))
            dir(dut.gen_integrator_n._id(f'integrator_n({i+1})', extended=False)._id('gen_int_i', extended=False)._id('int_ni', extended=False))
            cic_int_complex_response_i[i][samp] = dut.gen_integrator_n._id(f'integrator_n({i+1})', extended=False)._id('gen_int_i', extended=False)._id('int_ni', extended=False)._id('data_i_o', extended=False).value
        dir(dut.gen_integrator_n)
        dir(dut.gen_integrator_n._id(f'integrator_n({ORDER})', extended=False))
        dir(dut.gen_integrator_n._id(f'integrator_n({ORDER})', extended=False)._id('gen_int_order', extended=False))
        dir(dut.gen_integrator_n._id(f'integrator_n({ORDER})', extended=False)._id('gen_int_order', extended=False)._id('int_norder', extended=False))
        dir(dut.gen_integrator_n._id(f'integrator_n({ORDER})', extended=False)._id('gen_int_order', extended=False)._id('int_norder', extended=False)._id('data_i_o', extended=False))
        cic_int_complex_response_i[ORDER-1][samp] = dut.gen_integrator_n._id(f'integrator_n({ORDER})', extended=False)._id('gen_int_order', extended=False)._id('int_norder', extended=False)._id('data_i_o', extended=False).value

        #cic_complex_response_i[samp] = dut.comb_out_i_s.value.signed_integer  # No Output Normalization
        cic_complex_response_i[samp] = dut.data_i_o.value.signed_integer  # Output Normalization
        cic_complex_response_q[samp] = dut.data_q_o.value.signed_integer

        # wait until reset is over, then start the assertion checking
        #if(samp>=2):
        #    assert cic_complex_response_i[samp] == cic_theo_response[samp], "filter result is incorrect: %d != %d" % (cic_complex_response_i[samp], cic_theo_response[samp])

    time_max_idx = num_clks
    plt.figure(1)
    plt.plot(cic_complex_response_i[1:time_max_idx], marker='x')
    plt.plot(cic_theo_response[:time_max_idx], marker='.')
    plt.plot(input_signal[:time_max_idx])
    plt.legend(['DUT I', 'Theory Out', 'Impulse'])
    plt.title('Time domain: Impulse response')

    if NORMALIZE_FREQUENCY is True:
        xaxis = np.arange(0, 0.5, 1/nfft)
    else:
        xaxis = np.arange(0, fs/2, fs/nfft)

    cic_complex_fft_i = 20*np.log10(np.abs(np.fft.fft(cic_complex_response_i[1:time_max_idx+1])))
    cic_theo_fft = 20*np.log10(np.abs(np.fft.fft(cic_theo_response[:time_max_idx])))

    plt.figure(2)
    plt.plot(xaxis, cic_complex_fft_i[0:int(nfft/2)], marker='x')
    plt.plot(xaxis, cic_theo_fft[0:int(nfft/2)], marker='.')
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


#@cocotb.test()
async def cic_filter_step_response_test(dut):
    """Analyze filter step response.
    """
    print("Begin cic_filter_impulse_response_test()")

    if NORMALIZE_FREQUENCY is True:
        fs = 1
    else:
        fs = FS
    num_clks = STIMULI_SIZE
    nfft     = num_clks

    # Initialize
    dut.data_i_i.value = 0
    dut.data_q_i.value = 0

    # stimuli input -> step
    impulse_amplitude = 1
    input_signal = [impulse_amplitude]*(nfft)

    # bit accurate predictor values
    cic_theo_response = cic_decimator(
        input_signal,
        int(dut.DECIMATE_FACTOR),
        int(dut.ORDER),
        int(dut.DATA_IN_SIZE),
        int(dut.DATA_OUT_SIZE))
    # Repeat data sample to handle input vs output data number mismatch
    # due to decimate.
    cic_theo_response = np.repeat(cic_theo_response, DECIMATE_FACTOR)

    # start simulator clock
    cocotb.start_soon(Clock(dut.clk, CLOCK_PERIOD, units="ns").start())

    # Reset DUT
    await reset_dut(dut.reset, dut.clk, 20)
    print("!!! After reset !!! ")

    cic_complex_response_i = np.zeros(int(num_clks))
    cic_complex_response_q = np.zeros(int(num_clks))

    dut.data_en_i.value = 1

    # run through each clock
    for samp in range(num_clks):
        # feed a new input in
        dut.data_i_i.value = int(input_signal[samp])
        dut.data_q_i.value = int(input_signal[samp])

        await RisingEdge(dut.clk)

        # get the output at rising edge
        cic_complex_response_i[samp] = dut.data_i_o.value.signed_integer
        cic_complex_response_q[samp] = dut.data_q_o.value.signed_integer

        # wait until reset is over, then start the assertion checking
        if(samp>=2):
            assert cic_complex_response_i[samp] == cic_theo_response[samp], "filter result is incorrect: %d != %d" % (cic_complex_response_i[samp], cic_theo_response[samp])

    time_max_idx = num_clks
    plt.figure()
    plt.plot(cic_complex_response_i[:time_max_idx], marker='x')
    plt.plot(cic_complex_response_q[:time_max_idx], marker='<')
    plt.plot(cic_theo_response[:time_max_idx], marker='.')
    plt.plot(input_signal[:time_max_idx])
    plt.legend(['DUT I', 'DUT Q', 'Theory', 'Impulse'])
    plt.title('Time domain: Impulse response')
    plt.show()


# ============================================================================
@cocotb.test()
async def cic_filter_code_generation_test(dut):
    """Only check code generation"""
    print("Begin cic_filter_code_generation_test()")
    print("End cic_filter_code_generation_test()")


# ============================================================================
def cic_tb_runner():
    print("Begin cic_tb_runner()")
    hdl_toplevel_lang = os.getenv("HDL_TOPLEVEL_LANG", "vhdl")
    sim = os.getenv("SIM", "ghdl")

    proj_path = pathlib.Path(__file__).resolve().parent
    vhdl_sources = [
        proj_path / "../../hdl/common.vhd",
        proj_path / "../../hdl/comb.vhd",
        proj_path / "../../hdl/integrator.vhd",
        proj_path / "../../hdl/cicComplex_top.vhd",
        ]

    runner = get_runner(sim)

    print("Build HDL")
    runner.build(
        sources=vhdl_sources,
        hdl_toplevel="ciccomplex_top",
        parameters={"BIT_PRUNING": BIT_PRUNING,
                    "DATA_IN_SIZE": Bin,
                    "DECIMATE_FACTOR": DECIMATE_FACTOR,
                    "ORDER": ORDER,
                    "DIFFERENTIAL_DELAY": DIFFERENTIAL_DELAY,
                    "DATA_OUT_SIZE": Bout},
        always=True,
        build_args=['--ieee=synopsys', '-fexplicit',],
        build_dir=proj_path / "sim_build/",
    )

    print("Start test")
    runner.test(
        hdl_toplevel="ciccomplex_top",
        test_module="cicComplex_tb,",
        waves=True,
        test_args=['--ieee=synopsys', '-fexplicit', '-v'],
        plusargs=['--wave=cic_waves.ghw',],
        build_dir=proj_path / "sim_build/",
        test_dir=proj_path / "sim_build/",
        )


# ============================================================================
if __name__ == "__main__":
    # From https://www.dsprelated.com/blogimages/RickLyons/CIC_Filter_Testing_Lyons.pdf
    D = DECIMATE_FACTOR #* DIFFERENTIAL_DELAY
    S = ORDER

    print(f"y_Impulse(1) = {math.factorial(D+S-1)/math.factorial(D)/math.factorial(S-1) - S}")
    print(f"y_Step(1) = {math.factorial(D+S)/math.factorial(D)/math.factorial(S) - S}")

    cic_tb_runner()
