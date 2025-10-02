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

np.seterr(divide="ignore", invalid="ignore")

# FFT frequency normalisation
NORMALIZE_FREQUENCY = False

# HDL generic tuning
K_SIZE = 8
K_SR = 0
UN_SR = 0
DATA_IN_SIZE = 14
DATA_OUT_SIZE_MAX = DATA_IN_SIZE + 1 + K_SIZE - K_SR + 2 - UN_SR
DATA_OUT_SIZE = DATA_OUT_SIZE_MAX - 8
# DATA_OUT_SIZE = 24

# Input stimuli tuning
## Sinus and square tuning
Bin = DATA_IN_SIZE - 4  # Maximal bit size of input data
FS = 125e6  # Sampling frequency (in Hz)
Freq_in = 1.25e6
CLOCK_PERIOD = 8  # in ns
F_MOD = FS / 128  # About 1 MHz
## Pulse and step tuning
START_DELAY = 10
PULSE_WIDTH = 1
STEP_AMP = 1
PULSE_AMP = 1

# PID parameter tuning
KP = 1
KI = 3
SIGN = 0

# Length of stimuli input in each test
STIMULI_SIZE = 128

# Clock latency (input to output) of PID HDL process
LATENCY = 3


# ============================================================================
def sin_wave(amp, f, fs, clks):
    clks = np.arange(0, clks)
    sample = np.rint(amp * np.sin(2.0 * np.pi * f / fs * clks))
    return sample


def square_wave(amp, f, fs, clks):
    clks = np.arange(0, clks)
    sinus = np.sin(2.0 * np.pi * f / fs * clks)
    sample = list(map(lambda sin: amp if sin > 0 else -amp, sinus))
    return sample


# ============================================================================
def pid_predictor(source, kp, ki, sign, ibits, obits, latency):
    global integral
    integral = 0

    def PI(kp, ki, setpoint, sign, measurement):
        global integral
        # PID calculations
        if sign == 0:
            e = measurement - setpoint
        else:
            e = setpoint - measurement
        P = kp * e
        integral = integral + ki * e
        # calculate manipulated variable - MV
        MV = P + integral
        return MV

    nb_step = len(source) - latency

    # Add delay @ begining (=clock latency of HDL process) to sync data with dut data
    pid_result = [0] * latency

    for i in range(nb_step):
        pid_out = PI(kp, ki, 0, sign, source[i])
        pid_result.append(pid_out)

    return pid_result


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
async def data_en_test(dut):
    print("Begin data_en_test()")

    num_clks = STIMULI_SIZE

    PSAMP = 6  # in clock cycle

    # Calculate k1 and k2 parameters from the classical kp and ki parameters.
    k1 = KP + KI
    k2 = -KP

    # Set initial input value to prevent it from floating
    dut.k1_i.value = k1
    dut.k2_i.value = k2
    dut.setpoint_i.value = 0
    dut.sign_i.value = SIGN
    dut.data_i.value = 0
    dut.data_en_i.value = 0

    clock = Clock(dut.clk_i, CLOCK_PERIOD, units="ns")
    # Start the clock. Start it low to avoid issues on the first RisingEdge
    cocotb.start_soon(clock.start(start_high=False))

    # Reset DUT
    await reset_dut(dut.reset, dut.clk_i, 20)
    print("!!! After reset !!! ")

    # Synchronize with the clock. This will regisiter the initial input value
    await RisingEdge(dut.clk_i)

    amp = 2 ** (Bin - 4)
    fs = FS
    nb_pts = 5000

    pid_response = np.zeros(int(num_clks))

    input_signal = sin_wave(amp, Freq_in, fs, nb_pts)

    # PID theoritical response
    pid_response_theo = pid_predictor(
        input_signal[::PSAMP], KP, KI, SIGN, DATA_IN_SIZE, DATA_OUT_SIZE, LATENCY
    )
    pid_response_theo = np.repeat(pid_response_theo, PSAMP)[2*PSAMP:]

    for samp in range(num_clks):
        dut.data_en_i.value = 0
        if samp % PSAMP == 0:
            dut.data_i.value = int(input_signal[samp])
            dut.data_en_i.value = 1
        await RisingEdge(dut.clk_i)
        # assert dut.data_o.value == expected_val, f"output was incorrect on the {i}th cycle"
        # expected_val = val  # Save random value for next RisingEdge
        pid_response[samp] = dut.data_o.value.signed_integer
    # Check the final input on the next clock
    await RisingEdge(dut.clk_i)
    # assert dut..value == expected_val, "output q was incorrect on the last cycle"

    time_max_idx = num_clks
    plt.figure()
    plt.plot(pid_response[:time_max_idx], marker="x")
    plt.plot(pid_response_theo[:time_max_idx], marker=".")
    plt.plot(input_signal[:time_max_idx])
    plt.legend(["DUT", "Theory", "Input"])
    plt.title("Time domain: data_en_test")
    plt.show()


