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

NORMALIZE_FREQUENCY = False

CLOCK_PERIOD = 8  # in ns

Bin = 16  # Input sample precision
DECIMATE_FACTOR = 64  # decimate or interpolation ratio
ORDER = 3  # Number of stages in filter
N = 1  # Number of samples per stage (usually 1)
Bout = 23 #M * int(round(math.log(R) / math.log(2))) + Bin # Output sample precision

FS = 125e6  # Sampling frequency (in Hz)

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
#@cocotb.test()
async def cic_simple_test(dut):
    """Test that input propagates to output"""
    FREQ_IN = 10  # in Hz

    print("Begin cic_simple_test()")
 
    # Set initial input value to prevent it from floating
    dut.data_i.value = 0

    clock = Clock(dut.clk, CLOCK_PERIOD, units="ns")
    # Start the clock. Start it low to avoid issues on the first RisingEdge
    cocotb.start_soon(clock.start(start_high=False))

    # Reset DUT
    await reset_dut(dut.rst_n, dut.clk, 20)
    print("!!! After reset !!! ")

    # Synchronize with the clock. This will regisiter the initial input value
    await RisingEdge(dut.clk)
    #expected_val = 0  # Matches initial input value
    for i in range(1000):
        val = int(2**(Bin-3) * math.sin(2*3.14*FREQ_IN*CLOCK_PERIOD*i))
        dut.data_i.value = val  # Assign the random value val to the input port
        await RisingEdge(dut.clk)
        #assert dut.data_o.value == expected_val, f"output was incorrect on the {i}th cycle"
        #expected_val = val  # Save random value for next RisingEdge

    # Check the final input on the next clock
    await RisingEdge(dut.clk)
    #assert dut.q.value == expected_val, "output q was incorrect on the last cycle"


# ============================================================================
def wave(amp, f, fs, clks): 
    clks = np.arange(0, clks)
    sample = np.rint(amp*np.sin(2.0*np.pi*f/fs*clks))
    return sample

def predictor(signal,coefs):
    output = lfilter(coefs,1.0,signal)
    return output

def cic_decimator(source, decimate_factor=DECIMATE_FACTOR, order=ORDER, ibits=Bin, obits=Bout):
    """'Theoritical' CIC decimator.
    From https://stackoverflow.com/questions/21879676/filtering-signal-with-python-lfilter
    """
    # Calculate the total number of bits used internally, and the output
    # shift and mask required.
    numbits = order * int(round(math.log(decimate_factor) / math.log(2))) + ibits
    shift_gain = int(np.log2((decimate_factor * N)**order))
    outmask  = (1 << obits) - 1

    # If we need more than 64 bits, we can't do it...
    assert numbits <= 64

    # Create a numpy array with the source
    result = np.array(source, np.int64)

    # Do the integration stages
    for i in range(order):
        result.cumsum(out=result)

    # Decimate
    result = np.array(result[ : : decimate_factor])

    # Do the comb stages.  Iterate backwards through the array,
    # because we use each value before we replace it.
    for i in range(order):
        result[len(result) - 1 : 0 : -1] -= result[len(result) - 2 : : -1]

    # Normalize the output
    result = np.int64(result) >> shift_gain

    result &= outmask
    return result


