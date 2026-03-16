---------------------------------------------------------------------------
-- (c) Copyright: FemtoEngineering 2024-2025
-- Author : Benoit Dubois <benoit.dubois@femto-engineering.fr>
-- Creation date : 2024/04/15
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

package common is
	type real_array is array (natural range <>) of real;
	type natural_array is array (natural range <>) of natural;
	subtype coeff_t is natural_array;
	--
	function "-"(a: real_array) return real_array;
	function DotFloor(a: real_array) return natural_array;
	function DotLog2(a: real_array) return real_array;
	function DotProd(a: natural_array; b: natural_array) return natural_array;
	function DotProd(a: real_array; b: real_array) return real_array;
	function DotSum(a: natural_array; b: natural) return natural_array;
	function DotSum(a: natural_array; b: natural_array) return natural_array;
	function DotSum(a: real_array; b: real) return real_array;
	function DotSum(a: real_array; b: real_array) return real_array;
	function CumSum(a: natural_array) return natural;
	function CumSum(a: real_array) return real;
	function Binomial(n : natural; k : natural) return real;
	function CicRegSize(Pruning: boolean; Bin : natural; Bout : natural; R : natural; N : natural; M : natural) return coeff_t;
	function Gain(R : natural; M : natural; N : natural) return natural;
	function Bmax(Bin : natural; R : natural; M : natural; N : natural) return natural;
	function GetIntInputSize(data_in_size : natural; is_signed: boolean) return natural;
end package;