# ============================================================================
# @cocotb.test()
async def output_saturation_test(dut):
    """Check behavior of PID velocity form when output saturate"""
    print("Begin output_saturation_test()")

    num_clks = STIMULI_SIZE

    # Calculate k1 and k2 parameters from the classical kp and ki parameters.
    k1 = KP + KI
    k2 = -KP

    # Set initial input value to prevent it from floating
    dut.k1_i.value = k1
    dut.k2_i.value = k2
    dut.setpoint_i.value = 0
    dut.sign_i.value = SIGN
    dut.data_i.value = 0

    # stimuli input -> step
    input_signal = (
        [0] * START_DELAY
        + [2 ** (DATA_IN_SIZE - 1) - 1] * int(STIMULI_SIZE / 8)
        + [-(2 ** (DATA_IN_SIZE - 1))] * int(STIMULI_SIZE / 8)
        + [2 ** (DATA_IN_SIZE - 1) - 1] * int(STIMULI_SIZE / 8)
        + [-(2 ** (DATA_IN_SIZE - 1))] * int(STIMULI_SIZE / 8)
        + [2 ** (DATA_IN_SIZE - 1) - 1] * int(STIMULI_SIZE / 8)
        + [-(2 ** (DATA_IN_SIZE - 1))] * int(STIMULI_SIZE / 8)
        + [2 ** (DATA_IN_SIZE - 1) - 1] * int(STIMULI_SIZE / 8)
        + [0] * int(STIMULI_SIZE / 8 - START_DELAY)
    )

    # PID theoritical response
    pid_response_theo = pid_predictor(
        input_signal, KP, KI, SIGN, DATA_IN_SIZE, DATA_OUT_SIZE, LATENCY
    )

    # start simulator clock
    cocotb.start_soon(Clock(dut.clk_i, CLOCK_PERIOD, units="ns").start())

    # Reset DUT
    await reset_dut(dut.reset, dut.clk_i, 20)
    print("!!! After reset !!! ")

    pid_response = np.zeros(int(num_clks))

    dut.data_en_i.value = 1

    # run through each clock
    for samp in range(num_clks):
        # feed a new input in
        dut.data_i.value = int(input_signal[samp])

        await RisingEdge(dut.clk_i)

        # get the output at rising edge
        pid_response[samp] = dut.data_o.value.signed_integer

        # wait until reset is over, then start the assertion checking
        # if(samp>=2):
        #     assert pid_response[samp] == pid_response_theo[samp], "filter result is incorrect: %d != %d" % (pid_response[samp], pid_response_theo[samp])

    time_max_idx = num_clks
    plt.figure()
    plt.plot(pid_response[:time_max_idx], marker="x")
    plt.plot(pid_response_theo[:time_max_idx], marker=".")
    plt.plot(input_signal[:time_max_idx])
    plt.legend(["DUT", "Theory", "Input"])
    plt.title("Time domain: output_saturation_test")
    plt.show()