@cocotb.test()
async def cic_filter_frequency_response_test(dut):
    """Analyze filter frequency response.
    """
    # Initialize
    dut.data_i.value = 0
    if NORMALIZE_FREQUENCY is True:
        fs = 1
    else:
        fs = FS
    num_clks = 2048  # Length of stimuli input
    nfft     = num_clks; 
    ##f0       = 50*(1.0/nfft)

    # Check generic parameter values consistency between DUT and simulator
    assert int(dut.DECIMATE_FACTOR) == DECIMATE_FACTOR, ("Generic value mismatch: DECIMATE_FACTOR")
    assert int(dut.ORDER) == ORDER, ("Generic value mismatch: ORDER")
    assert int(dut.N) == N, ("Generic value mismatch: N")

    # stimuli input -> Impulse
    impulse_amplitude = 1024  # 2**(Bin-1)-1
    input_signal = [impulse_amplitude]+[0]*(nfft)

    # bit accurate predictor values
    cic_theo_response = cic_decimator(input_signal)
    # Repeat data sample to handle input vs output data number mismatch
    # due to decimate.
    cic_theo_response = np.repeat(cic_theo_response, DECIMATE_FACTOR)

    # start simulator clock
    cocotb.start_soon(Clock(dut.clk, 1, units="ns").start())

    # Reset DUT
    await reset_dut(dut.reset, dut.clk, 20)
    print("!!! After reset !!! ")

    cic_real_response = np.zeros(int(num_clks))
    # run through each clock
    for samp in range(num_clks):
        await RisingEdge(dut.clk)
        # get the output at rising edge
        dut_data_out = dut.data_o.value.signed_integer

        # feed a new input in
        dut.data_i.value = int(input_signal[samp])

        cic_real_response[samp] = dut_data_out

        # wait until reset is over, then start the assertion checking
        #if(cnt>=2):
        #    assert dut_data_out == data_out_pred[cnt-2], "filter result is incorrect: %d != %d" % (dut_data_out, data_out_pred[cnt-2])

    cic_theo_fft  = 20*np.log10(np.abs(np.fft.fft(cic_theo_response)))
    cic_real_fft  = 20*np.log10(np.abs(np.fft.fft(cic_real_response)))

    time_max_idx = 100
    plt.figure(1)
    #plt.subplot(1,2,1)
    plt.plot(input_signal[:time_max_idx])
    plt.plot(cic_real_response[:time_max_idx], marker='x')
    plt.plot(cic_theo_response[:time_max_idx], marker='o')
    plt.legend(['Impulse', 'DUT', 'Theory'])
    plt.title('Time domain: Impulse response')
    #plt.subplot(1,2,2)
    #plt.stem(cic_real_response[2:-1]-cic_theo_response)
    #plt.stem(cic_real_response-cic_theo_response)
    #plt.title('error : DUT - Golden Reference')

    if NORMALIZE_FREQUENCY is True:
        xaxis = np.arange(0, 0.5, 1/nfft)
    else:
        xaxis = np.arange(0, fs/2, fs/nfft)

    plt.figure(2)
    plt.plot(xaxis, cic_real_fft[0:int(nfft/2)], marker='x')
    plt.plot(xaxis, cic_theo_fft[0:int(nfft/2)], marker='o')
    plt.grid()
    if NORMALIZE_FREQUENCY is True:
        plt.xlabel('Normalized Frequency')
        plt.xlim([0, .5])
    else:
        plt.xlabel('Absolute Frequency')
        plt.xlim([0, fs/2])
    plt.ylabel('dB')
    
    #plt.ylim([min(cic_real_fft),max(max(cic_theo_fft), max(cic_real_fft))])
    plt.legend(['DUT', 'Theory'])
    plt.title('Filter frequency Domain Response')

    plt.show()


