import math
import numpy as np
import scipy.special as ss

#
#  Computes CIC decimation filter accumulator register  
#  truncation in each filter stage based on Hogenauer's  
#  'accumulator register pruning' technique.
#
#   Inputs:
#     N = number of decimation CIC filter stages (filter order).
#     R = CIC filter rate change factor (decimation factor).
#     M = differential delay.
#     Bin = number of bits in an input data word.
#     Bout = number of bits in the filter's final output data word.
#   Outputs:
#     Stage number (ranges from 1 -to- 2*N+1).
#     Bj = number of least significant bits that can be truncated
#       at the input of a filter stage.
#     Accumulator widths = number of a stage's necessary accumulator
#       bits accounting for truncation.
#
#  Benoit Dubois April, 2024
#  
#  Translated Matlab into Python code, from
#  "Computing CIC Filter Register Pruning Using Matlab"
#  find here:
#  https://www.dsprelated.com/showcode/269.php
#

#  Define CIC filter parameters
#N = 4;  R = 25;  M = 1;  Bin = 16;  Bout = 16; # Hogenauer paper, pp. 159
#N = 3;  R = 32;  M = 2;  Bin = 8;  Bout = 10; # Meyer Baese book, pp. 268
#N = 3;  R = 16;  M = 1;  Bin = 16;  Bout = 16; # Thorwartl's PDF file
# N = 3; R = 8; M = 1; Bin = 12; Bout = 12; # Lyons' blog Figure 2 example
N = 4; R = 32; M = 4; Bin = 25; Bout = 25; # Perso
# Bout = N * math.ceil(math.log(R * M) / math.log(2)) + Bin  # No truncation

# Find h_sub_j and "F_sub_j" values for (N-1) cascaded integrators
F_sub_j = np.zeros(2*N +1)
for j in range(N-2, -1, -1):
    h_sub_j = np.zeros((R*M-1)*N +N)
    for k in range((R*M-1)*N +j+1):
        for L in range(math.floor(k/(R*M)) + 1):
            Change_to_Result = \
                (-1)**L * ss.comb(N, L) * ss.comb(N-j-1+k-R*M*L, k-R*M*L)
            h_sub_j[k] =  h_sub_j[k] + Change_to_Result

    F_sub_j[j] = math.sqrt(sum(h_sub_j**2))

# Define "F_sub_j" values for up to seven cascaded combs
F_sub_j_for_many_combs = np.sqrt([2, 6, 20, 70, 252, 924, 3432])
 
#  Compute F_sub_j for last integrator stage
F_sub_j[N-1] = F_sub_j_for_many_combs[N-2]*math.sqrt(R*M)  # Last integrator   

#  Compute F_sub_j for N cascaded filter's comb stages
for j in range(2*N-1, N-1, -1):
    F_sub_j[j] = F_sub_j_for_many_combs[2*N-j-1]

# Define "F_sub_j" values for the final output register truncation
F_sub_j[2*N] = 1 # Final output register truncation

# for j in range(len(F_sub_j)):
#     print(f"F_sub_j({j}): {F_sub_j[j]}")
# print("")

# Compute column vector of minus log base 2 of "F_sub_j" values
Minus_log2_of_F_sub_j = -np.log2(F_sub_j)

# Compute total "Output_Truncation_Noise_Variance" terms
CIC_Filter_Gain = (R*M)**N
Num_of_Bits_Growth = math.ceil(math.log2(CIC_Filter_Gain))

# The following is from Hogenauer's Eq. (11)
#Num_Output_Bits_With_No_Truncation = Num_of_Bits_Growth + Bin -1;
Num_Output_Bits_With_No_Truncation = Num_of_Bits_Growth + Bin
Num_of_Output_Bits_Truncated = Num_Output_Bits_With_No_Truncation - Bout
Output_Truncation_Noise_Variance = (2**Num_of_Output_Bits_Truncated)**2 / 12
print(f"Output_Truncation_Noise_Variance: {Output_Truncation_Noise_Variance}")

# Compute log base 2 of "Output_Truncation_Noise_Standard_Deviation" terms
Output_Truncation_Noise_Standard_Deviation = \
    math.sqrt(Output_Truncation_Noise_Variance)
print(f"Output_Truncation_Noise_Standard_Deviation: {Output_Truncation_Noise_Standard_Deviation}")

