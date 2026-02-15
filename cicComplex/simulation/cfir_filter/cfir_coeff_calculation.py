#!/usr/bin/env python

"""
From https://www.gibbard.me/cic_filters/cic_filters_ipython.html
"""
from math import log
import numpy as np
from scipy.signal import firwin2
from scipy.signal import freqz
import matplotlib.pyplot as plt

np.seterr(divide='ignore', invalid='ignore');
FFT_RESOLUTION = 1024

# CIC
CIC_DECIMATION_FACTOR = 32
ORDER = 4
DIFFERENTIAL_DELAY = 4

# FIR
FIR_DECIMATION_FACTOR = 1
NUM_TAPS = 32
CUT_OFF = 0.18

FS = 125e6
F_CIC_OUT = FS / CIC_DECIMATION_FACTOR
F_FIR_OUT = F_CIC_OUT / FIR_DECIMATION_FACTOR

PLOT_FIGURE = True
NORMALIZE_FREQUENCY = False


# =============================================================================
def float2integer(ftaps, n_bit=16):
    max_ = (2**(n_bit-1))-1
    min_ = (2**(n_bit-1))
    taps_norm = np.array(ftaps)/max(ftaps)
    ptr_neg = [idx for idx, samp in enumerate(ftaps) if samp < 0]
    taps_Q = taps_norm * max_
    for i in ptr_neg:
        taps_Q[i] = taps_norm[i] * min_
    taps_Q = np.rint(taps_Q)
    return taps_Q


# =============================================================================
def plotCICCompFilter(R,M,N):
    plt.figure(figsize=(12,4))
    w = np.arange(FFT_RESOLUTION) * np.pi/FFT_RESOLUTION
    xAxis = np.arange(FFT_RESOLUTION) / (FFT_RESOLUTION * 2)
    Hcomp = lambda w : ((M*R)**N)*(np.abs((np.sin(w/(2.*R))) / (np.sin((w*M)/2.)) ) **N)
    Hcic = lambda w : (1/((M*R)**N))*np.abs( (np.sin((w*M)/2.)) / (np.sin(w/(2.*R))) )**N

    cicMagResponse = np.array(list(map(Hcic, w)))
    cicCompResponse = np.array(list(map(Hcomp, w)))

    # Multiply frequency responses is a convolution in the time domain
    combine = cicCompResponse * cicMagResponse

    plt.plot(xAxis, 20.0*np.log10(cicMagResponse), label="CIC Filter")
    plt.plot(xAxis, 20.0*np.log10(cicCompResponse), label="Compensation Filter")
    plt.plot(xAxis, 20.0*np.log10(combine), label="Combined Response")

    axes = plt.gca(); axes.set_xlim([0,0.5]);
    plt.grid(); plt.legend()
    plt.title("Ideal CIC Compensation filter M={}, N={}".format(M,N))
    plt.xlabel('Normalised freq (2$\pi$ radians/sample)')
    plt.ylabel('Normalised Filter Magnitude Response (dB)')

    plt.show()


#plotCICCompFilter(R=8,M=1,N=3)
#plotCICCompFilter(R=8,M=1,N=5)
#plotCICCompFilter(R=8,M=2,N=3)
#plotCICCompFilter(R=8,M=2,N=5)


# =============================================================================
def getFIRCompensationFilter(R,M,N,cutOff,numTaps,calcRes=1024):
    """Cut off is the cutOff as a fraction of the sample rate
    i.e 0.5 = nyquist frequency
    """
    w = np.arange(calcRes) * np.pi/(calcRes - 1)
    Hcomp = lambda w : ((M*R)**N)*(np.abs((np.sin(w/(2.*R))) / (np.sin((w*M)/2.)) ) **N)
    cicCompResponse = np.array(list(map(Hcomp, w)))
    # Set DC response to 1 as it is calculated as 'nan' by Hcomp
    cicCompResponse[0] = 1
    # Set stopband response to 0
    cicCompResponse[int(calcRes*cutOff*2):] = 0
    normFreq = np.arange(calcRes) / (calcRes - 1)
    taps = firwin2(numTaps, normFreq, cicCompResponse)
    return taps


def plotFIRCompFilter(R,M,N,cutOff,taps, yMin, yMax, wideband=False, fs=1):
    """
    wideband = True  : 0 to R*pi
    wideband = False : 0 to pi
    """
    plt.figure(figsize=(12,4))

    if wideband:
        interp = np.zeros(len(taps)*R)
        interp[::R] = taps
        freqs,response = freqz(interp)
    else:
        freqs,response = freqz(taps)

    if NORMALIZE_FREQUENCY is False:
        freqs *= fs
        if wideband is False:
            freqs /= CIC_DECIMATION_FACTOR

    if wideband:
        w = np.arange(len(freqs)) * np.pi/len(freqs) * R
    else:
        w = np.arange(len(freqs)) * np.pi/len(freqs)

    Hcic = lambda w : (1/((M*R)**N))*np.abs( (np.sin((w*M)/2.)) / (np.sin(w/(2.*R))) )**N
    cicMagResponse = np.array(list(map(Hcic, w)))

    combinedResponse = cicMagResponse * response

    plt.plot(freqs/(2*np.pi),20*np.log10(abs(cicMagResponse)), label="CIC Filter")
    plt.plot(freqs/(2*np.pi),20*np.log10(abs(response)), label="Compensation Filter")
    plt.plot(freqs/(2*np.pi),20*np.log10(abs(combinedResponse)), label="Combined Response")
    if NORMALIZE_FREQUENCY is True:
        plt.xlabel('Normalized Frequency')
    else:
        plt.xlabel('Absolute Frequency')
        if wideband is False:
            fs /= CIC_DECIMATION_FACTOR
    axes = plt.gca(); axes.set_xlim([0,fs/2]); axes.set_ylim([yMin,yMax])
    plt.grid(); plt.legend()
    plt.title("CIC Compensation filter M={}, N={}, Cutoff={}fs, Taps={}, Wideband={}".format(M,N,cutOff,len(taps),wideband))
    plt.ylabel('Normalised Filter Magnitude Response (dB)')



print("Float coeffs")
ftaps = getFIRCompensationFilter(R=CIC_DECIMATION_FACTOR,M=DIFFERENTIAL_DELAY,N=ORDER,cutOff=CUT_OFF,numTaps=NUM_TAPS)
print(ftaps)

print("Integer coeffs")
itaps = float2integer(ftaps, 23)
with open("coeffs.txt", "+w") as fd:
    for tap in itaps:
        fd.write(f"{int(tap):d}\n")
print(itaps)

if PLOT_FIGURE is True:
    if NORMALIZE_FREQUENCY is True:
        fs = 1
    else:
        fs = FS
    plotFIRCompFilter(R=CIC_DECIMATION_FACTOR,M=DIFFERENTIAL_DELAY,N=ORDER,cutOff=CUT_OFF,taps=itaps,yMin=-150,yMax=150,wideband=False,fs=fs)
    plotFIRCompFilter(R=CIC_DECIMATION_FACTOR,M=DIFFERENTIAL_DELAY,N=ORDER,cutOff=CUT_OFF,taps=itaps,yMin=-150,yMax=150,wideband=True,fs=fs)
    plt.show()