package body common is

	function "-"(a: real_array) return real_array is
		variable ret_array : real_array(a'range);
	begin
		for i in a'range loop
			ret_array(i) := -a(i);
		end loop;
		return ret_array;
	end function;


	-- Arrays term to term floor with min at 0.
	function DotFloor(a: real_array) return natural_array is
		variable ret_array : natural_array(a'range);
		variable a_int : real;
	begin
		for i in a'range loop
			a_int := floor(a(i));
			if a_int < 0.0 then
				ret_array(i) := 0;
			else
				ret_array(i) := integer(a_int);
			end if;
		end loop;
		return ret_array;
	end function;

	-- Arrays term to term multiplication.
	-- Note: 'a' and 'b' must have the same range.
	function DotProd(a: natural_array; b: natural_array) return natural_array is
		variable ret_array : natural_array(a'range);
	begin
		assert (a'low = b'low) and (a'high = b'high)
			report "DotProd: input arrays must have same length"
			severity failure;

			for i in a'range loop
			ret_array(i) := a(i) * b(i);
		end loop;
		return ret_array;
	end function;

	function DotProd(a: real_array; b: real_array) return real_array is
		variable ret_array : real_array(a'range);
	begin
		assert (a'low = b'low) and (a'high = b'high)
			report "DotProd: input arrays must have same length"
			severity failure;

			for i in a'range loop
			ret_array(i) := a(i) * b(i);
		end loop;
		return ret_array;
	end function;


	-- Arrays term to term log2
	function DotLog2(a: real_array) return real_array is
		variable ret_array : real_array(a'range);
	begin
		for i in a'range loop
			ret_array(i) := log2(a(i));
		end loop;
		return ret_array;
	end function;


	-- Arrays term to term sumation
	function DotSum(a: natural_array; b: natural) return natural_array is
		variable ret_array : natural_array(a'range);
	begin
		for i in a'range loop
			ret_array(i) := a(i) + b;
		end loop;
		return ret_array;
	end function;

	function DotSum(a: natural_array; b: natural_array) return natural_array is
		variable ret_array : natural_array(a'range);
	begin
		for i in a'range loop
			ret_array(i) := a(i) + b(i);
		end loop;
		return ret_array;
	end function;

	function DotSum(a: real_array; b: real) return real_array is
		variable ret_array : real_array(a'range);
	begin
		for i in a'range loop
			ret_array(i) := a(i) + b;
		end loop;
		return ret_array;
	end function;

	function DotSum(a: real_array; b: real_array) return real_array is
		variable ret_array : real_array(a'range);
	begin
		for i in a'range loop
			ret_array(i) := a(i) + b(i);
		end loop;
		return ret_array;
	end function;


	-- Cumulative summation of array values.
	function CumSum(a: natural_array) return natural is
		variable retval : natural;
	begin
		retval := 0;
		for i in a'range loop
			retval := retval + a(i);
		end loop;
		return retval;
	end function;

	function CumSum(a: real_array) return real is
		variable retval : real;
	begin
		retval := 0.0;
		for i in a'range loop
			retval := retval + a(i);
		end loop;
		return retval;
	end function;

	-- -- Binomial combination computation
	function Binomial(n : natural; k : natural) return real is
		variable result : real := 1.0;
		variable kk : natural;
	begin
		if k > n then
			return 0.0;
		elsif k = 0 or k = n then
			return 1.0;
		end if;

		-- use the smaller of k and (n - k) for numerical stability
		if k > n - k then
			kk := n - k;
		else
			kk := k;
		end if;

		for i in 1 to kk loop
			result := result * real(n - kk + i) / real(i);
		end loop;
		return result;
	end function;

	function Gain(R : natural; M : natural; N : natural) return natural is
		constant a : real := real(R * N);
		constant x : real := real(a ** real(M));
	begin
		return natural(log2(x));
	end function;


	function Bmax(Bin : natural; R : natural; M : natural; N : natural) return natural is
		constant a : real := real(R * N);
		constant b : real := log2(a);
		constant c : real := real(real(M) * b);
	begin
		return natural(c) + Bin;
	end function;


	function GetIntInputSize(data_in_size : natural; is_signed: boolean) return natural is
	begin
		if (is_signed) then
			return data_in_size;
		end if;
		return data_in_size + 1;
	end function GetIntInputSize;


	-- Return array with accumulator size optimized following Hogenauer's pruning theory.
	-- R: Decimation factor
	-- N: Order
	-- M: Differential delay
	-- Note: For up to 7th-order filter design.
	function CicRegSize(Pruning: boolean; Bin : natural;  Bout : natural; R : natural; N : natural; M : natural) return coeff_t is
		-- Define "FsubJ" values for up to seven cascaded combs
		constant FsubJforManyCombs : real_array(0 to 6) := (
			sqrt(2.0), sqrt(6.0), sqrt(20.0), sqrt(70.0),
			sqrt(252.0), sqrt(924.0), sqrt(3432.0));
		-- Compute column vector of "half log base 2 of 6/N" terms
		constant HalfLog2of6overN :real := 0.5 * log2(6.0/real(N));
		--
		variable BsubJ : coeff_t(0 to 2*N);
		variable HsubJ : real_array(0 to ((R*M-1)*N + N - 2));
		variable FsubJ : real_array(0 to 2*N);
		variable MinusLog2ofFsubJ : real_array(FsubJ'low to FsubJ'high);
		variable DeltaHsubJ : real;
		variable CicFilterGain : natural;
		variable NumOfBitsGrowth: natural;
		variable NumOutputBitsWithNoTruncation: natural;
		variable NumOfOutputBitsTruncated: natural;
		variable OutputTruncationNoiseVariance: real;
		variable OutputTruncationNoiseStandardDeviation: real;
		variable Log2ofOutputTruncationNoiseStandardDeviation: real;
	begin

		if (Pruning = false) then
			for i in 1 to 2*N loop
				BsubJ(i) := Bmax(Bin, R, M, N);
			end loop;
			return BsubJ;
		end if;

		-- Find Hsubj and Fsubj values for (N-1) cascaded integrators
		for j in N-2 downto 0 loop
			for k in 0 to (R * M - 1) * N + j loop
				HsubJ(k) := 0.0;
				for L in 0 to integer(floor(real(k)/real(R*M))) loop -- Use uppercase "L" for loop variable
					-- Can't do in in VHDL:
					-- DeltaHsubJ := (-1)**real(L) * Binomial(N, L) * Binomial(N-j-1+k-R*M*L, k-R*M*L);
					-- because VHDL '**' operator raise error if 
					-- base is negative and exponent is different than 0.
					-- So we use the following 'if' statement:
					if (L mod 2) = 0 then
						DeltaHsubJ :=
							Binomial(N, L) * Binomial(N-j-1+k-R*M*L, k-R*M*L);
					else
						DeltaHsubJ :=
							-1.0 * Binomial(N, L) * Binomial(N-j-1+k-R*M*L, k-R*M*L);
					end if;
					HsubJ(k) :=  HsubJ(k) + DeltaHsubJ;
				end loop;
			end loop;
			FsubJ(j) := sqrt(CumSum(DotProd(HsubJ, HsubJ)));
		end loop;

		-- Compute F_sub_j for last integrator stage
		FsubJ(N-1) := FsubJforManyCombs(N-2) * (sqrt(real(R*M)));  -- Last integrator

		-- Compute F_sub_j for N cascaded filter's comb stages
		for j in 2*N-1 downto N loop
			FsubJ(j) := FsubJforManyCombs(2*N-j-1);
		end loop;

			-- Define "F_sub_j" values for the final output register truncation
		FsubJ(2*N) := 1.0; -- Final output register truncation

		-- Compute column vector of minus log base 2 of "F_sub_j" values
		MinusLog2ofFsubJ := -DotLog2(FsubJ);

		-- Compute total "Output_Truncation_Noise_Variance" terms
		CicFilterGain := (R*M)**N;
		NumOfBitsGrowth := integer(ceil(log2(real(CicFilterGain))));

		-- The following is from Hogenauer's Eq. (11)
		NumOutputBitsWithNoTruncation := NumOfBitsGrowth + Bin;
		NumOfOutputBitsTruncated := NumOutputBitsWithNoTruncation - Bout;
		OutputTruncationNoiseVariance := real(2**(NumOfOutputBitsTruncated*2)) / 12.0;
		OutputTruncationNoiseStandardDeviation := sqrt(OutputTruncationNoiseVariance);
		Log2ofOutputTruncationNoiseStandardDeviation := log2(OutputTruncationNoiseStandardDeviation);

		-- report " ";
		-- report "OutputTruncationNoiseVariance: " & real'image(OutputTruncationNoiseVariance);
		-- report "OutputTruncationNoiseStandardDeviation: " & real'image(OutputTruncationNoiseStandardDeviation);
		-- report "Log2ofOutputTruncationNoiseStandardDeviation: " & real'image(Log2ofOutputTruncationNoiseStandardDeviation);
		-- report " ";
		-- report "N = " & integer'image(N) &
		-- 	", R = " & integer'image(R) &
		-- 	", M = " & integer'image(M) &
		-- 	", Bin = " & integer'image(Bin) &
		-- 	", Bout = " & integer'image(Bout);
		-- report "Num of Bits Growth Due To CIC Filter Gain = " & integer'image(NumOfBitsGrowth);
		-- report "Num of Accumulator Bits With No Truncation = " & integer'image(NumOutputBitsWithNoTruncation);
		-- report " ";

		-- Compute bit truncation vector of accumulator vector
		BsubJ := DotFloor(
			DotSum(
				DotSum(
					MinusLog2ofFsubJ,
					Log2ofOutputTruncationNoiseStandardDeviation
					),
				HalfLog2of6overN
				)
			);
		-- Include final output stage truncation
		BsubJ(2*N) := NumOfOutputBitsTruncated;

		-- "Correct" Hogenaurer's pruning method:
		-- Depending on the filter's values for N and R, Hogenaurer's pruning
		-- method lead to an initial truncation of one (or more) bit of
		-- the filter's input sequence prior to the first integrator.
		-- That decrease the signal-to-quantization noise ratio by 6 dB prior
		-- to any filtering. 
		-- To correct the method, we set B1 = 0 (no truncation) and we increase
		-- the truncation of the following integrators by one additional LSB.
		if BsubJ(0) > 1 then
			for j in 1 to BsubJ(0) loop
				BsubJ(j) := BsubJ(j) + 1;
			end loop;
			BsubJ(0) := 0;
		end if;

		-- Compute final accumulator size vector
		for j in BsubJ'range loop
			BsubJ(j) := NumOutputBitsWithNoTruncation - BsubJ(j);
		end loop;

		return BsubJ;

	end function;

end package body;