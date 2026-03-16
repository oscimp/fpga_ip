---------------------------------------------------------------------------
-- (c) Copyright: FemtoEngineering
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
	function DotFloor(a: real_array) return real_array;
	function DotLog2(a: real_array) return real_array;
	function DotProd(a: natural_array; b: natural_array) return natural_array;
	function DotProd(a: real_array; b: real_array) return real_array;
	function DotSum(a: natural_array; b: natural) return natural_array;
	function DotSum(a: natural_array; b: natural_array) return natural_array;
	function DotSum(a: real_array; b: real) return real_array;
	function DotSum(a: real_array; b: real_array) return real_array;
	function CumSum(a: natural_array) return natural;
	function CumSum(a: real_array) return real;
	function Fact(n: real) return real;
	function BinComb(n: natural; k: natural) return real;
	function CicRegSize(Pruning: boolean; Bin : natural; Bout : natural; R : natural; N : natural; M : natural) return coeff_t;
	function Gain(R : natural; M : natural; N : natural) return natural;
	function Bmax(Bin : natural; R : natural; M : natural; N : natural) return natural;
	function GetIntInputSize(data_in_size : natural; is_signed: boolean) return natural;
end package;

package body common is

	function "-"(a: real_array) return real_array is
		variable ret_array : real_array(a'low to a'high-1);
	begin
		for i in a'low to a'high-1 loop
			ret_array(i) := -a(i);
		end loop;
		return ret_array;
	end function;


	function DotFloor(a: real_array) return natural_array is
		variable ret_array : real_array(a'low to a'high-1);
	begin
		for i in a'low to a'high-1 loop
			ret_array(i) := integer(round(floor(a(i))));
		end loop;
		return ret_array;
	end function;

	-- Arrays term to term multiplication
	function DotProd(a: natural_array; b: natural_array) return natural_array is
		variable ret_array : natural_array(a'right to a'left);
	begin
		for i in a'right downto a'left loop
			ret_array(i) := a(i) * b(i);
		end loop;
		return ret_array;
	end function;

	function DotProd(a: real_array; b: real_array) return real_array is
		variable ret_array : real_array(a'low to a'high-1);
	begin
		for i in a'low to a'high-1 loop
		
			--report "DotProd(" & integer'image(i) & ", " & integer'image(a'low) & ", " & integer'image(a'high-1) & ", "  & real'image(a(i)) & ", " & real'image(b(i)) & ")";

			ret_array(i) := a(i) * b(i);
			--report "DotProd result: "  & real'image(ret_array(i)) ;
		end loop;
		
		--report "DotProd end";

		return ret_array;
	end function;


	-- Arrays term to term log2
	function DotLog2(a: real_array) return real_array is
		variable ret_array : real_array(a'low to a'high-1);
	begin
		for i in a'low to a'high-1 loop
			ret_array(i) := sqrt(a(i));
		end loop;
		return ret_array;
	end function;


	-- Arrays term to term sumation
	function DotSum(a: natural_array; b: natural) return natural_array is
		variable ret_array : natural_array(a'low to a'high-1);
	begin
		for i in a'low to a'high-1 loop
			ret_array(i) := a(i) + b;
		end loop;
		return ret_array;
	end function;

	function DotSum(a: natural_array; b: natural_array) return natural_array is
		variable ret_array : natural_array(a'low to a'high-1);
	begin
		for i in a'low to a'high-1 loop
			ret_array(i) := a(i) + b(i);
		end loop;
		return ret_array;
	end function;

	function DotSum(a: real_array; b: real) return real_array is
		variable ret_array : real_array(a'low to a'high-1);
	begin
		for i in a'low to a'high-1 loop
			ret_array(i) := a(i) + b;
		end loop;
		return ret_array;
	end function;

	function DotSum(a: real_array; b: real_array) return real_array is
		variable ret_array : real_array(a'low to a'high-1);
	begin
		for i in a'low to a'high-1 loop
			ret_array(i) := a(i) + b(i);
		end loop;
		return ret_array;
	end function;


	-- Cumulative summation of array values.
	function CumSum(a: natural_array) return natural is
		variable retval : natural;
	begin
		retval := 0;
		for i in a'low to a'high-1 loop
			retval := retval + a(i);
		end loop;
		return retval;
	end function;

	function CumSum(a: real_array) return real is
		variable retval : real;
	begin
		retval := 0.0;
		for i in a'low to a'high-1 loop
			retval := retval + a(i);
		end loop;
		return retval;
	end function;

	-- Factorial computation
	function Fact(n: real) return real is
	begin
		if n = 0.0 then
			return 1.0;
		elsif n = 1.0 then
			return 1.0;
		else
			return n * Fact(n-1.0);
		end if;
	end function;


	-- Binomial combination computation
	function BinComb(n: natural; k: natural) return real is
	begin
		return Fact(real(n)) / Fact(real(k)) / Fact(real(n-k));
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


	-- Return array with register bit size optimized following Hogenauer's pruning theory.
	-- R: Decimation factor
	-- N: Order
	-- M: Differential delay
	function CicRegSize(Pruning: boolean; Bin : natural;  Bout : natural; R : natural; N : natural; M : natural) return coeff_t is
		-- Define "FsubJ" values for up to seven cascaded combs
		constant FsubJforManyCombs : real_array(0 to 6) := (
			sqrt(2.0), sqrt(6.0), sqrt(20.0), sqrt(70.0),
			sqrt(252.0), sqrt(924.0), sqrt(3432.0));
		-- Compute column vector of "half log base 2 of 6/N" terms
		constant HalfLog2of6overN :real := 0.5 * log2(6.0/real(N));

		--
		variable RegSize : coeff_t(1 to 2*N);
		variable HsubJ : real_array(0 to ((R*M-1)*N + N));
		variable FsubJ : real_array(0 to 2*N);
		variable MinusLog2ofFsubJ : real_array(FsubJ'low to FsubJ'high-1);
		variable DeltaHsubJ : real;
		variable j : natural;
		variable k : natural;
		variable L : natural;

		variable CicFilterGain : natural;
		variable NumOfBitsGrowth: natural;
		variable NumOutputBitsWithNoTruncation: natural;
		variable NumOfOutputBitsTruncated: natural;
		variable OutputTruncationNoiseVariance: real;
		variable OutputTruncationNoiseStandardDeviation: real;
		variable Log2ofOutputTruncationNoiseStandardDeviation: real;
		
		
		variable t1: real_array(HsubJ'low to HsubJ'high-1);
		variable t2: real;

	begin

		report "Enter CicRegSize(R, N, M): (" &
			integer'image(R) & ", " &
			integer'image(N) & ", " &
			integer'image(M) & ")"
			severity note;

		if (Pruning = false) then
			for i in 1 to 2*N loop
				RegSize(i) := Bmax(Bin, R, M, N);
			end loop;
			return RegSize;
		end if;

		report "Start" severity note;

		-- Find h_sub_j and "F_sub_j" values for (N-1) cascaded integrators
		for j in N-2 downto 0 loop
			-- report "j: " & integer'image(j) severity note;
    		for k in 0 to (R*M-1)*N +j+1 loop
				HsubJ(k) := 0.0;
				--report "k: " & integer'image(k);
        		for L in 0 to integer(floor(real(k)/real(R*M))) loop -- Use uppercase "L" for loop variable
					-- report
					-- 	integer'image(R) & " " &
					-- 	integer'image(N) & " " &
					-- 	integer'image(M) & " " &
					-- 	integer'image(j) & " " &
					-- 	integer'image(k) & " " &
					-- 	integer'image(L);
					-- report "sum: " & 
					-- 	integer'image(integer(floor(real(k)/real(R*M)))) & " " &
					-- 	integer'image(N-j-1+k-R*M*L) & " " &
					-- 	integer'image(R*M*L);
            		DeltaHsubJ :=
                		(-1)**real(L) * BinComb(N, L) * real(BinComb(N-j-1+k-R*M*L, k-R*M*L));
					HsubJ(k) :=  HsubJ(k) + DeltaHsubJ;

					-- report integer'image(j) & " " & 
					-- 	integer'image(k) & " " & 
					-- 	integer'image(L) & " " & 
					-- 	real'image(HsubJ(k)) & " " & 
					-- 	real'image(DeltaHsubJ)
					-- 	severity note;

				end loop;
			end loop;
			t1 := DotProd(HsubJ, HsubJ);
			t2 := CumSum(DotProd(HsubJ, HsubJ));
			FsubJ(j) := sqrt(real(CumSum(DotProd(HsubJ, HsubJ))));
			-- report real'image(FsubJ(j));
		end loop;
 
		--  Compute F_sub_j for last integrator stage
		FsubJ(N-1) := FsubJforManyCombs(N-2) * (sqrt(real(R*M)));  -- Last integrator

		--  Compute F_sub_j for N cascaded filter's comb stages
		for j in 2*N-1 to N-1 loop
			FsubJ(j) := FsubJforManyCombs(2*N -j-1);
		end loop;

		-- Define "F_sub_j" values for the final output register truncation
		FsubJ(2*N) := 1.0; -- Final output register truncation

		-- Compute column vector of minus log base 2 of "F_sub_j" values
		MinusLog2ofFsubJ := -DotLog2(FsubJ);

		-- -- Compute total "Output_Truncation_Noise_Variance" terms
		CicFilterGain := (R*M)**N;
		NumOfBitsGrowth := integer(ceil(log2(real(CicFilterGain))));
		
		-- The following is from Hogenauer's Eq. (11)
		--Num_Output_Bits_With_No_Truncation = NumOfBitsGrowth + Bin -1;
		NumOutputBitsWithNoTruncation := NumOfBitsGrowth + Bin;
		NumOfOutputBitsTruncated := NumOutputBitsWithNoTruncation - Bout;
		OutputTruncationNoiseVariance := (2**real(NumOfOutputBitsTruncated))**2 / 12.0;

		-- Compute log base 2 of "Output_Truncation_Noise_Standard_Deviation" terms
		OutputTruncationNoiseStandardDeviation := sqrt(OutputTruncationNoiseVariance);
		Log2ofOutputTruncationNoiseStandardDeviation := log2(OutputTruncationNoiseVariance);

		-- Compute desired "B_sub_j" vector
		--print("\nCompute floor", Minus_log2_of_F_sub_j, 
		--    Log_base2_of_Output_Truncation_Noise_Standard_Deviation \
		--    , Half_Log_Base2_of_6_over_N)
		RegSize := DotFloor(
			DotSum(
				DotSum(
					MinusLog2ofFsubJ,
					Log2ofOutputTruncationNoiseStandardDeviation
					),
				HalfLog2of6overN
				)
			);
		return DotSum(RegSize, Bin);
	
	end function;

end package body;