Log_base2_of_Output_Truncation_Noise_Standard_Deviation = \
    math.log2(Output_Truncation_Noise_Standard_Deviation)
print(f"Log_base2_of_Output_Truncation_Noise_Standard_Deviation: {Log_base2_of_Output_Truncation_Noise_Standard_Deviation}")

# Compute column vector of "half log base 2 of 6/N" terms
Half_Log_Base2_of_6_over_N = 0.5 * math.log2(6/N)

# Compute desired "B_sub_j" vector
#print("\nCompute floor", Minus_log2_of_F_sub_j, 
#    Log_base2_of_Output_Truncation_Noise_Standard_Deviation \
#    , Half_Log_Base2_of_6_over_N)
B_sub_j = np.floor(Minus_log2_of_F_sub_j \
    + Log_base2_of_Output_Truncation_Noise_Standard_Deviation \
    + Half_Log_Base2_of_6_over_N)

# "Correct" Hogenaurer's pruning method:
# Depending on the filter's values for N and R, Hogenaurer's pruning
# method lead to an initial truncation of one (or more) bit of
# the filter's input sequence prior to the first integrator.
# That decrease the signal-to-quantization noise ratio by 6 dB prior
# to any filtering. 
# To correct the method, we set B1 = 0 (no truncation) and we increase
# the truncation of the following integrators by one additional LSB.
if B_sub_j[0] > 1:
	for j in range(1, int(B_sub_j[0])+1):
		B_sub_j[j] = B_sub_j[j] + 1
	B_sub_j[0] = 0

print('N = ',str(N),',   R = ',str(R),',   M = ',str(M), \
        ',   Bin = ', str(Bin),',   Bout = ',str(Bout))
print('Num of Bits Growth Due To CIC Filter Gain = ', \
    str(Num_of_Bits_Growth))
print('Num of Accumulator Bits With No Truncation = ', \
    str(Num_Output_Bits_With_No_Truncation))
# print(['Output Truncation Noise Variance = ', ...
#     str(Output_Truncation_Noise_Variance)])
# print(['Log Base2 of Output Truncation Noise Standard Deviation = ',...
#         str(Log_base2_of_Output_Truncation_Noise_Standard_Deviation)])
# print(['Half Log Base2 of 6/N = ', str(Half_Log_Base2_of_6_over_N)])

# Create and printlay "Results" matrix
Results = np.zeros([2*N+1, 5])
for Stage in range(2*N):
    Results[Stage, 0] = Stage + 1
    Results[Stage, 1] = F_sub_j[Stage]
    Results[Stage, 2] = Minus_log2_of_F_sub_j[Stage]
    Results[Stage, 3] = B_sub_j[Stage]
    Results[Stage, 4] = Num_Output_Bits_With_No_Truncation -B_sub_j[Stage]

# Include final output stage truncation in "Results" matrix
Results[2*N, 0] = 2*N+1  # Output stage number
Results[2*N, 1] = 1
Results[2*N, 3] = Num_of_Output_Bits_Truncated
Results[2*N, 4] = Bout
#Results # printlay "Results" matrix in raw float-pt.form
 
# # printlay "F_sub_j" values if you wish
# print(' ')
# print(' Stage        Fj        -log2(Fj)    Bj   Accum width')
# for Stage = 1:2*N+1
#   print(['  ',sprintf('#2.2g',Results[Stage,1)),sprintf('\t'),sprintf('#12.3g',Results[Stage,2)),...
#         sprintf('\t'),sprintf('#7.5g',Results[Stage,3)),sprintf('\t'),...
#         sprintf('#7.5g',Results[Stage,4)),sprintf('\t'),sprintf('#7.5g',Results[Stage,5))])
# end
 
# printlay Stage number, of truncated input bits, & Accumulator word widths
print(' ')
print(' Stage(j)   Bj   Accum (adder) width')
for Stage in range(2*N):
    print(f'  {Results[Stage,0]:#2.0g}\t{Results[Stage,3]:#5.0f}\t{Results[Stage,4]:#7.0f}')
print(f'  {Results[2*N,0]:#2.0f}\t{Results[2*N,3]:#5.0f}\t{Results[2*N,4]:#7.0f} (final truncation)')