#@cocotb.test()
async def cic_IO_frequency_reponse_test(dut):
    """Analyse input to output filter response to a sinus wave signal.
    """ 
    #initialize
    dut.data_i.value = 0
    fs       = 1
    amp0     = 80
    num_clks = 512
    nfft     = num_clks; 
    f0       = 50*(1.0/nfft)
    coefs    = np.array([-1., -7., -4.,  4., 18., 32., 38., 32., 18.,  4., -4., -7., -1.])
    cnt      = 0

    # input data
    input_signal = wave(amp0, f0, fs, num_clks) + wave(amp0/2, 200.5*(1.0/nfft), fs, num_clks)

    # bit accurate predictor values
    #data_out_fir_pred = predictor(input_signal, coefs)
    data_out_pred = cic_decimator(input_signal)

    # start simulator clock
    cocotb.start_soon(Clock(dut.clk, 1, units="ns").start())

    # Reset DUT
    await reset_dut(dut.reset, dut.clk, 20)
    print("!!! After reset !!! ")

    output_signal = np.zeros(int(num_clks / R))

    # run through each clock
    for samp in range(num_clks):
        await RisingEdge(dut.clk)
        # get the output at rising edge
        dut_data_out = dut.data_o.value.signed_integer

        # feed a new input in
        dut.data_i.value = int(input_signal[samp])

        # Get output result rated with decimate ratio
        if samp % 8 == 0:
            output_signal[cnt] = dut_data_out

            # wait until reset is over, then start the assertion checking
            #if(cnt>=2):
            #    assert dut_data_out == data_out_pred[cnt-2], "filter result is incorrect: %d != %d" % (dut_data_out, data_out_pred[cnt-2])
            cnt = cnt + 1
    
    # CIC filter frequency response
    impulse = [1]+[0]*(nfft)
    cic_theo_response = np.array(cic_decimator(impulse, R))

    in_fft    = np.fft.fftshift(20*np.log10(np.abs(np.fft.fft(input_signal, nfft))))
    out_fft   = np.fft.fftshift(20*np.log10(np.abs(np.fft.fft(output_signal[2:], nfft))))
    pred_fft  = np.fft.fftshift(20*np.log10(np.abs(np.fft.fft(data_out_pred[:-2], nfft))))
    #filt_fft  = np.fft.fftshift(20*np.log10(np.abs(np.fft.fft(coefs/sum(coefs), nfft))))
    filt_fft  = 20*np.log10(np.fft.fft(cic_theo_response))

    # normalize FFTs lazy style
    in_fft   = in_fft   - np.max(in_fft)
    out_fft  = out_fft  - np.max(out_fft)
    pred_fft = pred_fft - np.max(pred_fft)
    xaxis    = np.arange(-0.5, 0.5, 1/nfft)

    plt.figure(1)
    plt.subplot(1,2,1)
    plt.plot(output_signal[2:], marker='x')
    plt.plot(data_out_pred[:-2], marker='o')
    plt.legend(['DUT', 'Theory'])
    plt.title('time domain')
    plt.subplot(1,2,2)
    plt.stem(output_signal[2:]-data_out_pred[:-2])
    plt.title('error : DUT - Golden Reference')

    plt.figure(2)
    plt.subplot(2,1,1)
    #plt.plot(xaxis, in_fft)
    plt.plot(xaxis, filt_fft)
    plt.title('Input to DUT: Frequency Domain Response')
    #plt.legend(['input', 'filter'])
    plt.subplot(2,1,2)
    plt.plot(xaxis, out_fft, marker='x')
    plt.plot(xaxis, pred_fft, marker='o')
    plt.title('Output of DUT: Frequency Domain Response')
    plt.plot(xaxis, filt_fft)
    plt.grid()
    plt.xlabel('Normalized Frequency')
    plt.ylabel('dB')
    plt.title('Filter Response')
    plt.xlim([-.5, .5])
    plt.legend(['output', 'pred', 'filter'])
    plt.show()


# ============================================================================
def cic_tb_runner():
    print("Begin cic_tb_runner()")
    hdl_toplevel_lang = os.getenv("HDL_TOPLEVEL_LANG", "vhdl")
    sim = os.getenv("SIM", "ghdl")

    proj_path = pathlib.Path(__file__).resolve().parent
    vhdl_sources = [
        proj_path / "../../hdl/common.vhd",
        proj_path / "../../hdl/comb.vhd",
        proj_path / "../../hdl/integrate.vhd",
        proj_path / "../../hdl/cicReal_top.vhd",
        ]

    runner = get_runner(sim)

    print("Build HDL")
    runner.build(
        vhdl_sources=vhdl_sources,
        hdl_toplevel="cicreal_top",
        parameters={"DECIMATE_FACTOR": DECIMATE_FACTOR, "ORDER": ORDER},
        always=True,
        build_args=['--ieee=synopsys', '-fexplicit',],
    )

    print("Start test")
    runner.test(
        hdl_toplevel="cicreal_top", 
        test_module="cicReal_tb,",
        waves=True,
        test_args=['--ieee=synopsys', '-fexplicit', '-v'],
        #test_args=['-gDEC_RATIO=64', '--ieee=synopsys', '-fexplicit',],
        plusargs=['--vcd=cic_waves.vcd',],
        )


# ============================================================================
if __name__ == "__main__":
    cic_tb_runner()