# ============================================================================
# @cocotb.test()
async def pid_impulse_response_test(dut):
    """Analyze PID response."""
    print("Begin pid_impulse_response_test()")
    num_clks = STIMULI_SIZE

    # Calculate k1 and k2 parameters from the classical kp and ki parameters.
    k1 = KP + KI
    k2 = -KP

    # Set initial input value to prevent it from floating
    dut.k1_i.value = k1
    dut.k2_i.value = k2
    dut.setpoint_i.value = 0
    dut.sign_i.value = SIGN
    dut.data_i.value = 0

    # stimuli input -> Impulse
    input_signal = [0] * START_DELAY + [PULSE_AMP] * PULSE_WIDTH + [0] * (num_clks - 1)

    # PID theoritical response
    pid_response_theo = pid_predictor(
        input_signal, KP, KI, SIGN, DATA_IN_SIZE, DATA_OUT_SIZE, LATENCY
    )

    # start simulator clock
    cocotb.start_soon(Clock(dut.clk_i, CLOCK_PERIOD, units="ns").start())

    # Reset DUT
    await reset_dut(dut.reset, dut.clk_i, 20)
    print("!!! After reset !!! ")

    pid_response = np.zeros(int(num_clks))

    # Alway enable input data
    dut.data_en_i.value = 1

    # run through each clock
    for samp in range(num_clks):

        dut.data_i.value = int(input_signal[samp])

        await RisingEdge(dut.clk_i)
        # feed a new input in

        # get the output at rising edge
        pid_response[samp] = dut.data_o.value.signed_integer

        # wait until reset is over, then start the assertion checking
        if samp >= 2:
            assert (
                pid_response[samp] == pid_response_theo[samp]
            ), "PID velocity result is incorrect: %d != %d" % (
                pid_complex_response_i[samp],
                pid_theo_response[samp],
            )

    time_max_idx = num_clks
    plt.figure(1)
    plt.plot(pid_response[:time_max_idx], marker="x")
    plt.plot(pid_response_theo[:time_max_idx], marker=".")
    plt.plot(input_signal[:time_max_idx])
    plt.legend(["DUT", "Theory", "Input"])
    plt.title("Time domain: Impulse response")
    plt.grid()

    plt.show()


# ============================================================================
# @cocotb.test()
async def pid_step_response_test(dut):
    """Analyze PID step response."""
    print("Begin pid_step_response_test()")

    num_clks = STIMULI_SIZE

    # Calculate k1 and k2 parameters from the classical kp and ki parameters.
    k1 = KP + KI
    k2 = -KP

    # Set initial input value to prevent it from floating
    dut.k1_i.value = k1
    dut.k2_i.value = k2
    dut.setpoint_i.value = 0
    dut.sign_i.value = SIGN
    dut.data_i.value = 0

    # stimuli input -> step
    input_signal = [0] * START_DELAY + [STEP_AMP] * (num_clks)

    # PID theoritical response
    pid_response_theo = pid_predictor(
        input_signal, KP, KI, SIGN, DATA_IN_SIZE, DATA_OUT_SIZE, LATENCY
    )
    print(pid_response_theo[5:50])

    # start simulator clock
    cocotb.start_soon(Clock(dut.clk_i, CLOCK_PERIOD, units="ns").start())

    # Reset DUT
    await reset_dut(dut.reset, dut.clk_i, 20)
    print("!!! After reset !!! ")

    pid_response = np.zeros(int(num_clks))

    dut.data_en_i.value = 1

    # run through each clock
    for samp in range(num_clks):
        # feed a new input in
        dut.data_i.value = int(input_signal[samp])

        await RisingEdge(dut.clk_i)

        # get the output at rising edge
        pid_response[samp] = dut.data_o.value.signed_integer

        # wait until reset is over, then start the assertion checking
        if samp >= 2:
            assert (
                pid_response[samp] == pid_response_theo[samp]
            ), "PID velocity result is incorrect: %d != %d" % (
                pid_response[samp],
                pid_response_theo[samp],
            )

    time_max_idx = num_clks
    plt.figure()
    plt.plot(pid_response[:time_max_idx], marker="x")
    plt.plot(pid_response_theo[:time_max_idx], marker=".")
    plt.plot(input_signal[:time_max_idx])
    plt.legend(["DUT", "Theory", "Input"])
    plt.title("Time domain: Step response")
    plt.show()


