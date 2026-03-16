import math

def calculate_bit_growth(N, R, M, D):
    """
    Calculate bit growth at each stage of the CIC filter based on Hogenauer's pruning theory.

    Args:
    - N: Input sample size
    - R: Output sample size
    - M: Differential delay
    - D: Decimation factor

    Returns:
    - List of bit growth at each stage
    """
    bit_growth = []
    for i in range(1, M + 1):
        growth = math.ceil(math.log2((N * i) / (R * D)))
        bit_growth.append(growth)
    return bit_growth

def prune_bits(bit_growth, target_bits):
    """
    Prune bits at each stage of the filter to achieve the desired output bit width.

    Args:
    - bit_growth: List of bit growth at each stage
    - target_bits: Desired output bit width

    Returns:
    - List of pruned bits at each stage
    """
    pruned_bits = []
    cumulative_growth = 0
    for growth in bit_growth:
        if cumulative_growth + growth > target_bits:
            pruned_bits.append(target_bits - cumulative_growth)
            break
        pruned_bits.append(growth)
        cumulative_growth += growth
    return pruned_bits

# Example parameters
N = 16  # Input sample size
R = 16   # Output sample size
M = 4   # Differential delay
D = 16   # Decimation factor

target_bits = 12  # Desired output bit width

# Calculate bit growth
bit_growth = calculate_bit_growth(N, R, M, D)
print("Bit growth at each stage:", bit_growth)

# Prune bits
pruned_bits = prune_bits(bit_growth, target_bits)
print("Pruned bits at each stage:", pruned_bits)
