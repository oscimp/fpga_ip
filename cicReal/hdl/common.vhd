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
	--constant taps_hb_filter : integer := 32;
	--constant data_width : integer := 24;
	--constant coeff_width : integer := 24;

	--type data_array is array (0 to taps_hb_filter - 1) of signed(data_width - 1 downto 0);
	--type coeff_array is array (0 to taps_hb_filter - 1) of std_logic_vector(coeff_width - 1 downto 0);
	--type product_array is array (0 to taps_hb_filter - 1) of signed((data_width + coeff_width) - 1 downto 0);

	function Gain(R : natural; M : natural; N : natural) return natural;
	function Bmax(Bin : natural; R : natural; M : natural; N : natural) return natural;
	function calc_R_N(R : natural; N : natural) return real;
	function sqrt(d : unsigned) return unsigned;
end package;

package body common is

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

	function calc_R_N(R : natural; N : natural) return real is
	begin
		return real(R * N);
	end function;

	function sqrt(d : unsigned) return unsigned is
		variable a : unsigned(31 downto 0) := d; --original input.
		variable q : unsigned(15 downto 0) := (others => '0'); --result.
		variable left, right, r : unsigned(17 downto 0) := (others => '0'); --input to adder/sub.r-remainder.
		variable i : integer := 0;
	begin
		for i in 0 to 15 loop
			right(0) := '1';
			right(1) := r(17);
			right(17 downto 2) := q;
			left(1 downto 0) := a(31 downto 30);
			left(17 downto 2) := r(15 downto 0);
			a(31 downto 2) := a(29 downto 0); --shifting by 2 bit.

			if (r(17) = '1') then
				r := left + right;
			else
				r := left - right;
			end if;

			q(15 downto 1) := q(14 downto 0);
			q(0) := not r(17);
		end loop;

		return q;
	end sqrt;
end package body;