# ============================================================================
# @cocotb.test()
async def pid_wave_test(dut):
    """Test that wave propagates to output with respect to frequency"""
    print("Begin pid_wave_test()")

    num_clks = STIMULI_SIZE

    # Calculate k1 and k2 parameters from the classical kp and ki parameters.
    k1 = KP + KI
    k2 = -KP

    # Set initial input value to prevent it from floating
    dut.k1_i.value = k1
    dut.k2_i.value = k2
    dut.setpoint_i.value = 0
    dut.sign_i.value = SIGN
    dut.data_i.value = 0

    clock = Clock(dut.clk_i, CLOCK_PERIOD, units="ns")
    # Start the clock. Start it low to avoid issues on the first RisingEdge
    cocotb.start_soon(clock.start(start_high=False))

    # Reset DUT
    await reset_dut(dut.reset, dut.clk_i, 20)
    print("!!! After reset !!! ")

    # Alway enable input data
    dut.data_en_i.value = 1

    # Synchronize with the clock. This will regisiter the initial input value
    await RisingEdge(dut.clk_i)

    amp = 2 ** (Bin - 4)
    fs = FS
    nb_pts = 5000

    results_theo = []
    results_dut = []
    input_signal = []

    pid_response = np.zeros(int(num_clks))

    # expected_val = 0  # Matches initial input value
    for freq in [
        Freq_in / 2,
        3 * Freq_in / 4,
        Freq_in,
        4 * Freq_in / 3,
        2 * Freq_in,
        3 * Freq_in,
    ]:
        stimuli = sin_wave(amp, freq, fs, nb_pts)
        # PID theoritical response
        pid_response_theo = pid_predictor(
            stimuli, KP, KI, SIGN, DATA_IN_SIZE, DATA_OUT_SIZE, LATENCY
        )
        results_theo.append(pid_response_theo)
        input_signal.append(stimuli)
        for i in range(nb_pts):
            dut.data_i.value = int(stimuli[i])
            await RisingEdge(dut.clk_i)
            # assert dut.data_o.value == expected_val, f"output was incorrect on the {i}th cycle"
            # expected_val = val  # Save random value for next RisingEdge

    # expected_val = 0  # Matches initial input value
    for freq in [
        Freq_in / 2,
        3 * Freq_in / 4,
        Freq_in,
        4 * Freq_in / 3,
        2 * Freq_in,
        3 * Freq_in,
    ]:
        stimuli = square_wave(amp, freq, fs, nb_pts)
        for i in range(nb_pts):
            dut.data_i.value = int(stimuli[i])
            await RisingEdge(dut.clk_i)
            # assert dut.data_o.value == expected_val, f"output was incorrect on the {i}th cycle"
            # expected_val = val  # Save random value for next RisingEdge
            pid_response[samp] = dut.data_o.value.signed_integer
        results_dut.append(pid_response)
    # Check the final input on the next clock
    await RisingEdge(dut.clk_i)
    # assert dut..value == expected_val, "output q was incorrect on the last cycle"

    time_max_idx = num_clks
    plt.figure()
    plt.plot(results_dut[:time_max_idx], marker="x")
    plt.plot(results_theo[:time_max_idx], marker=".")
    plt.plot(input_signal[:time_max_idx])
    plt.legend(["DUT", "Theory", "Input"])
    plt.title("Time domain: wave excitation")
    plt.show()


# ============================================================================
@cocotb.test()
async def pid_code_generation_test(dut):
    """Only check code generation"""
    print("Begin pid_code_generation_test()")
    print("End pid_code_generation_test()")


# ============================================================================
def pid_tb_runner():
    print("Begin pid_tb_runner()")
    hdl_toplevel_lang = os.getenv("HDL_TOPLEVEL_LANG", "vhdl")
    sim = os.getenv("SIM", "ghdl")

    proj_path = pathlib.Path(__file__).resolve().parent
    vhdl_sources = [
        proj_path / "../../hdl/pid_velocity_axi_logic.vhd",
    ]

    runner = get_runner(sim)

    print("Build HDL")
    runner.build(
        vhdl_sources=vhdl_sources,
        hdl_toplevel="pid_velocity_axi_logic",
        parameters={
            "K_SIZE": K_SIZE,
            "K_SR": K_SR,
            "UN_SR": UN_SR,
            "DATA_IN_SIZE": DATA_IN_SIZE,
            "DATA_OUT_SIZE": DATA_OUT_SIZE,
        },
        always=True,
        build_args=[
            "--ieee=synopsys",
            "-fexplicit",
        ],
        build_dir=proj_path / "sim_build/",
    )

    print("Start test")
    runner.test(
        hdl_toplevel="pid_velocity_axi_logic",
        test_module="pid_axi_logic_tb,",
        waves=True,
        test_args=["--ieee=synopsys", "-fexplicit", "-v"],
        plusargs=[
            "--wave=pid_waves.ghw",
        ],
        build_dir=proj_path / "sim_build/",
        test_dir=proj_path / "sim_build/",
    )


# ============================================================================
if __name__ == "__main__":

    pid_tb_runner()
